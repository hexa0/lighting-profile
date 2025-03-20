--!strict

local utils = {}

local src = script.Parent.Parent

local LightingProfileUtils = require(src.api.lightingProfile.utils)

function utils.MakeButton(toolbar: PluginToolbar, name: string, uuid: string): PluginToolbarButton
	local button = toolbar:CreateButton(
		uuid,
		LightingProfileUtils.GetString(`{name}.description`),
		LightingProfileUtils.GetString(`{name}.icon`),
		LightingProfileUtils.GetString(`{name}.title`)
	)

	button.ClickableWhenViewportHidden = true

	return button
end

return utils