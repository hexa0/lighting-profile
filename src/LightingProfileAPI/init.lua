--!nocheck
-- silence nonsense LSP errors in studio ^

local Lighting = game:GetService("Lighting")
local Terrain = workspace:FindFirstChildOfClass("Terrain")
local LocalizationService = game:GetService("LocalizationService")

local LightingProfileHandler = {}
LightingProfileHandler._CLASSES = require(script.classes)
LightingProfileHandler._LANG = require(script.lang)
LightingProfileHandler._IS_PLUGIN = false

local types = require(script.types)

export type ProfileData = types.ProfileData

function LightingProfileHandler:_GetLocalizedString(key: string): string
	return self._LANG[key][LocalizationService.RobloxLocaleId] or self._LANG[key]["en-us"]
end

function LightingProfileHandler:DecodeProfileDataFromInstance(profileObj: Configuration | ProfileData): ProfileData
	if typeof(profileObj) == "table" then
		return profileObj
	elseif typeof(profileObj) == "Instance" then
		local profile = table.clone(profileObj:GetAttributes())

		for key, value in pairs(profileObj:GetAttributes()) do
			profile[key] = value
		end
	
		for _, child in pairs(profileObj:GetChildren()) do
			profile[child.Name] = self:DecodeProfileDataFromInstance(child)
		end
	
		return profile :: ProfileData
	else
		error("decode failed")
	end
end

function LightingProfileHandler:EncodeProfileDataAsInstance(profile: ProfileData)
	local profileObj: Configuration = Instance.new("Configuration")
	profileObj.Name = "index"

	for key, value in pairs(profile) do
		if typeof(value) == "table" then
			local childProfileObj: Configuration = self:EncodeProfileDataAsInstance(value)
			childProfileObj.Parent = profileObj
			childProfileObj.Name = key
		else
			profileObj:SetAttribute(key, value)
		end
	end

	return profileObj
end

function LightingProfileHandler:ApplyProfile(profile: Configuration | ProfileData)
	-- Cleanup old lighting stuff
	for _, child: Instance in pairs(Lighting:GetChildren()) do
		if (child:IsA("PostEffect") or child:IsA("Sky") or child:IsA("Atmosphere")) and child.Archivable then
			if self._IS_PLUGIN then
				-- hacky fix for this https://github.com/NightrainsRbx/RobloxLsp/issues/153 why is this still not patched wtf
				(child :: any).Parent = nil
			else
				child:Destroy()
			end
		end
	end

	local clouds: Clouds? = Terrain:FindFirstChildOfClass("Clouds")

	if clouds and clouds.Archivable then
		if self._IS_PLUGIN then
			(clouds :: any).Parent = nil
		else
			clouds:Destroy()
		end
	end

	-- Decode the profile

	local decoded = self:DecodeProfileDataFromInstance(profile) :: ProfileData

	-- Apply the profile

	for key: string, value in pairs(decoded.Lighting) do
		Lighting[key] = value
	end

	for _, postEffect in pairs(decoded.PostEffects) do
		local postInstance = Instance.new(postEffect.ClassName, Lighting)

		for key: string, value in pairs(postEffect) do
			if key ~= "ClassName" then
				postInstance[key] = value
			end
		end
	end

	if decoded.Sky then
		local skyInstance = Instance.new("Sky", Lighting)

		for key: string, value in pairs(decoded.Sky) do
			skyInstance[key] = value
		end
	end

	if decoded.Atmosphere then
		local atmosphereInstance = Instance.new("Atmosphere",Lighting)

		for key: string, value in pairs(decoded.Atmosphere) do
			atmosphereInstance[key] = value
		end
	end

	if decoded.Clouds then
		local cloudsIntance = Instance.new("Clouds",Terrain)
		
		for key: string, value in pairs(decoded.Clouds) do
			cloudsIntance[key] = value
		end
	end
end

function LightingProfileHandler:CreateProfileDataFromCurrentLighting(): ProfileData
	local profile = {}

	-- Store lighting settings

	profile.Lighting = {}

	for _, key in pairs(self._CLASSES.Lighting) do
		profile.Lighting[key] = Lighting[key]
	end

	-- Store post effects

	profile.PostEffects = {}

	for _, child in pairs(Lighting:GetChildren()) do
		if child:IsA("PostEffect") and child.Archivable then
			-- Fail-safe incase it's a new PostEffect class
			if not self._CLASSES[child.ClassName] then
				warn(self:_GetLocalizedString("api-warn-unknown-class-prop"):format(child.ClassName))
			else
				local name: string = child.Name

				if profile.PostEffects[child.Name] then
					name ..= self:_GetLocalizedString("duplicated-name-append") :: string
					warn(self:_GetLocalizedString("api-warn-duplicated-name"):format(child:GetFullName(),name))
				end

				profile.PostEffects[name] = {}

				for _, key in pairs(self._CLASSES[child.ClassName]) do
					profile.PostEffects[name][key] = child[key]
				end

				profile.PostEffects[name]["ClassName"] = child.ClassName
			end
		end
	end

	-- Store Skybox

	local sky: Sky =  Lighting:FindFirstChildOfClass("Sky")

	if sky then
		profile.Sky = {}

		for _, key in pairs(self._CLASSES["Sky"]) do
			profile.Sky[key] = sky[key]
		end
	end

	-- Store Atmosphere

	local atmosphere: Atmosphere =  Lighting:FindFirstChildOfClass("Atmosphere")

	if atmosphere then
		profile.Atmosphere = {}

		for _, key in pairs(self._CLASSES["Atmosphere"]) do
			profile.Atmosphere[key] = atmosphere[key]
		end
	end

	-- Store Clouds

	local clouds: Clouds =  Terrain:FindFirstChildOfClass("Clouds")

	if clouds then
		profile.Clouds = {}

		for _, key in pairs(self._CLASSES["Clouds"]) do
			profile.Clouds[key] = clouds[key]
		end
	end

	return profile
end

function LightingProfileHandler:CreateProfile(): Configuration
	warn(self:_GetLocalizedString("api-warn-deprecated"):format("CreateProfile", "", "CreateProfileInstanceFromCurrentLighting", ""))
	return self:CreateProfileInstanceFromCurrentLighting()
end

function LightingProfileHandler:CreateProfileInstanceFromCurrentLighting(): Configuration
	return self:EncodeProfileDataAsInstance(self:CreateProfileDataFromCurrentLighting())
end

return LightingProfileHandler