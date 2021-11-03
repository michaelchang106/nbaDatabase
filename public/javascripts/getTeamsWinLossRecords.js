// let teamsWinsAndLosses = {};
// const nbaDB = require(".../database/nbaSQLiteDB.js");

// let getTeamsWinLossRecords = async function (teams) {;
//   //loop thru each team and calcuate wins and losses
//   await teams.forEach(async (team) => {
//     let teamAbbrv = String(team.abbreviation);

//     let teamID = team.teamID;
//     let wins = await nbaDB.countWins(teamID);
//     let losses = await nbaDB.countLosses(teamID);

//     teamsWinsAndLosses[teamAbbrv] = [wins.teamWins, losses.teamLosses];
//     console.log(teamsWinsAndLosses, "--------------INSIDE CALL BACK");
//   });
//   // WHY IS THIS NOT KEEPING THE DATA INSERTED BY THE FOREACH CALLBACK?!?!?!?!
//   console.log(teamsWinsAndLosses, "--------------RIGHT HERE");
//   return teamsWinsAndLosses;
// };


// module.exports = getTeamsWinLossRecords;