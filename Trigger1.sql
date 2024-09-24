SET SERVEROUTPUT ON
SET linesize 200
SET pagesize 100
cl scr


-- Drop the sequence if it already exists
DROP SEQUENCE S_RECORD_ID;

-- Create the sequence for generating unique record IDs
CREATE SEQUENCE S_RECORD_ID
  START WITH 1
  MAXVALUE 99999
  INCREMENT BY 1
  NOCYCLE;

-- Drop the trigger if it already exists
DROP TRIGGER bookingDetailsTrigger;

-- Drop the record table if it already exists
DROP TABLE BookingDetails_Record;

-- Set up formatting for the report
SET LINESIZE 200
SET PAGESIZE 200
SET SERVEROUTPUT ON

-- Create the BookingDetails_Record table to store the updated booking details
CREATE TABLE BookingDetails_Record (
    S_RECORD_ID     NUMBER(3), 
    BookingID       VARCHAR(10)   NOT NULL,
    Old_FlightID    VARCHAR(10),
    New_FlightID    VARCHAR(10),
    Old_SeatNumber  NUMBER(4),
    New_SeatNumber  NUMBER(4),
    Old_Class       VARCHAR(10),
    New_Class       VARCHAR(10),
    Old_Price       NUMBER(10, 2),
    New_Price       NUMBER(10, 2),
    BOOKINGDETAILS_DIFF NUMBER(10, 2), -- Difference in price
    UPDATE_DATE     DATE,
    PRIMARY KEY (S_RECORD_ID)
);

-- Create the trigger to track updates to the BookingDetail table
CREATE OR REPLACE TRIGGER bookingDetailsTrigger
AFTER UPDATE ON BookingDetail
FOR EACH ROW
DECLARE
  v_bookingDetailsDiff NUMBER(10, 2);
BEGIN
  -- Calculate the price difference
  v_bookingDetailsDiff := :new.Price - :old.Price;
  
  -- Insert the updated record into BookingDetails_Record
  INSERT INTO BookingDetails_Record (
    S_RECORD_ID, BookingID, Old_FlightID, New_FlightID,
    Old_SeatNumber, New_SeatNumber, Old_Class, New_Class,
    Old_Price, New_Price, BOOKINGDETAILS_DIFF, UPDATE_DATE
  )
  VALUES (
    S_RECORD_ID.NEXTVAL, :new.BookingID, :old.FlightID, :new.FlightID,
    :old.SeatNumber, :new.SeatNumber, :old.Class, :new.Class,
    :old.Price, :new.Price, v_bookingDetailsDiff, SYSDATE
  );
  
  -- Output message for changes in booking details
  DBMS_OUTPUT.PUT_LINE('Booking details for Booking ID ' || :new.BookingID ||
                       ' have changed. Old flight: ' || :old.FlightID || 
                       ', new flight: ' || :new.FlightID || 
                       ', old price: $' || :old.Price || 
                       ', new price: $' || :new.Price || 
                       ', difference: ' || v_bookingDetailsDiff || '.');
END;
/


-- Example of how to view the inserted records after an update occurs
SELECT * FROM BookingDetails_Record;
