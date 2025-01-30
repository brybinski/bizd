-- Zad1.1
CREATE OR REPLACE FUNCTION get_job_title(p_job_id jobs.job_id%TYPE)
RETURN VARCHAR2
IS
    v_job_title jobs.job_title%TYPE;
BEGIN
    SELECT job_title INTO v_job_title
    FROM jobs
    WHERE job_id = p_job_id;
    
    RETURN v_job_title;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE( 'An error occurred: ' || SQLERRM);
END get_job_title;
/

SELECT get_job_title('SA_MAN') FROM dual;
/

-- Zad1.2
CREATE OR REPLACE FUNCTION get_annual_salary(p_employee_id employees.employee_id%TYPE)
RETURN NUMBER
IS
    v_salary employees.salary%TYPE;
    v_commission_pct employees.commission_pct%TYPE;
    v_annual_salary NUMBER;
BEGIN
    SELECT salary, commission_pct 
    INTO v_salary, v_commission_pct
    FROM employees
    WHERE employee_id = p_employee_id;
    
    v_annual_salary := v_salary * 12;
    
    IF v_commission_pct IS NOT NULL THEN
        v_annual_salary := v_annual_salary + (v_salary * v_commission_pct * 12);
    END IF;
    
    RETURN v_annual_salary;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE( 'An error occurred: ' || SQLERRM);
END get_annual_salary;
/

SELECT get_annual_salary(145) FROM dual;
/


-- Zad1.3
CREATE OR REPLACE FUNCTION format_phone_number(p_phone_number VARCHAR2)
RETURN VARCHAR2
IS
    v_country_code VARCHAR2(5);
    v_rest_number VARCHAR2(30);
BEGIN
    IF p_phone_number IS NULL THEN
        RETURN NULL;
    END IF;
    
    IF REGEXP_LIKE(p_phone_number, '^\+\d+') THEN
        v_country_code := REGEXP_SUBSTR(p_phone_number, '^\+(\d+)', 1, 1, NULL, 1);
        v_rest_number := REGEXP_SUBSTR(p_phone_number, '[ .,](.+)$', 1, 1, NULL, 1);
        RETURN '(+' || v_country_code || ') ' || v_rest_number;
    ELSE
        RETURN p_phone_number;
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error formatting phone number: ' || SQLERRM);
END format_phone_number;
/

SELECT format_phone_number('+48 515.123.4567') FROM dual;
SELECT format_phone_number('+48.515.123.4567') FROM dual;
SELECT format_phone_number('+48,515.123.4567') FROM dual;
SELECT format_phone_number('515.123.4567') FROM dual;

-- Zad1.4
CREATE OR REPLACE FUNCTION format_case(p_string VARCHAR2)
RETURN VARCHAR2
IS
    v_result VARCHAR2(4000);
BEGIN
    IF p_string IS NULL THEN
        RETURN NULL;
    END IF;
    
    IF LENGTH(p_string) = 1 THEN
        RETURN UPPER(p_string);
    END IF;
    
    v_result := UPPER(SUBSTR(p_string, 1, 1)) || 
                LOWER(SUBSTR(p_string, 2, LENGTH(p_string) - 2)) ||
                UPPER(SUBSTR(p_string, -1));
    
    RETURN v_result;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE( 'Error formatting string: ' || SQLERRM);
END format_case;
/

SELECT format_case('HELLO') FROM dual;
SELECT format_case('world') FROM dual;
SELECT format_case('a') FROM dual;
SELECT format_case('ab') FROM dual;
SELECT format_case(NULL) FROM dual;

-- Zad1.5
CREATE OR REPLACE FUNCTION pesel_to_date(p_pesel VARCHAR2)
RETURN VARCHAR2
IS
    v_year VARCHAR2(4);
    v_month NUMBER;
    v_day VARCHAR2(2);
    v_century NUMBER;
BEGIN
    IF p_pesel IS NULL OR LENGTH(p_pesel) != 11 THEN
        DBMS_OUTPUT.PUT_LINE( 'Invalid PESEL format');
    END IF;

    v_month := TO_NUMBER(SUBSTR(p_pesel, 3, 2));
    v_day := SUBSTR(p_pesel, 5, 2);
    
    IF v_month BETWEEN 1 AND 12 THEN
        v_century := 1900;
    ELSIF v_month BETWEEN 21 AND 32 THEN
        v_century := 2000;
        v_month := v_month - 20;
    ELSIF v_month BETWEEN 41 AND 52 THEN
        v_century := 2100;
        v_month := v_month - 40;
    ELSIF v_month BETWEEN 61 AND 72 THEN
        v_century := 2200;
        v_month := v_month - 60;
    ELSIF v_month BETWEEN 81 AND 92 THEN
        v_century := 1800;
        v_month := v_month - 80;
    END IF;
    
    v_year := v_century + TO_NUMBER(SUBSTR(p_pesel, 1, 2));
    
    RETURN v_year || '-' || 
           LPAD(v_month, 2, '0') || '-' || 
           v_day;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE( 'Error processing PESEL: ' || SQLERRM);
END pesel_to_date;
/

SELECT pesel_to_date('02271409862') FROM dual;
SELECT pesel_to_date('90090515836') FROM dual; 
SELECT pesel_to_date('00241400321') FROM dual; 

-- Zad1.6
CREATE OR REPLACE FUNCTION get_country_stats(p_country_name countries.country_name%TYPE)
RETURN VARCHAR2
IS
    v_emp_count NUMBER;
    v_dept_count NUMBER;
    v_country_exists NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_country_exists
    FROM countries
    WHERE country_name = p_country_name;
    
    IF v_country_exists = 0 THEN
        DBMS_OUTPUT.PUT_LINE( 'Country ' || p_country_name || ' does not exist');
    END IF;
    
    SELECT COUNT(DISTINCT e.employee_id), COUNT(DISTINCT d.department_id)
    INTO v_emp_count, v_dept_count
    FROM employees e
    RIGHT JOIN departments d ON e.department_id = d.department_id
    JOIN locations l ON d.location_id = l.location_id
    JOIN countries c ON l.country_id = c.country_id
    WHERE c.country_name = p_country_name;
    
    RETURN 'Employees: ' || v_emp_count || ', Departments: ' || v_dept_count;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error processing country stats: ' || SQLERRM);
END get_country_stats;
/

SELECT get_country_stats('United States of America') FROM dual;
SELECT get_country_stats('NonExistent') FROM dual;
/

-- Zad2.1
CREATE TABLE department_archive (
    department_id NUMBER,
    department_name VARCHAR2(30),
    close_date DATE,
    last_manager VARCHAR2(100)
);

CREATE OR REPLACE TRIGGER trg_department_archive
BEFORE DELETE ON departments
FOR EACH ROW
DECLARE
    v_manager_name VARCHAR2(100);
BEGIN
    BEGIN
        SELECT first_name || ' ' || last_name
        INTO v_manager_name
        FROM employees
        WHERE employee_id = :OLD.manager_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_manager_name := NULL;
    END;

    INSERT INTO department_archive (
        department_id,
        department_name,
        close_date,
        last_manager
    ) VALUES (
        :OLD.department_id,
        :OLD.department_name,
        SYSDATE,
        v_manager_name
    );
END;
/

-- UPDATE employees SET department_id = NULL WHERE department_id = 110;
-- DELETE FROM job_history WHERE department_id = 110;
-- DELETE FROM departments WHERE department_id = 110;
-- SELECT * FROM department_archive;

-- Zad2.2

CREATE TABLE thieves (
    violation_id NUMBER GENERATED ALWAYS AS IDENTITY,
    username VARCHAR2(30),
    attempt_date TIMESTAMP,
    employee_id NUMBER,
    attempted_salary NUMBER
);

CREATE OR REPLACE TRIGGER trg_validate_salary
BEFORE INSERT OR UPDATE OF salary ON employees
FOR EACH ROW
BEGIN
    IF :NEW.salary < 2000 OR :NEW.salary > 26000 THEN
        INSERT INTO thieves (
            username,
            attempt_date,
            employee_id,
            attempted_salary
        ) VALUES (
            USER,
            SYSTIMESTAMP,
            :NEW.employee_id,
            :NEW.salary
        );
        
        DBMS_OUTPUT.PUT_LINE(
            'Salary must be between 2000 and 26000. You are going to jail :D.');
    END IF;
END;
/

INSERT INTO employees (employee_id, first_name, last_name, salary) 
    VALUES (999, 'Test', 'User', 30000);

UPDATE employees SET salary = 100000 WHERE employee_id = 100;
SELECT * FROM thieves;

-- Zad2.3
-- sekwencja stworzona w labie 3
CREATE OR REPLACE TRIGGER trg_emp_id_autoincrement
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    IF :NEW.employee_id IS NULL THEN
        :NEW.employee_id := emp_id_seq.NEXTVAL;
    END IF;
END;
/

-- INSERT INTO employees (first_name, last_name, email, hire_date, job_id) 
-- VALUES ('Test', 'User', 'test@email.com', SYSDATE, 'IT_PROG');
-- SELECT * FROM employees WHERE first_name = 'Test';

-- Zad2.4
CREATE OR REPLACE TRIGGER trg_protect_job_grades
BEFORE INSERT OR UPDATE OR DELETE ON job_grades
BEGIN
    RAISE_APPLICATION_ERROR(-20008, 'Operations on JOB_GRADES table are not allowed');
END;
/
INSERT INTO job_grades VALUES ('X', 1000, 2000);
UPDATE job_grades SET min_salary = 2000 WHERE min_salary = 3000 ;
DELETE FROM job_grades WHERE min_salary = 3000;

-- Zad3.1
-- Przykład bo i tak tu usuwam wszystko
-- CREATE OR REPLACE PACKAGE BODY emp_pkg IS
--     FUNCTION get_job_title(p_job_id jobs.job_id%TYPE)
--     RETURN VARCHAR2;
--     BEGIN 
--         -- kod funkcji
--     END get_job_title;
-- END emp_pkg;
