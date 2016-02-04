local configuration = {
level = 2,
scene = "vole-whacking",
parentScene = "onion-patch",
levelTime = 10,
startingHealth = 15,
maxLives = 30,
veggie = "beet",
numberHoles = 6,
voleFrequency = 1000,
voleSpeed = 1000,
birdFrequencyLow = 2000,
birdFrequencyHigh = 5000,
birdSpeed = 3000,
deerFrequencyLow = 3000,
deerFrequencyHigh = 5000,
deerSpeed = 3000,
catStreak = 2,
deerStreak = 3,
eagleStreak = 4,
birdsInLevel = false,
deerInLevel = false,
-- gameType options - score, achieveStreaks, finishStreaks
objective = { gameType = "achieveStreaks", number = 10, cats = 1, eagles = 0, dogs = 0},
target1 = 10,
target2 = 60,
target3 = 70,
--ground booster options - zapRow, zapAll, speedUp, slowDown
groundBoosters = {"zapRow", "zapAll"},
----ground booster frequency - number between 2 and infinity. Greater the number, less frequent boosters.
groundBoosterFreq = 2,
levelStartBoosters = {"slowDown"},
levelStartBoostersMax = {slowDown = 1},
}

return configuration