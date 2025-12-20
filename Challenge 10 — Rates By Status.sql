SELECT
    O.Status,
    COUNT(*) AS COUNT_OF_STATUS
INTO SqlMiniProject.app.OrderStatusCounts
FROM SqlMiniProject.app.Orders O
GROUP BY O.Status;

SELECT * FROM SqlMiniProject.app.OrderStatusCounts;

SELECT 
    OSC.Status,
    ROUND((OSC.COUNT_OF_STATUS * 100.0 / 
    SUM(OSC.COUNT_OF_STATUS) OVER ()),2) AS Status_Percentage
FROM SqlMiniProject.app.OrderStatusCounts OSC;
