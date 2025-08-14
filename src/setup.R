# Install and load packages
install_and_load_from_file <- function(file = "packages.txt", install_missing = TRUE) {
  
    if (!file.exists(file)) stop("packages.txt not found at: ", file)
  
    pkgs <- readLines(file, warn = FALSE)
    pkgs <- pkgs[nzchar(pkgs)]
    
    for (p in pkgs) {
        # install if missing
        if (!requireNamespace(p, quietly = TRUE)) {
            if (install_missing) {
                message("Installing missing package: ", p)
                install.packages(p, dependencies = TRUE)
            } else {
            stop("Package missing and install_missing = FALSE: ", p)
            }
        }
        # attach the package
        library(p, character.only = TRUE, quietly = TRUE, warn.conflicts = FALSE)
    }
}