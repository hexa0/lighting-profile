local Selection: Selection = game:GetService("Selection")
local ChangeHistoryService: ChangeHistoryService = game:GetService("ChangeHistoryService")

local VERSION = "1.0.0"

local API = require(script.Parent.LightingProfileAPI)
API._IS_PLUGIN = true

if not plugin then plugin = PluginManager():CreatePlugin() end

local toolbar: PluginToolbar = plugin:CreateToolbar(API:_GetLang("plugin-toolbar"):format(VERSION))

local createProfileButton: PluginToolbarButton = toolbar:CreateButton(
    "new-lighting-profile-52a6dd5f-76f2-461e-84ea-5f1c2f8427af", -- buttonId
    API:_GetLang("plugin-button-create-profile-desc"), -- tooltip
    API:_GetLang("plugin-button-create-profile-icon"), -- icon
    API:_GetLang("plugin-button-create-profile") -- text
)
createProfileButton.ClickableWhenViewportHidden = true

createProfileButton.Click:Connect(function()
    ChangeHistoryService:SetWaypoint(API:_GetLang("plugin-history-new-profile"))

    createProfileButton:SetActive(false)

    local currentUTCTime: number = os.time(os.date("!*t"))
    local currentFormattedUTCTime = os.date("%x %I:%M:%S %p", currentUTCTime):upper()

    local newProfileObj: Configuration = API:CreateProfile()
    newProfileObj:SetAttribute("Created_UTC_Int", currentUTCTime)
    newProfileObj:SetAttribute("Created_UTC_Formatted", currentFormattedUTCTime)
    newProfileObj.Name = API:_GetLang("plugin-new-profile-default-name"):format(currentFormattedUTCTime)
    newProfileObj.Parent = Selection:Get()[1] or workspace
    Selection:Set{newProfileObj}

    ChangeHistoryService:SetWaypoint(API:_GetLang("plugin-history-new-profile-success"))
end)

local applyProfileButton: PluginToolbarButton = toolbar:CreateButton(
    "apply-lighting-profile-82aa2c36-b99e-4c71-a0ff-368a6df674c5", -- buttonId
    API:_GetLang("plugin-button-apply-profile-desc"), -- tooltip
    API:_GetLang("plugin-button-apply-profile-icon"), -- icon
    API:_GetLang("plugin-button-apply-profile") -- text
)
applyProfileButton.ClickableWhenViewportHidden = true

applyProfileButton.Click:Connect(function()
    ChangeHistoryService:SetWaypoint(API:_GetLang("plugin-history-apply-profile"))
    
    applyProfileButton:SetActive(false)

    local profileObj: Configuration = Selection:Get()[1]

    if not profileObj then
        warn(API:_GetLang("plugin-warn-apply-profile-no-selection"))
        return
    else
        API:ApplyProfile(profileObj)
    end

    ChangeHistoryService:SetWaypoint(API:_GetLang("plugin-history-applied-profile"))
end)

local getApiButton: PluginToolbarButton = toolbar:CreateButton(
    "get-api-1584eeb8-e65c-4c1f-8a07-753d4447d922", -- buttonId
    API:_GetLang("plugin-button-get-api-desc"), -- tooltip
    API:_GetLang("plugin-button-get-api-icon"), -- icon
    API:_GetLang("plugin-button-get-api") -- text
)
getApiButton.ClickableWhenViewportHidden = true

getApiButton.Click:Connect(function()
    ChangeHistoryService:SetWaypoint(API:_GetLang("plugin-history-get-api"))
    
    getApiButton:SetActive(false)

    local APIClone = script.Parent.LightingProfileAPI:Clone()
    APIClone.Parent = Selection:Get()[1] or workspace
    Selection:Set{APIClone}

    ChangeHistoryService:SetWaypoint(API:_GetLang("plugin-history-got-api"))
end)
