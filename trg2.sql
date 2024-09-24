DROP TABLE ItemsAudit;
DROP SEQUENCE items_audit_seq;
CREATE SEQUENCE items_audit_seq
minvalue 0
maxvalue 999
START WITH 0
INCREMENT BY 1
NOCACHE; 

CREATE TABLE ItemsAudit (
    AuditID       VARCHAR(10) PRIMARY KEY,
    OperationType VARCHAR(10),
    ItemID        VARCHAR(10),
    OldName       VARCHAR(50),
    NewName       VARCHAR(50),
    OldDescription VARCHAR(50),
    NewDescription VARCHAR(50),
    OldPrice      NUMBER(5, 2),
    NewPrice      NUMBER(5, 2),
    OldStockQuantity NUMBER(5),
    NewStockQuantity NUMBER(5),
    ChangeDate    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE TRIGGER trg_items_audit
AFTER INSERT OR UPDATE OR DELETE ON Items
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO ItemsAudit (
            AuditID, OperationType, ItemID, NewName, NewDescription, NewPrice, NewStockQuantity
        ) 
        VALUES (
            'IA' || TO_CHAR(items_audit_seq.NEXTVAL, 'FM000'),
            'INSERT', :NEW.ItemID, :NEW.Name, :NEW.Description, :NEW.Price, :NEW.StockQuantity
        );

    ELSIF UPDATING THEN
        INSERT INTO ItemsAudit (
            AuditID, OperationType, ItemID, OldName, NewName, OldDescription, NewDescription, OldPrice, NewPrice, OldStockQuantity, NewStockQuantity
        ) 
        VALUES (
            'IA' || TO_CHAR(items_audit_seq.NEXTVAL, 'FM000'), 
            'UPDATE', :OLD.ItemID, :OLD.Name, :NEW.Name, :OLD.Description, :NEW.Description, :OLD.Price, :NEW.Price, :OLD.StockQuantity, :NEW.StockQuantity
        );

    ELSIF DELETING THEN
        INSERT INTO ItemsAudit (
            AuditID, OperationType, ItemID, OldName, OldDescription, OldPrice, OldStockQuantity
        ) 
        VALUES (
            'IA' || TO_CHAR(items_audit_seq.NEXTVAL, 'FM000'), 
            'DELETE', :OLD.ItemID, :OLD.Name, :OLD.Description, :OLD.Price, :OLD.StockQuantity
        );
    END IF;
END;
/
INSERT INTO Items (ItemID, Name, Description, Price, StockQuantity) 
VALUES ('I0112', 'Travel Bag', 'Compact carry-on travel bag', 45.99, 60);

SET SERVEROUTPUT ON
SET linesize 300
SET pagesize 100

COLUMN AuditID FORMAT A10 HEADING 'Audit ID'
COLUMN OperationType FORMAT A15 HEADING 'Operation Type'
COLUMN ItemID FORMAT A10 HEADING 'Item ID'
COLUMN OldName FORMAT A20 HEADING 'Old Name'
COLUMN NewName FORMAT A20 HEADING 'New Name'
COLUMN OldDescription FORMAT A30 HEADING 'Old Description'
COLUMN NewDescription FORMAT A30 HEADING 'New Description'
COLUMN OldPrice FORMAT 999,999.99 HEADING 'Old Price'
COLUMN NewPrice FORMAT 999,999.99 HEADING 'New Price'
COLUMN OldStockQuantity FORMAT 999,999 HEADING 'Old Stock Quantity'
COLUMN NewStockQuantity FORMAT 999,999 HEADING 'New Stock Quantity'
COLUMN ChangeDate FORMAT A25 HEADING 'Change Date'

select * from ItemsAudit;

CLEAR COLUMNS 
