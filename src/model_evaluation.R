# Model Evaluation Function
evaluate_model <- function(model, test_data, train_levels = NULL, target_col = "Expression") {
  
    if (is.null(train_levels)) {
        train_levels <- sort(unique(as.character(test_data[[target_col]])))
    }
    
    true_f <- factor(test_data[[target_col]], levels = train_levels)
    
    preds_raw <- predict(model, test_data)
    preds_f <- factor(as.character(preds_raw), levels = train_levels)
    
    cm <- table(True = true_f, Pred = preds_f)
  
    accuracy <- if (sum(cm) == 0) NA else sum(diag(cm)) / sum(cm)
    
    classes <- train_levels
    precisions <- recalls <- f1s <- numeric(length(classes))
    names(precisions) <- names(recalls) <- names(f1s) <- classes
  
    for (i in seq_along(classes)) {
        cl <- classes[i]
        tp <- if (cl %in% rownames(cm) && cl %in% colnames(cm)) cm[cl, cl] else 0
        fp <- if (cl %in% colnames(cm)) sum(cm[, cl]) - tp else 0
        fn <- if (cl %in% rownames(cm)) sum(cm[cl, ]) - tp else 0
      
        prec <- if ((tp + fp) == 0) NA else tp / (tp + fp)
        rec <- if ((tp + fn) == 0) NA else tp / (tp + fn)
        f1 <- if (is.na(prec) || is.na(rec) || (prec + rec) == 0) NA else 2 * prec * rec / (prec + rec)
      
        precisions[i] <- prec
        recalls[i] <- rec
        f1s[i] <- f1
    }
    
    precision_macro <- mean(precisions, na.rm = TRUE)
    recall_macro    <- mean(recalls, na.rm = TRUE)
    f1_macro        <- mean(f1s, na.rm = TRUE)
    
    return(c(Accuracy = accuracy, Precision = precision_macro, 
           Recall = recall_macro, F1 = f1_macro))

}