local configuration = {
level = 1,
scene = "harvesting",
parentScene = "onion-patch",
levelTime = 60,
startingHealth = 10,
maxLives = 30,
veggie = "beet",
numberHoles = 6,
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
-- gameType options - score, achieveStreaks, finishStreaks ---- planting, harvesting, for special levels
objective = { gameType = "harvesting", number = 30, cats = 0, eagles = 0, dogs = 0},
--target 1 should match number
target1 = 10,
target2 = 30,
target3 = 50,
--ground booster options - zapRow, zapAll, speedUp, slowDown
groundBoosters = {"zapRow", "zapAll"},
----ground booster frequency - number between 2 and infinity. Greater the number, less frequent boosters.
groundBoosterFreq = 2,
seedSpeed = 3000,
seedFrequency = 700,
seeds = {"onion-seed", "beet-seed", "carrot-seed", "turnip-seed"},
targetSeed = "onion-seed"
}

return configuration