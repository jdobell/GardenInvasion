---------------------------------------------------------------------------------
--
-- scene.lua
--
---------------------------------------------------------------------------------

local sceneName = ...

local composer = require( "composer" )
local physic = require("physics")
local file = require("mod_file-management")
local globals = require("global-variables")
local _s = globals._s

-- Load scene with same root filename as this file
local scene = composer.newScene( sceneName )

---------------------------------------------------------------------------------

local sceneGroup
local globalSceneGroup
local timers = {}
local time
local timeDisplay
local scoreLabel
local score = 0
local scorePerClick = 10
local levelConfig
local streak = 0
local countdownTimer
local levelComplete
local bonus = 0
local bonusLabel
local bonusAmountLabel
local bonusItems = true
local gameOverLabel
local wiltedIndex
local veggiesAffectedPerChange
local maxLives
local health
local healthIndicatorMove
local healthIndicatorStart
local catBonus = 25
local eagleBonus = 50
local dogBonus = 100
local veggieBonus = 10
local catsAchieved = 0
local eaglesAchieved = 0
local dogsAchieved = 0
local targetBoard
local target1Achieved = false
local target2Achieved = false
local target3Achieved = false
local gameEnded = false
local gameOverCompleted = false
local groundBoosters
local voleSpeed
local numberZappedVoles = 0
local zappedVoles = {}
local voleTimer
local volesPaused = false

----------------------------Vole sprite setup --------------------------------
local holes = {}
local voleSheetOptions =
{
    width = 25,
    height = 20,
    numFrames = 2
}

local sequences_touchedVole = {
    -- consecutive frames sequence
    {
        name = "voleTouched",
        start = 1,
        count = 2,
        time = 100,
        loopCount = 1,
        loopDirection = "forward"
    }
}

local sheet_vole = graphics.newImageSheet( "vole.png", voleSheetOptions )

----------------------------Vole sprite setup end-----------------------------


----------------------------Bird sprite setup --------------------------------
local birds = {}
local birdNumber = 1
local birdSheetOptions =
{
    width = 22,
    height = 22,
    numFrames = 3
}

local sequences_flappingBird = {
    -- consecutive frames sequence
    {
        name = "normalFlying",
        start = 1,
        count = 2,
        time = 1000,
        loopCount = 0,
        loopDirection = "forward"
    },
    {
        name = "dive",
        start = 3,
        count = 1,
        time = 0,
        loopCount = 1,
        loopDirection = "forward"
    }
}

local sheet_flappingBird = graphics.newImageSheet( "bird.png", birdSheetOptions )

----------------------------Bird sprite setup end-----------------------------

----------------------------Deer sprite setup --------------------------------
local deers = {}
local deerNumber = 1
local deerSheetOptions =
{
    width = 37,
    height = 25,
    numFrames = 3
}

local sequences_deer = {
    -- consecutive frames sequences
    {
        name = "walking",
        start = 1,
        count = 2,
        time = 500,
        loopCount = 0,
        loopDirection = "forward"
    },
    {
        name = "hit",
        start = 3,
        count = 1,
        time = 0,
        loopCount = 1,
        loopDirection = "forward"
    }
}

local sheet_deer = graphics.newImageSheet( "deer.png", deerSheetOptions )

----------------------------Deer sprite setup end-----------------------------


----------------------------Cat sprite setup --------------------------------
local numberCats = 0
local cats = {}

local catSheetOptions =
{
    width = 14,
    height = 22,
    numFrames = 2
}

local sequences_cat = {
    -- consecutive frames sequence
    {
        name = "walkingCat",
        start = 1,
        count = 2,
        time = 500,
        loopCount = 0,
        loopDirection = "forward"
    }
}

local sheet_cat = graphics.newImageSheet( "cat.png", catSheetOptions )

----------------------------Cat sprite setup end-----------------------------

----------------------------Eagle sprite setup --------------------------------

local numberEagles = 0
local eagles = {}

local eagleSheetOptions =
{
    width = 25,
    height = 25,
    numFrames = 3
}

local sequences_eagle = {
    -- consecutive frames sequence
    {
        name = "flyingEagle",
        start = 1,
        count = 2,
        time = 1000,
        loopCount = 0,
        loopDirection = "forward"
    },
    {
        name = "dive",
        start = 3,
        count = 1,
        time = 0,
        loopCount = 1,
        loopDirection = "forward"
    }
}

local sheet_eagle = graphics.newImageSheet( "eagle.png", eagleSheetOptions )

----------------------------Eagle sprite setup end-----------------------------

----------------------------Dog sprite setup --------------------------------

local numberDogs = 0
local dogs = {}

local dogSheetOptions =
{
    width = 25,
    height = 15,
    numFrames = 2
}

local sequences_dog = {
    -- consecutive frames sequence
    {
        name = "walkingDog",
        start = 1,
        count = 2,
        time = 1000,
        loopCount = 0,
        loopDirection = "forward"
    },
    {
        name = "chase",
        start = 1,
        count = 2,
        time = 500,
        loopCount = 0,
        loopDirection = "forward"
    }
}

local sheet_dog = graphics.newImageSheet( "dog.png", dogSheetOptions )

----------------------------Eagle sprite setup end----------------------------

----------------------------Vegetable sprite setup --------------------------------

local numberVeggies = 24
local veggies = {}

local veggieSheetOptions =
{
    width = 20,
    height = 20,
    numFrames = 3
}

local sequences_veggies = {
    -- consecutive frames sequence
    {
        name = "revive",
        start = 1,
        count = 1,
        time = 100,
        loopCount = 1,
        loopDirection = "forward"
    },
    {
        name = "wilt",
        start = 2,
        count = 1,
        time = 100,
        loopCount = 1,
        loopDirection = "forward"
    }
}

----------------------------veggie sprite setup end----------------------------

----------------------------target board sprite setup--------------------------

local targetSheetOptions =
{
    width = 400,
    height = 150,
    numFrames = 4
}

local sequences_targetBoard = {
    -- consecutive frames sequence
    {
        name = "targets",
        start = 1,
        count = 4,
        time = 100,
        loopCount = 1,
        loopDirection = "forward"
    }
}

local sheet_targetBoard = graphics.newImageSheet( "target-board.png", targetSheetOptions)

----------------------------target board sprite setup end----------------------

----------------------------Zap sprite setup --------------------------------
local zapSheetOptions =
{
    width = 200,
    height = 50,
    numFrames = 3
}

local sequences_zap = {
    -- consecutive frames sequence
    {
        name = "zap",
        start = 1,
        count = 3,
        time = 300,
        loopCount = 0,
        loopDirection = "forward"
    }
}

local sheet_zap = graphics.newImageSheet( "zap.png", zapSheetOptions )

----------------------------Deer sprite setup end-----------------------------

----------------------------local variable setup-------------------------------

function scene:create( event )

    -- Called when the scene's view does not exist
    -- 
    -- INSERT code here to initialize the scene
    -- e.g. add display objects to 'sceneGroup', add touch listeners, etc

----------------load level-----------------
    levelConfig = event.params.levelConfig
    sceneGroup = self.view
    globalSceneGroup = display.newGroup()
    sceneGroup:insert(globalSceneGroup)

    physics.start()

    maxLives = levelConfig.maxLives
    health = levelConfig.startingHealth
    voleSpeed = levelConfig.voleSpeed

    local leftSide = display.screenOriginX + 7
    local rightSide = display.contentWidth - display.screenOriginX - 7

    -- this has to go here because the level config variable has to be set in scene:create
    local sheet_veggie = graphics.newImageSheet( levelConfig.veggie..".png", veggieSheetOptions )

    local background = display.newImage("background.png", -30, -45 ) 
    globalSceneGroup:insert(background)
    
    healthBar = display.newImageRect("health-bar.png", 23, 230)
    healthBar.x = leftSide
    healthBar.y = 50

    healthIndicatorMove = (healthBar.height - 30) / levelConfig.maxLives
    healthIndicatorStart = healthBar.contentBounds.yMax - 20

    healthIndicator = display.newImageRect("health-indicator.png", 23, 10)
    healthIndicator.x = leftSide
    healthIndicator.y = healthIndicatorStart - (healthIndicatorMove * health)

    sceneGroup:insert(healthBar)
    sceneGroup:insert(healthIndicator)

    scoreLabel = display.newText(globalSceneGroup, _s("Score:"), leftSide, 30, globals.font, 16)
    scoreAmountLabel = display.newText( globalSceneGroup, 0, scoreLabel.contentBounds.xMax + 2, 30, native.systemFont, 16)
    time = levelConfig.levelTime
    timeDisplay = display.newText( globalSceneGroup, _s("Time:")..time, leftSide, 10, native.systemFont, 16)

    groundBoosters = levelConfig.groundBoosters

    local yHole = 400
    local xHole = 40

    --create vole hills on display
    for i=1, levelConfig.numberHoles do

        local holeGroup = display.newGroup()
        local hole = {}

        local holeBottom = display.newImageRect("hole-bottom.png", 60, 29)
        holeBottom.x = xHole 
        holeBottom.y = yHole

        local vole = display.newSprite(sheet_vole, sequences_touchedVole)
        vole.x = xHole + 17
        vole.y = yHole + 3
        vole.isClickable = false
        vole.voleNumber = i

        xHole = xHole + 75

        if i % 3 == 0 then
            yHole = yHole -55
            xHole = xHole - (225)
        end

        holeGroup:insert(vole)
        holeGroup:insert(holeBottom)
        sceneGroup:insert(holeGroup)

        hole["bottom"] = holeBottom
        hole["vole"] = vole 
        holes[i] = hole;

        vole:addEventListener("touch", voleTouchedListener )
    end

    --how many vegetables die when a life is lost
    veggiesAffectedPerChange = numberVeggies / maxLives
    wiltedIndex = veggiesAffectedPerChange * health

    local veggieGroup = display.newGroup()
    globalSceneGroup:insert(veggieGroup)

    local veggieX = rightSide - 60
    local veggieY = 410

    for i=1, numberVeggies do

        local veggie = display.newSprite(sheet_veggie, sequences_veggies)
        veggie.x = veggieX
        veggie.y = veggieY

        veggieX = veggieX + 20

        if i % 3 == 0 then
            veggieY = veggieY - 30
            veggieX = veggieX - 60
        end

        veggieGroup:insert(veggie)
        table.insert(veggies, veggie)
        if(i > wiltedIndex) then
            veggie:setSequence("wilt")
            veggie:play()
        end
    end

    targetBoard = display.newSprite(sceneGroup, sheet_targetBoard, sequences_targetBoard)
    targetBoard.width, targetBoard.height = 80, 30
    targetBoard.x, targetBoard.y = display.contentWidth / 2, 440
    targetBoard.anchorX = 0.5

    startingCountdown = display.newText("", display.contentWidth / 2, display.contentHeight / 3, native.systemFont, 36)
    startingCountdown.anchorX = 0.5
    sceneGroup:insert(startingCountdown)

    for i = 3, 0, -1 do
        local countdown = i
        if(i == 0) then
            countdown = _s("Play")
        end

---------calculation for timer to change the text at the right time. I saved writing yet another function that calls another timer
        table.insert(timers, timer.performWithDelay((i*-1+4) * 1000, function()
                                        startingCountdown.text = countdown
                                        if(i == 0) then
                                            transition.fadeOut(startingCountdown, {time=3000})
                                        end
                                    end))
    end

    ----first timer needs to wait 5 seconds to allow the 3,2,1 countdown to take place before this happens
    timer.performWithDelay(5000, function() 
                                    voleTimer = timer.performWithDelay(voleSpeed, chooseRandomVole, 0)
                                    table.insert(timers, voleTimer)end, 1)
    timer.performWithDelay(5000, function() table.insert(timers, timer.performWithDelay(1000, levelCountdown, 0)) end, 1)


    if(levelConfig.birdsInLevel) then
        table.insert(timers, timer.performWithDelay(5000 + randomBirdDelay(), randomBird))
    end
    
    if(levelConfig.deerInLevel) then
        table.insert(timers, timer.performWithDelay(5000 + randomDeerDelay(), randomDeer))
    end

-----set up end of game labels
    levelComplete = display.newText(_s("Level Complete"), display.contentWidth / 2, display.contentHeight / 3, native.systemFont, 36)
    levelComplete.anchorX = 0.5
    levelComplete.alpha = 0
    sceneGroup:insert(levelComplete)

    bonusLabel = display.newText(_s("Bonus:"), (display.contentWidth / 2) - 20, levelComplete.contentBounds.yMax + 10, native.systemFont, 24)
    bonusLabel.anchorX = 0.5
    bonusLabel.alpha = 0
    sceneGroup:insert(bonusLabel)

    bonusAmountLabel = display.newText("0", bonusLabel.contentBounds.xMax + 3, bonusLabel.y, native.systemFont, 24)
    bonusAmountLabel.alpha = 0
    sceneGroup:insert(bonusAmountLabel)

    gameOverLabel = display.newText(_s("Game Over"), display.contentWidth / 2, display.contentHeight / 3, native.systemFont, 36)
    gameOverLabel.anchorX = 0.5
    gameOverLabel.alpha = 0
    sceneGroup:insert(gameOverLabel)
end

function gameOver(lost)
    --game over
    if(gameOverCompleted == false) then
        gameOverCompleted = true
        gameEnded = true
        cancelTimers()
        if(lost) then
            transition.fadeIn(gameOverLabel, {time = 2000})
            file.loseLife()
        else
            local data = file.loadGlobalData()
            if(data.maxLevel == nil or levelConfig.level > data.maxLevel) then
                data.maxLevel = levelConfig.level
                file.saveGlobalData(data)
            end
        end
        timer.performWithDelay(3000, function() composer.gotoScene(levelConfig.parentScene) end )
    end
end

function levelCountdown()
    time = time - 1
    timeDisplay.text = _s("Time:")..time

    if(time == 0) then
        gameEnded = true
        cancelTimers()

        local levelCompleted = false
        if(levelConfig.objective.gameType == "score") then
            if(score >= levelConfig.objective.number) then
                levelCompleted = true
            end
        elseif(levelConfig.objective.gameType == "achieveStreaks") then
            local streakComplete = false
            if(levelConfig.objective.cats > 0) then
                if(catsAchieved >= levelConfig.objective.cats) then
                    streakComplete = true
                else
                    streakComplete = false
                end
            end

             if(levelConfig.objective.eagles > 0) then
                if(eaglesAchieved >= levelConfig.objective.eagles) then
                    streakComplete = true
                else
                    streakComplete = false
                end
            end

             if(levelConfig.objective.dogs > 0) then
                if(dogsAchieved >= levelConfig.objective.dogs) then
                    streakComplete = true
                else
                    streakComplete = false
                end
            end

            if(streakComplete == true) then
                levelCompleted = true
            end
        elseif(levelConfig.objective.gameType == "finishStreaks") then
             local streakComplete = false
            
            if(levelConfig.objective.cats > 0) then
                if(numberCats >= levelConfig.objective.cats) then
                    streakComplete = true
                else
                    streakComplete = false
                end
            end

             if(levelConfig.objective.eagles > 0) then
                if(numberEagles >= levelConfig.objective.eagles) then
                    streakComplete = true
                else
                    streakComplete = false
                end
            end

             if(levelConfig.objective.dogs > 0) then
                if(numberDogs >= levelConfig.objective.dogs) then
                    streakComplete = true
                else
                    streakComplete = false
                end
            end

            if(streakComplete == true) then
                levelCompleted = true
            end
        end

        if(levelCompleted == true) then
            transition.fadeIn(levelComplete, {time = 2000})
            transition.fadeIn(bonusLabel, {time = 2000})
            transition.fadeIn(bonusAmountLabel, {time=2000})
            --set wilted index to the last whole number for bonus counting
            wiltedIndex = math.ceil(wiltedIndex)
            timer.performWithDelay(1000, countBonus)
        else
            gameOver(true)
        end
    end
end

function cancelTimers()
    for k, v in pairs(timers) do
        timer.cancel(v)
    end
end

function healthReduce()
    if(time > 0 and health > 0) then
        health = health - 1
        healthIndicator.y = healthIndicator.y + healthIndicatorMove
        wiltVeggies()
    end

    if(health == 0) then
        --game over
        gameOver(true)
    end
end

function healthIncrease()
    if(gameEnded == false and health < maxLives) then
        health = health + 1
        healthIndicator.y = healthIndicator.y - healthIndicatorMove
    end
end

function increaseScore()
    score = score + scorePerClick
    scoreAmountLabel.text = tonumber(score)

    if(target1Achieved == false and score >= levelConfig.target1 and score < levelConfig.target2) then
        target1Achieved = true
        targetBoard:setFrame(2)
        targetBoard.width, targetBoard.height = 80, 30
    elseif(target2Achieved == false and score >= levelConfig.target2 and score < levelConfig.target3) then
        target2Achieved = true
        targetBoard:setFrame(3)
        targetBoard.width, targetBoard.height = 80, 30
    elseif(target3Achieved == false and score >= levelConfig.target3) then
        target3Achieved = true
        targetBoard:setFrame(4)
        targetBoard.width, targetBoard.height = 80, 30
    end

end

function countBonus()

    if (#cats > 0) then
        local cat = cats[#cats]
        table.remove(cats, #cats)
        transition.fadeOut(cat, {time = 1000, onComplete=destroySelf})
        bonus = bonus + catBonus
    elseif(#eagles > 0) then
        local eagle = eagles[#eagles]
        table.remove(eagles, #eagles)
        transition.fadeOut(eagle, {time = 1000, onComplete=destroySelf})
        bonus = bonus + eagleBonus
    elseif(#dogs > 0) then
        local dog = dogs[#dogs]
        table.remove(dogs, #dogs)
        transition.fadeOut(dog, {time = 1000, onComplete=destroySelf})
        bonus = bonus + dogBonus
    elseif(wiltedIndex > 0) then
        transition.fadeOut(veggies[wiltedIndex], {time=500})
        wiltedIndex = wiltedIndex - 1
        bonus = bonus + veggieBonus
    else
        bonusItems = false
    end

    if(bonusItems) then
        bonusAmountLabel.text = bonus
        timer.performWithDelay(300, countBonus)
    else
        score = score + bonus
        local levelData = {}
        levelData.level = levelConfig.level
        levelData.score = score
        file.saveLevelData(levelData)
        scoreAmountLabel.text = score

        gameOver(false)
    end

end


function reviveVeggies()

    if(health < maxLives) then
        wiltedIndex = wiltedIndex + veggiesAffectedPerChange

        for i = math.floor((health - 1) * veggiesAffectedPerChange), math.ceil(wiltedIndex) do
            if(i > 0) then
                veggies[i]:setSequence("revive")
                veggies[i]:play()
            end
        end
    end
end

function wiltVeggies()
    if(health > 0) then
      for i = math.floor(health * veggiesAffectedPerChange), math.ceil(wiltedIndex) do
            if(i > 0) then
                veggies[i]:setSequence("wilt")
                veggies[i]:play()
            end
        end
        wiltedIndex = wiltedIndex - veggiesAffectedPerChange
    end
end

function animalHit(creature, animal)
    if(animal == "vole") then
        local gas = display.newImageRect('gas.png', 20, 20)
        gas.x = creature.x
        gas.y = creature.y
        gas.alpha = 0
        sceneGroup:insert(gas)
        transition.fadeIn(gas, {time=50, onComplete= function(gas) timer.performWithDelay(transition.fadeOut(gas, {time=500}), {time=500})end})
    else
        local rock = display.newImageRect('rock.png', 10, 10)
        rock.x, rock.y = creature.x, display.actualContentHeight
        sceneGroup:insert(rock)
        local rockSpeed
        local animalSpeed

        if(animal == "deer") then
            rockSpeed = 600
            animalSpeed = ((display.contentWidth + 80) -creature.x) / globals.animalHitSpeed
        elseif(animal == "bird") then
            rockSpeed = 500
            --100 being where the bird flys to on the x axis after being hit
            animalSpeed = 100 / globals.animalHitSpeed
        end

        local distance = animalSpeed * rockSpeed
        transition.to(rock, {time=rockSpeed, x=creature.x + distance, y=creature.y, onComplete=destroySelf})
    end
end


function voleTouchedListener( event )
    if (event.phase == "began" and gameEnded == false) then
        local vole = event.target

        if(vole.isClickable) then
            vole.hit = true
            animalHit(vole, "vole")
            increaseStreak()
            increaseScore()
            if (vole.transition == "up") then
                transition.cancel(vole)
                startVoleReturn(vole)
            end
            healthIncrease()
            reviveVeggies()
            vole:play()
            vole.isClickable = false
        end
    end
end

function birdTouchedListener( event )
    if (event.phase == "began" and time > 0) then
        local bird = event.target
        if(bird.isClickable) then
            animalHit(bird, "bird")
            increaseStreak()
            increaseScore()
            bird.isClickable = false
            transition.cancel(bird)
            transition.to(bird, {time=globals.animalHitSpeed, x=bird.x + 100, y=display.screenOriginY - 20, onComplete=destroySelf})
        end
    end
end

function deerTouchedListener( event )
    if (event.phase == "began" and time > 0) then
        local deer = event.target
        if(deer.isClickable) then
            animalHit(deer, "deer")
            increaseStreak()
            increaseScore()
            deer.isClickable = false
            deer:setSequence("hit")
            deer:play()
            transition.cancel(deer)
            transition.to(deer, {time=globals.animalHitSpeed, x= display.contentWidth + 40, onComplete=destroySelf})
        end
    end
end

function chooseRandomVole()

    if(volesPaused == false and numberZappedVoles < levelConfig.numberHoles) then
        local randomHole = math.random(1, levelConfig.numberHoles)

        local count = 0
        while holes[randomHole].vole.isMoving and count <= 10 do
            count = count + 1
            randomHole = math.random(1, levelConfig.numberHoles)
        end        

        if(count <= 10) then
            local groundBooster = math.random(1, levelConfig.groundBoosterFreq)

            if(#groundBoosters > 0 and groundBooster == levelConfig.groundBoosterFreq) then
                startGroundBoosterMove(randomHole)
            else
                startVoleMove(randomHole)
            end
        end
    end
end

function startGroundBoosterMove(voleNumber)

    local vole = holes[voleNumber].vole
    --so that the vole doesn't try to come up while booster is occupying hole
    vole.isMoving = true

    local booster = math.random(1, #groundBoosters)
    local boosterObject

    if(groundBoosters[booster] == "zapAll") then
        boosterObject = display.newImageRect(globalSceneGroup, "zapAll.png", 25, 25)
        boosterObject.boosterType = "zapAll"
        boosterObject:addEventListener("touch", zapAllTouched)
    elseif(groundBoosters[booster] == "zapRow") then
        boosterObject = display.newImageRect(globalSceneGroup, "zapRow.png", 25, 25)
        boosterObject.boosterType = "zapRow"
        boosterObject:addEventListener("touch", zapRowTouched)
    elseif(groundBoosters[booster] == "speedUp") then
        boosterObject = display.newImageRect(globalSceneGroup, "speedUp.png", 25, 25)
        boosterObject.boosterType = "speedUp"
        boosterObject:addEventListener("touch", speedUpTouched)
    elseif(groundBoosters[booster] == "slowDown") then
        boosterObject = display.newImageRect(globalSceneGroup, "slowDown.png", 25, 25)
        boosterObject.boosterType = "slowDown"
        boosterObject:addEventListener("touch", slowDownTouched)
    end

    boosterObject.x, boosterObject.y = vole.x, vole.y
    boosterObject.voleNumber = voleNumber
    boosterObject.transition = "up"

    transition.to(boosterObject, {time=voleSpeed, y=boosterObject.y - 23, onComplete=startGroundBoosterReturn})
end


function startGroundBoosterReturn(obj)
        obj.transition = "down"
        transition.to(obj, {time=voleSpeed, y=holes[obj.voleNumber].vole.y, onComplete=removeGroundBooster})
end

function removeGroundBooster(obj)
    destroySelf(obj)
end

function zapAllTouched(event)
    if (event.phase == "began" and gameEnded == false) then
        local voleNumber = event.target.voleNumber

        local zaps = {}

        for i = 1, levelConfig.numberHoles do

            if(i % 3 == 1) then
                zap = display.newSprite(sheet_zap, sequences_zap)
                zap.x = holes[i].bottom.contentBounds.xMin
                zap.y = holes[i].bottom.contentBounds.yMin - 35
                zap:play()

                table.insert(zaps, zap)
            end

            local vole = holes[i].vole
            
            if(vole.zapped == nil) then
                vole.zapped = {} 
            end
            
            vole.zapped[voleNumber] = "on"

            voleZapped(vole)
        end

        if(zap ~= nil) then
            timer.performWithDelay(3000, function() 
                                        for k, v in pairs(zaps) do
                                            destroySelf(v)
                                        end
                                        voleZappedComplete(voleNumber) 
                                    end)
        end
    end
end

function zapRowTouched(event)
    if (event.phase == "began" and gameEnded == false) then
        local voleNumber = event.target.voleNumber
        local firstVole
        local lastVole

        if(voleNumber % 3 == 0) then
            firstVole = voleNumber - 2
            lastVole = voleNumber
        elseif(voleNumber % 3 == 1) then
            firstVole = voleNumber
            lastVole = voleNumber + 2
        elseif(voleNumber % 3 == 2) then
            firstVole = voleNumber - 1
            lastVole = voleNumber + 1
        end

        local zap = display.newSprite(sheet_zap, sequences_zap)
        zap.x = holes[firstVole].bottom.contentBounds.xMin
        zap.y = holes[firstVole].bottom.contentBounds.yMin - 35
        zap:play()


        for i = firstVole, lastVole do
            local vole = holes[i].vole
            
            if(vole.zapped == nil) then
                vole.zapped = {} 
            end
            
            vole.zapped[voleNumber] = "on"

            voleZapped(vole)
        end

        timer.performWithDelay(3000, function() 
                                        destroySelf(zap)
                                        voleZappedComplete(voleNumber) 
                                    end)
    end
end

function voleZapped(vole)
    if(zappedVoles[vole.voleNumber] == nil) then
        transition.cancel("voleUp"..vole.voleNumber)
        transition.cancel("voleDown"..vole.voleNumber)

        zappedVoles[vole.voleNumber] = vole
        numberZappedVoles = numberZappedVoles + 1

        if(numberZappedVoles == levelConfig.numberHoles) then
            if(volesPaused == false) then
                timer.pause(voleTimer)
                volesPaused = true
            end
        end
        vole.isMoving = true
        vole.isClickable = false
        vole.transition = "up"
        vole.hit = false
        vole:setFrame(1)
        transition.to(vole, {time=voleSpeed, y=holes[vole.voleNumber].bottom.y - 17})
    end

end

function voleZappedComplete(voleNumber)

    for k,v in pairs(zappedVoles) do

        if(v.zapped[voleNumber] ~= nil) then

            v.zapped[voleNumber] = nil
            local done = true

            for key, value in pairs(v.zapped) do
                if(value == "on") then
                    done = false
                end
            end

            if(done) then
                v.transition = "down"
                local holeBottom = holes[v.voleNumber].bottom
                transition.to(v, {time=voleSpeed, y=holeBottom.y + 3, onComplete=   function() 
                                                                                        v.isMoving = false 
                                                                                        if(volesPaused == true) then
                                                                                            timer.resume(voleTimer)
                                                                                            volesPaused = false
                                                                                        end
                                                                                    end})
                v:setFrame(1)
                v.isClickable = false

                zappedVoles[k] = nil
                numberZappedVoles = numberZappedVoles - 1
            end
        end
    end
end

function speedUpTouched(event)
    if (event.phase == "began" and gameEnded == false) then
        voleSpeed = voleSpeed - 200
        timer.performWithDelay(3000, function() 
                                        voleSpeed = voleSpeed + 200 
                                    end, 1)
    end
end

function slowDownTouched(event)
    if (event.phase == "began" and gameEnded == false) then
        voleSpeed = voleSpeed + 200
        timer.performWithDelay(3000, function() 
                                        voleSpeed = voleSpeed - 200 
                                    end, 1)
    end
end

function startVoleMove(voleNumber)
    local vole = holes[voleNumber].vole
    vole.isClickable = true
    vole.isMoving = true
    vole.transition = "up"
    vole.hit = false
    transition.to(vole, {time=voleSpeed, y=vole.y - 17, onComplete=startVoleReturn, tag="voleUp"..voleNumber})
end

function startVoleReturn(obj)
    
    obj.transition = "down"
    
    local holeBottom = holes[obj.voleNumber].bottom
    
    transition.to(obj, {time=voleSpeed, y=holeBottom.y + 3, onComplete=removeVoleClickable, tag="voleDown"..obj.voleNumber})
end

function removeVoleClickable(obj)
    obj:setFrame(1)
    obj.isClickable = false
    obj.isMoving = false
    if(obj.hit ~= true and time > 0) then
        local maxCats = table.maxn(cats)
        if (maxCats > 0) then
            cat = cats[maxCats]
            numberCats = numberCats - 1
            table.remove(cats, maxCats)
            cat:play()
            transition.to(cat, {time=1000, x=obj.x, y=obj.y, onComplete=catGetVole})
        else
            healthReduce()
            resetStreak()
        end
    end
end

function catGetVole(obj)
    local vole = display.newImageRect("smallVole.png", 10, 11)
    vole.x = obj.x + 10
    vole.y = obj.y

    globalSceneGroup:insert(vole)

    physics.addBody(obj)
    physics.addBody(vole)
    local weldJoint = physics.newJoint("weld", obj, vole, obj.x, obj.y)

    transition.to(obj, {time=1000, y=550, onComplete=destroySelf})
end

function randomBirdDelay() return math.random(levelConfig.birdFrequencyLow, levelConfig.birdFrequencyHigh) end

function randomBird()

    local bird = display.newSprite(sheet_flappingBird, sequences_flappingBird)
    birds[birdNumber] = bird
    
    bird.birdNumber = birdNumber
    bird.isClickable = true
    bird.x = -40
    bird.y = math.random(10, 80)

    bird:addEventListener("touch", birdTouchedListener)
    birdNumber = birdNumber + 1

    globalSceneGroup:insert(bird)
    transition.to(bird, {time = levelConfig.birdSpeed, x = 240, onComplete=birdDive})
    bird:play()

    table.insert(timers, timer.performWithDelay(randomBirdDelay(), randomBird))
end

function randomDeerDelay() return math.random(levelConfig.deerFrequencyLow, levelConfig.deerFrequencyHigh) end

function randomDeer()

    local deer = display.newSprite(sheet_deer, sequences_deer)
    deers[deerNumber] = deer
    
    deer.deerNumber = deerNumber
    deer.isClickable = true
    deer.x = display.screenOriginX - 40
    deer.y = math.random(190, 220)

    deer:addEventListener("touch", deerTouchedListener)
    deerNumber = deerNumber + 1

    globalSceneGroup:insert(deer)
    transition.to(deer, {time = levelConfig.deerSpeed, x = display.contentWidth + 40, onComplete=deerMissed})
    deer:play()

    table.insert(timers, timer.performWithDelay(randomDeerDelay(), randomDeer))
end

function birdDive(bird)
    if(time > 0) then
        bird:setSequence("dive")
        bird:play()
        transition.to(bird, {time=1000, x = 280, y=300, onComplete=birdMissed})
    end
end

function birdMissed(bird)

    local maxEagles = table.maxn(eagles)
    if (maxEagles > 0 and time > 0) then
            bird:setSequence("normalFlying")
            bird:play()
            local eagle = eagles[maxEagles]
            numberEagles = numberEagles - 1
            table.remove(eagles, maxEagles)
            eagle:setSequence("dive")
            transition.to(eagle, {time=1000, x=bird.x, y=bird.y - bird.height, onComplete= function(eagle) eagleGetBird(eagle, bird) end})
    else
        bird:setSequence("normalFlying")
        bird:play()
        transition.to(bird, {time=500, x = 375, y= 280, onComplete=destroySelf})
        healthReduce()
        resetStreak()
    end
end

function deerMissed(deer)

    local maxDogs = table.maxn(dogs)
    if (maxDogs > 0 and time > 0) then
            --deer:setSequence("normalFlying")
            --deer:play()
            local dog = dogs[maxDogs]
            numberDogs = numberDogs - 1
            table.remove(dogs, maxDogs)
            dog:setSequence("chase")
            transition.to(dog, {time=500, x=200, y=deer.y, onComplete= function(dog) dogGetDeer(dog, deer) end})
    else
        --deer:setSequence("destroyGarden")
        --deer:play()
        transition.to(deer, {time=500, x = 400})
        healthReduce()
        resetStreak()
    end
end

function eagleGetBird(eagle, bird)
    physics.addBody(eagle, {density=10})
    physics.addBody(bird)
    eagle:setSequence("flyingEagle")
    eagle:play()
    local weldJoint = physics.newJoint("weld", eagle, bird, bird.x, bird.y)

    transition.to(eagle, {time=1000, x=400, y= eagle.y - 40, onComplete=destroySelf})
end

function dogGetDeer(dog, deer)

    transition.to(dog, {time=levelConfig.deerSpeed/2, x=400, onComplete=destroySelf})
    transition.to(deer, {time=levelConfig.deerSpeed/2, x=400, onComplete=destroySelf})
end

function destroySelf(obj)
    obj:removeSelf()
end

function increaseStreak()
    streak = streak + 1

    --no switch statement in lua...sigh
    if(streak == levelConfig.catStreak) then
        catStreakAchieved()
    elseif(streak == levelConfig.deerStreak) then
        if(levelConfig.deerInLevel) then
            deerStreakAchieved()
        else
            catStreakAchieved()
        end
    elseif(streak == levelConfig.eagleStreak) then
        if(levelConfig.birdsInLevel) then
            eagleStreakAchieved()
        elseif(levelConfig.deerInLevel) then
            deerStreakAchieved()
        else
            catStreakAchieved()
        end
    end

    
-----TODO Figure out what to do with streaks after achieved all.....multiplyer for score?    



end

function resetStreak()
    streak = 0
end

function catStreakAchieved()
    numberCats = numberCats + 1
    catsAchieved = catsAchieved + 1
    local cat = display.newSprite(sheet_cat, sequences_cat)
    cat.x = 10
    cat.y = 270 + (numberCats * 10)

    table.insert(cats,cat)

    sceneGroup:insert(cat)
end

function eagleStreakAchieved()
    numberEagles = numberEagles + 1
    eaglesAchieved = eaglesAchieved + 1
    local eagle = display.newSprite(sheet_eagle, sequences_eagle)
    eagle.x = 280
    eagle.y = 30 + (numberEagles * 10)
    eagle:play()

    table.insert(eagles,eagle)

    globalSceneGroup:insert(eagle)
end

function deerStreakAchieved()
    numberDogs = numberDogs + 1
    dogsAchieved = dogsAchieved + 1
    local dog = display.newSprite(sheet_dog, sequences_dog)
    dog.x = 280
    dog.y = 180 + (numberDogs * 10)

    table.insert(dogs,dog)

    globalSceneGroup:insert(dog)
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        -- Called when the scene is still off screen and is about to move on screen

    elseif phase == "did" then
        -- Called when the scene is now on screen
        -- 
        -- INSERT code here to make the scene come alive
        -- e.g. start timers, begin animation, play audio, etc
        
        -- we obtain the object by id from the scene's object hierarchy
    end 
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        -- Called when the scene is on screen and is about to move off screen
        --
        -- INSERT code here to pause the scene
        -- e.g. stop timers, stop animation, unload sounds, etc.)
    elseif phase == "did" then
            composer.removeScene( "vole-whacking", false )
        -- Called when the scene is now off screen

    end 
end


function scene:destroy( event )
    local sceneGroup = self.view

    -- Called prior to the removal of scene's "view" (sceneGroup)
    -- 
    -- INSERT code here to cleanup the scene
    -- e.g. remove display objects, remove touch listeners, save state, etc
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene
