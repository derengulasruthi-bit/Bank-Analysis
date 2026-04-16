-- LOADING/IMPORTING THE  FINANCE MASTER DATASET
LOAD DATA INFILE 'C:/programdata/MYSQL/MySQL Server 8.0/Uploads/Finance_Dataset.csv'
INTO TABLE finance_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
 -- UNDERSTANDING THE DATA
Show Columns from finance_dataset;
select * from finance_dataset;

-- Q1.TOTAL LOAN AMOUNT??
SELECT sum(loan_amnt) as total_loan_amnt
from finance_dataset;

-- Q.2 TOTAL PAYMENT RECIVED??
select sum(total_pymnt) as total_pay_recived
from finance_dataset;

-- Q.3 TOTAL LOAN COUNT??
select count(*) as total_loans
from finance_dataset;

-- Q.4 DEFAULT RATE
select 
count(case when loan_status='charged off' then 1 end) * 100.0 /count(*) as default_rate
from finance_dataset;

-- Q.5  YEAR WISE LOAN AMOUNT STATUS??
SELECT 
    YEAR(STR_TO_DATE(issue_d, '%d-%m-%Y %H:%i')) AS year,
    loan_status,
    SUM(loan_amnt) AS total_loan_amount
FROM finance_dataset
GROUP BY YEAR(STR_TO_DATE(issue_d, '%d-%m-%Y %H:%i')), loan_status
ORDER BY year;

-- Q.6 GRADE AND SUB_GRADE WISE REVOLVING_BALANCING??
SELECT 
    grade,
    sub_grade,
    SUM(revol_bal) AS total_revolving_balance
FROM finance_dataset
GROUP BY grade, sub_grade
ORDER BY grade, sub_grade;

-- Q.7 TOTAL PAYMENT FOR VERIFIED STATUS VS TOTAL PAYMENT FOR NON-VERIFIED STATUS??
SELECT 
    verification_status,
    SUM(total_pymnt) AS total_payment
FROM finance_dataset
GROUP BY verification_status;

-- Q.8 REPAYMENT BEHAVIOUR OF CUSTOMERS ACROSS VERIFIED AND NON-VERIFIED STATUS??
SELECT 
    verification_status,
    SUM(total_pymnt) AS total_payment,
    COUNT(CASE WHEN loan_status = 'Charged Off' THEN 1 END) AS defaults
FROM finance_dataset
GROUP BY verification_status;

-- Q.9 STATE WISE AND MONTH WISE LOAN STATUS??
SELECT 
    addr_state,
    YEAR(STR_TO_DATE(issue_d, '%d-%m-%Y %H:%i')) AS year,
    MONTH(STR_TO_DATE(issue_d, '%d-%m-%Y %H:%i')) AS month,
    loan_status,
    SUM(loan_amnt) AS total_loan
FROM finance_dataset
GROUP BY addr_state, year, month, loan_status
ORDER BY year, month;

-- Q.10 HOMEOWNER SHIP VS LAST PAYMENT DATE??
SELECT 
    home_ownership,
    COUNT(*) AS total_customers,
    AVG(DATEDIFF(CURDATE(), STR_TO_DATE(last_pymnt_d, '%d-%m-%Y %H:%i'))) AS avg_days_since_payment
FROM finance_dataset
GROUP BY home_ownership;

-- Q.11 FINDING RANK BASED ON STATE WISE BY TOTAL LOAN AMOUNT??
select addr_state,
sum(loan_amnt) as total_loan,
rank() over ( order by sum(loan_amnt) desc) as state_rank
from finance_dataset
group by addr_state;

-- Q.12 RUNNING TOTAL OF LOAN AMOUNT??
SELECT 
    DATE_FORMAT(STR_TO_DATE(issue_d, '%d-%m-%Y %H:%i'), '%Y-%m') AS month,
    SUM(loan_amnt) AS monthly_loan,
    SUM(SUM(loan_amnt)) OVER (ORDER BY DATE_FORMAT(STR_TO_DATE(issue_d, '%d-%m-%Y %H:%i'), '%Y-%m')) AS running_total
FROM finance_dataset
GROUP BY month;

-- Q.13 PUBLICK RECORD RISK??
SELECT 
    CASE 
        WHEN pub_rec = 0 THEN 'Clean'
        ELSE 'Risky'
    END AS risk_level,
    COUNT(*) AS customers
FROM finance_dataset
GROUP BY 
    CASE 
        WHEN pub_rec = 0 THEN 'Clean'
        ELSE 'Risky'
    END;
    
-- Q.14 INTEREST RATE ANALYSIS?
select grade,
avg(int_rate) as avg_interest
from finance_dataset
group by grade
order by grade;

-- Q.15 STORED PROCEDURE FOR DYNAMIC STATE ANALYSIS

DELIMITER //

CREATE PROCEDURE state_loan_analysis(IN state_name VARCHAR(10))
BEGIN
    SELECT 
        addr_state,
        COUNT(*) AS total_loans,
        SUM(loan_amnt) AS total_loan
    FROM finance_data
    WHERE addr_state = state_name
    GROUP BY addr_state;
END //

DELIMITER 

-- ---------------------------------------------END OF THE PROJECT ----------------------------------------------------------------------