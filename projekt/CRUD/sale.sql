create or replace trigger generate_sale_on_order_complete after
   update of order_status on orders
   for each row
   when ( new.order_status = 'Completed' )
begin
   insert into sales (
      restaurant_id,
      order_id,
      customer_id,
      total_amount,
      payment_method
   ) values ( :new.restaurant_id,
              :new.order_id,
              :new.customer_id,
              :new.total_price,
              :new.payment_method );
exception
   when others then
      raise_application_error(
         -20007,
         'Error generating sale: ' || sqlerrm
      );
end;
/

declare
   v_order_id number;
begin
   update_order_status(
      p_order_id   => 5,
      p_new_status => 'Completed'
   );
end;