# Model Evaluation Function
evaluate_model <- function(model, data, train_levels = NULL, target_col = "Expression") {
  
    if (is.null(train_levels)) {
        train_levels <- sort(unique(as.character(data[[target_col]])))
    }
    
    true <- factor(data[[target_col]], levels = train_levels)
    pred <- factor(as.character(predict(model, data)), levels = train_levels)
    
    cm <- table(True = true, Pred = pred)
  
    accuracy <- sum(diag(cm)) / sum(cm)
    
    precisions <- diag(cm) / colSums(cm)
    recalls    <- diag(cm) / rowSums(cm)
    f1s        <- 2 * precisions * recalls / (precisions + recalls)
    
    metrics <- c(
      Accuracy  = accuracy,
      Precision = mean(precisions, na.rm = TRUE),
      Recall    = mean(recalls,    na.rm = TRUE),
      F1        = mean(f1s,        na.rm = TRUE)
    )
    
    return(metrics)
}