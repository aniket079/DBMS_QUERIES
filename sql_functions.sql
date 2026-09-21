CREATE DATABASE IF NOT EXISTS company_db;
USE company_db;
DROP TABLE IF EXISTS class_employees;
CREATE TABLE class_employees (
    emp_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    salary DECIMAL(10,2),
    hire_date DATE,
    birth_date DATE
);

INSERT INTO class_employees (first_name, last_name, salary, hire_date, birth_date) VALUES
('  Alice ', 'Johnson', 75000.55, '2020-05-10', '1990-12-15'),
('Bob', '  Smith ', 48000.00, '2021-03-15', '1985-06-22'),
('charlie', 'brown', 62000.40, '2022-07-20', '1995-02-05'),
('Diana', 'Lee', 95000.99, '2018-11-01', '1988-09-30'),
(' Ethan', 'Miller  ', 54000.12, '2023-01-12', '1992-04-18');

Select * from class_employees;

Select first_name , last_name , 
concat(first_name,'--',last_name)
AS Full_Name 
from class_employees;

Select last_name, 
LCASE(last_name) as lower_part,
UCASE(last_name) as upper_part
from class_employees;

Select first_name as raw_name,
trim(first_name) as Trim_data
from class_employees;


Select first_name as raw_name,
length(first_name) as raw_length,
length(trim(first_name)) as trim_length
from class_employees;

Select first_name,
substring(trim(first_name),1,3) as F3,
substring(trim(first_name),-3,3) as L3
from class_employees;




Select salary as raw_salary,
round(salary,1) as round_up_1,
round(salary,2) as round_up_2
from class_employees;

Select salary as raw_salary,
truncate(salary,1) as truncate_up_1,
truncate(salary,2) as truncate_up_2
from class_employees;


Select emp_id ,first_name,
MOD(emp_id,2) as remainder,
if(mod(emp_id,2)=0,'even','odd') as Id_type
from class_employees;

Select curdate() as today_date;
Select now() as today_date_time;
select sysdate() as todays_sys_date,
now() as today_date_time;














