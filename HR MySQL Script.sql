CREATE DATABASE project2;

use project2;

select * from hr

ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL;

select * from hr;

SET sql_safe_updates = 0

UPDATE hr
SET birthdate =
CASE
WHEN birthdate LIKE '%/%/%' THEN date_format(str_to_date(birthdate, '%d/%m/%Y'), '%Y/%m/%d')
WHEN birthdate LIKE '%-%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y/%m/%d') 
ELSE NULL
END


ALTER TABLE hr
MODIFY COLUMN birthdate DATE

UPDATE hr SET hire_date =
CASE
WHEN hire_date LIKE '%/%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
WHEN hire_date LIKE '%-%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
ELSE NULL 
END

ALTER TABLE hr
MODIFY COLUMN hire_date DATE

DESCRIBE hr

select termdate from hr

SET sql_mode = 'ALLOW_INVALID_DATES'

UPDATE hr
SET termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate != ' ';

SELECT date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC')) as fml
FROM hr
WHERE termdate IS NOT NULL

ALTER TABLE hr
MODIFY COLUMN termdate DATE

ALTER TABLE hr ADD COLUMN age1 int

UPDATE hr 
SET age1 = FLOOR(DATEDIFF(CURDATE(), birthdate)/365)

SELECT birthdate, age FROM hr

ALTER TABLE hr
ADD COLUMN age int

UPDATE hr
SET age = timestampdiff(YEAR, birthdate, CURDATE())

ALTER TABLE hr
DROP COLUMN age1

SELECT age, birthdate
FROM hr
WHERE YEAR(birthdate) > 2024

SELECT
	min(age) as youngest,
	max(age) as oldest
FROM hr

SELECT emp_id, COUNT(emp_id)
FROM hr
GROUP BY emp_id
HAVING COUNT(emp_id) > 1

-- gender analysis

SELECT gender, COUNT(*) as count
FROM hr
WHERE termdate = '0000-00-00'
GROUP BY gender

-- race/ethnicity
SELECT race, COUNT(*) as count
FROM hr
WHERE termdate = '0000-00-00'
GROUP BY race
ORDER BY count DESC

-- age groups
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
GROUP BY age_group
ORDER BY age_group

-- age distribution between genders

SELECT
CASE
	WHEN age >= '18' AND age <= '24' THEN '18-24'
    WHEN age >= '25' AND age <= '34' THEN '25-34'
    WHEN age >= '35' AND age <= '44' THEN '35-44'
    WHEN age >= '45' AND age <= '54' THEN '45-54'
    WHEN age >= '55' AND age <= '64' THEN '55-64'
    ELSE '65+'
END as age_group, gender,
COUNT(*) as count
FROM hr
WHERE termdate = '0000-00-00'
GROUP BY age_group, gender
ORDER BY age_group, gender

-- number of emp. working at headquarters versus remote locations

SELECT location, COUNT(*) as count
FROM hr
WHERE termdate = '0000-00-00'
GROUP BY location

-- avg length of employment for terminated employees

SELECT ROUND(AVG(DATEDIFF(termdate, hire_date) / 365), 1) as avg_length_employemnt
FROM hr
WHERE termdate <> '0000-00-00' AND termdate <= CURDATE()

SELECT ROUND(AVG(DATEDIFF(termdate, hire_date) / 365), 1) as avg_length_employemnt, department
FROM hr
WHERE termdate <> '0000-00-00' AND termdate <= CURDATE()
GROUP BY department
ORDER BY avg_length_employemnt DESC

-- how does gender distribution vary across departments

SELECT department, gender, COUNT(*) as count
FROM hr
WHERE termdate = '0000-00-00'
GROUP BY department, gender
ORDER BY department

-- distribution of job titles across the company

SELECT jobtitle, COUNT(*) as count
FROM hr
WHERE termdate = '0000-00-00'
GROUP BY jobtitle
ORDER BY jobtitle

-- highest turnover rate

SELECT department, total_count, terminated_count, terminated_count / total_count as termination_rate
FROM (
	SELECT department, COUNT(*) as total_count,
    SUM(CASE
		WHEN termdate <> '0000-00-00' AND termdate < CURDATE() THEN 1 ELSE 0
    END) as terminated_count
    FROM hr
    GROUP BY department
    ) as subquery
ORDER BY termination_rate DESC


WITH cte as (
	SELECT department, COUNT(*) as total_count,
    SUM(CASE
			WHEN termdate <> '0000-00-00' AND termdate < CURDATE() THEN 1 ELSE 0
		END) as terminated_count
    FROM hr
    GROUP BY department
		)

SELECT department, total_count, terminated_count, terminated_count / total_count as termination_rate
FROM cte
ORDER BY termination_rate DESC

-- distribution of employees across locations by state

SELECT location_state, COUNT(*) as count
FROM hr
WHERE termdate <> '0000-00-00'
GROUP BY location_state
ORDER BY count DESC


-- how has the company's employee count changed over time based on hire date and term date?

WHERE termdate <= CURDATE()
GROUP BY hire_date


SELECT YEAR(hire_date) as hire_year, YEAR(termdate) as term_year, COUNT(*) as count
FROM hr
WHERE termdate <= CURDATE()
AND YEAR(hire_date) = YEAR(termdate)
GROUP BY hire_year, term_year
ORDER BY hire_year

WITH cte as (
	SELECT SUM(CASE WHEN test1 > 1 THEN 1 ELSE 0 END) as hires
    FROM (SELECT COUNT(YEAR(hire_date)) as test1
		FROM hr
        GROUP BY YEAR(hire_date)) as test1
)
SELECT
hires
FROM cte

SELECT 
year,
hires,
terminations,
hires - terminations as difference,
ROUND(((hires - terminations) / hires * 100), 2) as difference_percentage
FROM (
	SELECT YEAR(hire_date) as year, COUNT(*) as hires,
    SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <= CURDATE() THEN 1 ELSE 0 END) as terminations
    FROM hr
    GROUP BY year
    ORDER BY year) as subquery

-- tenure distribution for each department

SELECT department, ROUND(AVG(DATEDIFF(termdate, hire_date) / 365), 2) as tenure_avg
FROM hr
WHERE termdate <> '0000-00-00' AND termdate <= CURDATE()
GROUP BY department
ORDER BY tenure_avg

















