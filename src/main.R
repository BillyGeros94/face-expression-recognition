source("setup.R")
source("load_data.R")
source("preprocessing.R")
source("feature_selection.R")
source("split_data.R")
source("pca.R")
source("model_training.R")
source("model_evaluation.R")
source("clustering.R")

# Install and load packages
install_and_load(packages)

# Load data
Facial_data <- load_data()

# Class Distribution
plot_class_distribution(Facial_data)

# Extract the feature data
features_data <- Facial_data[, 1:25]
labels <- Facial_data$Expression
                       
# Check for missing values
count_missing(features_data)

# Outlier detection and fixing
outlier_diagnostics(features_data)

hist(features_data$R3, main = "Histogram of R3", col = "lightblue", breaks = 30)
plot(density(features_data$R3), main = "Density Plot of R3", col = "red", lwd = 2)

features_data <- outlier_fix(features_data)

hist(features_data$R3, main = "Histogram of R3", col = "lightblue", breaks = 30)
plot(density(features_data$R3), main = "Density Plot of R3", col = "red", lwd = 2)

outlier_diagnostics(features_data)

# Apply Winsorization
features_data <- Winsorization(features_data)

# Pairwise scatter plots for feature groups
pairwise_plot_group(features_data, "Left_Eyebrow")
pairwise_plot_group(features_data, "Right_Eyebrow")
pairwise_plot_group(features_data, "Left_Eye")
pairwise_plot_group(features_data, "Right_Eye")
pairwise_plot_group(features_data, "Mouth")
pairwise_plot_group(features_data, "Relationships")

# Boxplots for features per Expression
plot_expression_group(Facial_data,"H1-H6")
plot_expression_group(Facial_data,"H7-H12")
plot_expression_group(Facial_data,"H13-L3")
plot_expression_group(Facial_data,"W")
plot_expression_group(Facial_data,"R")

# Correlation analysis
cor_results <- cor_analysis(features_data)

# ANOVA analysis
data_for_anova <- cbind(features_data, Expression = labels)
anova_results <- anova_analysis(data_for_anova)

# Extract relevant variables from the results
features_to_remove <- cor_results$features_to_remove
significant_features <- anova_results$significant_features

# Final features after excluding highly correlated ones
final_features <- setdiff(significant_features, features_to_remove)
print("Final selected features after combining correlation and ANOVA results:")
print(final_features)

# Create new data frame with only the selected features
final_data <- features_data[, final_features]

# Boxplot to check for outliers in the final features
boxplot(final_data, main = "Final Selected Features", col = "lightblue", las = 2)

final_data = cbind(final_data, Expression = labels)

# Split the dataset (80% train, 20% test)
split_result <- split_process(final_data)

train_data <- split_result$train_data
test_data <- split_result$test_data

# Perform PCA
pca_result <- pca_process(split_result$train_data, split_result$test_data)

train_pca <- pca_result$train_pca
test_pca <- pca_result$test_pca

# Train Models with PCA
models_pca <- train_models(train_pca)

# Evaluate models
nb_results <- evaluate_model(models_pca$nb, test_pca)
dt_results <- evaluate_model(models_pca$dt, test_pca)
knn_results <- evaluate_model(models_pca$knn, test_pca)

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
models_raw <- train_models(train_data)

# Evaluate models
nb_before_results <- evaluate_model(models_raw$nb, test_data)
dt_before_results <- evaluate_model(models_raw$dt, test_data)
knn_before_results <- evaluate_model(models_raw$knn, test_data)

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
pred_probs_before <- predict(models_raw$nb, newdata = test_data, type = "prob")

# Histogram for each class
par(mfrow = c(2, 4))
for (i in 1:ncol(pred_probs_before)) {
  hist(pred_probs_before[, i], main = colnames(pred_probs_before)[i], xlab = "Probability", col = "lightblue", border = "black")
}

# Compute confusion matrices before PCA
nb_cm_before <- confusionMatrix(predict(models_raw$nb, test_data), test_data$Expression)
dt_cm_before <- confusionMatrix(predict(models_raw$dt, test_data), test_data$Expression)
knn_cm_before <- confusionMatrix(predict(models_raw$knn, test_data), test_data$Expression)

# Print confusion matrices
cat("\nConfusion Matrix for Naive Bayes:\n")
print(nb_cm_before$table)

cat("\nConfusion Matrix for Decision Tree:\n")
print(dt_cm_before$table)

cat("\nConfusion Matrix for KNN:\n")
print(knn_cm_before$table)

par(mfrow = c(1, 1))

# Remove Expressions column
features_only <- final_data[, -which(names(final_data) == "Expression")]

# Perform PCA
pca_results <- pca_transform(features_only)
pca_data <- pca_results$pca_data

# Apply K-means
cluster(pca_data, method = "kmeans")

# Apply GMM
cluster(pca_data, method = "gmm")

# Apply DBSCAN
cluster(pca_data, method = "dbscan")
