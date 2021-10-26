CREATE TABLE sqlite_sequence(name,seq);
CREATE TABLE IF NOT EXISTS "Employee_Types" (
	"employeeTypeID"	INTEGER NOT NULL,
	"employeeType"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("employeeTypeID" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "Locations" (
	"locationID"	INTEGER NOT NULL,
	"city"	TEXT NOT NULL,
	"state"	TEXT NOT NULL,
	PRIMARY KEY("locationID" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "Players_Positions" (
	"playerID"	INTEGER NOT NULL,
	"positionID"	INTEGER NOT NULL,
	PRIMARY KEY("playerID","positionID"),
	FOREIGN KEY("positionID") REFERENCES "Positions"("positionID"),
	FOREIGN KEY("playerID") REFERENCES "Players"("playerID")
);
CREATE TRIGGER LocationsConstraintUpdate
BEFORE UPDATE ON Locations
BEGIN
  SELECT CASE WHEN city || state = NEW.city || NEW.state
  THEN 
    RAISE(ABORT, "Two cities in the same location")
  END
  FROM Locations;
END;
CREATE TABLE IF NOT EXISTS "Games" (
	"gameID"	INTEGER NOT NULL,
	"homeTeam"	INTEGER NOT NULL CHECK("homeTeam" != "awayTeam"),
	"awayTeam"	INTEGER NOT NULL CHECK("awayTeam" != "homeTeam"),
	"winTeam"	INTEGER CHECK("winTeam" != "loseTeam" AND ("winTeam" = "awayTeam" OR "winTeam" = "homeTeam")),
	"loseTeam"	INTEGER CHECK("loseTeam" != "winTeam" AND ("loseTeam" = "awayTeam" OR "loseTeam" = "homeTeam")),
	"date"	TEXT NOT NULL,
	PRIMARY KEY("gameID" AUTOINCREMENT),
	FOREIGN KEY("homeTeam") REFERENCES "Teams"("teamID"),
	FOREIGN KEY("awayTeam") REFERENCES "Teams"("teamID"),
	FOREIGN KEY("loseTeam") REFERENCES "Teams"("teamID"),
	FOREIGN KEY("winTeam") REFERENCES "Teams"("teamID")
);
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
END;
CREATE TABLE IF NOT EXISTS "Positions" (
	"positionID"	INTEGER NOT NULL,
	"positionDesc"	TEXT NOT NULL CHECK("positionDesc" IN ("G","F", "C")),
	PRIMARY KEY("positionID" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "Teams" (
	"teamID"	INTEGER NOT NULL,
	"name"	TEXT NOT NULL UNIQUE,
	"abbreviation"	TEXT NOT NULL UNIQUE,
	"locationID"	INTEGER NOT NULL,
	PRIMARY KEY("teamID" AUTOINCREMENT),
	FOREIGN KEY("locationID") REFERENCES "Locations"("locationID")
);
CREATE TRIGGER LocationsConstraintInsert
BEFORE INSERT ON Locations
BEGIN
  SELECT CASE WHEN city || state = NEW.city || NEW.state
  THEN 
    RAISE(ABORT, "Two cities in the same location")
  END
  FROM Locations;
END;
CREATE TRIGGER NoTeamSameDayInsert
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
END;
CREATE TRIGGER winTeamAndLoseTeamNotNullUpdate
BEFORE UPDATE OF winTeam, loseTeam ON Games
BEGIN
  SELECT CASE WHEN 
    (NEW.winTeam NOT NULL AND NEW.loseTeam IS NULL) OR (NEW.loseTeam NOT NULL AND NEW.winTeam IS NULL)
	THEN
	RAISE(ABORT, "Need to fill out both Win Team and Lose Team")
    END;
END;
CREATE TRIGGER winTeamAndLoseTeamNotNullInsert
BEFORE INSERT ON Games
BEGIN
  SELECT CASE WHEN 
    (NEW.winTeam NOT NULL AND NEW.loseTeam IS NULL) OR (NEW.loseTeam NOT NULL AND NEW.winTeam IS NULL)
	THEN
	RAISE(ABORT, "Need to fill out both Win Team and Lose Team")
    END;
END;
CREATE TABLE IF NOT EXISTS "Employees" (
	"employeeID"	INTEGER NOT NULL,
	"firstName"	TEXT NOT NULL,
	"lastName"	TEXT NOT NULL,
	"birthDate"	TEXT NOT NULL,
	"teamID"	INTEGER,
	"employeeTypeID"	INTEGER NOT NULL,
	PRIMARY KEY("employeeID" AUTOINCREMENT),
	FOREIGN KEY("teamID") REFERENCES "Teams"("teamID"),
	FOREIGN KEY("employeeTypeID") REFERENCES "Employee_Types"("employeeTypeID")
);
CREATE TRIGGER NotEnoughPlayersInsert

BEFORE INSERT ON Games

BEGIN
  WITH winningTeamCount AS (
  SELECT COUNT(teamID) AS playerCountWinningTeam
    FROM "Employees"
    WHERE teamID = NEW.winTeam AND employeeTypeID=1)
  
   SELECT CASE
    WHEN
    (playerCountWinningTeam IS NULL OR playerCountWinningTeam < 5) AND NEW.winTeam NOT NULL
    THEN
    RAISE(ABORT, "Not Enough Players on win team" )
    
    WHEN
    playerCountWinningTeam > 15 AND NEW.winTeam NOT NULL
    THEN
    RAISE(ABORT, "Too many Players on win team" )
    END
  FROM winningTeamCount;

	WITH losingTeamCount AS (
    SELECT COUNT(teamID) AS playerCountLosingTeam
    FROM "Employees"
    WHERE teamID = NEW.loseTeam AND employeeTypeID=1)
   SELECT CASE
    WHEN
    (playerCountLosingTeam IS NULL OR playerCountLosingTeam < 5) AND NEW.loseTeam NOT NULL
    THEN
    RAISE(ABORT, "Not Enough Players on lose team" )
    
    WHEN
       playerCountLosingTeam > 15 AND NEW.loseTeam NOT NULL
    THEN
    RAISE(ABORT, "Too many Players on lose team" )
    END
  FROM losingTeamCount;
  
  END;
CREATE TABLE IF NOT EXISTS "Coaches" (
	"coachID"	INTEGER NOT NULL,
	"yearsOfExp"	INTEGER NOT NULL CHECK("yearsOfExp" >= 0),
	"employeeID"	INTEGER NOT NULL,
	PRIMARY KEY("coachID" AUTOINCREMENT),
	FOREIGN KEY("employeeID") REFERENCES "Employees"("employeeID")
);
CREATE TABLE IF NOT EXISTS "Players" (
	"playerID"	INTEGER NOT NULL,
	"height"	REAL NOT NULL CHECK("height" > 0),
	"weight"	REAL NOT NULL CHECK("weight" > 0),
	"jerseyNum"	INTEGER NOT NULL CHECK("jerseyNum" >= 0 AND "jerseyNum" < 100),
	"employeeID"	INTEGER NOT NULL,
	PRIMARY KEY("playerID" AUTOINCREMENT),
	FOREIGN KEY("employeeID") REFERENCES "Employees"("employeeID")
);
CREATE TABLE IF NOT EXISTS "Trades" (
	"tradeID"	INTEGER NOT NULL,
	"employeeID"	INTEGER NOT NULL,
	"teamFrom"	INTEGER NOT NULL CHECK("teamFrom" != "teamTo"),
	"teamTo"	INTEGER NOT NULL CHECK("teamTo" != "teamFrom"),
	"tradeDate"	TEXT NOT NULL,
	PRIMARY KEY("tradeID" AUTOINCREMENT),
	FOREIGN KEY("employeeID") REFERENCES "Employees"("employeeID"),
	FOREIGN KEY("teamTo") REFERENCES "Teams"("teamID"),
	FOREIGN KEY("teamFrom") REFERENCES "Teams"("teamID")
);
CREATE TRIGGER TradePlayerDelete
	AFTER DELETE ON Trades
	BEGIN
		UPDATE "Employees"
			SET teamID = OLD.teamFrom
			WHERE employeeID = OLD.employeeID;
	END;
CREATE TRIGGER TradePlayerUpdate
	AFTER INSERT ON Trades
	BEGIN
		UPDATE "Employees"
			SET teamID = NEW.teamTo
			WHERE employeeID = NEW.employeeID;
	END;
CREATE TRIGGER NotEnoughPlayersUpdate

BEFORE UPDATE OF winTeam, loseTeam ON Games

BEGIN
  WITH winningTeamCount AS (
  SELECT COUNT(teamID) AS playerCountWinningTeam
    FROM "Employees"
    WHERE teamID = NEW.winTeam AND employeeTypeID=1)
  
   SELECT CASE
    WHEN
    (playerCountWinningTeam IS NULL OR playerCountWinningTeam < 5) AND NEW.winTeam NOT NULL
    THEN
    RAISE(ABORT, "Not Enough Players on win team" )
    
    WHEN
    playerCountWinningTeam > 15 AND NEW.winTeam NOT NULL
    THEN
    RAISE(ABORT, "Too many Players on win team" )
    END
  FROM winningTeamCount;

	WITH losingTeamCount AS (
    SELECT COUNT(teamID) AS playerCountLosingTeam
    FROM "Employees"
    WHERE teamID = NEW.loseTeam AND employeeTypeID=1)
   SELECT CASE
    WHEN
    (playerCountLosingTeam IS NULL OR playerCountLosingTeam < 5) AND NEW.loseTeam NOT NULL
    THEN
    RAISE(ABORT, "Not Enough Players on lose team" )
    
    WHEN
       playerCountLosingTeam > 15 AND NEW.loseTeam NOT NULL
    THEN
    RAISE(ABORT, "Too many Players on lose team" )
    END
  FROM losingTeamCount;
  
  END;
CREATE TRIGGER TeamFromConstraintInsert
 BEFORE INSERT ON Trades
BEGIN
	SELECT CASE
		WHEN (SELECT teamID FROM "Employees" WHERE employeeID = NEW.employeeID) != NEW.teamFrom
		THEN RAISE (ABORT, "Select correct teamFrom for Employee")
	END
	FROM "Employees";
END;
CREATE TRIGGER TeamToConstraintInsert
 BEFORE INSERT ON Trades
BEGIN
	SELECT CASE
		WHEN (SELECT teamID FROM "Employees" WHERE employeeID = NEW.employeeID) = NEW.teamTo
		THEN RAISE (ABORT, "Cannot trade employee to the employee's current team")
	END
	FROM "Employees";
END;
CREATE TRIGGER CoachToTeamConstraintInsert
AFTER INSERT ON "Employees"
BEGIN
  SELECT CASE WHEN 
    (SELECT COUNT(teamID) 
      FROM "Employees"
      WHERE teamID = NEW.teamID AND employeeTypeID = 2) > 1 -- B/c we check before update
      THEN RAISE(ABORT, "Can't have more than 1 head coach")
    END;
END;
CREATE TRIGGER CoachToTeamConstraintUpdate
AFTER UPDATE of teamID, employeeTypeID ON "Employees"
BEGIN
  SELECT CASE WHEN 
    (SELECT COUNT(teamID) 
    FROM "Employees"
    WHERE teamID = NEW.teamID AND employeeTypeID = 2) > 1 -- B/c we check before update
      THEN RAISE(ABORT, "Can't have more than 1 head coach")
  END;
END;
CREATE TRIGGER NoMoreThan41GamesInsert
BEFORE INSERT ON "Games"
BEGIN
  SELECT CASE WHEN 
    (SELECT COUNT(homeTeam) 
      FROM "Games"
      WHERE homeTeam = NEW.homeTeam) >= 41
      THEN RAISE(ABORT, "Can't have more than 41 home games")
    END;
	
	  SELECT CASE WHEN 
    (SELECT COUNT(awayTeam) 
      FROM "Games"
      WHERE awayTeam = NEW.awayTeam) >= 41
      THEN RAISE(ABORT, "Can't have more than 41 away games")
    END;
END;
CREATE TRIGGER NoMoreThan41GamesUpdate
BEFORE UPDATE OF homeTeam, awayTeam ON "Games"
BEGIN
  SELECT CASE WHEN 
    (SELECT COUNT(homeTeam) 
      FROM "Games"
      WHERE homeTeam = NEW.homeTeam) >= 41
      THEN RAISE(ABORT, "Can't have more than 41 home games")
    END;
	
	  SELECT CASE WHEN 
    (SELECT COUNT(awayTeam) 
      FROM "Games"
      WHERE awayTeam = NEW.awayTeam) >= 41
      THEN RAISE(ABORT, "Can't have more than 41 away games")
    END;
END;
