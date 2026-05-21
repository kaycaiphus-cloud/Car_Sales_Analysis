--1. GENERAL QUERY
------------------------------------------------------------------------------
SELECT * FROM `car_sales_data`.`default`.`car_sales_dataset` LIMIT 100;


-------------------------------------------------------------------------------
--2. CHECKING TOTAL NUMBER OF CARS RECORDED
-------------------------------------------------------------------------------
SELECT COUNT(*) FROM `car_sales_data`.`default`.`car_sales_dataset` AS `Total Recorded Cars`;


--------------------------------------------------------------------------------
--3. CHECKING TOTAL NUMBER OF EXISTING CAR MAKES
--------------------------------------------------------------------------------
SELECT DISTINCT make FROM `car_sales_data`.`default`.`car_sales_dataset`;


--------------------------------------------------------------------------------
--4. CLEANING 'COLOR' COLUMN
--------------------------------------------------------------------------------
SELECT color,
    CASE 
        WHEN color RLIKE '^[0-9]+$' THEN 'Unspecified'
        ELSE INITCAP(color)
        END AS Color
FROM `car_sales_data`.`default`.`car_sales_dataset`;


----------------------------------------------------------------------------------
--5. ELIMINATING NULL VALUES AND RETURNING A CLEANER DATA TO ANALYSE AND REPORT ON
----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW Cleaned_Car_Sales AS 
SELECT 
        year, INITCAP(make) AS Make, INITCAP(body) AS Body, INITCAP(transmission) AS Transmission,
        INITCAP(color) AS Color, UPPER(state) AS State, odometer, mmr, sellingprice, saledate
        FROM `car_sales_data`.`default`.`car_sales_dataset`
    WHERE color IS NOT NULL AND State NOT REGEXP '^[0-9]'
    AND make IS NOT NULL
    AND odometer IS NOT NULL
    AND body IS NOT NULL
    AND transmission IS NOT NULL
    AND state IS NOT NULL;

SELECT * FROM Cleaned_Car_Sales;

SELECT COUNT(*) FROM Cleaned_Car_Sales;


--------------------------------------------------------------------------------
--6. SEPARATING DAY AND DATE 
--------------------------------------------------------------------------------
SELECT 
    year, INITCAP(make) AS Make, INITCAP(body) AS Body, INITCAP(transmission) AS Transmission,
        INITCAP(color) AS Color, UPPER(state) AS State, odometer, mmr, sellingprice,
    TO_DATE(TO_TIMESTAMP(SUBSTRING(saledate, 5), 'MMM dd yyyy HH:mm:ss')) AS Sale_Date,
    DATE_FORMAT(TO_TIMESTAMP(SUBSTRING(saledate, 5), 'MMM dd yyyy HH:mm:ss'), 'EEE') AS Day_Name
    FROM Cleaned_Car_Sales
    WHERE NOT State REGEXP '^[0-9]';


--------------------------------------------------------------------------------
--7. AVERAGE SELLING PRICE BY CAR MAKE
--------------------------------------------------------------------------------
SELECT make, 
    CONCAT('$', ROUND(AVG(sellingprice), 2)) AS Avg_price
FROM Cleaned_Car_Sales
GROUP BY make
ORDER BY Avg_price DESC;


--------------------------------------------------------------------------------
--8. TOP-SELLING CAR BODY (BY CAR MAKE)
--------------------------------------------------------------------------------
SELECT make, body, COUNT(*) AS total_sales
FROM Cleaned_Car_Sales
GROUP BY make, body
ORDER BY total_sales DESC
LIMIT 10;


--------------------------------------------------------------------------------
--9. AVERAGE MILEAGE BY YEAR
--------------------------------------------------------------------------------
SELECT year, 
    CAST(ROUND(AVG(odometer), 0) AS INTEGER) AS Avg_mileage
FROM Cleaned_Car_Sales
GROUP BY year
ORDER BY year DESC;


--------------------------------------------------------------------------------
--10. TOTAL NUMBER OF CARS SOLD PER YEAR
--------------------------------------------------------------------------------
SELECT year,
    COUNT(*) AS Total_Sales_Per_Year
FROM Cleaned_Car_Sales
GROUP BY year
ORDER BY year DESC;


--------------------------------------------------------------------------------
--11. AUTOMATIC VS MANUAL TRANSMISSION
--------------------------------------------------------------------------------
SELECT transmission, COUNT(*) AS Total_By_Transmission
FROM Cleaned_car_sales
GROUP BY transmission;


--------------------------------------------------------------------------------
--12. RELATIONSHIP BETWEEN ODOMETER AND SELLING PRICE
--------------------------------------------------------------------------------
SELECT make, body, odometer, sellingprice
FROM cleaned_car_sales
WHERE odometer > 120000
ORDER BY odometer DESC;


--------------------------------------------------------------------------------
--13. CATEGORIZING ODOMETER INTO GROUPS
--------------------------------------------------------------------------------
SELECT make, body, 
    CASE 
        WHEN odometer <= 50000 THEN 'Low'
        WHEN odometer > 50000 AND odometer <= 100000 THEN 'Medium'
        WHEN odometer > 100000 THEN 'High'
    END AS Odometer_Group
    FROM cleaned_car_sales
    ORDER BY Odometer_Group DESC;


--------------------------------------------------------------------------------
--14. AVERAGE DIFFERENCE BETWEEN SELLING PRICE AND MMR
--------------------------------------------------------------------------------
SELECT make, body,
       CONCAT('$', ROUND(AVG(sellingprice - mmr)), 2) AS Avg_price_diff
FROM cleaned_car_sales
GROUP BY make, body
ORDER BY Avg_price_diff DESC;


--------------------------------------------------------------------------------
--15. BIG QUERY
--------------------------------------------------------------------------------
SELECT 
    year, 
    INITCAP(make) AS Make, 
    INITCAP(body) AS Body, 
    INITCAP(transmission) AS Transmission,
    INITCAP(color) AS Color, 
    UPPER(state) AS State,
    mmr, sellingprice,
    TO_DATE(TO_TIMESTAMP(SUBSTRING(saledate, 5), 'MMM dd yyyy HH:mm:ss')) AS Sale_Date,
    DATE_FORMAT(TO_TIMESTAMP(SUBSTRING(saledate, 5), 'MMM dd yyyy HH:mm:ss'), 'MMM') AS Month_Of_Sale,
    DATE_FORMAT(TO_TIMESTAMP(SUBSTRING(saledate, 5), 'MMM dd yyyy HH:mm:ss'), 'EEE') AS Day_Name,
    odometer,
    CASE
        WHEN odometer <= 50000 THEN 'Low'
        WHEN odometer > 50000 AND odometer <= 100000 THEN 'Medium'
        WHEN odometer > 100000 THEN 'High'
    END AS Odometer_Group
    FROM Cleaned_Car_Sales
    WHERE NOT State REGEXP '^[0-9]';