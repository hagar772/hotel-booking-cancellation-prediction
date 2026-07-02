
# Hotel Booking Cancellation Prediction

## Overview
Predicting hotel booking cancellations using Logistic Regression in SAS,
to help hotels reduce revenue loss from last-minute cancellations.

## Problem
Hotels lose revenue when bookings are cancelled close to arrival with no
time to resell the room. This project builds a predictive model that
estimates cancellation probability at the time of booking.

## Dataset
- 20,000 hotel bookings (City Hotel & Resort Hotel)
- Target variable: `is_canceled` (0 = not cancelled, 1 = cancelled)
- Class distribution: 62.3% not cancelled / 37.7% cancelled

## Approach
1. Exploratory Data Analysis (distribution, missing values, outliers)
2. Data Cleaning (missing value imputation, outlier capping)
3. Feature Engineering (guest_loyalty_score, is_family, room_match, 
   lead_time_cat, has_special_requests)
4. Model Building: Logistic Regression (SAS PROC LOGISTIC)
5. Model Evaluation

## Results
- **AUC:** 0.84
- **Accuracy:** 79%
- **Recall:** 59%
- **Precision:** 79%

## Key Findings
- Room match is the strongest predictor: guests who get a different room
  than reserved cancel far less (likely an upgrade effect)
- Longer lead time → higher cancellation risk
- Non-refundable deposits correlate strongly with cancellations
- Guests with special requests are less likely to cancel

## Files
— SAS code for cleaning, feature engineering, and modeling
 — raw dataset
 — full project report (PDF)

## Tools
SAS (PROC LOGISTIC, PROC UNIVARIATE, PROC FREQ, PROC GLMMOD)
