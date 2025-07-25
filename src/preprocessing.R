# Class Distribution
plot_class_distribution <- function(df) {
  counts <- table(df$Expression)
  bar <- barplot(counts, main = "Class Distribution", col = "lightblue")
  text(bar, counts - 2, labels = counts, cex = 1, col = "black")
  return(invisible(counts))
}

# Check for missing values
count_missing <- function(df) {
  return(sum(is.na(df)))
}

# Outlier Detection
outlier_diagnostics <- function(data) {
boxplot(data, main = "Outlier Detection")

# Print outliers
outliers <- data$R3[data$R3 > 100]
print(outliers)
}

# Compute Q3 and IQR
outlier_fix <- function(data) {
Q3 <- quantile(data$R3, 0.75, na.rm = TRUE)
IQR_value <- IQR(data$R3, na.rm = TRUE)

# Compute the upper limit (Q3 + 1.5 * IQR)
upper_limit <- Q3 + 1.5 * IQR_value

# Cap outliers to the upper limit
data$R3[data$R3 > upper_limit] <- upper_limit

return(data)
}

Winsorization <- function(data) {
  # Boxplot BEFORE Winsorization
  boxplot(data, main = "Before Winsorization")
  
  # Function to Winsorize based on IQR
  winsorize_feature <- function(x) {
    if (is.numeric(x)) {
      q1 <- quantile(x, 0.25, na.rm = TRUE)
      q3 <- quantile(x, 0.75, na.rm = TRUE)
      iqr <- q3 - q1
      lower_bound <- q1 - 1.5 * iqr
      upper_bound <- q3 + 1.5 * iqr
      
      x[x < lower_bound] <- lower_bound
      x[x > upper_bound] <- upper_bound
    }
    return(x)
  }
  
  # Apply Winsorization
  data[] <- lapply(data, winsorize_feature)
  
  # Boxplot AFTER Winsorization
  boxplot(data, main = "After Winsorization")
  
  return(data)
}

# Pairwise scatter plots for feature groups
pairwise_plot_group <- function(data, group_name) {
  plot_groups <- list(
    Left_Eyebrow   = c("H1", "H2", "H3", "H4", "L1"),
    Right_Eyebrow  = c("H5", "H6", "H7", "H8", "L2"),
    Left_Eye       = c("H9", "H10", "W1"),
    Right_Eye      = c("H11", "H12", "W2"),
    Mouth          = c("H13", "H14", "H15", "W3", "L3"),
    Relationships  = c("R1", "R2", "R3", "R4")
  )
  
  if (!(group_name %in% names(plot_groups))) {
    stop("Invalid group name. Choose from: ", paste(names(plot_groups), collapse = ", "))
  }
  
  group_cols <- plot_groups[[group_name]]
  pairs(data[, group_cols], main = paste("Pairwise Scatter Plot for the", group_name), pch = 19)
}

# Boxplots for features per Expression
plot_expression_group <- function(data, group) {
  data$Expression <- as.factor(data$Expression)
  
  if (group == "H1-H6") {
    par(mfrow = c(2, 3))
    boxplot(H1 ~ Expression, data = data, main = "H1 by Expression", col = "lightblue")
    boxplot(H2 ~ Expression, data = data, main = "H2 by Expression", col = "lightgreen")
    boxplot(H3 ~ Expression, data = data, main = "H3 by Expression", col = "lightcoral")
    boxplot(H4 ~ Expression, data = data, main = "H4 by Expression", col = "lightpink")
    boxplot(H5 ~ Expression, data = data, main = "H5 by Expression", col = "lightyellow")
    boxplot(H6 ~ Expression, data = data, main = "H6 by Expression", col = "lightgray")
    
  } else if (group == "H7-H12") {
    par(mfrow = c(2, 3))
    boxplot(H7 ~ Expression, data = data, main = "H7 by Expression", col = "lightblue")
    boxplot(H8 ~ Expression, data = data, main = "H8 by Expression", col = "lightgreen")
    boxplot(H9 ~ Expression, data = data, main = "H9 by Expression", col = "lightcoral")
    boxplot(H10 ~ Expression, data = data, main = "H10 by Expression", col = "lightpink")
    boxplot(H11 ~ Expression, data = data, main = "H11 by Expression", col = "lightyellow")
    boxplot(H12 ~ Expression, data = data, main = "H12 by Expression", col = "lightgray")
    
  } else if (group == "H13-L3") {
    par(mfrow = c(2, 3))
    boxplot(H13 ~ Expression, data = data, main = "H13 by Expression", col = "lightblue")
    boxplot(H14 ~ Expression, data = data, main = "H14 by Expression", col = "lightgreen")
    boxplot(H15 ~ Expression, data = data, main = "H15 by Expression", col = "lightcoral")
    boxplot(L1 ~ Expression, data = data, main = "L1 by Expression", col = "lightpink")
    boxplot(L2 ~ Expression, data = data, main = "L2 by Expression", col = "lightyellow")
    boxplot(L3 ~ Expression, data = data, main = "L3 by Expression", col = "lightgray")
    
  } else if (group == "W") {
    par(mfrow = c(1, 3))
    boxplot(W1 ~ Expression, data = data, main = "W1 by Expression", col = "lightblue")
    boxplot(W2 ~ Expression, data = data, main = "W2 by Expression", col = "lightgreen")
    boxplot(W3 ~ Expression, data = data, main = "W3 by Expression", col = "lightcoral")
    
  } else if (group == "R") {
    par(mfrow = c(2, 2))
    boxplot(R1 ~ Expression, data = data, main = "R1 by Expression", col = "lightblue")
    boxplot(R2 ~ Expression, data = data, main = "R2 by Expression", col = "lightgreen")
    boxplot(R3 ~ Expression, data = data, main = "R3 by Expression", col = "lightcoral")
    boxplot(R4 ~ Expression, data = data, main = "R4 by Expression", col = "lightpink")
    
  } else {
    stop("Invalid group name. Choose from 'H1-H6', 'H7-H12', 'H13-L3', 'W', 'R'.")
  }
  
  # Reset layout
  par(mfrow = c(1, 1))
}