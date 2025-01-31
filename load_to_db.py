from faker import Faker
from faker_script import *
from sql_utils import *
from sqlalchemy import create_engine, text
from visualisation import *

engine = create_engine(
    "oracle+oracledb://rybinskib:hnmj@213.184.8.44:1521/?service_name=orcl"
)


with engine.connect() as connection:
    with connection.begin():

        # # Drop all tables
        # clearTables(connection)
        # clearSequences(connection)
        # # Recreate Structure
        # execute_statements_from_file(connection, "projekt/generate_structure.sql")

        # # Here run set_sequences.sql manually as it is not working correctly with sqlalchemy but works in sqldeveloper vscode plugin xD
        # x = input("now run set_sequences.sql manually and press enter")

        # Create the roles table and insert fake users
        # execute_statements(connection, fakeUsers(100, fakeroles=False))

        # # Insert fake restaurants
        # execute_statements(connection, fakeRestaurant(connection, 10))

        # # Insert fake suppliers
        # execute_statements(connection, fakeSuppliers(10))

        # # Insert fake inventory
        # execute_statements(connection, fakeInventory(connection, 10))

        # # Insert fake expenses
        # execute_statements(connection, fakeExpenses(connection, 10))

        # # Insert fake customers
        # execute_statements(connection, fakeCustomers(40))

        # # Insert fake menu items
        # execute_statements(connection, fakeMenuItems(15))

        # # # Insert fake orders
        # #  execute_statements(connection, fakeOrders(connection, 100))

        # # Insert fake reservations
        # execute_statements(connection, fakeReservations(connection, 10))

        # # Insert fake sales
        # execute_statements(connection, fakeSales(connection))

        # # Insert fake employees
        execute_statements(connection, fakeEmployees(connection))

        # # Insert fake shifts
        # execute_statements(connection, fakeShift(connection))

        # result = connection.execute(text("SELECT * FROM shifts"))

        # for row in result:
        #     print(row)


        # result = connection.execute(text("SELECT * FROM logs"))

        # for row in result:
        #     print(row)
        expenses_report(connection, -3,-2)
        # repr(inventory_value_report(connection))

        connection.close()