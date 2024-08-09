local TranslationHelper = {}

-- Roblox services
local LocalizationService = game:GetService("LocalizationService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local Resources = require(game.ReplicatedStorage.Resources)
local Janitor = Resources:LoadLibrary("Janitor")

local LabelJan = Janitor.new() 

-- Local variables
local player = Players.LocalPlayer
local sourceLocale = "en"

-- Get translators
local playerTranslator, fallbackTranslator
local foundPlayerTranslator = pcall(function()
	playerTranslator = LocalizationService:GetTranslatorForPlayerAsync(player)
end)
local foundFallbackTranslator = pcall(function()
	fallbackTranslator = LocalizationService.GameLocalization:GetTranslator(sourceLocale)
end)

TranslationHelper.setSourceLocale = function(locale)
	if sourceLocale ~= locale then
		foundFallbackTranslator = pcall(function()
			fallbackTranslator = LocalizationService:GetTranslatorForLocaleAsync(sourceLocale)
			sourceLocale = locale
			return true
		end)	
	end
	return false
end

-- Translate function
TranslationHelper.translate = function(text, object)
	if not object then
		object = game
	end
	local translation = ""
	local foundTranslation = false
	if foundPlayerTranslator then
		return playerTranslator:Translate(object, text)
	end
	if foundFallbackTranslator then
		return fallbackTranslator:Translate(object, text)
	end
	return false
end

-- Translate by key function 
TranslationHelper.translateByKey = function(key, arguments)
	local translation = ""
	local foundTranslation = false

	-- First tries to translate for the player's language (if a translator was found)
	if foundPlayerTranslator then
		foundTranslation = pcall(function()
			translation = playerTranslator:FormatByKey(key, arguments)
		end)
	end
	if foundFallbackTranslator and not foundTranslation then
		foundTranslation = pcall(function()
			translation = fallbackTranslator:FormatByKey(key, arguments)
		end)
	end
	if foundTranslation then
		return translation
	else
		return false
	end
end

TranslationHelper.translateGameString = function(category, key, arguments)
	local translation = ""
	local foundTranslation = false

	-- First tries to translate for the player's language (if a translator was found)
	if foundPlayerTranslator then
		foundTranslation = pcall(function()
			translation = playerTranslator:FormatByKey(category.."_"..key, arguments)
		end)
	end
	if foundFallbackTranslator and not foundTranslation then
		foundTranslation = pcall(function()
			translation = fallbackTranslator:FormatByKey(category.."_"..key, arguments)
		end)
	end
	if foundTranslation then
		return translation
	else
		return false
	end
end

TranslationHelper.translateLabelTemplate = function(category, key, arguments)
	local translation = ""
	local foundTranslation = false

	-- First tries to translate for the player's language (if a translator was found)
	if foundPlayerTranslator or (foundFallbackTranslator and (not foundTranslation)) then
		foundTranslation = pcall(function()
			translation = TranslationHelper.translateGameString("TemplateLabel" ,category.."_"..key, arguments)
		end)
	end

	if foundTranslation then
		return translation
	else
		return false
	end
end

TranslationHelper.setupLabels = function()
	for _, item in CollectionService:GetTagged("TempLabel") do
		if item:IsA("GuiObject") then
			local val = item:GetAttribute("UIValue")
			if val then
				item.Text = TranslationHelper.translateLabelTemplate("UI", item:GetAttribute("LabelName"), {
					UIValue = val;
				})  
			end

			LabelJan:Add(item:GetAttributeChangedSignal("UIValue"):Connect(function()
				val = item:GetAttribute("UIValue")
				if val then
					item.Text = TranslationHelper.translateLabelTemplate("UI", item:GetAttribute("LabelName"), {
						UIValue = val;
					})  
				end
			end))
		end
	end
end

TranslationHelper.getTerm = function(term)
	return TranslationHelper.translateGameString("LabelTerm", term)
end

return TranslationHelper