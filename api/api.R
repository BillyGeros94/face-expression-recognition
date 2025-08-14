#* @apiTitle Facial Expression Recognition via Measurable Features
#* @apiDescription This API utilizes a KNN model to predict facial expressions 
#* based on the trained features.

library(plumber)

# Artifacts paths
MODEL_PATH <- "../artifacts/models/knn_raw.rds"
META_PATH  <- "../artifacts/models/metadata.rds"

# Data load
model <- readRDS(MODEL_PATH)
metadata <- readRDS(META_PATH)

# Expected features and levels
expected_features <- as.character(metadata$final_features)
train_levels <- metadata$train_levels

#* Health
#* @get /health
function() {
    list(status = "ok", message = "API running")
}

#* Predict
#* @post /predict
function(H3 = NULL, L1 = NULL, H5 = NULL, H7 = NULL, H8 = NULL,
         W2 = NULL, L3 = NULL, R1 = NULL, R3 = NULL, R4 = NULL, res) {
  
    params <- list(H3 = H3, L1 = L1, H5 = H5, H7 = H7, H8 = H8,
                 W2 = W2, L3 = L3, R1 = R1, R3 = R3, R4 = R4)
  
    # Convert each param to numeric
    numeric_vec <- vapply(params, function(x) {
    if (is.null(x)) return(NA_real_)
        suppressWarnings(as.numeric(x))
    }, numeric(1))
  
    # Detect non-numeric inputs or missing
    if (any(is.na(numeric_vec))) {
        bad <- names(numeric_vec)[is.na(numeric_vec)]
        res$status <- 400
        return(list(error = "All parameters must be numeric and provided.",
                missing_or_non_numeric = bad))
    }
  
    # Build single-row data.frame with correct names
    df <- as.data.frame(as.list(numeric_vec), stringsAsFactors = FALSE)
  
    # Order columns exactly as during training 
    df <- df[, expected_features, drop = FALSE]
  
    # Prediction
    pred <- predict(model, df)
    probs <- predict(model, df, type = "prob")
  
    return(list(prediction = as.character(pred), 
                probabilities = as.list(as.data.frame(probs))))
 }