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
local numberHoles = 8
local holes = {}
local birds = {}
local birdNumber = 1

function scene:create( event )
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
    for i=1, numberHoles do

        local holeGroup = display.newGroup()
        local hole = {}

        local holeBottom = display.newImageRect("hole-bottom.png", 40, 19)
        holeBottom.x = xHole 
        holeBottom.y = yHole

        local holeTop = display.newImageRect("hole-top.png", 40, 19)
        holeTop.x = xHole
        holeTop.y = yHole - 19

        local vole = display.newImageRect("vole.png", 25, 20)
        vole.x = xHole + 7.5
        vole.y = yHole - 8
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

        vole:addEventListener("touch", moleTouchedListener )
    end

    timer.performWithDelay(1000, ChooseRandomMole, 0)
    timer.performWithDelay(randomBirdDelay(), randomBird)    
    
end

function moleTouchedListener( event )
    if (event.phase == "ended") then
        if(event.target.isClickable) then
            score.text = tonumber(score.text) + 1
            event.target.isClickable = false
        end
    end
end

function ChooseRandomMole()
    local randomHole = math.random(1, numberHoles)

    while holes[randomHole].vole.isMoving do
        randomHole = math.random(1, numberHoles)
    end        
    startMoleMove(randomHole)
end

function startMoleMove(moleNumber)
    holes[moleNumber].vole.isClickable = true
    holes[moleNumber].vole.isMoving = true
    transition.to(holes[moleNumber].vole, {time=1000, y=holes[moleNumber].vole.y - 15, onComplete=startMoleReturn})
end

function startMoleReturn(obj)
    
    transition.to(obj, {time=1000, y=obj.y + 15, onComplete=removeMoleClickable})
end

function removeMoleClickable(obj)
    obj.isClickable = false
    obj.isMoving = false
end

function randomBirdDelay() return math.random(1000, 5000) end

function randomBird()
    bird = display.newImageRect("bird.png", 20, 20)
    birds[birdNumber] = bird
    
    bird.birdNumber = birdNumber
    bird.x = 300
    bird.y = math.random(10, 80)

    birdNumber = birdNumber + 1

    globalSceneGroup:insert(bird)
    transition.to(bird, {time = 4000, x = -40})

    timer.performWithDelay(randomBirdDelay(), randomBird)
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
