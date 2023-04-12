-- 1.1 Retrieve a list of cities
-- Initially, you need to produce a list of all of you customers' locations.
-- Write a Transact-SQL query that queries the SalesLT.Address table 
-- and retrieves the values for City and StateProvince, removing duplicates ,
-- then sorts in ascending order of StateProvince and descending order of City.

select distinct City,StateProvince
from SalesLT.Address 
order by StateProvince asc, City desc

-- 1.2 Retrieve the heaviest products information
-- Transportation costs are increasing and you need to identify the heaviest products. 
-- Retrieve the names, weight of the top ten percent of products by weight. 
select top 10 percent Name,
                      Weight
from SalesLT.Product
order by Weight DESC

-- 2.1 Filter products by color and size 
-- Retrieve the product number and name of the products that have a color of black, red, or white 
-- and a size of S or M. 
select ProductNumber, 
       Name
from SalesLT.Product
where Color in ('Black', 'Red', 'White') and Size in ('S', 'M')

-- 2.2 Filter products by color, size and product number
-- Retrieve the ProductID, ProductNumber and Name of the products, 
-- that must have Product number begins with 'BK-' followed by any character other than 'T' 
-- and ends with a '-' followed by any two numerals. 
-- And satisfy one of the following conditions:
-- o	color of black, red, or white 
-- o	size is S or M 
select ProductID,
       ProductNumber,
       Name
from SalesLT.Product
where ProductNumber like 'BK-%[^T]%-[1-9][1-9]'
      and (Color in ('Black', 'Red', 'While') or Size in ('S','M') )

-- 2.3 Retrieve specific products by product ID 
-- Retrieve the product ID, product number, name, and
-- list price of products whose product name contains "HL " or "Mountain",
-- product number is at least 8 characters and never have been ordered.
select ProductID,
       Name,
       ProductNumber,
       ListPrice
from SalesLT.Product
where Name like '%HL%' or Name like '%Mountain%'
and ProductNumber like '%________%'
and SellEndDate = NULL

    


