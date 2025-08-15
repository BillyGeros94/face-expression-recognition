source("src/setup.R")
source("src/load_data.R")
source("src/preprocessing.R")
source("src/feature_selection.R")
source("src/split_data.R")
source("src/pca.R")
source("src/model_training.R")
source("src/model_evaluation.R")
source("src/clustering.R")

# Install and load packages
install_and_load_from_file("./packages.txt")

GLOBAL_SEED <- 42

# Load data
Facial_data <- load_data(file_path = "./data/cohn-kanade-rev_new.xls")

# Class Distribution
plot_class_distribution(Facial_data)

# Extract the feature data
numeric_cols <- names(Facial_data)[sapply(Facial_data, is.numeric)]
features_data <- Facial_data[, numeric_cols[1:25], drop = FALSE]
labels <- as.factor(Facial_data$Expression)
features_data = cbind(features_data, Expression = labels)

# Missing Values
count_missing(features_data)

# Split the dataset (80% train, 20% test)
split_result <- split_process(features_data, seed = GLOBAL_SEED)

train_data <- split_result$train_data
test_data <- split_result$test_data

# Pairwise scatter plots for feature groups
pairwise_plot_group(train_data, "Left_Eyebrow")
pairwise_plot_group(train_data, "Right_Eyebrow")
pairwise_plot_group(train_data, "Left_Eye")
pairwise_plot_group(train_data, "Right_Eye")
pairwise_plot_group(train_data, "Mouth")
pairwise_plot_group(train_data, "Relationships")

# Boxplots for features per Expression
plot_expression_group(train_data,"H1-H6")
plot_expression_group(train_data,"H7-H12")
plot_expression_group(train_data,"H13-L3")
plot_expression_group(train_data,"W")
plot_expression_group(train_data,"R")

# Outlier detection R3
outlier_diagnostics(train_data, col_name = "R3")

hist(train_data$R3, main = "Histogram of R3", col = "lightblue", breaks = 30)
plot(density(train_data$R3), main = "Density Plot of R3", col = "red", lwd = 2)

# R3 outlier fix
r3_upper <- iqr_lim(train_data,col_name = "R3")
train_data <- iqr_outlier_fix(train_data, r3_upper, col_name = "R3")
test_data <- iqr_outlier_fix(test_data,  r3_upper, col_name = "R3")

hist(train_data$R3, main = "Histogram of R3 (Fixed)", col = "lightblue", breaks = 30)
plot(density(train_data$R3), main = "Density Plot of R3 (Fixed)", col = "red", lwd = 2)

# Apply Winsorization on data
winsor_bounds <- wins_lim(train_data)
train_data <- apply_winsor(train_data, winsor_bounds)
test_data  <- apply_winsor(test_data,  winsor_bounds)

# ANOVA analysis
data_for_anova <- cbind(train_data)
anova_results <- anova_analysis(data_for_anova)

# candidate features are those significant by ANOVA (raw p < 0.05)
candidate_features <- anova_results$significant_features
if (length(candidate_features) == 0) {
  stop("No candidate features found by ANOVA — check your data or ANOVA threshold.")
}
pvals <- anova_results$p_values

# Correlation analysis
cor_results <- cor_analysis(train_data[, candidate_features, drop = FALSE], 
                            p_values = pvals[candidate_features])

# Final features after excluding highly correlated ones
final_features <- setdiff(candidate_features, cor_results$features_to_remove)
if (length(final_features) == 0) {
  stop("No final features left after correlation pruning — relax thresholds or review p-values.")
}
print("Final selected features after combining ANOVA and correlation results:")
print(final_features)

# Data checks
length(final_features)
setdiff(final_features, names(train_data))
setdiff(final_features, names(test_data))

# Create new data frame with only the selected features
train_final_features <- train_data[, final_features]
test_final_features <- test_data[, final_features]

# Boxplot to check for outliers in the final features
boxplot(train_final_features, main = "Final Selected Features", col = "lightblue", las = 2)

train_final <- cbind(train_final_features, Expression = train_data$Expression)
test_final <- cbind(test_final_features, Expression = test_data$Expression)

# Data Checks
sapply(train_final_features, function(x) is.numeric(x))
sum(is.na(train_final))
sum(is.na(test_final))
table(train_final$Expression)
table(test_final$Expression)

# Perform PCA
pca_result <- pca_process(train_final, test_final)

if (is.null(pca_result$num_pcs) || is.na(pca_result$num_pcs) || pca_result$num_pcs < 1) {
  stop("PCA did not select any principal components. Check var_threshold or feature scaling.")
}

train_pca <- pca_result$train_pca
test_pca <- pca_result$test_pca

# Data checks
is.factor(train_pca$Expression)
is.factor(test_pca$Expression)
identical(levels(train_pca$Expression), levels(test_pca$Expression))

# Train Models with PCA
models_pca <- train_models(train_pca, global_seed = GLOBAL_SEED)

# Evaluate models
train_levels <- levels(train_pca$Expression)
nb_results <- evaluate_model(models_pca$nb, test_pca, train_levels = train_levels)
dt_results <- evaluate_model(models_pca$dt, test_pca, train_levels = train_levels)
knn_results <- evaluate_model(models_pca$knn, test_pca, train_levels = train_levels)

# Combine all metrics into a data frame for comparison
metrics <- data.frame(
  Model = c("Naive Bayes", "Decision Tree", "KNN"),
  Accuracy = c(nb_results[1], dt_results[1], knn_results[1]),
  Precision = c(nb_results[2], dt_results[2], knn_results[2]),
  Recall = c(nb_results[3], dt_results[3], knn_results[3]),
  F1_Score = c(nb_results[4], dt_results[4], knn_results[4])
)

# Print the metrics for comparison
cat("\nPerformance Metrics:\n")
print(metrics)

# Visualizations
par(mfrow = c(2, 2))
metric_names <- colnames(metrics)[2:5]
colors <- c("lightblue", "lightgreen", "lightcoral", "lightpink")

# Create bar plots for each metric
for (i in 1:length(metric_names)) {
  bar_heights <- metrics[, metric_names[i]]
  bp <- barplot(bar_heights, names.arg = metrics$Model, col = colors[i], 
                main = paste("Model Comparison -", metric_names[i]), ylim = c(0, 1))
  text(bp, bar_heights, labels = round(bar_heights, 2), pos = 3, cex = 0.8)
}

# Reset plot layout
par(mfrow = c(1, 1))

# Plot the decision tree after PCA
rpart.plot(models_pca$dt$finalModel, 
           type = 3,
           extra = 101,
           fallen.leaves = TRUE,
           shadow.col = "gray",   
           box.palette = "Blues", 
           main = "Decision Tree Visualization")

# Get probabilities for each class after PCA
pred_probs <- predict(models_pca$nb, newdata = test_pca, type = "prob")

# Histogram for each class
par(mfrow = c(2, 4))
for (i in 1:ncol(pred_probs)) {
  hist(pred_probs[, i], main = colnames(pred_probs)[i], xlab = "Probability", col = "lightblue", border = "black")
}

# Compute confusion matrices after PCA
nb_cm <- confusionMatrix(predict(models_pca$nb, test_pca), test_pca$Expression)
dt_cm <- confusionMatrix(predict(models_pca$dt, test_pca), test_pca$Expression)
knn_cm <- confusionMatrix(predict(models_pca$knn, test_pca), test_pca$Expression)

# Print confusion matrices
cat("\nConfusion Matrix for Naive Bayes:\n")
print(nb_cm$table)

cat("\nConfusion Matrix for Decision Tree:\n")
print(dt_cm$table)

cat("\nConfusion Matrix for KNN:\n")
print(knn_cm$table)

# Train Models without PCA
models_raw <- train_models(train_final, global_seed = GLOBAL_SEED)

# Evaluate models
train_levels_raw <- levels(train_final$Expression)
nb_before_results <- evaluate_model(models_raw$nb, test_final,train_levels = train_levels_raw)
dt_before_results <- evaluate_model(models_raw$dt, test_final,train_levels = train_levels_raw)
knn_before_results <- evaluate_model(models_raw$knn, test_final,train_levels = train_levels_raw)

# Combine all metrics into a data frame for comparison
metrics_before <- data.frame(
  Model = c("Naive Bayes", "Decision Tree", "KNN"),
  Accuracy = c(nb_before_results[1], dt_before_results[1], knn_before_results[1]),
  Precision = c(nb_before_results[2], dt_before_results[2], knn_before_results[2]),
  Recall = c(nb_before_results[3], dt_before_results[3], knn_before_results[3]),
  F1_Score = c(nb_before_results[4], dt_before_results[4], knn_before_results[4])
)

# Print the metrics for comparison
cat("\nPerformance Metrics:\n")
print(metrics_before)

# Visualizations
par(mfrow = c(2, 2))
metric_names <- colnames(metrics)[2:5]
colors <- c("lightblue", "lightgreen", "lightcoral", "lightpink")

# Create bar plots for each metric
for (i in 1:length(metric_names)) {
  bar_heights <- metrics_before[, metric_names[i]]
  bp <- barplot(bar_heights, names.arg = metrics_before$Model, col = colors[i], 
                main = paste("Model Comparison -", metric_names[i]), ylim = c(0, 1))
  text(bp, bar_heights, labels = round(bar_heights, 2), pos = 3, cex = 0.8)
}

# Reset plot layout
par(mfrow = c(1, 1))

# Plot the decision tree before PCA
rpart.plot(models_raw$dt$finalModel, 
           type = 3,
           extra = 101,
           fallen.leaves = TRUE,
           shadow.col = "gray",   
           box.palette = "Reds", 
           main = "Decision Tree Visualization")


# Get probabilities for each class before PCA
pred_probs_before <- predict(models_raw$nb, newdata = test_final, type = "prob")

# Histogram for each class
par(mfrow = c(2, 4))
for (i in 1:ncol(pred_probs_before)) {
  hist(pred_probs_before[, i], main = colnames(pred_probs_before)[i], xlab = "Probability", col = "lightblue", border = "black")
}

# Compute confusion matrices before PCA
nb_cm_before <- confusionMatrix(predict(models_raw$nb, test_final), test_final$Expression)
dt_cm_before <- confusionMatrix(predict(models_raw$dt, test_final), test_final$Expression)
knn_cm_before <- confusionMatrix(predict(models_raw$knn, test_final), test_final$Expression)

# Print confusion matrices
cat("\nConfusion Matrix for Naive Bayes:\n")
print(nb_cm_before$table)

cat("\nConfusion Matrix for Decision Tree:\n")
print(dt_cm_before$table)

cat("\nConfusion Matrix for KNN:\n")
print(knn_cm_before$table)

par(mfrow = c(1, 1))

saveRDS(models_pca$knn, "artifacts/models/knn_pca.rds")
saveRDS(models_pca$dt,  "artifacts/models/dt_pca.rds")
saveRDS(models_pca$nb,  "artifacts/models/nb_pca.rds")

saveRDS(models_raw$knn, "artifacts/models/knn_raw.rds")
saveRDS(models_raw$dt,  "artifacts/models/dt_raw.rds")
saveRDS(models_raw$nb,  "artifacts/models/nb_raw.rds")

# save PCA object
saveRDS(pca_result$pca_model, "artifacts/models/pca_model.rds")

# Minimal metadata 
metadata <- list(
  saved_at = Sys.time(),
  seed = GLOBAL_SEED,
  final_features = final_features,
  anova_candidate_features = candidate_features,
  winsor_bounds = winsor_bounds,
  r3_upper = r3_upper,
  pca_num_pcs = pca_result$num_pcs,
  train_levels = levels(train_final$Expression),
  models = list(
    knn_pca = "artifacts/models/knn_pca.rds",
    dt_pca  = "artifacts/models/dt_pca.rds",
    nb_pca  = "artifacts/models/nb_pca.rds",
    knn_raw = "artifacts/models/knn_raw.rds",
    dt_raw  = "artifacts/models/dt_raw.rds",
    nb_raw  = "artifacts/models/nb_raw.rds"
  ),
  session_info = capture.output(sessionInfo())
)

saveRDS(metadata, "artifacts/models/metadata.rds")

if (requireNamespace("jsonlite", quietly = TRUE)) {
  jsonlite::write_json(metadata, "artifacts/models/metadata.json", pretty = TRUE, auto_unbox = TRUE)
}

cluster_data <- rbind(train_final_features, test_final_features)
pca_cluster_data <- pca_transform(cluster_data, var_threshold = 0.8)
pca_data <- pca_cluster_data$pca_data

labels_all <- c(as.character(train_final$Expression), as.character(test_final$Expression))
k_value <- length(unique(labels_all))

# kmeans clustering 
res_km <- cluster(pca_data, true_labels = labels_all, method = "kmeans", k = k_value)
print(res_km$silhouette_avg)
print(res_km$ARI)
print(res_km$confusion)

# GMM clustering
res_gmm <- cluster(pca_data, true_labels = labels_all, method = "gmm", k = k_value)
print(res_gmm$silhouette_avg) 
print(res_gmm$ARI) 
print(res_gmm$confusion)

# DBSCAN clustering
res_dbscan <- cluster(pca_data, true_labels = labels_all, method = "dbscan", 
                      eps = 1.5, minPts = 5)
print(res_dbscan$silhouette_avg) 
print(res_dbscan$ARI) 
print(res_dbscan$confusion)