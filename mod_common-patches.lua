local globals = require("global-variables")
local composer = require("composer")
local _s = globals._s
local _M = {}
local levelConfig
local commonGroup
local modalGroup
local levelText

function _M.new(sceneGroup)
	commonGroup = sceneGroup
	modalGroup = display.newGroup()
	local modal = display.newImageRect(modalGroup, "level-start-modal.png", 280, 440)
	modal.x, modal.y = 20, 20
	levelText = display.newText(modalGroup, "", modal.contentBounds.xMin + 15, modal.contentBounds.yMin + 12, globals.font, 16)
	levelText:setFillColor( black )

	local playButton = display.newImageRect( modalGroup, "button-medium.png", 70, 30 )
	playButton.x, playButton.y = 220, 420
	local playButtonText = display.newText(modalGroup, _s("Play"), playButton.x + playButton.width / 2, playButton.y + playButton.height / 2, globals.font, 16)
	playButtonText.anchorX, playButtonText.anchorY = 0.5, 0.5
	playButton:addEventListener( "touch", _M.goToLevel )

	local goBackButton = display.newImageRect( modalGroup, "button-medium.png", 70, 30 )
	goBackButton.x, goBackButton.y = 140, 420
	local goBackButtonText = display.newText(modalGroup, _s("Go Back"), goBackButton.x + goBackButton.width / 2, goBackButton.y + goBackButton.height / 2, globals.font, 16)
	goBackButtonText.anchorX, goBackButtonText.anchorY = 0.5, 0.5
	goBackButton:addEventListener( "touch", _M.closeModal )


	commonGroup:insert(modalGroup)
	_M:toggleModalVisible(false)

end

function _M:toggleModalVisible(visible)
	local alpha = 0

	if(visible) then
		alpha = 1
	end

	for i=1,modalGroup.numChildren do
		print(modalGroup[i].alpha)
    	modalGroup[i].alpha = alpha
	end 
end

function _M:createMarker(x, y, level)
	
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
    levelText.text = _s("Level").." "..levelConfig.level

    _M:toggleModalVisible(true)
    modalGroup:toFront()
end

function _M.goToLevel(level)
    composer.gotoScene(levelConfig.scene, {params = {levelConfig = levelConfig}} )
end

function _M.closeModal()
	_M.toggleModalVisible(false)
end

return _M