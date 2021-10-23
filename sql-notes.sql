
-- Creates a Constraint that prevents a user from adding more than 15 players to a team.
CREATE TRIGGER PlayerToTeamConstraint
BEFORE INSERT ON Employees
BEGIN
  SELECT CASE WHEN 
    (SELECT COUNT(teamID) 
      FROM Employees 
      WHERE (teamID = NEW.teamID AND employeeType = 1)
      GROUP BY teamID) >= 15
      THEN RAISE(ABORT, "Can't have more than 15 players on a team")
    END;
END

-- Prevents user from updating a player employee if it will make more than 15 player on a team.
CREATE TRIGGER PlayerToTeamConstraintUpdate
BEFORE UPDATE of teamID ON Employees
BEGIN
  SELECT CASE WHEN 
    (SELECT COUNT(teamID) 
      FROM Employees 
      WHERE (teamID = NEW.teamID AND employeeType = 1)
      GROUP BY teamID) >= 15
      THEN RAISE(ABORT, "Can't have more than 15 players on a team")
    END;
END

-- Creates a Constraint that prevents a user from adding more than 1 coach to a team.
CREATE TRIGGER CoachToTeamConstraint
BEFORE INSERT ON Employees
BEGIN
  SELECT CASE WHEN 
    (SELECT COUNT(teamID) 
      FROM Employees 
      WHERE teamID = (NEW.teamID AND employeeType = 2)
      GROUP BY teamID) >= 1
      THEN RAISE(ABORT, "Can't have more than 1 head coach")
    END;
END

-- Prevents user from updating a coach employee if it will make more than one coach on a team.
CREATE TRIGGER CoachToTeamConstraintUpdate
BEFORE UPDATE of teamID ON Employees
BEGIN
  SELECT CASE WHEN 
    (SELECT COUNT(teamID) 
    FROM Employees 
    WHERE (teamID = NEW.teamID AND employeeType = 2)
    GROUP BY teamID) >= 1
      THEN RAISE(ABORT, "Can't have more than 1 head coach")
  END;
END

-- Prevents a city that already exist from being added to the same state twice.
CREATE TRIGGER LocatiosRestraint
BEFORE INSERT ON Locations
BEGIN
  SELECT CASE WHEN city || state = NEW.city || NEW.state
  THEN 
    RAISE(ABORT, "Two cities in the same location")
  END
  FROM Locations;
END

