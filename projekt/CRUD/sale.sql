CREATE OR REPLACE TRIGGER generate_sale_on_order_complete
AFTER UPDATE OF order_status ON orders
FOR EACH ROW
WHEN (NEW.order_status = 'Completed')
BEGIN
    INSERT INTO sales (
        restaurant_id,
        order_id,
        customer_id,
        total_amount,
        payment_method
    ) VALUES (
        :NEW.restaurant_id,
        :NEW.order_id,
        :NEW.customer_id,
        :NEW.total_price,
        :NEW.payment_method
);
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20007, 'Error generating sale: ' || SQLERRM);
END;
/

declare
   v_order_id   number;
BEGIN
    update_order_status(
      p_order_id   => 5,
      p_new_status => 'Completed'
   );
END;