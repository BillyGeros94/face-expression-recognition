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
- `api/` – API folder containing the serialized model and Plumber API script

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

## ⚙️ API Usage

This project includes a **Plumber-based API** for real-time facial expression prediction using the trained KNN model.

### Locally (R Session)

1. Make sure the **R package `plumber`** is installed.

2. Run the API script located in the api/ folder inside an interactive R session (R console or RStudio):
   
   ```r
   library(plumber)
   pr <- plumb('path/to/api/api.R')
   pr$run(host='0.0.0.0', port=8000)
   ```

3. The API listens on all network interfaces (0.0.0.0) at port 8000.

4. Access the Swagger UI at: http://localhost:8000/__swagger__/

### Using Docker

1. Build the Docker image (run once):

   ```bash 
   docker build -t fer-api:1.0 api/
   ```

2. Run the container:

   ```bash 
   docker run -d -p 8000:8000 fer-api:1.0
   ```

3. The API listens on all network interfaces (0.0.0.0) at port 8000.

4. Access the Swagger UI at: http://localhost:8000/__swagger__/

### API Structure

Health check: /health

Swagger UI: /__docs__/

Prediction endpoint: /predict
---

## 📄 License and Dataset

This repository and its contents are for academic and non-commercial use only.

The dataset features are derived from the [Cohn-Kanade Facial Expression Database](https://www.pitt.edu/~emotion/ck-spread.htm).  
Original facial images are not included and remain subject to the original dataset’s licensing terms.

For dataset access and licensing details, consult the dataset owners’ website.

---