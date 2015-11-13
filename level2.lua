local configuration = {
level = 2,
scene = "scene1",
parentScene = "onion-patch",
levelTime = 35,
startingHealth = 15,
maxLives = 30,
veggie = "beet.png",
numberHoles = 9,
voleFrequency = 1000,
voleSpeed = 1000,
birdFrequencyLow = 2000,
birdFrequencyHigh = 5000,
birdSpeed = 3000,
deerFrequencyLow = 3000,
deerFrequencyHigh = 5000,
deerSpeed = 5000,
catStreak = 2,
deerStreak = 3,
eagleStreak = 4,
birdsInLevel = true,
deerInLevel = true,
-- gameType options - score, achieveStreaks, finishStreaks
objective = { gameType = "finishStreaks", number = 0, cats = 2, eagles = 0, dogs = 0},
target1 = 20,
target2 = 40,
target3 = 60
}

return configuration