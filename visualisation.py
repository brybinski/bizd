import matplotlib.pyplot as plt
import numpy as np
from sqlalchemy import text


def expenses_report(connection, from_mon: int = -9, to_mon=1):

    sql = f"""WITH regularexpenses AS (
        SELECT *
        FROM (
            SELECT r.name as restaurant_name, 
                   e.category, 
                   e.amount
            FROM expenses e
            JOIN restaurants r ON e.restaurant_id = r.restaurant_id
            WHERE e.expense_date BETWEEN add_months(
      trunc(sysdate),
      {from_mon}
   ) AND add_months(
      trunc(sysdate),
      {to_mon})
              AND e.expense_date < TRUNC(SYSDATE, 'MM')
        )
        PIVOT (
            SUM(amount)
            FOR category IN (
                'Media' AS utilities,
                'Zaopatrzenie' AS supplies,
                'Konserwacja' AS maintenance,
                'Marketing' AS marketing
            )
        )
    )
    SELECT 
        restaurant_name,
        NVL(utilities, 0) as utilities,
        NVL(supplies, 0) as supplies,
        NVL(maintenance, 0) as maintenance,
        NVL(marketing, 0) as marketing,
        NVL(utilities, 0) + NVL(supplies, 0) + NVL(maintenance, 0) 
        + NVL(marketing, 0) as total_expenses
    FROM regularexpenses
    ORDER BY restaurant_name"""

    res = connection.execute(text(sql))
    results = res.fetchall()

    restaurants = [row[0] for row in results]
    utilities = [row[1] for row in results]
    supplies = [row[2] for row in results]
    maintenance = [row[3] for row in results]
    marketing = [row[4] for row in results]

    x = np.arange(len(restaurants))
    width = 0.2
    fig, ax = plt.subplots(figsize=(12, 6))

    rects1 = ax.bar(x - width * 1.5, utilities, width, label="Media", color="#2ecc71")
    rects2 = ax.bar(
        x - width / 2, supplies, width, label="Zaopatrzenie", color="#3498db"
    )
    rects3 = ax.bar(
        x + width / 2, maintenance, width, label="Konserwacja", color="#e74c3c"
    )
    rects4 = ax.bar(
        x + width * 1.5, marketing, width, label="Marketing", color="#f1c40f"
    )

    ax.set_ylabel("Wydatki (PLN)")
    ax.set_title("Wydatki miesięczne według kategorii")
    ax.set_xticks(x)
    ax.set_xticklabels(restaurants, rotation=45, ha="right")
    ax.legend()
    ax.grid(True, axis="y", linestyle="--", alpha=0.7)

    plt.tight_layout()

    plt.show()

import pandas as pd
def inventory_value_report(connection):
    
    res = connection.execute(text("SELECT DISTINCT item_name FROM inventory ORDER BY item_name"))
    items = [row[0] for row in res.fetchall()]
    items_str = ','.join(f"'{item}'" for item in items)
    
    pivot_query = f"""
    WITH inventory_values AS (
        SELECT 
            r.name as restaurant_name,
            i.item_name,
            i.quantity * i.price as item_value
        FROM restaurants r
        JOIN inventory i ON r.restaurant_id = i.restaurant_id
    )
    SELECT *
    FROM inventory_values
    PIVOT (
        SUM(item_value)
        FOR item_name IN ({items_str})
    )
    ORDER BY restaurant_name
    """
    print(pivot_query)
    res = connection.execute(text(pivot_query))
    
    columns = ['Restaurant'] + [desc for desc in items]
    df = pd.DataFrame(res.fetchall(), columns=columns)
    df.set_index('Restaurant', inplace=True)
    
    df['Total'] = df.sum(axis=1)
    
    for col in df.columns:
        df[col] = df[col].apply(lambda x: f"{x:,.2f} PLN")
    
    return df