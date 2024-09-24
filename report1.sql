SET SERVEROUTPUT ON
SET LINESIZE 200
SET PAGESIZE 100

CREATE INDEX idx_routes_routeid ON Routes(RouteID);

CREATE OR REPLACE VIEW RoutePerformanceReport AS
SELECT 
    r.RouteID,
    r.DepartureLocation,
    r.ArrivalLocation,
    COUNT(DISTINCT bd.BookingID) AS TotalBookings, -- Total number of bookings
    COUNT(DISTINCT bd.PassengerID) AS TotalPassengers, -- Total number of unique passengers
    ROUND(SUM(bd.Price + p.TotalAmount) / COUNT(DISTINCT bd.BookingID), 2) AS AvgRevenuePerBooking, -- Average revenue per booking
    SUM(bd.Price + p.TotalAmount) AS TotalRevenue -- Total revenue including flight price and item sales
FROM
    Routes r
JOIN Flights f ON r.RouteID = f.RouteID
JOIN Airplane a ON f.AirplaneID = a.AirplaneID -- Join with Airplane table to get Capacity
JOIN BookingDetail bd ON f.FlightID = bd.FlightID
LEFT JOIN Purchase p ON bd.PassengerID = p.PassengerID
JOIN (
    SELECT 
        f.FlightID,
        (COUNT(DISTINCT bd.PassengerID) / a.Capacity) * 100 AS LoadFactor 
    FROM Flights f
    JOIN Airplane a ON f.AirplaneID = a.AirplaneID
    JOIN BookingDetail bd ON f.FlightID = bd.FlightID
    GROUP BY f.FlightID, a.Capacity
) FlightLoadFactors ON f.FlightID = FlightLoadFactors.FlightID
GROUP BY
    r.RouteID, r.DepartureLocation, r.ArrivalLocation;


DECLARE
    -- Outer cursor to select data from the RoutePerformanceReport view
    CURSOR c_RoutePerformance IS
        SELECT 
            RouteID,
            DepartureLocation,
            ArrivalLocation,
            TotalBookings,
            TotalPassengers,
            AvgRevenuePerBooking,
            TotalRevenue
        FROM RoutePerformanceReport
        ORDER BY TotalRevenue DESC; -- Sort by total revenue

    -- Inner cursor to calculate total flights and load factor for each route
    CURSOR c_LoadFactorByRoute (v_RouteID Routes.RouteID%TYPE) IS
        SELECT 
            ROUND(AVG((COUNT(DISTINCT bd.PassengerID) / a.Capacity) * 100), 2) AS AvgLoadFactor
        FROM Flights f
        JOIN Airplane a ON f.AirplaneID = a.AirplaneID
        JOIN BookingDetail bd ON f.FlightID = bd.FlightID
        WHERE f.RouteID = v_RouteID
        GROUP BY a.Capacity;

    -- Variables to hold outer cursor values
    v_RouteID RoutePerformanceReport.RouteID%TYPE;
    v_DepartureLocation RoutePerformanceReport.DepartureLocation%TYPE;
    v_ArrivalLocation RoutePerformanceReport.ArrivalLocation%TYPE;
    v_TotalBookings RoutePerformanceReport.TotalBookings%TYPE;
    v_TotalPassengers RoutePerformanceReport.TotalPassengers%TYPE;
    v_AvgRevenuePerBooking RoutePerformanceReport.AvgRevenuePerBooking%TYPE;
    v_TotalRevenue RoutePerformanceReport.TotalRevenue%TYPE;
    v_AvgLoadFactor NUMBER; -- Variable to hold the load factor calculated by the inner cursor

BEGIN
    -- Open the outer cursor
    OPEN c_RoutePerformance;
    DBMS_OUTPUT.PUT_LINE('|' || RPAD('-', 156, '-') || '|');
    DBMS_OUTPUT.PUT_LINE('|' || RPAD(' ', 68) || RPAD('Route Performance Report', 88, ' ') || '|');
    DBMS_OUTPUT.PUT_LINE('|' || RPAD(' ', 136) || RPAD('Date: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY'), 20, ' ') || '|');
    DBMS_OUTPUT.PUT_LINE('|' || RPAD('-', 156, '-') || '|');

    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------------------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('| Route ID | Departure          | Arrival            | Total Bookings | Total Passengers | Avg Revenue/Booking (RM) | Total Revenue (RM) | Avg Load Factor % |');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------------------------------------------------------------------------------------');

    -- Loop through each record returned by the outer cursor
    LOOP
        FETCH c_RoutePerformance INTO v_RouteID, v_DepartureLocation, v_ArrivalLocation, v_TotalBookings, v_TotalPassengers, v_AvgRevenuePerBooking, v_TotalRevenue;
        EXIT WHEN c_RoutePerformance%NOTFOUND; -- Exit the loop if no more rows are returned

        -- Open the inner cursor to calculate the load factor for the current route
        OPEN c_LoadFactorByRoute(v_RouteID);
        FETCH c_LoadFactorByRoute INTO v_AvgLoadFactor; -- Fetch the average load factor
        CLOSE c_LoadFactorByRoute; -- Close the inner cursor

        -- Display the route performance record
        DBMS_OUTPUT.PUT_LINE('| ' || RPAD(v_RouteID, 8) || ' | ' ||
                         RPAD(v_DepartureLocation, 18) || ' | ' ||
                         RPAD(v_ArrivalLocation, 18) || ' | ' ||
                         LPAD(TO_CHAR(v_TotalBookings, '999,999'), 14) || ' | ' || -- Format total bookings
                         LPAD(TO_CHAR(v_TotalPassengers, '999,999'), 16) || ' | ' || -- Format total passengers
                         LPAD(TO_CHAR(v_AvgRevenuePerBooking, '999,999.99'), 24) || ' | ' || -- Format average revenue per booking
                         LPAD(TO_CHAR(v_TotalRevenue, '999,999,999'), 18) || ' | ' || -- Format total revenue
                         LPAD(TO_CHAR(v_AvgLoadFactor, '999.99'), 17) || ' |'); -- Format average load factor

    END LOOP;

    -- Close the outer cursor
    CLOSE c_RoutePerformance;

    DBMS_OUTPUT.PUT_LINE('|' || RPAD('-',156, '-') || '|');
    DBMS_OUTPUT.PUT_LINE('|' || RPAD(' ', 73) || RPAD('End of Report', 83, ' ') || '|');
    DBMS_OUTPUT.PUT_LINE('|' || RPAD('-', 156, '-') || '|');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/
