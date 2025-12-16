SELECT  
SUM(CASE WHEN S.DeliveredDate IS NULL THEN 1 ELSE 0 END) AS DidNotArrive,
SUM(CASE WHEN S.DeliveredDate IS NOT NULL THEN 1 ELSE 0 END) AS DidArrive
FROM SqlMiniProject.app.Shipments S


SELECT S.DeliveredDate, S.Carrier, S.TrackingNo, 
    CASE WHEN S.DeliveredDate IS NULL THEN 'Did Not Arrive' WHEN S.DeliveredDate IS NOT NULL 
    THEN 'Did Arrive' END AS DelivStatus 
FROM SqlMiniProject.app.Shipments S
