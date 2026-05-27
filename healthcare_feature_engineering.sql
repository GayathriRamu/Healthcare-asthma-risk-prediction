----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Big Data and Data Mining (CI7524_A_TB1_25): Course Work --
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Script about: CLEANING + FEATURE ENGINEERING (WITH CTEs)
-- Table name: CW_PATIENTS

----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Copy of original data
-- CREATE TABLE CW_PATIENTS_ORG AS SELECT * FROM CW_PATIENTS;

-- Checking if the copy is successful
-- SELECT COUNT(*) AS No_of_records FROM CW_PATIENTS_ORG;

-- DROP TABLE CW_PATIENTS_ORG

-- Structure of the data
DESC CW_PATIENTS;

-- To make sure if the dataset has 10,000 records
SELECT COUNT(*) AS No_of_records FROM CW_PATIENTS;


----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 1. INITIAL DATA UNDERSTANDING
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

    -- 1.1 IDENTIFYING DUPLICATE PATIENTS 

    SELECT COUNT(DISTINCT PATIENT_ID) FROM CW_PATIENTS;
    -- there are no duplicate patients

    
    -- NULL CHECK
    SELECT 
        COUNT(*) AS total_records,
        SUM(CASE WHEN GENDER IS NULL THEN 1 ELSE 0 END) AS missing_gender,
        SUM(CASE WHEN DIAB_CODE1 IS NULL THEN 1 ELSE 0 END) AS missing_diab,
        SUM(CASE WHEN SMOK_CODE1 IS NULL THEN 1 ELSE 0 END) AS missing_smoking_status,
        SUM(CASE WHEN MWAYDIST_KM1 IS NULL THEN 1 ELSE 0 END) AS missing_motorway_dist,
        SUM(CASE WHEN FH_ASTHMA_CODE1 IS NULL THEN 1 ELSE 0 END) AS missing_fh_asthma,
        SUM(CASE WHEN ASTHMA_WORSENED IS NULL THEN 1 ELSE 0 END) AS missing_target_vriable
        FROM CW_PATIENTS;

    -------------------------------------------------------------------------------

    -- 1.2 DISTRIBUTION OF CATEGORICAL FEATURES
    -- GENDER: 
    SELECT GENDER, COUNT(*) AS Gender_count
        FROM CW_PATIENTS
        GROUP BY GENDER
        ORDER BY Gender_count DESC;


    -- SMOKING STATUS
    SELECT SMOK_CODE1, COUNT(*) AS Smoke_count
        FROM CW_PATIENTS
        GROUP BY SMOK_CODE1;


    -- DIABETES STATUS
    SELECT DIAB_CODE1, COUNT(*) AS Diab_count
        FROM CW_PATIENTS
        GROUP BY DIAB_CODE1;


    -- ASTHMA WORSENING STATUS
    SELECT ASTHMA_WORSENED, COUNT(*) AS ASTHMA_COUNT
        FROM CW_PATIENTS
        GROUP BY ASTHMA_WORSENED;

    -------------------------------------------------------------------------------

    -- 1.3 OUTLIER DETECTION
    -- BP Check 
    SELECT COUNT(*) AS outlier_count
        FROM CW_PATIENTS
        WHERE SYS_VAL1 < 60 OR SYS_VAL1 > 260
           OR DIAS_VAL1 < 30 OR DIAS_VAL1 > 160;
           -- (0 outliers)

    SELECT COUNT(*) AS outlier_count
        FROM CW_PATIENTS
        WHERE SYS_VAL2 < 60 OR SYS_VAL2 > 260
           OR DIAS_VAL2 < 30 OR DIAS_VAL2 > 160;
           -- (0 outliers)

    -- Cholestrol check
    SELECT COUNT(*) AS chol_outliers
        FROM CW_PATIENTS
        WHERE CHLHDL_VAL1 < 1 OR CHLHDL_VAL1 > 20;
        -- (1106 outliers)

    -------------------------------------------------------------------------------

    -- 1.4 DATE EXPLORATION
    -- Records per year
    SELECT EXTRACT(YEAR FROM BP_DATE1) AS Year, COUNT(*) AS Year_count
        FROM CW_PATIENTS
        WHERE BP_DATE1 IS NOT NULL
        GROUP BY EXTRACT(YEAR FROM BP_DATE1)
        ORDER BY Year;

    -- Identifying bad/invalid dates
    SELECT PATIENT_ID, YEAR_OF_BIRTH
        FROM CW_PATIENTS
        WHERE YEAR_OF_BIRTH < 1900 OR YEAR_OF_BIRTH > EXTRACT(YEAR FROM SYSDATE);

    SELECT COUNT(*) AS bad_bp_dates
        FROM CW_PATIENTS
        WHERE BP_DATE1 < DATE '1900-01-01'
           OR BP_DATE1 > SYSDATE;
           -- (no bad bp dates)

    SELECT COUNT(*) AS bad_bp_dates
        FROM CW_PATIENTS
        WHERE BP_DATE2 < DATE '1900-01-01'
           OR BP_DATE2 > SYSDATE;
           -- (no bad bp dates)

    SELECT COUNT(*) AS bad_smoke_date1 
        FROM CW_PATIENTS
        WHERE TO_DATE(SMOK_DATE1, 'YYYY-MM-DD') < DATE '1900-01-01'
           OR TO_DATE(SMOK_DATE1, 'YYYY-MM-DD') > SYSDATE;           -- no bad smoke dates
    
    SELECT COUNT(*) AS bad_diab_date1 
        FROM CW_PATIENTS
        WHERE TO_DATE(DIAB_DATE1, 'YYYY-MM-DD') < DATE '1900-01-01'
           OR TO_DATE(DIAB_DATE1, 'YYYY-MM-DD') > SYSDATE;           -- no bad diab dates

    SELECT COUNT(*) AS bad_fhasthma_date1 
        FROM CW_PATIENTS
        WHERE TO_DATE(FH_ASTHMA_DATE1, 'YYYY-MM-DD') < DATE '1900-01-01'
           OR TO_DATE(FH_ASTHMA_DATE1, 'YYYY-MM-DD') > SYSDATE;          -- no bad fh_asthma dates
    

    -------------------------------------------------------------------------------
    -- 1.5 VALUE RANGES OF NUMERICAL DATA
    SELECT 
        MIN(SYS_VAL1) AS Min_Systolic, MAX(SYS_VAL1) AS Max_Systolic,
        MIN(DIAS_VAL1) AS Min_Diastolic, MAX(DIAS_VAL1) AS Max_Diastolic,
        MIN(MWAYDIST_KM1) AS Min_Dist, MAX(MWAYDIST_KM1) AS Max_Dist
        FROM CW_PATIENTS;


    -------------------------------------------------------------------------------
    -- 1.6 IDENTIFYING INCORRECT CODES (SNOMED)
    SELECT SYS_CODE1,  COUNT(*)
        FROM CW_PATIENTS
        WHERE SYS_CODE1 != 271649006
        GROUP BY SYS_CODE1;

    SELECT SYS_CODE2,  COUNT(*)
        FROM CW_PATIENTS
        WHERE SYS_CODE2 != 271649006
        GROUP BY SYS_CODE2;
        
    SELECT DIAS_CODE1,  COUNT(*)
        FROM CW_PATIENTS
        WHERE DIAS_CODE1 != 271650006
        GROUP BY DIAS_CODE1;

    SELECT DIAS_CODE2,  COUNT(*)
        FROM CW_PATIENTS
        WHERE DIAS_CODE2 != 271650006
        GROUP BY DIAS_CODE2;

    SELECT CHLTOT_CODE1,  COUNT(*)
        FROM CW_PATIENTS
        WHERE CHLTOT_CODE1 != 853681000000104
        GROUP BY CHLTOT_CODE1;

    SELECT CHLTOT_CODE2,  COUNT(*)
        FROM CW_PATIENTS
        WHERE CHLTOT_CODE2 != 853681000000104
        GROUP BY CHLTOT_CODE2;

    SELECT CHLHDL_CODE1,  COUNT(*)
        FROM CW_PATIENTS
        WHERE CHLHDL_CODE1 != 1005681000000107
        GROUP BY CHLHDL_CODE1;

    SELECT CHLHDL_CODE2,  COUNT(*)
        FROM CW_PATIENTS
        WHERE CHLHDL_CODE2 != 1005681000000107
        GROUP BY CHLHDL_CODE2;


    SELECT DIAB_CODE1,  COUNT(*)
        FROM CW_PATIENTS
        WHERE DIAB_CODE1 NOT IN (44054006, 237599002, 73211009, 111552007)
        GROUP BY DIAB_CODE1;

    SELECT SMOK_CODE1,  COUNT(*)
        FROM CW_PATIENTS
        WHERE SMOK_CODE1 NOT IN (8392000, 230056004, 230057008, 230058003, 266919005, 266920004)
        GROUP BY SMOK_CODE1;

    SELECT FH_ASTHMA_CODE1,  COUNT(*)
        FROM CW_PATIENTS
        WHERE FH_ASTHMA_CODE1 != 1603770011
        GROUP BY FH_ASTHMA_CODE1;
    -- (Need to change the SNOMED code for FH_ASTHMA_CODE1 as the correct code is 1603770011)

    -------------------------------------------------------------------------------
    -- 1.7 EDA Analysis
    -- Asthma outcome vs cvdrx (CVD medication often associated with asthma due to Shared risk factors
    -- Medication side effects
    -- Disease coexistence (multimorbidity)
    -- Healthcare utilisation bias)
    SELECT CVDRX_CODE1, COUNT(*) AS n_patients,
            COUNT(ASTHMA_WORSENED) AS asthma_worsen_count
    FROM CW_PATIENTS
    GROUP BY CVDRX_CODE1;


    -- Smoking vs asthma outcome (a smoker has higher probability of asthma worsening)
    SELECT SMOK_CODE1, COUNT(*) AS n_patients,
            COUNT(ASTHMA_WORSENED) AS asthma_worsen_count
    FROM CW_PATIENTS
    WHERE ASTHMA_WORSENED = 1
    GROUP BY SMOK_CODE1;

    
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 2. DATA PREPARATION 
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ADDING DERIVED COLUMNS
DECLARE
    col_count INTEGER;

    -- Helper: add column only if it does NOT already exist
    PROCEDURE add_column(colname IN VARCHAR2, datatype IN VARCHAR2) IS
    BEGIN
        SELECT COUNT(*)
        INTO col_count
        FROM user_tab_columns
        WHERE table_name = 'CW_PATIENTS'
          AND column_name = UPPER(colname);

        IF col_count = 0 THEN
            EXECUTE IMMEDIATE 'ALTER TABLE CW_PATIENTS ADD ' || colname || ' ' || datatype;
        END IF;
    END;
BEGIN
    -- Cleaned demographic + BP features
    add_column('C_GENDER',          'VARCHAR2(1)');         -- cleaned gender: M/F/U
    add_column('C_AGE',             'NUMBER');              -- cleaned age
    add_column('C_AGE_FLAG',        'VARCHAR2(20)');        -- patients' age groups
    add_column('C_BP_PAIR_INVALID', 'NUMBER(1)');           -- 1 = sys < dias
    add_column('C_PP',              'NUMBER');              -- pulse pressure

    -- Clinical flags
    add_column('C_DIABETES',        'NUMBER(1)');           -- 1 = diabetes dx
    add_column('C_SMOKER',          'NUMBER(1)');           -- 1 = smoker, 0 = non, NULL = unknown
    add_column('C_CVDRX',           'NUMBER(1)');           -- 1 = on cv meds
    add_column('C_HTN',             'NUMBER(1)');           -- 1 = hypertensive

    add_column('C_FH_ASTHMA',       'NUMBER(1)');           -- 1 = Family history of asthma
    add_column('CHL_TOT_CHANGE',      'NUMBER');
    add_column('CHL_HDL_CHANGE',      'NUMBER');
    add_column('SYS_BP_CHANGE',      'NUMBER');
    add_column('DIAS_BP_CHANGE',      'NUMBER');
    add_column('C_MWAY_BAND',       'VARCHAR2(20)');        -- Distance bands: High, Moderate, Low Risk

    add_column('C_COMORBIDITY_INDEX', 'NUMBER(1)');             -- sum of flags (diseases)
END;
/


----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 3. DATA CLEANING + UPDATING DERIVED COLUMNS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- UPDATING THE INCORRECT SNOMED CODE
UPDATE CW_PATIENTS
SET FH_ASTHMA_CODE1 = 160377001
WHERE FH_ASTHMA_CODE1 = 160357008;


-- UPDATING THE CLEAN DATA FEATURES
UPDATE CW_PATIENTS
SET
    -------------------------------------------------------------------------------
    -- 3.1 UPDATING CLEAN GENDER BASED ON SNOMED CODE 
    -- male_code(M)   = '446151000124109'
    -- female_code(F) = '446141000124107'
    -- U
    -------------------------------------------------------------------------------
    C_GENDER = 
        CASE
            WHEN GENDER = '446151000124109' THEN 'M'
            WHEN GENDER = '446141000124107' THEN 'F'
            ELSE 'U'
        END,
    
    -------------------------------------------------------------------------------
    -- 3.2 UPDATING C_AGE COLUMN FROM YEAR_OF_BIRTH
    -------------------------------------------------------------------------------
    C_AGE = 
        CASE
            WHEN YEAR_OF_BIRTH IS NULL THEN 0
            WHEN YEAR_OF_BIRTH < 1900 THEN NULL
            WHEN YEAR_OF_BIRTH > EXTRACT (YEAR FROM SYSDATE) THEN NULL
            ELSE EXTRACT( YEAR FROM SYSDATE) - YEAR_OF_BIRTH
        END,

    C_AGE_FLAG = 
        CASE
            WHEN C_AGE < 13 THEN 'Child'
            WHEN C_AGE BETWEEN 13 AND 19 THEN 'Teenager'
            WHEN C_AGE BETWEEN 20 AND 40 THEN 'Young adult'
            WHEN C_AGE > 40 THEN 'Older adult'
            ELSE 'Unknown'
        END,



    -------------------------------------------------------------------------------
    -- 3.3 UPDATING BLOOD PRESSURE & PULSE PRESSURE
    -------------------------------------------------------------------------------

    SYS_BP_CHANGE =
        CASE
            WHEN SYS_VAL1 IS NULL AND SYS_VAL2 IS NULL THEN 0
            ELSE SYS_VAL2 - SYS_VAL1
        END,

    DIAS_BP_CHANGE = 
        CASE
            WHEN DIAS_VAL1 IS NULL AND DIAS_VAL2 IS NULL THEN 0
            ELSE DIAS_VAL2 - DIAS_VAL1
        END,

    C_BP_PAIR_INVALID = 
        CASE
            WHEN SYS_VAL1 IS NOT NULL 
            AND DIAS_VAL1 IS NOT NULL 
            AND SYS_VAL1 < DIAS_VAL1 THEN 1
            ELSE 0
        END,

    C_PP = 
        CASE
            WHEN SYS_VAL1 IS NOT NULL 
            AND DIAS_VAL1 IS NOT NULL 
            THEN SYS_VAL1 - DIAS_VAL1
            ELSE NULL
        END,
    
    -------------------------------------------------------------------------------
    -- 3.4 UPDATING THE CHOLESTROL OUTLIERS FLAG & IMPROVEMENTS
    -- (1–20 mmol/L plausible)
    -- IDEAL CHOLESTROL HDL VALUE: < 5.0 mmol/L
    -------------------------------------------------------------------------------

    CHL_HDL_CHANGE = 
        CASE
            WHEN CHLHDL_VAL1 IS NULL AND CHLHDL_VAL2 IS NULL THEN 0
            ELSE CHLHDL_VAL2 - CHLHDL_VAL1
        END,


    CHL_TOT_CHANGE = 
        CASE
            WHEN CHLTOT_VAL1 IS NULL AND CHLTOT_VAL2 IS NULL THEN 0
            ELSE CHLTOT_VAL2 - CHLTOT_VAL1
        END,

    -------------------------------------------------------------------------------    
    -- 3.5 DIABETES FLAG
    -- diabetes_codes = 44054006,111552007,237599002,73211009
    -------------------------------------------------------------------------------
    C_DIABETES = 
        CASE
            WHEN DIAB_CODE1 IS NULL THEN 0
            WHEN DIAB_CODE1 IN ('44054006','111552007','237599002','73211009') THEN 1
            ELSE 0
        END,

    -------------------------------------------------------------------------------
    -- 3.6 UPDATING THE SMOKING FLAG
    -- all smoking codes: 8392000,230056004,230057008,230058003,266919005,266920004
    -- smoker = 1 (230056004,230057008,230058003,266920004)
    -- non-smoker/never smoked = 0 (8392000','266919005)
    -------------------------------------------------------------------------------
    C_SMOKER = 
        CASE
            WHEN SMOK_CODE1 IS NULL THEN 0                                                  -- unknown
            WHEN SMOK_CODE1 IN ('230056004','230057008','230058003','266920004') THEN 1     -- smoker 
            WHEN SMOK_CODE1 IN ('8392000','266919005') THEN 0                               -- ambiguous
            ELSE 0                                                                          -- explicit non-smoker (if coded)
        END,
        
    -------------------------------------------------------------------------------
    -- 3.7 UPDATING CARDIOVASCULAR DISEASE MEDICATION FLAG
    -- bp_management_rx_codes: 6131004,372727001,11000132102,11000129103, 
    --                         1040010010001002,111708003,372729009,
    --                         324121000000109,11560009    
    -------------------------------------------------------------------------------
    C_CVDRX = 
        CASE 
            WHEN CVDRX_CODE1 IN (
                    '6131004','372727001','11000132102','11000129103',
                    '1040010010001002','111708003','372729009',
                    '324121000000109','11560009'
                ) THEN 1
                ELSE 0
        END,

    -------------------------------------------------------------------------------
    -- 3.8 UPDATING HYPERTENSION FLAG
    -- SYS_VAL >= 140 OR DIAS_VAL >= 90
    -------------------------------------------------------------------------------
    C_HTN = 
        CASE
            WHEN SYS_VAL1 >= 140 OR DIAS_VAL1 >= 90 THEN 1
            ELSE 0
        END,

    
    -------------------------------------------------------------------------------
    -- 3.9 UPDATING THE FAMILY HISTORY ASTHMA CODE FLAG
    -------------------------------------------------------------------------------
    C_FH_ASTHMA = 
        CASE
            WHEN FH_ASTHMA_CODE1 IS NOT NULL THEN 1
            ELSE 0
        END,


    -------------------------------------------------------------------------------
    -- 3.10 UPDATING MOTORWAY DISTANCE BAND
    -------------------------------------------------------------------------------
    C_MWAY_BAND = 
        CASE 
            WHEN MWAYDIST_KM1 < 0.5 THEN 'High risk'
            WHEN MWAYDIST_KM1 >= 0.5 AND MWAYDIST_KM1 < 5 THEN 'Moderate risk'
            WHEN MWAYDIST_KM1 >= 5 AND MWAYDIST_KM1 <= 30 THEN 'Low risk'
            ELSE 'Unknown'
        END,


    -------------------------------------------------------------------------------
    -- 3.11 UPDATING COMORBIDITY INDEX
    -------------------------------------------------------------------------------
    C_COMORBIDITY_INDEX = 
        COALESCE(C_HTN, 0)
      + COALESCE(C_DIABETES, 0)
      + COALESCE(C_CVDRX, 0)
      + COALESCE(C_SMOKER, 0)
        -- WHEN (C_HTN + C_DIABETES + C_CVDRX + C_SMOKER) = 0 THEN 0
        -- ELSE (C_HTN + C_DIABETES + C_CVDRX + C_SMOKER)
;


----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 4. FEATURE VIEW FOR MODELLING (USING CTE PIPELINE)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE OR REPLACE VIEW VW_PATIENTS_FINAL_CTE AS
WITH BASE_RAW AS (
    -------------------------------------------------------------------------------
    -- STEP-1: GET THE INITIAL (CLEANED) COLUMNS FROM CW_PATIENTS
    -------------------------------------------------------------------------------
    SELECT 
        PATIENT_ID,
        C_GENDER,
        C_AGE,
        -- readings for delta
        SYS_VAL1,
        DIAS_VAL1, 
        -- cleaned features and flags
        C_PP,
        C_DIABETES,
        C_SMOKER,
        C_CVDRX,
        C_HTN,
        C_BP_PAIR_INVALID,

        C_AGE_FLAG,
        C_COMORBIDITY_INDEX,
        C_FH_ASTHMA,
        CHL_HDL_CHANGE,
        CHL_TOT_CHANGE,
        SYS_BP_CHANGE,
        DIAS_BP_CHANGE,
        C_MWAY_BAND,
        -- target variable
        ASTHMA_WORSENED         

    FROM CW_PATIENTS
),

DEMO_FILTER AS (
    -------------------------------------------------------------------------------
    -- STEP-2: APPLYING FILTERS ON BASIC DEMOGRAPHIC FEATURES
    -------------------------------------------------------------------------------
    SELECT 
        PATIENT_ID,
        C_GENDER,
        C_AGE,
        SYS_VAL1, 
        DIAS_VAL1, 
        -- cleaned features and flags
        C_PP,
        C_DIABETES,
        C_SMOKER,
        C_CVDRX,
        C_HTN,
        C_BP_PAIR_INVALID,

        C_AGE_FLAG,
        C_COMORBIDITY_INDEX,
        C_FH_ASTHMA,
        CHL_HDL_CHANGE,
        CHL_TOT_CHANGE,
        SYS_BP_CHANGE,
        DIAS_BP_CHANGE,
        C_MWAY_BAND,
        -- target variable
        ASTHMA_WORSENED    
    FROM BASE_RAW 
    WHERE C_BP_PAIR_INVALID = 0     -- sys >= dias
),

CLINICAL AS (
    -------------------------------------------------------------------------------
    -- STEP-3: PROVIDING ALIASES TO FINAL FEATURES
    -------------------------------------------------------------------------------
    SELECT
        PATIENT_ID,
        C_GENDER        AS GENDER,
        C_AGE           AS AGE,
        C_AGE_FLAG      AS AGE_FLAG,
        SYS_VAL1        AS SYS_BP,
        DIAS_VAL1       AS DIAS_BP,
        SYS_BP_CHANGE,
        DIAS_BP_CHANGE,
        C_PP            AS PULSE_PRESSURE,
        CHL_TOT_CHANGE,
        CHL_HDL_CHANGE,
        C_MWAY_BAND     AS MOTORWAY_RISK_BAND,
        C_FH_ASTHMA     AS FAMILY_HISTORY_ASTHMA,
        C_DIABETES      AS DIABETES_FLAG,
        C_SMOKER        AS SMOKER_FLAG,
        C_CVDRX         AS CVD_MEDS_FLAG,
        C_HTN           AS HYPERTENSION_FLAG,
        C_COMORBIDITY_INDEX AS COMORBIDITY_INDEX,
        ASTHMA_WORSENED     -- target label
    FROM DEMO_FILTER

),

FINAL_FEATURES AS (
    -------------------------------------------------------------------------------
    -- STEP-4: OPTIONAL CTE: FINAL FEATURES 
    -------------------------------------------------------------------------------
    SELECT 
        PATIENT_ID,
        GENDER,
        AGE,
        AGE_FLAG,
        SYS_BP,
        DIAS_BP,
        SYS_BP_CHANGE,
        DIAS_BP_CHANGE,
        PULSE_PRESSURE,
        CHL_TOT_CHANGE,
        CHL_HDL_CHANGE,
        MOTORWAY_RISK_BAND,
        FAMILY_HISTORY_ASTHMA,
        DIABETES_FLAG,
        SMOKER_FLAG,
        CVD_MEDS_FLAG,
        HYPERTENSION_FLAG,
        COMORBIDITY_INDEX,
        ASTHMA_WORSENED
    FROM CLINICAL


)

SELECT * FROM FINAL_FEATURES;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 5. CHECKING SAMPLE OF FINAL VIEW
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT * FROM VW_PATIENTS_FINAL_CTE
FETCH FIRST 20 ROWS ONLY;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- END OF SCRIPT
----------------------------------------------------------------------------------------------------------------------------------------------------------------------