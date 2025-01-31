-- Role
create sequence role_id_seq start with 1000 increment by 1 nocache nocycle;
create or replace trigger role_id_trg before
   insert on roles
   for each row
   when ( new.role_id is null )
begin
   :new.role_id := role_id_seq.nextval;
end;
/

-- Users
create sequence user_id_seq start with 1000 increment by 1 nocache nocycle;
create or replace trigger user_id_trg before
   insert on users
   for each row
   when ( new.user_id is null )
begin
   :new.user_id := user_id_seq.nextval;
end;
/

-- Restaurants
create sequence restaurant_id_seq start with 1000 increment by 1 nocache nocycle;
create or replace trigger restaurant_id_trg before
   insert on restaurants
   for each row
   when ( new.restaurant_id is null )
begin
   :new.restaurant_id := restaurant_id_seq.nextval;
end;
/

-- Suppliers
create sequence supplier_id_seq start with 1000 increment by 1 nocache nocycle;
create or replace trigger supplier_id_trg before
   insert on suppliers
   for each row
   when ( new.supplier_id is null )
begin
   :new.supplier_id := supplier_id_seq.nextval;
end;
/

-- Inventory
create sequence inventory_id_seq start with 1000 increment by 1 nocache nocycle;
create or replace trigger inventory_id_trg before
   insert on inventory
   for each row
   when ( new.inventory_id is null )
begin
   :new.inventory_id := inventory_id_seq.nextval;
end;
/

-- Menu Items
create sequence menu_item_id_seq start with 1000 increment by 1 nocache nocycle;
create or replace trigger menu_item_id_trg before
   insert on menu_items
   for each row
   when ( new.menu_item_id is null )
begin
   :new.menu_item_id := menu_item_id_seq.nextval;
end;
/

-- Customers
create sequence customer_id_seq start with 1000 increment by 1 nocache nocycle;
create or replace trigger customer_id_trg before
   insert on customers
   for each row
   when ( new.customer_id is null )
begin
   :new.customer_id := customer_id_seq.nextval;
end;
/

-- Orders
create sequence order_id_seq start with 1000 increment by 1 nocache nocycle;
create or replace trigger order_id_trg before
   insert on orders
   for each row
   when ( new.order_id is null )
begin
   :new.order_id := order_id_seq.nextval;
end;
/

-- Order Items
create sequence order_item_id_seq start with 1000 increment by 1 nocache nocycle;
create or replace trigger order_item_id_trg before
   insert on order_items
   for each row
   when ( new.order_item_id is null )
begin
   :new.order_item_id := order_item_id_seq.nextval;
end;
/

-- Sales
create sequence sale_id_seq start with 1000 increment by 1 nocache nocycle;
create or replace trigger sale_id_trg before
   insert on sales
   for each row
   when ( new.sale_id is null )
begin
   :new.sale_id := sale_id_seq.nextval;
end;
/

-- Employees
create sequence employee_id_seq start with 1000 increment by 1 nocache nocycle;
create or replace trigger employee_id_trg before
   insert on employees
   for each row
   when ( new.employee_id is null )
begin
   :new.employee_id := employee_id_seq.nextval;
end;
/

-- Reservations
create sequence reservation_id_seq start with 1000 increment by 1 nocache nocycle;
create or replace trigger reservation_id_trg before
   insert on reservations
   for each row
   when ( new.reservation_id is null )
begin
   :new.reservation_id := reservation_id_seq.nextval;
end;
/

-- Expenses
create sequence expense_id_seq start with 1000 increment by 1 nocache nocycle;
create or replace trigger expense_id_trg before
   insert on expenses
   for each row
   when ( new.expense_id is null )
begin
   :new.expense_id := expense_id_seq.nextval;
end;
/


-- Shifts
create sequence shifts_id_seq start with 1000 increment by 1 nocache nocycle;
create or replace trigger shifts_id_trg before
   insert on shifts
   for each row
   when ( new.shift_id is null )
begin
   :new.shift_id := shifts_id_seq.nextval;
end;
/



-- Logs 
create sequence logs_id_seq start with 1000 increment by 1 nocache nocycle;
create or replace trigger log_id_trg before
   insert on logs
   for each row
   when ( new.log_id is null )
begin
   :new.log_id := logs_id_seq.nextval;
end;
/