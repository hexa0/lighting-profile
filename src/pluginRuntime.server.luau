--[[
	written by hexa0
	https://github.com/hexa0/lighting-profile/
]]

local major, minor, patch = 0,0,0

require(script.Parent.plugin).pluginObject = plugin
require(script.Parent.plugin).CURRENT_VERSION = {
	major = major;
	minor = minor;
	patch = patch;
	string = `{major}.{minor}.{patch}`;
}
require(script.Parent.plugin.setup)