/*This time, we are going to take a look at customer churn.

Customers will stop using our services at some point. There can be many reasons for this: they may want to go to our competitors, or they may simply no longer need our services. 
This phenomenon is called "customer churn." On the other hand, "customer retention" is when we have succeeded in keeping a customer active during a given period.

Its not always easy to determine if a given customer has churned.
After all, customers dont usually explicitly tell us when they leave, especially in businesses like e-stores. 
Instead, we need to identify such customers ourselves and define our own churn criteria. Depending on the business type, you may want to use the last login date, the last purchase date, the last subscription renewal event, etc. Each business will approach customer churn differently.

When you apply SQL patterns covered in this part to your own business, you should adapt the "churn" criteria in the SQL queries to match the ones used in your business.

In this part, you will learn how to compute the number of churned customers and how to prepare a customer retention chart. 
The customer retention chart might look like this:
year	week	after_30_days	after_60_days	after_90_days
2018	45	58.33	50 	33.33
2018	46	71.43	57.14	42.86
2018	47	83.33	66.67	66.67

For each weekly registration cohort, the chart shows the percentage of customers still active 30, 60, and 90 days after the registration date. 
Customer retention figures will inevitably decrease over time. Comparing these values can help us determine if our customers are leaving us too quickly.
*/

/*
Out of customers registered in 2017, find the number of churned customers. 
Define a churned customer as one who hasn't placed an order in more than 60 days. 
Show the count in a column named churned_customers.

Does this number seem large?
*/
SELECT COUNT(*) AS churned_customers
FROM customers
WHERE CURRENT_DATE - last_order_date > INTERVAL '60' day
  AND registration_date >= '2017-01-01'
  AND registration_date <  '2018-01-01';

/*

Churned customers in weekly cohorts

Perfect! We know how to count the total number of churned customers. Next, let's see how we can split that count into weekly registration cohorts. Take a look:

SELECT
  DATE_TRUNC('week', registration_date) AS week,
  COUNT(*) As churned_customers
FROM customers
WHERE CURRENT_DATE - last_order_date > INTERVAL '30' day
GROUP BY DATE_TRUNC('week', registration_date)
ORDER BY DATE_TRUNC('week', registration_date);

As usual, we used the DATE_TRUNC() function to extract the week and year of users' registrations. This information is used in the GROUP BY clause to group customers into weekly signup cohorts.
Exercise

Find the number of churned customers in monthly registration cohorts from 2017. In this exercise, churned customers are those who haven't placed an order in more than 45 days. Show the following columns: month and churned_customers. Order the results by month.
*/

SELECT
  DATE_TRUNC('month', registration_date) AS month,
  COUNT(*) AS churned_customers
FROM customers
WHERE CURRENT_DATE - last_order_date > INTERVAL '45' day
  AND registration_date >= '2017-01-01'
  AND registration_date <  '2018-01-01'
GROUP BY DATE_TRUNC('month', registration_date)
ORDER BY DATE_TRUNC('month', registration_date);


/*
Find the number of churned customers in weekly signup cohorts from 2017. 
In this exercise, churned customers are those who haven't placed an order in 30 days. 
Show the following columns: week and churned_customers. Order the results by week.
*/

SELECT
  DATE_TRUNC('week', registration_date) AS week,
  COUNT(*) AS churned_customers
FROM customers
WHERE CURRENT_DATE - last_order_date > INTERVAL '30' day
  AND registration_date >= '2017-01-01'
  AND registration_date < '2018-01-01'
GROUP BY DATE_TRUNC('week', registration_date)
ORDER BY DATE_TRUNC('week', registration_date);

/*
Percentage of churned customers in weekly cohorts

Good job! We already know how many churned customers there are in each registration cohort. 
However, we would like to compare the number of churned customers to the total number of customers in a given registration cohort. 
How can we do that?

As you can see, we used COUNT(customer_id) to count all the customers in a given cohort. 
Then we used COUNT(CASE WHEN ...) to include only customers that placed an order no later than 30 days ago.

Next, we calculated the percentage of churned customers in the cohort by dividing the number of churned customers by the number of all customers. 
Note that we multiplied the numerator by 100.0 (of type numeric) and not 100 (of type integer) to avoid integer division.
Exercise

Modify the template so that it shows the following columns: month, all_customers, churned_customers, and churned_percentage. 
Find the number of churned customers in monthly signup cohorts from 2017. 
In this exercise, churned customers are those who haven't placed an order in 45 days.

Previously, we only saw churned customer counts with no reference to total customer counts. 
Now we can clearly see the relation between these figures. 
What do you think about the churn values? Are they high?
*/


SELECT
  DATE_TRUNC('week', registration_date) AS week,
  COUNT(customer_id) AS all_customers,
  COUNT(CASE WHEN CURRENT_DATE - last_order_date > INTERVAL '30' day THEN customer_id END) AS churned_customers,
  COUNT(CASE WHEN CURRENT_DATE - last_order_date > INTERVAL '30' day THEN customer_id END) * 100.0 / COUNT(customer_id) AS churned_percentage
FROM customers
GROUP BY DATE_TRUNC('week', registration_date)
ORDER BY DATE_TRUNC('week', registration_date);

/*
Percentage of churned customers in weekly cohorts 
Find the percentage of churned customers in monthly signup cohorts. 
Show the following columns: month, all_customers, churned_customers, and churned_percentage. 
Define churned customers as those who have not ordered anything in the last 60 days. 
Sort the results by year and month.
*/

SELECT
  DATE_TRUNC('month', registration_date) AS month,
  COUNT(customer_id) AS all_customers,
  COUNT(CASE WHEN CURRENT_DATE - last_order_date > INTERVAL '60' day THEN customer_id END) AS churned_customers,
  COUNT(CASE WHEN CURRENT_DATE - last_order_date > INTERVAL '60' day THEN customer_id END) * 100.0 / COUNT(customer_id) AS churned_percentage
FROM customers
GROUP BY DATE_TRUNC('month', registration_date)
ORDER BY DATE_TRUNC('month', registration_date);

/*
The customer retention chart

Perfect! The last report we'll create will be a customer retention chart. 
For each weekly registration cohort, we want to see the percentage of customers still active 30, 60, and 90 days after the registration date. 

Take a look:

Result:
week	percent_active_30d	percent_active_60d	percent_active_90d
2017-01-09 00:00:00	83.3333333333333333	83.3333333333333333	83.3333333333333333
2017-01-16 00:00:00	60.0000000000000000	60.0000000000000000	60.0000000000000000
2017-01-23 00:00:00	66.6666666666666667	66.6666666666666667	66.6666666666666667

By looking at a single row, we can analyze a given signup cohort and see what percentage of customers were still active after one, two, or three months. 
Customer retention figures will inevitably decrease over time. 
Comparing these values can help us determine if our customers are leaving us too quickly.

As you can see, we used the COUNT(CASE WHEN ...) construction three times, each time with a slightly different condition. 
Because of that, we can include multiple metrics in a single query. 
Other than this, the query used all the standard features we've already gotten to know.


Create a similar customer retention chart for weekly signup cohorts from 2017. Show the following columns: week, percent_active_10d, percent_active_30d, and percent_active_60d. 
Order the results by week.

*/

SELECT
  DATE_TRUNC('week', registration_date) AS week,
  COUNT(CASE
    WHEN last_order_date - registration_date > INTERVAL '30' day
    THEN customer_id
  END) * 100.0 / COUNT(customer_id) AS percent_active_30d,
  COUNT(CASE
    WHEN last_order_date - registration_date > INTERVAL '60' day
    THEN customer_id
  END) * 100.0 / COUNT(customer_id) AS percent_active_60d,
  COUNT(CASE
    WHEN last_order_date - registration_date > INTERVAL '90' day
    THEN customer_id
  END) * 100.0 / COUNT(customer_id) AS percent_active_90d
FROM customers
GROUP BY DATE_TRUNC('week', registration_date)
ORDER BY DATE_TRUNC('week', registration_date);

/* Customer retention chart 

Create a customer retention chart based on monthly signup cohorts for all years. It should have the following columns:
    month
    percent_active_14d (the percentage of customers still active after 14 days).
    percent_active_30d (the percentage of customers still active after 30 days).
*/

SELECT
  DATE_TRUNC('month', registration_date) AS month,
  COUNT(CASE WHEN last_order_date - registration_date > INTERVAL '14' day THEN customer_id END) * 100.0 / COUNT(customer_id) AS percent_active_14d,
  COUNT(CASE WHEN last_order_date - registration_date > INTERVAL '30' day THEN customer_id END) * 100.0 / COUNT(customer_id) AS percent_active_30d
  FROM customers
GROUP BY DATE_TRUNC('month', registration_date)
ORDER BY DATE_TRUNC('month', registration_date);


/*3. Churned Customers in Monthly Cohorts
Objective: Similar to the previous query but using monthly cohorts. This provides a broader view of churn over time.*/

SELECT COUNT(*)
FROM customers
WHERE CURRENT_DATE - last_order_date > INTERVAL '30' day;

/*4. Percentage of Churned Customers in Weekly Cohorts
Objective: Calculate the percentage of churned customers relative to the total number of customers in each weekly cohort.*/

SELECT
    DATE_TRUNC('week', registration_date) AS week,
    COUNT(*) AS churned_customers
FROM customers
WHERE CURRENT_DATE - last_order_date > INTERVAL '30' day
GROUP BY DATE_TRUNC('week', registration_date)
ORDER BY DATE_TRUNC('week', registration_date);

/*5. Customer Retention Chart for Weekly Cohorts
Objective: Create a retention chart showing the percentage of customers still active after 30, 60, and 90 days for weekly cohorts.*/

SELECT
    DATE_TRUNC('week', registration_date) AS week,
    COUNT(CASE
    WHEN CURRENT_DATE - last_order_date > INTERVAL '30' day
    THEN customer_id
    END) * 100.0 / COUNT(customer_id) AS churned_percentage
FROM customers
GROUP BY DATE_TRUNC('week', registration_date)
ORDER BY DATE_TRUNC('week', registration_date);

/*6. Customer Retention Chart for Monthly Cohorts
Objective: Create a similar retention chart but for monthly cohorts and a shorter time period (14 and 30 days).
*/
SELECT
    DATE_TRUNC('week', registration_date) AS week,
    COUNT(CASE
    WHEN last_order_date - registration_date > INTERVAL '30' day
    THEN customer_id
    END) * 100.0 / COUNT(customer_id) AS percent_active_30d,
    COUNT(CASE
    WHEN last_order_date - registration_date > INTERVAL '60' day
    THEN customer_id
    END) * 100.0 / COUNT(customer_id) AS percent_active_60d,
    COUNT(CASE
    WHEN last_order_date - registration_date > INTERVAL '90' day
    THEN customer_id
    END) * 100.0 / COUNT(customer_id) AS percent_active_90d
FROM customers
GROUP BY DATE_TRUNC('week', registration_date)
ORDER BY DATE_TRUNC('week', registration_date);

