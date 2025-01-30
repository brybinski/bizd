-- -- Zad1
 DECLARE
     numer_max NUMBER;
     nazwa_dep departments.department_name%TYPE := 'EDUCATION';
 BEGIN
     SELECT MAX(department_id)
     INTO numer_max
     FROM departments;
    
     DBMS_OUTPUT.PUT_LINE('Maksymalny numer departamentu: ' || numer_max);
    
     INSERT INTO departments (department_id, department_name)
     VALUES (numer_max + 10, nazwa_dep);
    
     COMMIT;
 END;
/

 -- Zad2
 DECLARE
     numer_max NUMBER;
     nazwa_dep departments.department_name%TYPE := 'EDUCATION';
 BEGIN
     SELECT MAX(department_id)
     INTO numer_max
     FROM departments;
    
     DBMS_OUTPUT.PUT_LINE('Maksymalny numer departamentu: ' || numer_max);
    
     INSERT INTO departments (department_id, department_name)
     VALUES (numer_max + 10, nazwa_dep);
    
     UPDATE departments 
     SET location_id = 3000
     WHERE department_id = numer_max + 10;
    
     COMMIT;
 END;
 /

 -- Zad3
 CREATE TABLE nowa (
     liczba VARCHAR2(2)
 );

 DECLARE
     i NUMBER;
 BEGIN
     FOR i IN 1..10 LOOP
         IF i != 4 AND i != 6 THEN
             INSERT INTO nowa (liczba)
             VALUES (TO_CHAR(i));
         END IF;
     END LOOP;
    
     COMMIT;
 END;
 /

 -- Zad4
 DECLARE
     kraj_record countries%ROWTYPE;
 BEGIN
     SELECT *
     INTO kraj_record
     FROM countries
     WHERE country_id = 'CA';
    
     DBMS_OUTPUT.PUT_LINE('Nazwa kraju: ' || kraj_record.country_name);
     DBMS_OUTPUT.PUT_LINE('Region ID: ' || kraj_record.region_id);
 END;
 /

 --Zad 5
 DECLARE
     CURSOR emp_cur IS
         SELECT salary, last_name
         FROM employees
         WHERE department_id = 50;
    
     v_salary employees.salary%TYPE;
     v_lastname employees.last_name%TYPE;
 BEGIN
     OPEN emp_cur;
     LOOP
         FETCH emp_cur INTO v_salary, v_lastname;
         EXIT WHEN emp_cur%NOTFOUND;
        
         IF v_salary > 3100 THEN
             DBMS_OUTPUT.PUT_LINE(v_lastname || ' - nie dawać podwyżki');
         ELSE
             DBMS_OUTPUT.PUT_LINE(v_lastname || ' - dać podwyżkę');
         END IF;
     END LOOP;
     CLOSE emp_cur;
 END;
 /

 -- Zad6
 DECLARE
     CURSOR emp_cur(p_min_sal NUMBER, p_max_sal NUMBER, p_name_pattern VARCHAR2) IS
         SELECT salary, first_name, last_name
         FROM employees
         WHERE salary BETWEEN p_min_sal AND p_max_sal
         AND UPPER(first_name) LIKE '%' || UPPER(p_name_pattern) || '%';
    
     v_salary employees.salary%TYPE;
     v_firstname employees.first_name%TYPE;
     v_lastname employees.last_name%TYPE;
 BEGIN
     DBMS_OUTPUT.PUT_LINE('Pracownicy z pensją 1000-5000 i literą "a" w imieniu:');
     FOR emp_rec IN emp_cur(1000, 5000, 'a') LOOP
         DBMS_OUTPUT.PUT_LINE(emp_rec.first_name || ' ' || emp_rec.last_name || ': ' || emp_rec.salary);
     END LOOP;
    
     DBMS_OUTPUT.PUT_LINE('Pracownicy z pensją 5000-20000 i literą "u" w imieniu:');
     FOR emp_rec IN emp_cur(5000, 20000, 'u') LOOP
         DBMS_OUTPUT.PUT_LINE(emp_rec.first_name || ' ' || emp_rec.last_name || ': ' || emp_rec.salary);
     END LOOP;
 END;
 /

 -- Zad7 a
 CREATE OR REPLACE PROCEDURE add_job (
     p_job_id IN jobs.job_id%TYPE,
     p_job_title IN jobs.job_title%TYPE
 ) IS
 BEGIN
     INSERT INTO jobs (job_id, job_title)
     VALUES (p_job_id, p_job_title);
     COMMIT;
 EXCEPTION
     WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
         ROLLBACK;
 END add_job;
 /

 -- Zad7 b
 CREATE OR REPLACE PROCEDURE update_job_title (
     p_job_id IN jobs.job_id%TYPE,
     p_new_title IN jobs.job_title%TYPE
 ) IS
     no_job_updated EXCEPTION;
     v_rows_updated NUMBER;
 BEGIN
     UPDATE jobs 
     SET job_title = p_new_title
     WHERE job_id = p_job_id;
    
     v_rows_updated := SQL%ROWCOUNT;
    
     IF v_rows_updated = 0 THEN
         RAISE no_job_updated;
     END IF;
    
     COMMIT;
     DBMS_OUTPUT.PUT_LINE('Job title updated successfully');
    
 EXCEPTION
     WHEN no_job_updated THEN
         DBMS_OUTPUT.PUT_LINE('Error: No job found with ID ' || p_job_id);
         ROLLBACK;
     WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
         ROLLBACK;
 END update_job_title;
 /

 BEGIN
     update_job_title('AD_PRES', 'Company President');
     update_job_title('INVALID_ID', 'Test Title');
 END;
 /

 -- Zad7 c
 CREATE OR REPLACE PROCEDURE delete_job(
     p_job_id IN jobs.job_id%TYPE
 )
 IS
     no_job_deleted EXCEPTION;
     v_rows_deleted NUMBER;
 BEGIN
     DELETE FROM jobs 
     WHERE job_id = p_job_id;
    
     v_rows_deleted := SQL%ROWCOUNT;
    
     IF v_rows_deleted = 0 THEN
         RAISE no_job_deleted;
     END IF;
    
     COMMIT;
     DBMS_OUTPUT.PUT_LINE('Job deleted successfully');
    
 EXCEPTION
     WHEN no_job_deleted THEN
         DBMS_OUTPUT.PUT_LINE('Error: No job found with ID ' || p_job_id);
         ROLLBACK;
     WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
         ROLLBACK;
 END delete_job;
 /

 -- Zad7 d
 CREATE OR REPLACE PROCEDURE get_employee_details(
     p_employee_id IN employees.employee_id%TYPE,
     p_salary OUT employees.salary%TYPE,
     p_last_name OUT employees.last_name%TYPE
 )
 IS
 BEGIN
     SELECT salary, last_name
     INTO p_salary, p_last_name
     FROM employees
     WHERE employee_id = p_employee_id;
    
     DBMS_OUTPUT.PUT_LINE('Employee details retrieved successfully');
    
 EXCEPTION
     WHEN NO_DATA_FOUND THEN
         DBMS_OUTPUT.PUT_LINE('Error: No employee found with ID ' || p_employee_id);
         p_salary := NULL;
         p_last_name := NULL;
     WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
         p_salary := NULL;
         p_last_name := NULL;
 END get_employee_details;
 /

 -- Zad7 e
 CREATE SEQUENCE emp_id_seq
 START WITH 1000 INCREMENT BY 1;
 /

 CREATE OR REPLACE PROCEDURE add_employee(
     p_last_name IN employees.last_name%TYPE,
     p_email IN employees.email%TYPE,
     p_hire_date IN employees.hire_date%TYPE DEFAULT SYSDATE,
     p_job_id IN employees.job_id%TYPE,
     p_first_name IN employees.first_name%TYPE DEFAULT NULL,
     p_phone_number IN employees.phone_number%TYPE DEFAULT NULL,
     p_salary IN employees.salary%TYPE DEFAULT 1000,
     p_commission_pct IN employees.commission_pct%TYPE DEFAULT NULL,
     p_manager_id IN employees.manager_id%TYPE DEFAULT NULL,
     p_department_id IN employees.department_id%TYPE DEFAULT NULL
 )
 IS
     salary_too_high EXCEPTION;
 BEGIN
     IF p_salary > 20000 THEN
         RAISE salary_too_high;
     END IF;

     INSERT INTO employees (
         employee_id,
         first_name,
         last_name,
         email,
         phone_number,
         hire_date,
         job_id,
         salary,
         commission_pct,
         manager_id,
         department_id
     ) VALUES (
         emp_id_seq.NEXTVAL,
         p_first_name,
         p_last_name,
         p_email,
         p_phone_number,
         p_hire_date,
         p_job_id,
         p_salary,
         p_commission_pct,
         p_manager_id,
         p_department_id
     );

     COMMIT;
     DBMS_OUTPUT.PUT_LINE('Employee added successfully');

 EXCEPTION
     WHEN salary_too_high THEN
         DBMS_OUTPUT.PUT_LINE('Error: Salary cannot exceed 20000');
         ROLLBACK;
     WHEN DUP_VAL_ON_INDEX THEN
         DBMS_OUTPUT.PUT_LINE('Error: Duplicate email address');
         ROLLBACK;
     WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
         ROLLBACK;
 END add_employee;
 /