const sqlite3 = require("sqlite3");
const { open } = require("sqlite");

sqlite3.verbose();

async function connect() {
  return open({
    filename: "./database/nba-db.db",
    driver: sqlite3.Database,
  });
}

async function getTeamPlayers(team) {
  try {
    const db = await connect();
    const query = `WITH playersFullDetails AS (
      SELECT *
      FROM Players
      JOIN Players_Positions ON Players.playerID = Players_Positions.playerID
      JOIN Employees ON Employees.employeeID = Players.employeeID
      JOIN Positions ON Positions.positionID = Players_Positions.positionID)

      SELECT 
        P.employeeID,
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
      WHERE name = '${team}' GROUP BY  firstName, lastName;`;
    return await db.all(query);
  } catch (error) {
    console.log(error);
  }
}

async function getTeams() {
  try {
    const query = "SELECT * FROM Teams";
    const db = await connect();
    return await db.all(query);
  } catch (error) {
    console.log(error);
  }
}

async function getCoach(team) {
  try {
    const query = `SELECT  * FROM Employees JOIN 
                Teams ON  Teams.teamID = Employees.teamID WHERE 
                name = "${team}" AND employeeTypeID = 2;`;

    const db = await connect();
    return await db.all(query);
  } catch (error) {
    console.log(error);
  }
}

async function deletePlayer(player) {
  const db = await connect();

  console.log("player to delete:", player);

  const stmt = await db.prepare(
    `DELETE FROM Players_Positions WHERE playerID = :playerID;
    DELETE FROM Players WHERE playerID = :playerID;
    DELETE FROM Employees WHERE employeeID = :employeeID;`
  );

  stmt.bind({ ":playerID": player.playerID, ":employeeID": ":employeeID" });

  return await stmt.run();
}

async function createNewEmployee(newEmployee) {
  try {
    const db = await connect();
    console.log("Createing New Employee", newEmployee);
    const teamIDObj = await getTeamID(newEmployee.team);

    const insertEmployeeInfo = `INSERT INTO Employees (firstName, lastName, birthDate, teamID, employeeTypeID)
    VALUES("${newEmployee.firstName}", "${newEmployee.lastName}", "${
      newEmployee.birthDate
    }", ${teamIDObj.teamID}, ${1})`;

    await db.run(insertEmployeeInfo);

    //Update Attributes

    const employeeObj = await db.get(
      "SELECT * FROM Employees ORDER BY employeeID DESC LIMIT 1;"
    ); //Get the last value

    const employeeID = employeeObj.employeeID;

    console.log("---->", employeeID);

    const insertAttr = `INSERT INTO Employees (height, weight, jerseyNum, employeeID) 
    VALUES(${newEmployee.height}, ${newEmployee.weight}, ${
      newEmployee.jerseyNum
    }, ${Number(employeeID)})`;
    await db.run(insertAttr);
    return;
  } catch (error) {
    console.log(error);
  }
}

async function getTeamID(teamName) {
  const db = await connect();
  const query = `SELECT teamID FROM Teams WHERE name = "${teamName}"`;
  return db.get(query);
}

async function editPlayer(player) {
  try {
    const db = await connect();
    console.log("Editing: ", player);

    const employeeID = Number(player.employeeID);

    // });
    await db.run(query1);
    await db.run(query2);

    return;
  } catch (error) {
    console.log(error);
  }
}
module.exports.getTeamPlayers = getTeamPlayers;
module.exports.getTeams = getTeams;
module.exports.getCoach = getCoach;
module.exports.createNewEmployee = createNewEmployee;
module.exports.deletePlayer = deletePlayer;
module.exports.editPlayer = editPlayer;
