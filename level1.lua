local configuration = {
level = 1,
scene = "planting",
parentScene = "onion-patch",
levelTime = 60,
startingHealth = 10,
maxLives = 30,
veggie = "beet",
numberHoles = 12,
voleFrequency = 1000,
voleSpeed = 1000,
birdFrequencyLow = 2000,
birdFrequencyHigh = 5000,
birdSpeed = 4000,
deerFrequencyLow = 5000,
deerFrequencyHigh = 10000,
deerSpeed = 1000,
birdsInLevel = true,
deerInLevel = true,
-- gameType options - score, achieveStreaks, finishStreaks ---- planting, harvesting, for special levels
objective = { gameType = "planting", number = 30, cats = 0, eagles = 0, dogs = 0},
--target 1 should match number in objective
target1 = 50,
target2 = 60,
target3 = 70,
--ground booster options - zapRow, zapAll, speedUp, slowDown
groundBoosters = {"zapRow", "zapAll"},
----ground booster frequency - number between 2 and infinity. Greater the number, less frequent boosters.
groundBoosterFreq = 2,
seedSpeed = 3000,
seedFrequency = 700,
seeds = {"onion-seed", "beet-seed", "carrot-seed", "turnip-seed"},
targetSeed = "onion-seed",
--levelStartBooster options - slowDown
levelStartBoosters = {"slowDown"},
--must be in the same order as level Start Boosters and all must match
levelStartBoostersMax = {slowDown = 1},
}

return configuration