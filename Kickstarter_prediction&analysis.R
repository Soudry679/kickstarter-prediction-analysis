# Kickstarter Final Script: Questions 1 & 2

# ------------------------------
# Block 0: Setup, Libraries, and Data Preparation
# ------------------------------

# Load required libraries
library(caret)
library(dplyr)
library(rpart)
library(rpart.plot)
library(stargazer)

# Set working directory and seed
setwd("C:/Users/SoAv984/OneDrive - HP Inc/Desktop/Uni/אנליטיקה עסקית")
set.seed(123)

# Load data
df <- read.csv("kickstarter_projects.csv", stringsAsFactors = TRUE)

# Feature Engineering (shared for Q1 and Q2)
df$state_indfac <- factor(df$state_ind, labels = c("No", "Yes"))
df$DeadlineWeekendfac <- factor(df$DeadlineWeekend, labels = c("No", "Yes"))
df$global_currency <- df$goal * df$currency_rate
df$country <- factor(df$country)
df$staff_pick <- factor(df$staff_pick, labels = c("No", "Yes"))
df$category <- factor(df$category)
df$deadline_dayfac <- factor(df$deadline_day)
df$launched_at_monthfac <- factor(df$launched_at_month)

# ------------------------------
# Question 1: Prediction Model
# ------------------------------

# Split: 80/20 for prediction model
train_idx_q1 <- sample(nrow(df), size = floor(0.8 * nrow(df)))
train_q1 <- df[train_idx_q1, ]
test_q1 <- df[-train_idx_q1, ]

# Train decision tree model
tree_model <- train(state_indfac ~ global_currency + country + staff_pick + category +
                      DeadlineWeekendfac + deadline_dayfac + launched_at_monthfac,
                    data = train_q1,
                    method = "rpart",
                    trControl = trainControl(method = "repeatedcv", number = 5, repeats = 1),
                    control = rpart.control(maxdepth = 10, minsplit = 20, cp = 0.01))

# Plot decision tree
rpart.plot(tree_model$finalModel)

# Predict on test set
test_q1_probs <- predict(tree_model, newdata = test_q1, type = "prob")[, "Yes"]
test_q1$pred <- ifelse(test_q1_probs >= 0.5, 1, 0)

# Calculate recall
actual_positive <- sum(test_q1$state_ind == 1)
true_positive <- sum(test_q1$pred == 1 & test_q1$state_ind == 1)
recall <- true_positive / actual_positive
print(paste("Recall for Q1 model:", round(recall, 4)))

# Final Prediction on New Projects (Q1 Export)
new_projects <- read.csv("new_projects.csv", stringsAsFactors = TRUE)

# Feature engineering on new data (same as training)
new_projects$DeadlineWeekendfac <- factor(new_projects$DeadlineWeekend, labels = c("No", "Yes"))
new_projects$global_currency <- new_projects$goal * new_projects$currency_rate
new_projects$country <- factor(new_projects$country)
new_projects$staff_pick <- factor(new_projects$staff_pick, labels = c("No", "Yes"))
new_projects$category <- factor(new_projects$category)
new_projects$deadline_dayfac <- factor(new_projects$deadline_day)
new_projects$launched_at_monthfac <- factor(new_projects$launched_at_month)

# Predict on new projects
new_probs <- predict(tree_model, newdata = new_projects, type = "prob")[, "Yes"]
new_projects$pred_ind_state <- ifelse(new_probs >= 0.5, 1, 0)

# Export CSV with id and pred_ind_state
final_output <- new_projects[, c("id", "pred_ind_state")]
write.csv(final_output, "Predictions.csv", row.names = FALSE)

# ------------------------------
# Question 2: Expected Value Analysis
# ------------------------------

# Split: 70/30 for expected value evaluation
train_idx_q2 <- sample(nrow(df), size = floor(0.7 * nrow(df)))
train_q2 <- df[train_idx_q2, ]
test_q2 <- df[-train_idx_q2, ]

# --- Simple model (staff_pick rule) ---
test_q2$pred_simple <- ifelse(test_q2$staff_pick == "Yes", "Yes", "No")
test_q2$pred_simple <- factor(test_q2$pred_simple, levels = levels(test_q2$state_indfac))
conf_simple <- confusionMatrix(test_q2$pred_simple, test_q2$state_indfac, positive = "Yes")
print(conf_simple)

# Calculate expected value for simple model
tp_s <- conf_simple$table["Yes", "Yes"]
fp_s <- conf_simple$table["Yes", "No"]
fn_s <- conf_simple$table["No", "Yes"]
ev_simple <- (tp_s * 250) + (fp_s * -50) + (fn_s * 100)
print(paste("Expected Value - Simple Model:", ev_simple))

# --- Model from Q1 ---
test_q2_probs <- predict(tree_model, newdata = test_q2, type = "prob")[, "Yes"]
test_q2$pred_model <- ifelse(test_q2_probs >= 0.5, "Yes", "No")
test_q2$pred_model <- factor(test_q2$pred_model, levels = levels(test_q2$state_indfac))
conf_model <- confusionMatrix(test_q2$pred_model, test_q2$state_indfac, positive = "Yes")
print(conf_model)

# Calculate expected value for Q1 model
tp_m <- conf_model$table["Yes", "Yes"]
fp_m <- conf_model$table["Yes", "No"]
fn_m <- conf_model$table["No", "Yes"]
ev_model <- (tp_m * 250) + (fp_m * -50) + (fn_m * 100)
print(paste("Expected Value - Full Model:", ev_model))

# --- Recommendation and value of model ---
delta_ev <- ev_model - ev_simple
value_for_100k <- delta_ev * 100000 / nrow(test_q2)
print(paste("Model Value for 100,000 projects:", round(value_for_100k, 2)))
