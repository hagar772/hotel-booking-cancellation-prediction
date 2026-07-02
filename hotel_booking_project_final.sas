/**--------- HOTEL BOOKING CANCELLATION PREDICTION -------
DATASET: hotel_booking.csv (~119,000 rows)
TARGET  : is_canceled (1 = cancelled, 0 = not cancelled)  **/
/*      IMPORT THE DATASET          */
FILENAME REFFILE "/home/u64501847/hotel_booking (2).csv";

PROC IMPORT DATAFILE=REFFILE DBMS=CSV OUT=work.hotel_data;
    GETNAMES=YES;
RUN;

/*           Explore the dataset structure         */
PROC CONTENTS DATA=work.hotel_data;
    TITLE "Dataset Structure - Column Names and Types";
RUN;

/*   Preview the first 10 rows */
PROC PRINT DATA=work.hotel_data (OBS=10);
    TITLE "Raw Data Preview - First 10 Rows";
RUN;

/* Summary statistics for all numeric columns */
PROC MEANS DATA=work.hotel_data N NMISS MEAN STD MIN MAX;
    TITLE "Summary Statistics - Raw Data";
RUN;

/*                      INVESTIGATE THE DATA                    */

/* --- VIZ 1: Cancellation class balance ---*/
PROC SGPLOT DATA=work.hotel_data;
    VBAR is_canceled / DATALABEL FILLATTRS=(COLOR=CXADD8E6);
    TITLE "VIZ 1 - Cancellation Class Distribution (Raw Data)";
    XAXIS LABEL="Cancelled (1) vs Not Cancelled (0)";
    YAXIS LABEL="Number of Bookings";
RUN;

/* --- VIZ 2: Cancellation rate by hotel type ---*/
PROC SGPLOT DATA=work.hotel_data;
    VBAR hotel / GROUP=is_canceled GROUPDISPLAY=CLUSTER;
    TITLE "VIZ 2 - Cancellations by Hotel Type";
    XAXIS LABEL="Hotel Type";
    YAXIS LABEL="Number of Bookings";
    KEYLEGEND / TITLE="Cancelled";
RUN;

/* --- VIZ 3: Lead time distribution --- */
PROC SGPLOT DATA=work.hotel_data;
    HISTOGRAM lead_time / FILLATTRS=(COLOR=CX87CEEB);
    DENSITY lead_time;
    TITLE "VIZ 3 - Distribution of Lead Time (Days Before Arrival)";
    XAXIS LABEL="Lead Time (Days)";
    YAXIS LABEL="Frequency";
RUN;

/* --- VIZ 4: Lead time vs cancellation status ---*/
PROC SGPLOT DATA=work.hotel_data;
    VBOX lead_time / CATEGORY=is_canceled FILLATTRS=(COLOR=CXFFA07A);
    TITLE "VIZ 4 - Lead Time vs Cancellation Status";
    XAXIS LABEL="Cancelled (1) vs Not Cancelled (0)";
    YAXIS LABEL="Lead Time (Days)";
RUN;

/* --- VIZ 5: ADR (Average Daily Rate) distribution --- */
PROC SGPLOT DATA=work.hotel_data;
    HISTOGRAM adr / FILLATTRS=(COLOR=CX90EE90);
    DENSITY adr;
    TITLE "VIZ 5 - Distribution of ADR (Average Daily Rate) - Raw";
    XAXIS LABEL="ADR (Price per Night)";
    YAXIS LABEL="Frequency";
RUN;

/* --- VIZ 6: ADR vs cancellation status ---*/
PROC SGPLOT DATA=work.hotel_data;
    VBOX adr / CATEGORY=is_canceled FILLATTRS=(COLOR=CXDDA0DD);
    TITLE "VIZ 6 - Room Price (ADR) vs Cancellation Status";
    XAXIS LABEL="Cancelled (1) vs Not Cancelled (0)";
    YAXIS LABEL="ADR (Price per Night)";
RUN;

/* --- VIZ 7: Market segment distribution --- */
PROC SGPLOT DATA=work.hotel_data;
    VBAR market_segment / DATALABEL FILLATTRS=(COLOR=CXF0E68C);
    TITLE "VIZ 7 - Market Segment Distribution";
    XAXIS LABEL="Market Segment";
    YAXIS LABEL="Number of Bookings";
RUN;

/* --- VIZ 8: Outlier detection in ADR and Lead Time --- */
PROC SGPLOT DATA=work.hotel_data;
    VBOX adr;
    TITLE "VIZ 8a - Outliers in ADR (Before Cleaning)";
RUN;

PROC SGPLOT DATA=work.hotel_data;
    VBOX lead_time;
    TITLE "VIZ 8b - Outliers in Lead Time (Before Cleaning)";
RUN;

/* Missing value counts and categorical frequencies - BEFORE cleaning */
PROC MEANS DATA=work.hotel_data N NMISS;
    TITLE "Missing Values Count - BEFORE Cleaning";
RUN;

PROC FREQ DATA=work.hotel_data;
    TABLES children country agent company / MISSING;
    TITLE "BEFORE Cleaning - Missing in Key Categorical Columns";
RUN;

/* Outlier investigation using full percentile detail */
PROC UNIVARIATE DATA=work.hotel_data;
    VAR adr lead_time;
    TITLE "BEFORE Cleaning - Percentile Detail for Outlier Thresholds";
RUN;

/* Categorical value consistency check */
PROC FREQ DATA=work.hotel_data;
    TABLES hotel market_segment deposit_type customer_type reserved_room_type /
        MISSING;
    TITLE "Categorical Values Consistency Check - BEFORE Cleaning";
RUN;

/* Correlation analysis between key numeric variables */
ODS GRAPHICS ON;

PROC CORR DATA=work.hotel_data PLOTS=MATRIX;
    VAR lead_time adr stays_in_week_nights stays_in_weekend_nights adults
        total_of_special_requests previous_cancellations;
    TITLE "Correlation Analysis - Key Numeric Features";
RUN;

/*               FIX THE DATA (DATA CLEANING)                  */
DATA work.hotel_clean;
    SET work.hotel_data;

    /* Fix missing numeric values */
    IF children=. THEN children=0;
    IF agent=. THEN agent=0;
    IF company=. THEN company=0;

    /* Fix missing character values */
    IF country='' THEN country='Unknown';

    /* Fix impossible and extreme ADR values */
    IF adr < 0 THEN adr=0;
    IF adr > 252 THEN adr=252;

    /* Cap lead time at 1 year */
    IF lead_time > 365 THEN lead_time=365;

    /* Standardize categorical text formatting */
    hotel=PROPCASE(STRIP(hotel));
    market_segment=PROPCASE(STRIP(market_segment));
    deposit_type=PROPCASE(STRIP(deposit_type));
    customer_type=PROPCASE(STRIP(customer_type));

RUN;

/* ---- AFTER Cleaning Validation ---- */
PROC MEANS DATA=work.hotel_clean N NMISS;
    TITLE "Missing Values Count - AFTER Cleaning";
RUN;

/* ADR before vs after: compare the box plot from VIZ 8a
to this one. The extreme outliers should now be gone. */
PROC SGPLOT DATA=work.hotel_clean;
    VBOX adr;
    TITLE "VIZ 9 - ADR Outliers AFTER Cleaning";
RUN;

PROC SGPLOT DATA=work.hotel_clean;
    VBOX lead_time;
    TITLE "VIZ 10 - Lead Time Outliers AFTER Cleaning";
RUN;

PROC SGPLOT DATA=work.hotel_clean;
    HISTOGRAM adr / FILLATTRS=(COLOR=CX98FB98);
    DENSITY adr;
    TITLE "VIZ 11 - ADR Distribution AFTER Cleaning";
    XAXIS LABEL="ADR (Price per Night)";
    YAXIS LABEL="Frequency";
RUN;

PROC PRINT DATA=work.hotel_clean (OBS=10);
    TITLE "Preview of Cleaned Dataset";
RUN;

PROC CONTENTS DATA=work.hotel_clean;
    TITLE "Final Clean Dataset Structure";
RUN;

/*                            FEATURE ENGINEERING                         */
DATA work.hotel_features;
    SET work.hotel_clean;

    /* --------FEATURE 1: guest_loyalty_score----------- */
    guest_loyalty_score=0;
    IF previous_bookings_not_canceled > 0 THEN guest_loyalty_score + 1;
    IF is_repeated_guest=1 THEN guest_loyalty_score + 1;

    /* ----------FEATURE 2: is_family----------------- */
    IF children > 0 OR babies > 0 THEN is_family=1;
    ELSE is_family=0;

    /* --------------FEATURE 3: room_match------------ */
    IF reserved_room_type=assigned_room_type THEN room_match=1;
    ELSE room_match=0;

    /* ------------FEATURE 4: lead_time_cat----------- */
    LENGTH lead_time_cat $14;
    IF lead_time <= 7 THEN lead_time_cat='Last Minute';
    ELSE IF lead_time <= 30 THEN lead_time_cat='Short Term';
    ELSE IF lead_time <= 90 THEN lead_time_cat='Medium Term';
    ELSE IF lead_time <= 180 THEN lead_time_cat='Long Term';
    ELSE lead_time_cat='Very Long Term';

    /* ------FEATURE 5: has_special_requests---------*/
    IF total_of_special_requests > 0 THEN has_special_requests=1;
    ELSE has_special_requests=0;

RUN;

/*          Visualize the engineered features vs cancellation           */

/* --- VIZ 12: Cancellation rate by lead time category --- */
PROC SGPLOT DATA=work.hotel_features;
    VBAR lead_time_cat / GROUP=is_canceled GROUPDISPLAY=CLUSTER DATALABEL;
    TITLE
        "VIZ 12 - Cancellation Rate by Lead Time Category (Engineered Feature)";
    XAXIS LABEL="Lead Time Category";
    YAXIS LABEL="Number of Bookings";
    KEYLEGEND / TITLE="Cancelled";
RUN;

/* --- VIZ 13: Cancellation rate by guest loyalty score --- */
PROC SGPLOT DATA=work.hotel_features;
    VBAR guest_loyalty_score / GROUP=is_canceled GROUPDISPLAY=CLUSTER DATALABEL
        FILLATTRS=(COLOR=CXFFDAB9);
    TITLE
        "VIZ 13 - Cancellation Rate by Guest Loyalty Score (Engineered Feature)";
    XAXIS LABEL="Guest Loyalty Score (0=New, 2=Loyal)";
    YAXIS LABEL="Number of Bookings";
    KEYLEGEND / TITLE="Cancelled";
RUN;

/* --- VIZ 14: Cancellation rate by room match --- */
PROC SGPLOT DATA=work.hotel_features;
    VBAR room_match / GROUP=is_canceled GROUPDISPLAY=CLUSTER DATALABEL;
    TITLE "VIZ 14 - Cancellation Rate by Room Match (Engineered Feature)";
    XAXIS LABEL="Room Match (1=Same Room, 0=Upgraded)";
    YAXIS LABEL="Number of Bookings";
    KEYLEGEND / TITLE="Cancelled";
RUN;

/* --- VIZ 15: Cancellation rate by special requests --- */
PROC SGPLOT DATA=work.hotel_features;
    VBAR has_special_requests / GROUP=is_canceled GROUPDISPLAY=CLUSTER
        DATALABEL;
    TITLE "VIZ 15 - Cancellation Rate by Special Requests (Engineered Feature)";
    XAXIS LABEL="Has Special Requests (1=Yes, 0=No)";
    YAXIS LABEL="Number of Bookings";
    KEYLEGEND / TITLE="Cancelled";
RUN;

/*       Export feature-engineered dataset    */
PROC EXPORT DATA=work.hotel_features
    OUTFILE="/home/u64501847/sasuser.v94/hotel_features.csv" DBMS=CSV REPLACE;
RUN;

/*   SECTION 6: MODEL BUILDING      */

/*       Train/Test Split          */
DATA work.train work.test;
    SET work.hotel_features;

    IF RANUNI(42) <= 0.8 THEN output work.train;
    ELSE output work.test;
RUN;

/*    Logistic Regression Model     */
PROC LOGISTIC DATA=work.train OUTMODEL=work.model;

    CLASS deposit_type market_segment hotel / PARAM=REF;

    MODEL is_canceled(event='1')=lead_time adr guest_loyalty_score is_family
        room_match has_special_requests total_of_special_requests deposit_type
        market_segment hotel / SELECTION=STEPWISE CTABLE PPROB=0.5;

    TITLE "Hotel Cancellation Model";
RUN;

/*           Score Test Data         */
PROC LOGISTIC INMODEL=work.model;
    SCORE DATA=work.test OUT=work.scored;
RUN;

/*    Convert Probability to Class    */
DATA work.scored;
    SET work.scored;

    IF P_1 >= 0.5 THEN predicted_cancel=1;
    ELSE predicted_cancel=0;
RUN;

/*      Confusion Matrix             */
PROC FREQ DATA=work.scored;
    TABLES is_canceled * predicted_cancel;
    TITLE "Confusion Matrix";
RUN;

/*            Accuracy             */
DATA work.acc;
    SET work.scored;
    correct=(is_canceled=predicted_cancel);
RUN;

PROC MEANS DATA=work.acc MEAN;
    VAR correct;
    TITLE "Accuracy";
RUN;

/*         Sample Predictions       */
PROC PRINT DATA=work.scored (OBS=20);
    VAR hotel lead_time adr deposit_type is_canceled P_1 predicted_cancel;
RUN;

/*       Cancellation Insights      */
PROC FREQ DATA=work.hotel_features;
    TABLES deposit_type * is_canceled;
RUN;

PROC FREQ DATA=work.hotel_features;
    TABLES market_segment * is_canceled;
RUN;

/*      Model Explanation           */
PROC FREQ DATA=work.hotel_features;
    TABLES deposit_type * is_canceled;
    TITLE "Deposit Type vs Cancellation";
RUN;

PROC FREQ DATA=work.hotel_features;
    TABLES market_segment * is_canceled;
    TITLE "Market Segment vs Cancellation";
RUN;

/*     Model predictions summary    */
PROC FREQ DATA=work.hotel_scored;
    TABLES predicted_cancel;
    TITLE "Predicted Cancellations";
RUN;

/*          Sample results          */
PROC PRINT DATA=work.hotel_scored (OBS=20);
    VAR hotel lead_time adr deposit_type is_canceled P_1 predicted_cancel;
    TITLE "Sample Predictions";
RUN;

/*          Export results          */
PROC EXPORT DATA=work.hotel_scored
    OUTFILE="/home/u64501847/sasuser.v94/hotel_predictions.csv" DBMS=CSV
    REPLACE;
RUN;
