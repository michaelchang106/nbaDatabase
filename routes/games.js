const express = require("express");
const router = express.Router();
const nbaDB = require("../database/nbaSQLiteDB.js");

// helper functions
async function calculateWinsAndLosses(teams) {
  let teamsWinsAndLosses = {};

  //loop thru each team and calcuate wins and losses
  await teams.forEach(async (team) => {
    let teamAbbrv = team.abbreviation;

    let teamID = team.teamID;
    let wins = await nbaDB.countWins(teamID);
    let losses = await nbaDB.countLosses(teamID);

    teamsWinsAndLosses[teamAbbrv] = [wins.teamWins, losses.teamLosses];
    console.log(teamsWinsAndLosses, "--------------INSIDE CALL BACK");
  });
  // WHY IS THIS NOT KEEPING THE DATA INSERTED BY THE FOREACH CALLBACK?!?!?!?!
  console.log(teamsWinsAndLosses, "--------------OUTSIDE CALL BACK");
  return teamsWinsAndLosses;
}

// helper functions
async function getAllDates() {
  const allGames = await nbaDB.getGames();
  let allDates = new Set();

  //loop thru each team and calcuate wins and losses
  allGames.forEach((game) => {
    if (!allDates.has(game.date)) {
      allDates.add(game.date);
    }
  });
  return Array.from(allDates);
}

/* GET /games page. */
router.get("/", async function (req, res) {
  console.log("Got request for /games");
  const games = await nbaDB.getGames();
  const teams = await nbaDB.getTeams();
  const teamsWinsAndLosses = await calculateWinsAndLosses(teams);

  const allDates = await getAllDates();
  console.log("Got Games");
  try {
    console.log("TRYING TO RENDER");
    res.render("games", {
      games: games,
      teams: teams,
      teamsWinsAndLosses: teamsWinsAndLosses,
      allDates: allDates,
    });
  } catch (error) {
    console.log("CAUGHT AN ERORR TRYING TO RENDER");
    res.render(error, {
      error: error,
      message: "There was an error, please fix and try again",
    });
  }
});

/* POST /games/insertGame. */
router.post("/insertGame", async function (req, res) {
  console.log("Got request for /insertGame");
  const homeTeam = req.body.homeTeam;
  const awayTeam = req.body.awayTeam;
  let date = req.body.date;

  date = date.replace(/^0+/, "");

  try {
    await nbaDB.insertGame(homeTeam, awayTeam, date);
    console.log(
      "Inserted game with home team:",
      homeTeam,
      "and away team:",
      awayTeam, "on", date,
    );
    res.status("200").redirect("/games");
  } catch (error) {
    console.log("CAUGHT AN ERORR TRYING TO INSERT");
    res.render("error", {
      error: error,
      message: "There was an error, please fix and try again",
    });
  }
});

/* POST /games/deleteGame. */
router.post("/deleteGame", async function (req, res) {
  console.log("Got request for /deleteGame");
  const gameID = req.body.gameID;

  try {
    await nbaDB.deleteGame(gameID);
    console.log("Deleted Game", gameID);
    res.status("200").redirect("/games");
  } catch (error) {
    console.log("CAUGHT AN ERORR TRYING TO DELETE GAME");
    res.render("error", {
      error: error,
      message: "There was an error, please fix and try again",
    });
  }
});

/* POST /games/filterBy. */
router.post("/filterBy", async function (req, res) {
  console.log("Got request for /filterBy");
  const teamID = req.body.teamID;
  const date = req.body.date;

  let query = {};
  let games;

  // specify which SQLite query to use based on date && teamID
  // date and teamID are empty
  if (teamID === "" && date === "") {
    res.status("200").redirect("/games");
    return;
    // date is empty
  } else if (date === "") {
    query = { teamID: teamID };
    games = await nbaDB.filterGamesByTeam(query);
    // teamID is empty
  } else if (teamID === "") {
    query = { date: date };
    games = await nbaDB.filterGamesByDate(query);
    // date and teamID are both present
  } else if (!(teamID === "") && !(date === "")) {
    query = { teamID: teamID, date: date };
    games = await nbaDB.filterGamesByTeamAndDate(query);
  }

  const allDates = await getAllDates();
  const teams = await nbaDB.getTeams();
  const teamsWinsAndLosses = await calculateWinsAndLosses(teams);

  console.log("Got Games filterBy");
  try {
    console.log("TRYING TO RENDER");
    res.render("games", {
      games: games,
      teams: teams,
      teamsWinsAndLosses: teamsWinsAndLosses,
      allDates: allDates,
    });
  } catch (error) {
    console.log("CAUGHT AN ERORR TRYING TO RENDER");
    res.render(error, {
      error: error,
      message: "There was an error, please fix and try again",
    });
  }
});

module.exports = router;
