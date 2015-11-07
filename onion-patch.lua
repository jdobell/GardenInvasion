local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
-- -----------------------------------------------------------------------------------------------------------------

-- local forward references should go here

-- -------------------------------------------------------------------------------


-- "scene:create()"
function scene:create( event )

    local sceneGroup = self.view

    local background = display.newImage( sceneGroup, "onion-patch.png", -30, -45 )

    local levelMarker1 = display.newImageRect( sceneGroup, "level-marker.png", 50,50)
    levelMarker1.x = 5
    levelMarker1.y = 370
    local levelIdentifier1 = display.newText(sceneGroup, 1, levelMarker1.x + levelMarker1.width / 2, levelMarker1.y +  levelMarker1.height / 2, native.systemFont, 16)
    levelIdentifier1.anchorX, levelIdentifier1.anchorY = 0.5, 0.5
    levelMarker1.level = 1
    levelMarker1:addEventListener("touch", goToLevel)

    local levelMarker2 = display.newImageRect( sceneGroup, "level-marker.png", 50,50)
    levelMarker2.x = 5
    levelMarker2.y = 270
    local levelIdentifier2 = display.newText(sceneGroup, 2, levelMarker2.x + levelMarker2.width / 2, levelMarker2.y +  levelMarker2.height / 2, native.systemFont, 16)
    levelIdentifier2.anchorX, levelIdentifier2.anchorY = 0.5, 0.5
    levelMarker2.level = 2
    levelMarker2:addEventListener("touch", goToLevel)

end


function goToLevel(event)
    local levelSelect = "level"..event.target.level
-- load scene1

    local levelConfig = require(levelSelect)
    composer.gotoScene(levelConfig.scene, {params = {levelConfig = levelConfig}} )
end

-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen.
        -- Insert code here to make the scene come alive.
        -- Example: start timers, begin animation, play audio, etc.
    end
end


-- "scene:hide()"
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen).
        -- Insert code here to "pause" the scene.
        -- Example: stop timers, stop animation, stop audio, etc.
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen.
    end
end


-- "scene:destroy()"
function scene:destroy( event )

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view ("sceneGroup").
    -- Insert code here to clean up the scene.
    -- Example: remove display objects, save state, etc.
end


-- -------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene