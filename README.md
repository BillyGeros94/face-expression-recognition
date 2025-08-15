# Facial Expression Recognition via Measurable Features

## 📌 Project Overview
This project implements a complete **Data Science and Machine Learning pipeline** for recognizing human facial expressions based on measurable facial features. Using the **Cohn-Kanade dataset**, we extract 25 anthropometric measurements from key facial landmarks and classify them into one of seven emotional states.

The workflow covers **data preprocessing**, **feature selection**, **dimensionality reduction**, **model training and evaluation**, and the deployment of a **REST API** using [Plumber](https://www.rplumber.io/) in R, containerized via Docker.

---

## 🎯 Objectives
- Process and analyze raw anthropometric facial data.
- Identify the most relevant features for expression recognition.
- Evaluate multiple supervised learning models before and after PCA.
- Apply unsupervised clustering for exploratory analysis.
- Deploy the best-performing model as a REST API.

---

## 📂 Repository Structure
```
my_project/
├─ data/                         # Dataset(s)
│  └─ cohn-kanade-rev_new.xls
├─ src/                          # R scripts for each pipeline step
│  ├─ main.R
│  ├─ setup.R
│  ├─ load_data.R
│  ├─ preprocessing.R
│  ├─ feature_selection.R
│  ├─ split_data.R
│  ├─ pca.R
│  ├─ model_training.R
│  ├─ model_evaluation.R
│  └─ clustering.R
├─ artifacts/                    # Saved plots and trained models
│  ├─ plots/
│  └─ models/
├─ packages.txt                  # List of required R packages
├─ README.md                     # Project documentation
├─ report/                       # Final written report
│  └─ Project-Report.pdf
├─ presentation/                 # Final presentation slides
│  └─ Project-Presentation.pptx
├─ api/                          # REST API deployment files
│  ├─ api.R
│  └─ Dockerfile
```

---

## 📊 Dataset
- **Source**: Cohn-Kanade Database (modified subset).
- **Size**: 210 instances, 25 measurable features, 7 emotion classes.
- **Features**: Distances and angles from facial landmarks (eyebrows, eyes, mouth).
- **Labels**: `ANGER`, `DISGUST`, `FEAR`, `JOY`, `NEUTRAL`, `SADNESS`, `SURPRISE`.

---

## 🔬 Methodology

### **1. Data Preprocessing**
- Missing value check (none found).
- Outlier capping via IQR-based Winsorization.
- Exploratory Data Analysis with boxplots and pairwise scatterplots.

### **2. Feature Selection**
- Statistical selection using ANOVA (`p < 0.05`).
- Remove highly correlated features (`correlation > 0.8`).
- Final selection of 10 features.

### **3. Dimensionality Reduction (PCA)**
- Retained enough components to explain 80% variance.
- PCA reduced dimensionality but degraded classifier performance.

### **4. Supervised Learning**
Models tested (with and without PCA):
- **Naïve Bayes**
- **Decision Tree**
- **KNN** (best-performing model)

Evaluation:
- Repeated 10-fold cross-validation.
- Metrics: Accuracy, Precision, Recall, F1-score.

### **5. Unsupervised Learning**
- Algorithms: K-Means, Gaussian Mixture Models (GMM), DBSCAN.
- Metrics: Silhouette score, ARI, confusion matrices.
- Finding: Best separation for `SURPRISE`, poor for negative emotions.

---

## 🚀 Model Deployment
The **KNN** model was deployed as a REST API using [Plumber](https://www.rplumber.io/) and containerized with Docker.

**API Endpoints:**
- `GET /health` – Health check endpoint.
- `POST /predict` – Takes facial measurements and returns predicted emotion and probabilities.

Example request (JSON):
```json
{
  "H3": 19,
  "L1": 38,
  "H5": 20,
  "H7": 16,
  "H8": 23,
  "W2": 10,
  "L3": 24,
  "R1": 33,
  "R3": 14,
  "R4": 73
}
```

Example response:
```json
{
  "prediction": "NEUTRAL",
  "probabilities": {
    "ANGER": 0.0,
    "DISGUST": 0.0,
    "FEAR": 0.0,
    "JOY": 0.0,
    "NEUTRAL": 1.0,
    "SADNESS": 0.0,
    "SURPRISE": 0.0
  }
}
```

---

## 🐳 Running with Docker
Build the Docker image:
```bash
docker build -t face-expr-api -f api/Dockerfile . 
```
Run the container:
```bash
docker run -p 8000:8000 --rm face-expr-api
```

The API will be available at:
```
http://localhost:8000
```

---

## 📦 Installation & Requirements
**R version**: ≥ 4.2.0  
Install required packages:
```r
install.packages(scan("packages.txt", what = character()))
```
**Reproducible environment**  
This project uses `renv` for R package management. After cloning,run:
```r
R -e "renv::restore()"
``` 
to install the exact package versions recorded in `renv.lock`.  
**R version used**: 4.5.1 (recorded in `renv.lock`) — use the same R base for best compatibility.

---

## 📑 Deliverables
- **`src/`** – Full modular pipeline in R.
- **`artifacts/models/`** – Trained models and metadata.
- **`artifacts/plots/`** – Visualization outputs.
- **`report/Project-Report.pdf`** – Final written report.
- **`presentation/Project-Presentation.pptx`** – Presentation slides.
- **`api/`** – REST API implementation and Docker setup.

---

## 🧠 Key Findings
- PCA reduced model performance for this dataset.
- KNN outperformed Naïve Bayes and Decision Tree.
- Clustering methods failed to cleanly separate negative emotions.
- SURPRISE was the most easily distinguishable emotion.

---

## 📜 License
This repository and its contents are for academic and non-commercial use only.

The dataset features are derived from the [Cohn-Kanade Facial Expression Database](https://www.pitt.edu/~emotion/ck-spread.htm).  
Original facial images are not included and remain subject to the original dataset’s licensing terms.

For dataset access and licensing details, consult the dataset owners’ website.

---

## Academic Context
This project was completed as part of the **DAMA 51 – Foundations in Computer Science** module  
in the MSc program **Data Science and Machine Learning** at the **Hellenic Open University (HOU)**.

- 🔗 [MSc program overview](https://www.eap.gr/en/data-science-and-machine-learning/)  
- 📚 [Full list of modules](https://www.eap.gr/en/data-science-and-machine-learning/topics/)  
- 📄 [DAMA 51 module description](https://www.eap.gr/en/data-science-and-machine-learning/topics/#dama51)

---
