--!nocheck

--[[
	api written by hexa0
	https://github.com/hexa0/lighting-profile
]]

local Lighting = game:GetService("Lighting")
local Terrain = workspace:FindFirstChildOfClass("Terrain")

local Utils = require(script.utils)

local classes = require(script.classes)

export type LightingProfilePrivate = {
	-- set as private since this is deprecated
	CreateProfile: (self: LightingProfilePublic) -> Configuration;
	_DecodeAttributeEncodedDataFromInstanceRecursive: (self: LightingProfilePrivate) -> any;
}

export type LightingProfilePublic = {
	INSTANCE: ModuleScript;
	CURRENT_VERSION: VersionData;

	DecodeProfileDataFromInstance: (self: LightingProfilePublic, profileObject: Instance | ProfileData) -> ProfileData;
	EncodeProfileDataAsInstance: (self: LightingProfilePublic, profile: ProfileData) -> Configuration;
	ApplyProfile: (self: LightingProfilePublic, profile: Instance | ProfileData) -> ();
	CreateProfileDataFromCurrentLighting: (self: LightingProfilePublic) -> ProfileData;
	CreateProfileInstanceFromCurrentLighting: (self: LightingProfilePublic) -> Configuration;
}

type LightingProfile = LightingProfilePublic & LightingProfilePrivate


local LightingProfile: any = {} :: LightingProfile
LightingProfile.INSTANCE = script

local major, minor, patch = 1,2,1

LightingProfile.CURRENT_VERSION = {
	major = major;
	minor = minor;
	patch = patch;
	string = `{major}.{minor}.{patch}`;
}

export type VersionData = {
	major: number;
	minor: number;
	patch: number;
	string: string;
}

export type ProfileData = {
	Lighting: { [string]: any },
	PostEffects: { [string]: { [string]: any } },

	Sky: { [string]: any }?,
	Atmosphere: { [string]: any }?,
	Clouds: { [string]: any }?,
	Version: VersionData;
}

function LightingProfile:_DecodeAttributeEncodedDataFromInstanceRecursive(instance: Instance): any
	local data = table.clone(instance:GetAttributes())

	for key, value in instance:GetAttributes() do
		data[key] = value
	end

	for _, child in instance:GetChildren() do
		data[child.Name] = self:_DecodeAttributeEncodedDataFromInstanceRecursive(child)
	end

	return data
end

function LightingProfile:DecodeProfileDataFromInstance(profileObject: Instance | ProfileData): ProfileData
	if typeof(profileObject) == "table" then
		return profileObject
	elseif typeof(profileObject) == "Instance" then
		local profile = self:_DecodeAttributeEncodedDataFromInstanceRecursive(profileObject)

		if not profile.Version then
			-- we don't know the version that encoded it, assume it's the last version that didn't store this!
			profile.Version = {
				major = 1;
				minor = 2;
				patch = 0;
				string = "1.2.0";
			}
		end

		return profile
	else
		error("decode failed")
	end
end

function LightingProfile:EncodeProfileDataAsInstance(profile: ProfileData): Configuration
	local profileObject: Configuration = Instance.new("Configuration")
	profileObject.Name = "index"

	for key, value in profile do
		if typeof(value) == "table" then
			local childProfileObject: Configuration = self:EncodeProfileDataAsInstance(value)
			childProfileObject.Parent = profileObject
			childProfileObject.Name = key
		else
			profileObject:SetAttribute(key, value)
		end
	end

	return profileObject
end

--[[
	Applies the provided profile as the current lighting.
]]
function LightingProfile:ApplyProfile(profile: Instance | ProfileData)
	-- Cleanup old lighting stuff
	for _, child: Instance in Lighting:GetChildren() do
		if (child:IsA("PostEffect") or child:IsA("Sky") or child:IsA("Atmosphere")) and child.Archivable then
			Utils.DestroyInstance(child)
		end
	end

	local clouds: Clouds? = Terrain:FindFirstChildOfClass("Clouds")

	if clouds and clouds.Archivable then
		Utils.DestroyInstance(clouds)
	end

	-- Decode the profile

	local decoded = self:DecodeProfileDataFromInstance(profile)

	-- Apply the profile

	for key: string, value in decoded.Lighting do
		Lighting[key] = value
	end

	for _, postEffect in decoded.PostEffects do
		Utils.MakeInstance(postEffect.ClassName, postEffect, Lighting)
	end

	if decoded.Sky then
		Utils.MakeInstance("Sky", decoded.Sky, Lighting)
	end

	if decoded.Atmosphere then
		Utils.MakeInstance("Atmosphere", decoded.Atmosphere, Lighting)
	end

	if decoded.Clouds then
		Utils.MakeInstance("Clouds", decoded.Clouds, Terrain)
	end
end

function LightingProfile:CreateProfileDataFromCurrentLighting(): ProfileData
	local profile = {}

	-- Store lighting settings

	profile.Lighting = {}

	for _, key in classes.Lighting do
		profile.Lighting[key] = Lighting[key]
	end

	-- Store post effects

	profile.PostEffects = {}

	for _, child in Lighting:GetChildren() do
		if child:IsA("PostEffect") and child.Archivable then
			-- Fail-safe incase it's a new PostEffect class
			if not classes[child.ClassName] then
				warn(Utils.GetString("api.warn.unknown-class-prop"):format(child.ClassName))
			else
				local name: string = child.Name

				if profile.PostEffects[child.Name] then
					repeat
						name ..= Utils.GetString("api.naming.duplicated-name-append") :: string
					until not profile.PostEffects[name]

					-- no-longer needed since the original name is stored in the properties
					-- warn(Utils.GetString("api.warn.duplicated-name"):gsub("ORIGINAL_NAME", child:GetFullName()):gsub("UNIQUE_NAME", name))
				end

				profile.PostEffects[name] = Utils.ReadInstance(child)
			end
		end
	end

	-- Store Skybox

	local sky: Sky = Lighting:FindFirstChildOfClass("Sky")
	profile.Sky = sky and Utils.ReadInstance(sky)

	-- Store Atmosphere

	local atmosphere: Atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	profile.Atmosphere = atmosphere and Utils.ReadInstance(atmosphere)

	-- Store Clouds

	local clouds: Clouds = Terrain:FindFirstChildOfClass("Clouds")
	profile.Clouds = clouds and Utils.ReadInstance(clouds)

	-- Store Verison Metadata

	profile.Version = self.CURRENT_VERSION

	return profile
end

function LightingProfile:CreateProfile(): Configuration
	warn(
		Utils.GetString("api.warn.deprecated")
			:format("CreateProfile", "", "CreateProfileInstanceFromCurrentLighting", "")
	)
	return self:CreateProfileInstanceFromCurrentLighting()
end

function LightingProfile:CreateProfileInstanceFromCurrentLighting(): Configuration
	return self:EncodeProfileDataAsInstance(self:CreateProfileDataFromCurrentLighting())
end

return LightingProfile :: LightingProfilePublic