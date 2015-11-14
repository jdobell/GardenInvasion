local GGData = require( "GGData" ) -- Assumes GGData.lua is in root folder
local crypto = require( "crypto" )
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
return file