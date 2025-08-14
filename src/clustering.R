cluster <- function(pca_data, true_labels = NULL, method = c("kmeans", "gmm", "dbscan"),
                         k = NA, eps = NA, minPts = NA) {
  
    method <- match.arg(method)
    X <- as.data.frame(pca_data)
    dist_mat <- dist(X)
    
    # Check for required parameters based on the method
    if (method %in% c("kmeans", "gmm") && is.na(k)) {
      stop("For 'kmeans' and 'gmm' methods, the number of clusters 'k' must be specified.")
    }
    
    if (method == "dbscan" && (is.na(eps) || is.na(minPts))) {
      stop("For 'dbscan' method, 'eps' and 'minPts' must be specified.")
    }
  
    out <- list()
    clusters <- NULL
    sil <- NA
    sil_avg <- NA
    
    if (method == "kmeans") {
        set.seed(42)
        km <- kmeans(X, centers = k, nstart = 25)
        clusters <- km$cluster
        sil <- silhouette(clusters, dist_mat)
        sil_avg <- if (is.matrix(sil)) mean(sil[, 3]) else NA
        out$object <- km
    
    } else if (method == "gmm") {
        gmm <- Mclust(X, G = k)
        clusters <- gmm$classification
        sil <- silhouette(clusters, dist_mat)
        sil_avg <- if (is.matrix(sil)) mean(sil[, 3]) else NA
        out$object <- gmm
    
    } else if (method == "dbscan") {
        db <- dbscan(X, eps = eps, minPts = minPts)
        clusters <- db$cluster
        
        # remove noise (cluster 0)
        if (any(clusters == 0)) {
            keep <- clusters != 0
            if (sum(keep) > 2) {
                sil <- silhouette(clusters[keep], dist(X[keep, , drop = FALSE]))
                sil_avg <- if (is.matrix(sil)) mean(sil[, 3]) else NA
            } else {
                sil <- NA 
                sil_avg <- NA
            }
        } else {
            sil <- silhouette(clusters, dist_mat)
            sil_avg <- if (is.matrix(sil)) mean(sil[, 3]) else NA
            }
        out$object <- db
    }
    
    out$clusters <- clusters
    out$silhouette <- sil
    out$silhouette_avg <- sil_avg
    
    # True-label comparisons
    if (!is.null(true_labels)) {
        if (length(true_labels) != length(clusters)) stop("true_labels length must match pca_data rows")
            out$ARI <- adjustedRandIndex(as.integer(factor(true_labels)), as.integer(factor(clusters)))
            out$confusion <- table(Cluster = clusters, Label = true_labels)
        } else {
            out$ARI <- NA
            out$confusion <- NULL
        }
    
    return(out)

}