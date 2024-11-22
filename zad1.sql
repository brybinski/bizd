
CREATE TABLE REGIONS (
    region_id NUMBER PRIMARY KEY,
    region_name VARCHAR2(100)
);

CREATE TABLE COUNTRIES (
    country_id CHAR(2) PRIMARY KEY,
    country_name VARCHAR2(100)
);
ALTER TABLE COUNTRIES ADD (region_id NUMBER);
ALTER TABLE COUNTRIES ADD CONSTRAINT fk_region FOREIGN KEY (region_id) REFERENCES REGIONS(region_id);

CREATE TABLE LOCATIONS (
    location_id NUMBER PRIMARY KEY,
    postal_code VARCHAR2(100),
    city VARCHAR2(100) NOT NULL,
    state_province VARCHAR2(100),
    country_id CHAR(2),
    CONSTRAINT fk_country FOREIGN KEY (country_id) REFERENCES COUNTRIES(country_id)
);

ALTER TABLE	LOCATIONS ADD (street_address VARCHAR2(100));

CREATE TABLE DEPARTMENTS (
    department_id NUMBER PRIMARY KEY,
    department_name VARCHAR2(100) NOT NULL,
    manager_id NUMBER,
    location_id NUMBER,
    CONSTRAINT fk_location FOREIGN KEY (location_id) REFERENCES LOCATIONS(location_id)
);

CREATE TABLE JOBS (
    job_id VARCHAR2(10) PRIMARY KEY,
    job_title VARCHAR2(100) NOT NULL,
    min_salary NUMBER,
    max_salary NUMBER,
    CONSTRAINT chk_salary CHECK (min_salary <= max_salary AND min_salary >= 2000)
);

CREATE TABLE EMPLOYEES (
    employee_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(100),
    last_name VARCHAR2(100) NOT NULL,
    email VARCHAR2(254) UNIQUE NOT NULL,
    phone_number VARCHAR2(11),
    hire_date DATE NOT NULL,
    job_id VARCHAR2(10),
    salary NUMBER,
    department_id NUMBER,
	CONSTRAINT fk_department FOREIGN KEY (department_id) REFERENCES DEPARTMENTS(department_id),
    CONSTRAINT fk_job FOREIGN KEY (job_id) REFERENCES JOBS(job_id)
);

ALTER TABLE EMPLOYEES ADD (commission_pct NUMBER, manager_id NUMBER);

ALTER TABLE EMPLOYEES ADD CONSTRAINT fk_manager FOREIGN KEY (manager_id) REFERENCES EMPLOYEES(employee_id);
ALTER TABLE DEPARTMENTS ADD CONSTRAINT fk_dept_manager FOREIGN KEY (manager_id) REFERENCES EMPLOYEES(employee_id);



CREATE TABLE JOB_HISTORY (
    employee_id NUMBER,
    start_date DATE NOT NULL,
    end_date DATE,
    job_id VARCHAR2(10),
    department_id NUMBER,
    CONSTRAINT pk_job_history PRIMARY KEY (employee_id, start_date),
    CONSTRAINT fk_job_history_employee FOREIGN KEY (employee_id) REFERENCES EMPLOYEES(employee_id),
    CONSTRAINT fk_job_history_job FOREIGN KEY (job_id) REFERENCES JOBS(job_id),
    CONSTRAINT fk_job_history_department FOREIGN KEY (department_id) REFERENCES DEPARTMENTS(department_id)
);

SELECT table_name FROM user_tables;

--COMMIT;
--
--DROP TABLE REGIONS CASCADE CONSTRAINTS;
--SELECT table_name FROM user_tables;
--
--ROLLBACK;
--SELECT table_name FROM user_tables;

-- Tabeli REGIONS nie da się odzyskać ponieważ to operacja DDL a nie DML + wyłączona jest funkcja FLASHBACK
