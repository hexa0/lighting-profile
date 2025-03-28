--!strict

export type VersionData = {
	major: number;
	minor: number;
	patch: number;
	string: string;
}

export type PluginGlobals = {
	pluginObject: Plugin;
	CURRENT_VERSION: VersionData;
}

local pluginGlobals: PluginGlobals = {
	pluginObject = nil
} :: any

return pluginGlobals