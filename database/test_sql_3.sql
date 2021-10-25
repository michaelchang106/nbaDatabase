-- COUNT THE PLAYERS ON THE TEAM AND LIST/PARTITION THEM BY TEAM WITH DETAILS

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
WHERE E.employeeType = 1
GROUP BY E.employeeID
ORDER BY 6
