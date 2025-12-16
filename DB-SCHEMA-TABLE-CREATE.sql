
IF DB_ID('SqlMiniProject') IS NULL
BEGIN
    CREATE DATABASE SqlMiniProject;
END
GO

USE SqlMiniProject;
GO


IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'app')
BEGIN
    EXEC('CREATE SCHEMA app');
END
GO

IF OBJECT_ID('app.Shipments', 'U')   IS NOT NULL DROP TABLE app.Shipments;
IF OBJECT_ID('app.Payments', 'U')    IS NOT NULL DROP TABLE app.Payments;
IF OBJECT_ID('app.OrderItems', 'U')  IS NOT NULL DROP TABLE app.OrderItems;
IF OBJECT_ID('app.Orders', 'U')      IS NOT NULL DROP TABLE app.Orders;
IF OBJECT_ID('app.Products', 'U')    IS NOT NULL DROP TABLE app.Products;
IF OBJECT_ID('app.Customers', 'U')   IS NOT NULL DROP TABLE app.Customers;
GO

CREATE TABLE app.Customers (
    CustomerID  INT IDENTITY(1,1) CONSTRAINT PK_Customers PRIMARY KEY,
    FullName    NVARCHAR(200) NOT NULL,
    Email       NVARCHAR(320) NULL,
    Country     NVARCHAR(100) NULL,
    SignupDate  DATE NOT NULL CONSTRAINT DF_Customers_SignupDate DEFAULT (CONVERT(date, GETDATE())),
    CONSTRAINT UQ_Customers_Email UNIQUE (Email)
);
GO

CREATE TABLE app.Products (
    ProductID   INT IDENTITY(1,1) CONSTRAINT PK_Products PRIMARY KEY,
    SKU         NVARCHAR(50)  NOT NULL CONSTRAINT UQ_Products_SKU UNIQUE,
    ProductName NVARCHAR(200) NOT NULL,
    Category    NVARCHAR(100) NOT NULL,
    ListPrice   DECIMAL(12,2) NOT NULL CONSTRAINT CK_Products_ListPrice_NonNegative CHECK (ListPrice >= 0),
    IsActive    BIT NOT NULL CONSTRAINT DF_Products_IsActive DEFAULT (1)
);
GO

CREATE TABLE app.Orders (
    OrderID     INT IDENTITY(1,1) CONSTRAINT PK_Orders PRIMARY KEY,
    CustomerID  INT NOT NULL,
    OrderDate   DATETIME2(0) NOT NULL CONSTRAINT DF_Orders_OrderDate DEFAULT (SYSDATETIME()),
    Status      NVARCHAR(30) NOT NULL,
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerID) REFERENCES app.Customers(CustomerID),
    CONSTRAINT CK_Orders_Status CHECK (Status IN ('Processing','Shipped','Delivered','Cancelled','Returned'))
);
GO

CREATE TABLE app.OrderItems (
    OrderItemID INT IDENTITY(1,1) CONSTRAINT PK_OrderItems PRIMARY KEY,
    OrderID     INT NOT NULL,
    ProductID   INT NOT NULL,
    Quantity    INT NOT NULL CONSTRAINT CK_OrderItems_Qty_Positive CHECK (Quantity > 0),
    UnitPrice   DECIMAL(12,2) NOT NULL CONSTRAINT CK_OrderItems_UnitPrice_NonNegative CHECK (UnitPrice >= 0),
    CONSTRAINT FK_OrderItems_Orders   FOREIGN KEY (OrderID)   REFERENCES app.Orders(OrderID),
    CONSTRAINT FK_OrderItems_Products FOREIGN KEY (ProductID) REFERENCES app.Products(ProductID),
    CONSTRAINT UQ_OrderItems_Order_Product UNIQUE (OrderID, ProductID)
);
GO

CREATE TABLE app.Payments (
    PaymentID   INT IDENTITY(1,1) CONSTRAINT PK_Payments PRIMARY KEY,
    OrderID     INT NOT NULL,
    PaidDate    DATETIME2(0) NOT NULL CONSTRAINT DF_Payments_PaidDate DEFAULT (SYSDATETIME()),
    Method      NVARCHAR(30) NOT NULL,
    Amount      DECIMAL(12,2) NOT NULL CONSTRAINT CK_Payments_Amount_Positive CHECK (Amount > 0),
    CONSTRAINT FK_Payments_Orders FOREIGN KEY (OrderID) REFERENCES app.Orders(OrderID),
    CONSTRAINT CK_Payments_Method CHECK (Method IN ('Card','EFT','Cash','Wallet','Voucher'))
);
GO

CREATE TABLE app.Shipments (
    ShipmentID    INT IDENTITY(1,1) CONSTRAINT PK_Shipments PRIMARY KEY,
    OrderID       INT NOT NULL,
    Carrier       NVARCHAR(60) NOT NULL,
    ShippedDate   DATETIME2(0) NULL,
    DeliveredDate DATETIME2(0) NULL,
    TrackingNo    NVARCHAR(80) NULL,
    CONSTRAINT FK_Shipments_Orders FOREIGN KEY (OrderID) REFERENCES app.Orders(OrderID),
    CONSTRAINT CK_Shipments_Dates CHECK (DeliveredDate IS NULL OR ShippedDate IS NULL OR DeliveredDate >= ShippedDate)
);
GO


CREATE INDEX IX_Orders_CustomerID_OrderDate ON app.Orders(CustomerID, OrderDate);
CREATE INDEX IX_OrderItems_OrderID          ON app.OrderItems(OrderID);
CREATE INDEX IX_OrderItems_ProductID        ON app.OrderItems(ProductID);
CREATE INDEX IX_Payments_OrderID_PaidDate   ON app.Payments(OrderID, PaidDate);
CREATE INDEX IX_Shipments_OrderID           ON app.Shipments(OrderID);
GO


SELECT 'Customers'  AS TableName, COUNT(*) AS Rows FROM app.Customers
UNION ALL
SELECT 'Products',  COUNT(*) FROM app.Products
UNION ALL
SELECT 'Orders',    COUNT(*) FROM app.Orders
UNION ALL
SELECT 'OrderItems',COUNT(*) FROM app.OrderItems
UNION ALL
SELECT 'Payments',  COUNT(*) FROM app.Payments
UNION ALL
SELECT 'Shipments', COUNT(*) FROM app.Shipments;
GO
