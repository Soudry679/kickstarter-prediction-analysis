# Kickstarter Prediction & Expected Value Analysis

This repository contains an R script (`Kickstarter_prediction&analysis.R`) that addresses two key tasks related to Kickstarter project data:

## 📌 Overview

1. **Prediction Model (Question 1):**  
   Build and evaluate a decision tree model to predict whether a Kickstarter project will succeed, using features such as funding goal, category, staff pick status, and launch time.

2. **Expected Value Analysis (Question 2):**  
   Compare the business value (expected monetary return) of the prediction model against a simple rule-based approach (based solely on the `staff_pick` flag).

---

## 📁 Files

- `Kickstarter_prediction&analysis.R`: Full R script with clear block structure for each question.
- `kickstarter_projects.csv`: The dataset used for both modeling and evaluation.
- Output files (e.g., predictions, HTML summary) are generated during execution.

---

## 🧱 Feature Engineering (Shared Across Q1 & Q2)

To ensure consistency and efficiency, all feature engineering steps are performed once at the beginning of the script and reused in both questions. These include:

- Creating `state_indfac` as a factor version of the target variable
- Calculating `global_currency` by multiplying `goal` and `currency_rate`
- Converting categorical fields like `staff_pick`, `country`, and `category` into factors
- Deriving time-based factors like `deadline_dayfac` and `launched_at_monthfac`

This shared preprocessing ensures both the predictive model and the expected value evaluation operate on the same well-prepared dataset.

---

## 🧪 Methodology

### 🔹 Question 1: Predictive Modeling
- Model: Decision Tree (`rpart` via `caret`)
- Evaluation metric: **Recall** (focus on detecting successful projects)
- Data split: 80% training / 20% testing

### 🔹 Question 2: Business Value Analysis
- Simple rule: If `staff_pick == TRUE` → predict success
- Cost and return structure:
  - Successful project + video = **+$250**
  - Successful project, no video = **+$100**
  - Failed project + video = **−$50**
  - Failed project, no video = **$0**
- Data split: 70% training / 30% testing
- Metric: **Expected Value (EV)** for both models

---

## ✅ Results
- Confusion matrices and recall values are printed in the console.
- EV comparison determines whether the ML model provides financial benefit over the simple rule.
- Value of switching to the ML model is calculated based on 100,000 future predictions.

---

## 🛠 Requirements
Make sure the following R packages are installed:
```r
install.packages(c("caret", "dplyr", "rpart", "rpart.plot", "stargazer"))
```

---

## 📌 How to Run
Open `Kickstarter_prediction&analysis.R` in RStudio or your R environment and run the script from top to bottom. Ensure `kickstarter_projects.csv` is in your working directory.

---

## 📬 Contact
For questions or feedback, feel free to reach out.

---

*Created as part of a Business Intelligence course project.*
