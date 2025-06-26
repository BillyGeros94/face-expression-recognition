load_data <- function() {
  # Set up a path to read the file
  path <- file.choose()
  
  # Read the file
  Facial_data  <- read_excel(path)
  
  return(Facial_data)
}