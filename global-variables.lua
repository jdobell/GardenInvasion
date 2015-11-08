local configuration = {
font = native.systemFont,
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

return configuration