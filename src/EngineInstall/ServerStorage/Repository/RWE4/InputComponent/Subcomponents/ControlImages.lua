return function(API, InputComponent)

	function InputComponent:getPlatformSheet(index, preferredStyle, preferredPlatform)
		local function findSheet()
			local preferredSheet = API.Resources:LoadSpritesheet((preferredPlatform or "Keyboard")..preferredStyle)
			if preferredSheet and preferredSheet:HasSprite(tostring(typeof(index) == "EnumItem" and index.Name or  index)) then
				return preferredSheet
			end

			-- otherwise search (yes, we double hit a sheet)
			for _, sheet in pairs(API.Resources:AllLoadedSpritesheets()) do
				if sheet:HasSprite(tostring(typeof(index) == "EnumItem" and index.Name or  index)) then
					return sheet
				end
			end
		end

		local preferredSheet = findSheet()
		if preferredSheet then
			return preferredSheet
		end

		warn("[XAdapt InputComponent] - Unable to find sprite for", tostring(typeof(index) == "EnumItem" and index.Name or  index), "type", typeof(index))

		return nil
	end

	local function _getImageInstance(instanceType, index, preferredStyle, preferredPlatform)
		local sheet = InputComponent:getPlatformSheet(tostring(typeof(index) == "EnumItem" and index.Name or  index), preferredStyle, preferredPlatform)
		if sheet then
			local image =  sheet:GetSprite(index):Get(instanceType,UDim2.new(1,0,1,0))
			image.Parent = game.Players.LocalPlayer.PlayerGui:WaitForChild("GameMenu",20)
			image.Visible = false
			return image
		end

		return nil
	end

	local function _styleImageInstance(image, index, preferredStyle, preferredPlatform)
		local sheet = InputComponent:getPlatformSheet(tostring(typeof(index) == "EnumItem" and index.Name or  index), preferredStyle, preferredPlatform)
		if sheet then
			sheet:GetSprite(index):Style(image)
			return true
		end
		return false
	end

	function InputComponent:GetScaledImageLabel(keyCode, preferredStyle, preferredPlatform)
		local kc = if typeof(keyCode) == "EnumItem" then keyCode.Name else tostring(keyCode)
		if API.UIS:GamepadSupports(InputComponent.GetActiveGamepad(), keyCode) then
			kc = API.UIS:GetStringForKeyCode(keyCode)
		end
		local image = _getImageInstance("ImageLabel", kc, preferredStyle or "Dark", preferredPlatform)
		if not image then
			return nil
		end

		local size = image.AbsoluteSize
		local imageRatio = {image.ImageRectSize.X,image.ImageRectSize.Y}
		local ratio = imageRatio[1] > imageRatio[2] and  imageRatio[1]/imageRatio[2]  or imageRatio[2]/imageRatio[1] 
		if imageRatio[1] ~= imageRatio[2] then
			local uiAspectRatio = Instance.new("UIAspectRatioConstraint")
			uiAspectRatio.DominantAxis =  imageRatio[1] > imageRatio[2] and Enum.DominantAxis.Width or  Enum.DominantAxis.Height
			uiAspectRatio.AspectRatio = ratio
			uiAspectRatio.Parent = image
		else
			local uiAspectRatio = Instance.new("UIAspectRatioConstraint")
			uiAspectRatio.DominantAxis = Enum.DominantAxis.Height
			uiAspectRatio.AspectRatio = 1
			uiAspectRatio.Parent = image
		end
		image.Size = UDim2.new(1, 0, 1, 0)
		image.ScaleType = "Crop"
		image.Visible = true
		return image
	end

	function InputComponent:GetScaledImageButton(keyCode, preferredStyle, preferredPlatform)
		local kc = if typeof(keyCode) == "EnumItem" then keyCode.Name else tostring(keyCode)
		if API.UIS:GamepadSupports(InputComponent.GetActiveGamepad(), keyCode) then
			kc = API.UIS:GetStringForKeyCode(keyCode)
		end
		local image = _getImageInstance("ImageButton", kc, preferredStyle or "Dark", preferredPlatform)
		if not image then
			return nil
		end

		local size = image.AbsoluteSize
		local imageRatio = {image.ImageRectSize.X,image.ImageRectSize.Y}
		local ratio = imageRatio[1] > imageRatio[2] and  imageRatio[1]/imageRatio[2]  or imageRatio[2]/imageRatio[1] 
		if imageRatio[1] ~= imageRatio[2] then
			local uiAspectRatio = Instance.new("UIAspectRatioConstraint")
			uiAspectRatio.DominantAxis =  imageRatio[1] > imageRatio[2] and Enum.DominantAxis.Width or  Enum.DominantAxis.Height
			uiAspectRatio.AspectRatio = ratio
			uiAspectRatio.Parent = image
		else
			local uiAspectRatio = Instance.new("UIAspectRatioConstraint")
			uiAspectRatio.DominantAxis = Enum.DominantAxis.Height
			uiAspectRatio.AspectRatio = 1
			uiAspectRatio.Parent = image
		end

		image.Size = UDim2.new(1, 0, 1, 0)
		image.ScaleType = "Crop"
		return image
	end

	function InputComponent.StyleControlImage(image, keyCode, preferredStyle, preferredPlatform)
		local kc = if typeof(keyCode) == "EnumItem" then keyCode.Name else tostring(keyCode)
		if API.UIS:GamepadSupports(InputComponent.GetActiveGamepad(), keyCode) then
			kc = API.UIS:GetStringForKeyCode(keyCode)
		end
		local imageReady = _styleImageInstance(image, kc, preferredStyle or "Dark", preferredPlatform)
		if not imageReady then
			return 
		end

		local size = image.AbsoluteSize
		local imageRatio = {image.ImageRectSize.X,image.ImageRectSize.Y}
		local ratio = imageRatio[1] > imageRatio[2] and  imageRatio[1]/imageRatio[2]  or imageRatio[2]/imageRatio[1] 
		if imageRatio[1] ~= imageRatio[2] then
			local uiAspectRatio = Instance.new("UIAspectRatioConstraint")
			uiAspectRatio.DominantAxis =  imageRatio[1] > imageRatio[2] and Enum.DominantAxis.Width or  Enum.DominantAxis.Height
			uiAspectRatio.AspectRatio = ratio
			uiAspectRatio.Parent = image
		else
			local uiAspectRatio = Instance.new("UIAspectRatioConstraint")
			uiAspectRatio.DominantAxis = Enum.DominantAxis.Height
			uiAspectRatio.AspectRatio = 1
			uiAspectRatio.Parent = image
		end

	end
	function InputComponent.getDimensions(keyCode,theme,platform)
		local kc = if typeof(keyCode) == "EnumItem" then keyCode.Name else tostring(keyCode)
		if API.UIS:GamepadSupports(InputComponent.GetActiveGamepad(), keyCode) then
			kc = API.UIS:GetStringForKeyCode(keyCode)
		end
		local image = _getImageInstance("ImageLabel", kc, theme or "Light", platform or "XboxOne")
		return image.Image,image.ImageRectSize,image.ImageRectOffset
	end
	function InputComponent.getSelectorDimensions(theme, platform)
		local image = _getImageInstance("ImageLabel","ButtonA",theme or "Light",platform or "XboxOne")
		return image.Image,image.ImageRectSize,image.ImageRectOffset
	end
	
	return {
		Name = "ControlImages";
		SubComp = true
	}	
end
