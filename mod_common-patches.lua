local globals = require("global-variables")
local composer = require("composer")
local _s = globals._s
local _M = {}
local levelConfig
local commonGroup
local modalGroup
local navigateModalGroup
local levelText
local voleChit
local birdChit
local deerChit
local navigatePatchButton

local file = require("mod_file-management")
local widget = require("widget")

function _M.new(sceneGroup)

	file:setBox(globals.levelDataFile)

	commonGroup = sceneGroup

	navigatePatchButton = display.newImageRect( commonGroup, "button-medium.png", 70, 30 )
	navigatePatchButton.x, navigatePatchButton.y = display.contentWidth - display.screenOriginX - 5, display.screenOriginY + 5
	navigatePatchButton.anchorX = 1
	navigatePatchButton:addEventListener("touch", _M.navigatePatches)

	navigateText = display.newText( commonGroup, _s("Patches"), navigatePatchButton.contentBounds.xMin + navigatePatchButton.width / 2, navigatePatchButton.contentBounds.yMin + navigatePatchButton.height / 2, globals.font, 16 )
	navigateText.anchorX, navigateText.anchorY = 0.5, 0.5

	modalGroup = display.newGroup()
	local modal = display.newImageRect(modalGroup, "level-start-modal.png", 380, 570)
	modal.x, modal.y = -23, -44
	modal:addEventListener( "touch", _M.modalTouched )
	modal:addEventListener( "tap", _M.modalTouched )

	navigateModalGroup = display.newGroup()
	local navigateModalBackground = display.newImageRect(navigateModalGroup, "transparent-background.png", 380, 570)
	navigateModalBackground.x, navigateModalBackground.y = -23, -44
	navigateModalBackground:addEventListener( "touch", _M.modalTouched )
	navigateModalBackground:addEventListener( "tap", _M.modalTouched )

	local scrollView = widget.newScrollView
    {
        x = display.contentCenterX,
        y = display.contentCenterY,
        width = 200,
        height = 300,
        scrollHeight = 310,
        horizontalScrollDisabled = true
    }

    scrollView.anchorX, scrollView.anchorY = 0.5, 0.5

	local navigateModal = display.newImageRect(navigateModalGroup, "navigate-patches.png", 200, 300)
	scrollView:insert( navigateModal )

    navigateModalGroup:insert(scrollView)

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
	commonGroup:insert(navigateModalGroup)
	 _M:toggleModalVisible(false)

end

function _M:toFront()
	navigatePatchButton:toFront()
	navigateText:toFront()
	navigateModalGroup:toFront()
end

function _M:toggleModalVisible(visible, modal)
	local alpha = 0

	if(visible) then
		alpha = 1
	end

	if(modal == "modal" or modal == nil) then
		for i=1,modalGroup.numChildren do
	    	modalGroup[i].alpha = alpha
		end
	end

	if(modal == "navigate" or modal == nil) then
		for i=1,navigateModalGroup.numChildren do
			print(navigateModalGroup[i].alpha)
	    	navigateModalGroup[i].alpha = alpha
		end
	end 
end

function _M:createMarker(x, y, level)

	local levelMarker = display.newImageRect( commonGroup, "level-marker.png", 50,50)
    levelMarker.x = x + display.screenOriginX
    levelMarker.y = y
    local levelIdentifier = display.newText(commonGroup, level, levelMarker.x + levelMarker.width / 2, levelMarker.y +  levelMarker.height / 2, globals.font, 16)
    levelIdentifier.anchorX, levelIdentifier.anchorY = 0.5, 0.5
    levelMarker.level = level
    levelMarker:addEventListener("touch", _M.getLevelSelectModal)

    local data = file.loadLevelData(level)
	if(data ~= nil) then
		local dataText = display.newText(commonGroup, data.score, x, y, globals.font, 16)
	end
end

function _M.getLevelSelectModal(event)

	local levelSelect = "level"..event.target.level
-- load scene1

    levelConfig = require(levelSelect)
    levelText.text = _s("Level").." "..levelConfig.level

    _M:toggleModalVisible(true, "modal")

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
	_M:toggleModalVisible(false)
end

function _M.modalTouched(event)
	---stop propagation through dialog as to act like a modal
	return true
end

function _M.navigatePatches(event)

	_M:toggleModalVisible(true, "navigate")
end

return _M