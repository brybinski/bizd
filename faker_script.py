from faker import Faker
import random
import hashlib
from sqlalchemy import text
import datetime


def fakeUsers(n: int, fakeroles=False) -> str:

    fake = Faker("pl_PL")
    roles = [
        (1, "Admin"),
        (2, "Manager"),
        (3, "Waiter"),
        (4, "Chef"),
        (5, "Salesperson"),
        (6, "TemporaryUser"),
    ]

    sql = ""
    if fakeroles:
        for role_id, role_name in roles:
            sql += f"INSERT INTO roles (role_id, role_name) VALUES ({role_id}, '{role_name}');\n"

    for i in range(n):
        username = fake.user_name()
        password = fake.password()
        password_hash = hashlib.sha256(password.encode()).hexdigest()
        email = fake.email()
        role_id = random.randint(1, len(roles))

        sql += f"""INSERT INTO users ( username, password_hash, email, role_id)
VALUES ('{username}', '{password_hash}', '{email}', {role_id});\n"""

    sql += "\nCOMMIT;"
    return sql


def fakeRestaurant(connection, n: int) -> str:
    fake = Faker("pl_PL")

    # Get all managers (role_id = 2)
    result = connection.execute(text("SELECT user_id FROM users WHERE role_id = 2"))
    manager_ids = [row[0] for row in result]

    if not manager_ids:
        raise ValueError("No managers found in users table")

    sql = ""
    for i in range(n):
        name = fake.company()
        location = fake.address().replace("'", "''")  # Escape single quotes
        phone = "+48 " + str(fake.random_number(digits=9, fix_len=True))
        # Cycle through managers if we have more restaurants than managers
        manager_id = manager_ids[i % len(manager_ids)]

        sql += f"""INSERT INTO restaurants ( name, location, phone, manager_id)
VALUES ('{name}', '{location}', '{phone}', {manager_id});\n"""

    sql += "\nCOMMIT;"
    return sql


def fakeSuppliers(n: int) -> str:
    fake = Faker("pl_PL")

    sql = ""
    for i in range(n):
        name = fake.company().replace("'", "''")
        contact_name = fake.name().replace("'", "''")
        phone = "+48" + str(fake.random_number(digits=9, fix_len=True))
        email = fake.company_email()

        sql += f"""INSERT INTO suppliers ( name, contact_name, phone, email)
VALUES ( '{name}', '{contact_name}', '{phone}', '{email}');\n"""

    sql += "\nCOMMIT;"
    return sql


def fakeInventory(connection, n: int) -> str:
    fake = Faker("pl_PL")

    fish_products = [
        ("Łosoś Atlantycki", 5, 50, "kg", "Ryby Świeże", 89.99),
        ("Filet z Tuńczyka", 10, 100, "kg", "Ryby Świeże", 79.99),
        ("Dorsz", 5, 40, "kg", "Ryby Świeże", 59.99),
        ("Krewetki Mrożone", 20, 200, "kg", "Mrożone", 49.99),
        ("Makrela Wędzona", 3, 30, "kg", "Przetworzone", 39.99),
        ("Paluszki Rybne", 50, 500, "szt", "Mrożone", 12.99),
        ("Sardynki w Puszce", 100, 1000, "szt", "Przetworzone", 8.99),
        ("Okoń Morski", 5, 30, "kg", "Ryby Świeże", 69.99),
        ("Halibut", 5, 25, "kg", "Ryby Świeże", 74.99),
        ("Kawior", 1, 5, "kg", "Premium", 2999.99),
    ]

    result = connection.execute(text("SELECT restaurant_id FROM restaurants"))
    restaurant_ids = [row[0] for row in result]

    result = connection.execute(text("SELECT supplier_id FROM suppliers"))
    supplier_ids = [row[0] for row in result]

    if not restaurant_ids or not supplier_ids:
        raise ValueError("No restaurants or suppliers found")

    sql = ""
    inventory_id = 1
    for rest_id in restaurant_ids:
        selected_products = random.sample(fish_products, n)

        for product in selected_products:
            name, min_qty, max_qty, unit, category, price = product
            quantity = random.randint(min_qty, max_qty)
            supplier_id = random.choice(supplier_ids)

            sql += f"""INSERT INTO inventory 
            (restaurant_id, item_name, category, quantity, unit, supplier_id, price)
            VALUES ({rest_id}, '{name}', '{category}', {quantity}, '{unit}', {supplier_id}, {price});\n"""

            inventory_id += 1

    sql += "\nCOMMIT;"
    return sql


def fakeExpenses(connection, n: int) -> str:
    fake = Faker("pl_PL")

    expense_categories = [
        (
            "Media",
            1000,
            5000,
            [
                "Rachunek za prąd",
                "Rachunek za wodę",
                "Rachunek za gaz",
                "Usługi internetowe",
                "Usługi telefoniczne",
                "Wywóz śmieci",
            ],
        ),
        (
            "Konserwacja",
            200,
            2000,
            [
                "Naprawa sprzętu",
                "Konserwacja hydrauliki",
                "Serwis HVAC",
                "Konserwacja sprzętu kuchennego",
                "Naprawa chłodzenia",
            ],
        ),
        (
            "Zaopatrzenie",
            500,
            3000,
            [
                "Środki czystości",
                "Wyposażenie kuchni",
                "Materiały biurowe",
                "Artykuły jednorazowe",
                "Sprzęt restauracyjny",
            ],
        ),
        (
            "Marketing",
            1000,
            10000,
            [
                "Reklama w mediach społecznościowych",
                "Reklamy w lokalnej prasie",
                "Materiały promocyjne",
                "Utrzymanie strony internetowej",
            ],
        ),
    ]

    result = connection.execute(text("SELECT restaurant_id FROM restaurants"))
    restaurant_ids = [row[0] for row in result]

    if not restaurant_ids:
        raise ValueError("Nie znaleziono restauracji")

    sql = ""
    expense_id = 1

    for rest_id in restaurant_ids:
        for i in range(n):
            category, min_amount, max_amount, descriptions = random.choice(
                expense_categories
            )
            amount = round(random.uniform(min_amount, max_amount), 2)
            description = random.choice(descriptions)

            expense_date = fake.date_between(start_date="-90d", end_date="today")

            sql += f"""INSERT INTO expenses 
            (restaurant_id, description, amount, expense_date, category)
            VALUES ({rest_id}, '{description}', {amount}, 
            TO_DATE('{expense_date}', 'YYYY-MM-DD'), '{category}');\n"""

            expense_id += 1

    sql += "\nCOMMIT;"
    return sql


def fakeCustomers(n: int) -> str:
    fake = Faker("pl_PL")

    sql = ""
    for i in range(n):
        name = fake.name().replace("'", "''")
        phone = "+48" + str(fake.random_number(digits=9, fix_len=True))
        email = fake.email()
        loyalty_points = random.randint(0, 1000)

        sql += f"""INSERT INTO customers 
        (name, phone, email, loyalty_points)
        VALUES ('{name}', '{phone}', '{email}', {loyalty_points});\n"""

    sql += "\nCOMMIT;"
    return sql


def fakeMenuItems(n: int) -> str:
    fake = Faker("pl_PL")

    # Przyznaje się bez bicia, nazwy robiłem czatem bo to za dużo roboty a nie taki jest cel zadania
    menu_categories = [
        (
            "Przystawki",
            [
                ("Zupa Rybna", "Tradycyjna zupa rybna z warzywami", 25.99),
                (
                    "Krążki Kalmarów",
                    "Chrupiące krążki z kalmarów z sosem tatarskim",
                    32.99,
                ),
                ("Koktajl Krewetkowy", "Świeże krewetki z sosem koktajlowym", 45.99),
                (
                    "Sałatka z Owocami Morza",
                    "Mix owoców morza ze świeżymi warzywami",
                    38.99,
                ),
            ],
        ),
        (
            "Dania Główne",
            [
                ("Łosoś z Grilla", "Świeży łosoś z ziołami i cytryną", 79.99),
                ("Fish & Chips", "Tradycyjny dorsz z chrupiącymi frytkami", 49.99),
                ("Stek z Tuńczyka", "Stek z tuńczyka w sezamowej panierce", 89.99),
                ("Filet z Okonia Morskiego", "Smażony okoń w sosie maślanym", 94.99),
                ("Homar Thermidor", "Homar w bogatym kremowym sosie", 159.99),
            ],
        ),
        (
            "Dodatki",
            [
                ("Warzywa na Parze", "Sezonowe warzywa", 15.99),
                ("Ryż Pilaw", "Aromatyczny ryż z ziołami", 12.99),
                ("Puree Ziemniaczane", "Kremowe puree ziemniaczane", 14.99),
                ("Grillowane Szparagi", "Świeże szparagi z oliwą", 18.99),
            ],
        ),
        (
            "Desery",
            [
                ("Crème Brûlée", "Klasyczny francuski deser", 24.99),
                ("Mus Czekoladowy", "Bogaty deser czekoladowy", 22.99),
                ("Lody", "Wybór lodów", 16.99),
                ("Szarlotka", "Ciepła szarlotka z sosem waniliowym", 19.99),
            ],
        ),
    ]

    sql = ""
    item_id = 1

    for i in range(n):
        category, items = random.choice(menu_categories)
        name, description, base_price = random.choice(items)
        price = round(base_price * random.uniform(0.9, 1.1), 2)
        available = random.randint(0, 1)

        sql += f"""INSERT INTO menu_items 
        ( name, description, price, category, available)
        VALUES ('{name}', '{description}', {price}, '{category}', {available});\n"""

        item_id += 1

    sql += "\nCOMMIT;"
    return sql


def fakeOrders(connection, n: int) -> str:
    fake = Faker()

    # Get required data from database
    res = connection.execute(text("SELECT restaurant_id FROM restaurants"))
    restaurant_ids = [row[0] for row in res.fetchall()]

    res = connection.execute(
        text("SELECT menu_item_id FROM menu_items WHERE available = 1")
    )
    menu_items = [row[0] for row in res.fetchall()]

    res = connection.execute(text("SELECT customer_id FROM customers"))
    customer_ids = [row[0] for row in res.fetchall()]

    order_types = ["dine-in", "take-out", "drive-thru"]
    payment_methods = ["Cash", "Card"]

    sql = ""
    for rest_id in restaurant_ids:
        for i in range(n):
            customer_id = (
                "NULL" if random.random() > 0.8 else random.choice(customer_ids)
            )
            table_number = random.randint(1, 20)
            order_type = random.choice(order_types)
            payment_method = random.choice(payment_methods)

            num_items = random.randint(1, 5)
            selected_items = random.sample(menu_items, num_items)
            quantities = [random.randint(1, 3) for j in range(num_items)]

            connection.execute( f"""
            DECLARE
                v_menu_items sys.odcinumberlist;
                v_quantities sys.odcinumberlist;
                v_order_id   number;
            BEGIN
                v_menu_items sys.odcinumberlist := sys.odcinumberlist{tuple(selected_items)};
                v_quantities sys.odcinumberlist := sys.odcinumberlist{tuple(quantities)};
                v_order_id := create_order(
                    p_restaurant_id => {rest_id},
                    p_customer_id   => {customer_id},
                    p_table_number  => {table_number},
                    p_order_type    => '{order_type}',
                    p_order_status  => 'Completed',
                    p_menu_items    => v_menu_items,
                    p_quantities    => v_quantities,
                    p_payment_type  => '{payment_method}'
                );
            END;
            /""")

    sql += "\nCOMMIT;"
    return 


def fakeReservations(connection, n: int) -> str:
    fake = Faker("pl_PL")

    # Get required data
    restaurants = connection.execute(
        text("SELECT restaurant_id FROM restaurants")
    ).fetchall()
    customers = connection.execute(text("SELECT customer_id FROM customers")).fetchall()

    if not restaurants or not customers:
        raise ValueError("No restaurants or customers found")

    sql = ""
    reservation_id = 1

    for rest_id in restaurants:
        for i in range(n):
            customer_id = random.choice(customers)[0]
            table_number = random.randint(1, 20)

            date_time = fake.date_time_between(start_date="-90d", end_date="+14d")
            sql += f"""INSERT INTO reservations 
            ( restaurant_id, customer_id, table_number, date_time)
            VALUES ( {rest_id[0]}, {customer_id}, {table_number}, 
            TO_TIMESTAMP('{date_time}', 'YYYY-MM-DD HH24:MI:SS.FF6'));\n"""

            reservation_id += 1

    sql += "\nCOMMIT;"
    return sql


def fakeSales(connection) -> str:
    fake = Faker("pl_PL")

    # Get completed orders
    orders = connection.execute(
        text(
            """
        SELECT order_id, restaurant_id, customer_id, total_price, created_at 
        FROM orders 
        WHERE order_status = 'Completed'
    """
        )
    ).fetchall()

    if not orders:
        raise ValueError("No completed orders found")

    payment_methods = ["Cash", "Card", "Mobile Payment"]
    sql = ""

    sale_id = 1

    for order in orders:
        order_id, restaurant_id, customer_id, total_price, order_time = order
        payment_method = random.choice(payment_methods)

        # Set sale time 15-45 minutes after order time
        sale_time = order_time + datetime.timedelta(minutes=random.randint(15, 45))

        customer = f"{customer_id}" if customer_id else "NULL"

        sql += f"""INSERT INTO sales 
        (order_id, restaurant_id, customer_id, payment_method, total_amount, date_time)
        VALUES ( {order_id}, {restaurant_id}, {customer}, 
        '{payment_method}', {total_price}, 
        TO_TIMESTAMP('{sale_time}', 'YYYY-MM-DD HH24:MI:SS.FF6'));\n"""

        sale_id += 1

    sql += "\nCOMMIT;"
    return sql


def fakeEmployees(connection) -> str:
    fake = Faker("pl_PL")

    role_salaries = {
        2: (8000, 12000),  # Manager
        3: (4000, 6000),  # Waiter
        4: (6000, 9000),  # Chef
        5: (4500, 7000),  # Salesperson
    }

    # Get eligible users
    users = connection.execute(
        text(
            """
        SELECT u.user_id, u.username, r.role_id, r.role_name 
        FROM users u 
        JOIN roles r ON u.role_id = r.role_id 
        WHERE r.role_id BETWEEN 2 AND 5
    """
        )
    ).fetchall()

    restaurants = connection.execute(
        text("SELECT restaurant_id FROM restaurants")
    ).fetchall()

    if not users or not restaurants:
        raise ValueError("No users or restaurants found")

    sql = ""
    employee_id = 1

    for user in users:
        user_id, username, role_id, role_name = user
        restaurant_id = random.choice(restaurants)[0]
        min_salary, max_salary = role_salaries[role_id]
        salary = round(random.uniform(min_salary, max_salary), 2)
        hire_date = fake.date_between(start_date="-2y", end_date="today")
        phone = "+48" + str(fake.random_number(digits=9, fix_len=True))
        name = fake.name()

        sql += f"""INSERT INTO employees 
        ( user_id, restaurant_id, name, position, salary, phone, hire_date)
        VALUES ( {user_id}, {restaurant_id}, '{name}', '{role_name}', 
        {salary}, '{phone}', TO_DATE('{hire_date}', 'YYYY-MM-DD'));\n"""

        employee_id += 1

    sql += "\nCOMMIT;"
    return sql


def fakeShift(connection) -> str:
    fake = Faker("pl_PL")
    sql = ""

    res = connection.execute(text("SELECT employee_id FROM employees"))
    employees = res.fetchall()

    for employee in employees:
        num_shifts = random.randint(1, 5)

        for _ in range(num_shifts):
            employee_id = employee[0]
            # Shift duration between 4-12 hours
            shift_duration = round(random.uniform(4, 12), 2)

            shift_start = fake.date_time_between(start_date="-90d", end_date="now")

            sql += f"""INSERT INTO shifts 
            (employee_id, shift_duration, shift_start_time)
            VALUES ( {employee_id}, {shift_duration}, 
            TO_TIMESTAMP('{shift_start}', 'YYYY-MM-DD HH24:MI:SS.FF6'));\n"""

    sql += "\nCOMMIT;"
    return sql


if __name__ == "__main__":
    faker = Faker("pl_PL")
    print(faker.name())
