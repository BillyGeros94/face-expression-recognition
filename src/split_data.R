split_process <- function(data, target_col = "Expression", train_frac = 0.8, seed) {
  
  # Set seed for reproducibility
  set.seed(seed)
  
  # Ensure Expression is a factor
  data[[target_col]] <- as.factor(data[[target_col]])
  
  # Split the dataset (80% train, 20% test)
  train_indices <- createDataPartition(data[[target_col]], p = train_frac, list = FALSE)
  train_data <- data[train_indices, ]
  test_data <- data[-train_indices, ]
  
  print(table(train_data[[target_col]]))
  print(table(test_data[[target_col]]))
  
  list(train_data = train_data, test_data = test_data)
}