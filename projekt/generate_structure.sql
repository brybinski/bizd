CREATE TABLE roles (
    role_id INT PRIMARY KEY,
    role_name VARCHAR(100) NOT NULL UNIQUE -- e.g. Admin, Manager, Waiter, Chef, etc.
);


CREATE TABLE users (
    user_id INT PRIMARY KEY,
    username VARCHAR2(100) NOT NULL UNIQUE,
    password_hash VARCHAR2(1024) NOT NULL,
    email VARCHAR2(320) UNIQUE,
    role_id INT NOT NULL,
    created_at DATE DEFAULT SYSDATE,
    CONSTRAINT fk_user_role FOREIGN KEY (role_id) REFERENCES roles(role_id)
);

CREATE TABLE restaurants (
    restaurant_id INT PRIMARY KEY,
    name VARCHAR(512) NOT NULL,
    location VARCHAR(1024) NOT NULL,
    phone VARCHAR(20),
    manager_id INT REFERENCES users(user_id)
);

CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY,
    name VARCHAR(1024) NOT NULL,
    contact_name VARCHAR(1024),
    phone VARCHAR(20),
    email VARCHAR(320)
);


CREATE TABLE inventory (
    inventory_id INT PRIMARY KEY,
    restaurant_id INT NOT NULL,
    item_name VARCHAR(512) NOT NULL,
    category VARCHAR(50),
    quantity INT DEFAULT 0,
    price DECIMAL(10,2), 
    unit VARCHAR(4), -- e.g. kg, g, l, ml, pcs
    supplier_id INT NOT NULL,
    CONSTRAINT fk_restaurant_id FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id),
    CONSTRAINT fk_supplier_id FOREIGN KEY (supplier_id)REFERENCES suppliers(supplier_id),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE menu_items (
    menu_item_id INT PRIMARY KEY,
    name VARCHAR(256) NOT NULL,
    description VARCHAR(2048),
    price DECIMAL(10,2) NOT NULL,
    category VARCHAR(50),
    available INT DEFAULT 0
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(512) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(320),
    loyalty_points INT DEFAULT 0
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    restaurant_id INT NOT NULL,
    customer_id INT REFERENCES customers(customer_id),
    table_number INT,
    order_type VARCHAR(50), --drive-thru, dine-in, take-out
    order_status VARCHAR(50) DEFAULT 'Pending', -- Pending, In Progress, Completed, Cancelled
    total_price DECIMAL(10,2),
    payment_method VARCHAR(50), -- Cash, Card, Mobile Payment, etc.
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_restaurant_id_order FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)

);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT ,
    menu_item_id INT REFERENCES menu_items(menu_item_id),
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_order_id FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    restaurant_id INT NOT NULL,
    order_id INT NOT NULL,
    customer_id INT REFERENCES customers(customer_id),
    total_amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(50),
    date_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_restaurant_id_sales FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id),
    CONSTRAINT fk_order_id_sales FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    restaurant_id INT NOT NULL,
    name VARCHAR(512) NOT NULL,
    position VARCHAR(256),
    salary DECIMAL(10,2),
    phone VARCHAR(20),
    hire_date DATE,
    CONSTRAINT fk_user_id_employees FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_restaurant_id_employees FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
);

CREATE TABLE reservations (
    reservation_id INT PRIMARY KEY,
    restaurant_id INT REFERENCES restaurants(restaurant_id),
    customer_id INT REFERENCES customers(customer_id),
    table_number INT NOT NULL,
    date_time TIMESTAMP NOT NULL
);

CREATE TABLE expenses (
    expense_id INT PRIMARY KEY,
    restaurant_id INT NOT NULL,
    description VARCHAR(512),
    amount DECIMAL(10,2) NOT NULL,
    expense_date DATE,
    category VARCHAR(50),
    CONSTRAINT fk_restaurant_id_expenses FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)

);


CREATE TABLE logs (
    log_id INT PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    operation VARCHAR(1000) NOT NULL,
    operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

CREATE TABLE shifts (
    shift_id INT PRIMARY KEY,
    employee_id INT NOT NULL,
    shift_duration DECIMAL(4,2) NOT NULL,
    shift_start_time TIMESTAMP NOT NULL,
    CONSTRAINT fk_employee_id_shifts FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);