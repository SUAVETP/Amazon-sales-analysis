--  EXPLORATORY ANALYSIS OF DOMESTIC AND INTERNATIONAL SALES

-- View full domestic dataset (for reference / sanity check)
SELECT * FROM amazon_sales;

-- View full international dataset (for reference / sanity check)
SELECT * FROM international_sales;


-- TOTAL ORDERS, QUANTITY, AND REVENUE BY SALES TYPE (DOMESTIC VS INTERNATIONAL)
SELECT  
    'DOMESTIC' AS Sale_Type,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(QTY) AS Total_Quantity,
    SUM(Amount) AS Total_Revenue
FROM amazon_sales

UNION ALL

SELECT  
    'INTERNATIONAL' AS Sale_Type,
    COUNT(*) AS Total_Orders,
    SUM(PCS) AS Total_Quantity,
    SUM(Gross_Amt) AS Total_Revenue
FROM international_sales;


-- MONTHLY SALES TREND: DOMESTIC VS INTERNATIONAL
SELECT  
    DATE_FORMAT(Order_Date, '%Y-%m') AS Sales_Month,
    'DOMESTIC' AS Sale_Type,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(QTY) AS Total_Quantity,
    SUM(Amount) AS Total_Revenue
FROM amazon_sales
GROUP BY Sales_Month

UNION ALL

SELECT  
    DATE_FORMAT(Sale_Date, '%Y-%m') AS Sales_Month,
    'INTERNATIONAL' AS Sale_Type,
    COUNT(*) AS Total_Orders,
    SUM(PCS) AS Total_Quantity,
    SUM(Gross_Amt) AS Total_Revenue
FROM international_sales
GROUP BY Sales_Month
ORDER BY Sales_Month, Sale_Type;


-- STYLE PERFORMANCE: REVENUE + QUANTITY BY SALES TYPE
SELECT  
    Style AS Product_Group,
    'DOMESTIC' AS Sales_Type,
    SUM(QTY) AS Total_Quantity,
    SUM(Amount) AS Total_Revenue
FROM amazon_sales
GROUP BY Style

UNION ALL

SELECT  
    Style AS Product_Group,
    'INTERNATIONAL' AS Sales_Type,
    SUM(PCS) AS Total_Quantity,
    SUM(Gross_Amt) AS Total_Revenue
FROM international_sales
GROUP BY Style
ORDER BY Sales_Type, Total_Revenue DESC;


-- TOP CATEGORIES (DOMESTIC ONLY)
SELECT  
    Category,
    'DOMESTIC' AS Sales_Type,
    SUM(QTY) AS Total_Quantity,
    SUM(Amount) AS Total_Revenue
FROM amazon_sales
GROUP BY Category
ORDER BY Total_Revenue DESC;


-- % OF ORDERS BY ORDER STATUS (DOMESTIC ONLY)
SELECT  
    Cleaned_Order_Status AS Order_Status,
    COUNT(DISTINCT Order_ID) AS Order_Count,
    ROUND(
        100.0 * COUNT(DISTINCT Order_ID) / 
        (SELECT COUNT(DISTINCT Order_ID) FROM amazon_sales), 
        2
    ) AS Percent_Of_Orders
FROM amazon_sales
GROUP BY Order_Status
ORDER BY Percent_Of_Orders DESC;


-- RETURN % AND CANCELLATION % BY CATEGORY (DOMESTIC ONLY)
SELECT  
    Category,
    SUM(CASE WHEN Cleaned_Order_Status = 'Returned' THEN 1 ELSE 0 END) AS Return_Count,
    SUM(CASE WHEN Cleaned_Order_Status = 'Cancelled' THEN 1 ELSE 0 END) AS Cancel_Count,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    ROUND(
        100.0 * SUM(CASE WHEN Cleaned_Order_Status = 'Returned' THEN 1 ELSE 0 END) / 
        COUNT(DISTINCT Order_ID), 
        2
    ) AS Return_Percent,
    ROUND(
        100.0 * SUM(CASE WHEN Cleaned_Order_Status = 'Cancelled' THEN 1 ELSE 0 END) / 
        COUNT(DISTINCT Order_ID), 
        2
    ) AS Cancel_Percent
FROM amazon_sales
GROUP BY Category
ORDER BY Return_Percent DESC, Cancel_Percent DESC;


-- TOP REGIONS (CITIES) BY REVENUE (DOMESTIC ONLY)
SELECT  
    Ship_City AS Region,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(QTY) AS Total_Quantity,
    SUM(Amount) AS Total_Revenue
FROM amazon_sales
GROUP BY Region
ORDER BY Total_Revenue DESC;


-- TOP REGIONS WITH REVENUE % SHARE (DOMESTIC ONLY)
SELECT  
    Ship_City AS Region,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(QTY) AS Total_Quantity,
    SUM(Amount) AS Total_Revenue,
    ROUND(
        100.0 * SUM(Amount) / (SELECT SUM(Amount) FROM amazon_sales),
        2
    ) AS Revenue_Percent
FROM amazon_sales
GROUP BY Region
ORDER BY Total_Revenue DESC;


