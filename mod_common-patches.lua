local globals = require("global-variables")
local composer = require("composer")
local _s = globals._s
local _M = {}
local levelConfig
local commonGroup
local modalGroup
local levelText
local voleChit
local birdChit
local deerChit

local file = require("mod_file-management")

function _M.new(sceneGroup)
	commonGroup = sceneGroup
	modalGroup = display.newGroup()
	local modal = display.newImageRect(modalGroup, "level-start-modal.png", 380, 570)
	modal.x, modal.y = -23, -44
	modal:addEventListener( "touch", _M.modalTouched )

	levelText = display.newText(modalGroup, "", modal.contentBounds.xMin + 61, modal.contentBounds.yMin + 80, globals.font, 16)
	levelText:setFillColor( black )

	local pestText = display.newText(modalGroup, _s("Pests"), modal.contentBounds.xMin + modal.width / 2, 70, globals.font, 16)
	pestText.anchorX = 0.5
	pestText:setFillColor( black )

	voleChit = display.newImageRect(modalGroup, "vole-chit.png", 40, 40)
	voleChit.x, voleChit.y = 70, 100

	birdChit = display.newImageRect(modalGroup, "bird-chit.png", 40, 40)
	birdChit.x, birdChit.y = 140, 100
	birdChit.alpha = 0

	deerChit = display.newImageRect(modalGroup, "deer-chit.png", 40, 40)
	deerChit.x, deerChit.y = 210, 100
	birdChit.alpha = 0

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
    	modalGroup[i].alpha = alpha
	end 
end

function _M:createMarker(x, y, level)
	
	local data = file.loadTable(globals.garden_invasion_levels)

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

    if(levelConfig.birdsInLevel == false) then
    	birdChit.alpha = 0
    end

    if(levelConfig.deerInLevel == false) then
    	deerChit.alpha = 0
    end
    modalGroup:toFront()
end

function _M.goToLevel(level)
	_M:toggleModalVisible(false)
    composer.gotoScene(levelConfig.scene, {params = {levelConfig = levelConfig}} )
end

function _M.closeModal()
	_M.toggleModalVisible(false)
end

function _M.modalTouched(event)
	---stop propagation through dialog as to act like a modal
	return true
end

return _M