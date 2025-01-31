CREATE OR REPLACE TRIGGER trg_validate_supplier_email
BEFORE INSERT OR UPDATE OF email ON suppliers
FOR EACH ROW
WHEN (NEW.email IS NOT NULL)
BEGIN
    :NEW.email := is_valid_email(:NEW.email);
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid email format for supplier. Error: ' || SQLERRM);
END;
/


CREATE OR REPLACE TRIGGER trg_validate_users_email
BEFORE INSERT OR UPDATE OF email ON users
FOR EACH ROW
WHEN (NEW.email IS NOT NULL)
BEGIN
    :NEW.email := is_valid_email(:NEW.email);
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid email format for User. Error: ' || SQLERRM);
END;
/

CREATE OR REPLACE TRIGGER trg_validate_customers_email
BEFORE INSERT OR UPDATE OF email ON customers
FOR EACH ROW
WHEN (NEW.email IS NOT NULL)
BEGIN
    :NEW.email := is_valid_email(:NEW.email);
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid email format for Customer. Error: ' || SQLERRM);
END;
/

CREATE OR REPLACE TRIGGER trg_validate_customers_phone
BEFORE INSERT OR UPDATE OF phone ON customers
FOR EACH ROW
WHEN (NEW.phone IS NOT NULL)
BEGIN
    :NEW.phone := is_valid_phone_number(:NEW.phone);
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Invalid phone number format for Customer. Error: ' || SQLERRM);
END;
/

CREATE OR REPLACE TRIGGER trg_validate_suppliers_phone
BEFORE INSERT OR UPDATE OF phone ON suppliers
FOR EACH ROW
WHEN (NEW.phone IS NOT NULL)
BEGIN
    :NEW.phone := is_valid_phone_number(:NEW.phone);
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Invalid phone number format for Customer. Error: ' || SQLERRM);
END;
/

CREATE OR REPLACE TRIGGER trg_validate_employees_phone
BEFORE INSERT OR UPDATE OF phone ON employees
FOR EACH ROW
WHEN (NEW.phone IS NOT NULL)
BEGIN
    :NEW.phone := is_valid_phone_number(:NEW.phone);
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Invalid phone number format for Customer. Error: ' || SQLERRM);
END;
/

CREATE OR REPLACE TRIGGER trg_validate_restaurants_phone
BEFORE INSERT OR UPDATE OF phone ON restaurants
FOR EACH ROW
WHEN (NEW.phone IS NOT NULL)
BEGIN
    :NEW.phone := is_valid_phone_number(:NEW.phone);
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Invalid phone number format for Customer. Error: ' || SQLERRM);
END;
/