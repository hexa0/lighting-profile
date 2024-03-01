local Selection: Selection = game:GetService("Selection")
local ChangeHistoryService: ChangeHistoryService = game:GetService("ChangeHistoryService")

local VERSION = "1.1.1"

local API = require(script.Parent.LightingProfileAPI)
API._IS_PLUGIN = true

if not plugin then
	plugin = getfenv().PluginManager():CreatePlugin()
end

local toolbar: PluginToolbar = plugin:CreateToolbar(API:_GetLocalizedString("plugin-toolbar"):format(VERSION))

local createProfileButton: PluginToolbarButton = toolbar:CreateButton(
    "new-lighting-profile-52a6dd5f-76f2-461e-84ea-5f1c2f8427af", -- buttonId
    API:_GetLocalizedString("plugin-button-create-profile-desc"), -- tooltip
    API:_GetLocalizedString("plugin-button-create-profile-icon"), -- icon
    API:_GetLocalizedString("plugin-button-create-profile") -- text
)
createProfileButton.ClickableWhenViewportHidden = true

local applyProfileButton: PluginToolbarButton = toolbar:CreateButton(
    "apply-lighting-profile-82aa2c36-b99e-4c71-a0ff-368a6df674c5", -- buttonId
    API:_GetLocalizedString("plugin-button-apply-profile-desc"), -- tooltip
    API:_GetLocalizedString("plugin-button-apply-profile-icon"), -- icon
    API:_GetLocalizedString("plugin-button-apply-profile") -- text
)
applyProfileButton.ClickableWhenViewportHidden = true

local overwriteButton: PluginToolbarButton = toolbar:CreateButton(
    "overwrite-profile-77c76841-3c26-43c2-b095-64241c74d774", -- buttonId
    API:_GetLocalizedString("plugin-button-overwrite-profile-desc"), -- tooltip
    API:_GetLocalizedString("plugin-button-overwrite-profile-icon"), -- icon
    API:_GetLocalizedString("plugin-button-overwrite-profile") -- text
)
overwriteButton.ClickableWhenViewportHidden = true

local getApiButton: PluginToolbarButton = toolbar:CreateButton(
    "get-api-1584eeb8-e65c-4c1f-8a07-753d4447d922", -- buttonId
    API:_GetLocalizedString("plugin-button-get-api-desc"), -- tooltip
    API:_GetLocalizedString("plugin-button-get-api-icon"), -- icon
    API:_GetLocalizedString("plugin-button-get-api") -- text
)
getApiButton.ClickableWhenViewportHidden = true

createProfileButton.Click:Connect(function()
    ChangeHistoryService:SetWaypoint(API:_GetLocalizedString("plugin-history-new-profile"))

    createProfileButton:SetActive(false)

    local currentUTCTime: number = os.time(os.date("!*t"))
    local currentFormattedUTCTime = os.date("%x %I:%M:%S %p", currentUTCTime):upper()

    local newProfileObj: Configuration = API:CreateProfileInstanceFromCurrentLighting()
    newProfileObj:SetAttribute("Created_UTC_Int", currentUTCTime)
    newProfileObj:SetAttribute("Created_UTC_Formatted", currentFormattedUTCTime)
    newProfileObj.Name = API:_GetLocalizedString("plugin-new-profile-default-name"):format(currentFormattedUTCTime)
    newProfileObj.Parent = Selection:Get()[1] or workspace
    Selection:Set{newProfileObj}

    ChangeHistoryService:SetWaypoint(API:_GetLocalizedString("plugin-history-new-profile-success"))
end)

applyProfileButton.Click:Connect(function()
    ChangeHistoryService:SetWaypoint(API:_GetLocalizedString("plugin-history-apply-profile"))
    
    applyProfileButton:SetActive(false)

    local profileObj: Configuration? = Selection:Get()[1]

    if not profileObj then
        warn(API:_GetLocalizedString("plugin-warn-no-selection"))
        return
    else
        API:ApplyProfile(profileObj)
    end

    ChangeHistoryService:SetWaypoint(API:_GetLocalizedString("plugin-history-applied-profile"))
end)

getApiButton.Click:Connect(function()
    ChangeHistoryService:SetWaypoint(API:_GetLocalizedString("plugin-history-get-api"))
    
    getApiButton:SetActive(false)

    local APIClone = script.Parent.LightingProfileAPI:Clone()
    APIClone.Parent = Selection:Get()[1] or workspace
    Selection:Set{APIClone}

    ChangeHistoryService:SetWaypoint(API:_GetLocalizedString("plugin-history-got-api"))
end)

overwriteButton.Click:Connect(function()
    ChangeHistoryService:SetWaypoint(API:_GetLocalizedString("plugin-history-overwriting-profile"))
    
    overwriteButton:SetActive(false)

    local currentProfile: Configuration? = Selection:Get()[1]

	if currentProfile then
		local currentUTCTime: number = os.time(os.date("!*t"))
		local currentFormattedUTCTime = os.date("%x %I:%M:%S %p", currentUTCTime):upper()
	
		local modifiedProfileObj: Configuration = API:CreateProfileInstanceFromCurrentLighting()
		
		modifiedProfileObj:SetAttribute("Created_UTC_Int", currentProfile:GetAttribute("Created_UTC_Int"))
		modifiedProfileObj:SetAttribute("Modified_UTC_Int", currentUTCTime)
		modifiedProfileObj:SetAttribute("Created_UTC_Formatted", currentProfile:GetAttribute("Created_UTC_Formatted"))
		modifiedProfileObj:SetAttribute("Modified_UTC_Formatted", currentFormattedUTCTime)

		modifiedProfileObj.Name = currentProfile.Name
		modifiedProfileObj.Parent = currentProfile.Parent
		currentProfile.Parent = nil :: Instance

		Selection:Set{modifiedProfileObj}
	else
		warn(API:_GetLocalizedString("plugin-warn-no-selection"))
	end

    ChangeHistoryService:SetWaypoint(API:_GetLocalizedString("plugin-history-overwrote-profile"))
end)