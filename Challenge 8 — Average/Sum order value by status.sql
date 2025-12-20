SELECT 
    P.Method, CONCAT('R', ROUND(AVG(OI.Quantity * OI.UnitPrice), 2)) AS Order_Gross_sale
FROM SqlMiniProject.app.Orders O
LEFT JOIN SqlMiniProject.app.OrderItems OI 
    ON O.OrderID = OI.OrderID
LEFT JOIN SqlMiniProject.app.Payments P 
    ON OI.OrderID = P.OrderID
WHERE P.Method IS NOT NULL
GROUP BY P.Method

-----------------------------------

SELECT 
    P.Method, CONCAT('R', ROUND(SUM(OI.Quantity * OI.UnitPrice), 2)) AS Order_Gross_sale
FROM SqlMiniProject.app.Orders O
LEFT JOIN SqlMiniProject.app.OrderItems OI 
    ON O.OrderID = OI.OrderID
LEFT JOIN SqlMiniProject.app.Payments P 
    ON OI.OrderID = P.OrderID
WHERE P.Method IS NOT NULL
GROUP BY P.Method
;
