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

local levelConfig
local sceneGroup
local globalSceneGroup
local timers = {}
local time
local timeDisplay
local scoreLabel
local score = 0
local scorePerClick = 10
local levelConfig
local seeds
local conveyor
local holes = {}

----------------------------Conveyor sprite setup --------------------------------
local conveyorSheetOptions =
{
    width = 380,
    height = 38,
    numFrames = 4
}

local sequences_conveyor = {
    -- consecutive frames sequence
    {
        name = "conveyorMove",
        frames = {4,3,2,1},
        time = 300,
        loopCount = 0,
        loopDirection = "reverse"
    }
}

local sheet_conveyor = graphics.newImageSheet( "conveyor.png", conveyorSheetOptions )

----------------------------Conveyor sprite setup end-----------------------------

---------------------------------------------------------------------------------

function scene:create( event )

    levelConfig = event.params.levelConfig
    sceneGroup = self.view
    globalSceneGroup = display.newGroup()
    sceneGroup:insert(globalSceneGroup)

    physics.start()

    file:setBox(globals.levelDataFile)

    local leftSide = display.screenOriginX + 7
    local rightSide = display.contentWidth - display.screenOriginX - 7

    local background = display.newImage("planting-background.png", -30, -45 ) 
    globalSceneGroup:insert(background)

    sequences_conveyor[1].time = levelConfig.seedSpeed / 35

    conveyor = display.newSprite( sheet_conveyor, sequences_conveyor)
    conveyor.x, conveyor.y = leftSide - 20, 100
    conveyor:play()
    globalSceneGroup:insert(conveyor)

    seeds = levelConfig.seeds

    local yHole = 150
    local xHole = 40

    for i=1, levelConfig.numberHoles do

        local hole = display.newImageRect("planting-hole.png", 40, 20)
        hole.x = xHole 
        hole.y = yHole

        xHole = xHole + 100

        if i % 3 == 0 then
            yHole = yHole + 55
            xHole = xHole - 300
        end

        sceneGroup:insert(hole)

        holes[i] = hole;
    end

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
                                    seedTimer = timer.performWithDelay(levelConfig.seedFrequency, dropRandomSeed, 0)
                                    table.insert(timers, seedTimer)
                                end, 
                            1)
    timer.performWithDelay(5000, function() table.insert(timers, timer.performWithDelay(1000, levelCountdown, 0)) end, 1)

    scoreLabel = display.newText(globalSceneGroup, _s("Score:"), leftSide, 30, globals.font, 16)
    scoreAmountLabel = display.newText( globalSceneGroup, 0, scoreLabel.contentBounds.xMax + 2, 30, native.systemFont, 16)
    time = levelConfig.levelTime
    timeDisplay = display.newText( globalSceneGroup, _s("Time:")..time, leftSide, 10, native.systemFont, 16)

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

    -- Called when the scene's view does not exist
    -- 
    -- INSERT code here to initialize the scene
    -- e.g. add display objects to 'sceneGroup', add touch listeners, etc
end

function levelCountdown()
    time = time - 1
    timeDisplay.text = _s("Time:")..time

    if(time == 0) then
        gameEnded = true
        cancelTimers()

        local levelCompleted = false
        if(levelConfig.objective.gameType == "planting") then
            if(score >= levelConfig.objective.number) then
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
            gameOver()
        end
    end
end

function cancelTimers()
    for k, v in pairs(timers) do
        timer.cancel(v)
    end
end

function gameOver()
    --game over
    if(gameOverCompleted == false) then
        gameOverCompleted = true
        gameEnded = true
        cancelTimers()
        transition.fadeIn(gameOverLabel, {time = 2000})
        timer.performWithDelay(3000, function() composer.gotoScene(levelConfig.parentScene) end )
    end
end

function destroySelf(obj)
    obj:removeSelf()
end

function dropRandomSeed()

    local seedNumber = math.random(1, #seeds)

    local seed = display.newImageRect( globalSceneGroup, seeds[seedNumber]..".png", 30, 30)
    seed.x, seed.y = display.screenOriginX - 40, conveyor.contentBounds.yMin
    seed.anchorY = 1

    seed.isClickable = true

    seed:addEventListener("touch", seedClicked)

    transition.to(seed, {time=levelConfig.seedSpeed, x= 400, onComplete=destroySelf})
end

function seedClicked(event)

    local seed = event.target

    if event.phase == "moved" then -- Check if you moved your finger while touching
        local dy = math.abs( event.y - event.yStart ) -- Get the y-transition of the touch-input
        if (dy > 5 and seed.isClickable) then
            seed.isClickable = false
            
       end
   end
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
        composer.removeScene( "planting", false )
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
