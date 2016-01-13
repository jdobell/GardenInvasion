local GGData = require( "GGData" ) -- Assumes GGData.lua is in root folder
local crypto = require( "crypto" )
local globals = require("global-variables")
local box

local file = {}

function file:setBox(boxName)
    box = GGData:new(boxName) -- You may name the 'box' anything you like.

    local securityKey = "ThEoDa" -- Change this for each app

    box:enableIntegrityControl( crypto.sha512, securityKey )

    local corruptEntries = box:verifyIntegrity()

end

function file.loadLevelData(level)
    
    file:setBox(globals.levelDataFile)
    local levelData = box:get("level"..level)

    return levelData
end

function file.loadGlobalData()
    file:setBox(globals.globalDataFile)
    local globalData = box:get("globaldata")

    return globalData
end

function file.saveGlobalData(t)
    file:setBox(globals.globalDataFile)
    box:set("globaldata", t)
    box:save()
end

function file.saveLevelData(t)
    
    file:setBox(globals.levelDataFile)
    local levelData = box:get("level"..t.level)

    if(levelData == nil) then
        box:set("level"..t.level, t)
        box:save()
    else
        if(t.score > levelData.score) then
            levelData.score = t.score

            box:set("level"..t.level, levelData)
            box:save()
        end
    end
end

function file.loseLife()

    file.checkLives()

    file:setBox(globals.globalDataFile)

    local data = file.loadGlobalData()

    if(data.lives == nil) then
        data.lives = 0
    end

    if(data.lives > 0) then
        data.lives = data.lives - 1
        data.lastLifeGiven = os.time()
    end

    file.saveGlobalData(data)
    print(data.lives)
end

function file.checkLives()
    file:setBox(globals.globalDataFile)
    local data = file.loadGlobalData()
print(data.lives)
    local now = os.time()
    --round both now and last saved life down to the nearest half hour to calculate how many ***half hours*** have passed
    now = now - (now % globals.timeBetweenLives)
    local lastLife = data.lastLifeGiven
    lastLife = lastLife - (lastLife % globals.timeBetweenLives)

    local difference = now - lastLife
print(os.date("%c", now), os.date("%c",lastLife), difference)
    if(difference > 0) then
        local livesToGive = math.floor(difference / globals.timeBetweenLives)

        if(livesToGive > 0) then
            data.lives = data.lives + livesToGive
            data.lastLifeGiven = now

            if(data.lives > globals.maxLives) then
                data.lives = globals.maxLives
            end

            file.saveGlobalData(data)
        end
    end

    return data.lives
end
return file