cluster <- function(pca_data, method = c("kmeans", "gmm", "dbscan"),
                           k = 4, eps = 1.5, minPts = 5) {
  
  method <- match.arg(method)
  dist_mat <- dist(pca_data)
  
  if (method == "kmeans") {
    
    # Apply K-means
    kmeans_result <- kmeans(pca_data, centers = k, nstart = 25)
    
    # Visualize the clusters
    print(fviz_cluster(kmeans_result, data = pca_data, main = paste("K-means Clustering (k =", k, ")")))
    
    # Evaluate using Silhouette Score
    silhouette_score <- silhouette(kmeans_result$cluster, dist_mat)
    print(summary(silhouette_score))
    
    cat("\nConfusion Matrix (K-means):\n")
    print(table(Cluster = kmeans_result$cluster, Label = labels))
    
  } else if (method == "gmm") {
    
    # Apply GMM
    gmm_result <- Mclust(pca_data)
    
    # Visualize the clusters
    print(fviz_cluster(gmm_result, data = pca_data, main = "GMM Clustering"))
    
    # Evaluate using Silhouette Score
    gmm_clusters <- gmm_result$classification
    silhouette_score_gmm <- silhouette(gmm_clusters, dist_mat)
    print(summary(silhouette_score_gmm))
    
    cat("\nConfusion Matrix (GMM):\n")
    print(table(Cluster = gmm_clusters, Label = labels))
    
  } else if (method == "dbscan") {
    
    # Apply DBSCAN
    dbscan_result <- dbscan(pca_data, eps = eps, minPts = minPts)
    
    # Visualize the clusters
    print(fviz_cluster(dbscan_result, data = pca_data, main = "DBSCAN Clustering"))
    
    # Evaluate based on number of clusters (and noise points)
    table(dbscan_result$cluster)
    
    # Evaluate using Silhouette Score
    silhouette_score_dbscan <- silhouette(dbscan_result$cluster, dist_mat)
    print(summary(silhouette_score_dbscan))
    
    cat("\nConfusion Matrix (DBSCAN):\n")
    print(table(Cluster = dbscan_result$cluster, Label = labels))
  }
}