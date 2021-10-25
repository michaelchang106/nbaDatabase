WITH nbaCoachDetails AS (
SELECT *
FROM Coaches
JOIN Employees ON Employees.employeeID = Coaches.employeeID)

SELECT *
FROM nbaCoachDetails
WHERE nbaCoachDetails.yearsOfExp >= 10