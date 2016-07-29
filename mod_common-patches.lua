local globals = require("global-variables")
local composer = require("composer")
local _s = globals._s
local _M = {}
local world
local levelConfig
local commonGroup
local modalGroup
local modal
local navigateModalGroup
local confirmIAPModalGroup
local confirmIAPButton
local confirmIAPText
local fertilizerModalGroup
local levelText
local voleChit
local birdChit
local deerChit
local navigateScrollView
local navigatePatchButton
local closeNavigationButton
local buyFertilizerButton
local buyIAPButton
local livesLabel
local closeNavImage = { type="image", filename="close-button.png" }
local closeNavImagePressed = { type="image", filename="close-button-pressed.png" }
local timers = {}
local pestText
local plantingText
local plantingTargetText
local targetSeed
local harvestingSeed1
local harvestingSeed2
local harvestingSeed3
local harvestingSeedExplanation
local harvestingText
local targetText
local objectiveText
local boosterButtons = {}
local boosterSpriteSheets = {}
local boostersSelected = {}
local boosterMaxText 

local file = require("mod_file-management")
local widget = require("widget")
local patchConfig = require("patch-configuration")

----------------------------Slow down booster sprite setup --------------------------------
local slowSheetOptions =
{
    width = 100,
    height = 100,
    numFrames = 2
}

boosterSpriteSheets["slowDown"] = graphics.newImageSheet( "slow-down.png", slowSheetOptions )


----------------------------Button sprite setup----------------------------------------

local buttonSheetOptions =
{
    width = 70,
    height = 26.5,
    numFrames = 2
}

local buttonSheet = graphics.newImageSheet( "button-medium.png", buttonSheetOptions )

----------------------------Button sprite setup end----------------------------------------

----------------------------Close button sprite setup----------------------------------------

local closeButtonSheetOptions =
{
    width = 40,
    height = 42.5,
    numFrames = 2
}

local closeButtonSheet = graphics.newImageSheet( "button-close.png", closeButtonSheetOptions )

----------------------------Close button sprite setup end----------------------------------------

----------------------------Slow down sprite setup end-----------------------------

function _M.new(sceneGroup, worldNumber)

	table.insert(timers, timer.performWithDelay( 60000, _M.checkLives, 0))

	commonGroup = sceneGroup

	world = worldNumber

---------------------------------------------------------Navigation code start------------------------------------------------------------
	navigatePatchButton = widget.newButton
	{
	    width = 70,
	    height = 30,
	    sheet = buttonSheet,
	    defaultFrame = 1,
	    overFrame = 2,
	    onEvent = _M.navigatePatches,
	    label = _s("Patches"),
	    labelColor = {default = {0,0,0}, over = {1,1,1}},
	    font = globals.boldFont,
	    fontSize = 13,
	    emboss = true
	}

	navigatePatchButton.x, navigatePatchButton.y = display.contentWidth - display.screenOriginX - 5, display.screenOriginY + 5
	commonGroup:insert(navigatePatchButton)
	navigatePatchButton.anchorX = 1

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

    navigateModalGroup:insert(navigateScrollView)

	closeNavigationButton = widget.newButton
	{
	    width = 30,
	    height = 30,
		sheet = closeButtonSheet,
	    defaultFrame = 1,
	    overFrame = 2,
	    onEvent = _M.closeModal,
	    font = globals.font
	}
    closeNavigationButton.x, closeNavigationButton.y = navigateModal.contentBounds.xMax -18, navigateModal.contentBounds.yMin - 15
    navigateModalGroup:insert(closeNavigationButton)

    local data = file.loadGlobalData()

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


		if(data == nil or data.maxLevel == nil or data.maxLevel > v.minLevel) then
			if(v.minLevel > globals.minWorldAccessible) then
				buttonConfig.defaultFile = "navigate-button-disabled.png"
				buttonConfig.labelColor.over = {0,0,0}
			end
		end

		local button = widget.newButton(buttonConfig)
		button.anchorX = 0
		button.y = 40 * v.world
		button.enabled = true

		if(data == nil or data.maxLevel == nil or data.maxLevel > v.minLevel) then
			if(v.minLevel > globals.minWorldAccessible) then
				button.enabled = false
			end
		end

		button.path = v.path
		button.world = v.world

		navigateScrollView:insert(button)
	end

	local globalData = file.loadGlobalData()

	if(globalData == nil) then
		globalData = {}
	end

	if(globalData.lives == nil) then
		globalData.lives = globals.maxLives
		globalData.lastLifeGiven = os.time()
		file.saveGlobalData(globalData)
	end

	livesLabel = display.newText( commonGroup, _s("Lives:").." "..globalData.lives, display.screenOriginX + 5, display.screenOriginY + 5, globals.font, 16)

	-------------Buy fertilizer dialog is also In App Purchase Dialog-----------------------------
	_M:createBuyFertilizerDialog()
	_M:createBuyInAppPurchaseDialog()
	

---------------------------------------------------------Navigation/Fertilizer dialog code end ---------------------------------------------------------

	confirmIAPModalGroup = display.newGroup()

	local confirmIAPModalBackground = display.newImageRect(confirmIAPModalGroup, "transparent-background.png", 380, 570)
	confirmIAPModalBackground.x, confirmIAPModalBackground.y = -23, -44
	confirmIAPModalBackground:addEventListener( "touch", _M.modalTouched )
	confirmIAPModalBackground:addEventListener( "tap", _M.modalTouched )

	local confirmIAPModal = display.newImageRect(confirmIAPModalGroup, "buy-fertilizer-background.png", 150, 150)
	confirmIAPModal.x, confirmIAPModal.y = display.contentCenterX, display.contentCenterY
	confirmIAPModal.anchorX, confirmIAPModal.anchorY = 0.5, 1

	closeConfirmModalButton = widget.newButton
	{
	    width = 30,
	    height = 30,
	    sheet = closeButtonSheet,
	    defaultFrame = 1,
	    overFrame = 2,
	    onEvent = _M.closeModal,
	}
    closeConfirmModalButton.x, closeConfirmModalButton.y = confirmIAPModal.contentBounds.xMax -18, confirmIAPModal.contentBounds.yMin - 15
    confirmIAPModalGroup:insert(closeConfirmModalButton)

    --to only close this modal
    closeConfirmModalButton.modal = "confirmIAP"

	local confirmIAPTitle = display.newText(confirmIAPModalGroup, _s("Confirm IAP Title"), confirmIAPModal.contentBounds.xMin + confirmIAPModal.width / 2, confirmIAPModal.contentBounds.yMin + 10, globals.font, 14)
	confirmIAPTitle.anchorX = 0.5

	confirmIAPText = display.newText(confirmIAPModalGroup, "", confirmIAPModal.contentBounds.xMin + 10, confirmIAPModal.contentBounds.yMin + 35, 130, 90, globals.font, 12)

	confirmIAPButton = widget.newButton
	{
	    width = 70,
	    height = 30,
	    sheet = buttonSheet,
	    defaultFrame = 1,
	    overFrame = 2,
	    onEvent = _M.confirmIAPPurchase,
	    label = _s("Confirm"),
	    labelColor = {default = {0,0,0}, over = {1,1,1}},
	    font = globals.boldFont,
	    fontSize= 13,
	    emboss = true
	}

	confirmIAPButton.x, confirmIAPButton.y = confirmIAPModal.contentBounds.xMax - 10, confirmIAPModal.contentBounds.yMax - 10
	confirmIAPButton.anchorX, confirmIAPButton.anchorY = 1,1
	confirmIAPModalGroup:insert(confirmIAPButton)

	modalGroup = display.newGroup()

	local modalBackground = display.newImageRect(modalGroup, "transparent-background.png", 380, 570)
	modalBackground.x, modalBackground.y = -23, -44
	modalBackground:addEventListener( "touch", _M.modalTouched )
	modalBackground:addEventListener( "tap", _M.modalTouched )

	modal = display.newImageRect(modalGroup, "level-start-modal.png", 280, 440)
	modal.x, modal.y = display.contentWidth / 2, display.contentHeight / 2
	modal.anchorX, modal.anchorY = 0.5, 0.5
	modal:addEventListener( "touch", _M.modalTouched )
	modal:addEventListener( "tap", _M.modalTouched )

	levelText = display.newText(modalGroup, "", modal.contentBounds.xMin + 21, modal.contentBounds.yMin + 15, globals.font, 16)
	levelText:setFillColor( black )

	plantingText = display.newText(modalGroup, _s("Planting Level"), modal.contentBounds.xMin + modal.width / 2, modal.y -170, globals.font, 16)
	plantingText.anchorX = 0.5
	plantingText:setFillColor( black )

	plantingTargetText = display.newText(modalGroup, _s("Seed to Plant:"), modal.x - 113, modal.y -125, globals.font, 16)
	plantingTargetText:setFillColor( black )
	
	harvestingText = display.newText(modalGroup, _s("Harvesting Level"), modal.contentBounds.xMin + modal.width / 2, modal.y -170, globals.font, 16)
	harvestingText.anchorX = 0.5
	harvestingText:setFillColor( black )

	harvestingSeed1 = display.newImageRect(modalGroup, "harvesting-modal-sprout.png", 30, 30)
	harvestingSeed1.x, harvestingSeed1.y = modal.x - 40, modal.y - 130
	harvestingSeed1.anchorX = 0.5
	harvestingSeed2 = display.newImageRect(modalGroup, "harvesting-modal-sprout-big.png", 30, 30)
	harvestingSeed2.x, harvestingSeed2.y = modal.x, modal.y - 130
	harvestingSeed2.anchorX = 0.5
	harvestingSeed3 = display.newImageRect(modalGroup, "harvesting-modal-plant.png", 30, 30)
	harvestingSeed3.x, harvestingSeed3.y = modal.x + 40, modal.y - 130
	harvestingSeed3.anchorX = 0.5

	pestText = display.newText(modalGroup, _s("Pests"), modal.contentBounds.xMin + modal.width / 2, modal.y -170, globals.font, 16)
	pestText.anchorX = 0.5
	pestText:setFillColor( black )

	voleChit = display.newImageRect(modalGroup, "vole-chit.png", 40, 40)
	voleChit.x, voleChit.y = modal.x - 95, modal.y - 143

	birdChit = display.newImageRect(modalGroup, "bird-chit.png", 40, 40)
	birdChit.x, birdChit.y = modal.x - 23, modal.y - 143

	deerChit = display.newImageRect(modalGroup, "deer-chit.png", 40, 40)
	deerChit.x, deerChit.y = modal.x + 48, modal.y - 143

	objectiveText = display.newText(modalGroup, _s("Objective:"), modal.x - 113, modal.y -55, 235, 0, globals.font, 16)
	objectiveText.anchorX = 0
	objectiveText:setFillColor( black )

	noBoosterText = display.newText(modalGroup, _s("BoostersNotUnlocked"), modal.x - 113, modal.y + 110, 235, 0, globals.font, 16)	
	noBoosterText.anchorX = 0
	noBoosterText:setFillColor( black )


	targetText = display.newText(modalGroup, _s("Target:"), modal.x - 113, modal.y + 30, globals.font, 16)
	targetText.anchorX = 0
	targetText:setFillColor( black )

	local boosterText = display.newText(modalGroup, _s("Power Ups:"), modal.contentBounds.xMin + modal.width / 2, modal.y + 85, globals.font, 16)
	boosterText.anchorX = 0.5
	boosterText:setFillColor( black )

	boosterMaxText = display.newText(modalGroup, _s("Maximum booster reached"), modal.contentBounds.xMin + 20, modal.y + 185, globals.font, 14)
	boosterMaxText.anchorX = 0
	boosterMaxText:setFillColor(1,0,0)
	boosterMaxText.show = false

	local playButton = widget.newButton
	{
	    width = 70,
	    height = 30,
	   	sheet = buttonSheet,
	    defaultFrame = 1,
	    overFrame = 2,
	    onEvent = _M.goToLevel,
	    label = _s("Play"),
	    labelColor = {default = {0,0,0}, over = {1,1,1}},
	    font = globals.boldFont,
	    emboss = true
	}

	playButton.x, playButton.y = 220, 420
	modalGroup:insert(playButton)

	closeModalButton = widget.newButton
	{
	    width = 30,
	    height = 30,
	    sheet = closeButtonSheet,
	    defaultFrame = 1,
	    overFrame = 2,
	    onEvent = _M.closeModal,
	}
    closeModalButton.x, closeModalButton.y = modal.contentBounds.xMax -18, modal.contentBounds.yMin - 15
    modalGroup:insert(closeModalButton)

	commonGroup:insert(modalGroup)
	commonGroup:insert(navigateModalGroup)
	commonGroup:insert(fertilizerModalGroup)
	commonGroup:insert(IAPModalGroup)
	commonGroup:insert(confirmIAPModalGroup)
	 _M:toggleModalVisible(false)


	_M.checkLives()
end

function _M:createBuyFertilizerDialog()

	buyFertilizerButton = widget.newButton
	{
		width = 30,
		height = 30,
		defaultFile = "fertilizer-icon.png",
		overFile = "fertilizer-icon-over.png",
		onEvent = _M.openBuyFertilizerDialog
	}

	buyFertilizerButton.x, buyFertilizerButton.y = display.screenOriginX + 5, display.screenOriginY + 30
	commonGroup:insert(buyFertilizerButton)
	buyFertilizerButton.anchorX = 0

	fertilizerModalGroup = display.newGroup()
	local fertilizerModalBackground = display.newImageRect(fertilizerModalGroup, "transparent-background.png", 380, 570)
	fertilizerModalBackground.x, fertilizerModalBackground.y = -23, -44
	fertilizerModalBackground:addEventListener( "touch", _M.modalTouched )
	fertilizerModalBackground:addEventListener( "tap", _M.modalTouched )

	fertilizerScrollView = widget.newScrollView
    {
        x = display.contentCenterX,
        y = display.contentCenterY + 15,
        width = 250,
        height = 70,
        verticalScrollDisabled = true,
        hideBackground = true,
    }

    fertilizerScrollView.anchorX, fertilizerScrollView.anchorY = 0.5, 0.5

	local fertilizerModal = display.newImageRect(fertilizerModalGroup, "buy-fertilizer-background.png", 250, 130)
	fertilizerModal.x, fertilizerModal.y = display.contentCenterX, display.contentCenterY
	fertilizerModal.anchorX, fertilizerModal.anchorY = 0.5, 0.5
	fertilizerModalGroup:insert( fertilizerModal )

	local buyFertilizerText = display.newText(fertilizerModalGroup, _s("Buy Fertilizer"), fertilizerModal.contentBounds.xMin + fertilizerModal.width / 2, fertilizerModal.contentBounds.yMin + 7, globals.font, 16)
	buyFertilizerText.anchorX = 0.5

    fertilizerModalGroup:insert(fertilizerScrollView)

    local creditsText = display.newText(fertilizerModalGroup, "", fertilizerModal.contentBounds.xMin + 10, fertilizerModal.contentBounds.yMin + 25, globals.font, 14)
    creditsText.credit = true
	creditsText.anchorX = 0

	closeFertilizerButton = widget.newButton
	{
	    width = 30,
	    height = 30,
	    sheet = closeButtonSheet,
	    defaultFrame = 1,
	    overFrame = 2,
	    onEvent = _M.closeModal,
	}
    closeFertilizerButton.x, closeFertilizerButton.y = fertilizerModal.contentBounds.xMax -18, fertilizerModal.contentBounds.yMin - 15
    fertilizerModalGroup:insert(closeFertilizerButton)

    local buttonConfig = {
    	width = 55,
	    height = 60,
	    defaultFile = "fertilizer-scoop.png",
	    overFile = "fertilizer-scoop-over.png",
	    onEvent = _M.buyFertilizer,
	    font = globals.font,
	    left = 18
	}

	local fertilizerScoopGroup = display.newGroup()
	local scoopButton = widget.newButton(buttonConfig)
	scoopButton.amount = 1
	scoopButton.type = "scoop"
	fertilizerScoopGroup:insert(scoopButton)
	commonGroup:insert(fertilizerScoopGroup)

	local scoopText = display.newText(fertilizerScoopGroup, _s("Scoop"), scoopButton.contentBounds.xMin + scoopButton.width / 2, scoopButton.contentBounds.yMax, globals.font, 13)
	scoopText.anchorX, scoopText.anchorY = 0.5, 1

	local scoopAmountLabel = display.newText(fertilizerScoopGroup, scoopButton.amount, scoopButton.contentBounds.xMin + scoopButton.width / 2, scoopButton.contentBounds.yMin + scoopButton.height / 2, globals.font, 16)
	scoopAmountLabel.anchorX, scoopAmountLabel.anchorY = 0.5, 0.5

	fertilizerScrollView:insert(fertilizerScoopGroup)

	buttonConfig = {
    	width = 60,
	    height = 42,
	    defaultFile = "fertilizer-bucket.png",
	    overFile = "fertilizer-bucket-over.png",
	    onEvent = _M.buyFertilizer,
	    font = globals.font,
	    left = scoopButton.contentBounds.xMax - 10
	}

	local fertilizerBucketGroup = display.newGroup()
	local bucketButton = widget.newButton(buttonConfig)
	bucketButton.amount = 5
	bucketButton.type = "bucket"
	fertilizerBucketGroup:insert(bucketButton)
	commonGroup:insert(fertilizerBucketGroup)

	local bucketText = display.newText(fertilizerBucketGroup, _s("Bucket"), bucketButton.contentBounds.xMin + bucketButton.width / 2, bucketButton.contentBounds.yMax + 20, globals.font, 13)
	bucketText.anchorX, bucketText.anchorY = 0.5, 1

	local bucketAmountLabel = display.newText(fertilizerBucketGroup, bucketButton.amount, bucketButton.contentBounds.xMin + bucketButton.width / 2, bucketButton.contentBounds.yMin + bucketButton.height / 2, globals.font, 16)
	bucketAmountLabel.anchorX, bucketAmountLabel.anchorY = 0.5, 0.5

	fertilizerScrollView:insert(fertilizerBucketGroup)

	buttonConfig = {
    	width = 55,
	    height = 60,
	    defaultFile = "fertilizer-bag.png",
	    overFile = "fertilizer-bag-over.png",
	    onEvent = _M.buyFertilizer,
	    font = globals.font,
	    left = bucketButton.contentBounds.xMax - 10
	}

	local fertilizerBagGroup = display.newGroup()
	local bagButton = widget.newButton(buttonConfig)
	bagButton.amount = 10
	bagButton.type = "bag"
	fertilizerBagGroup:insert(bagButton)
	commonGroup:insert(fertilizerBagGroup)

	local bagText = display.newText(fertilizerBagGroup, _s("Bag"), bagButton.contentBounds.xMin + bagButton.width / 2, bagButton.contentBounds.yMax, globals.font, 13)
	bagText.anchorX, bagText.anchorY = 0.5, 1

	local bagAmountLabel = display.newText(fertilizerBagGroup, bagButton.amount, bagButton.contentBounds.xMin + bagButton.width / 2, bagButton.contentBounds.yMin + bagButton.height / 2, globals.font, 16)
	bagAmountLabel.anchorX, bagAmountLabel.anchorY = 0.5, 0.5


	fertilizerScrollView:insert(fertilizerBagGroup)
end

function _M:createBuyInAppPurchaseDialog()

	buyIAPButton = widget.newButton
	{
		width = 40,
		height = 35,
		defaultFile = "IAP-icon.png",
		overFile = "IAP-icon-over.png",
		onEvent = _M.openBuyIAPDialog
	}

	buyIAPButton.x, buyIAPButton.y = display.screenOriginX + 5, display.screenOriginY + 70
	commonGroup:insert(buyIAPButton)
	buyIAPButton.anchorX = 0

	IAPModalGroup = display.newGroup()
	local IAPModalBackground = display.newImageRect(IAPModalGroup, "transparent-background.png", 380, 570)
	IAPModalBackground.x, IAPModalBackground.y = -23, -44
	IAPModalBackground:addEventListener( "touch", _M.modalTouched )
	IAPModalBackground:addEventListener( "tap", _M.modalTouched )

	IAPScrollView = widget.newScrollView
    {
        x = display.contentCenterX,
        y = display.contentCenterY + 15,
        width = 250,
        height = 70,
        verticalScrollDisabled = true,
        hideBackground = true,
    }

    IAPScrollView.anchorX, IAPScrollView.anchorY = 0.5, 0.5

	local IAPModal = display.newImageRect(IAPModalGroup, "buy-fertilizer-background.png", 250, 130)
	IAPModal.x, IAPModal.y = display.contentCenterX, display.contentCenterY
	IAPModal.anchorX, IAPModal.anchorY = 0.5, 0.5
	IAPModalGroup:insert( IAPModal )

	local buyIAPText = display.newText(IAPModalGroup, _s("Farmer's Market"), IAPModal.contentBounds.xMin + IAPModal.width / 2, IAPModal.contentBounds.yMin + 7, globals.font, 16)
	buyIAPText.anchorX = 0.5

    IAPModalGroup:insert(IAPScrollView)

    local creditsText = display.newText(IAPModalGroup, "", IAPModal.contentBounds.xMin + 10, IAPModal.contentBounds.yMin + 25, globals.font, 14)
	creditsText.credit = true
	creditsText.anchorX = 0

	closeIAPButton = widget.newButton
	{
	    width = 30,
	    height = 30,
	    sheet = closeButtonSheet,
	    defaultFrame = 1,
	    overFrame = 2,
	    onEvent = _M.closeModal,
	}
    closeIAPButton.x, closeIAPButton.y = IAPModal.contentBounds.xMax -18, IAPModal.contentBounds.yMin - 15
    IAPModalGroup:insert(closeIAPButton)

	local purchaseItems = {}
	purchaseItems["slowDown"] = {sheet = boosterSpriteSheets["slowDown"], confirmText = "slowDownPurchase"}
	purchaseItems["lives"] = {defaultFile = "lives-button.png", overFile = "lives-button-over.png", confirmText = "livesPurchase"}

	local xStart = 15

	for k,v in pairs(purchaseItems) do

		v.width = 60
		v.height = 60
		v.onEvent = _M.buyIAP
		v.font = globals.font
		v.left = xStart

		if(v.sheet ~= nil) then
			v.defaultFrame = 1
			v.overFrame = 2
		end

		local button = widget.newButton(v)
		button.anchorx = 0.5

		button.confirmText = v.confirmText
		button.selected = k

		if(v.sheet ~= nil) then
			button.height = 60
			button.width = 60
		end

		IAPScrollView:insert(button)

		xStart = xStart + 80
	end
end

function _M:toFront()
	navigatePatchButton:toFront()
	navigateModalGroup:toFront()
	confirmIAPModalGroup:toFront()
	buyFertilizerButton:toFront()
	buyIAPButton:toFront()
	livesLabel:toFront()
end

function _M:toggleModalVisible(visible, modal)
	local alpha = 0

	if(visible) then
		alpha = 1
	end

	if(modal == "modal" or modal == nil) then
		for i=1,modalGroup.numChildren do
			if(alpha == 0 or modalGroup[i].show == nil) then
				modalGroup[i].alpha = alpha
			elseif(modalGroup[i].show == true) then
	    		modalGroup[i].alpha = 1
	    	elseif(modalGroup[i].show == false) then
	    		modalGroup[i].alpha = 0
	    	end
		end
	end

	if(modal == "navigate" or modal == nil) then
		for i=1,navigateModalGroup.numChildren do
	    	navigateModalGroup[i].alpha = alpha
		end
	end

	if(modal == "confirmIAP" or modal == nil) then
		for i=1,confirmIAPModalGroup.numChildren do
	    	confirmIAPModalGroup[i].alpha = alpha
		end
	end

	if(modal == "fertilizer" or modal == nil) then
		for i=1,fertilizerModalGroup.numChildren do
	    	fertilizerModalGroup[i].alpha = alpha

	    	if(fertilizerModalGroup[i].credit ~= nil) then
				local globalData = file.loadGlobalData()
	    		if(globalData.credits == nil) then
	    			globalData.credits = 0
	    			file.saveGlobalData(globalData)
	    		end

	    		fertilizerModalGroup[i].text = _s("Credits:")..globalData.credits
	    	end
		end
	end

	if(modal == "IAP" or modal == nil) then
		for i=1,IAPModalGroup.numChildren do
	    	IAPModalGroup[i].alpha = alpha

			if(IAPModalGroup[i].credit ~= nil) then
		    	local globalData = file.loadGlobalData()

				if(globalData.credits == nil) then
		    		globalData.credits = 0
		    		file.saveGlobalData(globalData)
		   		end

	    		IAPModalGroup[i].text = _s("Credits:")..globalData.credits
	    	end
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

end

function _M.getLevelSelectModal(event)

	local levelSelect = "level"..event.target.level
-- load scene1

    levelConfig = require(levelSelect)
    levelText.text = _s("Level").." "..levelConfig.level

    boostersSelected = {}

    data = file.loadLevelData(levelConfig.level)

    local gameType = levelConfig.objective.gameType

    if(gameType == "score" or gameType == "achieveStreaks" or gameType == "finishStreaks") then
    	pestText.show = true

	    if(levelConfig.birdsInLevel == true) then
	    	birdChit.show = true
	    else
	    	birdChit.show = false
	    end

	    if(levelConfig.deerInLevel == true) then
	    	deerChit.show = true
	    else
	    	deerChit.show = false
	    end

    	voleChit.show = true
    	plantingText.show = false
    	plantingTargetText.show = false
    	harvestingText.show = false
    	harvestingSeed1.show = false
    	harvestingSeed2.show = false
    	harvestingSeed3.show = false

    	if(targetSeed ~= nil) then
    		targetSeed.show = false
    	end
    else
		pestText.show = false
    	voleChit.show = false
    	birdChit.show = false
    	deerChit.show = false

    	if(gameType == "planting") then
    		plantingText.show = true
    		plantingTargetText.show = true

    		targetSeed = display.newImageRect(modalGroup, levelConfig.targetSeed..".png", 40, 40)
    		targetSeed.x, targetSeed.y = modal.contentBounds.xMin + 160, modal.y -135
    		targetSeed.show = true

			harvestingText.show = false
    		harvestingSeed1.show = false
    		harvestingSeed2.show = false
    		harvestingSeed3.show = false
    	elseif(gameType == "harvesting") then
    		harvestingText.show = true
    		harvestingSeed1.show = true
    		harvestingSeed2.show = true
    		harvestingSeed3.show = true

    		plantingText.show = false
    		if(targetSeed ~= nil) then
    			targetSeed.show = false
    		end
    		plantingTargetText.show = false
    	end
    end

    --dertermine what to show in target box

    local levelScore
    if(data == nil or data.score == nil) then
    	levelScore = 0
    else
    	levelScore = data.score
    end

    if(levelScore >= levelConfig.target3) then
    	targetText.text = _s("Target:").." ".._s("Complete")
	elseif(levelScore >= levelConfig.target2) then
		targetText.text = _s("Target:").." "..levelConfig.target3
	elseif(levelScore >= levelConfig.target1) then
		targetText.text = _s("Target:").." "..levelConfig.target2
	else
		targetText.text = _s("Target:").." "..levelConfig.target1
	end

	--determine what to display in objective box
	local streakTypes = 0
	local streakText = ""
	if(levelConfig.objective.cats > 0) then
		if(levelConfig.objective.cats > 1) then
			streakText = levelConfig.objective.cats.." ".._s("cats")
		else
			streakText = levelConfig.objective.cats.." ".._s("cat")
		end
		streakTypes = streakTypes + 1
	end
	if(levelConfig.objective.eagles > 0) then
		
		if(streakTypes > 0) then
			if(levelConfig.objective.dogs > 0) then
				streakText = streakText..", "
			else
				streakText = streakText.." ".._s("and").." "
			end
		end

		if(levelConfig.objective.eagles > 1) then
			streakText = streakText..levelConfig.objective.eagles.." ".._s("eagles")
		else
			streakText = streakText..levelConfig.objective.eagles.." ".._s("eagle")
		end

		streakTypes = streakTypes + 1
	end
	if(levelConfig.objective.dogs > 0) then
		if(streakTypes > 0) then
			streakText = streakText.." ".._s("and").." "
		end
		
		if(levelConfig.objective.dogs > 1) then
			streakText = streakText..levelConfig.objective.dogs.." ".._s("dogs")
		else
			streakText = streakText..levelConfig.objective.dogs.." ".._s("dog")
		end
	end

	if(gameType == "score") then
		objectiveText.text = _s("Objective:").." ".._s("ReachScore")
	elseif(gameType == "achieveStreaks") then
		objectiveText.text = _s("Objective:").." ".._s("AchieveStreaks1").." "..streakText.." ".._s("AchieveStreaks2")
	elseif(gameType == "finishStreaks") then
		objectiveText.text = _s("Objective:").." ".._s("FinishStreaks1").." "..streakText.." ".._s("FinishStreaks2")
	elseif(gameType == "planting") then
		objectiveText.text = _s("Objective:").." ".._s("PlantingObjective")
	elseif(gameType == "harvesting") then
		objectiveText.text = _s("Objective:").." ".._s("HarvestingObjective")
	end

	if (levelConfig.levelStartBoosters == nil or table.maxn(levelConfig.levelStartBoosters) == 0) then
		noBoosterText.show = true
	else
		noBoosterText.show = false
	end

	local boosterX = modal.x - 110

	for i=1, 3 do

		if(boosterButtons[i] ~= nil) then
			boosterButtons[i].availableText:removeSelf()
			boosterButtons[i].boosterSelectedText:removeSelf()
			boosterButtons[i]:removeSelf()
			boosterButtons[i].boosterSelected = nil
			boosterButtons[i] = nil

		end

		if(levelConfig.levelStartBoosters[i] ~= nil) then


			boosterButtons[i] = widget.newButton(
								    {
								    	parent = modalGroup,
								        sheet = boosterSpriteSheets[levelConfig.levelStartBoosters[i]],
								        defaultFrame = 1,
								        overFrame = 2,
								        onEvent = _M.boosterSelected
								    }
								)
			boosterButtons[i].booster = levelConfig.levelStartBoosters[i]
			modalGroup:insert(boosterButtons[i])
			boosterButtons[i]:scale(.35,.35)
			boosterButtons[i].x, boosterButtons[i].y = boosterX + (20*i), modal.y + 107

			local globalData = file.loadGlobalData()

			if(globalData[levelConfig.levelStartBoosters[i]] == nil) then
				globalData[levelConfig.levelStartBoosters[i]] = 0
				file.saveGlobalData(globalData)
			else
				--globalData[levelConfig.levelStartBoosters[i]] = 3
				--file.saveGlobalData(globalData)
			end

			local available = globalData[levelConfig.levelStartBoosters[i]]

			if(available == 0) then
				available = "$"
			end

			local availableText = display.newText( modalGroup, available, boosterButtons[i].x+30, boosterButtons[i].y+30, globals.font, 14)
			availableText:setFillColor( black )
			boosterButtons[i].availableText = availableText
			boosterButtons[i].available = globalData[levelConfig.levelStartBoosters[i]]
			boosterButtons[i].max = levelConfig.levelStartBoostersMax[levelConfig.levelStartBoosters[i]]

			local boosterSelectedText = display.newText( modalGroup, "", boosterButtons[i].x + 12, boosterButtons[i].y + 7, globals.font, 20)
			boosterSelectedText:setFillColor( black )
			boosterButtons[i].boosterSelectedText = boosterSelectedText
			boosterButtons[i].boosterSelected = 0

			--clean up variable about to be orphaned
			available = nil
		end
	end

    _M:toggleModalVisible(true, "modal")

    modalGroup:toFront()
end

function _M.goToLevel(event)
	if(event.phase == "ended") then
		_M:toggleModalVisible(false)
		_M:cancelTimers()

		local data = file.loadGlobalData()

		for k,v in pairs(boostersSelected) do

			if(data[k] ~= nil) then
				data[k] = data[k] - v
			end
		end

		file.saveGlobalData(data)

    	composer.gotoScene(levelConfig.scene, {params = {levelConfig = levelConfig, boosters = boostersSelected}} )
    end
end

function _M.closeModal(event)
	if(event.phase == "ended") then
		_M:toggleModalVisible(false, event.target.modal)
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
    	if(event.target.enabled) then
    		_M:toggleModalVisible(false)
    		if(event.target.world ~= world) then
    			_M:cancelTimers()
    			composer.gotoScene( event.target.path)
    		end
    	end
   end
end

function _M.openBuyFertilizerDialog(event)

	if(event.phase == "ended") then

		local startingPoint = fertilizerModalGroup.y
		transition.to(fertilizerModalGroup, {y=startingPoint - 300, time=10, 
			onComplete=	function(object)
				_M:toggleModalVisible(true, "fertilizer")
				fertilizerModalGroup:toFront()
				transition.to(fertilizerModalGroup, {y=startingPoint, time=800, transition=easing.outBounce})	
			end
		})

    	
    end
end

function _M.openBuyIAPDialog(event)

	if(event.phase == "ended") then

		local startingPoint = IAPModalGroup.y
		transition.to(IAPModalGroup, {y=startingPoint - 300, time=10, 
			onComplete=	function(object)
				_M:toggleModalVisible(true, "IAP")
				IAPModalGroup:toFront()
				transition.to(IAPModalGroup, {y=startingPoint, time=800, transition=easing.outBounce})	
			end
		})
    end
end

function _M.boosterSelected(event)

	if(event.phase == "ended") then
		local booster = event.target

		if(booster.available > 0) then
			local currentSelected = boostersSelected[booster.booster]

			if(currentSelected == nil) then
				currentSelected = 0
			end

			if(currentSelected < booster.max) then
				boostersSelected[booster.booster] = currentSelected + 1
				booster.boosterSelected = boostersSelected[booster.booster]
				booster.boosterSelectedText.text = booster.boosterSelected
				booster.available = booster.available - 1
				booster.availableText.text = booster.available
			else
				boosterMaxText.alpha = 1
				transition.fadeOut( boosterMaxText, {time=2000} )
			end
		end

		if(booster.available == 0) then
			booster.availableText.text = "$"
		end
	end
end

function _M.buyFertilizer(event)
	if event.phase == "moved" then -- Check if you moved your finger while touching
        local dx = math.abs( event.x - event.xStart ) -- Get the y-transition of the touch-input
        if dx > 5 then
        	fertilizerScrollView:takeFocus(event)
        end
    elseif(event.phase == "ended") then

	    local button = event.target

      	--button.type for store
       	local amount = button.amount

       	--initiate store
       	local data = file.loadGlobalData()

       	if(data.credits == nil) then
       		data.credits = 0
       	end

       	data.credits = data.credits + amount
       	file.saveGlobalData(data)

       	_M:toggleModalVisible(true, "fertilizer")
    end
end

function _M.buyIAP(event)
	if event.phase == "moved" then -- Check if you moved your finger while touching
        local dx = math.abs( event.x - event.xStart ) -- Get the y-transition of the touch-input
        if dx > 5 then
        	IAPScrollView:takeFocus(event)
        end
    elseif event.phase == "ended" then

    	confirmIAPButton.currentSelected = event.target

		_M:toggleModalVisible(true, "confirmIAP")
		confirmIAPModalGroup:toFront()
		confirmIAPText.text = _s(event.target.confirmText)
    end
end

function _M.confirmIAPPurchase(event)

	if event.phase == "ended" then
		local IAP = event.target.currentSelected.selected
		local transactionComplete = false

		if(IAP == "lives") then
			local globalData = file.loadGlobalData()

			globalData.lives = globals.maxLives
			globalData.lastLifeGiven = os.time()
			file.saveGlobalData(globalData)
			_M.checkLives()
			transactionComplete = true

		elseif(IAP == "slowDown") then

		end

		if(transactionComplete) then
			_M:toggleModalVisible(false, "confirmIAP")
		end
	end
end

function _M.checkLives()

	local numLives = file.checkLives()

	livesLabel.text = _s("Lives:").." "..numLives
end

function _M:cancelTimers()
	for k,v in pairs(timers) do
		timer.cancel(v)
	end
end

function _M:cleanUp()
	boosterButtons = {}
end

return _M