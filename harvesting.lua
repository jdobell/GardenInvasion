---------------------------------------------------------------------------------
--
-- scene.lua
--
---------------------------------------------------------------------------------

local sceneName = ...

local composer = require( "composer" )
local physics = require("physics")
--physics.setDrawMode( "hybrid" )
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
local streak = 0
local levelConfig
local numberHolesCompleted = 0
local holes = {}
local touchStart
local touchEnd


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

----------------------------veggie sprite setup end----------------------------

---------------------------------------------------------------------------------

function scene:create( event )

    levelConfig = event.params.levelConfig
    sceneGroup = self.view
    globalSceneGroup = display.newGroup()
    sceneGroup:insert(globalSceneGroup)

    file:setBox(globals.levelDataFile)

    local leftSide = display.screenOriginX + 7
    local rightSide = display.contentWidth - display.screenOriginX - 7

    local background = display.newImage("planting-background.png", -30, -45 ) 
    globalSceneGroup:insert(background)

    -- this has to go here because the level config variable has to be set in scene:create
    local sheet_veggie = graphics.newImageSheet( levelConfig.veggie, veggieSheetOptions )


    local yHole = 150
    local xHole = 40

    for i=1, levelConfig.numberHoles do
    
        local veggie = display.newSprite(sceneGroup, sheet_veggie, sequences_veggies)
        local hole = display.newImageRect( sceneGroup, "hole-bottom.png", 40, 20 )

        hole.x = xHole 
        hole.y = yHole

        veggie.x = xHole + 10
        veggie.y = yHole - 7

        xHole = xHole + 100

        if i % 3 == 0 then
            yHole = yHole + 55
            xHole = xHole - 300
        end

        veggie.completed = false
        veggie.holeNumber = i
        veggie.slow = 0
        hole.holeNumber = i

        holes[i] = hole
        veggies[i] = veggie

        veggie:addEventListener("touch", veggieClicked)
        hole:addEventListener("touch", cancelTouch)
        hole:addEventListener("tap", cancelTouch)
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

    -- timer.performWithDelay(5000, function() 
    --                                 seedTimer = timer.performWithDelay(levelConfig.seedFrequency, dropRandomSeed, 0)
    --                                 table.insert(timers, seedTimer)
    --                                 pickHole()
    --                             end, 
    --                         1)

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

local function easeSin(f,a)
  return function(t, tMax, start, delta)
    return start + delta + a*math.sin( (t/tMax) *f * math.pi*2)
  end
end

local function oscillate(f, a, axis, howlong)
  return function(thing)
    transition.to( thing, {time=howlong, delta=true, [axis]=0, transition=easeSin(f,a)} )
  end
end

function levelCountdown()
    time = time - 1
    timeDisplay.text = _s("Time:")..time

    if(time == 0) then
        gameEnded = true
        cancelTimers()

        local levelCompleted = false
        if(levelConfig.objective.gameType == "harvesting") then
            if(score >= levelConfig.objective.number) then
                levelCompleted = true
            end
        end

        if(levelCompleted == true) then
            transition.fadeIn(levelComplete, {time = 2000})
            transition.fadeIn(bonusLabel, {time = 2000})
            transition.fadeIn(bonusAmountLabel, {time=2000})
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

function increaseScore()
    score = score + (scorePerClick * streak)
    scoreAmountLabel.text = tonumber(score)
end

function increaseStreak()
    streak = streak + 1
end

function resetStreak()
    streak = 0
end

function cancelTouch(event)
    return true
end

function veggieClicked(event)

    local veggie = event.target

    if event.phase == "began" then

        display.getCurrentStage():setFocus( veggie )
        veggie.isFocus = true

        touchStart = system.getTimer()
    elseif veggie.isFocus then
        if event.phase == "moved" and veggie.completed == false then
            local dy = math.abs( event.y - event.yStart )

            if (dy > 10) then
                touchEnd = system.getTimer()

                local touchTime = touchEnd - touchStart
                print(touchTime)

                if(touchTime < globals.touchFast) then
                    print("fast")
                    veggie.completed = true
                elseif(touchTime >= globals.touchFast and touchTime <= globals.touchSlow) then
                    print("good")
                    veggie.completed = true
                elseif(touchTime > globals.touchSlow) then
                    print("slow")

                    if(veggie.slow == 3) then

                    else
                        oscillate( 10, 2, 'x', 300 ) (veggie)
                        transition.to(veggie, {time=300, y=veggie.y - 3})
                        veggie.slow = veggie.slow + 1
                    end
                end

                display.getCurrentStage():setFocus( nil )
                veggie.isFocus = false
            end

            --transition.to(seed, {time = 500, y=holes[currentHole].y+10, onComplete=seedMissed})
        elseif event.phase == "ended" or event.phase == "cancelled" then

            display.getCurrentStage():setFocus( nil )
            veggie.isFocus = false
        end
    end

    return true
end

function veggieSuccess(veggie)

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
