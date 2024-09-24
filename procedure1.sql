SET SERVEROUTPUT ON

CREATE OR REPLACE FUNCTION fnc_checkValueExists(
    p_value IN VARCHAR,
    p_table_name IN VARCHAR,
    p_column_name IN VARCHAR
) RETURN BOOLEAN 
IS
    v_count NUMBER;
    v_sql VARCHAR(1000);
BEGIN
    -- Construct the dynamic SQL statement
    v_sql := 'SELECT COUNT(*) FROM ' || p_table_name || 
             ' WHERE ' || p_column_name || ' = :1';

    -- Execute the dynamic SQL statement
    EXECUTE IMMEDIATE v_sql INTO v_count USING p_value;

    -- Check the count to determine if the value exists
    IF v_count > 0 THEN
        RETURN TRUE; -- Value exists in the specified table and column
    ELSE
        RETURN FALSE; -- Value does not exist
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE; -- Return FALSE in case of any errors
END fnc_checkValueExists;
/



CREATE OR REPLACE PROCEDURE prc_RestockItem (
    v_ItemID        IN VARCHAR,
    v_Quantity      IN NUMBER
) 
IS
BEGIN
    -- Use the function to check if the ItemID exists in the Items table
    IF fnc_checkValueExists(v_ItemID, 'Items', 'ItemID') THEN
        -- If the item exists, update the stock quantity
        UPDATE Items
        SET StockQuantity = StockQuantity + v_Quantity
        WHERE ItemID = v_ItemID;

        IF SQL%ROWCOUNT > 0 THEN
            DBMS_OUTPUT.PUT_LINE('Stock updated successfully.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Failed to update stock.');
        END IF;
    ELSE
        -- If the item does not exist, output a message
        DBMS_OUTPUT.PUT_LINE('Item not found.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
END;
/

EXEC prc_RestockItem('I004', 10)

