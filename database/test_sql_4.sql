-- SEE WHICH TEAMS HAVE LESS THAN 12 ACTIVE PLAYERS

SELECT Teams.name, COUNT(Employees.teamID) AS totalPlayersOnTeam
FROM Employees
JOIN Teams ON Teams.teamID = Employees.teamID
WHERE employeeType = 1
GROUP BY Teams.name
HAVING totalPlayersOnTeam < 12