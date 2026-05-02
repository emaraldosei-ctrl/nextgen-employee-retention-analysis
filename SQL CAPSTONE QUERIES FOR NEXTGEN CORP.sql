SELECT * FROM ATTENDANCE
SELECT * FROM DEPARTMENT
SELECT * FROM EMPLOYEE
SELECT * FROM PERFORMANCE
SELECT * FROM SALARY
SELECT * FROM TURNOVER

--EMPLOYEE ANALYSIS

--1 Who are the top 5 highest serving employees?
SELECT 
	employee_id,
	first_name || ' ' || last_name AS full_name,
	hire_date,
	age(CURRENT_DATE,hire_date) AS TENURE
	FROM employee 
ORDER BY employee.hire_date ASC
LIMIT 5;

--OR
select
	employee_id,
	first_name || ' ' || last_name AS full_name,
	hire_date
FROM employee
ORDER by employee.hire_date ASC
LIMIT 5;


--2 What is the turnover rate for each department?
SELECT 
	d.department_id,
	d.department_name,
	ROUND(
	COUNT(DISTINCT t.employee_id) :: numeric
	/
	COUNT(DISTINCT e.employee_id) :: numeric * 100,
	2
	) AS turnover_rate
FROM department d
LEFT JOIN employee e
	ON e.department_id = d.department_id
LEFT JOIN turnover t
	ON t.employee_id = e.employee_id
GROUP BY
	d.department_id,
	d.department_name
ORDER BY
	turnover_rate DESC;


--3 Which employees are at risk of leaving based on their performance?
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name AS fullname,
    ROUND (AVG(p.performance_score),2) AS performance_score,
    CASE 
        WHEN AVG(p.performance_score) >= 5 THEN 'Low Risk'
        WHEN AVG(p.performance_score) BETWEEN 3.5 AND 5 THEN 'Medium Risk'
        ELSE 'High Risk'
    END AS employee_status
FROM employee e
LEFT JOIN performance p
ON p.employee_id = e.employee_id
GROUP BY e.employee_id, fullname
ORDER BY performance_score ASC;


--4 What are the main reasons employees are leaving the company?
SELECT COUNT(employee_id) AS total_employee, reason_for_leaving
FROM turnover
GROUP BY reason_for_leaving
order by total_employee DESC;

-- PERFORMANCE ANALYSIS

-- Q1 How many employees has left the company?
SELECT COUNT(DISTINCT employee_id) AS total_employee_left
FROM turnover;

-- Q2 How many employees have a performance score of 5.0 / below 3.5?
SELECT 
    'score_5_0' AS category, 
    COUNT(DISTINCT employee_id) AS employee_count
FROM 
    Performance
WHERE 
    performance_score = 5.0

UNION ALL

SELECT 
    'score_below_3_5' AS category, 
    COUNT(DISTINCT employee_id) AS employee_count
FROM 
    Performance
WHERE 
    performance_score < 3.5;


-- Q3 Which department has the most employees with a performance of 5.0 / below 3.5?
SELECT
    d.department_name,
    CASE
        WHEN p.performance_score = 5.0 THEN 'score_5_0'
        WHEN p.performance_score < 3.5 THEN 'score_below_3_5'
    END AS category,
    COUNT(DISTINCT p.employee_id) AS employee_count
FROM performance p
JOIN department d
    ON p.department_id = d.department_id
WHERE p.performance_score = 5.0
   OR p.performance_score < 3.5
GROUP BY d.department_name, category
ORDER BY employee_count DESC;


--Q4 What is the average performance score by department?
SELECT 
    d.department_id,d.department_name,
    ROUND(AVG(p.performance_score), 2) AS avg_performance_score
FROM performance p
JOIN department d
    ON p.department_id = d.department_id
GROUP BY d.department_id,d.department_name
ORDER BY avg_performance_score DESC;

--SALARY ANALYSIS
-- Q1 What is the total salary expense for the company?
SELECT 
 '£'||  to_char(SUM(salary_amount),'FM99,999,999.00') as total_salary_expense
FROM salary;


--Q2 What is the average salary by job title? 
SELECT 
	e.job_title,
	'£' || to_char(AVG(s.salary_amount),'FM99,999,999.00') AS avg_salary
FROM salary s
JOIN employee e
ON e.employee_id = s.employee_id
GROUP BY e.job_title
ORDER BY avg_salary DESC;


--Q3 How many employees earn above 80,000?
SELECT COUNT(employee_id) AS total_employees_above_80000
FROM salary
WHERE salary_amount > 80000;


--Q4 How does performance correlate with salary across departments?
SELECT 
    d.department_name,
    ROUND(CORR(s.salary_amount, p.performance_score)::numeric, 2) AS salary_perf_corr
FROM salary s
JOIN performance p
    ON s.employee_id = p.employee_id
JOIN department d
    ON p.department_id = d.department_id
GROUP BY d.department_name
ORDER BY salary_perf_corr DESC;







