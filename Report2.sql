SET SERVEROUTPUT ON
SET linesize 200
SET pagesize 150
cl scr


-- Drop existing procedure if it exists
DROP PROCEDURE prc_salary_report;

-- Create or replace the procedure for the annual staff salary report
CREATE OR REPLACE PROCEDURE prc_salary_report AS
    v_total        NUMBER := 0;
    v_average      NUMBER := 0;
    staffnum       NUMBER := 0;
    maxsal         NUMBER := 0;
    minsal         NUMBER := NULL;
    pos_max_salary VARCHAR2(30) := NULL;
    pos_min_salary VARCHAR2(30) := NULL;

    -- Main cursor to get the distinct positions
    CURSOR main_cursor IS
        SELECT DISTINCT Position
        FROM Staffs
        ORDER BY Position;

    -- Nested cursor to get staff details for each position
    CURSOR detail_cursor (p_position VARCHAR2) IS
        SELECT 
            StaffID, 
            FirstName || ' ' || LastName AS StaffName, 
            Position, 
            Salary
        FROM 
            Staffs
        WHERE 
            Position = p_position
        ORDER BY 
            StaffID;
BEGIN
    -- Print the header for the report
    DBMS_OUTPUT.PUT_LINE(RPAD('*', 70, '*'));
    DBMS_OUTPUT.PUT_LINE(RPAD(' ', 25, ' ') || ' ' ||
                         RPAD('STAFF SALARY REPORT FOR THE YEAR', 40, ' ') || ' ' ||
                         RPAD(' ', 25, ' '));
    DBMS_OUTPUT.PUT_LINE(RPAD('*', 70, '*'));
    DBMS_OUTPUT.PUT_LINE(CHR(10));
    DBMS_OUTPUT.PUT_LINE(
        RPAD('STAFF ID', 15, ' ') || ' ' ||
        RPAD('STAFF NAME', 25, ' ') || ' ' ||
        RPAD('POSITION', 30, ' ') || ' ' ||
        RPAD('SALARY', 14, ' '));
    DBMS_OUTPUT.PUT_LINE(
        RPAD('=', 15, '=') || ' ' ||
        RPAD('=', 25, '=') || ' ' ||
        RPAD('=', 30, '=') || ' ' ||
        RPAD('=', 14, '='));

    -- Loop through the main cursor to process each position
    FOR main_rec IN main_cursor LOOP
        -- Loop through the nested cursor to process each staff member for the current position
        FOR detail_rec IN detail_cursor(main_rec.Position) LOOP
            DBMS_OUTPUT.PUT_LINE(
                RPAD(detail_rec.StaffID, 15, ' ') || ' ' ||
                RPAD(detail_rec.StaffName, 25, ' ') || ' ' ||
                RPAD(detail_rec.Position, 30, ' ') || ' ' ||
                TO_CHAR(detail_rec.Salary, '999,999.99'));
            
            -- Accumulate total salary and staff count
            v_total := v_total + detail_rec.Salary;
            staffnum := staffnum + 1;

            -- Determine max and min salaries
            IF detail_rec.Salary > maxsal THEN
                maxsal := detail_rec.Salary;
                pos_max_salary := detail_rec.Position;
            END IF;

            IF minsal IS NULL OR detail_rec.Salary < minsal THEN
                minsal := detail_rec.Salary;
                pos_min_salary := detail_rec.Position;
            END IF;
        END LOOP;
    END LOOP;

    -- Display summary statistics
    DBMS_OUTPUT.PUT_LINE(CHR(10));
    DBMS_OUTPUT.PUT_LINE('Total staff: ' || staffnum);

    IF minsal IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Min salary for the year ($): ' || TO_CHAR(minsal, '999,999.99'));
        DBMS_OUTPUT.PUT_LINE('Position of Min Salary: ' || pos_min_salary);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Min salary for the year ($): N/A');
        DBMS_OUTPUT.PUT_LINE('Position of Min Salary: N/A');
    END IF;

    DBMS_OUTPUT.PUT_LINE('Max salary for the year ($): ' || TO_CHAR(maxsal, '999,999.99'));
    DBMS_OUTPUT.PUT_LINE('Position of Max Salary: ' || pos_max_salary);
    DBMS_OUTPUT.PUT_LINE('Total salary for the year ($): ' || TO_CHAR(v_total, '9,999,999.99'));
    DBMS_OUTPUT.PUT_LINE('Average salary for the year ($): ' || TO_CHAR(v_total / staffnum, '999,999.99'));
    DBMS_OUTPUT.PUT_LINE(RPAD('=', 65, '='));
    DBMS_OUTPUT.PUT_LINE(CHR(10));
    DBMS_OUTPUT.PUT_LINE('----------------------------END OF REPORT----------------------------');
END;
/



-- Execute the procedure
EXEC prc_salary_report;
