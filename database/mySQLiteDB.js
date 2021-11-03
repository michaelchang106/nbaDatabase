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
  const db = await connect();
  try {
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
  } finally {
    await db.close();
  }
}

async function getTeams() {
  const db = await connect();
  try {
    const query = "SELECT * FROM Teams";
    return await db.all(query);
  } catch (error) {
    console.log(error);
  } finally {
    await db.close();
  }
}

async function getCoach(team) {
  const db = await connect();

  try {
    const query = `SELECT  * FROM Employees JOIN 
                Teams ON  Teams.teamID = Employees.teamID WHERE 
                name = "${team}" AND employeeTypeID = 2;`;
    return await db.all(query);
  } catch (error) {
    console.log(error);
  } finally {
    await db.close();
  }
}

async function deletePlayer(player) {
  const db = await connect();
  try {
    console.log("player to delete:", player);

    const query = `DELETE FROM Players_Positions WHERE playerID = ${player.playerID};
    // DELETE FROM Players WHERE playerID = ${player.playerID};
    // DELETE FROM Employees WHERE employeeID = ${player.employeeID};`;

    return await db.run(query);
  } catch (error) {
    console.log(error);
  } finally {
    await db.close();
  }
}

async function createNewEmployee(newEmployee) {
  const db = await connect();
  try {
    console.log("createNewEmployee --->", newEmployee);
    const teamIDObj = await getTeamID(newEmployee.team);
    const teamID = teamIDObj.teamID;

    let firstName = newEmployee.firstName;
    let lastName = newEmployee.lastName;
    let birthDate = newEmployee.birthDate;

    // Created a stmt for Employee Table
    const stmt1 = `INSERT INTO 
      Employees (firstName, lastName, birthDate, teamID, employeeTypeID) 
      VALUES("${firstName}", "${lastName}","${birthDate}", ${teamID},${1})`;

    console.log("<------ Added data to Employees Table -------->");
    await db.run(stmt1);

    // Will insert into Players table
    const newEmployeeID = await db.get(
      "SELECT employeeID FROM Employees ORDER BY employeeID DESC LIMIT 1;"
    ); //Grabs newly made EmployeeID

    const employeeID = newEmployeeID.employeeID;
    // console.log(newEmployeeID.employeeID);

    let height = newEmployee.height;
    let weight = newEmployee.weight;
    let jerseyNum = newEmployee.jerseyNum;

    const stmt2 = `INSERT INTO 
      Players (height, weight, jerseyNum, employeeID) 
      VALUES("${height}", "${weight}","${jerseyNum}", ${employeeID})`;
    console.log("<------ Added data to Players Table -------->");
    await db.run(stmt2);

    const newPlayerID = await db.get(
      "SELECT playerID FROM Players ORDER BY playerID DESC LIMIT 1;"
    ); //Grabs newly made EmployeeID
    console.log("------------------>", newEmployee.positionID);

    const stmt3 = `INSERT INTO 
      Players_Positions (playerID, positionID) 
      VALUES("${newPlayerID.playerID}", "${newEmployee.positionID}")`;

    await db.run(stmt3);
    console.log("<------ Added data to Position to Table -------->");

    console.log(stmt3);
  } catch (error) {
    console.log(error);
  } finally {
    await db.close();
  }
}

async function getTeamID(teamName) {
  const db = await connect();
  try {
    const query = `SELECT teamID FROM Teams WHERE name = "${teamName}"`;
    return db.get(query);
  } catch (error) {
    console.log(error);
  } finally {
    await db.close();
  }
}

async function editPlayer(player) {
  const db = await connect();
  try {
    console.log("Editing: ", player);

    const employeeID = Number(player.employeeID);

    const query1 = `UPDATE Employees SET firstName = "${player.firstName}", lastName = "${player.lastName}" WHERE employeeID = ${employeeID}`;
    const query2 = `UPDATE Players SET weight = ${player.weight}, jerseyNum = ${player.jerseyNum} WHERE employeeID = ${employeeID}`;
    await db.run(query1);
    await db.run(query2);

    return;
  } catch (error) {
    console.log(error);
  } finally {
    await db.close();
  }
}
module.exports.getTeamPlayers = getTeamPlayers;
module.exports.getTeams = getTeams;
module.exports.getCoach = getCoach;
module.exports.createNewEmployee = createNewEmployee;
module.exports.deletePlayer = deletePlayer;
module.exports.editPlayer = editPlayer;
