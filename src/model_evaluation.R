# Model Evaluation Function
evaluate_model <- function(model, test_data) {
  
  # Predict the classes on the test data
  predictions <- predict(model, test_data)
  
  # Generate confusion matrix
  cm <- confusionMatrix(predictions, test_data$Expression)
  
  # Calculate per-class precision, recall, and F1 score
  precision <- mean(cm$byClass[, "Precision"], na.rm = TRUE)
  recall <- mean(cm$byClass[, "Recall"], na.rm = TRUE)
  f1_score <- mean(cm$byClass[, "F1"], na.rm = TRUE)
  accuracy <- cm$overall["Accuracy"]
  
  return(c(accuracy, precision, recall, f1_score))
}