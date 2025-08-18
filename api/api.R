#* @apiTitle Facial Expression Recognition via Measurable Features
#* @apiDescription This API utilizes a KNN model to predict facial expressions 
#* based on the trained features.

library(plumber)
library(here)

# Resolve model paths relative to the project root
model_path    <- here::here("artifacts", "models", "knn_raw.rds")
metadata_path <- here::here("artifacts", "models", "metadata.rds")
preproc_path  <- here::here("artifacts", "models", "preproc_raw.rds")


# Sanity checks
if (!file.exists(model_path)) stop("Model not found at: ", model_path)
if (!file.exists(metadata_path)) stop("Metadata not found at: ", metadata_path)
if (!file.exists(preproc_path)) stop("Preproc not found at: ", preproc_path)


model <- readRDS(model_path)
metadata <- readRDS(metadata_path)
preproc <- readRDS(preproc_path)

expected_features <- metadata$runs$raw$selected_vars
train_levels <- levels(model$trainingData$.outcome)

#* Health
#* @get /health
function() {
    list(status = "ok", message = "API running")
}

#* Predict
#* @post /predict
function(H1 = NULL, H2 = NULL, H3 = NULL, H4 = NULL, L1 = NULL,
         H5 = NULL, H6 = NULL, H7 = NULL, H8 = NULL, L2 = NULL,
         H9 = NULL, H10 = NULL, W1 = NULL, H11 = NULL, H12 = NULL,
         W2 = NULL, H13 = NULL, H14 = NULL, H15 = NULL, W3 = NULL,
         L3 = NULL, R1 = NULL, R2 = NULL, R3 = NULL, R4 = NULL, res) {
  
    # Collect all inputs
    params <- list(H1=H1, H2=H2, H3=H3, H4=H4, L1=L1, H5=H5, H6=H6, H7=H7, H8=H8, L2=L2,
                   H9=H9, H10=H10, W1=W1, H11=H11, H12=H12, W2=W2, H13=H13, H14=H14, 
                   H15=H15, W3=W3, L3=L3, R1=R1, R2=R2, R3=R3, R4=R4)
  
    # Convert to numeric safely
    numeric_vec <- vapply(params, function(x) {
        if (is.null(x)) return(NA_real_)
        suppressWarnings(as.numeric(x))
    }, numeric(1))
  
    if (any(is.na(numeric_vec))) {
        bad <- names(numeric_vec)[is.na(numeric_vec)]
        res$status <- 400
        return(list(
          error = "Invalid input",
          details = list(
            missing_or_non_numeric = bad
          )
        ))
    }
  
    # Build single-row data frame with all 25 features
    input_df <- as.data.frame(t(numeric_vec), stringsAsFactors=FALSE)
    names(input_df) <- names(numeric_vec)
  
    # Apply preprocessing (on full feature set)
    processed_all <- predict(preproc, newdata=input_df)
  
    # Apply RFE feature selection
    input_processed <- processed_all[, expected_features, drop=FALSE]
  
    # Predict
    pred  <- predict(model, input_processed)
    probs <- predict(model, input_processed, type="prob")
  
    return(list(prediction=as.character(pred),
         probabilities=as.list(as.data.frame(probs))))
}