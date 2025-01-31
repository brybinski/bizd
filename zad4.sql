-- Zad1.1
create or replace function get_job_title (
   p_job_id jobs.job_id%type
) return varchar2 is
   v_job_title jobs.job_title%type;
begin
   select job_title
     into v_job_title
     from jobs
    where job_id = p_job_id;

   return v_job_title;
exception
   when others then
      dbms_output.put_line('An error occurred: ' || sqlerrm);
end get_job_title;
/

select get_job_title('SA_MAN')
  from dual;
/

-- Zad1.2
create or replace function get_annual_salary (
   p_employee_id employees.employee_id%type
) return number is
   v_salary         employees.salary%type;
   v_commission_pct employees.commission_pct%type;
   v_annual_salary  number;
begin
   select salary,
          commission_pct
     into
      v_salary,
      v_commission_pct
     from employees
    where employee_id = p_employee_id;

   v_annual_salary := v_salary * 12;
   if v_commission_pct is not null then
      v_annual_salary := v_annual_salary + ( v_salary * v_commission_pct * 12 );
   end if;

   return v_annual_salary;
exception
   when others then
      dbms_output.put_line('An error occurred: ' || sqlerrm);
end get_annual_salary;
/

select get_annual_salary(145)
  from dual;
/


-- Zad1.3
create or replace function format_phone_number (
   p_phone_number varchar2
) return varchar2 is
   v_country_code varchar2(5);
   v_rest_number  varchar2(30);
begin
   if p_phone_number is null then
      return null;
   end if;
   if regexp_like(
      p_phone_number,
      '^\+\d+'
   ) then
      v_country_code := regexp_substr(
         p_phone_number,
         '^\+(\d+)',
         1,
         1,
         null,
         1
      );
      v_rest_number := regexp_substr(
         p_phone_number,
         '[ .,](.+)$',
         1,
         1,
         null,
         1
      );
      return '(+'
             || v_country_code
             || ') '
             || v_rest_number;
   else
      return p_phone_number;
   end if;

exception
   when others then
      dbms_output.put_line('Error formatting phone number: ' || sqlerrm);
end format_phone_number;
/

select format_phone_number('+48 515.123.4567')
  from dual;
select format_phone_number('+48.515.123.4567')
  from dual;
select format_phone_number('+48,515.123.4567')
  from dual;
select format_phone_number('515.123.4567')
  from dual;

-- Zad1.4
create or replace function format_case (
   p_string varchar2
) return varchar2 is
   v_result varchar2(4000);
begin
   if p_string is null then
      return null;
   end if;
   if length(p_string) = 1 then
      return upper(p_string);
   end if;
   v_result := upper(substr(
      p_string,
      1,
      1
   ))
               || lower(substr(
      p_string,
      2,
      length(p_string) - 2
   ))
               || upper(substr(
      p_string,
      -1
   ));

   return v_result;
exception
   when others then
      dbms_output.put_line('Error formatting string: ' || sqlerrm);
end format_case;
/

select format_case('HELLO')
  from dual;
select format_case('world')
  from dual;
select format_case('a')
  from dual;
select format_case('ab')
  from dual;
select format_case(null)
  from dual;

-- Zad1.5
create or replace function pesel_to_date (
   p_pesel varchar2
) return varchar2 is
   v_year    varchar2(4);
   v_month   number;
   v_day     varchar2(2);
   v_century number;
begin
   if p_pesel is null
   or length(p_pesel) != 11 then
      dbms_output.put_line('Invalid PESEL format');
   end if;

   v_month := to_number ( substr(
      p_pesel,
      3,
      2
   ) );
   v_day := substr(
      p_pesel,
      5,
      2
   );
   if v_month between 1 and 12 then
      v_century := 1900;
   elsif v_month between 21 and 32 then
      v_century := 2000;
      v_month := v_month - 20;
   elsif v_month between 41 and 52 then
      v_century := 2100;
      v_month := v_month - 40;
   elsif v_month between 61 and 72 then
      v_century := 2200;
      v_month := v_month - 60;
   elsif v_month between 81 and 92 then
      v_century := 1800;
      v_month := v_month - 80;
   end if;

   v_year := v_century + to_number ( substr(
      p_pesel,
      1,
      2
   ) );
   return v_year
          || '-'
          || lpad(
      v_month,
      2,
      '0'
   )
          || '-'
          || v_day;

exception
   when others then
      dbms_output.put_line('Error processing PESEL: ' || sqlerrm);
end pesel_to_date;
/

select pesel_to_date('02271409862')
  from dual;
select pesel_to_date('90090515836')
  from dual;
select pesel_to_date('00241400321')
  from dual; 

-- Zad1.6
create or replace function get_country_stats (
   p_country_name countries.country_name%type
) return varchar2 is
   v_emp_count      number;
   v_dept_count     number;
   v_country_exists number;
begin
   select count(*)
     into v_country_exists
     from countries
    where country_name = p_country_name;

   if v_country_exists = 0 then
      dbms_output.put_line('Country '
                           || p_country_name
                           || ' does not exist');
   end if;

   select count(distinct e.employee_id),
          count(distinct d.department_id)
     into
      v_emp_count,
      v_dept_count
     from employees e
    right join departments d
   on e.department_id = d.department_id
     join locations l
   on d.location_id = l.location_id
     join countries c
   on l.country_id = c.country_id
    where c.country_name = p_country_name;

   return 'Employees: '
          || v_emp_count
          || ', Departments: '
          || v_dept_count;
exception
   when others then
      dbms_output.put_line('Error processing country stats: ' || sqlerrm);
end get_country_stats;
/

select get_country_stats('United States of America')
  from dual;
select get_country_stats('NonExistent')
  from dual;
/

-- Zad2.1
create table department_archive (
   department_id   number,
   department_name varchar2(30),
   close_date      date,
   last_manager    varchar2(100)
);

create or replace trigger trg_department_archive before
   delete on departments
   for each row
declare
   v_manager_name varchar2(100);
begin
   begin
      select first_name
             || ' '
             || last_name
        into v_manager_name
        from employees
       where employee_id = :old.manager_id;
   exception
      when no_data_found then
         v_manager_name := null;
   end;

   insert into department_archive (
      department_id,
      department_name,
      close_date,
      last_manager
   ) values ( :old.department_id,
              :old.department_name,
              sysdate,
              v_manager_name );
end;
/

-- UPDATE employees SET department_id = NULL WHERE department_id = 110;
-- DELETE FROM job_history WHERE department_id = 110;
-- DELETE FROM departments WHERE department_id = 110;
-- SELECT * FROM department_archive;

-- Zad2.2

create table thieves (
   violation_id     number
      generated always as identity,
   username         varchar2(30),
   attempt_date     timestamp,
   employee_id      number,
   attempted_salary number
);

create or replace trigger trg_validate_salary before
   insert or update of salary on employees
   for each row
begin
   if :new.salary < 2000
   or :new.salary > 26000 then
      insert into thieves (
         username,
         attempt_date,
         employee_id,
         attempted_salary
      ) values ( user,
                 systimestamp,
                 :new.employee_id,
                 :new.salary );

      dbms_output.put_line('Salary must be between 2000 and 26000. You are going to jail :D.');
   end if;
end;
/

insert into employees (
   employee_id,
   first_name,
   last_name,
   salary
) values ( 999,
           'Test',
           'User',
           30000 );

update employees
   set
   salary = 100000
 where employee_id = 100;
select *
  from thieves;

-- Zad2.3
-- sekwencja stworzona w labie 3
create or replace trigger trg_emp_id_autoincrement before
   insert on employees
   for each row
begin
   if :new.employee_id is null then
      :new.employee_id := emp_id_seq.nextval;
   end if;
end;
/

-- INSERT INTO employees (first_name, last_name, email, hire_date, job_id) 
-- VALUES ('Test', 'User', 'test@email.com', SYSDATE, 'IT_PROG');
-- SELECT * FROM employees WHERE first_name = 'Test';

-- Zad2.4
create or replace trigger trg_protect_job_grades before
   insert or update or delete on job_grades
begin
   raise_application_error(
      -20008,
      'Operations on JOB_GRADES table are not allowed'
   );
end;
/
insert into job_grades values ( 'X',
                                1000,
                                2000 );
update job_grades
   set
   min_salary = 2000
 where min_salary = 3000;
delete from job_grades
 where min_salary = 3000;

-- Zad3.1
-- Przykład bo i tak tu usuwam wszystko
-- CREATE OR REPLACE PACKAGE BODY emp_pkg IS
--     FUNCTION get_job_title(p_job_id jobs.job_id%TYPE)
--     RETURN VARCHAR2;
--     BEGIN 
--         -- kod funkcji
--     END get_job_title;
-- END emp_pkg;