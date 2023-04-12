-- Task 1:
--   
-- 1.1 Retrieve customer names and phone numbers
-- o Each customer has an assigned salesperson. You must write a query to create a call
-- sheet that lists:
--  The salesperson
--  A column named CustomerName that displays how the customer contact should
-- be greeted (for example, Mr Smith)
--  The customer’s phone number.

select right(SalesPerson, len(SalesPerson) - charindex('\', SalesPerson)) as SalesPersonName
      ,CONCAT_WS(' ', MiddleName, LastName) as CustomerName 
      ,Phone
from SalesLT.Customer

-- 1.2 Retrieve the heaviest products information
-- Transportation costs are increasing and you need to identify the heaviest products. Retrieve the
-- names, weight of the top ten percent of products by weight.
-- Then, add new column named Number of sell days (caculated from SellStartDate and SellEndDate)
-- of these products (if sell end date isn't defined then get Today date)

select top 10 percent Name
                    ,Weight
                    ,datediff(day, SellStartDate, iif(SellEndDate is null, CURRENT_TIMESTAMP, SellEndDate)) as 'Number of sell days'
from SalesLT.Product
order by Weight DESC

-- Task 2: Retrieve customer order data 
--  
-- -- 2.1 As you continue to work with the Adventure Works customer data, you must create
-- -- queries for reports that have been requested by the sales team.
-- -- Retrieve a list of customer companies
-- -- o You have been asked to provide a list of all customer companies in the
-- -- format Customer ID : Company Name - for example, 78: Preferred Bikes
select concat(CustomerID, ':', ' ', CompanyName) as 'Customer companies'
from SalesLT.Customer

-- 2.2 Retrieve a list of sales order revisions
-- o The SalesLT.SalesOrderHeader table contains records of sales orders. You have
-- been asked to retrieve data for a report that shows:
--  The sales order number and revision number in the format () – for example
-- SO71774 (2).
--  The order date converted to ANSI standard 102 format (yyyy.mm.dd – for
-- example 2015.01.31).

select concat(SalesOrderNumber, ' ', '(', RevisionNumber, ')'),
       convert(varchar(30), OrderDate, 102)
from SalesLT.SalesOrderHeader

-- Task 3: Retrieve customer contact details (hard) 
-- 3.1 Some records in the database include missing or unknown values that are returned
-- as NULL. You must create some queries that handle these NULL values appropriately.
-- Retrieve customer contact names with middle names if known
-- o You have been asked to write a query that returns a list of customer names.
-- The list must consist of a single column in the format first last (for
-- example Keith Harris) if the middle name is unknown, or first middle last (for
-- example Jane M. Gates) if a middle name is known.
select iif(MiddleName is null, concat(FirstName, ' ', LastName), concat_ws(' ', FirstName, MiddleName, LastName)) as 'Full name'
from SalesLT.Customer

-- 3.2 Retrieve primary contact details
-- o Customers may provide Adventure Works with an email address, a phone
-- number, or both. If an email address is available, then it should be used as
-- the primary contact method; if not, then the phone number should be used.
-- You must write a query that returns a list of customer IDs in one column, and
-- a second column named PrimaryContact that contains the email address if
-- known, and otherwise the phone number.
select CustomerID
      ,iif(EmailAddress is null, Phone, EmailAddress) as PrimaryContact
from SalesLT.Customer

-- As you continue to work with the Adventure Works customer, product and sales
-- data, you must create queries for reports that have been requested by the sales team.
-- Retrieve a list of customers with no address
-- o A sales employee has noticed that Adventure Works does not have address
-- information for all customers. You must write a query that returns a list of
-- customer IDs, company names, contact names (first name and last name),
-- and phone numbers for customers with no address stored in the database.

select CustomerID
      ,CompanyName
      ,concat(FirstName, ' ', LastName) as ContactName
      ,Phone
from SalesLT.Customer
where CustomerID not in (select CustomerID from SalesLT.CustomerAddress)
