from faker import Faker
from sqlalchemy import text

def execute_statements_from_file(connection, file_path):
    with open(file_path, "r") as f:
        sql_statements = f.read()
        execute_statements(connection, sql_statements)


def execute_statements(connection, sql_statements):
    statements = [stmt.strip() for stmt in sql_statements.split(";") if stmt.strip()]
    for statement in statements:
        if statement:
            connection.execute(text(statement))
t 
def clearTables(connection) -> None:
    result = connection.execute(
        text("SELECT table_name FROM user_tables ORDER BY table_name DESC")
    )

    for row in result:
        try:
            connection.execute(
                text(
                    f"""ALTER TABLE {row.table_name} DISABLE CONSTRAINT ALL ;
                    COMMIT;"""
                )
            )
            
        except Exception as e:
            print(f"Error dropping table {row.table_name}: {str(e)}")
            continue
        
        
def clearSequences(connection) -> None:
    result = connection.execute(
        text("SELECT sequence_name FROM user_sequences WHERE sequence_name != 'ISEQ$$_458883'")
    )

    for row in result:
        try:
            connection.execute(
                text(
                    f"""DROP SEQUENCE {row.sequence_name}';
                    COMMIT;"""
                )
            )
        except Exception as e:
            print(f"Error dropping sequence {row.sequence_name}: {str(e)}")
            continue