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

local nextSceneButton

function scene:create( event )
    local sceneGroup = self.view

    -- Called when the scene's view does not exist
    -- 
    -- INSERT code here to initialize the scene
    -- e.g. add display objects to 'sceneGroup', add touch listeners, etc
    local background = display.newImage("background.png", 0, 0 ) 
    sceneGroup:insert(background)

    local numberHoles = 11
    local holes = {}
    local yHole = 450
    local xHole = 60

    for i=1, numberHoles do
        local holeBottom = display.newImageRect("hole-bottom.png", 40, 19)
        holeBottom.x = xHole 
        holeBottom.y = yHole

        local holeTop = display.newImageRect("hole-top.png", 40, 19)
        holeTop.x = xHole
        holeTop.y = yHole - 19

        local vole = display.newImageRect("vole.png", 25, 20)
        vole.x = xHole + 7.5
        vole.y = yHole - 8

        xHole = xHole + 75

        if i % 3 == 0 then
            yHole = yHole -55
            xHole = xHole - (225)
        end

        sceneGroup:insert(holeTop)
        sceneGroup:insert(vole)
        sceneGroup:insert(holeBottom) 
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
