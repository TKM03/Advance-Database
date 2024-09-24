SET SERVEROUTPUT ON
SET LINESIZE 110
SET PAGESIZE 100

COLUMN RouteID FORMAT A10 HEADING 'Route ID'
COLUMN DepartureLocation FORMAT A20 HEADING 'Departure'
COLUMN ArrivalLocation FORMAT A20 HEADING 'Arrival'
COLUMN FlightRevenue FORMAT 999,999,999.99 HEADING 'Flight Revenue (RM)'
COLUMN ItemRevenue FORMAT 999,999,999.99 HEADING 'Items Revenue (RM)'
COLUMN TotalRevenue FORMAT 999,999,999.99 HEADING 'Total Revenue (RM)'

TTITLE CENTER 'Route Revenue Analysis' -
RIGHT 'Page: ' FORMAT 99 SQL.PNO SKIP 2 

CREATE OR REPLACE VIEW RouteRevenueAnalysis AS
SELECT *
FROM (
    SELECT 
        r.RouteID AS RouteID,
        r.DepartureLocation AS DepartureLocation,
        r.ArrivalLocation AS ArrivalLocation,
        SUM(bd.Price) AS FlightRevenue,
        SUM(p.TotalAmount) AS ItemRevenue,
        SUM(p.TotalAmount) + SUM(bd.Price) AS TotalRevenue
    FROM 
        Routes r
    JOIN Flights f ON r.RouteID = f.RouteID
    JOIN BookingDetail bd ON f.FlightID = bd.FlightID
    JOIN Purchase p ON bd.PassengerID = p.PassengerID
    GROUP BY 
        r.RouteID, r.DepartureLocation, r.ArrivalLocation
    ORDER BY 
        TotalRevenue DESC
)
WHERE ROWNUM <= 10;


SELECT * FROM RouteRevenueAnalysis;

CLEAR COLUMNS
TTITLE OFF;
