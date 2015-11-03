---------------------------------------------------------------------------------
--
-- scene.lua
--
---------------------------------------------------------------------------------

local sceneName = ...

local composer = require( "composer" )
local physic = require("physics")

-- Load scene with same root filename as this file
local scene = composer.newScene( sceneName )

---------------------------------------------------------------------------------

local globalSceneGroup
local time
local timeDisplay
local score
local levelConfig
local streak = 0

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
    -- consecutive frames sequence
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
    numFrames = 2
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

----------------------------Eagle sprite setup end----------------------------

----------------------------local variable setup------------------------------

function scene:create( event )

    -- Called when the scene's view does not exist
    -- 
    -- INSERT code here to initialize the scene
    -- e.g. add display objects to 'sceneGroup', add touch listeners, etc

----------------load level-----------------
    --levelConfig = require(event.params.levelSelect)
    levelConfig = event.params.levelConfig
    local sceneGroup = self.view
    globalSceneGroup = display.newGroup()
    sceneGroup:insert(globalSceneGroup)

    -- this has to go here because the level config variable has to be set in scene:create
    local sheet_veggie = graphics.newImageSheet( levelConfig.veggie, veggieSheetOptions )

    local background = display.newImage("background.png", 0, 0 ) 
    globalSceneGroup:insert(background)
    
    score = display.newText( globalSceneGroup, 0, 10, 10)
    timeDisplay = display.newText( globalSceneGroup, 0, 10, 30)
    time = levelConfig.levelTime
    timeDisplay.text = time

    local yHole = 450
    local xHole = 60

    --create vole hills on display
    for i=1, levelConfig.numberHoles do

        local holeGroup = display.newGroup()
        local hole = {}

        local holeBottom = display.newImageRect("hole-bottom.png", 40, 19)
        holeBottom.x = xHole 
        holeBottom.y = yHole

        local holeTop = display.newImageRect("hole-top.png", 40, 19)
        holeTop.x = xHole
        holeTop.y = yHole - 19

        local vole = display.newSprite(sheet_vole, sequences_touchedVole)
        vole.x = xHole + 7.5
        vole.y = yHole - 3
        vole.isClickable = false

        xHole = xHole + 75

        if i % 3 == 0 then
            yHole = yHole -55
            xHole = xHole - (225)
        end

        holeGroup:insert(holeTop)
        holeGroup:insert(vole)
        holeGroup:insert(holeBottom)
        globalSceneGroup:insert(holeGroup)

        hole["bottom"] = holeBottom
        hole["top"] = holeTop
        hole["vole"] = vole 
        holes[i] = hole;

        vole:addEventListener("touch", voleTouchedListener )
    end

    local veggieGroup = display.newGroup()
    globalSceneGroup:insert(veggieGroup)

    local veggieX = 260
    local veggieY = 450

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
        if(i > levelConfig.startingHealth) then
            print("hi")
            veggie:setSequence("wilt")
            veggie:play()
        end
    end

    timer.performWithDelay(levelConfig.voleFrequency, chooseRandomVole, 0)
    timer.performWithDelay(1000, levelCountdown, 0)

    if(levelConfig.birdsInLevel) then
        timer.performWithDelay(randomBirdDelay(), randomBird)    
    end
    
    if(levelConfig.deerInLevel) then
        timer.performWithDelay(randomDeerDelay(), randomDeer)    
    end

end

function levelCountdown()
    time = time - 1
    timeDisplay.text = time
end

function voleTouchedListener( event )
    if (event.phase == "ended") then
        local vole = event.target

        vole.hit = true
        increaseStreak()

        if(vole.isClickable) then
            if (vole.transition == "up") then
                transition.cancel(vole)
                startVoleReturn(vole)
            end
            vole:play()
            score.text = tonumber(score.text) + 1
            vole.isClickable = false
        end
    end
end

function birdTouchedListener( event )
    if (event.phase == "ended") then
        if(event.target.isClickable) then
            score.text = tonumber(score.text) + 1
            event.target.isClickable = false
            transition.cancel(event.target)
            transition.to(event.target, {time=800, x=event.target.x + 100, y=-100, onComplete=destroySelf})
        end
    end
end

function deerTouchedListener( event )
    if (event.phase == "ended") then
        if(event.target.isClickable) then
            score.text = tonumber(score.text) + 1
            event.target.isClickable = false
            transition.cancel(event.target)
            transition.to(event.target, {time=800, x= 400, onComplete=destroySelf})
        end
    end
end

function chooseRandomVole()
    local randomHole = math.random(1, levelConfig.numberHoles)

    while holes[randomHole].vole.isMoving do
        randomHole = math.random(1, levelConfig.numberHoles)
    end        
    startVoleMove(randomHole)
end

function startVoleMove(voleNumber)
    local vole = holes[voleNumber].vole
    vole.isClickable = true
    vole.isMoving = true
    vole.transition = "up"
    vole.hit = false
    transition.to(holes[voleNumber].vole, {time=levelConfig.voleSpeed, y=holes[voleNumber].vole.y - 17, onComplete=startVoleReturn})
end

function startVoleReturn(obj)
    
    obj.transition = "down"
    local holeBottom = obj.parent[1];
    transition.to(obj, {time=levelConfig.voleSpeed, y=holeBottom.y + 15, onComplete=removeVoleClickable})
end

function removeVoleClickable(obj)
    obj:setFrame(1)
    obj.isClickable = false
    obj.isMoving = false
    if(obj.hit ~= true) then
        local maxCats = table.maxn(cats)
        if (maxCats > 0) then
            cat = cats[maxCats]
            numberCats = numberCats - 1
            table.remove(cats, maxCats)
            cat:play()
            transition.to(cat, {time=1000, x=obj.x, y=obj.y, onComplete=catGetVole})
        else
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

    timer.performWithDelay(randomBirdDelay(), randomBird)
end

function randomDeerDelay() return math.random(levelConfig.deerFrequencyLow, levelConfig.deerFrequencyHigh) end

function randomDeer()

    local deer = display.newSprite(sheet_deer, sequences_deer)
    deers[deerNumber] = deer
    
    deer.deerNumber = deerNumber
    deer.isClickable = true
    deer.x = -40
    deer.y = math.random(190, 220)

    deer:addEventListener("touch", deerTouchedListener)
    deerNumber = deerNumber + 1

    globalSceneGroup:insert(deer)
    transition.to(deer, {time = levelConfig.deerSpeed, x = 275, onComplete=deerMissed})
    deer:play()

    timer.performWithDelay(randomDeerDelay(), randomDeer)
end

function birdDive(bird)
    bird:setSequence("dive")
    bird:play()
    transition.to(bird, {time=1000, x = 280, y=300, onComplete=birdMissed})
end

function birdMissed(bird)

    local maxEagles = table.maxn(eagles)
    if (maxEagles > 0) then
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
        transition.to(bird, {time=500, x = 320, y= 280})
        resetStreak()
    end
end

function deerMissed(deer)

    local maxDogs = table.maxn(dogs)
    if (maxDogs > 0) then
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
    local cat = display.newSprite(sheet_cat, sequences_cat)
    cat.x = 10
    cat.y = 200 + (numberCats * 10)

    table.insert(cats,cat)

    globalSceneGroup:insert(cat)
end

function eagleStreakAchieved()
    numberEagles = numberEagles + 1
    local eagle = display.newSprite(sheet_eagle, sequences_eagle)
    eagle.x = 280
    eagle.y = 30 + (numberEagles * 10)
    eagle:play()

    table.insert(eagles,eagle)

    globalSceneGroup:insert(eagle)
end

function deerStreakAchieved()
    numberDogs = numberDogs + 1
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

    if event.phase == "will" then
        -- Called when the scene is on screen and is about to move off screen
        --
        -- INSERT code here to pause the scene
        -- e.g. stop timers, stop animation, unload sounds, etc.)
    elseif phase == "did" then
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
