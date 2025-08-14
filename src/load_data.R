load_data <- function(file_path) {
 
    if (!file.exists(file_path)) stop("Data file not found: ", file_path) 
  
    # Read the file
    Facial_data  <- read_excel(file_path)
 
    return(as.data.frame(Facial_data))

}