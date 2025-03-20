--!strict

local src = script.Parent.Parent

local LightingProfile = require(src.api.lightingProfile)
local LightingProfileUtils = require(src.api.lightingProfile.utils)
local Utils = require(src.plugin.utils)
local Plugin = require(src.plugin)

local toolbar = Plugin.pluginObject:CreateToolbar(
	LightingProfileUtils.GetString("plugin.toolbar")
		:format(LightingProfile.CURRENT_VERSION.string)
)

return {
	createProfileButton = Utils.MakeButton(
		toolbar,
		"plugin.button.create-profile",
		"new-lighting-profile-52a6dd5f-76f2-461e-84ea-5f1c2f8427af"
	);
	applyProfileButton = Utils.MakeButton(
		toolbar,
		"plugin.button.apply-profile",
		"apply-lighting-profile-82aa2c36-b99e-4c71-a0ff-368a6df674c5"
	);
	overwriteButton = Utils.MakeButton(
		toolbar,
		"plugin.button.overwrite-profile",
		"overwrite-profile-77c76841-3c26-43c2-b095-64241c74d774"
	);
	getApiButton = Utils.MakeButton(
		toolbar,
		"plugin.button.get-api",
		"get-api-1584eeb8-e65c-4c1f-8a07-753d4447d922"
	);
}
