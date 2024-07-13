local InputComponent = {}
local UIS = game:GetService("UserInputService")
local HapticsService = game:GetService("HapticService")
local GuiService = game:GetService("GuiService")
local ContextActionService = game:GetService("ContextActionService")
local VEC2 = Vector2.new
local Resources = require(game.ReplicatedStorage.Resources)
local Signal = Resources:LoadLibrary("Signal")
local Janitor = Resources:LoadLibrary("Janitor")
local Spring = Resources:LoadLibrary("Spring")
local Enumeration = Resources:LoadLibrary("Enumeration")
local PseudoInstance = Resources:LoadLibrary("PseudoInstance")
local RemoteService = Resources:LoadLibrary("RemoteService")
local Lerps = Resources:LoadLibrary("Lerps")
local Tween = Resources:LoadLibrary("Tween")
local fastSpawn = Resources:LoadLibrary("FastSpawn")
local FastWait = Resources:LoadLibrary("FastWait")
local FastDelay = Resources:LoadLibrary("FastDelay")
local RayUtils = Resources:LoadLibrary("RayUtils")
local RAD = math.rad
local ABS = math.abs
local NONE = Enum.UserInputType.None
local RunService = game:GetService("RunService")
local isIgnored = Resources:LoadLibrary("isIgnored")
local Table = Resources:LoadLibrary("Table")
local removeElement = Resources:LoadLibrary("removeElement")
local Typer = Resources:LoadLibrary("Typer")
InputComponent.GamepadButtonChanged = Signal.new()
InputComponent.KeyChanged = Signal.new()
InputComponent.MouseButtonChanged = Signal.new()
InputComponent.KeypadModeChanged = Signal.new()
InputComponent.PlatformChanged  = Signal.new()
InputComponent.DeviceCount = 0;
InputComponent.DeviceSelectors = {};
function InputComponent:AddDeviceSelector(name,eval)
	self.DeviceSelectors[name] = eval;
end;
function InputComponent:EvaluatePlatformCount()
	self.DeviceCount = 0;
	for n, v in pairs(self.DeviceSelectors) do
		local result = v()
		if result then
			self.DeviceCount += 1;
		end 
	end
end
InputComponent.Binds = {};
InputComponent.SelectionSchemes = {}
InputComponent.CurrentSelection = "None";
InputComponent.Platform = "Keyboard";
InputComponent.CurrentInputGroup = "Gen";
InputComponent.MouseIconScheme = "Default";
InputComponent.Deadzone = 0.2;
InputComponent.KeypadNumbers = {
	"KeypadOne";
	"KeypadTwo";
	"KeypadThree";
	"KeypadFour";
	"KeypadFive";
	"KeypadSix";
	"KeypadSeven";
	"KeypadEight";
	"KeypadNine";
};
local inList = Resources:LoadLibrary("inList")

local keysActive = false
InputComponent.Pressed = setmetatable({
	inputCache = {};	
}, {
	__index = function(self,k)
		if typeof(k) == "EnumItem" then
			if self.inputCache[k] ~= nil then
				return self.inputCache[k] 
			end
		end
	end;
	__newindex = function(self,k,v)
		if typeof(k) == "EnumItem"  then
			self.inputCache[k] = v
			if k.EnumType == Enum.KeyCode and keysActive then
				if UIS:GamepadSupports(Enum.UserInputType.Gamepad1,k) then
					InputComponent.GamepadButtonChanged:Fire(k, v)
				else
					InputComponent.KeyChanged:Fire(k, v)
				end
			elseif k.EnumType == Enum.UserInputType and keysActive then
				if k.Name:find("MouseButton") then
					InputComponent.MouseButtonChanged:Fire(k, v)
				end
			end
		end
	end
})
InputComponent.Held = {};

for _, code in pairs(Enum.KeyCode:GetEnumItems()) do
	InputComponent.Pressed[code] = false;
end
keysActive = true
local activeGamepad = nil;

InputComponent.InputSchemes  = {};
InputComponent.CurrentIScheme = "General"
InputComponent.Sensitivity = {
	mouse =  0.3;
	aim =  0.3;
	touch = 0.875;
}
local activeGamepad = nil;
function InputComponent:GetActiveGamepad()
	local activateGamepad = nil
	local navigationGamepads = {}

	navigationGamepads = UIS:GetNavigationGamepads()

	if #navigationGamepads > 1 then
		for i = 1, #navigationGamepads do
			if activateGamepad == nil then
				activateGamepad = navigationGamepads[i]
			elseif navigationGamepads[i].Value < activateGamepad.Value then
				activateGamepad = navigationGamepads[i]
			end
		end
	else
		local connectedGamepads = {}

		connectedGamepads = UIS:GetConnectedGamepads()

		if #connectedGamepads > 0 then
			for i = 1, #connectedGamepads do
				if activateGamepad == nil then
					activateGamepad = connectedGamepads[i]
				elseif connectedGamepads[i].Value < activateGamepad.Value then
					activateGamepad = connectedGamepads[i]
				end
			end
		end
		if activateGamepad == nil then -- nothing is connected, at least set up for gamepad1
			activateGamepad = Enum.UserInputType.None
		end
	end

	return activateGamepad ~= Enum.UserInputType.None and  activateGamepad or nil;
end
local inputStates = {};
local regularKey = #UIS:GetConnectedGamepads() > 0 and Enum.KeyCode.ButtonR1 or Enum.KeyCode.I
local function refreshState(gp)
	if gp then
		local gpStates =UIS:GetGamepadState(gp)
		for _, state in pairs(gpStates) do
			inputStates[state.KeyCode] = state
		end
	end
end
if UIS.GamepadEnabled then
	activeGamepad = InputComponent:GetActiveGamepad()
	UIS.GamepadConnected:Connect(function(gp)
		print(gp.Name .. " is connected.")
		regularKey = #UIS:GetConnectedGamepads() > 0 and Enum.KeyCode.ButtonR1 or Enum.KeyCode.I
		activeGamepad = InputComponent:GetActiveGamepad()
		refreshState(activeGamepad);
	end)
	UIS.GamepadDisconnected:Connect(function(gp)
		print(gp.Name .. "is disconnected.")
		regularKey = #UIS:GetConnectedGamepads() > 0 and Enum.KeyCode.ButtonR1 or Enum.KeyCode.I
		activeGamepad = InputComponent:GetActiveGamepad()
		refreshState(activeGamepad);
	end)
	if #UIS:GetConnectedGamepads() > 0 then
		InputComponent.Platform = "Gamepad";
		refreshState(activeGamepad);
	end

end
if UIS.TouchEnabled then
	InputComponent.Platform = "Touch"
end
function InputComponent.isPlayStation()
		local str = UIS:GetStringForKeyCode(Enum.KeyCode.ButtonA)
		return str == "ButtonCross"
end
function InputComponent:RecalibratePlatform()
	local lastInputType = UIS:GetLastInputType()
	if lastInputType == Enum.UserInputType.Keyboard or string.find(tostring(lastInputType.Name), "Mouse") then
		InputComponent.Platform = "Keyboard"
	elseif lastInputType == Enum.UserInputType.Touch then
		InputComponent.Platform = "Touch"
	elseif string.find(tostring(lastInputType.Name), "Gamepad") then
		InputComponent.Platform = "Gamepad"
	end
end
function InputComponent:GetPlatform()
	local lastInputType = UIS:GetLastInputType()
	if lastInputType == Enum.UserInputType.Keyboard or string.find(tostring(lastInputType.Name), "Mouse") then
		return "Keyboard"
	elseif lastInputType == Enum.UserInputType.Touch then
		return "Touch"
	elseif string.find(tostring(lastInputType.Name), "Gamepad") then
		return "Gamepad"
	end
end
do
	InputComponent:AddDeviceSelector("Gamepad",function()
		return #UIS:GetConnectedGamepads() > 0 
	end)
	InputComponent:AddDeviceSelector("Keyboard",function()
		return UIS.KeyboardEnabled or UIS.MouseEnabled;
	end)
	InputComponent:AddDeviceSelector("Touch",function()
		return UIS.TouchEnabled
	end)
	InputComponent:EvaluatePlatformCount()
	if InputComponent.DeviceCount > 1 then
		UIS.LastInputTypeChanged:Connect(function()
			if InputComponent.Platform ~= InputComponent:GetPlatform() and (not _G.Tele) then
				InputComponent:RecalibratePlatform()
				InputComponent.PlatformChanged:Fire(InputComponent.Platform)
			end
		end)
	end
end
function InputComponent:GetCurrentGamepad()
	return activeGamepad
end
function InputComponent:GetUserInputTypeForKeyCode(keyCode)
	return UIS:GamepadSupports(self:GetActiveGamepad(),keyCode) and self:GetActiveGamepad() or Enum.UserInputType.Keyboard
end
function InputComponent:ControllerSupports(keyCode)
	return UIS:GamepadSupports(activeGamepad,keyCode)
end
function InputComponent:GetCurrentGamepadState(keyCode)
	return inputStates[keyCode]
end
function InputComponent.GetHighestPriorityGamepad()
	local connectedGamepads = UIS:GetConnectedGamepads()
	local bestGamepad = NONE -- Note that this value is higher than all valid gamepad values
	for _, gamepad in ipairs(connectedGamepads) do
		if gamepad.Value < bestGamepad.Value then
			bestGamepad = gamepad
		end
	end
	return bestGamepad
end
local gamepadS = 0.65;
local k = 0.35
local lowerK = 0.8
function Clamp(low, high, val)
	return math.min(math.max(val, low), high)
end
local function SCurveTranform(t)
	t = Clamp(-1,1,t)
	if t >= 0 then
		return (k*t) / (k - t + 1)
	end
	return -((lowerK*-t) / (lowerK + t + 1))
end

local function toSCurveSpace(t)
	return (1 + InputComponent.Deadzone) * (2*ABS(t) - 1) - InputComponent.Deadzone
end

local function fromSCurveSpace(t)
	return t/2 + 0.5
end
local function GamepadLinearToCurve(thumbstickPosition)
	local function onAxis(axisValue)
		local sign = 1
		if axisValue < 0 then
			sign = -1
		end
		local point = fromSCurveSpace(SCurveTranform(toSCurveSpace(math.abs(axisValue))))
		point = point * sign
		return Clamp(-1, 1, point)
	end
	return VEC2(onAxis(thumbstickPosition.x), onAxis(thumbstickPosition.y))
end
function InputComponent.SetDeadzone(zone)
	InputComponent.Deadzone = zone
end
function InputComponent.GetDeadzone(zone)
	return InputComponent.Deadzone
end
function InputComponent.GetUserSensitivity()
	local success, gamepadCameraSensitivity = pcall(function() return UserSettings():GetService("UserGameSettings").GamepadCameraSensitivity end)
	local finalConstant = success and (gamepadCameraSensitivity) or 0.09
	return finalConstant
end
function InputComponent:SetBinds(binds)
	InputComponent.Binds = binds
end
function InputComponent:IsInputDown(inputEnum)
	if inputEnum.EnumType == Enum.KeyCode or (inputEnum.EnumType == Enum.UserInputType and inputEnum.Name:find("MouseButton")) then
		return self.Pressed[inputEnum]
	end
	return false
end
function InputComponent:IsBindDown(category,bind)
	local bindKey = self.Binds[(category)]
	if bindKey then
		bindKey = bindKey[(self.Platform)]
		if bindKey then
			bindKey = bindKey[(bind)]
		end
	end	
	if not bindKey then return false end
	local inputEnum = Enum.KeyCode[bindKey]
	if not inputEnum then return false end
	if inputEnum.EnumType == Enum.KeyCode or (inputEnum.EnumType == Enum.UserInputType and inputEnum.Name:find("MouseButton")) then
		return self.Pressed[inputEnum]
	end
	return false
end
function InputComponent:GetBindCode(category,bind,platform)
	if self.Binds == {} then return end
	local bindKey = self.Binds[(category)]
	if bindKey then
		bindKey = bindKey[(platform or self.Platform)]
		if bindKey then
			bindKey = bindKey[(bind)]
		end
	end	
	if not bindKey then return false end
	local inputEnum = Enum.KeyCode[bindKey]
	return inputEnum
end
function InputComponent:AssignTopbarIconToBind(icon,category,bind,platform)
	if self.Binds == {} then return end
	local bindKey = self.Binds[(category)]
	if bindKey then
		bindKey = bindKey[(platform or self.Platform)]
		if bindKey then
			bindKey = bindKey[(bind)]
		end
	end	
	if not bindKey then return false end
	local inputEnum = Enum.KeyCode[bindKey]
	if inputEnum then
		if icon then
			icon:bindToggleKey(inputEnum)
		end
	end
end
do
	local InputBeganPlugins = {}
	local InputChangedPlugins = {}
	local InputEndedPlugins = {};
	local InputRenderedPlugins = {};
	local WindowFocusedPlugins = {};	
	local TouchMovedPlugins = {};	
	local TouchStartedPlugins = {};
	local TouchEndPlugins = {};
	local TapInWorldPlugins = {};
	local MenuPlugins = {};

	UIS.InputBegan:Connect(function(i,g)
		if not g then
			for _, plug in ipairs(InputBeganPlugins) do
				local res = plug(i,g)
				if res then
					break;
				end
			end
		end
	end)
	UIS.InputChanged:Connect(function(i,g)
		if not g then
			for _, plug in ipairs(InputChangedPlugins) do
				local res = plug(i,g)
				if res then
					break;
				end
			end
		end
	end)
	UIS.InputEnded:Connect(function(i,g)
		if not g then
			for _, plug in ipairs(InputEndedPlugins) do
				local res = plug(i,g)
				if res then
					break;
				end
			end
		end
	end)
	UIS.TouchMoved:Connect(function(i,g)
			for _, plug in ipairs(TouchMovedPlugins) do
				local res = plug(i,g)
				if res then
					break;
				end
			end
	end)
	UIS.TouchStarted:Connect(function(i,g)
		for _, plug in ipairs(TouchStartedPlugins) do
				local res = plug(i,g)
				if res then
					break;
				end
		end
	end)
	UIS.TouchEnded:Connect(function(i,g)
			for _, plug in ipairs(TouchEndPlugins) do
				local res = plug(i,g)
				if res then
					break;
				end
			end
	end)
	UIS.TouchTapInWorld:Connect(function(pos, g)
		for _, plug in ipairs(TapInWorldPlugins) do
			local res = plug(pos,g)
			if res then
				break;
			end
		end
	end)
	GuiService.MenuOpened:Connect(function()
		for _, plug in ipairs(MenuPlugins) do
			local res = plug(true)
			if res then
				break;
			end
		end
	end)
	GuiService.MenuClosed:Connect(function()
		for _, plug in ipairs(MenuPlugins) do
			local res = plug(false)
			if res then
				break;
			end
		end
	end)
	Enumeration.InputPluginType = {
		"Began";
		"Changed";
		"Ended";
		"Render";
		"WindowFocused";
		"TouchMoved";
		"TouchStarted";
		"TouchEnd";
		"TapInWorld";
		"Menu";
	}
	InputComponent.AddInputPlugin = function(typeOf,f)
		local n = typeOf.Name
		if n == "Began" then
			table.insert(InputBeganPlugins,f)
		elseif n == 'Changed' then
			table.insert(InputChangedPlugins,f)
		elseif n == 'Ended' then
			table.insert(InputEndedPlugins,f)
		elseif n == "Render" then
			table.insert(InputRenderedPlugins, f)
		elseif n == "WindowFocused" then
			table.insert(WindowFocusedPlugins, f)
		elseif n == "TouchMoved" then
			table.insert(TouchMovedPlugins, f)
		elseif n == "TouchStarted" then
			table.insert(TouchStartedPlugins, f)
		elseif n == "TouchEnd" then
			table.insert(TouchEndPlugins, f)
		elseif n == "TapInWorld" then
			table.insert(TapInWorldPlugins, f)
		elseif n == "Menu" then
			table.insert(MenuPlugins, f)
		end
	end;
	RunService:BindToRenderStep("RenderInput",Enum.RenderPriority.Input.Value-3,function(dt)
		for _, plug in ipairs(InputRenderedPlugins) do
			plug(dt)
		end 
	end)
	UIS.WindowFocused:Connect(function()
		for _, plug in ipairs(WindowFocusedPlugins) do
			plug()
		end 
	end)
end
function InputComponent.GetPositionCFrame(filter)
	local pos
	if UIS.MouseEnabled then
		pos = UIS:GetMouseLocation()
			--[[if UIS.MouseBehavior == Enum.MouseBehavior.LockCenter then
				pos = (workspace.CurrentCamera.ViewportSize/2)
			end]]--
	elseif UIS.TouchEnabled then
		pos = workspace.CurrentCamera.ViewportSize/2 
	end
	local r 
	if pos then
		r = workspace.CurrentCamera:ViewportPointToRay(pos.X,pos.Y,10)
		r = Ray.new(r.Origin,r.Direction * 1000)

	end
	if r then
		local ry = RayUtils:LineCastExclusive(r.Origin,r.Direction,{
			FilterList = filter;
			IgnoreWater = true;
		})
		if ry then
			return CFrame.new(ry.Position, ry.Position + r.Unit.Direction)
		end
	end
	return CFrame.new()
end
function InputComponent.GetPositionRay(filter)
	local pos
	if UIS.MouseEnabled then
		pos = _G.MouseOvveride or UIS:GetMouseLocation()
			--[[if UIS.MouseBehavior == Enum.MouseBehavior.LockCenter then
				pos = (workspace.CurrentCamera.ViewportSize/2)
			end]]--
	elseif UIS.TouchEnabled then
		pos = workspace.CurrentCamera.ViewportSize/2 
	end
	local r 
	if pos then
		r = workspace.CurrentCamera:ViewportPointToRay(pos.X,pos.Y,10)
		r = Ray.new(r.Origin,r.Direction * 1000)

	end

	return r
end
function InputComponent.GetPositionHit(filter)
	local pos
	if UIS.MouseEnabled then
		pos = _G.MouseOverride or UIS:GetMouseLocation()
			--[[if UIS.MouseBehavior == Enum.MouseBehavior.LockCenter then
				pos = (workspace.CurrentCamera.ViewportSize/2)
			end]]--
	elseif UIS.TouchEnabled then
		pos = workspace.CurrentCamera.ViewportSize/2 
	end
	local r 
	if pos then
		r = workspace.CurrentCamera:ViewportPointToRay(pos.X,pos.Y,10)
		r = Ray.new(r.Origin,r.Direction * 1000)

	end
	if r then
		local ry = RayUtils:LineCastExclusive(r.Origin,r.Direction,{
			FilterList = filter  or {game.Players.LocalPlayer.Character};
			IgnoreWater = true;
		})
		if ry then
			return ry.Instance
		end
	end
	return nil
end
do
	InputComponent.MobileRotationChanged = Signal.new()
	UIS.DeviceRotationChanged:Connect(function(rotI, cf)
		InputComponent.MobileRotationChanged:Fire(cf,rotI)
	end)
	
end
do
	local scTab = {
		"SuperJoystick";
		"InputScheme";
		"InputAxis";
		"Interaction";
		"LoadoutInputScheme";
		"RumblePreset";
		"CharacterController";
		"ControlImages";
		"SelectionScheme";
		"MouseUtils";
		"MenuComponent";
		"PlacementSession";
		"RadialMenu";
	};
	for  i, sc in ipairs(scTab) do
		local comp = script.Subcomponents:FindFirstChild(sc)
		local subcomponentData = require(comp)
		if typeof(subcomponentData) == "function" then
			subcomponentData = subcomponentData({
				Resources = Resources,
				PseudoInstance = PseudoInstance,
				Enumeration = Enumeration	,
				Tween = Tween,
				Lerps = Lerps;
				Typer = Typer,
				VEC2 = VEC2,
				V3 = Vector3.new,
				ZERO_VECTOR3 = Vector3.new();
				RAD = RAD,
				UIS = UIS,
				fastSpawn = fastSpawn;
				inList = inList;
				isIgnored = isIgnored;
				Players = game:GetService("Players");
				HapticsService = HapticsService;
				Spring = Spring;
				Janitor = Janitor,
				RemoteService = RemoteService;
				Signal = Signal;
				removeElement = removeElement;
				FastDelay = FastDelay;
				FastWait = FastWait;
				ContextActionService = ContextActionService;
				RunService = RunService;
				GamepadLinearToCurve = GamepadLinearToCurve;
				CollectionService = game:GetService("CollectionService");
				RayUtils = RayUtils;
			},InputComponent)
			InputComponent[subcomponentData.Name] = subcomponentData.SubComp
		end
	end
end
return InputComponent