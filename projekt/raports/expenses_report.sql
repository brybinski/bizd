with regularexpenses as (
   select *
     from (
      select r.name as restaurant_name,
             e.category,
             e.amount
        from expenses e
        join restaurants r
      on e.restaurant_id = r.restaurant_id
       where e.expense_date BETWEEN add_months(
      trunc(sysdate),
      :from_mon
   ) AND add_months(
      trunc(sysdate),
      :to_mon)
   ) pivot (
      sum(amount)
      for category
      in ( 'Media' as utilities,'Zaopatrzenie' as supplies,'Konserwacja' as maintenance,'Marketing' as marketing )
   )
)
select restaurant_name,
       nvl(
          utilities,
          0
       ) as utilities,
       nvl(
          supplies,
          0
       ) as supplies,
       nvl(
          maintenance,
          0
       ) as maintenance,
       nvl(
          marketing,
          0
       ) as marketing,
       nvl(
          utilities,
          0
       ) + nvl(
          supplies,
          0
       ) + nvl(
          maintenance,
          0
       ) + nvl(
          marketing,
          0
       ) as total_expenses
  from regularexpenses
 order by restaurant_name;

--restaurant groupped employee salaries
select r.name as restaurant_name,
       nvl(
          sum(e.salary / 160 * s.total_hours),
          0
       ) as total_salary_cost
  from restaurants r
  left join employees e
on r.restaurant_id = e.restaurant_id
  left join (
   select employee_id,
          sum(shift_duration) as total_hours
     from shifts
    where  shift_start_time BETWEEN add_months(
      trunc(sysdate),
      :from_mon
   ) AND add_months(
      trunc(sysdate),
      :to_mon)
    group by employee_id
) s
on e.employee_id = s.employee_id
 group by r.name
 order by r.name;


--employee salaries
select e.name as employee_name,
       e.position,
       nvl(
          s.total_hours,
          0
       ) as hours_worked,
       e.salary as base_salary,
       nvl(
          e.salary / 160 * s.total_hours,
          0
       ) as actual_salary_cost
  from employees e
  left join (
   select employee_id,
          sum(shift_duration) as total_hours
     from shifts
    where shift_start_time BETWEEN add_months(
      trunc(sysdate),
      :from_mon
   ) AND add_months(
      trunc(sysdate),
      :to_mon)
    group by employee_id
) s
on e.employee_id = s.employee_id
 where e.restaurant_id = (
   select restaurant_id
     from restaurants
    where restaurant_id = :restaurant_id
)
 order by e.name;

--inventory report restaurant
with inventory_values as (
   select r.name as restaurant_name,
          i.item_name,
          i.quantity * i.price as item_value
     from restaurants r
     join inventory i
   on r.restaurant_id = i.restaurant_id
)
select *
  from inventory_values pivot (
   sum(item_value)
   for item_name
   in ( 'Dorsz',
   'Filet z Tuńczyka',
   'Halibut',
   'Kawior',
   'Krewetki Mrożone',
   'Łosoś Atlantycki',
   'Makrela Wędzona',
   'Okoń Morski',
   'Paluszki Rybne',
   'Sardynki w Puszce' )
)
 order by restaurant_name;


--inventory report across suppliers
with supplier_stats as (
   select r.name as restaurant_name,
          s.name as supplier_name,
          count(i.item_name) as items_count,
          sum(i.quantity * i.price) as total_value,
          round(
             avg(i.price),
             2
          ) as avg_item_price
     from restaurants r
     join inventory i
   on r.restaurant_id = i.restaurant_id
     join suppliers s
   on i.supplier_id = s.supplier_id
    group by r.name,
             s.name
)
select restaurant_name,
       supplier_name,
       items_count,
       avg_item_price || ' PLN' as avg_price,
       total_value || ' PLN' as total_value
  from supplier_stats
 order by restaurant_name,
          total_value desc;


select r.name as restaurant_name,
       nvl(
          sum(s.total_amount),
          0
       )
       || ' PLN' as total_sales,
       nvl(
          count(s.sale_id),
          0
       ) as total_orders,
       case
          when count(s.sale_id) > 0 then
             round(
                sum(s.total_amount) / count(s.sale_id),
                2
             )
             || ' PLN'
          else
             '0.00 PLN'
       end as avg_order_value
  from restaurants r
  left join sales s
on r.restaurant_id = s.restaurant_id
 where s.date_time BETWEEN add_months(
      trunc(sysdate),
      :from_mon
   ) AND add_months(
      trunc(sysdate),
      :to_mon)


 group by r.name
 order by r.name;