-- Retail Sales Performance Analysis
-- Database: retail_sales_project
-- Table: sales
-- Run this script in MySQL Workbench.

USE retail_sales_project;

-- 1. Table structure and row count
DESCRIBE sales;
SELECT COUNT(*) AS Total_Rows FROM sales;

-- 2. Data quality validation
SELECT * FROM sales WHERE Order_ID IS NULL;
SELECT * FROM sales WHERE Quantity <= 0;
SELECT * FROM sales WHERE Unit_Price <= 0;
SELECT * FROM sales WHERE Sales <> Quantity * Unit_Price;
SELECT * FROM sales WHERE Profit <> Sales - Cost;

SELECT Order_ID, COUNT(*) AS Order_Count
FROM sales
GROUP BY Order_ID
HAVING COUNT(*) > 1;

-- 3. Overall KPIs
SELECT
    SUM(Sales) AS Total_Revenue,
    SUM(Cost) AS Total_Cost,
    SUM(Profit) AS Total_Profit,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(Quantity) AS Total_Quantity_Sold,
    ROUND(SUM(Sales) / COUNT(DISTINCT Order_ID), 2) AS Average_Order_Value,
    ROUND(SUM(Profit) / SUM(Sales) * 100, 2) AS Profit_Margin_Percent
FROM sales;

-- 4. Performance by category
SELECT
    Category,
    SUM(Sales) AS Total_Revenue,
    SUM(Cost) AS Total_Cost,
    SUM(Profit) AS Total_Profit,
    SUM(Quantity) AS Units_Sold,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    ROUND(SUM(Profit) / SUM(Sales) * 100, 2) AS Profit_Margin_Percent
FROM sales
GROUP BY Category
ORDER BY Total_Revenue DESC;

-- 5. Performance by region
SELECT
    Region,
    SUM(Sales) AS Total_Revenue,
    SUM(Profit) AS Total_Profit,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    ROUND(SUM(Profit) / SUM(Sales) * 100, 2) AS Profit_Margin_Percent
FROM sales
GROUP BY Region
ORDER BY Total_Revenue DESC;

-- 6. Performance by product
SELECT
    Product,
    SUM(Sales) AS Total_Revenue,
    SUM(Profit) AS Total_Profit,
    SUM(Quantity) AS Units_Sold,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    ROUND(SUM(Profit) / SUM(Sales) * 100, 2) AS Profit_Margin_Percent
FROM sales
GROUP BY Product
ORDER BY Total_Revenue DESC;

-- 7. Products ranked by profit
SELECT
    Product,
    SUM(Sales) AS Total_Revenue,
    SUM(Profit) AS Total_Profit,
    ROUND(SUM(Profit) / SUM(Sales) * 100, 2) AS Profit_Margin_Percent
FROM sales
GROUP BY Product
ORDER BY Total_Profit DESC;

-- 8. Product margin classification
SELECT
    Product,
    SUM(Sales) AS Total_Revenue,
    SUM(Profit) AS Total_Profit,
    ROUND(SUM(Profit) / SUM(Sales) * 100, 2) AS Profit_Margin_Percent,
    CASE
        WHEN SUM(Profit) / SUM(Sales) * 100 >= 40 THEN 'High Margin'
        WHEN SUM(Profit) / SUM(Sales) * 100 >= 30 THEN 'Medium Margin'
        ELSE 'Low Margin'
    END AS Margin_Category
FROM sales
GROUP BY Product
ORDER BY Profit_Margin_Percent DESC;

-- 9. Top 10 customers by revenue
SELECT
    Customer_ID,
    Customer_Name,
    SUM(Sales) AS Total_Revenue,
    SUM(Profit) AS Total_Profit,
    COUNT(DISTINCT Order_ID) AS Total_Orders
FROM sales
GROUP BY Customer_ID, Customer_Name
ORDER BY Total_Revenue DESC
LIMIT 10;

-- 10. Top 10 customers by average order value
SELECT
    Customer_ID,
    Customer_Name,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(Sales) AS Total_Revenue,
    ROUND(SUM(Sales) / COUNT(DISTINCT Order_ID), 2) AS Average_Order_Value
FROM sales
GROUP BY Customer_ID, Customer_Name
ORDER BY Average_Order_Value DESC
LIMIT 10;

-- 11. Monthly performance
SELECT
    YEAR(Order_Date) AS Sales_Year,
    MONTH(Order_Date) AS Sales_Month,
    SUM(Sales) AS Total_Revenue,
    SUM(Profit) AS Total_Profit,
    COUNT(DISTINCT Order_ID) AS Total_Orders
FROM sales
GROUP BY YEAR(Order_Date), MONTH(Order_Date)
ORDER BY Sales_Year, Sales_Month;

-- 12. Month-over-month revenue growth (MySQL 8.0+)
WITH MonthlySales AS (
    SELECT
        YEAR(Order_Date) AS Sales_Year,
        MONTH(Order_Date) AS Sales_Month,
        SUM(Sales) AS Total_Revenue
    FROM sales
    GROUP BY YEAR(Order_Date), MONTH(Order_Date)
),
MonthlyWithPrevious AS (
    SELECT
        Sales_Year,
        Sales_Month,
        Total_Revenue,
        LAG(Total_Revenue) OVER (
            ORDER BY Sales_Year, Sales_Month
        ) AS Previous_Month_Revenue
    FROM MonthlySales
)
SELECT
    Sales_Year,
    Sales_Month,
    Total_Revenue,
    Previous_Month_Revenue,
    ROUND(
        (Total_Revenue - Previous_Month_Revenue)
        / Previous_Month_Revenue * 100,
        2
    ) AS MoM_Growth_Percent
FROM MonthlyWithPrevious
ORDER BY Sales_Year, Sales_Month;
