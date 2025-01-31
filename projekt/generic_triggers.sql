create or replace trigger trg_protect_roles before
   insert or update or delete on roles
declare
   pragma autonomous_transaction; -- ale się z tym namęczyłem xd
begin
   insert into logs (
      log_username,
      operation
   ) values ( user,
              'INSERT/UPDATE/DELETE Operations on Role table are not allowed' );
   commit;
   raise_application_error(
      -20008,
      ' Operations on Role table are not allowed'
   );
end;
/

insert into roles ( role_name ) values ( 'X' );

insert into logs (
   log_username,
   operation
) values ( user,
           'Operations on Role table are not allowed' );

create or replace trigger trg_audit_users before
   update on users
   for each row
begin
   insert into logs (
      log_username,
      operation
   ) values ( user,
              'UPDATE Users - Old values: [Username: '
              || :old.username
              || ', Email: '
              || :old.email
              || ', Role: '
              || :old.role_id
              || '] New values: [Username: '
              || :new.username
              || ', Email: '
              || :new.email
              || ', Role: '
              || :new.role_id
              || ']' );
end;
/


create or replace trigger trg_insert_users before
   insert on users
   for each row
begin
   insert into logs (
      log_username,
      operation
   ) values ( user,
              'INSERT Users: [Username: '
              || :new.username
              || ', Email: '
              || :new.email
              || ', Role: '
              || :new.role_id
              || ']' );
end;
/

create or replace trigger trg_delete_users before
   delete on users
   for each row
begin
   insert into logs (
      log_username,
      operation
   ) values ( user,
              'DELETE users: [Username: '
              || :new.username
              || ', Email: '
              || :new.email
              || ', Role: '
              || :new.role_id
              || ']' );
end;
/

create or replace trigger trg_audit_employees before
   update on employees
   for each row
begin
   insert into logs (
      log_username,
      operation
   ) values ( user,
              'UPDATE Employee - Old values: [Name: '
              || :old.name
              || ', Position: '
              || :old.position
              || ', Salary: '
              || :old.salary
              || ', Phone: '
              || :old.phone
              || ', Restaurant: '
              || :old.restaurant_id
              || '] New values: [Name: '
              || :new.name
              || ', Position: '
              || :new.position
              || ', Salary: '
              || :new.salary
              || ', Phone: '
              || :new.phone
              || ', Restaurant: '
              || :new.restaurant_id
              || ']' );
end;
/

create or replace trigger trg_insert_employees before
   insert on employees
   for each row
begin
   insert into logs (
      log_username,
      operation
   ) values ( user,
              'INSERT Employee: [Name: '
              || :new.name
              || ', Position: '
              || :new.position
              || ', Salary: '
              || :new.salary
              || ', Phone: '
              || :new.phone
              || ', Restaurant: '
              || :new.restaurant_id
              || ']' );
end;
/

create or replace trigger trg_delete_employees before
   delete on employees
   for each row
begin
   insert into logs (
      log_username,
      operation
   ) values ( user,
              'DELETE Employee: [Name: '
              || :old.name
              || ', Position: '
              || :old.position
              || ', Salary: '
              || :old.salary
              || ', Phone: '
              || :old.phone
              || ', Restaurant: '
              || :old.restaurant_id
              || ']' );
end;
/