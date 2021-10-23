
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
      WHERE (teamID = NEW.teamID AND New.employeeType = 1)
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
      WHERE teamID = (NEW.teamID AND New.employeeType = 2)
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
    WHERE (teamID = NEW.teamID AND NEW.employeeType = 2)
    GROUP BY teamID) >= 1
      THEN RAISE(ABORT, "Can't have more than 1 head coach")
  END;
END

-- Prevents a city that already exist from being added to the same state twice.
CREATE TRIGGER LocationsConstraint
BEFORE INSERT ON Locations
BEGIN
  SELECT CASE WHEN city || state = NEW.city || NEW.state
  THEN 
    RAISE(ABORT, "Two cities in the same location")
  END
  FROM Locations;
END


-- Prevents a city update were a city already exist at the same state twice.
CREATE TRIGGER LocationsConstraintUpdate
BEFORE UPDATE ON Locations
BEGIN
  SELECT CASE WHEN city || state = NEW.city || NEW.state
  THEN 
    RAISE(ABORT, "Two cities in the same location")
  END
  FROM Locations;
END

SELECT CASE WHEN
  (SELECT COUNT(teamID), teamID 
  FROM Employees 
  WHERE teamID = 1 AND employeeType=1 
  GROUP BY teamID) < 5
THEN
  SELECT "YES"


-- Prevents a the update of a games win/loss if the team has less than 5 players.
CREATE TRIGGER NotEnoughPlayers
BEFORE UPDATE OF winTeam, loseTeam ON Games
BEGIN
  SELECT CASE 
  -- Not Enough Players on the Home Team
  WHEN
    (SELECT COUNT(teamID) 
    FROM Employees 
    WHERE teamID = NEW.homeTeam AND employeeType=1 
    GROUP BY teamID) IS NULL
  THEN
    RAISE(ABORT, "Not Enough Players on home team" )
  WHEN
    (SELECT COUNT(teamID) 
    FROM Employees 
    WHERE teamID = NEW.homeTeam AND employeeType=1 
    GROUP BY teamID) < 5
  THEN
    RAISE(ABORT, "Not Enough Players on home team")
  
  -- Not Enough Players on the Away Team
  WHEN
    (SELECT COUNT(teamID) 
    FROM Employees 
    WHERE teamID = NEW.awayTeam AND employeeType=1 
    GROUP BY teamID) IS NULL 
  THEN
    RAISE(ABORT, "Not Enough Players on away team" )
  WHEN
    (SELECT COUNT(teamID) 
    FROM Employees 
    WHERE teamID = NEW.awayTeam AND employeeType=1 
    GROUP BY teamID) < 5
    THEN
    RAISE(ABORT, "Not Enough Players on away  team")
  
  END;
END


--Prevents a user from inserting a game where the away or home team is already scheduled to play that day
CREATE TRIGGER NoTeamSameDay
BEFORE INSERT ON Games
BEGIN
  SELECT CASE
      WHEN  (homeTeam || " | " || date) = (NEW.homeTeam || " | " || NEW.date) OR (awayTeam || " | " || date) =  (NEW.homeTeam || " | " || NEW.date)
      THEN
        RAISE(ABORT, "Home team is already playing on this date")
      WHEN  (awayTeam || " | " || date) = (NEW.awayTeam || " | " || NEW.date)  OR (homeTeam || " | " || date) = (NEW.awayTeam || " | " || NEW.date)
      THEN
        RAISE(ABORT, "Away Team team is already playing on this date")
      END
  FROM Games;
END

--Prevents a user from updating the awayTeam or homeTeam if it results in either team being scheduled on the same day.
CREATE TRIGGER NoTeamSameDayUpdate
BEFORE UPDATE OF awayTeam, homeTeam ON Games
BEGIN
  SELECT CASE
      WHEN  (homeTeam || " | " || date) = (NEW.homeTeam || " | " || NEW.date) OR (awayTeam || " | " || date) =  (NEW.homeTeam || " | " || NEW.date)
      THEN
        RAISE(ABORT, "Home team is already playing on this date")
      WHEN  (awayTeam || " | " || date) = (NEW.awayTeam || " | " || NEW.date)  OR (homeTeam || " | " || date) = (NEW.awayTeam || " | " || NEW.date)
      THEN
        RAISE(ABORT, "Away Team team is already playing on this date")
      END
  FROM Games;
END
