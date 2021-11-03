const sqlite3 = require("sqlite3").verbose();
const { open } = require("sqlite");

async function connect() {
  return open({
    filename: "./database/nba-db.db",
    driver: sqlite3.Database,
  });
}

async function getGames() {
  const db = await connect();
  try {
    // console.log("Connected to nbaDB to Get Games");
    return await db.all(`
      WITH gamesWithAwayTeamsNames AS (
      SELECT gameID, date, awayTeam, name AS awayName, abbreviation AS awayAbbreviation, winTeam, loseTeam, homeTeam
      FROM Games
      JOIN Teams ON Teams.teamID = Games.awayTeam)

      SELECT gameID, date, awayTeam, awayName, awayAbbreviation, homeTeam, name AS homeName, abbreviation as homeAbbreviation, winTeam, loseTeam
      FROM gamesWithAwayTeamsNames
      JOIN Teams ON Teams.teamID = gamesWithAwayTeamsNames.homeTeam;`);
  } catch (error) {
    console.log(error);
    throw new Error(error);
  } finally {
    db.close();
  }
}

async function getSingleGame(gameID) {
  const db = await connect();
  try {
    // console.log("Connected to nbaDB to get a Single Game");
    return await db.get(`
      WITH gameWithAwayTeamName AS (
      SELECT gameID, date, awayTeam, name AS awayName, abbreviation AS awayAbbreviation, winTeam, loseTeam, homeTeam
      FROM Games
      JOIN Teams ON Teams.teamID = Games.awayTeam
      WHERE Games.gameID = ${gameID})

      SELECT gameID, date, awayTeam, awayName, awayAbbreviation, homeTeam, name, abbreviation, winTeam, loseTeam
      FROM gameWithAwayTeamName
      JOIN Teams ON Teams.teamID = gameWithAwayTeamName.homeTeam
      WHERE gameWithAwayTeamName.gameID = ${gameID};`);
  } catch (error) {
    console.log(error);
    throw new Error(error);
  } finally {
    db.close();
  }
}

async function getTeams() {
  const db = await connect();
  try {
    // console.log("Connected to nbaDB to get Teams");
    return await db.all(`
      SELECT * FROM Teams;`);
  } catch (error) {
    console.log(error);
    throw new Error(error);
  } finally {
    db.close();
  }
}

async function filterGamesByTeam(query) {
  const db = await connect();
  try {
    console.log("Connected to nbaDB to Get Filtered Games By Team Only");
    return await db.all(`
      WITH gamesWithAwayTeamsNames  AS (
      SELECT gameID, homeTeam, awayTeam, name AS awayName, abbreviation AS awayAbbreviation, winTeam, loseTeam, date
      FROM Games
      JOIN Teams ON Games.awayTeam = Teams.teamID)

      SELECT gameID, homeTeam, awayTeam, name AS homeName, awayName,  abbreviation AS homeAbbreviation, awayAbbreviation, winTeam, loseTeam, date
      FROM gamesWithAwayTeamsNames
      JOIN Teams ON Teams.teamID = gamesWithAwayTeamsNames.homeTeam
      WHERE gamesWithAwayTeamsNames.homeTeam = ${query.teamID} OR gamesWithAwayTeamsNames.awayTeam = ${query.teamID};`);
  } catch (error) {
    console.log(error);
    throw new Error(error);
  } finally {
    db.close();
  }
}

async function filterGamesByDate(query) {
  const db = await connect();
  console.log(query.date, typeof query.date, query.date.length);
  try {
    console.log("Connected to nbaDB to Get Filtered Games By Date Only");
    return await db.all(`
      WITH gamesWithAwayTeamsNames AS (
      SELECT gameID, homeTeam, awayTeam, name AS awayName, abbreviation AS awayAbbreviation, winTeam, loseTeam, date
      FROM Games
      JOIN Teams ON Teams.teamID = awayTeam
      WHERE Games.date = "${query.date}")
    
      SELECT gameID, homeTeam, awayTeam, awayName, name AS homeName, awayAbbreviation, abbreviation AS homeAbbreviation, winTeam, loseTeam, date
      FROM gamesWithAwayTeamsNames
      JOIN Teams ON Teams.teamID = gamesWithAwayTeamsNames.homeTeam
      WHERE gamesWithAwayTeamsNames.date = "${query.date}";`);
  } catch (error) {
    console.log(error);
    throw new Error(error);
  } finally {
    db.close();
  }
}

async function filterGamesByTeamAndDate(query) {
  const db = await connect();
  try {
    console.log("Connected to nbaDB to Get Filtered Games By Team AND DATE");
    return await db.all(`
      WITH gamesWithAwayTeamsNames AS (
      SELECT gameID, homeTeam, awayTeam, name AS awayName, abbreviation AS awayAbbreviation, winTeam, loseTeam, date
      FROM Games
      JOIN Teams ON Teams.teamID = awayTeam
      WHERE Games.date = "${query.date}")
    
      SELECT gameID, homeTeam, awayTeam, awayName, name AS homeName, awayAbbreviation, abbreviation AS homeAbbreviation, winTeam, loseTeam, date
      FROM gamesWithAwayTeamsNames
      JOIN Teams ON Teams.teamID = gamesWithAwayTeamsNames.homeTeam
      WHERE gamesWithAwayTeamsNames.date = "${query.date}" AND 
      gamesWithAwayTeamsNames.homeTeam = ${query.teamID} OR 
      gamesWithAwayTeamsNames.awayTeam = ${query.teamID};`);
  } catch (error) {
    console.log(error);
    throw new Error(error);
  } finally {
    db.close();
  }
}

async function insertGame(homeTeam, awayTeam, date) {
  const db = await connect();
  try {
    // console.log("Connected to nbaDB to insert a Game");
    return await db.run(`
      INSERT INTO Games (homeTeam, awayTeam, date)
      VALUES (${homeTeam}, ${awayTeam}, "${date}")`);
  } catch (error) {
    console.log(error);
    throw new Error(error);
  } finally {
    db.close();
  }
}

async function updateGameResult(gameID, winTeam, loseTeam) {
  const db = await connect();
  try {
    // console.log("Connected to nbaDB update a Game");
    return await db.run(`
      UPDATE Games
      SET winTeam = ${winTeam}, loseTeam = ${loseTeam}
      WHERE gameID = ${gameID}`);
  } catch (error) {
    console.log(error);
    throw new Error(error);
  } finally {
    db.close();
  }
}

async function deleteGame(gameID) {
  const db = await connect();
  try {
    // console.log("Connected to nbaDB to delete a Game");
    return await db.run(`
      DELETE FROM Games
      WHERE gameID = ${gameID}`);
  } catch (error) {
    console.log(error);
    throw new Error(error);
  } finally {
    db.close();
  }
}

async function countWins(teamID) {
  const db = await connect();
  try {
    // console.log("Connected to nbaDB to countWins");
    const wins = await db.get(`
      SELECT COUNT(gameID) AS teamWins
      FROM Games
      WHERE winTeam = ${teamID}`);

    return wins;
  } catch (error) {
    console.log(error);
    throw new Error(error);
  } finally {
    db.close();
  }
}

async function countLosses(teamID) {
  const db = await connect();
  try {
    // console.log("Connected to nbaDB to countLosses");
    const losses = await db.get(`
      SELECT COUNT(gameID) AS teamLosses
      FROM Games
      WHERE loseTeam = ${teamID}`);

    return losses;
  } catch (error) {
    console.log(error);
    throw new Error(error);
  } finally {
    db.close();
  }
}

module.exports.getGames = getGames;
module.exports.getSingleGame = getSingleGame;
module.exports.getTeams = getTeams;
module.exports.insertGame = insertGame;
module.exports.updateGameResult = updateGameResult;
module.exports.deleteGame = deleteGame;
module.exports.countWins = countWins;
module.exports.countLosses = countLosses;
module.exports.filterGamesByTeam = filterGamesByTeam;
module.exports.filterGamesByDate = filterGamesByDate;
module.exports.filterGamesByTeamAndDate = filterGamesByTeamAndDate;
