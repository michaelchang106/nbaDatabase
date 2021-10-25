-- GRAB FULL DETAILS OF PLAYERS LAST NAME LIKE "%SON%"

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

SELECT 
	P.playerID,
	P.firstName,
	P.lastName,
	P.birthDate,
	P.height,
	P.weight,
	P.jerseyNum,
	P.positionDesc,
	Teams.abbreviation,
	Teams.name
FROM playersFullDetails_w_Pos_Desc AS P
JOIN Teams ON Teams.teamID = P.teamID
WHERE lastName LIKE "%SON%"
GROUP BY 1
ORDER BY 1







