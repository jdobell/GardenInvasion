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