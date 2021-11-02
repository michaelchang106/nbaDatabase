-- SEE WHICH COACHES HAVE EXPERIENCE OF 10 YEARS OR GREATER

WITH nbaCoachDetails AS (
SELECT *
FROM Coaches
JOIN Employees ON Employees.employeeID = Coaches.employeeID)

SELECT *
FROM nbaCoachDetails
WHERE nbaCoachDetails.yearsOfExp >= 10