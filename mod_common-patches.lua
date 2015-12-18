local globals = require("global-variables")
local composer = require("composer")
local _s = globals._s
local _M = {}
local world
local levelConfig
local commonGroup
local modalGroup
local navigateModalGroup
local levelText
local voleChit
local birdChit
local deerChit
local navigateScrollView
local navigatePatchButton
local closeNavigationButton
local closeNavImage = { type="image", filename="close-button.png" }
local closeNavImagePressed = { type="image", filename="close-button-pressed.png" }

local file = require("mod_file-management")
local widget = require("widget")
local patchConfig = require("patch-configuration")

function _M.new(sceneGroup, worldNumber)

	file:setBox(globals.levelDataFile)

	commonGroup = sceneGroup

	world = worldNumber

---------------------------------------------------------Navigation code start------------------------------------------------------------
	navigatePatchButton = widget.newButton
	{
	    width = 70,
	    height = 30,
	    defaultFile = "button-medium.png",
	    overFile = "button-medium-pressed.png",
	    onEvent = _M.navigatePatches,
	    label = _s("Patches"),
	    labelColor = {default = {0,0,0}, over = {1,1,1}},
	    font = globals.font
	}

	navigatePatchButton.x, navigatePatchButton.y = display.contentWidth - display.screenOriginX - 5, display.screenOriginY + 5
	commonGroup:insert(navigatePatchButton)
	navigatePatchButton.anchorX = 1

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

	navigateScrollView = widget.newScrollView
    {
        x = display.contentCenterX,
        y = display.contentCenterY,
        width = 200,
        height = 300,
        horizontalScrollDisabled = true,
        hideBackground = true,
        bottomPadding = 50
    }

    navigateScrollView.anchorX, navigateScrollView.anchorY = 0.5, 0.5

	local navigateModal = display.newImageRect(navigateModalGroup, "navigate-patches.png", 200, 300)
	navigateModal.x, navigateModal.y = display.contentCenterX, display.contentCenterY
	navigateModal.anchorX, navigateModal.anchorY = 0.5, 0.5
	navigateModalGroup:insert( navigateModal )

    navigateModalGroup:insert(navigateScrollView)

	closeNavigationButton = widget.newButton
	{
	    width = 30,
	    height = 30,
	    defaultFile = "close-button.png",
	    overFile = "close-button-pressed.png",
	    onEvent = _M.closeModal,
	    font = globals.font
	}
    closeNavigationButton.x, closeNavigationButton.y = navigateModal.contentBounds.xMax -18, navigateModal.contentBounds.yMin - 15
    navigateModalGroup:insert(closeNavigationButton)

    local globalData = require("mod_file-management")
    local data = globalData.loadGlobalData()

	for k, v in pairs(patchConfig) do

	    buttonConfig = {
	    	width = 200,
	    	height = 40,
	    	onEvent = _M.goToPatch,
	    	defaultFile = "navigate-button.png",
	    	labelColor = {default = {0,0,0}, over = {1,1,1}},
	    	font = globals.font,
	    	label = _s(v.name)
		}


		if(data == nil or data.maxLevel > v.minLevel) then
			if(v.minLevel > globals.minWorldAccessible) then
				buttonConfig.defaultFile = "navigate-button-disabled.png"
				buttonConfig.labelColor.over = {0,0,0}
			end
		end

		local button = widget.newButton(buttonConfig)
		button.anchorX = 0
		button.y = 40 * v.world
		button.enabled = true

		if(data == nil or data.maxLevel > v.minLevel) then
			if(v.minLevel > globals.minWorldAccessible) then
				button.enabled = false
			end
		end

		button.path = v.path
		button.world = v.world

		navigateScrollView:insert(button)
	end

---------------------------------------------------------Navigation code end ---------------------------------------------------------

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

	local playButton = widget.newButton
	{
	    width = 70,
	    height = 30,
	    defaultFile = "button-medium.png",
	    overFile = "button-medium-pressed.png",
	    onEvent = _M.goToLevel,
	    label = _s("Play"),
	    labelColor = {default = {0,0,0}, over = {1,1,1}},
	    font = globals.font
	}

	playButton.x, playButton.y = 220, 420
	modalGroup:insert(playButton)

	local goBackButton = widget.newButton
	{
	    width = 70,
	    height = 30,
	    defaultFile = "button-medium.png",
	    overFile = "button-medium-pressed.png",
	    onEvent = _M.closeModal,
	    label = _s("Go Back"),
	    labelColor = {default = {0,0,0}, over = {1,1,1}},
	    font = globals.font
	}

	goBackButton.x, goBackButton.y = 140, 420
	modalGroup:insert(goBackButton)

	commonGroup:insert(modalGroup)
	commonGroup:insert(navigateModalGroup)
	 _M:toggleModalVisible(false)

end

function _M:toFront()
	navigatePatchButton:toFront()
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
	    	navigateModalGroup[i].alpha = alpha
		end
	end 
end

function _M:createMarker(x, y, level)


	local pastLevel = level - 1

	if(pastLevel > 0) then
		levelConfig = require("level"..pastLevel)
		local pastData = file.loadLevelData(pastLevel)

		if(pastData == nil or pastData.score < levelConfig.target1) then
			return false
		end
	end

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

function _M.goToLevel(event)
	if(event.phase == "ended") then
		_M:toggleModalVisible(false)
    	composer.gotoScene(levelConfig.scene, {params = {levelConfig = levelConfig}} )
    end
end

function _M.closeModal(event)
	if(event.phase == "ended") then
		_M:toggleModalVisible(false)
	end
end

function _M.modalTouched(event)
	---stop propagation through dialog as to act like a modal
	return true
end

function _M.navigatePatches(event)
	if(event.phase == "ended") then
		closeNavigationButton.fill = closeNavImage
		_M:toggleModalVisible(true, "navigate")
	end
end

function _M.goToPatch(event)
	if event.phase == "moved" then -- Check if you moved your finger while touching
        local dy = math.abs( event.y - event.yStart ) -- Get the y-transition of the touch-input
        if dy > 5 then
        	navigateScrollView:takeFocus(event)
       end
    elseif(event.phase == "ended") then
    	print(event.target.enabled)
    	if(event.target.enabled) then
    		_M.toggleModalVisible(false)
    		if(event.target.world ~= world) then
    			composer.gotoScene( event.target.path)
    		end
    	end
   end
end

return _M