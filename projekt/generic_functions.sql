CREATE OR REPLACE FUNCTION is_valid_phone_number(p_phone_number IN VARCHAR)
RETURN VARCHAR
IS
BEGIN
    IF p_phone_number IS NULL OR LENGTH(TRIM(p_phone_number)) = 0 THEN
        RAISE_APPLICATION_ERROR(-20911, 'Invalid phone number');
    END IF;
    
    DECLARE
        v_cleaned_number VARCHAR(20);
    BEGIN
        v_cleaned_number := REGEXP_REPLACE(p_phone_number, '[^0-9]', '');

        IF LENGTH(v_cleaned_number) BETWEEN 9 AND 15 THEN
            IF REGEXP_LIKE(v_cleaned_number, '^[0-9]+$') THEN
                RETURN v_cleaned_number;
            END IF;
        END IF;
    END;
    RAISE_APPLICATION_ERROR(-20911, 'Invalid phone number');

END is_valid_phone_number;
/

CREATE OR REPLACE FUNCTION is_valid_email(p_email IN VARCHAR)
RETURN VARCHAR
IS
BEGIN
    IF p_email IS NULL OR LENGTH(TRIM(p_email)) = 0 THEN
        RAISE_APPLICATION_ERROR(-20912, 'Invalid email address');
    END IF;
    
    IF REGEXP_LIKE(p_email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
        RETURN LOWER(TRIM(p_email));
    END IF;
    
    RAISE_APPLICATION_ERROR(-20912, 'Invalid email address');
END is_valid_email;
/

DECLARE
    phone_number VARCHAR(20);
BEGIN
    phone_number := is_valid_phone_number('123-456-7890');
    IF phone_number IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Valid phone number: ' || phone_number);
    END IF;
END;
/

DECLARE
    email VARCHAR(360);
BEGIN
    email := is_valid_email('valid@example.com');
    IF email IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Valid email: ' || email);
    END IF;
END;
/

