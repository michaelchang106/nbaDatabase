-- GRAB FULL DETAILS OF PLAYERS LAST NAME LIKE "%SON%"
-- JOIN 3 MORE TALBES --WITH (CTE/Subquery)
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

-- SEE WHICH COACHES HAVE EXPERIENCE OF 10 YEARS OR GREATER
-- WITH (CTE/Subquery)
WITH nbaCoachDetails AS (
SELECT *
FROM Coaches
JOIN Employees ON Employees.employeeID = Coaches.employeeID)

SELECT *
FROM nbaCoachDetails
WHERE nbaCoachDetails.yearsOfExp >= 10

-- COUNT THE PLAYERS ON THE TEAM AND LIST/PARTITION THEM BY TEAM WITH DETAILS
-- JOIN MORE THAN 3 TABLES --PARTION BY
SELECT 
	E.employeeID, 
	E.firstName, 
	E.lastName, 
	E.birthDate, 
	Pos.positionDesc,
	E.teamID, 
	L.city,
	T.name, 
	T.abbreviation,
	COUNT(E.teamID) OVER (PARTITION BY T.name) AS totalPlayersOnTeam
FROM Employees as E
JOIN Teams AS T ON T.teamID = E.teamID
JOIN Locations AS L ON T.locationID = L.locationID
JOIN Players AS P ON P.employeeID = E.employeeID
JOIN Players_Positions AS PP ON P.playerID = PP.playerID
JOIN Positions AS Pos ON Pos.positionID = PP.positionID
WHERE E.employeeTypeID = 1
GROUP BY E.employeeID
ORDER BY 6

-- SEE WHICH TEAMS HAVE LESS THAN 12 ACTIVE PLAYERS
-- GROUP BY, HAVING
SELECT Teams.name, COUNT(Employees.teamID) AS totalPlayersOnTeam
FROM Employees
JOIN Teams ON Teams.teamID = Employees.teamID
WHERE employeeTypeID = 1
GROUP BY Teams.name
HAVING totalPlayersOnTeam <= 13


-- FIND TEAMS HAVING 4 OR MORE CENTERS
-- GROUP BY, HAVING --JOIN 3 OR MORE TABLES
SELECT Employees.teamID, Teams.name, Positions.positionDesc, COUNT(Positions.positionID) AS totalNumAtPosition
FROM Employees
JOIN Players ON Employees.employeeID = Players.employeeID
JOIN Players_Positions ON Players_Positions.playerID = Players.playerID
JOIN Positions ON Players_Positions.positionID = Positions.positionID
JOIN Teams ON Teams.teamID = Employees.teamID
GROUP BY Employees.teamID, Positions.positionDesc
HAVING Positions.positionDesc = "C" AND totalNumAtPosition >= 4

-- FIND ALL PLAYERS THAT PLAY MORE THAN ONE POSITIONS
-- GROUP BY, HAVING --JOIN 3 OR MORE TABLES -- SELECT CASE WHEN THEN
SELECT Employees.employeeID, Employees.firstName, Employees.lastName,
(CASE WHEN 
	COUNT(Players_Positions.playerID) > 1
THEN
	"Multiple Positions Played"
END) AS Multiple_Position_Players
FROM Players_Positions
JOIN Players ON Players.playerID = Players_Positions.playerID
JOIN Employees ON Employees.employeeID = Players.employeeID
GROUP BY Players_Positions.playerID
HAVING Multiple_Position_Players NOT NULL


-- FIND WIN RECORD OF TEAMS SORTED DESC
-- GROUP BY, ORDER BY
SELECT Teams.teamID, Teams.abbreviation, Teams.name, count(winTeam) AS Wins
FROM Teams
LEFT JOIN Games ON Games.winTeam = Teams.teamID
GROUP BY 1
ORDER BY 4 DESC

-- FIND LOSE RECORD OF TEAMS SORTED ASC
-- GROUP BY, ORDER BY
SELECT Teams.teamID, Teams.abbreviation, Teams.name, count(loseTeam) AS Losses
FROM Teams
LEFT JOIN Games ON Games.loseTeam = Teams.teamID
GROUP BY 1
ORDER BY 4






