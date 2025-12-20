SELECT OI.UnitPrice * OI.Quantity AS ORDER_PRICE, 
        P.Amount AS PAYMENT_AMOUNT ,
       P.Amount - (OI.Quantity * OI.UnitPrice) AS DIFFERENCE_IN_MARKET_VS_RETAIL_PRICE
       FROM SqlMiniProject.app.OrderItems OI
  LEFT JOIN SqlMiniProject.app.Payments P ON OI.OrderID = P.OrderID;
