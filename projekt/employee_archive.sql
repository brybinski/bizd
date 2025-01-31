CREATE OR REPLACE FUNCTION archive_and_delete_employee(
    p_employee_id IN INT,
    p_termination_reason IN VARCHAR
) RETURN BOOLEAN IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_total_hours DECIMAL(8,2);
BEGIN
    SELECT NVL(SUM(shift_duration), 0)
    INTO v_total_hours
    FROM shifts
    WHERE employee_id = p_employee_id;
    
    -- Insert into archive
    INSERT INTO employee_archive (
        employee_id,
        user_id,
        restaurant_id,
        name,
        position,
        salary,
        phone,
        hire_date,
        worked_hours,
        termination_date,
        termination_reason
    )
    SELECT 
        e.employee_id,
        e.user_id,
        e.restaurant_id,
        e.name,
        e.position,
        e.salary,
        e.phone,
        e.hire_date,
        v_total_hours,
        CURRENT_TIMESTAMP,
        p_termination_reason
    FROM employees e
    WHERE e.employee_id = p_employee_id;
    
    DELETE FROM shifts WHERE employee_id = p_employee_id;
    DELETE FROM employees WHERE employee_id = p_employee_id;
    COMMIT;
    RETURN TRUE;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        RETURN FALSE;
END;
/

DECLARE
    employee_to_get_rekt INT;
    reason VARCHAR(255);
    v_succ BOOLEAN;
BEGIN
    employee_to_get_rekt := 1001;
    reason := 'LuLz';

    v_succ := archive_and_delete_employee(employee_to_get_rekt, reason);
END;
/

DELETE FROM shifts WHERE employee_id = 1000;
DELETE FROM employees WHERE employee_id = 1000;