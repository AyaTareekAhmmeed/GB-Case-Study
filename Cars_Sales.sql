select *
from Opportunities

--DATA Cleaning
select *
from Opportunities
where attribute<>payment_type 
and payment_type is not null

--it was susbended that columns payment_type and attribute are equal by first look
--but after run the last query we recognize that they arn't equal

--Standardize Data Format
--invoice date 
Alter Table Opportunities
Add Invoice_Date_M Date

Update Opportunities
Set Invoice_Date_M = Convert(Date,invoice_date)

alter table Opportunities
drop column invoice_date

--receipt date 
Alter Table Opportunities
Add Receipt_Date_M Date

Update Opportunities
Set Receipt_Date_M = Convert(Date,receipt_date)

alter table Opportunities
drop column receipt_date

--receipt creation date 
Alter Table Opportunities
Add Receipt_Creation_Date_M Date

Update Opportunities
Set Receipt_Creation_Date_M = Convert(Date,receipt_creation_date)

alter table Opportunities
drop column receipt_creation_date

--sales order creation date
Alter Table Opportunities
Add SO_Creation_Date_M Date

Update Opportunities
Set SO_Creation_Date_M = Convert(Date,so_creation_date)

alter table Opportunities
drop column so_creation_date

--Check for Duplicates rows
WITH RowNumCTE 
AS(
select *
,ROW_NUMBER() over(
				partition by
      [order_number]
      ,[flow_status_code]
      ,[sold_customer_number]
      ,[payment_type]
      ,[po_amount]
      ,[po_approval_status]
      ,[brand]
      ,[model_year]
      ,[model]
      ,[Brand1]
      ,[Model1]
      ,[Engine Capacity]
      ,[Body Type]
      ,[Transmission Type]
      ,[Trim]
      ,[invoice_date_m]
      ,[invoice_amount]
      ,[attribute9]
      ,[receipt_type]
      ,[receipt_number]
      ,[receipt_date_m]
      ,[receipt_creation_date_m]
      ,[receipt_amount]
      ,[move_number]
      ,[opportunity_status]
      ,[wish_list]
      ,[so_creation_date_m]
      ,[receipt_status]
      ,[unit_list_price]
		order by opportunity_id) as rownum
From Opportunities
)
Select * 
from RowNumCTE
where rownum >1

--there is no dublicates

---------------------------------------------------------------
--Data Exploration
--Search for null values
select *
from Opportunities
where flow_status_code is null            --One row

delete from Opportunities
where flow_status_code is null
-----------------------------------------
select *
from Opportunities
where po_approval_status is null          --99 rows

select *
from Opportunities
where model_year is null                 --92 rows

select *
from Opportunities
where Model1 is null                 --24 rows
--It seems for model1 here there is a problems with another columns
                      
select *
from Opportunities
where brand<>Brand1 
or brand is null
or Brand1 is null                    --24 rows

--it seems here that all 24 cars is HYUNDAI
update Opportunities
set brand = 'HYUNDAI'
where Model1 is null

--for Model
update Opportunities
set model = SUBSTRING(Brand1 , 1 , CHARINDEX('1',Brand1) -2)
where Model1 is null

--for engine capacity
update Opportunities
set [Engine Capacity] = SUBSTRING(Brand1 , CHARINDEX('1',Brand1) ,3)
where Model1 is null

select SUBSTRING(Brand1 , CHARINDEX('1',Brand1) ,3)
from Opportunities
where Model1 is null

--for Body Type
update Opportunities
set [Body Type] = Case
	When model = 'ELANTRA CN7' then 'SEDAN'
	when model = 'ELANTRA HD' then 'SEDAN'
	when model = 'I20' then 'HATCHBACK'
	END
where Model1 is null

--For transsmission type
update Opportunities
set [Transmission Type] = case 
	   when model = 'ELANTRA CN7' then SUBSTRING(Brand1 , CHARINDEX('1',Brand1) +4 , 2)
	   when model = 'ELANTRA HD' then SUBSTRING(Brand1 , CHARINDEX('1',Brand1) +6 , 2)
	   when model = 'I20' then SUBSTRING(Brand1 , CHARINDEX('1',Brand1) +4 , 3)
	   End
where Model1 is null

select case 
	   when model = 'ELANTRA CN7' then SUBSTRING(Brand1 , CHARINDEX('1',Brand1) +4 , 2)
	   when model = 'ELANTRA HD' then SUBSTRING(Brand1 , CHARINDEX('1',Brand1) +6 , 2)
	   when model = 'I20' then SUBSTRING(Brand1 , CHARINDEX('1',Brand1) +4 , 3)
	   End
from Opportunities
where Model1 is null

--For Trim
update Opportunities
set Trim = case 
	   when model = 'ELANTRA CN7' then SUBSTRING(Brand1 , CHARINDEX('T',Brand1 ,CHARINDEX('.',Brand1)+4) +2, LEN(brand1))
	   when model = 'ELANTRA HD' then SUBSTRING(Brand1 , CHARINDEX('T',Brand1 ,CHARINDEX('.',Brand1)+4) +2, LEN(brand1))
	   when model = 'I20' then SUBSTRING(Brand1 , CHARINDEX('T',Brand1 ,CHARINDEX('.',Brand1)+5) +2, LEN(brand1))
	   End
where Model1 is null

select case 
	   when model = 'ELANTRA CN7' then SUBSTRING(Brand1 , CHARINDEX('T',Brand1 ,CHARINDEX('.',Brand1)+4) +2, LEN(brand1))
	   when model = 'ELANTRA HD' then SUBSTRING(Brand1 , CHARINDEX('T',Brand1 ,CHARINDEX('.',Brand1)+4) +2, LEN(brand1))
	   when model = 'I20' then SUBSTRING(Brand1 , CHARINDEX('T',Brand1 ,CHARINDEX('.',Brand1)+5) +2, LEN(brand1))
	   End
from Opportunities
where Model1 is null

--brand1 column
--Update brand1 to check equality with brand
update Opportunities
set Brand1 = brand
where Model1 is null

select *
from Opportunities
where brand<>Brand1 
or brand is null
or Brand1 is null                  --zero rows
--Now we can drop brand1 column
alter table Opportunities
drop column brand1


--model1 column
--Update model1 to check equality with model
select *
from Opportunities
where Model1 is null

update Opportunities
set Model1 = model
where Model1 is null

select *
from Opportunities
where model<>Model1         --zero rows

--Now we can drop model1 column
alter table Opportunities
drop column Model1

--po_approval_status
Update Opportunities
Set po_approval_status = 'UnKnown'
where po_approval_status = 'null'
or po_approval_status is null


select *
from Opportunities
where po_approval_status is null

--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--SQL Questions:
--Sales by Brand and Model
select brand , sum(invoice_amount) as total_Invoice_amount_per_brand 
from Opportunities
group by brand
order by total_Invoice_amount_per_brand desc

select brand ,model , sum(invoice_amount) as total_Invoice_amount_per_brand 
from Opportunities
group by brand , model
order by total_Invoice_amount_per_brand desc


--Top Customers by Order Amount
SELECT*
FROM Opportunities
where [Engine Capacity] is null

--change null values at opportunity_stutes with Not Provided
UPDATE Opportunities
SET opportunity_status='Not Provided'
WHERE opportunity_status IS null;

SELECT*
FROM Opportunities
where [opportunity_status] is null

SELECT*
FROM Opportunities

--payment_type
Update Opportunities
Set payment_type = 'Not Provided'
where payment_type = 'null'
or payment_type is null


--Questions
--Sales by Brand and Model: Write a SQL query to retrieve the total sales amount for each brand and model combination.
select brand ,model , sum(invoice_amount) as total_Invoice_amount_per_brand 
from Opportunities
group by brand , model
order by total_Invoice_amount_per_brand desc


--Top Customers by Order Amount: Create a SQL query to identify the top 10 customers with the highest total order amounts.
SELECT TOP 10
    sold_customer_number,
    SUM(po_amount) AS total_order_amount
FROM
    Opportunities
GROUP BY
    sold_customer_number
ORDER BY
    total_order_amount DESC;



--Monthly Invoice Amount Trend: 
--Write a SQL query to calculate the monthly total invoice amount and present it in a time series format.
SELECT
    YEAR(Invoice_Date_M) AS invoice_year,
    MONTH(Invoice_Date_M) AS invoice_month,
    SUM(invoice_amount) AS monthly_total_invoice_amount
FROM
    Opportunities
GROUP BY
    YEAR(Invoice_Date_M),
    MONTH(Invoice_Date_M)
ORDER BY
    invoice_year, invoice_month;



--Payment Type Distribution: Develop an SQL query to count the occurrences of each payment type in the dataset.
SELECT
    payment_type,
    COUNT(*) AS payment_type_count
FROM
    Opportunities
GROUP BY
    payment_type;


SELECT
    payment_type,
    COUNT(*) AS payment_type_count
FROM
    Opportunities
WHERE
    payment_type <> 'Not Provided'
GROUP BY
    payment_type;



-- Average Time for Order Fulfillment: Write an SQL query to calculate the average time taken for order fulfillment, considering the duration between order creation and shipment.
SELECT
    AVG(CAST(DATEDIFF(DAY, Invoice_Date_M, SO_Creation_Date_M) AS int)) AS average_fulfillment_time_in_days
FROM
    Opportunities
WHERE
    SO_Creation_Date_M IS NOT NULL
    AND Invoice_Date_M IS NOT NULL;