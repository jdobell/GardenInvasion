local configuration = {
-- Set up some defaults...
--touchSlow, touchFast are for harvesting level touch events
touchSlow = 200,
touchFast = 100,
isApple = false,
isAndroid = false,
isGoogle = false,
isKindleFire = false,
isNook = false,
isIPad = false,
isTall = false,
isSimulator = false,
font = native.systemFont,
boldFont = native.systemFontBold,
levelDataFile = "garden_invasion_levels",
globalDataFile = "garden_invasion_globals",
--for testing purposed only -- change the world that is accessible by increasing number
minWorldAccessible = 0,
maxLives = 3,
timeBetweenLives = 180, -- in seconds
animalHitSpeed = 1000,
catStreak = 2,
deerStreak = 3,
eagleStreak = 15,
}

local localization = require( "mod_localize" )
local _string = localization.str

function setLocale()
    localization:setLocale(system.getPreference("locale", "identifier"))    
end

local  localeSet = pcall(setLocale, 'Language Not Available')

if (localeSet == false) then
    localization:setLocale( 'en_US' )
end

function configuration._s(string, ...)
	return _string(string, ...)
end

function print_r ( t )  
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end

local model = system.getInfo("model")

-- Are we on the Simulator?
if ( "simulator" == system.getInfo("environment") ) then
    configuration.isSimulator = true
end

if ( (display.pixelHeight/display.pixelWidth) > 1.5 ) then
   configuration.isTall = true
end

-- Now identify the Apple family of devices:
if ( string.sub( model, 1, 2 ) == "iP" ) then 
   -- We are an iOS device of some sort
   configuration.isApple = true

   if ( string.sub( model, 1, 4 ) == "iPad" ) then
      configuration.is_iPad = true
   end

else

	   -- Not Apple, so it must be one of the Android devices
   configuration.isAndroid = true

   -- Let's assume we are on Google Play for the moment
   configuration.isGoogle = true

   -- All of the Kindles start with "K", although Corona builds before #976 returned
   -- "WFJWI" instead of "KFJWI" (this is now fixed, and our clause handles it regardless)
   if ( model == "Kindle Fire" or model == "WFJWI" or string.sub( model, 1, 2 ) == "KF" ) then
      configuration.isKindleFire = true
      configuration.isGoogle = false  --revert Google Play to false
   end

   -- Are we on a Nook?
   if ( string.sub( model, 1 ,4 ) == "Nook" or string.sub( model, 1, 4 ) == "BNRV" ) then
      configuration.isNook = true
      configuration.isGoogle = false  --revert Google Play to false
   end

end

return configuration