-- COUNT THE PLAYERS ON THE TEAM AND LIST/PARTITION THEM BY TEAM

SELECT *, Teams.name, COUNT(Employees.teamID) OVER (PARTITION BY Teams.name)
FROM Employees
JOIN Teams ON Teams.teamID = Employees.teamID
WHERE employeeType = 1