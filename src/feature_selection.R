# Correlation analysis
cor_analysis <- function(data, p_values, thresh = 0.8, plot = TRUE) {
 
    cor_matrix <- cor(data, use = "pairwise.complete.obs")  
    
    # Visualizing the correlation matrix with a heatmap
    if (plot) {
      heatmap(cor_matrix, main = "Correlation Matrix of Features",
              col = terrain.colors(20), scale = "none", Rowv = NA, Colv = NA)
    }
  
    # Identifying highly correlated features (correlation > 0.9)
    pairs_idx <- which(abs(cor_matrix) > thresh & upper.tri(cor_matrix), arr.ind = TRUE)
    print("Highly correlated feature pairs:")
    print(pairs_idx)
    
    features_to_remove <- character(0)
    for (r in seq_len(nrow(pairs_idx))) {
        i <- pairs_idx[r, 1]
        j <- pairs_idx[r, 2]
        f1 <- colnames(cor_matrix)[i]
        f2 <- colnames(cor_matrix)[j]
      
        # prefer ANOVA p-values
        drop <- NA_character_
        if (all(c(f1, f2) %in% names(p_values))) {
            p1 <- p_values[[f1]]
            p2 <- p_values[[f2]]
            if (p1 > p2) drop <- f1 else if (p2 >= p1) drop <- f2
        }  
        # Features to remove based on correlation analysis
        features_to_remove <- c(features_to_remove, drop)
    }
    
    features_to_remove <- unique(features_to_remove)
    features_to_remove <- na.omit(features_to_remove)

    list(cor_matrix = cor_matrix,
         pairs_idx = pairs_idx,
         features_to_remove = features_to_remove,
         thresh = thresh)

}

# ANOVA analysis
anova_analysis <- function(data) {
  
    numeric_cols <- names(data)[sapply(data, is.numeric)]
    features_to_analyze <- numeric_cols[numeric_cols != "Expression"]
    
    anova_results <- lapply(features_to_analyze, function(x) {
        aov(as.formula(paste(x, "~ Expression")), data = data)  
    })
  
    names(anova_results) <- features_to_analyze
    
    # Extracting p-values from the ANOVA results
    p_values <- sapply(anova_results, function(model) {
      summary(model)[[1]]$`Pr(>F)`[1]  
    })
  
    print("ANOVA p-values:")
    print(p_values)
  
    # Selecting significant features based on ANOVA (p-value < 0.05)
    significant_features <- names(p_values)[p_values < 0.05]
    print("Significant features based on ANOVA:")
    print(significant_features)
  
    return(list(p_values = p_values, significant_features = significant_features))

}