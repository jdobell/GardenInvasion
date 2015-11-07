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

local levelSelect = "level2"
-- load scene1

local levelConfig = require(levelSelect)

--composer.gotoScene( levelConfig.scene, {params = {levelConfig = levelConfig}} )
composer.gotoScene("onion-patch")
-- Add any objects that should appear on all scenes below (e.g. tab bar, hud, etc)