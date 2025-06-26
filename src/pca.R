pca_process <- function(train_data, test_data, target_col = "Expression") {
  
  train_features <- train_data[, !(names(train_data) %in% target_col)]
  test_features <- test_data[, !(names(test_data) %in% target_col)]
  
  # Perform PCA
  pca_model <- prcomp(train_features, center = TRUE, scale. = TRUE)
  
  # Check variance explained by each component
  print(summary(pca_model))
  
  # Choose the first few PCs explaining ~80% variance
  variance_explained <- summary(pca_model)$importance[3, ]
  num_pcs <- which(variance_explained >= 0.8)[1]
  
  # Transform datasets using selected PCs
  train_pca <- as.data.frame(pca_model$x[, 1:num_pcs])
  test_pca <- as.data.frame(predict(pca_model, newdata = test_features)[, 1:num_pcs])
  
  # Reattach target variable
  train_pca[[target_col]] <- train_data[[target_col]]
  test_pca[[target_col]] <- test_data[[target_col]]
  
  # Check dimensions
  print(dim(train_pca))
  print(dim(test_pca))
  
  list(
    train_pca = train_pca,
    test_pca = test_pca,
    pca_model = pca_model,
    num_pcs = num_pcs,
    variance_explained = variance_explained
  )
}

pca_transform <- function(data, var_threshold = 0.8) {
  
  # Perform PCA
  pca_model <- prcomp(data, center = TRUE, scale. = TRUE)
  
  # Choose the first few PCs explaining ~80% variance
  variance_explained <- summary(pca_model)$importance[3, ]
  num_pcs <- which(variance_explained >= var_threshold)[1]
  
  # Transform data using selected PCs
  transformed <- as.data.frame(pca_model$x[, 1:num_pcs])
  
  list(pca_data = transformed, pca_model = pca_model, num_pcs = num_pcs, variance_explained = variance_explained)
}