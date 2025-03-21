CREATE DATABASE SupplyChainDB;
USE SupplyChainDB;

select * from additional_fields;

select * from brokerage;

select * from claims;

select * from customers_info;

select * from fees;

select * from individual_budgets;

select * from invoice;

select * from meeting;

select * from opportunity;

select * from paymenthistory;

select * from policy_details;

DESC additional_fields;
DESC brokerage;
DESC claims;
DESC customers_info;
DESC fees;
DESC individual_budgets;
DESC invoice;
DESC meeting;
DESC Opportunity;
DESC paymenthistory;
DESC policy_details;


-- WEEKLY BRANCH KPI --


#1-No of Invoice by Account Executive
SELECT `Account Executive`, COUNT(invoice_number) AS invoice_count
FROM invoice
GROUP BY `Account Executive`;


#2-Yearly Meeting Count
SELECT YEAR(STR_TO_DATE(meeting_date, '%d-%m-%Y')) AS Year, 
       COUNT(*) AS Meeting_Count
FROM supplychaindb.meeting
WHERE meeting_date IS NOT NULL
GROUP BY Year
ORDER BY Year;


#3  --3.1Cross Sell--Target, Achieve, new
	 #3.1New-Target,Achive,new
     #3.1Renewal-Target, Achieve , new. --
SELECT 'Cross Sell' AS Category, 
    ROUND(SUM(ib.`Cross sell bugdet`), 0) AS Target, 
    ROUND(SUM(CASE WHEN b.income_class = 'Cross Sell' THEN b.Amount ELSE 0 END), 0) AS Achieved, 
    ROUND(SUM(CASE WHEN i.income_class = 'Cross Sell' THEN i.Amount ELSE 0 END), 0) AS New
FROM individual_budgets ib  
LEFT JOIN Brokerage b ON ib.`Account Exe ID` = b.`Account Exe ID`  
LEFT JOIN Invoice i ON ib.`Account Exe ID` = i.`Account Exe ID`

UNION ALL

SELECT 'New' AS Category, 
    ROUND(SUM(ib.`New Budget`), 0) AS Target, 
    ROUND(SUM(CASE WHEN b.income_class = 'New' THEN b.Amount ELSE 0 END), 0) AS Achieved, 
    ROUND(SUM(CASE WHEN i.income_class = 'New' THEN i.Amount ELSE 0 END), 0) AS New
FROM individual_budgets ib  
LEFT JOIN Brokerage b ON ib.`Account Exe ID` = b.`Account Exe ID`  
LEFT JOIN Invoice i ON ib.`Account Exe ID` = i.`Account Exe ID`

UNION ALL

SELECT 'Renewal' AS Category, 
    ROUND(SUM(ib.`Renewal Budget`), 0) AS Target, 
    ROUND(SUM(CASE WHEN b.income_class = 'Renewal' THEN b.Amount ELSE 0 END), 0) AS Achieved, 
    ROUND(SUM(CASE WHEN i.income_class = 'Renewal' THEN i.Amount ELSE 0 END), 0) AS New
FROM individual_budgets ib  
LEFT JOIN Brokerage b ON ib.`Account Exe ID` = b.`Account Exe ID`  
LEFT JOIN Invoice i ON ib.`Account Exe ID` = i.`Account Exe ID`;



#4. Stage Funnel by Revenue
SELECT stage,concat('₹ ', SUM(revenue_amount)) AS total_revenue
FROM opportunity
GROUP BY stage;


#5. No of meeting By Account Exe
SELECT Account_Executive, COUNT(meeting_date) AS meeting_count
FROM meeting
GROUP BY Account_Executive;


#6- Top Open Opportunity
SELECT 
    opportunity_id, 
    opportunity_name, 
    `Account Exe Id`,
    `Account Executive`,
    stage, 
    revenue_amount
FROM opportunity
WHERE stage NOT IN ('Closed Won', 'Closed Lost')
ORDER BY revenue_amount DESC
LIMIT 5;




-- POLICY KPI --

#1️-Total Policy
SELECT COUNT(*) AS Total_Policies FROM policy_details;


#2-Total Customers
SELECT COUNT(DISTINCT customerid) AS Total_Customers FROM policy_details; 


#3-Age Bucket Wise Policy Count
SELECT 
    CASE 
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 50 THEN '36-50'
        ELSE '50+' 
    END AS Age_Bucket,
    COUNT(*) AS Policy_Count
FROM customers_info 
JOIN policy_details ON customers_info.customerid = policy_details.customerid
GROUP BY age_bucket;


#4-Gender Wise Policy Count
SELECT Gender, COUNT(*) AS Policy_Count 
FROM customers_info
JOIN policy_details ON customers_info.customerid = policy_details.customerid
GROUP BY gender;


#5-Policy Type Wise Policy Count
SELECT PolicyType, COUNT(*) AS Policy_Count 
FROM policy_details
GROUP BY policytype;


#6-Policy Expire This Year        
SELECT COUNT(*) AS Expiring_Policies
FROM policy_details
WHERE YEAR(PolicyEndDate) = YEAR(CURDATE());


#7-Premium Growth Rate
SELECT 
    YEAR(PolicyStartDate) AS Year,
    CONCAT('₹ ', FORMAT(SUM(PremiumAmount), 0)) AS TotalPremium,
    CONCAT('₹ ', FORMAT(COALESCE(LAG(SUM(PremiumAmount)) OVER (ORDER BY YEAR(PolicyStartDate)), 0), 0)) AS PreviousYearPremium,
    COALESCE(
        CONCAT(
            ROUND(
                ((SUM(PremiumAmount) - LAG(SUM(PremiumAmount)) OVER (ORDER BY YEAR(PolicyStartDate))) / 
                LAG(SUM(PremiumAmount)) OVER (ORDER BY YEAR(PolicyStartDate))) * 100, 0
            ), ' %'
        ), 'N/A'
    ) AS PremiumGrowth
FROM policy_details
GROUP BY YEAR(PolicyStartDate);


#8-Claim Status Wise Policy Count
SELECT ClaimStatus, COUNT(*) AS Policy_Count
FROM claims
GROUP BY ClaimStatus;


#9-Payment Status Wise Policy Count
SELECT PaymentStatus, COUNT(*) AS Policy_Count
FROM paymenthistory
GROUP BY PaymentStatus;


#10-Total Claim Amount
SELECT CONCAT('₹ ', FORMAT(ROUND(SUM(ClaimAmount), 0), 0)) AS Total_Claim_Amount
FROM claims;




