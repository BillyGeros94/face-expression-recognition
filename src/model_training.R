train_models <- function(data, target_col = "Expression") {
  
  # Define CV control (Repeated 10-Fold CV)
  ctrl <- trainControl(method = "repeatedcv", number = 10, repeats = 5)
  
  # Build formula dynamically
  formula <- as.formula(paste(target_col, "~ ."))
  
  # Train Models Only
  models <- list()
  
  # Naive Bayes
  models$nb <- train(formula, data = data, method = "nb",
                     trControl = ctrl,
                     tuneGrid = expand.grid(fL = seq(0, 1, by = 0.2),
                                            usekernel = c(TRUE, FALSE),
                                            adjust = seq(0.5, 2, by = 0.5)))
  
  # Decision Tree
  models$dt <- train(formula, data = data, method = "rpart",
                     trControl = ctrl,
                     tuneGrid = expand.grid(cp = seq(0.001, 0.05, by = 0.001)),
                     parms = list(split = "information"),
                     control = rpart.control(maxdepth = 6,
                                             minsplit = 10,
                                             minbucket = 5))
  
  # KNN
  models$knn <- train(
    formula, data = data,
    method = "kknn",
    trControl = ctrl,
    tuneGrid = expand.grid(
      kmax = seq(3, 15, 2),
      distance = c(1, 2),
      kernel = c("inv", "gaussian", "triangular", "optimal")
    )
  )
  
  return(models)
}