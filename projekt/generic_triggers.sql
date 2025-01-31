CREATE OR REPLACE TRIGGER trg_protect_roles
BEFORE INSERT OR UPDATE OR DELETE ON roles
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION; -- ale się z tym namęczyłem xd
BEGIN
    INSERT INTO logs ( log_username, operation) VALUES (user ,  'INSERT/UPDATE/DELETE Operations on Role table are not allowed');
    COMMIT;
    RAISE_APPLICATION_ERROR(-20008, ' Operations on Role table are not allowed');
END;
/

INSERT INTO roles (role_name) VALUES ('X');

INSERT INTO logs ( log_username, operation) VALUES (user ,  'Operations on Role table are not allowed');

CREATE OR REPLACE TRIGGER trg_audit_users
BEFORE UPDATE ON users
FOR EACH ROW
BEGIN
    INSERT INTO logs (
        log_username, 
        operation
    ) 
    VALUES (
        user,
        'UPDATE Users - Old values: [Username: ' || :OLD.username || 
        ', Email: ' || :OLD.email || 
        ', Role: ' || :OLD.role_id || 
        '] New values: [Username: ' || :NEW.username || 
        ', Email: ' || :NEW.email || 
        ', Role: ' || :NEW.role_id || ']'
    );
END;
/


CREATE OR REPLACE TRIGGER trg_insert_users
BEFORE INSERT ON users
FOR EACH ROW
BEGIN
    INSERT INTO logs (
        log_username, 
        operation
    ) 
    VALUES (
        user,
        'INSERT Users: [Username: ' || :NEW.username || 
        ', Email: ' || :NEW.email || 
        ', Role: ' || :NEW.role_id || ']'
    );
END;
/

CREATE OR REPLACE TRIGGER trg_delete_users
BEFORE DELETE ON users
FOR EACH ROW
BEGIN
    INSERT INTO logs (
        log_username, 
        operation
    ) 
    VALUES (
        user,
        'DELETE users: [Username: ' || :NEW.username || 
        ', Email: ' || :NEW.email || 
        ', Role: ' || :NEW.role_id || ']'
    );
END;
/

CREATE OR REPLACE TRIGGER trg_audit_employees
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
    INSERT INTO logs (
        log_username, 
        operation
    ) 
    VALUES (
        user,
        'UPDATE Employee - Old values: [Name: ' || :OLD.name || 
        ', Position: ' || :OLD.position ||
        ', Salary: ' || :OLD.salary ||
        ', Phone: ' || :OLD.phone ||
        ', Restaurant: ' || :OLD.restaurant_id ||
        '] New values: [Name: ' || :NEW.name || 
        ', Position: ' || :NEW.position ||
        ', Salary: ' || :NEW.salary ||
        ', Phone: ' || :NEW.phone ||
        ', Restaurant: ' || :NEW.restaurant_id || ']'
    );
END;
/

CREATE OR REPLACE TRIGGER trg_insert_employees
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    INSERT INTO logs (
        log_username, 
        operation
    ) 
    VALUES (
        user,
        'INSERT Employee: [Name: ' || :NEW.name || 
        ', Position: ' || :NEW.position ||
        ', Salary: ' || :NEW.salary ||
        ', Phone: ' || :NEW.phone ||
        ', Restaurant: ' || :NEW.restaurant_id || ']'
    );
END;
/

CREATE OR REPLACE TRIGGER trg_delete_employees
BEFORE DELETE ON employees
FOR EACH ROW
BEGIN
    INSERT INTO logs (
        log_username, 
        operation
    ) 
    VALUES (
        user,
        'DELETE Employee: [Name: ' || :OLD.name || 
        ', Position: ' || :OLD.position ||
        ', Salary: ' || :OLD.salary ||
        ', Phone: ' || :OLD.phone ||
        ', Restaurant: ' || :OLD.restaurant_id || ']'
    );
END;
/
