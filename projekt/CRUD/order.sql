-- Package Specification
CREATE OR REPLACE PACKAGE order_mgmt AS
   -- Function and procedure declarations
   FUNCTION create_order (
      p_restaurant_id IN orders.restaurant_id%TYPE,
      p_customer_id   IN orders.customer_id%TYPE,
      p_table_number  IN orders.table_number%TYPE,
      p_order_type    IN orders.order_type%TYPE,
      p_order_status  IN orders.order_status%TYPE,
      p_payment_type  IN orders.payment_method%TYPE,
      p_menu_items    IN sys.odcinumberlist,
      p_quantities    IN sys.odcinumberlist
   ) RETURN NUMBER;

   PROCEDURE create_order_proc (
      p_restaurant_id IN orders.restaurant_id%TYPE,
      p_customer_id   IN orders.customer_id%TYPE,
      p_table_number  IN orders.table_number%TYPE,
      p_order_type    IN orders.order_type%TYPE,
      p_order_status  IN orders.order_status%TYPE,
      p_payment_type  IN orders.payment_method%TYPE,
      p_menu_items    IN sys.odcinumberlist,
      p_quantities    IN sys.odcinumberlist
   );

   PROCEDURE delete_order (
      p_order_id IN orders.order_id%TYPE
   );

   PROCEDURE update_order_status (
      p_order_id   IN orders.order_id%TYPE,
      p_new_status IN orders.order_status%TYPE
   );
END order_mgmt;
/

-- Package Body
CREATE OR REPLACE PACKAGE BODY order_mgmt AS
   FUNCTION create_order (
      p_restaurant_id IN orders.restaurant_id%TYPE,
      p_customer_id   IN orders.customer_id%TYPE,
      p_table_number  IN orders.table_number%TYPE,
      p_order_type    IN orders.order_type%TYPE,
      p_order_status  IN orders.order_status%TYPE,
      p_payment_type  IN orders.payment_method%TYPE,
      p_menu_items    IN sys.odcinumberlist,
      p_quantities    IN sys.odcinumberlist
   ) RETURN NUMBER AS
      v_order_id    orders.order_id%TYPE;
      v_total_price orders.total_price%TYPE := 0;
      v_item_price  menu_items.price%TYPE;
      v_available   menu_items.available%TYPE;
   BEGIN
      -- Your existing create_order function code here
      -- (Everything from the first FOR loop to the RETURN statement)
      -- Check if all menu items are available
      FOR i IN 1..p_menu_items.count LOOP
         SELECT available
           INTO v_available
           FROM menu_items
          WHERE menu_item_id = p_menu_items(i);
          
         IF v_available = 0 THEN
            raise_application_error(-20006, 'Menu item ' || p_menu_items(i) || ' is not available');
         END IF;
      END LOOP;

      SELECT NVL(MAX(order_id), 0) + 1
        INTO v_order_id
        FROM orders;

      FOR i IN 1..p_menu_items.count LOOP
         SELECT price
           INTO v_item_price
           FROM menu_items
          WHERE menu_item_id = p_menu_items(i);

         v_total_price := v_total_price + (v_item_price * p_quantities(i));
      END LOOP;

      INSERT INTO orders (
         order_id,
         restaurant_id,
         customer_id,
         table_number,
         order_type,
         order_status,
         total_price,
         payment_method
      ) VALUES (
         v_order_id,
         p_restaurant_id,
         p_customer_id,
         p_table_number,
         p_order_type,
         p_order_status,
         v_total_price, 
         p_payment_type
      );

      FOR i IN 1..p_menu_items.count LOOP
         INSERT INTO order_items (
            order_item_id,
            order_id,
            menu_item_id,
            quantity,
            price
         ) VALUES (
            (SELECT NVL(MAX(order_item_id), 0) + 1 FROM order_items),
            v_order_id,
            p_menu_items(i),
            p_quantities(i),
            (SELECT price FROM menu_items WHERE menu_item_id = p_menu_items(i))
         );
      END LOOP;

      COMMIT;
      RETURN v_order_id;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         raise_application_error(-20001, 'Error creating order: ' || SQLERRM);
         RETURN NULL;
   END create_order;

   PROCEDURE create_order_proc (
      p_restaurant_id IN orders.restaurant_id%TYPE,
      p_customer_id   IN orders.customer_id%TYPE,
      p_table_number  IN orders.table_number%TYPE,
      p_order_type    IN orders.order_type%TYPE,
      p_order_status  IN orders.order_status%TYPE,
      p_payment_type  IN orders.payment_method%TYPE,
      p_menu_items    IN sys.odcinumberlist,
      p_quantities    IN sys.odcinumberlist
   ) AS
      v_order_id NUMBER;
   BEGIN
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
   END create_order_proc;

   PROCEDURE delete_order (
      p_order_id IN orders.order_id%TYPE
   ) AS
   BEGIN
      DELETE FROM order_items WHERE order_id = p_order_id;
      DELETE FROM orders WHERE order_id = p_order_id;
      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         raise_application_error(-20005, 'Error deleting order: ' || SQLERRM);
   END delete_order;

   PROCEDURE update_order_status (
      p_order_id   IN orders.order_id%TYPE,
      p_new_status IN orders.order_status%TYPE
   ) AS
   BEGIN
      UPDATE orders
         SET order_status = p_new_status
       WHERE order_id = p_order_id;
      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         raise_application_error(-20003, 'Error updating order status: ' || SQLERRM);
   END update_order_status;
END order_mgmt;
/



--TESTING v2
declare
   v_menu_items sys.odcinumberlist;
   v_quantities sys.odcinumberlist;
   v_order_id   number;
begin
   v_menu_items := sys.odcinumberlist(
      1003
   );
   v_quantities := sys.odcinumberlist(
      1
   );
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

DECLARE
   v_menu_items sys.odcinumberlist;
   v_quantities sys.odcinumberlist;
   v_order_id   number;
BEGIN
   FOR i IN 1000..1009 LOOP
      v_menu_items := sys.odcinumberlist(1013,1014,1003);
      v_quantities := sys.odcinumberlist(1,2,3);
      
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
   END LOOP;
END;
/

