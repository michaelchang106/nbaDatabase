const express = require("express");
const router = express.Router();
const nbaDB = require("../database/nbaSQLiteDB.js");
const getTeamsWinLossRecords = require("../public/javascripts/getTeamsWinLossRecords.js");

/* GET /games page. */
router.get("/", async function (req, res, next) {
  console.log("Got request for /games");
  const games = await nbaDB.getGames();
  const teams = await nbaDB.getTeams();

  let teamsWinsAndLosses = {};

  //loop thru each team and calcuate wins and losses
  await teams.forEach(async (team) => {
    let teamAbbrv = String(team.abbreviation);

    let teamID = team.teamID;
    let wins = await nbaDB.countWins(teamID);
    let losses = await nbaDB.countLosses(teamID);

    teamsWinsAndLosses[teamAbbrv] = [wins.teamWins, losses.teamLosses];
    console.log(teamsWinsAndLosses, "--------------INSIDE CALL BACK");
  });
  // WHY IS THIS NOT KEEPING THE DATA INSERTED BY THE FOREACH CALLBACK?!?!?!?!
  console.log(teamsWinsAndLosses, "--------------RIGHT HERE");
  console.log("Got Games");
  try {
    console.log("TRYING TO RENDER");
    res.render("games", {
      games: games,
      teams: teams,
      teamsWinsAndLosses: teamsWinsAndLosses,
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
router.post("/insertGame", async function (req, res, next) {
  console.log("Got request for /insertGame");
  const homeTeam = req.body.homeTeam;
  const awayTeam = req.body.awayTeam;

  // WHY IS THIS NOT WORKING FOR DATE FORMAT MANIPULATION!?!?!?!
  let date = new Date(req.body.date).toISOString().split("T")[0];
  date = String(date);
  console.log(date);

  try {
    await nbaDB.insertGame(homeTeam, awayTeam, date);
    console.log(
      "Inserted game with home team:",
      homeTeam,
      "and away team:",
      awayTeam
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
router.post("/deleteGame", async function (req, res, next) {
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

/* POST /games/filterByTeamAndDate. */
router.post("/filterByTeamAndDate", async function (req, res, next) {
  console.log("Got request for /filterByTeamAndDate");
  const teamID = req.body.teamID;
  const date = req.body.date;
  console.log(teamID, "TEAM", date, "DATE", typeof date);
  let query = {};
  let games;

  // specicy which SQLite query to use based on date && teamID
  if (teamID === "" && date === "") {
    res.status("200").redirect("/games");
    return;
  } else if (date === "") {
    query = { teamID: teamID };
    games = await nbaDB.filterGamesByTeam(query);
  } else if (teamID === "") {
    query = { date: date };
    games = await nbaDB.filterGamesByDate(query);
    console.log(games, "-----------GAMES by DATE");
  } else if (!(teamID === "") && !(date === "")) {
    query = { teamID: teamID, date: date };
    games = await nbaDB.filterGamesByTeamAndDate(query);
  }

  const teams = await nbaDB.getTeams();
  let teamsWinsAndLosses = {};
  console.log(games, "--------GAMES FILTERED");
  //loop thru each team and calcuate wins and losses
  await teams.forEach(async (team) => {
    let teamAbbrv = String(team.abbreviation);

    let teamID = team.teamID;
    let wins = await nbaDB.countWins(teamID);
    let losses = await nbaDB.countLosses(teamID);

    teamsWinsAndLosses[teamAbbrv] = [wins.teamWins, losses.teamLosses];
    console.log(teamsWinsAndLosses, "--------------INSIDE CALL BACK");
  });
  // WHY IS THIS NOT KEEPING THE DATA INSERTED BY THE FOREACH CALLBACK?!?!?!?!
  console.log(teamsWinsAndLosses, "--------------RIGHT HERE");
  console.log("Got Games filterByTeamAndDate");
  try {
    console.log("TRYING TO RENDER");
    res.render("games", {
      games: games,
      teams: teams,
      teamsWinsAndLosses: teamsWinsAndLosses,
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
