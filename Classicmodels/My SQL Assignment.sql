-- MySQL ASSIGNMENTS -- SUBMITTED BY:- ANAGHA J. H. 

SHOW tables;


#### a) Employee number,first name and last name of employees working as Sales Rep reporting to employee with employeenumber 1102 
SELECT*from employees;

SELECT distinct employeeNumber,
firstname,
lastname 
FROM employees 
WHERE jobTitle LIKE 'sales rep%' 
AND reportsTo = 1102;
#### b) Unique productline values containing the word cars at the end from the products table
SELECT*FROM products;

SELECT DISTINCT productline
FROM PRODUCTS
WHERE productline LIKE '%cars';

########################################################################################################################################

#### Q2. a) Segment customers into three categories based on their country using CASE statement
SELECT customerNumber,customerName,
CASE 
WHEN country IN ('USA','Canada') THEN 'North America'
WHEN country IN ('UK','France','Germany') THEN 'Europe'
ELSE 'Others'
END AS 'CustomerSegment'
FROM customers;

########################################################################################################################################

#### Q3. a) Identify the top 10 products (by productCode) with the highest total order quantity across all orders
SELECT*FROM orderdetails;

SELECT productcode,sum(quantityordered) AS total_ordered
FROM orderdetails
GROUP BY productCode
HAVING total_ordered>1000
ORDER BY total_ordered desc
LIMIT 10;
#### b) Count total number of payments for each month, filter months with more than 20 payments, sort by payment count in descending order.
SELECT MONTHNAME(paymentDate) AS payment_month,
COUNT(customerNumber) AS num_payment
FROM payments
GROUP BY payment_month
HAVING num_payment > 20
ORDER BY num_payment DESC;

#######################################################################################################################################

#### Q4. a) Create a table named Customers to store customer information.
CREATE DATABASE CUSTOMER_ORDERS;
USE CUSTOMER_ORDERS;

CREATE TABLE Customer(customer_ID int AUTO_INCREMENT PRIMARY KEY,
first_name varchar(50),
last_name varchar(50),
email varchar(255),
phone_number varchar(20) );
DESC customer;

ALTER TABLE customer MODIFY first_name varchar(50) NOT NULL,
MODIFY last_name varchar(50) NOT NULL; 
#### b) Create a table named Orders to store information about customer orders
CREATE TABLE Orders (
Order_ID INT AUTO_INCREMENT PRIMARY KEY,
Customer_ID INT, 
FOREIGN KEY(Customer_ID) REFERENCES customer(Customer_ID),
Order_date DATE,
Total_Amount DECIMAL(10,2) CHECK (Total_Amount>0)); 

DESC Orders;

####################################################################################################################################

#### Q5. List the top 5 countries (by order count) that Classic Models ships to
SELECT * FROM customers;
SELECT * FROM Orders;

SELECT country, count(ordernumber) AS order_count 
FROM customers c 
INNER JOIN orders o ON c.customernumber=o.customernumber 
GROUP BY c.country
ORDER BY order_count DESC
LIMIT 5;

#######################################################################################################################################

#### Q6. Create a table project and add data into it. Find the names of employees and their related managers
CREATE TABLE Project (
EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
FullName VARCHAR(50) NOT NULL,
Gender ENUM ('Male','Female'),
ManagerID INT);
DESC Project;

INSERT INTO Project VALUES (1,"Pranaya","Male",3),
(2,"Priyanka","Female",1),
(3,"Preety","Female",null),
(4,"Anurag","Male",1),
(5,"Sambit","Male",1),
(6,"Rajesh","Male",3),
(7,"Hina","Male",3);
SELECT * FROM Project;

SELECT m.FullName AS Manager_Name, e.Fullname AS Emp_Name FROM Project e 
JOIN Project m 
ON (e.EmployeeID=m.EmployeeID);

#######################################################################################################################################

#### Q7. Create table facility
CREATE TABLE facility(FacilityID int,
Name varchar(100),
State varchar(100),
Country varchar(100));
DESC facility;

#### (i) Alter the table by adding the primary key and auto increment to Facility_ID column
ALTER TABLE facility MODIFY facilityID int auto_increment primary key;
#### (ii) Add a new column city after name with data type as varchar which should not accept any null values
ALTER TABLE facility ADD City varchar(100) NOT NULL AFTER name;

#######################################################################################################################################

#### Q8. Create a view named product_category_sales that provides insights into sales performance by product category
CREATE VIEW product_sales_category AS
SELECT productLine,
SUM(quantityOrdered * priceEach) AS total_sales,
COUNT(DISTINCT orderNumber) AS number_of_orders
FROM productlines
JOIN products USING (productLine)
JOIN orderdetails USING (productCode)
JOIN orders USING (orderNumber)
GROUP BY productLine;
SELECT * FROM product_sales_category;

########################################################################################################################################
#### Q9. Create a stored procedure `Get_country_payments` that accepts  year and country as inputs and returns the total payment amount for the specified year and country.

 DELIMITER $$

CREATE PROCEDURE Get_country_payments(IN year_in INT, IN country_in VARCHAR(100))
BEGIN
    SELECT
        YEAR(p.paymentDate) AS Year,
        c.country,
        CONCAT(FORMAT(SUM(p.amount) / 1000, 0), 'K') AS Total_Amount
    FROM
        Payments p
        JOIN Customers c ON p.customerNumber = c.customerNumber
    WHERE
        YEAR(p.paymentDate) = year_in AND
        c.country = country_in
    GROUP BY
        Year, c.country;
END $$

DELIMITER ;

CALL classicmodels.Get_country_payments(2003,'France');

########################################################################################################################################
#### Q10. a) Using customers and orders tables, rank the customers based on their order frequency
SELECT * FROM customers; 
SELECT * FROM orders;
SELECT DISTINCT customerName,
COUNT(customerNumber) AS Order_Count,
RANK() OVER(ORDER BY COUNT(customerNumber) DESC) AS order_frequency_rnk
FROM customers
JOIN orders USING (customerNumber)
GROUP BY customerNumber
ORDER BY Order_Count DESC;
#### b) Calculation of %YOY
SELECT YEAR(orderDate) AS Year,
MONTHNAME(orderDate) AS Month,
COUNT(orderNumber) AS Total_Orders,
CONCAT(
ROUND(
((COUNT(orderNumber)-LAG(COUNT(orderNumber)) OVER())/LAG(COUNT(orderNumber)) OVER())*100),
"%") AS "% YOY Change"
FROM orders
GROUP BY Year, Month;

########################################################################################################################################
#### Q11. Find the number of product lines where buy price value is greater than average of buy price value
SELECT productline, COUNT(productline) AS Total 
FROM products
WHERE buyprice>(SELECT AVG(buyprice) FROM products) 
GROUP BY productline; 

########################################################################################################################################

#### Q12. Create the table Emp_EH. Create a procedure to accept the values for the columns in Emp_EH and handle the error using exception handling concept.
CREATE TABLE Emp_EH(EmpID INT,
EmpName VARCHAR(50),
EmailAddress VARCHAR(50),
CONSTRAINT PK_Emp PRIMARY KEY (EmpID));
 DESC Emp_EH; 
 
 DELIMITER $$
 CREATE PROCEDURE Emp(
 IN Emp_name VARCHAR(50),
 IN Emp_email VARCHAR(50)
 )
 BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'ERROR Occured' AS MESSAGE;
	END;
    
    INSERT INTO Emp_EH(EmpName,EmailAddress)
    VALUES (Emp_name,Emp_email);
    
    SELECT 'Inserted Successfully'AS MESSAGE;
END$$
DELIMITER ;

CALL classicmodels.Emp('Smith', 'smith@gmail.com');

########################################################################################################################################

#### Q13. Create the table Emp_BIT. Insert the data. Create before insert trigger to make sure that the working hours entered in negative are converted to positive.
CREATE TABLE Emp_BIT(Name VARCHAR(50) NOT NULL,
Occupation VARCHAR(50) NOT NULL,
Working_Date DATE,
Working_hrs INT);
DESC Emp_BIT;

INSERT INTO Emp_BIT VALUES ('Robin', 'Scientist', '2020-10-04', 12),  
('Warner', 'Engineer', '2020-10-04', 10),  
('Peter', 'Actor', '2020-10-04', 13),  
('Marco', 'Doctor', '2020-10-04', 14),  
('Brayden', 'Teacher', '2020-10-04', 12),  
('Antonio', 'Business', '2020-10-04', 11); 
SELECT * FROM Emp_BIT;

DELIMITER $$
CREATE TRIGGER before_insert_empworkinghours
BEFORE INSERT ON Emp_BIT 
FOR EACH ROW
BEGIN
	IF NEW.working_hrs < 0 THEN
		SET NEW.working_hrs = -NEW.working_hrs;
    END IF;
END;
$$
DELIMITER ;

INSERT INTO Emp_BIT 
VALUES ('Alexander', 'Doctor', '2020-10-04', -6);
SELECT * FROM Emp_BIT;

########################################################################################################################################
