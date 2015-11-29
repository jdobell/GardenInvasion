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
local seeds = {"onion-seed", "beet-seed", "carrot-seed", "turnip-seed"}

----------------------------Conveyor sprite setup --------------------------------
local conveyorSheetOptions =
{
    width = 300,
    height = 30,
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

    local background = display.newImage("planting-background.png", -30, -45 ) 
    globalSceneGroup:insert(background)

    local conveyor = display.newSprite( sheet_conveyor, sequences_conveyor)
    conveyor.x, conveyor.y = 10, 10
    conveyor:play()

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
                                    seedTimer = timer.performWithDelay(levelConfig.seedSpeed, dropRandomSeed, 0)
                                    table.insert(timers, seedTimer)end, 1)
    timer.performWithDelay(5000, function() table.insert(timers, timer.performWithDelay(1000, levelCountdown, 0)) end, 1)

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
