CREATE DATABASE ecommerce_project;
USE ecommerce_project;

-- ============================
-- CREATE TABLES
-- ============================

CREATE TABLE amazon_sales (
    Order_ID VARCHAR(50),
    Order_Date DATE,
    Order_Status VARCHAR(100),
    Fulfilment VARCHAR(100),
    Sales_channel VARCHAR(100),
    Ship_Service_level VARCHAR(100),
    Style VARCHAR(50),
    SKU VARCHAR(100),
    Category VARCHAR(100),
    Size VARCHAR(50),
    ASIN VARCHAR(100),
    Courier_Status VARCHAR(100),
    QTY INT,
    Currency VARCHAR(10),
    Amount DECIMAL(10,2),
    Ship_City VARCHAR(100),
    Ship_State VARCHAR(100),
    Ship_Postal_Code VARCHAR(20),
    Ship_County VARCHAR(10),
    Promotion_IDS TEXT,
    B2B BOOLEAN,
    Fulfilled_by VARCHAR(100),
    Unused_column TEXT
);

ALTER TABLE amazon_sales MODIFY B2B VARCHAR(10);
ALTER TABLE amazon_sales CHANGE Ship_County Ship_Country VARCHAR(50);
ALTER TABLE amazon_sales MODIFY Amount VARCHAR(50);

CREATE TABLE Cloud_warehouse_Chart (
    Shiprocket VARCHAR(100),
    Unnamed_column VARCHAR(1000),
    Increff VARCHAR(1000)
);

CREATE TABLE pl_2021_raw (
    sku VARCHAR(50),
    style_id VARCHAR(50),
    catalog VARCHAR(100),
    category VARCHAR(50),
    weight_text VARCHAR(50),
    tp_1_text VARCHAR(50),
    tp_2_text VARCHAR(50),
    mrp_old_text VARCHAR(50),
    final_mrp_old_text VARCHAR(50),
    ajio_mrp_text VARCHAR(50),
    amazon_mrp_text VARCHAR(50),
    amazon_fba_mrp_text VARCHAR(50),
    flipkart_mrp_text VARCHAR(50),
    limeroad_mrp_text VARCHAR(50),
    myntra_mrp_text VARCHAR(50),
    paytm_mrp_text VARCHAR(50),
    snapdeal_mrp_text VARCHAR(50)
);

CREATE TABLE sales_report_raw (
    sku_code VARCHAR(50),
    design_no VARCHAR(50),
    stock_text VARCHAR(50),
    category VARCHAR(100),
    size VARCHAR(10),
    color VARCHAR(50)
);

-- ============================
-- REMOVE DUPLICATES
-- ============================

ALTER TABLE amazon_sales ADD COLUMN ID INT AUTO_INCREMENT PRIMARY KEY;

WITH Ranked_orders AS (
    SELECT ID,
           ROW_NUMBER() OVER (PARTITION BY Order_ID ORDER BY ID) AS rn
    FROM amazon_sales
)
DELETE FROM amazon_sales
WHERE ID IN (
    SELECT ID FROM Ranked_orders WHERE rn > 1
);

-- ============================
-- VALIDATION & CLEANING
-- ============================

-- Check Order_ID
SELECT DISTINCT Order_ID
FROM amazon_sales
WHERE Order_ID IS NULL OR Order_ID = '' OR Order_ID LIKE '%[^0-9A-Z\\-]%';

-- Check Order_Date
SELECT DISTINCT Order_Date
FROM amazon_sales
WHERE Order_Date IS NULL;

SELECT COUNT(*) AS invalid_dates
FROM amazon_sales
WHERE Order_Date = CAST('0000-00-00' AS DATE);

-- Amount validation
SELECT DISTINCT Amount
FROM amazon_sales
WHERE TRIM(Amount) = '' OR Amount IS NULL OR Amount NOT REGEXP '^[0-9]+(\\.[0-9]+)?$';

UPDATE amazon_sales
SET Amount = NULL
WHERE TRIM(Amount) = '';

ALTER TABLE amazon_sales MODIFY COLUMN Amount DECIMAL(10,2);

-- Clean Order_Status
ALTER TABLE amazon_sales ADD COLUMN Cleaned_Order_Status VARCHAR(50);

UPDATE amazon_sales
SET Cleaned_Order_Status = CASE
    WHEN TRIM(Order_Status) = 'Shipped' THEN 'Shipped'
    WHEN TRIM(Order_Status) = 'Shipping' THEN 'Shipped'
    WHEN TRIM(Order_Status) = 'Shipped - Delivered to Buyer' THEN 'Delivered'
    WHEN TRIM(Order_Status) = 'Shipped - Returned to Seller' THEN 'Returned'
    WHEN TRIM(Order_Status) = 'Shipped - Rejected by Buyer' THEN 'Rejected'
    WHEN TRIM(Order_Status) = 'Shipped - Returning to Seller' THEN 'Returning'
    WHEN TRIM(Order_Status) = 'Shipped - Picked Up' THEN 'Picked Up'
    WHEN TRIM(Order_Status) = 'Shipped - Lost in Transit' THEN 'Lost'
    WHEN TRIM(Order_Status) = 'Shipped - Out for Delivery' THEN 'Out for Delivery'
    WHEN TRIM(Order_Status) = 'Shipped - Damaged' THEN 'Damaged'
    WHEN TRIM(Order_Status) = 'Pending' THEN 'Pending'
    WHEN TRIM(Order_Status) = 'Pending - Waiting for Pick Up' THEN 'Pending Pick Up'
    WHEN TRIM(Order_Status) = 'Cancelled' THEN 'Cancelled'
    ELSE 'Other'
END;

-- Currency cleaning
UPDATE amazon_sales SET Currency = 'INR' WHERE Currency = '';

-- Ship_City cleaning
UPDATE amazon_sales SET Ship_City = 'UNKNOWN' WHERE Ship_City = '';
UPDATE amazon_sales
SET Ship_City = CONCAT(UPPER(LEFT(Ship_City,1)), LOWER(SUBSTRING(Ship_City,2)))
WHERE Ship_City IS NOT NULL;

UPDATE amazon_sales
SET Ship_City = TRIM(
    REGEXP_REPLACE(
        REGEXP_REPLACE(
            REGEXP_REPLACE(
                REGEXP_REPLACE(Ship_City, '\\(.*?\\)', ''),
            '[0-9]', ''),
        ',', ''),
    '\\.', '')
)
WHERE Ship_City IS NOT NULL;

-- Ship_State cleaning
-- NOTE: Ship_State column got corrupted during cleaning due to mistaken UPDATE (Ship_City logic applied to Ship_State).
-- Attempt to restore failed due to join/import issues — decided to proceed without Ship_State for analysis transparency.

UPDATE amazon_sales SET Ship_State = 'Unknown' WHERE Ship_State = '';
UPDATE amazon_sales
SET Ship_State = CONCAT(UPPER(LEFT(Ship_State,1)), LOWER(SUBSTRING(Ship_State,2)))
WHERE Ship_State IS NOT NULL;

UPDATE amazon_sales
SET Ship_State = TRIM(
    REGEXP_REPLACE(
        REGEXP_REPLACE(
            REGEXP_REPLACE(
                REGEXP_REPLACE(Ship_State, '\\(.*?\\)', ''),
            '[0-9]', ''),
        ',', ''),
    '\\.', '')
)
WHERE Ship_State IS NOT NULL;

-- Ship_Postal_Code
UPDATE amazon_sales SET Ship_Postal_Code = 'Unknown' WHERE Ship_Postal_Code = '';

-- Ship_Country
UPDATE amazon_sales SET Ship_Country = 'Unknown' WHERE Ship_Country = '';

-- B2B cleaning
-- NOTE: B2B column crashed due to type conversion issues (text inconsistencies). 
-- Converted cleaned values to BOOLEAN with 1 (True) / 0 (False)

UPDATE amazon_sales
SET B2B = CONCAT(UPPER(LEFT(B2B,1)), LOWER(SUBSTRING(B2B,2)));

ALTER TABLE amazon_sales MODIFY COLUMN B2B BOOLEAN;

UPDATE amazon_sales
SET B2B = CASE
    WHEN B2B = 'True' THEN 1
    WHEN B2B = 'False' THEN 0
    ELSE NULL
END;

-- Fulfilled_by
UPDATE amazon_sales SET Fulfilled_by = 'Unknown' WHERE Fulfilled_by = '';

-- ============================
-- EXPENSES CLEANING
-- ============================
SELECT * FROM
expenses;

DESCRIBE expenses;

UPDATE expenses
SET expense_item = CONCAT(
UPPER(LEFT(expense_item,1)),
LOWER(SUBSTRING(expense_item,2))
);

-- Expenses table has only 4 rows. 
-- Verified manually and no cleaning needed. 
-- Standardized expense_item values to proper case for consistency.
-- Data ready for analysis.


-- ============================
-- INTERNATIONAL SALES CLEANING
-- ============================

ALTER TABLE international_sales MODIFY COLUMN sale_date DATE;

-- Drop and recreate for clean import
DROP TABLE IF EXISTS international_sales;
CREATE TABLE international_sales (
    sale_date VARCHAR(50),
    sale_month VARCHAR(50),
    customer VARCHAR(100),
    style VARCHAR(50),
    sku VARCHAR(100),
    size VARCHAR(20),
    pcs VARCHAR(10),
    rate VARCHAR(20),
    gross_amt VARCHAR(20)
);

ALTER TABLE international_sales ADD COLUMN Clean_Sale_Date DATE;
UPDATE international_sales
SET Clean_Sale_Date = STR_TO_DATE(sale_date, '%m/%d/%Y');
ALTER TABLE international_sales DROP COLUMN sale_date;
ALTER TABLE international_sales CHANGE Clean_Sale_Date sale_date DATE;
ALTER TABLE international_sales DROP COLUMN sale_month;

UPDATE international_sales
SET customer = CONCAT(UPPER(LEFT(customer,1)), LOWER(SUBSTRING(customer,2)));

UPDATE international_sales
SET SKU = 'UNKNOWN'
WHERE SKU IS NULL OR SKU = '';

ALTER TABLE international_sales MODIFY COLUMN pcs INT;
ALTER TABLE international_sales MODIFY COLUMN rate DECIMAL(10,2);
ALTER TABLE international_sales MODIFY COLUMN gross_amt INT;

