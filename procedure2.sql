SET SERVEROUTPUT ON
SET LINESIZE 150

CREATE OR REPLACE FUNCTION fnc_isValidEmail(p_email IN VARCHAR) RETURN BOOLEAN IS
    v_at_pos NUMBER;  -- Position of the '@' character
    v_dot_pos NUMBER; -- Position of the last '.' character
BEGIN
    -- Find the position of the '@' symbol
    v_at_pos := INSTR(p_email, '@');
    
    -- Find the position of the last '.' after the '@'
    v_dot_pos := INSTR(p_email, '.', v_at_pos + 1);

    -- Check if '@' is present and is not at the start or end
    IF v_at_pos > 1 AND v_at_pos < LENGTH(p_email) THEN
        -- Check if a '.' is present after the '@' and it is not at the end
        IF v_dot_pos > v_at_pos + 1 AND v_dot_pos < LENGTH(p_email) THEN
            RETURN TRUE; -- Email is valid
        ELSE
            RETURN FALSE; -- Invalid due to incorrect domain part
        END IF;
    ELSE
        RETURN FALSE; -- Invalid due to incorrect placement of '@'
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE; -- Invalid if any exception occurs
END fnc_isValidEmail;
/


CREATE OR REPLACE PROCEDURE prc_UpdateStaffDetails (
    v_StaffID IN VARCHAR,
    v_FirstName IN VARCHAR,
    v_LastName IN VARCHAR,
    v_Position IN VARCHAR,
    v_Email IN VARCHAR,
    v_Phone IN VARCHAR,
    v_Salary IN NUMBER
)
IS
    v_count NUMBER := 0;
BEGIN
    IF fnc_isValidEmail(v_Email) THEN
    -- Update the staff details based on StaffID
        UPDATE Staffs
        SET FirstName = v_FirstName,
            LastName = v_LastName,
            Position = v_Position,
            Email = v_Email,
            Salary = v_Salary,
            Phone = v_Phone
        WHERE StaffID = v_StaffID;
        
        -- Count the number of updated records
        v_count := SQL%ROWCOUNT;

        IF v_count = 0 THEN
            DBMS_OUTPUT.PUT_LINE('No staff member found with the StaffID.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Staff details updated successfully for StaffID: ' || v_StaffID);
        END IF;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Invalid email format provided: ' || v_Email);
    END IF;    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/

EXEC prc_UpdateStaffDetails('S002', 'Fong', 'Wei Sheng','Pilot','abc@gmail.com','0123456',5000)