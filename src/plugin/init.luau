--!strict

export type PluginGlobals = {
	pluginObject: Plugin;
}

local pluginGlobals: PluginGlobals = {
	pluginObject = nil
} :: any

return pluginGlobals