train_models <- function(data, target_col = "Expression", global_seed = 42, cv_folds = 10, 
                         cv_repeats = 3, metric = "Accuracy", use_pca = FALSE) {
  
    # Define CV control (Repeated 10-Fold CV)
    ctrl <- trainControl(method = "repeatedcv",
                         number = cv_folds,
                         repeats = cv_repeats,
                         savePredictions = "final",
                         classProbs = TRUE,
                         verboseIter = FALSE)

    # Set seeds
    set.seed(global_seed)
    
    # predictors / response
    x <- data[, setdiff(names(data), target_col), drop = FALSE]
    y <- data[[target_col]]
    
    # Candidate sizes
    sizes <- seq(3, min(20, ncol(x)), by = 1)
    
    # RFE control
    ctrl_rfe <- rfeControl(functions = caretFuncs, method = "repeatedcv",
                           number = cv_folds, repeats = cv_repeats, verbose = FALSE)
    
    # PCA Check
    if (isTRUE(use_pca)) {
      
      pr <- stats::prcomp(x, center = TRUE, scale. = TRUE)
      n_pcs <- min(max(sizes), ncol(pr$x))
      x_pcs <- as.data.frame(pr$x[, seq_len(n_pcs), drop = FALSE])
      colnames(x_pcs) <- paste0("PC", seq_len(n_pcs))
      
      # RFE on the PC scores
      rfe_fit <- rfe(x = x_pcs, y = y, sizes = sizes[sizes <= n_pcs], rfeControl = ctrl_rfe, metric = metric)
      
      selected_vars <- predictors(rfe_fit)
      if (length(selected_vars) == 0) stop("RFE returned zero selected variables.")
      
      preproc_full <- pr

    } else {
      
      rfe_fit <- rfe(x = x, y = y, sizes = sizes, rfeControl = ctrl_rfe,
                     metric = metric, preProcess = c("center", "scale"))
      
      selected_vars <- predictors(rfe_fit)
      if (length(selected_vars) == 0) stop("RFE returned zero selected variables (raw path).")
      
      # Fit preprocessing on training data
      preproc_full <- caret::preProcess(x, method = c("center", "scale"))
      x_pcs <- predict(preproc_full, x)
    }
    
    # Build the final training data from transformed predictors + target
    data_sel <- as.data.frame(x_pcs[, selected_vars, drop = FALSE])
    data_sel[[target_col]] <- y
    
    # Build formula dynamically
    formula <- as.formula(paste(target_col, "~ ."))
  
    # Train Models Only
    models <- list()
  
    # Naive Bayes
    set.seed(global_seed)
    models$nb <- train(formula, data = data_sel, method = "nb",
                       trControl = ctrl,
                       metric = metric,
                       tuneGrid = expand.grid(fL = c(0, 0.5, 1),
                                              usekernel = c(TRUE, FALSE),
                                              adjust = c(0.5, 1, 1.5)))
  
    # Decision Tree
    set.seed(global_seed + 1)
    models$dt <- train(formula, data = data_sel, method = "rpart",
                       trControl = ctrl,
                       metric = metric,
                       tuneLength = 6,
                       parms = list(split = "information"),
                       control = rpart.control(maxdepth = 6, minsplit = 10, minbucket = 5))
  
    # KNN (kknn)
    set.seed(global_seed + 2)
    models$knn <- train(
                        formula, data = data_sel,
                        method = "kknn",
                        trControl = ctrl,
                        metric = metric,
                        tuneGrid = expand.grid(kmax = seq(3, 11, by = 2), 
                                               distance = c(1,2), 
                                               kernel = c("inv","triangular")
                                              )
                       )
  
    # Artifacts
    suffix <- if (use_pca) "_pca" else "_raw"
    dir.create("artifacts/models", showWarnings = FALSE, recursive = TRUE)
    saveRDS(rfe_fit, file = paste0("artifacts/models/rfe_fit", suffix, ".rds"))
    saveRDS(preproc_full, file = paste0("artifacts/models/preproc", suffix, ".rds"))
    saveRDS(models$nb, file = paste0("artifacts/models/nb", suffix, ".rds"))
    saveRDS(models$dt, file = paste0("artifacts/models/dt", suffix, ".rds"))
    saveRDS(models$knn, file = paste0("artifacts/models/knn", suffix, ".rds"))
    
    return(list(models = models,
                selected_vars = selected_vars,
                rfe = rfe_fit,
                preproc = preproc_full,
                suffix = suffix,
                n_pcs = if (isTRUE(use_pca)) n_pcs else NULL))
}