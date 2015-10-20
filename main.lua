---------------------------------------------------------------------------------
--
-- main.lua
--
---------------------------------------------------------------------------------

-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )

-- require the composer library
local composer = require "composer"

display.setDefault( "anchorX", 0.0 )	-- default to TopLeft anchor point for new objects
display.setDefault( "anchorY", 0.0 )

local function moleTouchedListener( event )

    print( "Touch X location"..event.x )
    print( "Touch Y location"..event.y )
end

-- load scene1
composer.gotoScene( "scene1" )

-- Add any objects that should appear on all scenes below (e.g. tab bar, hud, etc)