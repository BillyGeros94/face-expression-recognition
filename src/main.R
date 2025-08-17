source("src/setup.R")
source("src/load_data.R")
source("src/eda.R")
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

# Parallel processing
if (requireNamespace("doParallel", quietly = TRUE)) {
  cores <- max(1, parallel::detectCores() - 1)
  doParallel::registerDoParallel(cores)
  on.exit(doParallel::stopImplicitCluster(), add = TRUE)
}

# Train Models with PCA
res_pca <- train_models(train_data, global_seed = GLOBAL_SEED, use_pca = TRUE)
models_pca    <- res_pca$models
selected_pca  <- res_pca$selected_vars
preproc_pca   <- res_pca$preproc

# Transform full predictor matrix
x_train_trans_pca <- predict(preproc_pca, train_data[, setdiff(names(train_data), "Expression"), drop = FALSE])
x_test_trans_pca  <- predict(preproc_pca, test_data[,  setdiff(names(test_data),  "Expression"), drop = FALSE])

# Subset transformed matrices to the selected variables
train_final_pca <- as.data.frame(x_train_trans_pca[, selected_pca, drop = FALSE])
train_final_pca$Expression <- train_data$Expression

test_final_pca  <- as.data.frame(x_test_trans_pca[, selected_pca, drop = FALSE])
test_final_pca$Expression <- test_data$Expression

# Evaluate models
train_levels <- levels(train_data$Expression)
nb_results <- evaluate_model(models_pca$nb, test_final_pca, train_levels = train_levels)
dt_results <- evaluate_model(models_pca$dt, test_final_pca, train_levels = train_levels)
knn_results <- evaluate_model(models_pca$knn, test_final_pca, train_levels = train_levels)

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

# Get probabilities for each class after PCA (use transformed & selected test set)
pred_probs <- predict(models_pca$nb, newdata = test_final_pca, type = "prob")

# Histogram for each class
par(mfrow = c(2, 4))
for (i in 1:ncol(pred_probs)) {
  hist(pred_probs[, i], main = colnames(pred_probs)[i], xlab = "Probability", col = "lightblue", border = "black")
}

# Compute confusion matrices after PCA (use transformed & selected test set)
nb_cm <- confusionMatrix(predict(models_pca$nb, test_final_pca), test_final_pca$Expression)
dt_cm <- confusionMatrix(predict(models_pca$dt, test_final_pca), test_final_pca$Expression)
knn_cm <- confusionMatrix(predict(models_pca$knn, test_final_pca), test_final_pca$Expression)

# Print confusion matrices
cat("\nConfusion Matrix for Naive Bayes:\n")
print(nb_cm$table)

cat("\nConfusion Matrix for Decision Tree:\n")
print(dt_cm$table)

cat("\nConfusion Matrix for KNN:\n")
print(knn_cm$table)

# Train Models without PCA
res_raw <- train_models(train_data, global_seed = GLOBAL_SEED, use_pca = FALSE)
models_raw   <- res_raw$models
selected_raw <- res_raw$selected_vars
preproc_raw  <- res_raw$preproc

x_train_trans_raw <- predict(preproc_raw, train_data[, setdiff(names(train_data), "Expression"), drop = FALSE])
x_test_trans_raw  <- predict(preproc_raw, test_data[,  setdiff(names(test_data),  "Expression"), drop = FALSE])

train_final_raw <- as.data.frame(x_train_trans_raw[, selected_raw, drop = FALSE])
train_final_raw$Expression <- train_data$Expression

test_final_raw  <- as.data.frame(x_test_trans_raw[, selected_raw, drop = FALSE])
test_final_raw$Expression <- test_data$Expression

# Evaluate models
train_levels_raw <- levels(train_data$Expression)
nb_before_results <- evaluate_model(models_raw$nb, test_final_raw,train_levels = train_levels_raw)
dt_before_results <- evaluate_model(models_raw$dt, test_final_raw,train_levels = train_levels_raw)
knn_before_results <- evaluate_model(models_raw$knn, test_final_raw,train_levels = train_levels_raw)

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
pred_probs_before <- predict(models_raw$nb, newdata = test_final_raw, type = "prob")

# Histogram for each class
par(mfrow = c(2, 4))

for (i in 1:ncol(pred_probs_before)) {
  hist(pred_probs_before[, i], main = colnames(pred_probs_before)[i], xlab = "Probability", col = "lightblue", border = "black")
}

# Compute confusion matrices before PCA
nb_cm_before <- confusionMatrix(predict(models_raw$nb, test_final_raw), test_final_raw$Expression)
dt_cm_before <- confusionMatrix(predict(models_raw$dt, test_final_raw), test_final_raw$Expression)
knn_cm_before <- confusionMatrix(predict(models_raw$knn, test_final_raw), test_final_raw$Expression)

# Print confusion matrices
cat("\nConfusion Matrix for Naive Bayes:\n")
print(nb_cm_before$table)

cat("\nConfusion Matrix for Decision Tree:\n")
print(dt_cm_before$table)

cat("\nConfusion Matrix for KNN:\n")
print(knn_cm_before$table)

par(mfrow = c(1, 1))

# Minimal metadata 
metadata <- list(
  saved_at = Sys.time(),
  seed = GLOBAL_SEED,
  runs = list(
    raw = list(selected_vars = selected_raw, models = list(nb = "artifacts/models/nb_raw.rds", dt = "artifacts/models/dt_raw.rds", knn = "artifacts/models/knn_raw.rds")),
    pca = list(selected_vars = selected_pca, models = list(nb = "artifacts/models/nb_pca.rds", dt = "artifacts/models/dt_pca.rds", knn = "artifacts/models/knn_pca.rds"))
  ),
  session_info = capture.output(sessionInfo())
)
jsonlite::write_json(metadata, "artifacts/models/metadata.json", pretty = TRUE, auto_unbox = TRUE)

saveRDS(metadata, "artifacts/models/metadata.rds")

numeric_c <- names(train_data)[sapply(train_data, is.numeric)]
cluster_data <- train_data[, numeric_c, drop = FALSE]
pca_cluster_data <- pca_transform(cluster_data, var_threshold = 0.8)
pca_data <- pca_cluster_data$pca_data

labels_all <- as.character(train_data$Expression)
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