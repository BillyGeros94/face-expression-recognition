# Install and load packages
packages <- c("readxl", "caret", "rpart", "rpart.plot", "dbscan", 
              "mclust", "cluster", "factoextra")

install_and_load <- function(pkg_list) {
  for (pkg in pkg_list) {
    if (!require(pkg, character.only = TRUE)) {
      install.packages(pkg, dependencies = TRUE)
      library(pkg, character.only = TRUE)
    }
  }
}