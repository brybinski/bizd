create table regions (
   region_id   number primary key,
   region_name varchar2(100)
);

create table countries (
   country_id   char(2) primary key,
   country_name varchar2(100)
);
alter table countries add (
   region_id number
);
alter table countries
   add constraint fk_region foreign key ( region_id )
      references regions ( region_id );

create table locations (
   location_id    number primary key,
   postal_code    varchar2(100),
   city           varchar2(100) not null,
   state_province varchar2(100),
   country_id     char(2),
   constraint fk_country foreign key ( country_id )
      references countries ( country_id )
);

alter table locations add (
   street_address varchar2(100)
);

create table departments (
   department_id   number primary key,
   department_name varchar2(100) not null,
   manager_id      number,
   location_id     number,
   constraint fk_location foreign key ( location_id )
      references locations ( location_id )
);

create table jobs (
   job_id     varchar2(10) primary key,
   job_title  varchar2(100) not null,
   min_salary number,
   max_salary number,
   constraint chk_salary
      check ( min_salary <= max_salary
         and min_salary >= 2000 )
);

create table employees (
   employee_id   number primary key,
   first_name    varchar2(100),
   last_name     varchar2(100) not null,
   email         varchar2(254) unique not null,
   phone_number  varchar2(11),
   hire_date     date not null,
   job_id        varchar2(10),
   salary        number,
   department_id number,
   constraint fk_department foreign key ( department_id )
      references departments ( department_id ),
   constraint fk_job foreign key ( job_id )
      references jobs ( job_id )
);

alter table employees add (
   commission_pct number,
   manager_id     number
);

alter table employees
   add constraint fk_manager foreign key ( manager_id )
      references employees ( employee_id );
alter table departments
   add constraint fk_dept_manager foreign key ( manager_id )
      references employees ( employee_id );



create table job_history (
   employee_id   number,
   start_date    date not null,
   end_date      date,
   job_id        varchar2(10),
   department_id number,
   constraint pk_job_history primary key ( employee_id,
                                           start_date ),
   constraint fk_job_history_employee foreign key ( employee_id )
      references employees ( employee_id ),
   constraint fk_job_history_job foreign key ( job_id )
      references jobs ( job_id ),
   constraint fk_job_history_department foreign key ( department_id )
      references departments ( department_id )
);

select table_name
  from user_tables;

--COMMIT;
--
--DROP TABLE REGIONS CASCADE CONSTRAINTS;
--SELECT table_name FROM user_tables;
--
--ROLLBACK;
--SELECT table_name FROM user_tables;

-- Tabeli REGIONS nie da się odzyskać ponieważ to operacja DDL a nie DML + wyłączona jest funkcja FLASHBACK