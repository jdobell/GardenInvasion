local configuration = {
level = 1,
scene = "scene1",
parentScene = "onion-patch",
levelTime = 25,
startingHealth = 10,
maxLives = 30,
veggie = "beet.png",
numberHoles = 9,
voleFrequency = 1000,
voleSpeed = 1000,
birdFrequencyLow = 2000,
birdFrequencyHigh = 5000,
birdSpeed = 4000,
deerFrequencyLow = 5000,
deerFrequencyHigh = 10000,
deerSpeed = 1000,
catStreak = 2,
deerStreak = 3,
eagleStreak = 15,
birdsInLevel = false,
deerInLevel = false,
-- gameType options - score, achieveStreaks, finishStreaks
objective = { gameType = "score", number = 10, cats = 0, eagles = 0, dogs = 0},
target1 = 10,
target2 = 30,
target3 = 50,
--ground booster options - zapRow, zapAll, speedUp, slowDown
groundBoosters = {"zapRow"},
----ground booster frequency - number between 2 and infinity. Greater the number, less frequent boosters.
groundBoosterFreq = 2
}

return configuration