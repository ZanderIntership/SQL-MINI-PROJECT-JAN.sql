SELECT  TOP 20 C.Country,CONCAT('R',SUM(P.Amount)) FROM SqlMiniProject.app.Payments P
    LEFT JOIN SqlMiniProject.app.Orders O 
    ON P.OrderID = O.OrderID
    LEFT JOIN SqlMiniProject.app.Customers C 
    ON O.CustomerID = C.CustomerID
GROUP BY C.Country;
