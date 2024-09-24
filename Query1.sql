-- Set up formatting for the report
SET LINESIZE 200
SET PAGESIZE 180
SET SERVEROUTPUT ON

-- Prompt for flight ID input
ACCEPT flight_id PROMPT 'Enter the Flight ID : '

-- Title formatting for the report
TTITLE LEFT 'Passenger Booking Details for Flight ID ' &flight_id -
SKIP 2


-- Column formatting
COLUMN passenger_id FORMAT A20 HEADING 'Passenger_ID' JUSTIFY LEFT
COLUMN name FORMAT A20 HEADING 'Name' JUSTIFY LEFT
COLUMN contact_number FORMAT A20 HEADING 'Contact Number' JUSTIFY LEFT
COLUMN booking_id FORMAT A15 HEADING 'Booking_ID' JUSTIFY LEFT
COLUMN seat_number FORMAT 9999 HEADING 'Seat Number' JUSTIFY LEFT
COLUMN luggage_id FORMAT A15 HEADING 'Luggage ID' JUSTIFY LEFT
COLUMN class FORMAT A20 HEADING 'Class' JUSTIFY LEFT
COLUMN price FORMAT A20 HEADING 'Price' JUSTIFY LEFT


-- Main query to retrieve passenger booking details
SELECT 
    p.PassengerID AS passenger_id,
    p.Name AS name,
    p.ContactNumber AS contact_number,
    b.BookingID AS booking_id,
    b.SeatNumber AS seat_number,
    b.CheckLuggageID AS luggage_id,
    b.Class AS class,
    '$ ' || TO_CHAR(b.Price, '99999.99') AS price
FROM 
    BookingDetail b
JOIN 
    Passengers p ON b.PassengerID = p.PassengerID
WHERE 
    b.FlightID = '&flight_id'
ORDER BY 
    p.Name;

-- Total number of bookings and total booking price
SELECT 
    COUNT(b.BookingID) AS "Total Bookings",
    '$ ' || TO_CHAR(SUM(b.Price), '99999999999999.99') AS "Total Booking Price"
FROM 
    BookingDetail b
WHERE 
    b.FlightID = '&flight_id';

-- Turn off title and formatting settings
TTITLE OFF
CLEAR COLUMNS
CLEAR BREAKS
