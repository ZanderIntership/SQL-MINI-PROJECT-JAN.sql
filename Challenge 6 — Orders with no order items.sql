SELECT *,
    CASE
    WHEN P.IsActive = 1 THEN 'Can put product on shelf'
    ELSE 'Cannot sell these products anymore'
    END AS Shelf_Products
FROM SqlMiniProject.app.Products P;

SELECT  COUNT(*) AS COUNT, p.IsActive FROM SqlMiniProject.app.Products P
    GROUP BY P.IsActive;
