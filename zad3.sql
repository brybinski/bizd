-- -- Zad1
declare
   numer_max number;
   nazwa_dep departments.department_name%type := 'EDUCATION';
begin
   select max(department_id)
     into numer_max
     from departments;

   dbms_output.put_line('Maksymalny numer departamentu: ' || numer_max);
   insert into departments (
      department_id,
      department_name
   ) values ( numer_max + 10,
              nazwa_dep );

   commit;
end;
/

 -- Zad2
declare
   numer_max number;
   nazwa_dep departments.department_name%type := 'EDUCATION';
begin
   select max(department_id)
     into numer_max
     from departments;

   dbms_output.put_line('Maksymalny numer departamentu: ' || numer_max);
   insert into departments (
      department_id,
      department_name
   ) values ( numer_max + 10,
              nazwa_dep );

   update departments
      set
      location_id = 3000
    where department_id = numer_max + 10;

   commit;
end;
/

 -- Zad3
create table nowa (
   liczba varchar2(2)
);

declare
   i number;
begin
   for i in 1..10 loop
      if
         i != 4
         and i != 6
      then
         insert into nowa ( liczba ) values ( to_char(i) );
      end if;
   end loop;

   commit;
end;
/

 -- Zad4
declare
   kraj_record countries%rowtype;
begin
   select *
     into kraj_record
     from countries
    where country_id = 'CA';

   dbms_output.put_line('Nazwa kraju: ' || kraj_record.country_name);
   dbms_output.put_line('Region ID: ' || kraj_record.region_id);
end;
/

 --Zad 5
declare
   cursor emp_cur is
   select salary,
          last_name
     from employees
    where department_id = 50;

   v_salary   employees.salary%type;
   v_lastname employees.last_name%type;
begin
   open emp_cur;
   loop
      fetch emp_cur into
         v_salary,
         v_lastname;
      exit when emp_cur%notfound;
      if v_salary > 3100 then
         dbms_output.put_line(v_lastname || ' - nie dawać podwyżki');
      else
         dbms_output.put_line(v_lastname || ' - dać podwyżkę');
      end if;
   end loop;
   close emp_cur;
end;
/

 -- Zad6
declare
   cursor emp_cur (
      p_min_sal      number,
      p_max_sal      number,
      p_name_pattern varchar2
   ) is
   select salary,
          first_name,
          last_name
     from employees
    where salary between p_min_sal and p_max_sal
      and upper(first_name) like '%'
                                 || upper(p_name_pattern)
                                 || '%';

   v_salary    employees.salary%type;
   v_firstname employees.first_name%type;
   v_lastname  employees.last_name%type;
begin
   dbms_output.put_line('Pracownicy z pensją 1000-5000 i literą "a" w imieniu:');
   for emp_rec in emp_cur(
      1000,
      5000,
      'a'
   ) loop
      dbms_output.put_line(emp_rec.first_name
                           || ' '
                           || emp_rec.last_name
                           || ': '
                           || emp_rec.salary);
   end loop;

   dbms_output.put_line('Pracownicy z pensją 5000-20000 i literą "u" w imieniu:');
   for emp_rec in emp_cur(
      5000,
      20000,
      'u'
   ) loop
      dbms_output.put_line(emp_rec.first_name
                           || ' '
                           || emp_rec.last_name
                           || ': '
                           || emp_rec.salary);
   end loop;
end;
/

 -- Zad7 a
create or replace procedure add_job (
   p_job_id    in jobs.job_id%type,
   p_job_title in jobs.job_title%type
) is
begin
   insert into jobs (
      job_id,
      job_title
   ) values ( p_job_id,
              p_job_title );
   commit;
exception
   when others then
      dbms_output.put_line('Error: ' || sqlerrm);
      rollback;
end add_job;
/

 -- Zad7 b
create or replace procedure update_job_title (
   p_job_id    in jobs.job_id%type,
   p_new_title in jobs.job_title%type
) is
   no_job_updated exception;
   v_rows_updated number;
begin
   update jobs
      set
      job_title = p_new_title
    where job_id = p_job_id;

   v_rows_updated := sql%rowcount;
   if v_rows_updated = 0 then
      raise no_job_updated;
   end if;
   commit;
   dbms_output.put_line('Job title updated successfully');
exception
   when no_job_updated then
      dbms_output.put_line('Error: No job found with ID ' || p_job_id);
      rollback;
   when others then
      dbms_output.put_line('Error: ' || sqlerrm);
      rollback;
end update_job_title;
/

begin
   update_job_title(
      'AD_PRES',
      'Company President'
   );
   update_job_title(
      'INVALID_ID',
      'Test Title'
   );
end;
/

 -- Zad7 c
create or replace procedure delete_job (
   p_job_id in jobs.job_id%type
) is
   no_job_deleted exception;
   v_rows_deleted number;
begin
   delete from jobs
    where job_id = p_job_id;

   v_rows_deleted := sql%rowcount;
   if v_rows_deleted = 0 then
      raise no_job_deleted;
   end if;
   commit;
   dbms_output.put_line('Job deleted successfully');
exception
   when no_job_deleted then
      dbms_output.put_line('Error: No job found with ID ' || p_job_id);
      rollback;
   when others then
      dbms_output.put_line('Error: ' || sqlerrm);
      rollback;
end delete_job;
/

 -- Zad7 d
create or replace procedure get_employee_details (
   p_employee_id in employees.employee_id%type,
   p_salary      out employees.salary%type,
   p_last_name   out employees.last_name%type
) is
begin
   select salary,
          last_name
     into
      p_salary,
      p_last_name
     from employees
    where employee_id = p_employee_id;

   dbms_output.put_line('Employee details retrieved successfully');
exception
   when no_data_found then
      dbms_output.put_line('Error: No employee found with ID ' || p_employee_id);
      p_salary := null;
      p_last_name := null;
   when others then
      dbms_output.put_line('Error: ' || sqlerrm);
      p_salary := null;
      p_last_name := null;
end get_employee_details;
/

 -- Zad7 e
create sequence emp_id_seq start with 1000 increment by 1;


create or replace procedure add_employee (
   p_last_name      in employees.last_name%type,
   p_email          in employees.email%type,
   p_hire_date      in employees.hire_date%type default sysdate,
   p_job_id         in employees.job_id%type,
   p_first_name     in employees.first_name%type default null,
   p_phone_number   in employees.phone_number%type default null,
   p_salary         in employees.salary%type default 1000,
   p_commission_pct in employees.commission_pct%type default null,
   p_manager_id     in employees.manager_id%type default null,
   p_department_id  in employees.department_id%type default null
) is
   salary_too_high exception;
begin
   if p_salary > 20000 then
      raise salary_too_high;
   end if;
   insert into employees (
      employee_id,
      first_name,
      last_name,
      email,
      phone_number,
      hire_date,
      job_id,
      salary,
      commission_pct,
      manager_id,
      department_id
   ) values ( emp_id_seq.nextval,
              p_first_name,
              p_last_name,
              p_email,
              p_phone_number,
              p_hire_date,
              p_job_id,
              p_salary,
              p_commission_pct,
              p_manager_id,
              p_department_id );

   commit;
   dbms_output.put_line('Employee added successfully');
exception
   when salary_too_high then
      dbms_output.put_line('Error: Salary cannot exceed 20000');
      rollback;
   when dup_val_on_index then
      dbms_output.put_line('Error: Duplicate email address');
      rollback;
   when others then
      dbms_output.put_line('Error: ' || sqlerrm);
      rollback;
end add_employee;
/