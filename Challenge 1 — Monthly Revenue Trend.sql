SELECT DATEPART(MONTH,PaidDate) AS MONTH,
	   DATEPART(YEAR, PaidDate) AS YEAR,
		SUM(Amount) AS TotalRevenueEarned
FROM SqlMiniProject.app.Payments
GROUP BY 
	DATEPART(MONTH, PaidDate),
	DATEPART(YEAR, PaidDate)
ORDER BY
	YEAR, MONTH;
