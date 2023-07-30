-- Explorating the tables of the database (OK)

SELECT *
FROM [Portfolio Project].dbo.Price;




SELECT *
FROM [Portfolio Project].dbo.Car_Region;




SELECT *
FROM [Portfolio Project].dbo.Car_Detail;




SELECT * 
FROM [Portfolio Project].dbo.Torque;



-- Checking cars' brands in the dataset 
SELECT DISTINCT name AS BRAND
FROM [Portfolio Project].dbo.Price
ORDER BY 1;

-- Checking total cars' quantity per brand 
SELECT name AS BRAND,
       COUNT(sold) AS TOTAL_CAR_NUMBER
FROM [Portfolio Project].dbo.Price
GROUP BY name
ORDER BY 2 DESC;

-- Checking the quantity of sold cars per brand 
SELECT name AS Brand,
       COUNT(sold) AS SOLD_CARS
FROM [Portfolio Project].dbo.Price
WHERE sold = 'Y'
GROUP BY name,
         sold
ORDER BY 2 DESC;

-- Checking Top5 most sold cars in all period 
SELECT name AS Brand,
       COUNT(sold) AS COUNT
FROM [Portfolio Project].dbo.Price
WHERE sold = 'Y'
GROUP BY name,
         sold
ORDER BY 2 DESC
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;


-- Checking quantity of not sold cars per brand 
SELECT name AS Brand,
       COUNT(sold) AS COUNT
FROM [Portfolio Project].dbo.Price
WHERE sold = 'N'
GROUP BY name,
         sold
ORDER BY 2 DESC;

-- Checking TOP5 less sold cars in all period 
SELECT name AS Brand,
       COUNT(sold) AS COUNT
FROM [Portfolio Project].dbo.Price
WHERE sold = 'N'
GROUP BY name,
         sold
ORDER BY 2 ASC
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;


-- Checking cars' total, sold, and not sold quantity per cars' year
SELECT t2.year,
       COUNT(t1.sold) AS TOTAL_CAR_NUMBER,
       COUNT(CASE
                 WHEN t1.sold = 'Y' THEN t1.sold
                 ELSE NULL
             END) AS SOLD_CAR_NUMBER,
       COUNT(CASE
                 WHEN t1.sold = 'N' THEN t1.sold
                 ELSE NULL
             END) AS NOTSOLD_CAR_NUMBER
FROM [Portfolio Project].dbo.Price t1
INNER JOIN [Portfolio Project].dbo.Car_Detail t2 ON t1.Sales_ID = t2.Sales_ID
GROUP BY t2.year
ORDER BY t2.year


-- Using Common Table Expression[CTE] to get the percentage of sold and not sold used car per cars' year
WITH PERCENTAGE (YEAR, TOTAL_CAR_NUMBER, SOLD_CAR_NUMBER, NOTSOLD_CAR_NUMBER) AS
  (SELECT t2.year,
          COUNT(t1.sold) AS TOTAL_CAR_NUMBER,
          COUNT(CASE
                    WHEN t1.sold = 'Y' THEN t1.sold
                    ELSE NULL
                END) AS SOLD_CAR_NUMBER,
          COUNT(CASE
                    WHEN t1.sold = 'N' THEN t1.sold
                    ELSE NULL
                END) AS NOTSOLD_CAR_NUMBER
   FROM [Portfolio Project].dbo.Price t1
   INNER JOIN [Portfolio Project].dbo.Car_Detail t2 ON t1.Sales_ID = t2.Sales_ID
   GROUP BY t2.year)
SELECT YEAR,
       TOTAL_CAR_NUMBER,
       CASE
           WHEN SOLD_CAR_NUMBER = 0 THEN NULL
           ELSE SOLD_CAR_NUMBER*100/TOTAL_CAR_NUMBER
       END AS SOLD_PERCENTAGE,
       CASE
           WHEN NOTSOLD_CAR_NUMBER = 0 THEN NULL
           ELSE NOTSOLD_CAR_NUMBER*100/TOTAL_CAR_NUMBER
       END AS NOTSOLD_PERCENTAGE
FROM PERCENTAGE
ORDER BY YEAR



-- Total revenue and average ticket from sold cars per region 
SELECT t2.[State or Province],
       COUNT(t1.name) AS Qty,
       SUM(t1.selling_price)*0.069 AS 'REVENUE(R$)',
       (SUM(t1.selling_price)/COUNT(t1.name))*0.069 AS AVG_TICKET
FROM [Portfolio Project].dbo.Price t1
INNER JOIN [Portfolio Project].dbo.Car_Region t2 ON t1.Sales_ID = t2.Sales_ID
WHERE t1.sold = 'Y'
GROUP BY t2.[State or Province]
ORDER BY 3 DESC

/* According to the query above:
 PS1: Note that even though some States sold more car quantity, not always they have the highest revenue compared to the states that had sold less car quantity. (Example: Ilinois and Texas)
 PS2: Note that even though some States had more revenue, not always they have the highest average ticket compared to the states that had less revenues. (Example: Ilinois and Florida)*/


-- Since New York State has the highest revenues by selling used cars, next step is to check which cars' brands brought more revenue in New York.
SELECT t1.name AS BRAND,
       t2.[State or Province] AS STATE,
       SUM(t1.selling_price)*0.069 AS 'CAR_REVENUE(R$)',
       COUNT(t1.sold) AS CAR_QTY
FROM [Portfolio Project].dbo.Price t1
INNER JOIN [Portfolio Project].dbo.Car_Region t2 ON t1.Sales_ID = t2.Sales_ID
WHERE t2.[State or Province] = 'New York'
  AND t1.sold = 'Y'
GROUP BY t1.name,
         t2.[State or Province]
ORDER BY 3 DESC;

-- From the previous query, we can see that Maruti was the TOP1 sold brand in New York State, selling 96 cars with a revenue of R$2767175,931

-- Now, let's take a look more closely to New York State, analyzing which City has the highest used cars' revenues
SELECT t2.City,
       SUM(t1.selling_price)*0.069 AS 'CAR_REVENUE(R$)',
       COUNT(t1.sold) AS CAR_QTY
FROM [Portfolio Project].dbo.Price t1
INNER JOIN [Portfolio Project].dbo.Car_Region t2 ON t1.Sales_ID = t2.Sales_ID
WHERE t2.[State or Province] = 'New York'
  AND t1.sold = 'Y'
GROUP BY t2.City
ORDER BY 3 DESC;

-- Analyzing the previous query result, we can see that New York City is the location that had the highest revenues from used cars in New York State


-- Now, let's take a look at how kilometer driven influences in the selling price of a car
SELECT *
FROM [Portfolio Project].dbo.Price
WHERE km_driven = 100000
  AND name = 'Maruti'
ORDER BY selling_price DESC

-- As we can see from the previous query, there are several Maruti's cars with the same km driven but with distinct selling prices


-- Now we want to understand which factors are more important in deciding cars' selling price
SELECT t1.Sales_ID,
       t1.name,
       t2.torque,
       t3.owner,
       t3.year,
       t4.[State or Province],
       t1.km_driven,
       t1.selling_price*0.069 AS selling_price,
       t4.City
FROM [Portfolio Project].dbo.Price t1
INNER JOIN [Portfolio Project].dbo.Torque t2 ON t1.Sales_ID = t2.Sales_ID
INNER JOIN [Portfolio Project].dbo.Car_Detail t3 ON t3.Sales_ID = t1.Sales_ID
INNER JOIN [Portfolio Project].dbo.Car_Region t4 ON t4.Sales_ID = t1.Sales_ID
WHERE km_driven = 100000
  AND t1.name = 'Maruti'
  AND t2.torque = '190Nm@ 2000rpm'
  AND t3.owner = 'Second_Owner'
ORDER BY t1.selling_price DESC


/* According to the previous query's result:
Selecting Maruti's car brand, fixing the km driven to 100000km and getting the same torque,
we can see that the most impactful factor in the price of a car is the cars' year, but also the State 
is relevant, for example, if we compare Sales_ID = 5877 (Florida) and Sales_ID = 6845 (Massachusetts), 
we can see that the cars' attributes are all the same (km driven, torque, qty of owners, and car year)
but the selling price's difference is considerable (39537[R$] vs 31739[R$]), so this is a variable that shifts according to each State
The number of owners is also impactful, but as we can see the priority of relevance of the attributes seems to be: Cars' Year > State > Qty of Owners*/


-- Creating some views for later visualization

CREATE VIEW TOTAL_BRANDS_CAR AS
SELECT name AS Brand,
       COUNT(sold) AS TOTAL_CAR_NUMBER
FROM [Portfolio Project].dbo.Price
GROUP BY name 

CREATE VIEW TOTAL_SOLD_NOTSOLD AS
SELECT t2.year,
       COUNT(t1.sold) AS TOTAL_CAR_NUMBER,
       COUNT(CASE
                 WHEN t1.sold = 'Y' THEN t1.sold
                 ELSE NULL
             END) AS SOLD_CAR_NUMBER,
       COUNT(CASE
                 WHEN t1.sold = 'N' THEN t1.sold
                 ELSE NULL
             END) AS NOTSOLD_CAR_NUMBER
FROM [Portfolio Project].dbo.Price t1
INNER JOIN [Portfolio Project].dbo.Car_Detail t2 ON t1.Sales_ID = t2.Sales_ID
GROUP BY t2.year

-- View 1
CREATE VIEW SOLD_NOTSOLD_PERCENTAGE AS
SELECT t2.year,
       COUNT(t1.sold) AS TOTAL_CAR_NUMBER,
       COUNT(CASE
                 WHEN t1.sold = 'Y' THEN t1.sold
                 ELSE NULL
             END)*100/COUNT(t1.sold) AS SOLD_PERCENTAGE,
       COUNT(CASE
                 WHEN t1.sold = 'N' THEN t1.sold
                 ELSE NULL
             END)*100/COUNT(t1.sold) AS NOT_SOLD_PERCENTAGE
FROM [Portfolio Project].dbo.Price t1
INNER JOIN [Portfolio Project].dbo.Car_Detail t2 ON t1.Sales_ID = t2.Sales_ID
GROUP BY t2.year

-- View 2
CREATE VIEW STATE_REVENUE_AVGTICKET AS
SELECT t2.[State or Province],
       COUNT(t1.name) AS Qty,
       SUM(t1.selling_price)*0.069 AS 'REVENUE(R$)',
       (SUM(t1.selling_price)/COUNT(t1.name))*0.069 AS AVG_TICKET
FROM [Portfolio Project].dbo.Price t1
INNER JOIN [Portfolio Project].dbo.Car_Region t2 ON t1.Sales_ID = t2.Sales_ID
WHERE t1.sold = 'Y'
GROUP BY t2.[State or Province]
ORDER BY 3 DESC
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;

-- View 3
CREATE VIEW NY_STATE_BRANDS AS
SELECT t1.name AS BRAND,
       t2.[State or Province] AS STATE,
       SUM(t1.selling_price)*0.069 AS 'CAR_REVENUE(R$)',
       COUNT(t1.sold) AS CAR_QTY
FROM [Portfolio Project].dbo.Price t1
INNER JOIN [Portfolio Project].dbo.Car_Region t2 ON t1.Sales_ID = t2.Sales_ID
WHERE t2.[State or Province] = 'New York'
  AND t1.sold = 'Y'
GROUP BY t1.name,	
         t2.[State or Province];

-- View 4
CREATE VIEW NY_CITIES_REVENUE AS
SELECT t2.City,
       SUM(t1.selling_price)*0.069 AS 'CAR_REVENUE(R$)',
       COUNT(t1.sold) AS CAR_QTY
FROM [Portfolio Project].dbo.Price t1
INNER JOIN [Portfolio Project].dbo.Car_Region t2 ON t1.Sales_ID = t2.Sales_ID
WHERE t2.[State or Province] = 'New York'
  AND t1.sold = 'Y'
GROUP BY t2.City
ORDER BY 2 DESC
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;

-- View 5
CREATE VIEW VARIABLES_ON_CARS_PRICE AS
SELECT t1.Sales_ID,
       t1.name,
       t2.torque,
       t3.owner,
       t3.year,
       t4.[State or Province],
       t1.km_driven,
       t1.selling_price*0.069 AS selling_price,
       t4.City
FROM [Portfolio Project].dbo.Price t1
INNER JOIN [Portfolio Project].dbo.Torque t2 ON t1.Sales_ID = t2.Sales_ID
INNER JOIN [Portfolio Project].dbo.Car_Detail t3 ON t3.Sales_ID = t1.Sales_ID
INNER JOIN [Portfolio Project].dbo.Car_Region t4 ON t4.Sales_ID = t1.Sales_ID
WHERE km_driven = 100000
  AND t1.name = 'Maruti'
  AND t2.torque = '190Nm@ 2000rpm';


-- View 6


SELECT t1.name AS BRAND,
       COUNT(CASE
                 WHEN t1.sold = 'Y' THEN t1.sold
                 ELSE NULL
             END) AS SOLD_CAR_NUMBER,
       COUNT(CASE
                 WHEN t1.sold = 'N' THEN t1.sold
                 ELSE NULL
             END) AS NOTSOLD_CAR_NUMBER,
       COUNT(t1.sold) AS TOTAL_CAR_NUMBER,
       COUNT(CASE
                 WHEN t1.sold = 'Y' THEN t1.sold
                 ELSE NULL
             END)*100/COUNT(t1.sold) AS SOLD_PERCENTAGE
FROM [Portfolio Project].dbo.Price t1
INNER JOIN [Portfolio Project].dbo.Car_Detail t2 ON t1.Sales_ID = t2.Sales_ID
GROUP BY t1.name


-- View 7
SELECT t2.year,
       COUNT(t1.sold) AS TOTAL_CAR_NUMBER,
       COUNT(CASE
                 WHEN t1.sold = 'Y' THEN t1.sold
                 ELSE NULL
             END)*100/COUNT(t1.sold) AS SOLD_PERCENTAGE
FROM [Portfolio Project].dbo.Price t1
INNER JOIN [Portfolio Project].dbo.Car_Detail t2 ON t1.Sales_ID = t2.Sales_ID
GROUP BY t2.year;






















SELECT t2.year,
                       COUNT(CASE
                 WHEN t1.sold = 'Y' THEN t1.sold
                 ELSE NULL
             END) AS SOLD_CAR_NUMBER,
           COUNT(CASE
                 WHEN t1.sold = 'N' THEN t1.sold
                 ELSE NULL
             END) AS NOTSOLD_CAR_NUMBER,
			 COUNT(t1.sold) AS TOTAL_CAR_NUMBER,
			            COUNT(CASE
                 WHEN t1.sold = 'Y' THEN t1.sold
                 ELSE NULL
             END)*100/COUNT(t1.sold) AS SOLD_PERCENTAGE
			 
FROM [Portfolio Project].dbo.Price t1
INNER JOIN [Portfolio Project].dbo.Car_Detail t2 ON t1.Sales_ID = t2.Sales_ID
GROUP BY t2.year





SELECT t1.name,
       SUM(t1.selling_price)*0.069 AS 'CAR_REVENUE(R$)',
       COUNT(t1.sold) AS CAR_QTY
FROM [Portfolio Project].dbo.Price t1
INNER JOIN [Portfolio Project].dbo.Car_Region t2 ON t1.Sales_ID = t2.Sales_ID
WHERE t2.[State or Province] = 'New York'
  AND t1.sold = 'Y'
GROUP BY t1.name
ORDER BY 2 DESC
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;



 









































