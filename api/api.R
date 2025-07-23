#* @apiTitle Facial Expression Recognition via Measurable Features

#* @apiDescription This API utilizes a KNN model to predict facial expressions based 
#* on the 16 most meaningful numerical features

library(plumber)

model <- readRDS("./PrePCA_KNN.rds")


#* @param H1 Height of the inner left eyebrow
#* @param H2 Height of the middle left eyebrow
#* @param H3 Height of the outer left eyebrow
#* @param L1 Length of the left eyebrow
#* @param H5 Height of the inner right eyebrow
#* @param H6 Height of the middle right eyebrow
#* @param H7 Height of the outer right eyebrow
#* @param H8 Height of the right eyebrow tip
#* @param L2 Length of the right eyebrow
#* @param H10 Height of the right eye center
#* @param W2 Width of the right eye
#* @param H15 Height of the center of the mouth
#* @param W3 Width of the mouth
#* @param R1 Distance between the eyebrows
#* @param R2 Distance between eyes and mouth
#* @param R4 Distance between eye centers

#* @get /health
function(){
  
  res <- list(
    status_code = 200,
    status = "success",
    message = "The API is up and running."
  )
  
  return(res)
}

#* @post /predict
function (H1, H2, H3, L1, H5, H6, H7, H8, L2, H10, W2, H15, W3, R1, R2, R4){
  
  values <- c(H1, H2, H3, L1, H5, H6, H7, H8, L2, H10, W2, H15, W3, R1, R2, R4)
  
  if (any(is.na(suppressWarnings(as.numeric(values))))) {
    return(list(error = "All parameters must be numeric."))
  }
  
  data <- data.frame(H1 = as.numeric(H1), H2 = as.numeric(H2), H3 = as.numeric(H3), 
                        L1 = as.numeric(L1), H5 = as.numeric(H5), H6 = as.numeric(H6),
                        H7 = as.numeric(H7), H8 = as.numeric(H8), L2 = as.numeric(L2),
                        H10 = as.numeric(H10), W2 = as.numeric(W2), H15 = as.numeric(H15),
                        W3 = as.numeric(W3), R1 = as.numeric(R1), R2 = as.numeric(R2),
                        R4 = as.numeric(R4))
  
  prediction <- predict(model, data)
  
  return(list(
    prediction = as.character(prediction)
  ))
}