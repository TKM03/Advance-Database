-- Set up formatting for the report
SET SERVEROUTPUT ON
SET linesize 200
SET pagesize 150
cl scr

CREATE OR REPLACE PROCEDURE updateBookingDetail (
    v_bookingID     IN VARCHAR2,  -- Input: Booking ID
    v_wayID         IN NUMBER,    -- Input: Way ID (1 for 1-way, 2 for return)
    v_passengerID   IN VARCHAR2,  -- Input: Passenger ID
    v_flightID      IN VARCHAR2,  -- Input: Flight ID
    v_policyID      IN VARCHAR2,  -- Input: Policy ID
    v_checkLuggageID IN VARCHAR2, -- Input: Check Luggage ID
    v_seatNumber    IN NUMBER,    -- Input: New Seat Number
    v_class         IN VARCHAR2,  -- Input: New Class (e.g., 'Economy', 'Business')
    v_price         IN NUMBER     -- Input: New Price
)
IS
    -- Variable to check if the booking exists
    v_exists NUMBER := 0;

    -- Define custom exceptions
    booking_not_found EXCEPTION;
    PRAGMA EXCEPTION_INIT(booking_not_found, -20001); -- Example error code

BEGIN
    -- Check if the booking exists in the BookingDetail table
    SELECT COUNT(*)
    INTO v_exists
    FROM BookingDetail
    WHERE BookingID = v_bookingID
    AND WayID = v_wayID
    AND PassengerID = v_passengerID;
    
    -- If the booking exists, update the booking details
    IF v_exists > 0 THEN
        UPDATE BookingDetail
        SET FlightID = v_flightID,
            PolicyID = v_policyID,
            CheckLuggageID = v_checkLuggageID,
            SeatNumber = v_seatNumber,
            Class = v_class,
            Price = v_price
        WHERE BookingID = v_bookingID
        AND WayID = v_wayID
        AND PassengerID = v_passengerID;
        
        -- Feedback for successful update
        DBMS_OUTPUT.PUT_LINE('--- Booking details updated successfully for Booking ID ' || v_bookingID || ', Way ID ' || v_wayID || ', Passenger ID ' || v_passengerID || '.---');
    ELSE
        -- Raise custom exception if the booking does not exist
        RAISE booking_not_found;
    END IF;

    -- Commit the transaction
    COMMIT;

EXCEPTION
    WHEN booking_not_found THEN
        -- Feedback if the booking does not exist
        DBMS_OUTPUT.PUT_LINE('Booking ID ' || v_bookingID || ' with Way ID ' || v_wayID || ' and Passenger ID ' || v_passengerID || ' does not exist.');
    WHEN OTHERS THEN
        -- Handle any unexpected errors
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END updateBookingDetail;
/

--- Execute the procedure
EXEC updateBookingDetail('B001', 1, 'P001', 'FL005', 'IP001', 'CL006', 10, 'Business', 1399.88);

EXEC updateBookingDetail('B003', 1, 'P003', 'FL010', 'IP001', 'CL012', 20, 'Business', 1899.88);

EXEC updateBookingDetail('B016', 1, 'P006', 'FL027', 'IP001', 'CL002', 12, 'Economy', 299.88);

EXEC updateBookingDetail('B027', 2, 'P007', 'FL008', 'IP001', 'CL009', 2, 'First', 4399.88);

EXEC updateBookingDetail('B061', 2, 'P001', 'FL012', 'IP001', 'CL007', 3, 'First', 7099.88);
