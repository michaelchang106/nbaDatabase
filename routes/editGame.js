const express = require("express");
const router = express.Router();
const nbaDB = require("../database/nbaSQLiteDB.js");

/* POST home page. */
router.post("/", async function (req, res, next) {
  console.log("Got request for /editGame");
  const gameID = req.body.gameID;
  const homeTeam = req.body.homeTeam;
  const awayTeam = req.body.awayTeam;
  const date = String(req.body.date);

  try {
    const gameFromDB = await nbaDB.getSingleGame(gameID);
    // check if the form data is the same and user didn't edit somehow
    if (
      gameFromDB.gameID == gameID &&
      gameFromDB.homeTeam == homeTeam &&
      gameFromDB.awayTeam == awayTeam &&
      gameFromDB.date == date
    ) {
      // create a gameObject
      const gameObjectFromDB = {
        gameID: gameFromDB.gameID,
        winTeam: gameFromDB.winTeam,
        loseTeam: gameFromDB.loseTeam,
        homeTeam: gameFromDB.homeTeam,
        awayTeam: gameFromDB.awayTeam,
        date: gameFromDB.date,
        homeName: gameFromDB.name,
        homeAbbreviation: gameFromDB.abbreviation,
        awayName: gameFromDB.awayName,
        awayAbbreviation: gameFromDB.awayAbbreviation,
      };
      res.status("200").render("editGame", { gameObjectFromDB });
    } else {
      console.log("Game data from frontEnd doesn't match database");
      throw new Error("Game data doesn't match database");
    }
  } catch (error) {
    console.log("CAUGHT AN ERORR TRYING TO UPDATE");
    res.render("error", {
      error: error,
      message: "There was an error, please fix and try again",
    });
  }
});

/* POST editGameUpdate page. */
router.post("/editGameUpdate", async function (req, res, next) {
  console.log("Got request for /editGameUpdate");
  const gameID = req.body.gameID;
  const winTeam = req.body.winTeam;
  const loseTeam = req.body.loseTeam;

  try {
    await nbaDB.updateGameResult(gameID, winTeam, loseTeam);
    console.log("Updated Game Details in DB");
    res.status("200").redirect("/games");
  } catch (error) {
    console.log("CAUGHT AN ERORR TRYING TO UPDATE");
    res.render("error", {
      error: error,
      message: "There was an error, please fix and try again",
    });
  }
});

module.exports = router;
