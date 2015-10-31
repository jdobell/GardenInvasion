---------------------------------------------------------------------------------
--
-- scene.lua
--
---------------------------------------------------------------------------------

local sceneName = ...

local composer = require( "composer" )

-- Load scene with same root filename as this file
local scene = composer.newScene( sceneName )

---------------------------------------------------------------------------------

local globalSceneGroup
local score
local levelConfig

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
        count = 3,
        time = 0,
        loopCount = 1,
        loopDirection = "forward"
    }
}

local sheet_flappingBird = graphics.newImageSheet( "bird.png", birdSheetOptions )

----------------------------Bird sprite setup end-----------------------------

----------------------------local variable setup------------------------------
local streak = 0

function scene:create( event )

----------------load level-----------------
    levelConfig = require(event.params.levelSelect)

    local sceneGroup = self.view
    globalSceneGroup = display.newGroup()
    sceneGroup:insert(globalSceneGroup)
    -- Called when the scene's view does not exist
    -- 
    -- INSERT code here to initialize the scene
    -- e.g. add display objects to 'sceneGroup', add touch listeners, etc
    local background = display.newImage("background.png", 0, 0 ) 
    globalSceneGroup:insert(background)
    
    score = display.newText( globalSceneGroup, 0, 10, 10)

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

        --local vole = display.newImageRect("vole.png", 25, 20)
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

    timer.performWithDelay(1000, chooseRandomVole, 0)

    if(levelConfig.birdsInLevel) then
        timer.performWithDelay(randomBirdDelay(), randomBird)    
    end
    
end

function voleTouchedListener( event )
    if (event.phase == "ended") then
        local vole = event.target
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
    transition.to(holes[voleNumber].vole, {time=1000, y=holes[voleNumber].vole.y - 17, onComplete=startVoleReturn})
end

function startVoleReturn(obj)
    
    obj.transition = "down"
    local holeBottom = obj.parent[1];
    transition.to(obj, {time=1000, y=holeBottom.y + 15, onComplete=removeVoleClickable})
end

function removeVoleClickable(obj)
    obj:setFrame(1)
    obj.isClickable = false
    obj.isMoving = false
end

function randomBirdDelay() return math.random(1000, 5000) end

function randomBird()

    bird = display.newSprite(sheet_flappingBird, sequences_flappingBird)
    birds[birdNumber] = bird
    
    bird.birdNumber = birdNumber
    bird.isClickable = true
    bird.x = -40
    bird.y = math.random(10, 80)

    bird:addEventListener("touch", birdTouchedListener)
    birdNumber = birdNumber + 1

    globalSceneGroup:insert(bird)
    transition.to(bird, {time = 4000, x = 240, onComplete=birdDive})
    bird:play()

    timer.performWithDelay(randomBirdDelay(), randomBird)
end

function birdDive(bird)
    bird:setSequence("dive")
    bird:play()
    transition.to(bird, {time=1000, x = 280, y=300, onComplete=birdMissed})
end

function birdMissed(bird)
    bird:setSequence("normalFlying")
    bird:play()
    transition.to(bird, {time=500, x = 320, y= 280})
end

function destroySelf(obj)
    obj:removeSelf()
end

function increaseStreak()
    streak = streak + 1

    --no switch statement in lua...sigh
    if(streak == levelConfig.catStreak) then
        catStreakAchieved()
    elseif(streak == levelConfig.eagleStreak) then
        if(levelConfig.birdsInLevel) then
            eagleStreakAchieveded()
        else
            catStreakAchieved()
        end
    elseif(streak == levelConfig.deerStreak) then
        if(levelConfig.deerInLevel) then
            deerStreakAchieved()
        elseif(levelConfig.birdsInLevel) then
            eagleStreakAchieveded()
        else
            catStreakAchieved()
        end
    end
end

function resetStreak()
    streak = 0
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
