--!strict

local src = script.Parent.Parent
local LightingProfileUtils = require(src.api.lightingProfile.utils)

-- monkey patch this function to always return true when ran from the plugin
-- this is ugly unfortunately
LightingProfileUtils.isPlugin = function()
	return true
end

require(src.plugin.buttonLogic)

return {}