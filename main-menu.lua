---------------------------------------------------------------------------------
--
-- scene.lua
--
---------------------------------------------------------------------------------

local sceneName = ...

local composer = require( "composer" )
local globals = require("global-variables")
local widget = require("widget")
local _s = globals._s

-- Load scene with same root filename as this file
local scene = composer.newScene( sceneName )

local levelConfig
local sceneGroup
local globalSceneGroup
local levelConfig


---------------------------------------------------------------------------------

function scene:create( event )

    --levelConfig = event.params.levelConfig
    sceneGroup = self.view
    globalSceneGroup = display.newGroup()
    sceneGroup:insert(globalSceneGroup)

    local leftSide = display.screenOriginX + 7
    local rightSide = display.contentWidth - display.screenOriginX - 7

    local background = display.newImage("main-menu.png", -30, -45 ) 
    globalSceneGroup:insert(background)

    PlayButton = widget.newButton
    {
        width = 130,
        height = 40,
        defaultFile = "button-medium.png",
        overFile = "button-medium-pressed.png",
        onEvent = play,
        label = _s("Play"),
        labelColor = {default = {0,0,0}, over = {1,1,1}},
        font = globals.font
    }

    PlayButton.x, PlayButton.y = display.contentWidth / 2, display.screenOriginY + 180
    globalSceneGroup:insert(PlayButton)
    PlayButton.anchorX = 0.5

    SettingsButton = widget.newButton
    {
        width = 130,
        height = 40,
        defaultFile = "button-medium.png",
        overFile = "button-medium-pressed.png",
        onEvent = play,
        label = _s("Settings"),
        labelColor = {default = {0,0,0}, over = {1,1,1}},
        font = globals.font
    }

    SettingsButton.x, SettingsButton.y = display.contentWidth / 2, display.screenOriginY + 280
    globalSceneGroup:insert(SettingsButton)
    SettingsButton.anchorX = 0.5


    -- Called when the scene's view does not exist
    -- 
    -- INSERT code here to initialize the scene
    -- e.g. add display objects to 'sceneGroup', add touch listeners, etc
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
        composer.removeScene( "main-menu", false )
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
