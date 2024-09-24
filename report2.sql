SET SERVEROUTPUT ON
SET LINESIZE 150

-- Creating an index for faster lookup
CREATE INDEX idx_bookingdetail_bookingid ON BookingDetail(BookingID);

-- Creating views for yearly revenue and its change
CREATE OR REPLACE VIEW YearlyRevenue AS
SELECT 
    EXTRACT(YEAR FROM b.BookingDate) AS Year,
    SUM(b.TotalPrice) + SUM(pu.TotalAmount) AS TotalRevenue
FROM 
    Booking b
JOIN BookingDetail bd ON b.bookingID = bd.BookingID
JOIN Passengers p ON bd.PassengerID = p.PassengerID
JOIN Purchase pu ON p.PassengerID = pu.PassengerID
GROUP BY 
    EXTRACT(YEAR FROM b.BookingDate)
ORDER BY 
    Year;

CREATE OR REPLACE VIEW YearlyRevenueChange AS
SELECT 
    Year,
    TotalRevenue,
    LAG(TotalRevenue) OVER (ORDER BY Year) AS PreviousYearRevenue,
    TotalRevenue - LAG(TotalRevenue) OVER (ORDER BY Year) AS RevenueChange
FROM 
    YearlyRevenue   
ORDER BY 
    Year;

-- PL/SQL Block with Nested Cursor
DECLARE
    -- Outer cursor to select data from the YearlyRevenueChange view
    CURSOR c_YearlyRevenue IS
        SELECT 
            Year,
            TotalRevenue,
            PreviousYearRevenue,
            RevenueChange
        FROM YearlyRevenueChange
        ORDER BY Year;

    -- Inner cursor to calculate monthly revenue for the given year
    CURSOR c_MonthlyRevenue (v_Year IN NUMBER) IS
        SELECT 
            EXTRACT(MONTH FROM b.BookingDate) AS Month,
            SUM(b.TotalPrice) + SUM(pu.TotalAmount) AS MonthlyRevenue,
            LAG(SUM(b.TotalPrice) + SUM(pu.TotalAmount)) OVER (ORDER BY EXTRACT(MONTH FROM b.BookingDate)) AS PreviousMonthRevenue,
            LAG(SUM(b.TotalPrice) + SUM(pu.TotalAmount)) OVER (ORDER BY EXTRACT(MONTH FROM b.BookingDate)) AS MonthRevenueChange
        FROM 
            Booking b
        JOIN BookingDetail bd ON b.bookingID = bd.BookingID
        JOIN Passengers p ON bd.PassengerID = p.PassengerID
        JOIN Purchase pu ON p.PassengerID = pu.PassengerID
        WHERE EXTRACT(YEAR FROM b.BookingDate) = v_Year
        GROUP BY EXTRACT(MONTH FROM b.BookingDate)
        ORDER BY EXTRACT(MONTH FROM b.BookingDate);

    -- Variables to hold outer cursor values
    v_Year YearlyRevenueChange.Year%TYPE;
    v_TotalRevenue YearlyRevenueChange.TotalRevenue%TYPE;
    v_PreviousYearRevenue YearlyRevenueChange.PreviousYearRevenue%TYPE;
    v_RevenueChange YearlyRevenueChange.RevenueChange%TYPE;
    
    -- Variables to hold inner cursor values
    v_Month NUMBER;
    v_MonthlyRevenue NUMBER;
    v_PreviousMonthRevenue NUMBER;
    v_MonthRevenueChange NUMBER;

BEGIN
    -- Open the outer cursor
    DBMS_OUTPUT.PUT_LINE('|' || RPAD('-', 90, '-') || '|');
    DBMS_OUTPUT.PUT_LINE('|' || RPAD(' ', 36) || RPAD('Yearly Revenue Report', 54, ' ') || '|');
    DBMS_OUTPUT.PUT_LINE('|' || RPAD(' ', 70) || RPAD('Date: ' || TO_CHAR(TO_DATE('01-JAN-2027', 'DD-MON-YYYY'), 'DD-MON-YYYY'), 20, ' ') || '|');
    DBMS_OUTPUT.PUT_LINE('|' || RPAD('-', 90, '-') || '|');
    OPEN c_YearlyRevenue;

    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('| Year/Month | Total Revenue (RM) | Previous Year/Month Revenue (RM) | Revenue Change (RM) |');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------------------');

    -- Loop through each record returned by the outer cursor
    LOOP
        FETCH c_YearlyRevenue INTO v_Year, v_TotalRevenue, v_PreviousYearRevenue, v_RevenueChange;
        EXIT WHEN c_YearlyRevenue%NOTFOUND; -- Exit the loop if no more rows are returned

        -- Display the yearly summary
        DBMS_OUTPUT.PUT_LINE('|    ' || LPAD(v_Year, 7) || ' |' ||
                             LPAD(TO_CHAR(v_TotalRevenue, '999,999,999'), 19) || ' |' ||
                             LPAD(TO_CHAR(NVL(v_PreviousYearRevenue, 0), '999,999,999'), 33) || ' |' ||
                             LPAD(TO_CHAR(NVL(v_RevenueChange, 0), '999,999,999'), 20) || ' |');
                             
        -- Open the inner cursor for the current year
        OPEN c_MonthlyRevenue(v_Year);
        -- DBMS_OUTPUT.PUT_LINE('   Monthly Breakdown:');

        -- Loop through each month for the given year
        LOOP
            FETCH c_MonthlyRevenue INTO v_Month, v_MonthlyRevenue, v_PreviousMonthRevenue, v_MonthRevenueChange;
            EXIT WHEN c_MonthlyRevenue%NOTFOUND; -- Exit when no more rows are returned

            -- Display the monthly revenue
            DBMS_OUTPUT.PUT_LINE('|    ' || LPAD(v_Month, 7) || ' |' || 
                                LPAD(TO_CHAR(v_MonthlyRevenue, '999,999,999'), 19) || ' |'|| 
                                LPAD(TO_CHAR(NVL(v_PreviousMonthRevenue, 0), '999,999,999'), 33)|| ' |' || 
                                LPAD(TO_CHAR(NVL(v_MonthRevenueChange, 0), '999,999,999'), 20) || ' |');
        END LOOP;

        -- Close the inner cursor
        CLOSE c_MonthlyRevenue;

        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------------------');
    END LOOP;

    -- Close the outer cursor
    CLOSE c_YearlyRevenue;

    DBMS_OUTPUT.PUT_LINE('|' || RPAD('-', 90, '-') || '|');
    DBMS_OUTPUT.PUT_LINE('|' || RPAD(' ', 39) || RPAD('End of Report', 51, ' ') || '|');
    DBMS_OUTPUT.PUT_LINE('|' || RPAD('-', 90, '-') || '|');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/
