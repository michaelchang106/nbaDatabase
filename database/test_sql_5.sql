-- FIND TEAMS HAVING 4 OR MORE CENTERS

SELECT Employees.teamID, Teams.name, Positions.positionDesc, COUNT(Positions.positionID) AS totalNumAtPosition
FROM Employees
JOIN Players ON Employees.employeeID = Players.employeeID
JOIN Players_Positions ON Players_Positions.playerID = Players.playerID
JOIN Positions ON Players_Positions.positionID = Positions.positionID
JOIN Teams ON Teams.teamID = Employees.teamID
GROUP BY Employees.teamID, Positions.positionDesc
HAVING Positions.positionDesc = "C" AND totalNumAtPosition >= 4