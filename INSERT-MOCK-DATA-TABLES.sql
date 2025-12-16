
INSERT INTO app.Customers (FullName, Email, Country, SignupDate)
SELECT
    CONCAT('Customer ', n),
    CONCAT('customer', n, '@example.com'),
    Country,
    DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 900, CAST(GETDATE() AS DATE))
FROM (
    SELECT TOP (5000)
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
) t
CROSS APPLY (
    SELECT TOP (1) Country
    FROM (VALUES
        ('South Africa'),('Namibia'),('Botswana'),('Kenya'),
        ('Nigeria'),('United Kingdom'),('Germany'),
        ('Netherlands'),('United States'),('India')
    ) c(Country)
    ORDER BY NEWID()
) x;


INSERT INTO app.Products (SKU, ProductName, Category, ListPrice, IsActive)
SELECT
    CONCAT('SKU-', FORMAT(n, '00000')),
    CONCAT('Product ', n),
    Category,
    CAST((ABS(CHECKSUM(NEWID())) % 50000) / 100.0 + 5 AS DECIMAL(12,2)),
    CASE WHEN ABS(CHECKSUM(NEWID())) % 100 < 92 THEN 1 ELSE 0 END
FROM (
    SELECT TOP (300)
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects
) t
CROSS APPLY (
    SELECT TOP (1) Category
    FROM (VALUES
        ('Electronics'),('Home'),('Office'),('Sports'),
        ('Toys'),('Fashion'),('Books'),('Grocery')
    ) c(Category)
    ORDER BY NEWID()
) x;



INSERT INTO app.Orders (CustomerID, OrderDate, Status)
SELECT
    c.CustomerID,
    DATEADD(
        DAY, -ABS(CHECKSUM(NEWID())) % 365,
        DATEADD(SECOND, ABS(CHECKSUM(NEWID())) % 86400, CAST(GETDATE() AS DATETIME2))
    ),
    CASE
        WHEN p < 70 THEN 'Delivered'
        WHEN p < 82 THEN 'Shipped'
        WHEN p < 92 THEN 'Processing'
        WHEN p < 98 THEN 'Cancelled'
        ELSE 'Returned'
    END
FROM (
    SELECT TOP (25000)
           ABS(CHECKSUM(NEWID())) % 100 AS p
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
) r
CROSS APPLY (
    SELECT TOP (1) CustomerID
    FROM app.Customers
    ORDER BY NEWID()
) c;



DECLARE @MaxItemsPerOrder INT = 6;

WITH Num AS (
    SELECT TOP (@MaxItemsPerOrder)
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects
),
ItemCounts AS (
    SELECT
        OrderID,
        1 + ABS(CHECKSUM(NEWID())) % @MaxItemsPerOrder AS ItemCount
    FROM app.Orders
),
Expanded AS (
    SELECT
        ic.OrderID,
        n.n
    FROM ItemCounts ic
    JOIN Num n ON n.n <= ic.ItemCount
),
Picked AS (
    SELECT
        e.OrderID,
        p.ProductID,
        1 + ABS(CHECKSUM(NEWID())) % 4 AS Quantity,
        CAST(p.ListPrice * (0.90 + (ABS(CHECKSUM(NEWID())) % 21) / 100.0) AS DECIMAL(12,2)) AS UnitPrice
    FROM Expanded e
    CROSS APPLY (
        SELECT TOP (1) ProductID, ListPrice
        FROM app.Products
        WHERE IsActive = 1
        ORDER BY NEWID()
    ) p
),
Dedup AS (
    SELECT
        OrderID,
        ProductID,
        MAX(Quantity)  AS Quantity,
        MAX(UnitPrice) AS UnitPrice
    FROM Picked
    GROUP BY OrderID, ProductID
)
INSERT INTO app.OrderItems (OrderID, ProductID, Quantity, UnitPrice)
SELECT OrderID, ProductID, Quantity, UnitPrice
FROM Dedup;



INSERT INTO app.Payments (OrderID, PaidDate, Method, Amount)
SELECT
    o.OrderID,
    DATEADD(HOUR, ABS(CHECKSUM(NEWID())) % 72, o.OrderDate),
    CHOOSE(ABS(CHECKSUM(NEWID())) % 5 + 1,
        'Card','EFT','Cash','Wallet','Voucher'
    ),
    CAST(ot.Total * (0.95 + (ABS(CHECKSUM(NEWID())) % 11) / 100.0) AS DECIMAL(12,2))
FROM app.Orders o
CROSS APPLY (
    SELECT SUM(Quantity * UnitPrice) AS Total
    FROM app.OrderItems oi
    WHERE oi.OrderID = o.OrderID
) ot
WHERE
    ot.Total IS NOT NULL
    AND (
        o.Status IN ('Delivered','Shipped','Processing')
        OR (o.Status = 'Returned'  AND ABS(CHECKSUM(NEWID())) % 100 < 60)
        OR (o.Status = 'Cancelled' AND ABS(CHECKSUM(NEWID())) % 100 < 15)
    );



INSERT INTO app.Shipments (OrderID, Carrier, ShippedDate, DeliveredDate, TrackingNo)
SELECT
    o.OrderID,
    Carrier,
    ShippedDate,
    CASE
        WHEN o.Status IN ('Delivered','Returned')
            THEN DATEADD(DAY, 1 + ABS(CHECKSUM(NEWID())) % 10, ShippedDate)
    END,
    CONCAT('TRK', RIGHT(CONVERT(varchar(40), NEWID()), 10))
FROM app.Orders o
CROSS APPLY (
    SELECT TOP (1) Carrier
    FROM (VALUES
        ('DHL'),('FedEx'),('UPS'),('Aramex'),('DPD'),('LocalCourier')
    ) c(Carrier)
    ORDER BY NEWID()
) c
CROSS APPLY (
    SELECT DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 5, o.OrderDate) AS ShippedDate
) s
WHERE o.Status IN ('Shipped','Delivered','Returned');
