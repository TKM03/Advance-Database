SET SERVEROUTPUT ON
SET linesize 200
SET pagesize 100
cl scr


-- Drop existing procedure if it exists
DROP PROCEDURE prc_bookingDetailByDate;

-- Create or replace the procedure for booking details
CREATE OR REPLACE PROCEDURE prc_bookingDetailByDate (
    d_StartDate IN VARCHAR2,
    d_EndDate IN VARCHAR2
) IS
    -- Variables for outer cursor (high-level booking details)
    v_bookingID    Booking.BookingID%TYPE;
    v_bookingDate  Booking.BookingDate%TYPE;
    
    -- Variables for inner cursor (detailed booking information)
    d_passengerID        Passengers.PassengerID%TYPE;
    d_passengerName      Passengers.Name%TYPE;
    d_flightID           Flights.FlightID%TYPE;
    d_seatNumber         BookingDetail.SeatNumber%TYPE;
    d_class              BookingDetail.Class%TYPE;
    d_price              BookingDetail.Price%TYPE;
    d_checkLuggageID     CheckLuggages.CheckLuggageID%TYPE;
    v_index              NUMBER := 1;

    -- Outer cursor to fetch booking details within the selected date range
    CURSOR bookingCursor IS
        SELECT 
            b.BookingID, 
            b.BookingDate
        FROM 
            Booking b
        WHERE 
            b.BookingDate BETWEEN TO_DATE(d_StartDate, 'DD-MON-YYYY') AND TO_DATE(d_EndDate, 'DD-MON-YYYY')
        ORDER BY 
            b.BookingDate;

    -- Inner cursor to fetch detailed booking information based on BookingID
    CURSOR detailCursor(p_bookingID IN Booking.BookingID%TYPE) IS
        SELECT 
            p.PassengerID, 
            p.Name, 
            bd.FlightID, 
            bd.SeatNumber, 
            bd.Class, 
            bd.Price, 
            bd.CheckLuggageID
        FROM 
            BookingDetail bd
        INNER JOIN 
            Passengers p ON bd.PassengerID = p.PassengerID
        INNER JOIN 
            Flights f ON bd.FlightID = f.FlightID
        LEFT JOIN 
            CheckLuggages cl ON bd.CheckLuggageID = cl.CheckLuggageID
        WHERE 
            bd.BookingID = p_bookingID
        ORDER BY 
            bd.FlightID;

BEGIN
    -- Print header
    DBMS_OUTPUT.PUT_LINE(RPAD('=', 60, '='));
    DBMS_OUTPUT.PUT_LINE('Booking Details in Selected Date Range');
    DBMS_OUTPUT.PUT_LINE(RPAD('=', 60, '='));

    -- Open and loop through the outer cursor
    OPEN bookingCursor;
    LOOP
        FETCH bookingCursor INTO v_bookingID, v_bookingDate;
        EXIT WHEN bookingCursor%NOTFOUND;

        -- Display high-level booking information
        DBMS_OUTPUT.PUT_LINE('Booking ID: ' || v_bookingID);
        DBMS_OUTPUT.PUT_LINE('Booking Date: ' || TO_CHAR(v_bookingDate, 'DD-MON-YYYY'));

        -- Open and loop through the inner cursor for each booking
        OPEN detailCursor(v_bookingID);
        LOOP
            FETCH detailCursor INTO 
                d_passengerID, 
                d_passengerName, 
                d_flightID, 
                d_seatNumber, 
                d_class, 
                d_price, 
                d_checkLuggageID;
                
            EXIT WHEN detailCursor%NOTFOUND;

            -- Display the detailed booking information
            DBMS_OUTPUT.PUT_LINE('  Index: ' || v_index);
            DBMS_OUTPUT.PUT_LINE('  Passenger ID: ' || d_passengerID);
            DBMS_OUTPUT.PUT_LINE('  Passenger Name: ' || d_passengerName);
            DBMS_OUTPUT.PUT_LINE('  Flight ID: ' || d_flightID);
            DBMS_OUTPUT.PUT_LINE('  Seat Number: ' || d_seatNumber);
            DBMS_OUTPUT.PUT_LINE('  Class: ' || d_class);
            DBMS_OUTPUT.PUT_LINE('  Price: $ ' || TO_CHAR(d_price, '9999.99'));
            DBMS_OUTPUT.PUT_LINE('  Check Luggage ID: ' || NVL(d_checkLuggageID, 'N/A'));
            DBMS_OUTPUT.PUT_LINE(CHR(10));  -- Add a blank line for spacing

            -- Increment index
            v_index := v_index + 1;
        END LOOP;

        -- Close the inner cursor
        CLOSE detailCursor;

        -- Reset the index for the next booking
        v_index := 1;
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 60, '-'));
    END LOOP;

    -- Close the outer cursor
    CLOSE bookingCursor;
END;
/

-- Execute the procedure for a specific date range
EXEC prc_bookingDetailByDate('01-May-2023', '10-May-2023');
