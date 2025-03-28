local Selection = game:GetService("Selection")
local ChangeHistoryService = game:GetService("ChangeHistoryService")

local src = script.Parent.Parent

local LightingProfile = require(src.api.lightingProfile)
local Utils = require(src.plugin.utils)

local buttons = require(src.plugin.buttons)

buttons.createProfileButton.Click:Connect(function()
	ChangeHistoryService:SetWaypoint(Utils.GetString("plugin.history.new-profile"))

	buttons.createProfileButton:SetActive(false)

	local currentUTCTime: number = os.time(os.date("!*t"))
	local currentFormattedUTCTime = os.date("%x %I:%M:%S %p", currentUTCTime):upper()

	local newProfileObj: Configuration = LightingProfile:CreateProfileInstanceFromCurrentLighting()
	newProfileObj:SetAttribute("Created_UTC_Int", currentUTCTime)
	newProfileObj:SetAttribute("Created_UTC_Formatted", currentFormattedUTCTime)
	newProfileObj.Name = Utils.GetString("plugin.naming.new-profile-default-name"):format(currentFormattedUTCTime)
	newProfileObj.Parent = Selection:Get()[1] or workspace
	Selection:Set{newProfileObj}

	ChangeHistoryService:SetWaypoint(Utils.GetString("plugin.history.new-profile-success"))
end)

buttons.applyProfileButton.Click:Connect(function()
	ChangeHistoryService:SetWaypoint(Utils.GetString("plugin.history.apply-profile"))

	buttons.applyProfileButton:SetActive(false) -- doesn't work sadly

	local oldSelection = Selection:Get()

	local profileObj: Instance = Selection:Get()[1]

	if profileObj and profileObj:IsA("Configuration") then
		LightingProfile:ApplyProfile(profileObj)
	else
		warn(Utils.GetString("plugin.warn.no-selection"))
		return
	end

	ChangeHistoryService:SetWaypoint(Utils.GetString("plugin.history.applied-profile"))

	Selection:Set{}
	Selection:Set(oldSelection)
end)

buttons.getApiButton.Click:Connect(function()
	ChangeHistoryService:SetWaypoint(Utils.GetString("plugin.history.get-api"))

	buttons.getApiButton:SetActive(false)

	local APIClone = LightingProfile.INSTANCE:Clone()
	APIClone.Parent = Selection:Get()[1] or workspace
	Selection:Set{APIClone}

	ChangeHistoryService:SetWaypoint(Utils.GetString("plugin.history.got-api"))
end)

buttons.overwriteButton.Click:Connect(function()
	ChangeHistoryService:SetWaypoint(Utils.GetString("plugin.history.overwriting-profile"))

	buttons.overwriteButton:SetActive(false)

	local currentProfile: Instance = Selection:Get()[1]

	if currentProfile and currentProfile:IsA("Configuration") then
		local currentUTCTime: number = os.time(os.date("!*t"))
		local currentFormattedUTCTime = os.date("%x %I:%M:%S %p", currentUTCTime):upper()

		local modifiedProfileObj: Configuration = LightingProfile:CreateProfileInstanceFromCurrentLighting()

		modifiedProfileObj:SetAttribute("Created_UTC_Int", currentProfile:GetAttribute("Created_UTC_Int"))
		modifiedProfileObj:SetAttribute("Modified_UTC_Int", currentUTCTime)
		modifiedProfileObj:SetAttribute("Created_UTC_Formatted", currentProfile:GetAttribute("Created_UTC_Formatted"))
		modifiedProfileObj:SetAttribute("Modified_UTC_Formatted", currentFormattedUTCTime)

		modifiedProfileObj.Name = currentProfile.Name
		modifiedProfileObj.Parent = currentProfile.Parent
		currentProfile.Parent = nil

		Selection:Set{modifiedProfileObj}
	else
		warn(Utils.GetString("plugin.warn.no-selection"))
	end

	ChangeHistoryService:SetWaypoint(Utils.GetString("plugin.history.overwrote-profile"))
end)

return buttons