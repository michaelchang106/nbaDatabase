-- GRAB FULL DETAILS OF PLAYERS LAST NAME LIKE "%SON%"

WITH playersFullDetails AS (
SELECT *
FROM Players
JOIN Players_Positions ON Players.playerID = Players_Positions.playerID
JOIN Employees ON Employees.employeeID = Players.employeeID
JOIN Positions ON Positions.positionID = Players_Positions.positionID)


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
FROM playersFullDetails AS P
JOIN Teams ON Teams.teamID = P.teamID
WHERE lastName LIKE "%SON%"
GROUP BY 1
ORDER BY 1







