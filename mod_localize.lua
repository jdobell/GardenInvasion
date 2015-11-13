----------------------------------------------------------
-- mod_localize
----------------------------------------------------------

---Localization Module
-- This module aids in simple localization
-- for your CoronaSDK apps and games
-- @author Chris Byerley
-- @copyright 2014 develephant.com
-- @license MIT
-- @module mod_localize
local _M = {}

_M.locale = 'en_US'
_M.langTbl = {}
---Sets the locale for localization.
-- See: http://framework.zend.com/manual/1.12/en/zend.locale.appendix.html
-- @string locale Set the locale for translation
-- @usage
-- local localize = require( "mod_localize" )
-- localize:setLocale( "es_ES" )
-- --Change locale later
-- localize:setLocale( "en_US" )
function _M:setLocale( locale )
	self.locale = locale

	--clear tbl to be sure
	self.langTbl = {}

	--load lang file
	--fix by Misael M.
	local langFilePath = system.pathForFile( "lang/" .. self.locale .. ".txt", system.ResourceDirectory )

	--loop over translated lines, build lang tbl
	local pattern = "(.+)%s*=%s*(.+)"
	for line in io.lines( langFilePath ) do
		for k, v in string.gmatch( line, pattern ) do
			self.langTbl[ string.trim( k ) ] = string.trim( v )
		end
	end
end
---Translates the string.
-- If you provide arguments then the method acts like
-- __string.format__, with token replacement.
-- @string strKey The string key to translate
-- @tparam args ... The extra arguments
-- @treturn string The translated string key
-- @usage 
-- local localize = require( "mod_localize" )
-- local _s = localize.str --place in shortcut var
--
-- localize:setLocale( "es_ES" )
-- 
-- print( _s( "I like muffins" ) )
-- > Me gustan los molletes
function _M.str( strKey, ... )

	local langTbl = _M.langTbl

	local str = langTbl[ strKey ]
	if str then
		if ... then
			return string.format( str, ... )
		else
			return str
		end
	end

	error( "Localization string not found!  Please add \"" .. strKey .. "\" to lang/" .. _M.locale .. ".txt" )
end
---Trims white space on both sides.
-- @local
function string.trim(self)
   return self:match('^%s*(.-)%s*$')
end

return _M
