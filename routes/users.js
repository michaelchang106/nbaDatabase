<<<<<<< HEAD
const express = require("express");
const router = express.Router();

/* GET users listing. */
router.get("/", function (req, res, next) {
  res.send("respond with a resource");
});
=======
var express = require("express");
var router = express.Router();

// const myDB = require("../db/sqliteDBmanager.js");
// /* GET users listing. */
// router.get("/", function (req, res) {
//   console.log("Got requrest for '/'");

//   const players = await myDB.getPlayers();

//   res.send(players);
// });
>>>>>>> 72c9b456d9e87c6ead814e839b636f5b54244d16

module.exports = router;
