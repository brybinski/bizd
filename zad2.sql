--DROP TABLE EMPLOYEES CASCADE CONSTRAINTS;
--DROP TABLE JOBS CASCADE CONSTRAINTS;
--DROP TABLE DEPARTMENTS CASCADE CONSTRAINTS;
--DROP TABLE LOCATIONS CASCADE CONSTRAINTS;
--DROP TABLE COUNTRIES CASCADE CONSTRAINTS;
--DROP TABLE REGIONS CASCADE CONSTRAINTS;
--COPY DATA
create table regions
   as
      select *
        from hr.regions;
create table countries
   as
      select *
        from hr.countries;
create table locations
   as
      select *
        from hr.locations;
create table departments
   as
      select *
        from hr.departments;
create table jobs
   as
      select *
        from hr.jobs;
create table employees
   as
      select *
        from hr.employees;
create table job_history
   as
      select *
        from hr.job_history;
create table job_grades
   as
      select *
        from hr.job_grades;
create table products
   as
      select *
        from hr.products;
create table sales
   as
      select *
        from hr.sales;
--PK
alter table regions add constraint regions_id_pk primary key ( region_id );
alter table countries add constraint countries_id_pk primary key ( country_id );
alter table locations add constraint locations_id_pk primary key ( location_id );
alter table departments add constraint departments_id_pk primary key ( department_id );
alter table jobs add constraint jobs_id_pk primary key ( job_id );
alter table employees add constraint employees_id_pk primary key ( employee_id );
alter table job_history add constraint job_history_id_date_pk primary key ( employee_id,
                                                                            start_date );
alter table job_grades add constraint job_grades_id_pk primary key ( grade );
alter table products add constraint products_id_pk primary key ( product_id );
alter table sales add constraint sales_id_pk primary key ( sale_id );
--ADD FK
alter table countries
   add constraint fk_region foreign key ( region_id )
      references regions ( region_id );
alter table departments
   add constraint fk_dept_manager foreign key ( manager_id )
      references employees ( employee_id );
alter table departments
   add constraint fk_location foreign key ( location_id )
      references locations ( location_id );
alter table employees
   add constraint fk_department foreign key ( department_id )
      references departments ( department_id );
alter table employees
   add constraint fk_job foreign key ( job_id )
      references jobs ( job_id );
alter table employees
   add constraint fk_manager foreign key ( manager_id )
      references employees ( employee_id );
alter table job_history
   add constraint fk_job_history_employee foreign key ( employee_id )
      references employees ( employee_id );
alter table job_history
   add constraint fk_job_history_department foreign key ( department_id )
      references departments ( department_id );
alter table job_history
   add constraint fk_job_history_job foreign key ( job_id )
      references jobs ( job_id );

alter table locations
   add constraint fk_country foreign key ( country_id )
      references countries ( country_id );

alter table sales
   add constraint fk_employee_sales foreign key ( employee_id )
      references employees ( employee_id );

--A to już nie potrzebne było xD
alter table sales
   add constraint fk_product_sales foreign key ( product_id )
      references products ( product_id );

select concat(
   concat(
      last_name,
      ' '
   ),
   salary
) as wynagrodzenie
  from employees
 where department_id in ( 20,
                          50 )
   and salary between 2000 and 7000
 order by last_name;

select hire_date,
       last_name,
       salary
  from employees
 where manager_id is not null
   and extract(year from hire_date) = 2005
 order by salary;

select concat(
   concat(
      first_name,
      ' '
   ),
   last_name
) as full_name,
       salary,
       phone_number
  from employees
 where substr(
   last_name,
   3,
   1
) = 'e'
--  AND first_name LIKE 'John'
 order by 1 desc,
          2 asc;

--zmieniłem liczby bo nie było prawie nikogo poniżej 200
select first_name,
       last_name,
       round(months_between(
          current_date,
          hire_date
       )) as months_worked,
       salary,
       case
          when round(months_between(
             current_date,
             hire_date
          )) < 200               then
             salary * 0.10
          when round(months_between(
             current_date,
             hire_date
          )) between 200 and 250 then
             salary * 0.20
          else
             salary * 0.30
       end as wysokość_dodatku
  from employees
 order by months_worked asc;

select d.department_name,
       round(sum(e.salary)) as suma_zarobków,
       round(avg(e.salary)) as średnia_zarobków
  from employees e
  join departments d
on e.department_id = d.department_id
 group by d.department_name
having min(e.salary) > 5000;

select e.employee_id,
       e.first_name,
       e.last_name,
       d.department_name,
       l.city
  from employees e
  join departments d
  join locations l
on l.location_id = d.location_id
on d.department_id = d.department_id
 where l.city = 'Toronto';



select e1.first_name
       || ' '
       || e1.last_name as jenifer,
       e2.first_name
       || ' '
       || e2.last_name as coworker
  from employees e1
  join employees e2
on e1.department_id = e2.department_id
 where e1.first_name = 'Jennifer'
   and e1.employee_id != e2.employee_id;