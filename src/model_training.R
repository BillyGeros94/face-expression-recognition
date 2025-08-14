train_models <- function(data, target_col = "Expression", global_seed = 42,
                         cv_folds = 10, cv_repeats = 3, metric = "Accuracy") {
  
    # Define CV control (Repeated 10-Fold CV)
    ctrl <- trainControl(method = "repeatedcv",
                         number = cv_folds,
                         repeats = cv_repeats,
                         savePredictions = "final",
                         classProbs = TRUE,
                         verboseIter = FALSE)
  
    # Build formula dynamically
    formula <- as.formula(paste(target_col, "~ ."))
  
    # Train Models Only
    models <- list()
  
    # Naive Bayes
    set.seed(global_seed + 1)
    models$nb <- train(formula, data = data, method = "nb",
                       trControl = ctrl,
                       metric = metric,
                       tuneGrid = expand.grid(fL = c(0, 0.5, 1),
                                              usekernel = c(TRUE, FALSE),
                                              adjust = c(0.5, 1, 1.5)))
  
    # Decision Tree
    set.seed(global_seed + 2)
    models$dt <- train(formula, data = data, method = "rpart",
                       trControl = ctrl,
                       metric = metric,
                       tuneLength = 6,
                       parms = list(split = "information"),
                       control = rpart.control(maxdepth = 6, minsplit = 10, minbucket = 5))
  
    # KNN (kknn)
    set.seed(global_seed + 3)
    models$knn <- train(
                        formula, data = data,
                        method = "kknn",
                        trControl = ctrl,
                        metric = metric,
                        tuneGrid = expand.grid(kmax = seq(3, 11, by = 2), 
                                               distance = c(1,2), 
                                               kernel = c("inv","triangular")
                                              )
                       )
  
    return(models)

}