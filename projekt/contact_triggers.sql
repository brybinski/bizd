create or replace trigger trg_validate_supplier_email before
   insert or update of email on suppliers
   for each row
   when ( new.email is not null )
begin
   :new.email := is_valid_email(:new.email);
exception
   when others then
      raise_application_error(
         -20001,
         'Invalid email format for supplier. Error: ' || sqlerrm
      );
end;
/


create or replace trigger trg_validate_users_email before
   insert or update of email on users
   for each row
   when ( new.email is not null )
begin
   :new.email := is_valid_email(:new.email);
exception
   when others then
      raise_application_error(
         -20001,
         'Invalid email format for User. Error: ' || sqlerrm
      );
end;
/

create or replace trigger trg_validate_customers_email before
   insert or update of email on customers
   for each row
   when ( new.email is not null )
begin
   :new.email := is_valid_email(:new.email);
exception
   when others then
      raise_application_error(
         -20001,
         'Invalid email format for Customer. Error: ' || sqlerrm
      );
end;
/

create or replace trigger trg_validate_customers_phone before
   insert or update of phone on customers
   for each row
   when ( new.phone is not null )
begin
   :new.phone := is_valid_phone_number(:new.phone);
exception
   when others then
      raise_application_error(
         -20002,
         'Invalid phone number format for Customer. Error: ' || sqlerrm
      );
end;
/

create or replace trigger trg_validate_suppliers_phone before
   insert or update of phone on suppliers
   for each row
   when ( new.phone is not null )
begin
   :new.phone := is_valid_phone_number(:new.phone);
exception
   when others then
      raise_application_error(
         -20002,
         'Invalid phone number format for Customer. Error: ' || sqlerrm
      );
end;
/

create or replace trigger trg_validate_employees_phone before
   insert or update of phone on employees
   for each row
   when ( new.phone is not null )
begin
   :new.phone := is_valid_phone_number(:new.phone);
exception
   when others then
      raise_application_error(
         -20002,
         'Invalid phone number format for Customer. Error: ' || sqlerrm
      );
end;
/

create or replace trigger trg_validate_restaurants_phone before
   insert or update of phone on restaurants
   for each row
   when ( new.phone is not null )
begin
   :new.phone := is_valid_phone_number(:new.phone);
exception
   when others then
      raise_application_error(
         -20002,
         'Invalid phone number format for Customer. Error: ' || sqlerrm
      );
end;
/