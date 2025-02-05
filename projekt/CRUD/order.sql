-- Package Specification
create or replace package order_mgmt as
   function create_order (
      p_restaurant_id in orders.restaurant_id%type,
      p_customer_id   in orders.customer_id%type,
      p_table_number  in orders.table_number%type,
      p_order_type    in orders.order_type%type,
      p_order_status  in orders.order_status%type,
      p_payment_type  in orders.payment_method%type,
      p_menu_items    in sys.odcinumberlist,
      p_quantities    in sys.odcinumberlist
   ) return number;

   procedure create_order_proc (
      p_restaurant_id in orders.restaurant_id%type,
      p_customer_id   in orders.customer_id%type,
      p_table_number  in orders.table_number%type,
      p_order_type    in orders.order_type%type,
      p_order_status  in orders.order_status%type,
      p_payment_type  in orders.payment_method%type,
      p_menu_items    in sys.odcinumberlist,
      p_quantities    in sys.odcinumberlist
   );

   procedure delete_order (
      p_order_id in orders.order_id%type
   );

   procedure update_order_status (
      p_order_id   in orders.order_id%type,
      p_new_status in orders.order_status%type
   );
end order_mgmt;
/

-- Package Body
create or replace package body order_mgmt as
   function create_order (
      p_restaurant_id in orders.restaurant_id%type,
      p_customer_id   in orders.customer_id%type,
      p_table_number  in orders.table_number%type,
      p_order_type    in orders.order_type%type,
      p_order_status  in orders.order_status%type,
      p_payment_type  in orders.payment_method%type,
      p_menu_items    in sys.odcinumberlist,
      p_quantities    in sys.odcinumberlist
   ) return number as
      v_order_id    orders.order_id%type;
      v_total_price orders.total_price%type := 0;
      v_item_price  menu_items.price%type;
      v_available   menu_items.available%type;
   begin
      -- Your existing create_order function code here
      -- (Everything from the first FOR loop to the RETURN statement)
      -- Check if all menu items are available
      for i in 1..p_menu_items.count loop
         select available
           into v_available
           from menu_items
          where menu_item_id = p_menu_items(i);

         if v_available = 0 then
            raise_application_error(
               -20006,
               'Menu item '
               || p_menu_items(i)
               || ' is not available'
            );
         end if;
      end loop;
      
      -- This is workaround...
      select nvl(
         max(order_id),
         0
      ) + 1
        into v_order_id
        from orders;

      for i in 1..p_menu_items.count loop
         select price
           into v_item_price
           from menu_items
          where menu_item_id = p_menu_items(i);

         v_total_price := v_total_price + ( v_item_price * p_quantities(i) );
      end loop;

      insert into orders (
         order_id,
         restaurant_id,
         customer_id,
         table_number,
         order_type,
         order_status,
         total_price,
         payment_method
      ) values ( v_order_id,
                 p_restaurant_id,
                 p_customer_id,
                 p_table_number,
                 p_order_type,
                 p_order_status,
                 v_total_price,
                 p_payment_type );

      for i in 1..p_menu_items.count loop
         insert into order_items (
            order_item_id,
            order_id,
            menu_item_id,
            quantity,
            price
         ) values ( (
            select nvl(
               max(order_item_id),
               0
            ) + 1
              from order_items
         ),
                    v_order_id,
                    p_menu_items(i),
                    p_quantities(i),
                    (
                       select price
                         from menu_items
                        where menu_item_id = p_menu_items(i)
                    ) );
      end loop;

      commit;
      return v_order_id;
   exception
      when others then
         rollback;
         raise_application_error(
            -20001,
            'Error creating order: ' || sqlerrm
         );
         return null;
   end create_order;

   procedure create_order_proc (
      p_restaurant_id in orders.restaurant_id%type,
      p_customer_id   in orders.customer_id%type,
      p_table_number  in orders.table_number%type,
      p_order_type    in orders.order_type%type,
      p_order_status  in orders.order_status%type,
      p_payment_type  in orders.payment_method%type,
      p_menu_items    in sys.odcinumberlist,
      p_quantities    in sys.odcinumberlist
   ) as
      v_order_id number;
   begin
      v_order_id := create_order(
         p_restaurant_id,
         p_customer_id,
         p_table_number,
         p_order_type,
         p_order_status,
         p_payment_type,
         p_menu_items,
         p_quantities
      );
   end create_order_proc;

   procedure delete_order (
      p_order_id in orders.order_id%type
   ) as
   begin
      delete from order_items
       where order_id = p_order_id;
      delete from orders
       where order_id = p_order_id;
      commit;
   exception
      when others then
         rollback;
         raise_application_error(
            -20005,
            'Error deleting order: ' || sqlerrm
         );
   end delete_order;

   procedure update_order_status (
      p_order_id   in orders.order_id%type,
      p_new_status in orders.order_status%type
   ) as
   begin
      update orders
         set
         order_status = p_new_status
       where order_id = p_order_id;
      commit;
   exception
      when others then
         rollback;
         raise_application_error(
            -20003,
            'Error updating order status: ' || sqlerrm
         );
   end update_order_status;
end order_mgmt;
/



--TESTING v2
declare
   v_menu_items sys.odcinumberlist;
   v_quantities sys.odcinumberlist;
   v_order_id   number;
begin
   v_menu_items := sys.odcinumberlist(1003);
   v_quantities := sys.odcinumberlist(1);
   v_order_id := order_mgmt.create_order(
      p_restaurant_id => 1003,
      p_customer_id   => null,
      p_table_number  => 1,
      p_order_type    => 'dine-in',
      p_order_status  => 'Pending',
      p_menu_items    => v_menu_items,
      p_quantities    => v_quantities,
      p_payment_type  => 'Cash'
   );

   order_mgmt.update_order_status(
      p_order_id   => v_order_id,
      p_new_status => 'In Progress'
   );
end;
/

declare
   v_menu_items sys.odcinumberlist;
   v_quantities sys.odcinumberlist;
   v_order_id   number;
begin
   for i in 1000..1009 loop
      v_menu_items := sys.odcinumberlist(
         1013,
         1014,
         1003
      );
      v_quantities := sys.odcinumberlist(
         1,
         2,
         3
      );
      v_order_id := order_mgmt.create_order(
         p_restaurant_id => i,
         p_customer_id   => null,
         p_table_number  => 1,
         p_order_type    => 'dine-in',
         p_order_status  => 'Pending',
         p_menu_items    => v_menu_items,
         p_quantities    => v_quantities,
         p_payment_type  => 'Cash'
      );

      order_mgmt.update_order_status(
         p_order_id   => v_order_id,
         p_new_status => 'In Progress'
      );
   end loop;
end;
/