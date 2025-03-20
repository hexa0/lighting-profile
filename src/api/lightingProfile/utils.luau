--!strict

local utils = {}

local LocalizationService = game:GetService("LocalizationService")

local classes = require(script.Parent.classes)
local localizedStrings = require(script.Parent.localizedStrings)

--[[
	check if we're running as a plugin.
	this gets monkey patched to return true when ran in the plugin,
	for your own plugins (if for whatever reason you need to use the API in a plugin which i'm unsure of a usecase for) you'll need to monkey patch this API too so you can create undo and redo states
]]
function utils.isPlugin(): boolean
	return false
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
	calls :Destroy() on an instance,
	however if we're a plugin we instead parent it to nil to allow undoing.
]]
function utils.DestroyInstance(instance: Instance)
	if utils.isPlugin() then
		instance.Parent = nil
	else
		instance:Destroy()
	end
end

--[[
	makes an instance and assignes the specified properties and parents it to the specified parent.
]]
function utils.MakeInstance(instanceType: string, properties: {[string]: any}, parent: Instance?)
	local instance = Instance.new(instanceType)

	for key, value in properties do
		if instance[key] ~= value then
			instance[key] = value
		end
	end

	instance.Parent = parent

	return instance
end

--[[
	reads all properties from an instance if it is documented in classes.json to a table
]]
function utils.ReadInstance(instance: any)
	local read = {}

	for _, key in classes[instance.ClassName] do
		read[key] = instance[key]
	end

	read.ClassName = instance.ClassName

	return read
end

--[[
	Get a localized string from the lighting profile strings,
	you shouldn't need to call this.
]]
function utils.GetString(key: string): string
	return utils.SafeAssert(
		localizedStrings[key][LocalizationService.RobloxLocaleId] or localizedStrings[key]["en-us"],
		`string {key} doesn't exist.`
	)
end

return utils