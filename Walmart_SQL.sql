-- Show the entire table
select * from "Walmart"

-- Count the number of records in table
select
	count(*) as records
from "Walmart"

-- Show the different branches
select 
	distinct (branch) as branches
from "Walmart"
order by branches

-- Count the number of different branches
select
	count(distinct(branch)) as no_of_branches
from "Walmart"

-- Show the different cities
select
	distinct(city) as cities
from "Walmart" 
order by cities

-- Count the number of different cities
select
	count(distinct(city)) as no_of_cities
from "Walmart"

-- Show the different categories
select
	distinct(category) as categories
from "Walmart"
order by categories

-- Show the different payment methods
select 
	distinct(payment_method) as payment_methods
from "Walmart"
order by payment_method

-- Show the minimum, maximum and average unit price
select 
	min(unit_price) as min_unit_price,
	max(unit_price) as max_unit_price,
	avg(unit_price) as avg_unit_price
from "Walmart"

-- Show the minimum, maximum and average rating
select 
	min(rating) as min_rating,
	max(rating) as max_rating,
	avg(rating) as avg_rating
from "Walmart"

-- Show the total amount of sale
select
	sum(total) as total_sale
from "Walmart"

-- Show the total number of item sold
select
	sum(quantity) as total_item_sold
from "Walmart"

-- Few questions and answers

-- 1) What are the different payment methods, and how many transactions and items were sold with each method
select
	payment_method,
	count(invoice_id) as transactions,
	sum(quantity) as item_sold
from "Walmart"
group by payment_method
order by payment_method 

-- 2) Which category received the highest average rating in each branch
select branch, category
from
	(
	select 
	branch,
	category,
	avg(rating) as avg_rating,
	rank() over(partition by branch order by avg(rating)desc) as rank
	from "Walmart"
	group by branch, category
	)
where rank = 1

-- 3) What is the busiest day of the week for each branch based on transaction volume
select branch, Day, orders
from
	(
	select
	branch,
	to_char(to_date(date, 'DD/MM/YY'), 'Day') as day,
	count(invoice_id) as orders,
	rank() over(partition by branch order by count(invoice_id) desc) as rank
	from "Walmart"
	group by 1,2
	order by 1
	)
where rank = 1

-- 4) What are the average, minimum, and maximum ratings for each category in each city

select 
	city,
	category,
	min(rating) as min_rating,
	max(rating) as max_rating,
	avg(rating) as avg_rating
from "Walmart"
group by 1,2
order by 1

-- 5) What is the total revenue and profit for each category, ranked from highest to lowest
select
	category,
	sum(total) as revenue,
	sum(total*profit_margin) as profit
from "Walmart"
group by category
order by profit desc

-- 6) What is the most frequently used payment method in each branch
select branch, payment_method
from
	(
	select 
	branch, 
	payment_method,
	count(payment_method) as pay_count,
	rank() over(partition by branch order by(payment_method) desc) as rank
	from "Walmart"
	group by branch, payment_method
	order by branch
	)
where rank = 1

-- 7) How many transactions occur in each shift (Morning, Afternoon, Evening) across branches
select
	branch,
	case
		when extract(hour from (time::time)) < 12 then 'Morning'
		when extract(hour from (time::time)) between 12 and 17 then 'Day'
		else 'Night'
	end shift,
	count(invoice_id) as transactions
from "Walmart"
group by branch, shift
order by branch, transactions

-- 8) Which year's data is available in this table
select
	distinct(extract(year from to_date(date,'DD/MM/YY'))) as years
from "Walmart"
order by 1

-- 9) what is the total transactions and revenue per year
select
	distinct(extract(year from to_date(date,'DD/MM/YY'))) as years,
	count(invoice_id) as transactions,
	sum(total) as revenue
from "Walmart"
group by 1
order by 1

-- 10) What are the last two years revenues and growth ratio in revenue of current year compared to the previous year
with 
revenue_2022
as
(
	select
			branch,
			sum(total) as pre_rev
		from "Walmart"
		where extract(year from to_date(date,'DD/MM/YY')) = 2022
		group by branch
),

revenue_2023
as
(
	select
			branch,
			sum(total) as cur_rev
		from "Walmart"
		where extract(year from to_date(date,'DD/MM/YY')) = 2023
		group by branch
)

select
rev_p.branch,
pre_rev,
cur_rev,
round(((cur_rev - pre_rev)::numeric/pre_rev::numeric) * 100, 2) as rev_growth_ratio
from
revenue_2022 as rev_p
join
revenue_2023 as rev_c
on rev_p.branch = rev_c.branch

-- 11) Which branches generated better revenue in current year than last year and what is the revenue difference
with 
revenue_2022
as
(
	select
			branch,
			sum(total) as pre_rev
		from "Walmart"
		where extract(year from to_date(date,'DD/MM/YY')) = 2022
		group by branch
),

revenue_2023
as
(
	select
			branch,
			sum(total) as cur_rev
		from "Walmart"
		where extract(year from to_date(date,'DD/MM/YY')) = 2023
		group by branch
)

select
rev_p.branch,
pre_rev,
cur_rev,
(cur_rev - pre_rev) as rev_diff
from
revenue_2022 as rev_p
join
revenue_2023 as rev_c
on rev_p.branch = rev_c.branch
where cur_rev > pre_rev