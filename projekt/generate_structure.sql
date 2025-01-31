create table roles (
   role_id   int primary key,
   role_name varchar(100) not null unique -- e.g. Admin, Manager, Waiter, Chef, etc.
);


create table users (
   user_id       int primary key,
   username      varchar2(100) not null unique,
   password_hash varchar2(1024) not null,
   email         varchar2(320) unique,
   role_id       int not null,
   created_at    date default sysdate,
   constraint fk_user_role foreign key ( role_id )
      references roles ( role_id )
);

create table restaurants (
   restaurant_id int primary key,
   name          varchar(512) not null,
   location      varchar(1024) not null,
   phone         varchar(20),
   manager_id    int
      references users ( user_id )
);

create table suppliers (
   supplier_id  int primary key,
   name         varchar(1024) not null,
   contact_name varchar(1024),
   phone        varchar(20),
   email        varchar(320)
);


create table inventory (
   inventory_id  int primary key,
   restaurant_id int not null,
   item_name     varchar(512) not null,
   category      varchar(50),
   quantity      int default 0,
   price         decimal(10,2),
   unit          varchar(4), -- e.g. kg, g, l, ml, pcs
   supplier_id   int not null,
   constraint fk_restaurant_id foreign key ( restaurant_id )
      references restaurants ( restaurant_id ),
   constraint fk_supplier_id foreign key ( supplier_id )
      references suppliers ( supplier_id ),
   last_updated  timestamp default current_timestamp
);

create table menu_items (
   menu_item_id int primary key,
   name         varchar(256) not null,
   description  varchar(2048),
   price        decimal(10,2) not null,
   category     varchar(50),
   available    int default 0
);

create table customers (
   customer_id    int primary key,
   name           varchar(512) not null,
   phone          varchar(20),
   email          varchar(320),
   loyalty_points int default 0
);

create table orders (
   order_id       int primary key,
   restaurant_id  int not null,
   customer_id    int
      references customers ( customer_id ),
   table_number   int,
   order_type     varchar(50), --drive-thru, dine-in, take-out 
   order_status   varchar(50) default 'Pending', -- Pending, In Progress, Completed, Cancelled
   total_price    decimal(10,2),
   payment_method varchar(50), -- Cash, Card, Mobile Payment, etc.
   created_at     timestamp default current_timestamp,
   constraint fk_restaurant_id_order foreign key ( restaurant_id )
      references restaurants ( restaurant_id )
);

create table order_items (
   order_item_id int primary key,
   order_id      int,
   menu_item_id  int
      references menu_items ( menu_item_id ),
   quantity      int not null,
   price         decimal(10,2) not null,
   constraint fk_order_id foreign key ( order_id )
      references orders ( order_id )
);

create table sales (
   sale_id        int primary key,
   restaurant_id  int not null,
   order_id       int not null,
   customer_id    int
      references customers ( customer_id ),
   total_amount   decimal(10,2) not null,
   payment_method varchar(50),
   date_time      timestamp default current_timestamp,
   constraint fk_restaurant_id_sales foreign key ( restaurant_id )
      references restaurants ( restaurant_id ),
   constraint fk_order_id_sales foreign key ( order_id )
      references orders ( order_id )
);

create table employees (
   employee_id   int primary key,
   user_id       int not null,
   restaurant_id int not null,
   name          varchar(512) not null,
   position      varchar(256),
   salary        decimal(10,2),
   phone         varchar(20),
   hire_date     date,
   constraint fk_user_id_employees foreign key ( user_id )
      references users ( user_id ),
   constraint fk_restaurant_id_employees foreign key ( restaurant_id )
      references restaurants ( restaurant_id )
);

create table reservations (
   reservation_id int primary key,
   restaurant_id  int
      references restaurants ( restaurant_id ),
   customer_id    int
      references customers ( customer_id ),
   table_number   int not null,
   date_time      timestamp not null
);

create table expenses (
   expense_id    int primary key,
   restaurant_id int not null,
   description   varchar(512),
   amount        decimal(10,2) not null,
   expense_date  date,
   category      varchar(50),
   constraint fk_restaurant_id_expenses foreign key ( restaurant_id )
      references restaurants ( restaurant_id )
);


create table logs (
   log_id         int primary key,
   log_username   varchar(100) not null,
   operation      varchar(1000) not null,
   operation_time timestamp default current_timestamp
);

create table shifts (
   shift_id         int primary key,
   employee_id      int not null,
   shift_duration   decimal(4,2) not null,
   shift_start_time timestamp not null,
   constraint fk_employee_id_shifts foreign key ( employee_id )
      references employees ( employee_id )
);

create table employee_archive (
   employee_id        int primary key,
   user_id            int
      references users ( user_id ),
   restaurant_id      int
      references restaurants ( restaurant_id ),
   name               varchar(512) not null,
   position           varchar(256),
   salary             decimal(10,2),
   phone              varchar(20),
   hire_date          date,
   worked_hours       decimal(8,2),
   termination_date   date,
   termination_reason varchar(512)
);