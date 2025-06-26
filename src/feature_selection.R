# Correlation analysis
cor_analysis <- function(data) {
  cor_matrix <- cor(data[, 1:25])  
  print("Correlation Matrix:")
  print(cor_matrix)
  
  # Visualizing the correlation matrix with a heatmap
  heatmap(cor_matrix, 
          main = "Correlation Matrix of Features", 
          col = terrain.colors(20), 
          scale = "none", 
          Rowv = NA, 
          Colv = NA)
  
  # Identifying highly correlated features (correlation > 0.9)
  high_corr_pairs <- which(abs(cor_matrix) > 0.9 & upper.tri(cor_matrix), arr.ind = TRUE)
  print("Highly correlated feature pairs:")
  print(high_corr_pairs)
  
  # Features to remove based on correlation analysis
  features_to_remove <- colnames(data[, 1:25])[unique(high_corr_pairs[, 2])]
  print("Features to remove based on correlation analysis:")
  print(features_to_remove)
  
  return(list(cor_matrix = cor_matrix, features_to_remove = features_to_remove))
}

# ANOVA analysis
anova_analysis <- function(data) {
  anova_results <- lapply(data[, 1:25], function(x) {
    aov(x ~ Expression, data = data)  
  })
  
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