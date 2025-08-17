pca_transform <- function(data, var_threshold = 0.8) {
  
    # Perform PCA
    pca_model <- prcomp(data, center = TRUE, scale. = TRUE)
  
    # Choose the first few PCs explaining ~80% variance
    variance_explained <- summary(pca_model)$importance[3, ]
    num_pcs <- which(variance_explained >= var_threshold)[1]
    if (is.na(num_pcs)) {
        num_pcs <- max(2, min(10, ncol(pca_model$x)))
    }
  
    # Transform data using selected PCs
    transformed <- as.data.frame(pca_model$x[, 1:num_pcs])
  
    list(pca_data = transformed, pca_model = pca_model, num_pcs = num_pcs, variance_explained = variance_explained)

}