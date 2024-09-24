SET SERVEROUTPUT ON
SET linesize 100
SET pagesize 100

COLUMN ItemID FORMAT A20 HEADING 'Item ID'
COLUMN Name   FORMAT A50 HEADING 'Item Name'
COLUMN TotalQuantitySold FORMAT 999,999 HEADING 'Quantity'
COLUMN TotalAmount FORMAT 999,999.00 HEADING 'Total Revenue (RM)'

ACCEPT v_Year NUMBER PROMPT 'Enter year: '

TTITLE CENTER 'Top 10 Items Sold in &v_year' -
RIGHT 'Page: ' FORMAT 99 SQL.PNO SKIP 2 


CREATE OR REPLACE VIEW TopItemsSold AS
SELECT *
FROM (
    SELECT 
        i.ItemID AS ItemID,
        i.Name AS Name,
        SUM(p.Quantity) AS TotalQuantitySold,
        SUM(p.TotalAmount) AS TotalAmount
    FROM 
        Items i
    JOIN 
        Purchase p ON i.ItemID = p.ItemID
    WHERE
        EXTRACT(YEAR FROM p.purchaseDate) = &v_year
    GROUP BY 
        i.ItemID, i.Name
    ORDER BY 
        TotalQuantitySold DESC
)
WHERE ROWNUM <= 10;

SELECT * FROM TopItemsSold;

CLEAR COLUMNS
TTITLE OFF;


