create or replace function archive_and_delete_employee (
   p_employee_id        in int,
   p_termination_reason in varchar
) return boolean is
   pragma autonomous_transaction;
   v_total_hours decimal(
      8,
      2
   );
begin
   select nvl(
      sum(shift_duration),
      0
   )
     into v_total_hours
     from shifts
    where employee_id = p_employee_id;

   insert into employee_archive (
      employee_id,
      user_id,
      restaurant_id,
      name,
      position,
      salary,
      phone,
      hire_date,
      worked_hours,
      termination_date,
      termination_reason
   )
      select e.employee_id,
             e.user_id,
             e.restaurant_id,
             e.name,
             e.position,
             e.salary,
             e.phone,
             e.hire_date,
             v_total_hours,
             current_timestamp,
             p_termination_reason
        from employees e
       where e.employee_id = p_employee_id;

   delete from shifts
    where employee_id = p_employee_id;
   delete from employees
    where employee_id = p_employee_id;
   commit;
   return true;
exception
   when others then
      dbms_output.put_line('Error: ' || sqlerrm);
      return false;
end;
/

declare
   employee_to_get_rekt int;
   reason               varchar(255);
   v_succ               boolean;
begin
   employee_to_get_rekt := 1001;
   reason := 'LuLz';
   v_succ := archive_and_delete_employee(
      employee_to_get_rekt,
      reason
   );
end;
/

delete from shifts
 where employee_id = 1000;
delete from employees
 where employee_id = 1000;