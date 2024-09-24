SET SERVEROUTPUT ON
SET linesize 200
SET pagesize 100
cl scr

COLUMN ID HEADING 'NO' FORMAT 99
COLUMN user_id HEADING 'User' FORMAT A8
COLUMN edit_date HEADING 'Edited On' FORMAT A11
COLUMN staff_id HEADING 'Staff ID' FORMAT A8
COLUMN staff_name HEADING 'Staff Name' FORMAT A15
COLUMN staff_phoneno HEADING 'Phone No' FORMAT A12
COLUMN old_staff_phoneno HEADING 'Old Phone No' FORMAT A12
COLUMN new_staff_phoneno HEADING 'New Phone No' FORMAT A12
COLUMN staff_email HEADING 'Staff Email' FORMAT A25
COLUMN old_staff_email HEADING 'Old Staff Email' FORMAT A21
COLUMN new_staff_email HEADING 'New Staff Email' FORMAT A20
COLUMN hire_date HEADING 'Hire Date' FORMAT A10
COLUMN position HEADING 'Position' FORMAT A10
COLUMN salary HEADING 'Salary' FORMAT 999999

-- Dropping existing trigger, tables, and sequences (if they exist)
DROP TRIGGER trg_track_staff;
DROP TABLE DeleteStaff;
DROP TABLE UpdateStaff;
DROP TABLE InsertStaff;
DROP SEQUENCE insert_seq;
DROP SEQUENCE update_seq;
DROP SEQUENCE delete_seq;

-- Creating sequences for insert, update, and delete operations
CREATE SEQUENCE insert_seq START WITH 1 INCREMENT BY 1 NOCYCLE;
CREATE SEQUENCE update_seq START WITH 1 INCREMENT BY 1 NOCYCLE;
CREATE SEQUENCE delete_seq START WITH 1 INCREMENT BY 1 NOCYCLE;

-- Creating table to store inserted staff records
CREATE TABLE InsertStaff (
  ID NUMBER(2),
  user_id VARCHAR2(7),
  edit_date DATE,
  staff_id VARCHAR2(10) NOT NULL,
  staff_name VARCHAR2(50) NOT NULL,
  staff_phoneno VARCHAR2(15),
  staff_email VARCHAR2(30),
  hire_date DATE NOT NULL,
  position VARCHAR2(20) NOT NULL,
  salary NUMBER(10, 2) NOT NULL
);

-- Creating table to store updated staff records with old and new values
CREATE TABLE UpdateStaff (
  ID NUMBER(2),
  user_id VARCHAR2(7),
  edit_date DATE,
  staff_id VARCHAR2(10) NOT NULL,
  staff_name VARCHAR2(50) NOT NULL,
  old_staff_phoneno VARCHAR2(15),
  new_staff_phoneno VARCHAR2(15),
  old_staff_email VARCHAR2(30),
  new_staff_email VARCHAR2(30),
  hire_date DATE NOT NULL,
  position VARCHAR2(20) NOT NULL,
  salary NUMBER(10, 2) NOT NULL
);

-- Creating table to store deleted staff records
CREATE TABLE DeleteStaff (
  ID NUMBER(2),
  user_id VARCHAR2(7),
  edit_date DATE,
  staff_id VARCHAR2(10) NOT NULL,
  staff_name VARCHAR2(50) NOT NULL,
  staff_phoneno VARCHAR2(15),
  staff_email VARCHAR2(30),
  hire_date DATE NOT NULL,
  position VARCHAR2(20) NOT NULL,
  salary NUMBER(10, 2) NOT NULL
);

-- Creating trigger to log insert, update, and delete operations
CREATE OR REPLACE TRIGGER trg_track_staff
AFTER INSERT OR UPDATE OR DELETE ON Staffs
FOR EACH ROW
BEGIN
  CASE
    -- Log insert operation
    WHEN INSERTING THEN
      INSERT INTO InsertStaff
      VALUES (
        insert_seq.NEXTVAL, 
        USER, 
        SYSDATE, 
        :NEW.StaffID, 
        :NEW.FirstName || ' ' || :NEW.LastName, 
        :NEW.Phone, 
        :NEW.Email, 
        :NEW.HireDate, 
        :NEW.Position, 
        :NEW.Salary
      );

    -- Log update operation
    WHEN UPDATING THEN
      INSERT INTO UpdateStaff
      VALUES (
        update_seq.NEXTVAL, 
        USER, 
        SYSDATE, 
        :OLD.StaffID, 
        :OLD.FirstName || ' ' || :OLD.LastName, 
        :OLD.Phone, 
        :NEW.Phone, 
        :OLD.Email, 
        :NEW.Email, 
        :NEW.HireDate, 
        :NEW.Position, 
        :NEW.Salary
      );

    -- Log delete operation
    WHEN DELETING THEN
      INSERT INTO DeleteStaff
      VALUES (
        delete_seq.NEXTVAL, 
        USER, 
        SYSDATE, 
        :OLD.StaffID, 
        :OLD.FirstName || ' ' || :OLD.LastName, 
        :OLD.Phone, 
        :OLD.Email, 
        :OLD.HireDate, 
        :OLD.Position, 
        :OLD.Salary
      );
  END CASE;
END;
/


-- Insert a new staff record
INSERT INTO Staffs
VALUES ('S033', 'Jacqueline', 'Doe', 'Waiter', 'jacqueline@gmail.com', '555-8324', TO_DATE('2021-09-20', 'YYYY-MM-DD'), 3600.00);

INSERT INTO Staffs
VALUES ('S032', 'BJ', 'Er', 'FreeRider', 'bjjdhqiwdr@gmail.com', '555-7488', TO_DATE('2021-09-01', 'YYYY-MM-DD'), 600.00);

-- Update an existing staff's phone number and email
UPDATE Staffs
SET Phone = '017-8116435', Email = 'melissa@gmail.com'
WHERE StaffID = 'S002';

-- Delete a staff record
DELETE FROM Staffs
WHERE StaffID = 'S032';

-- Display records logged in InsertStaff table
TTITLE LEFT ' INSERT'
SELECT * FROM InsertStaff;

-- Display records logged in UpdateStaff table
TTITLE LEFT ' UPDATE'
SELECT * FROM UpdateStaff;

-- Display records logged in DeleteStaff table
TTITLE LEFT ' DELETE'
SELECT * FROM DeleteStaff;

-- Turn off title formatting and clear columns
TTITLE OFF;
CLEAR COLUMNS;
