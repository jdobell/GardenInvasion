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

    local levelData = box:get("level"..level)

    return levelData
end

function file.loadGlobalData()

    local globalData = box:get("globaldata")

    return globalData
end

function file.saveGlobalData(t)

    box:set("globaldata", t)
    box:save()
end

function file.saveLevelData(t)
    
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
    file:setBox(globals.globalDataFile)

    local data = file.loadGlobalData()

    if(data.lives == nil) then
        data.lives = 0
    end

    if(data.lives > 0) then
        data.lives = data.lives - 1
    end

    file.saveGlobalData(data)

end
return file