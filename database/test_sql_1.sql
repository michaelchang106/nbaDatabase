-- GRAB FULL DETAILS OF PLAYERS NAMED "JAYLEN"

WITH playersByPosition AS (
SELECT *
FROM Players
JOIN Players_Positions ON Players.playerID = Players_Positions.playerID),

playersFullDetails AS (
SELECT *
FROM playersByPosition
JOIN Employees ON playersByPosition.employeeID = Employees.employeeID),

playersFullDetails_w_Pos_Desc AS (
SELECT *
FROM playersFullDetails
JOIN Positions ON Positions.positionID = playersFullDetails.positionID)

SELECT *
FROM playersFullDetails_w_Pos_Desc
WHERE firstName = "Jaylen"






