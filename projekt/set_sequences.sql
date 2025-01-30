-- Role
create sequence role_id_seq start with 1000 increment by 1 nocache nocycle;
create or replace trigger role_id_trg before
   insert on roles
   for each row
   WHEN (new.role_id is null)
begin
   :new.role_id := role_id_seq.nextval;
end;
/

-- Users
create sequence user_id_seq start with 1000 increment by 1 nocache nocycle;
create or replace trigger user_id_trg before
   insert on users
   for each row
   WHEN (new.user_id is null)
begin
   :NEW.user_id := user_id_seq.nextval;
end;
/

-- Restaurants
create sequence restaurant_id_seq start with 1000 increment by 1 nocache nocycle;
create or replace trigger restaurant_id_trg before
   insert on restaurants
   for each row
   WHEN (new.restaurant_id is null)
begin
   :NEW.restaurant_id := restaurant_id_seq.nextval;
end;
/

-- Suppliers
create sequence supplier_id_seq start with 1000 increment by 1 nocache nocycle;
create or replace trigger supplier_id_trg before
   insert on suppliers
   for each row
   WHEN (new.supplier_id is null)
begin
   :NEW.supplier_id := supplier_id_seq.nextval;
end;
/

-- Inventory
create sequence inventory_id_seq start with 1000 increment by 1 nocache nocycle;
create or replace trigger inventory_id_trg before
   insert on inventory
   for each row
   WHEN (new.inventory_id is null)
begin
   :NEW.inventory_id := inventory_id_seq.nextval;
end;
/

-- Menu Items
create sequence menu_item_id_seq start with 1000 increment by 1 nocache nocycle;
create or replace trigger menu_item_id_trg before
   insert on menu_items
   for each row
   WHEN (new.menu_item_id is null)
begin
   :NEW.menu_item_id := menu_item_id_seq.nextval;
end;
/

-- Customers
create sequence customer_id_seq start with 1000 increment by 1 nocache nocycle;
create or replace trigger customer_id_trg before
   insert on customers
   for each row
   WHEN (new.customer_id is null)
begin
   :NEW.customer_id := customer_id_seq.nextval;
end;
/

-- Orders
create sequence order_id_seq start with 1000 increment by 1 nocache nocycle;
create or replace trigger order_id_trg before
   insert on orders
   for each row
   WHEN (new.order_id is null)
begin
   :NEW.order_id := order_id_seq.nextval;
end;
/

-- Order Items
create sequence order_item_id_seq start with 1000 increment by 1 nocache nocycle;
create or replace trigger order_item_id_trg before
   insert on order_items
   for each row
   WHEN (new.order_item_id is null)
begin
   :NEW.order_item_id := order_item_id_seq.nextval;
end;
/

-- Sales
create sequence sale_id_seq start with 1000 increment by 1 nocache nocycle;
create or replace trigger sale_id_trg before
   insert on sales
   for each row
   WHEN (new.sale_id is null)
begin
   :NEW.sale_id := sale_id_seq.nextval;
end;
/

-- Employees
create sequence employee_id_seq start with 1000 increment by 1 nocache nocycle;
create or replace trigger employee_id_trg before
   insert on employees
   for each row
   WHEN (new.employee_id is null)
begin
   :NEW.employee_id := employee_id_seq.nextval;
end;
/

-- Reservations
create sequence reservation_id_seq start with 1000 increment by 1 nocache nocycle;
create or replace trigger reservation_id_trg before
   insert on reservations
   for each row
   WHEN (new.reservation_id is null)
begin
   :NEW.reservation_id := reservation_id_seq.nextval;
end;
/

-- Expenses
create sequence expense_id_seq start with 1000 increment by 1 nocache nocycle;
create or replace trigger expense_id_trg before
   insert on expenses
   for each row
   WHEN (new.expense_id is null)
begin
   :NEW.expense_id := expense_id_seq.nextval;
end;
/
