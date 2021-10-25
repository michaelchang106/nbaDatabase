-- COUNT THE PLAYERS ON THE TEAM AND LIST/PARTITION THEM BY TEAM WITH DETAILS

SELECT 
	E.employeeID, 
	E.firstName, 
	E.lastName, 
	E.birthDate, 
	E.teamID, 
	L.city,
	T.name, 
	T.abbreviation,
	COUNT(E.teamID) OVER (PARTITION BY T.name) AS totalPlayersOnTeam
FROM Employees as E
JOIN Teams as T ON T.teamID = E.teamID
JOIN Locations as L ON T.locationID = L.locationID
WHERE E.employeeType = 1