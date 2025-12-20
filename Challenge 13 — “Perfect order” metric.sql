
SELECT SUM(CASE 
    WHEN O.Status = 'Delivered' AND P.PaidDate IS NOT NULL AND S.DeliveredDate IS NOT NULL THEN 1
    ELSE 0
    END) AS PERFECT_ORDERS,
    COUNT(*) - SUM(CASE 
    WHEN O.Status = 'Delivered' AND P.PaidDate IS NOT NULL AND S.DeliveredDate IS NOT NULL THEN 1
    ELSE 0
    END) AS NON_PERFECT_ORDERS,
    COUNT(CASE 
    WHEN O.Status = 'Delivered' AND P.PaidDate IS NOT NULL AND S.DeliveredDate IS NOT NULL THEN 1
    ELSE 0
    END) AS TOTAL_ORDERS
FROM SqlMiniProject.app.Orders O
LEFT JOIN SqlMiniProject.app.Payments P ON O.OrderID = P.OrderID
LEFT JOIN SqlMiniProject.app.Shipments S ON P.OrderID = S.OrderID;
