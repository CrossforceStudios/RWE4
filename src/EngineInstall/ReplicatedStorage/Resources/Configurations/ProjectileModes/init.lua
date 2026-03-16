local ProjectileModes = {}

for _, mode in script.Modes:GetChildren() do
	if mode:IsA("ModuleScript") then
		local func = require(mode)
		ProjectileModes[mode.Name] = func
	end
end

return ProjectileModes