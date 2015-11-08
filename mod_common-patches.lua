local globals = require("global-variables")
local _s = globals._s
local _M = {}
local levelConfig
local commonGroup

function _M.createMarker(sceneGroup, x, y, level)
	commonGroup = sceneGroup
	local levelMarker = display.newImageRect( commonGroup, "level-marker.png", 50,50)
    levelMarker.x = x
    levelMarker.y = y
    local levelIdentifier = display.newText(commonGroup, level, levelMarker.x + levelMarker.width / 2, levelMarker.y +  levelMarker.height / 2, globals.font, 16)
    levelIdentifier.anchorX, levelIdentifier.anchorY = 0.5, 0.5
    levelMarker.level = level
    levelMarker:addEventListener("touch", _M.getLevelSelectModal)
end

function _M.getLevelSelectModal(event)

	local levelSelect = "level"..event.target.level
-- load scene1

    levelConfig = require(levelSelect)


	local group = display.newGroup()
	local modal = display.newImageRect(group, "level-start-modal.png", 280, 440)
	modal.x, modal.y = 20, 20

	local levelText = display.newText(group, _s("Level").." "..levelConfig.level, modal.contentBounds.xMin + 15, modal.contentBounds.yMin + 12, globals.font, 16)
	levelText:setFillColor( black )

	commonGroup:insert(group)
	return group
end

function _M.goToLevel(level)
    composer.gotoScene(levelConfig.scene, {params = {levelConfig = levelConfig}} )
end

return _M