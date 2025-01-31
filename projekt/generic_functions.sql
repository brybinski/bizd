create or replace function is_valid_phone_number (
   p_phone_number in varchar
) return varchar is
begin
   if p_phone_number is null
   or length(trim(p_phone_number)) = 0 then
      raise_application_error(
         -20911,
         'Invalid phone number'
      );
   end if;

   declare
      v_cleaned_number varchar(20);
   begin
      v_cleaned_number := regexp_replace(
         p_phone_number,
         '[^0-9]',
         ''
      );
      if length(v_cleaned_number) between 9 and 15 then
         if regexp_like(
            v_cleaned_number,
            '^[0-9]+$'
         ) then
            return v_cleaned_number;
         end if;
      end if;
   end;
   raise_application_error(
      -20911,
      'Invalid phone number'
   );
end is_valid_phone_number;
/

create or replace function is_valid_email (
   p_email in varchar
) return varchar is
begin
   if p_email is null
   or length(trim(p_email)) = 0 then
      raise_application_error(
         -20912,
         'Invalid email address'
      );
   end if;

   if regexp_like(
      p_email,
      '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
   ) then
      return lower(trim(p_email));
   end if;

   raise_application_error(
      -20912,
      'Invalid email address'
   );
end is_valid_email;
/

declare
   phone_number varchar(20);
begin
   phone_number := is_valid_phone_number('123-456-7890');
   if phone_number is not null then
      dbms_output.put_line('Valid phone number: ' || phone_number);
   end if;
end;
/

declare
   email varchar(360);
begin
   email := is_valid_email('valid@example.com');
   if email is not null then
      dbms_output.put_line('Valid email: ' || email);
   end if;
end;
/