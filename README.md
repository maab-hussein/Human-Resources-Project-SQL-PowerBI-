# Human Resources Analysis "SQL / PowerBI"

## Project Overview

This project involves general comprehensive analysis of human resources metrics, utilizing SQL to clean and prepare data, followed by the use of PowerBI to create visualizations that provide deep insights into HR trends and performance indicators.

## Data Cleaning and Preparation Using SQL

To begin with, I downloaded data by left-clicking `Tables > Table Data Import Wizard > Browse`, and choosing the Excel file. The table was named `hr`. I started off with a simple `SELECT * FROM hr` and `DESCRIBE hr` to take a general look at the data.

### Commands Used for the Cleaning Process

- Command
```
ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL
```
To change the first column's name and data type.

- Command
```
UPDATE hr
SET birthdate =
  CASE
    WHEN birthdate LIKE '%/%/%' THEN date_format(str_to_date(birthdate, '%d/%m/%Y'), '%Y-%m-%d')
    WHEN birthdate LIKE '%-%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d') 
    ELSE NULL
  END
```
To change and unify date formats for `hire_date` column to `yyyy-mm-dd` since there were different formats. Then `ALTER TABLE hr MODIFY COLUMN hire_date DATE` to change the date type from a text to a date.

- Command
```
UPDATE hr
SET termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate != ' '
```
Extracts the date from the datetime expression format for `termdate` column. Then `ALTER TABLE hr MODIFY COLUMN termdate DATE` to change data type to date.

- Now I want to calculate the age. First, I will add a column for age, then calculate it
1. Adding the table:
```
ALTER TABLE hr
ADD COLUMN age int
```
2. Calculating age:
```
UPDATE hr
SET age = timestampdiff(YEAR, birthdate, CURDATE())
```
or

```
UPDATE hr
SET age = FLOOR(DATEDIFF(CURDATE(), birthdate) / 365)
```
- Command
```
SELECT age, birthdate
FROM hr
WHERE YEAR(birthdate) > 2024
```
to check for unreasonable data, and
```
SELECT
	min(age) as youngest,
	max(age) as oldest
FROM hr
```
for further checking.

- Checking for duplicates using
```
SELECT emp_id, COUNT(emp_id)
FROM hr
GROUP BY emp_id
HAVING COUNT(emp_id) > 1
```


### Commands Used for Analyzing

1- What is the gender breakdown in the company?
```
SELECT gender, COUNT(*)
FROM hr
WHERE termdate = '0000-00-00'
GROUP BY gender
```

Because MySQL considers `0000-00-00` as an incorrect date value, we use the code `SET sql_mode = 'ALLOW_INVALID_DATES'` to allow these values.

![gender](https://github.com/user-attachments/assets/501bd91c-26b5-45cc-a14e-ce22f20e5b2a)

2- What is the race/ethnicity breakdown in the company?
```
SELECT race, COUNT(*) as count
FROM hr
WHERE termdate = '0000-00-00'
GROUP BY race
ORDER BY count DESC
```

![race](https://github.com/user-attachments/assets/1579eaeb-1b3e-47df-988f-4c47a373169d)

3- What is the age distribution of employees in the company?

**Generally**
```
SELECT
  CASE
    WHEN age >= '18' AND age <= '24' THEN '18-24'
    WHEN age >= '25' AND age <= '34' THEN '25-34'
    WHEN age >= '35' AND age <= '44' THEN '35-44'
    WHEN age >= '45' AND age <= '54' THEN '45-54'
    WHEN age >= '55' AND age <= '64' THEN '55-64'
    ELSE '65+'
  END as age_group,
  COUNT(*) as count
FROM hr
WHERE termdate = '0000-00-00'
ORDER BY age_group DESC
```

![age_group](https://github.com/user-attachments/assets/50f52ab3-805b-42a4-92c5-3410c498d0a3)

**Between Genders**
```
SELECT
  CASE
    WHEN age >= '18' AND age <= '24' THEN '18-24'
    WHEN age >= '25' AND age <= '34' THEN '25-34'
    WHEN age >= '35' AND age <= '44' THEN '35-44'
    WHEN age >= '45' AND age <= '54' THEN '45-54'
    WHEN age >= '55' AND age <= '64' THEN '55-64'
    ELSE '65+'
  END as age_group,
  gender,
  COUNT(*) as count
FROM hr
WHERE termdate = '0000-00-00'
GROUP BY age_group, gender
ORDER BY age_group, gender
```

![age_group_gender](https://github.com/user-attachments/assets/b9ee5cf5-1774-4040-ab88-f79ee358f7f9)

4- How many employees work at headquarters versus remote locations?
```
SELECT location, COUNT(*) as count
FROM hr
WHERE termdate = '0000-00-00'
GROUP BY location
```

![location](https://github.com/user-attachments/assets/f3d1954c-f089-43c5-bd1f-5c8ea19953e7)

5- What is the average length of employment for employees who have been terminated?

```
SELECT
  ROUND(AVG(DATEDIFF(termdate, hire_date) / 365), 1) as avg
FROM hr
WHERE termdate <> '0000-00-00' AND termdate <= CURDATE()
```

![avg_length_emp](https://github.com/user-attachments/assets/b167d76f-7eee-4828-bfa1-955cf44ee454)

6- How does the gender distribution vary across departments and job titles?
```
SELECT
  gender, department, COUNT(*) as count
FROM hr
WHERE termdate <> '0000-00-00'
GROUP BY department, gender
ORDER BY department
```

![gender_department](https://github.com/user-attachments/assets/b148328a-c235-4e10-8313-50c5184fcf43)

7- What is the distribution of job titles across the company?
```
SELECT jobtitle, COUNT(*) as count
FROM hr
WHERE termdate <> '0000-00-00'
GROUP BY jobtitle
ORDER BY jobtitle
```

![job_title](https://github.com/user-attachments/assets/1ace33f0-d3ed-4877-b456-713e149cbb1e)

8- Which department has the highest turnover rate?
```
SELECT
  department,
  total_count,
  terminated_count,
  terminated_count / total_count as termination_rate
FROM (
  SELECT
    department, COUNT(*) as total_count,
    SUM(CASE
      WHEN termdate <> '0000-00-00' AND termdate < CURDATE() THEN 1 ELSE 0
      END) as terminated_count
  FROM hr
  GROUP BY department) as subquery
ORDER BY termination_rate DESC
```
An alternative
```
WITH cte as (
  SELECT
    department,
    COUNT(*) as total_count,
    SUM(CASE
      WHEN termdate <> '0000-00-00' AND termdate < CURDATE() THEN 1 ELSE 0
    END) as terminated_count
  FROM hr
  GROUP BY department
)

SELECT
  department,
  total_count,
  terminated_count,
  terminated_count / total_count as termination_rate
FROM cte
ORDER BY termination_rate DESC
```

![turnover_rate](https://github.com/user-attachments/assets/fb22b90c-591b-4356-81a6-c1d70bdee5ee)

9- What is the distribution of employees across locations by city and state?

```
SELECT location_state, COUNT(*) as count
FROM hr
WHERE termdate <> '0000-00-00'
GROUP BY location_state
ORDER BY count DESC
```

![location_state](https://github.com/user-attachments/assets/25ee9bb9-4e1b-4675-ab64-4f8502952cc1)

10- How has the company's employee count changed over time based on hire and term dates?
```
SELECT 
  year,
  hires,
  terminations,
  hires - terminations as difference,
  ROUND(((hires - terminations) / hires * 100), 2) as difference_percentage
FROM (
  SELECT
    YEAR(hire_date) as year,
    COUNT(*) as hires,
    SUM( CASE WHEN termdate <> '0000-00-00' AND termdate <= CURDATE() THEN 1 ELSE 0 END) as terminations
  FROM hr
  GROUP BY year
  ORDER BY year) as subquery
```

![emp_year](https://github.com/user-attachments/assets/f3b9aa66-93be-4a31-b6ec-5aa9723d7e73)

11- What is the tenure distribution for each department?
```
SELECT
  department,
  ROUND(AVG(DATEDIFF(termdate, hire_date) / 365), 2) as tenure_avg
FROM hr
WHERE termdate <> '0000-00-00' AND termdate <= CURDATE()
GROUP BY department
ORDER BY tenure_avg
```

![tenure_avg](https://github.com/user-attachments/assets/c844fc91-8f74-4012-86b1-c3d448d898af)

These were the general questions, and, after finishing the queries, I downloaded every resulting table as a .csv file to upload them later on PowerBI.


## Data Visualizations and Dashboard with PowerBI

Open PowerPI desktop. Since I have already uploaded each resulting table from the above queries into .csv files, upload each table to PowerBI from `Get data > Text/CSV` and then choose the desired table.

Choose the suitable chart for every table. Here are pictures of the final result.

### Snapshot of the First Page of the Dashboard

![Dashboard p1](https://github.com/user-attachments/assets/ab0dac9f-ae13-4f7f-a34c-d43aee828a83)



### Snapshot of the Second Page of the Dashboard

![Dashboard p2](https://github.com/user-attachments/assets/95b3c1aa-4ad2-4f46-b563-aa71fe9252bf)




## Summary of Findings
1. Males are slightly more than females in the company.
2. White race is the most dominant while Native Hawaiians and American Indians are the least.
3. Age groups are divided into 5 groups, 18-24, 25-34, 35-44, 45-54, 55-64, and 65+. Age groups 25-34, 35-44, and 45-54 are the most common ones with slight differences between them, and the group 35-44 as the most common. The least common age group is 18-24.
4. When it comes to age groups by members, there is roughly no significant difference in a particular age group by genders. The ratio of men and women is roughly constant.
5. 25% of employees work remotely versus headquarters of 75%.
6. Average length of employment for terminated employees throughout years is 7.9.
7. Men are dominant in every department, having the largest difference in Engineering and Accounting departments, and the least in difference in Research and Development.
8. Engineering and Accounting are the departments with the largest number of employees, while Auditing has the least number of employees.
9. Auditing is the department with the highest turnover rate, and Marketing is the department with the lowest turnover rate.
10. Ohio is the state with the vast majority number of employees by 82%, while Wisconsin is the state with the least number of employees.
11. According to the line chart, the number of employees has generally been increasing continuously throughout years.
12. Average tenure for departments is 7.9, having Sales and Marketing departments with the highest, and Legal and Product Management with the least.







































