-- Set up formatting for the report
SET LINESIZE 180
SET PAGESIZE 150
SET SERVEROUTPUT ON


-- Prompt for campaign ID input
ACCEPT campaign_id PROMPT 'Enter the Campaign ID : '

-- Title formatting for the report
TTITLE LEFT 'Booking Report Made on the Promotion within Campaign ID ' &campaign_id -
SKIP 2

-- Column formatting
COLUMN promotion_id FORMAT A20 HEADING 'Promotion_ID' JUSTIFY LEFT
COLUMN promotion_code FORMAT A25 HEADING 'Promotion_Code' JUSTIFY LEFT
COLUMN discount FORMAT A20 HEADING 'Discount Percentage' JUSTIFY LEFT
COLUMN booking_id FORMAT A20 HEADING 'Booking_ID' JUSTIFY LEFT
COLUMN booking_date FORMAT A15 HEADING 'Booking_Date' JUSTIFY LEFT
COLUMN booking_price FORMAT A20 HEADING 'Total Price'JUSTIFY LEFT
COLUMN campaign FORMAT A15 HEADING 'Campaign ID' JUSTIFY LEFT

-- Main query to retrieve the booking report
SELECT 
    b.BookingID AS booking_id,
    p.PromotionID AS promotion_id,
    b.BookingDate AS booking_date,
    '$ ' || TO_CHAR(b.TotalPrice, '99999.99') AS booking_price,
    p.PromotionCode AS promotion_code,
    TO_CHAR(p.DiscountPercentage, '99990') || '%' AS discount,
    c.CampaignID AS campaign
FROM 
    Booking b
JOIN 
    Promotions p ON b.PromotionID = p.PromotionID
JOIN 
    Campaign c ON p.CampaignID = c.CampaignID
WHERE 
    c.CampaignID = '&campaign_id'
ORDER BY 
    b.BookingDate;

-- Total number of bookings and total booking price
SELECT 
    COUNT(b.BookingID) AS "Total Bookings" ,
    '$ ' || TO_CHAR(SUM(b.TotalPrice), '99999.99') AS "Total Booking Price"
FROM 
    Booking b
JOIN 
    Promotions p ON b.PromotionID = p.PromotionID
JOIN 
    Campaign c ON p.CampaignID = c.CampaignID
WHERE 
    c.CampaignID = '&campaign_id';

-- Turn off title and formatting settings
TTITLE OFF
CLEAR COLUMNS
CLEAR BREAKS
