local configuration = {
level = 3,
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
birdsInLevel = true,
deerInLevel = true,
-- gameType options - score, achieveStreaks, finishStreaks ---- planting, harvesting, for special levels
objective = { gameType = "harvesting", number = 30, cats = 0, eagles = 0, dogs = 0},
--target 1 should match number in objective
target1 = 40,
target2 = 50,
target3 = 60,
--ground booster options - zapRow, zapAll, speedUp, slowDown
groundBoosters = {"zapRow", "zapAll"},
----ground booster frequency - number between 2 and infinity. Greater the number, less frequent boosters.
groundBoosterFreq = 2,
seedSpeed = 3000,
seedFrequency = 700,
seeds = {"onion-seed", "beet-seed", "carrot-seed", "turnip-seed"},
targetSeed = "onion-seed",
--levelStartBooster options - slow-down
levelStartBoosters = {"slow-down"}
}

return configuration