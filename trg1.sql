SET SERVEROUTPUT ON
SET linesize 120
SET pagesize 100
ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD';


CREATE OR REPLACE TRIGGER trg_newpurchase
BEFORE INSERT ON purchase
FOR EACH ROW
DECLARE
    v_price items.price%TYPE;
    v_stock items.stockquantity%TYPE;
BEGIN
    -- Fetch the price and current stock quantity from Items table
    SELECT price, StockQuantity INTO v_price, v_stock
    FROM Items
    WHERE ItemID = :new.ItemID;

    -- Check if there is enough stock
    IF v_stock < :new.quantity THEN
        RAISE_APPLICATION_ERROR(-20001, 'Insufficient stock for the purchased item.');
    END IF;

    -- Calculate the total amount using the fetched price
    :new.TotalAmount := v_price * :new.quantity;

    -- Update the stock quantity in Items table
    UPDATE Items
    SET StockQuantity = StockQuantity - :new.quantity
    WHERE ItemID = :new.ItemID;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'Item ID not found in table.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20003, 'An unexpected error occurred.');
END;
/
INSERT INTO Purchase VALUES ('2025-12-17', 'I001', 'P001', null, 84);
INSERT INTO Purchase VALUES ('2025-01-30', 'I031', 'P023', null, 1);
