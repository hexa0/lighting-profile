--!strict

local utils = {}

local src = script.Parent.Parent

local LocalizationService = game:GetService("LocalizationService")


local localizedPluginStrings = require(src.plugin.localizedPluginStrings)

function utils.MakeButton(toolbar: PluginToolbar, name: string, uuid: string): PluginToolbarButton
	local button = toolbar:CreateButton(
		uuid,
		utils.GetString(`{name}.description`),
		utils.GetString(`{name}.icon`),
		utils.GetString(`{name}.title`)
	)

	button.ClickableWhenViewportHidden = true

	return button
end

--[[
	passes only if <value: T>, if not we throw <errorMessage: string?>,
	as an alternative to the real ` we only will ever return the passed check variable when passing,
	not a tuple with the error message because that makes the function useless in many usecases and is incredibly stupid,
	maybe one day it'll get reverted and the 1 person relying on it will like explode thx
]]
function utils.SafeAssert<T>(value: T, errorMessage: string?): T
	assert(value, errorMessage)
	return value
end

--[[
	Get a localized string from the lighting profile plugin strings,
	you shouldn't need to call this.
]]
function utils.GetString(key: string): string
	return utils.SafeAssert(
		localizedPluginStrings[key][LocalizationService.SystemLocaleId] or localizedPluginStrings[key]["en-us"],
		`string {key} doesn't exist.`
	)
end

return utils