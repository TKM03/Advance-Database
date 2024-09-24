-- Set up formatting for the report
SET LINESIZE 180
SET PAGESIZE 100
SET SERVEROUTPUT ON

CREATE OR REPLACE PROCEDURE prc_calc_monthly_booking_total(
    p_month IN NUMBER,      -- Input: Month for which to calculate the totals (1-12)
    p_year  IN NUMBER       -- Input: Year for which to calculate the totals
)
IS
    -- Declare variables to store totals
    v_total_bookings NUMBER := 0;
    v_total_amount   NUMBER := 0;
    
    -- Cursor to fetch booking details
    CURSOR cur_monthly_bookings IS
        SELECT b.BookingID, b.BookingDate, bd.Class, bd.Price
        FROM Booking b
        JOIN BookingDetail bd ON b.BookingID = bd.BookingID
        WHERE EXTRACT(MONTH FROM b.BookingDate) = p_month
        AND EXTRACT(YEAR FROM b.BookingDate) = p_year;
    
    -- Record type for the cursor
    rec_monthly_bookings cur_monthly_bookings%ROWTYPE;

BEGIN
    -- Fetch data from the cursor and calculate totals
    FOR rec_monthly_bookings IN cur_monthly_bookings LOOP
        -- Increment the total number of bookings
        v_total_bookings := v_total_bookings + 1;
        
        -- Add the booking price to the total amount
        v_total_amount := v_total_amount + rec_monthly_bookings.Price;
        
        -- Display booking details with $ before price
        DBMS_OUTPUT.PUT_LINE('Booking ID: ' || rec_monthly_bookings.BookingID || 
                             ' | Booking Date: ' || TO_CHAR(rec_monthly_bookings.BookingDate, 'DD-MON-YYYY') || 
                             ' | Class: ' || rec_monthly_bookings.Class || 
                             ' | Price: $' || TO_CHAR(rec_monthly_bookings.Price, '99999.99'));
    END LOOP;
    
    
    -- Display the total bookings and amounts with $ before the values
    DBMS_OUTPUT.PUT_LINE('------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Total Bookings for ' || p_month || '-' || p_year || ': ' || v_total_bookings);
    DBMS_OUTPUT.PUT_LINE('Total Booking Amount: $' || TO_CHAR(v_total_amount, '9999999.99'));
    DBMS_OUTPUT.PUT_LINE('------------------------------------------');
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No bookings found for the specified month and year.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END prc_calc_monthly_booking_total;
/


--- Execute the procedure
EXEC prc_calc_monthly_booking_total(9, 2023);
EXEC prc_calc_monthly_booking_total(11, 2023);
