# Facial Expression Recognition via Measurable Features

A machine learning pipeline for classifying facial expressions using interpretable geometric features extracted from the Cohn-Kanade dataset. Fully implemented in R as part of an MSc project on supervised and unsupervised learning.

---

## 🎓 Academic Context

This project was completed as part of the **DAMA 51 – Foundations in Computer Science** module  
in the MSc program **Data Science and Machine Learning** at the **Hellenic Open University (HOU)**.

- 🔗 [MSc program overview](https://www.eap.gr/en/data-science-and-machine-learning/)  
- 📚 [Full list of modules](https://www.eap.gr/en/data-science-and-machine-learning/topics/)  
- 📄 [DAMA 51 module description](https://www.eap.gr/en/data-science-and-machine-learning/topics/#dama51)

---

## 📁 Project Structure

- `data/` – Cleaned dataset of facial expression measurements  
- `src/` – Modular R scripts: preprocessing, modeling, evaluation  
- `report/` – Full analytical report (PDF)  
- `presentation/` – Slide deck summarizing methods and results (PowerPoint)

---

## 📊 Dataset Overview

- **Instances:** 210  
- **Features:** 25 geometric features (distances and angles) derived from facial landmarks  
- **Labels:** 7 emotions – Anger, Disgust, Fear, Happiness, Sadness, Surprise, Neutral  

---

## 🧠 Machine Learning Pipeline

- **Preprocessing:** Outlier capping, Winsorization, ANOVA for feature selection, PCA for dimensionality reduction  
- **Supervised Models:** Naïve Bayes, Decision Tree, K-Nearest Neighbors (KNN)  
- **Unsupervised Methods:** K-Means clustering, Gaussian Mixture Models (GMM), DBSCAN  
- **Evaluation Metrics:** Accuracy, Precision, Recall, F1-score, Confusion Matrices, Silhouette Scores  

> 📌 See `report/` and `presentation/` for detailed methodology, results, and interpretation.

---

## 🚀 How to Run

1. Open RStudio in the project root directory  
2. Run the main script `src/main.R` to execute the full pipeline  
3. Ensure the required packages are installed:  
   - `readxl`, `caret`, `rpart`, `rpart.plot`, `dbscan`, `mclust`, `cluster`, `factoextra`  
4. See `src/setup.R` for package installation helper function  

---

## 📄 License and Dataset

This repository and its contents are for academic and non-commercial use only.

The dataset features are derived from the [Cohn-Kanade Facial Expression Database](https://www.pitt.edu/~emotion/ck-spread.htm).  
Original facial images are not included and remain subject to the original dataset’s licensing terms.

For dataset access and licensing details, consult the dataset owners’ website.

---