return function(API, InputComponent)
	local INTERPOLATION_DAMP = .21; 
	local PlacementSession
	local Sessions = API.Resources:GetLocalTable("Sessions");
	Sessions.Sessions = {};
	local TargetFilter = {};
	Sessions.Current = nil;
	API.Enumeration.PlacementMode = {
		"Placement";
		"Colliding";
		
	}
	API.Enumeration.PlacementState = {
		"Placing";
		"Colliding";

	}
	local Round =  API.Resources:LoadLibrary("MathRound")
	local PaintCallback = function(struct,color)
		API.RemoteService.send("Server","PaintStructure",struct,color)
	end
	local DeleteCallback = function(struct)
		API.RemoteService.send("Server","DestroyStructure",struct)
	end
	function InputComponent.GetPlacementPos(posOverride)
		if posOverride then
			local pos = posOverride
			local r 
			if pos then
				
				r = workspace.CurrentCamera:ViewportPointToRay(posOverride.X, posOverride.Y, 10)
				r = Ray.new(r.Origin,r.Direction * 1000)

			end
			if r then
				local ry = API.RayUtils:LineCastExclusive(r.Origin,r.Direction,{
					FilterList = TargetFilter or {game.Players.LocalPlayer.Character};
					IgnoreWater = true;
				})
				if ry then
					return CFrame.new(ry.Position, ry.Position + r.Unit.Direction)
				end
			end
			return nil
		end
		return InputComponent.GetPositionCFrame(TargetFilter);
	end
	function InputComponent.GetPlacementTarget(posOverride)
		if posOverride then
			local pos = posOverride
			local r 
			if pos then
				r = Ray.new(workspace.CurrentCamera.CFrame.Position, (posOverride - workspace.CurrentCamera.CFrame.Position))
				r = Ray.new(r.Origin,r.Direction * 1000)

			end
			if r then
				local ry = API.RayUtils:LineCastExclusive(r.Origin,r.Direction,{
					FilterList = TargetFilter or {game.Players.LocalPlayer.Character};
					IgnoreWater = true;
				})
				if ry then
					return ry.Instance
				end
			end
			return nil
		end
		return InputComponent.GetPositionHit(TargetFilter);
	end
	function InputComponent.GetPlacementCancelKey()
		return InputComponent:GetBindCode("Toolbox","Cancel")
	end
	function InputComponent.PaintStructure(color)
		local struct = InputComponent.GetPlacementTarget()
		if struct then
			if struct:FindFirstAncestor("PropStorage") then
				PaintCallback(struct,color)
			end
		end
	end	
	function InputComponent.DeleteStructure()
		local struct = InputComponent.GetPlacementTarget()
		if struct then
			if struct:FindFirstAncestor("PropStorage") then
				DeleteCallback(struct)
			end
		end
		
	end	
	
	PlacementSession = API.PseudoInstance:Register("PlacementSession",{
		Internals = {
				lastPos = Vector3.new();
				callbacks = {};
				StY = 0;
				"lowerXBound";	
			    "lowerZBound";	
			    "upperXBound";	
				"upperZBound";	
				"cx";
				"cz";
				"movementConn";
				"movementConn2";
				"rotateConn";
				"posOverride";	
				lastPosTouch = Vector3.new() ;
		};
		
		Methods = {
			Setup = function(self, plot, cancelCB, config)
				print(plot)
				local selfObj = self
				self.Plot = plot
				if TargetFilter then
					table.insert(TargetFilter,self.Plot)
					if self.Structure:IsA("Model") then
						table.insert(TargetFilter,self.Structure)
					end
				end
				if self.Structure:IsA("Model") then
					self.StartingPos  = Vector3.new(plot.CFrame.X,self:CalculateY(plot.CFrame.Y,plot.Size.Y,0),plot.CFrame.Z)
					self.StY = self.StartingPos.Y
					local p = self.StartingPos
					self.Structure:SetPrimaryPartCFrame(CFrame.new(p.X,self.StartingPos.Y,p.Z))
					for _, proc in ipairs(self.callbacks) do
						proc(self.Structure,API)
					end
					for i, m in ipairs(self.Structure:GetDescendants()) do
						if m then
							if m:IsA("Part") or m:IsA("UnionOperation") or m:IsA("MeshPart") then
								m.CanCollide = false
								m.Transparency = m.Transparency + self.Config.transparentDelta
							end
						end
					end
					self.Structure.PrimaryPart.Transparency =  self.Config.hitboxTransparency	
					self:DisplayGridOnCanvas()
					self.Structure.Parent = self.Config.Parent 
					if not self.Config.Parent then
						self.Structure.Parent =  plot.Parent.PropStorage
					end
					self.Active = true

					self.Position = self.Structure:GetPrimaryPartCFrame().p
					print(self.Position, ":", plot.Position)

				elseif self.Structure:IsA("BasePart") then
					self.StartingPos  = Vector3.new(plot.CFrame.X,self:CalculateY(plot.CFrame.Y,plot.Size.Y,0),plot.CFrame.Z)
					local p = InputComponent.GetPlacementPos()
					self.Structure.CFrame = (CFrame.new(p.X,self.StartingPos.Y,p.Z))
					self.StY = self.StartingPos.Y 

					self.Structure.CanCollide = false
					self.Structure.Transparency = self.Structure.Transparency + (self.Config.transparentDelta)
					self:DisplayGridOnCanvas()
					self.Structure.Parent = self.Config.Parent 
					if not self.Config.Parent then
						self.Structure.Parent =  plot.Parent.PropStorage
					end
					self.Active = true
					self.Position = self.Structure:GetPrimaryPartCFrame().p
				end
				Sessions.Current = self
				InputComponent.RegisterSchemeAction("Toolbox","Rotate",{InputComponent:GetBindCode("Toolbox","Rotate")},false,function(i,g)
					self:RotateModel()
				end,true,1)
				InputComponent.RegisterSchemeAction("Toolbox","Cancel",{InputComponent:GetBindCode("Toolbox","Cancel")},false,function(i,g)
					if self.Destroy then
						self.Structure:Destroy()
						self.Janitor:Cleanup()
						API.removeElement(Sessions.Sessions,self)
						Sessions.Current = nil;
					end
					if cancelCB then
						cancelCB()
					end
				end,true,1)	
				InputComponent.RegisterSJSchemeModes("Toolbox", {
					{
						Type = "Movement";
						Title = "Placement";
					};
					{
						Type = "AxisAction";
						Title = "Floors";
						Actions = {
							Up = {
								Name = "FloorUp";
								Range = NumberRange.new(.5, 1);
								Axis = "Y";
								OppositeAxis = "X";
							};
							Down = {
								Name = "FloorDown";
								Range = NumberRange.new(-1, -.5);
								Axis = "Y";
								OppositeAxis = "X";
							};
						};
					}
				})
				InputComponent.CurrentIScheme = "Toolbox"
				if InputComponent.Platform == "Touch" then
						InputComponent.Joystick:SetupScheme()
						InputComponent.ForceSJScheme(1)
						local times = 0;
						local debounce = false
						self.movementConn = API.UIS.TouchTapInWorld:Connect(function(pos, gp)
						if (not gp) and (not debounce) then
							debounce = true
							
							local pos2 = InputComponent.GetPlacementPos(pos) 
							task.delay(0.1, function()
								debounce = false
							end)
							if pos2 then
								self:CalculateNewPosition(pos2)
								if (pos2.p - self.lastPosTouch).Magnitude <= 1 then
									times += 1
									self.lastPosTouch = pos2.Position
								end
							end
							
							times += 1
							task.delay(0.4, function()
								debounce = false
							end)
							if times >= 2 then
								times = 0
								self:Finalize()
								if self.Destroy then
									self.movementConn:Disconnect()
									self.movementConn = nil
									self.movementConn2:Disconnect()
									self.movementConn2 = nil
									self.Structure:Destroy()
									self.Janitor:Cleanup()
									_G.ToolboxRotateButton.Visible = false
									_G.ToolboxCancelButton.Visible = false
									_G.ToolboxPlaceButton.Visible = false
									API.removeElement(Sessions.Sessions,self)
									InputComponent.ResetSJScheme()
									Sessions.Current = nil;
								end
								if cancelCB then
									cancelCB()
								end
								return
							end
						end	
					end)
					self.movementConn2 = InputComponent.Joystick.AxisChanged:Connect(function(t, v)
						if t == "Placement" then
							self.Position += Vector3.new(v.X/10, 0, v.Y/10)
						end
					end)
					self.Janitor:Add(_G.ToolboxRotateButton.Activated:Connect(function()
						self:RotateModel()
					end),"Disconnect")
					self.Janitor:Add(_G.ToolboxPlaceButton.Activated:Connect(function()
						self:Finalize()
					end),"Disconnect")
					self.Janitor:Add(_G.ToolboxCancelButton.Activated:Connect(function()
						if self.Destroy then
							self.movementConn:Disconnect()
							self.movementConn = nil
							self.movementConn2:Disconnect()
							self.movementConn2 = nil
							self.Structure:Destroy()
							self.Janitor:Cleanup()
							_G.ToolboxRotateButton.Visible = false
							_G.ToolboxCancelButton.Visible = false
							_G.ToolboxPlaceButton.Visible = false

							API.removeElement(Sessions.Sessions,self)
							InputComponent.ResetSJScheme()
							Sessions.Current = nil;
						end
						if cancelCB then
							cancelCB()
						end
					end),"Disconnect")
					self.Janitor:Add(InputComponent.Joystick.ActionTriggered:Connect(function(act, input, scheme)
						if act == "FloorUp" or act == "FloorDown" then
							local h = InputComponent.GetPlacementTarget(self:IsTouch() and self.Position or nil)
							if h then
								if h:IsDescendantOf(self.Structure.Parent) then
									self:EditFloor(h)
								else
									self.FloorPos = self.StY		
								end
							end
						end
					end),"Disconnect")
					_G.ToolboxRotateButton.Visible = true
					_G.ToolboxCancelButton.Visible = true
					_G.ToolboxPlaceButton.Visible = true
				end

				InputComponent.ToggleMouseControl(true, false)

			end;
				IsMovementAllowed = function(self)
					return self.PrimaryMode.Name == "Placement" and self.Active and self.Structure
				end;
				CalcFinalCFrame = function(self)
					if self.CurrentRot then
						self.CFrame = CFrame.new(self.Position) 
					end
				end;
				CalculateY = function(self, tp, ts, o)
					return (tp + (ts * .5)) + (o * .5)
				end;
				CheckRotation = function(self)
					if self.Structure then
						if self.CurrentRot then
							self.CurrentRot = false
						else 
							self.CurrentRot = true
						end
					end
				end;
				GetSize = function(self)
					return self.Structure:IsA("Model") and self.Structure:GetExtentsSize() or self.Structure.Size
				end;
				Bounds = function(self)
							if self.CurrentRot then
								self.lowerXBound = self.Plot.Position.X - (self.Plot.Size.X / 2) 
								self.upperXBound = self.Plot.Position.X + (self.Plot.Size.X / 2) - self:GetSize().X

								self.lowerZBound = self.Plot.Position.Z - (self.Plot.Size.Z / 2)	
								self.upperZBound = self.Plot.Position.Z + (self.Plot.Size.Z / 2) -  self:GetSize().Z
							else
								self.lowerXBound = self.Plot.Position.X - (self.Plot.Size.X / 2) 
								self.upperXBound = self.Plot.Position.X + (self.Plot.Size.X / 2) -  self:GetSize().Z

								self.lowerZBound = self.Plot.Position.Z - (self.Plot.Size.Z / 2)	
								self.upperZBound = self.Plot.Position.Z + (self.Plot.Size.Z / 2) -  self:GetSize().X
							end
							local posX = math.clamp(self.Position.X, self.lowerXBound, self.upperXBound)
							local posZ = math.clamp(self.Position.Z, self.lowerZBound, self.upperZBound)
							self.Position = Vector3.new(posX,self.FloorPos,posZ)
			end;
			EditFloor = function(self, h)
						if self.Structure:FindFirstChild("CanStack") then
							if not self.Structure.CanStack.Value then return end
						end
						local tp, ts, o = h.Parent:GetPrimaryPartCFrame().Y, h.Parent:GetExtentsSize().Y, math.clamp(h.Parent:GetExtentsSize().Y,0.05,10)
						self.FloorPos = self:CalculateY(tp,ts,o)
			end;
			RotateModel = function(self)
				local prevRot = math.rad(self.Rotation)

				API.Tween.new(0.2, "Linear", "PieceRotation", true, function(x)
					self.Rotation = math.deg(API.Lerps.angle(prevRot, prevRot + math.rad(self.Config.RotationStep),1 - (1 - x)^2))
				end):Wait()
				if self.Rotation >= 360 then
					self.Rotation = 0
				end
			end;
			CalculateNewPosition = function(self, Hit)
						-- use other method to get info about the surface
						local x, z = Hit.X, Hit.Z
						local posX, posZ = x, z
						if self.GridSize then
							if x % (self.GridSize or 2) < (self.GridSize or 2) / 2 then
								posX = Round(x - (x % (self.GridSize or 2)))
							else
								posX = Round(x + ((self.GridSize or 2) - (x % (self.GridSize or 2))))
							end

							if z % (self.GridSize or 2) < (self.GridSize or 2) / 2 then
								posZ = Round(z - (z % (self.GridSize or 2)))
							else
								posZ = Round(z + ((self.GridSize or 2) - (z % (self.GridSize or 2))))
							end
						end
						if self.CurrentRot then
							self.cx = self:GetSize().X / 2
							self.cz = self:GetSize().Z / 2
						else
							self.cx = self:GetSize().Z / 2
							self.cz = self:GetSize().X / 2
						end

						local h = InputComponent.GetPlacementTarget(self:IsTouch() and self.Position or nil)
						if h then
							if h:IsDescendantOf(self.Structure.Parent) then
								self:EditFloor(h)
							else
								self.FloorPos = self.StY		
							end
						end
						self.FloorPos = math.clamp(self.FloorPos, self.StY, self.MaxHeight + self.StY)
						self.Position = Vector3.new(posX,self.FloorPos,posZ)
						self:Bounds()				
			end;
			Calc = function(self, tf)
						if self.CurrentRot then
							if self.Structure:IsA("Model") then
								self.Structure:SetPrimaryPartCFrame(CFrame.new(self.Position) * CFrame.new(self.cx,0,self.cz) * CFrame.Angles(0, math.rad(self.Rotation), 0))
							elseif self.Structure:IsA("BasePart") then
								self.Structure.CFrame = (CFrame.new(self.Position) * CFrame.new(self.cx,0,self.cz) * CFrame.Angles(0, math.rad(self.Rotation), 0))
							end
						else
							if self.Structure:IsA("Model") then
								self.Structure:SetPrimaryPartCFrame(CFrame.new(self.Position) * CFrame.new(self.cx,0,self.cz) * CFrame.Angles(0, math.rad(self.Rotation), 0))
							elseif self.Structure:IsA("BasePart") then
								self.Structure.CFrame = (CFrame.new(self.Position) * CFrame.new(self.cx,0,self.cz) * CFrame.Angles(0, math.rad(self.Rotation), 0))
							end
						end
			end;
			CheckHitbox = function(self, ignore)
								if self.Structure then
									local colliding = false
									self.CurrentState = "Placing"
									if self.Structure:IsA("Model") then
										local collisionPoint = self.Structure.PrimaryPart.Touched:Connect(function() end)
										local collisionPoints = self.Structure.PrimaryPart:GetTouchingParts()

										for i = 1, #collisionPoints do
											if not collisionPoints[i]:IsDescendantOf(self.Structure)  and not API.isIgnored(collisionPoints[i],ignore) then
												self.CurrentState = "Colliding"

												break
											end
										end

										colliding = (self.CurrentState.Name == "Colliding")
										collisionPoint:Disconnect()
									elseif self.Structure:IsA("BasePart")then
										local collisionPoint = self.Structure.Touched:Connect(function() end)
										local collisionPoints = self.Structure:GetTouchingParts()

										for i = 1, #collisionPoints do
							if not collisionPoints[i]:IsDescendantOf(self.Structure)  and not API.isIgnored(collisionPoints[i],ignore) then
												self.CurrentState = "Colliding"

												break
											end
										end

										colliding = (self.CurrentState.Name == "Colliding")
										collisionPoint:Disconnect()
									end

									return colliding
								end
			end;
			EditColor = function(self)
						if self.Structure then
							if self.Structure:IsA("Model") then
								self.Structure.PrimaryPart.Color =  (self.CurrentState.Name == "Colliding" and self.Config.CollisionColor or self.Config.PlacingColor)
							elseif self.Structure:IsA("BasePart") then
								self.Structure.Color =  (self.CurrentState.Name == "Colliding" and self.Config.CollisionColor or self.Config.PlacingColor)	
							end
						end
			end;
			DisplayGridOnCanvas = function(self)
						local gridTex = Instance.new("Texture")

						gridTex.Name = "GridTexture"
						gridTex.Texture = self.Config.GridTexture
						gridTex.Parent = self.Plot
						gridTex.Face = Enum.NormalId.Top


						gridTex.StudsPerTileU = self.GridSize
						gridTex.StudsPerTileV = self.GridSize

			end;
			Finalize = function(self)
						if self.Structure:IsA("Model") then
							self.lastPos = self.Structure.PrimaryPart.CFrame.p
						elseif self.Structure:IsA("BasePart") then
							self.lastPos = self.Structure.CFrame.p
						end

						self:Calc(self.CurrentRot)
						self:CalculateNewPosition(InputComponent.GetPlacementPos())
						self:CalcFinalCFrame()
						self:CheckHitbox(TargetFilter)

						if self.CurrentState.Name ~= "Colliding"then
						if (not self.Config.Final) and self.PlaceCallback then
								self.PlaceCallback(self:Replicate(), workspace.PropStorage, self.CFrame)
							else
								self.Config.Final(self:Replicate(), workspace.PropStorage,self.CFrame)
							end
						end
						API.FastWait(self.Config.Cooldown)
							
			end;
			Replicate = function(self)
						if self.Structure then
							if self.Structure:IsA("Model") then
								local modelInfo = {
									Name = self.Structure.Name;
									CollisionState = (self.CurrentState.Name == "Colliding");


									CFrame = {
										X = self.Structure.PrimaryPart.CFrame.X,
										Y =  self.Structure.PrimaryPart.CFrame.Y,
										Z =  self.Structure.PrimaryPart.CFrame.Z,
										Rotation = self.Structure.PrimaryPart.Orientation.Y
									}
								}

								return modelInfo
							elseif self.Structure:IsA("BasePart") then
								local modelInfo = {
									Name = self.Structure.Name;
									CollisionState = (self.CurrentState.Name == "Colliding");


									CFrame = {
										X = self.Structure.CFrame.X,
										Y =  self.Structure.CFrame.Y,
										Z =  self.Structure.CFrame.Z,
										Rotation = self.Structure.Orientation.Y
									}
								}

								return modelInfo

							end
						end	
			end;
			IsTouch = function(self)
				return self.movementConn ~= nil and API.UIS.TouchEnabled
			end,
		};
		
		Events = {
			"SelectionChanged";
		};
		
		Properties = {
			Rotation = API.Typer.Number;
			Active = API.Typer.Boolean;
			Size = API.Typer.OptionalVector3;
			Structure = API.Typer.OptionalInstanceWhichIsAPVInstance;
			Plot = API.Typer.OptionalInstanceWhichIsAPVInstance;
			FloorStep = API.Typer.OptionalNumber;
			StartingPos = API.Typer.OptionalVector3;
			MaxHeight = API.Typer.OptionalNumber;
			Config = API.Typer.OptionalTable;
			Position = API.Typer.OptionalVector3;
			PrimaryMode =  API.Typer.EnumerationOfTypePlacementMode;
			CurrentState =  API.Typer.EnumerationOfTypePlacementState;
			PlaceCallback = API.Typer.OptionalFunction;
			CurrentRot = API.Typer.Boolean;
			CFrame = API.Typer.OptionalCFrame;
			GridSize = API.Typer.OptionalNumber;
			FloorPos = API.Typer.OptionalNumber;

		};
		
		Init = function(self, ...)
			local args = {...}
			self:superinit()
			local structure = typeof(args[1]) == "Instance" and args[1] or API.Resources:GetProp(args[1])
			if structure:IsA("Model") then
				structure = structure:Clone()
				self.Structure = structure
				if self.Structure:FindFirstChild("CamPart") then
					self.Structure.CamPart:Destroy()
				end		
				local size = structure:GetExtentsSize()
				self.Size = size
				self.FloorStep = size.Y
				self.MaxHeight = (size.Y * 10)
				self.FloorPos = 0;
			elseif structure:IsA("BasePart") then
				structure = structure:Clone()
				self.Structure = structure	
				local size = structure.Size
				self.Size = size
				self.FloorStep = size.Y
				self.MaxHeight = (size.Y * 10)
				self.FloorPos = 0;
				self.Janitor:Add(self.Structure)
			else
				return nil;
			end
			self.Config = args[2] or {};
			self.GridSize = self.Config.GridSize		
			self.Position = Vector3.new();
			self.PrimaryMode = "Placement";
			self.Active = false
			self.Rotation = 0;
			self.CurrentRot = true;
			self.CFrame = CFrame.new(self.Position)
			self.CurrentState = "Placing";
			table.insert(Sessions.Sessions,self)


		end;
		
	})
	function InputComponent.CreatePlacement(...)
		return API.PseudoInstance.new("PlacementSession",...)
	end
	InputComponent.AddInputPlugin(API.Enumeration.InputPluginType.Render, function(dt)
		for _, p in ipairs(Sessions.Sessions) do
			if p then
				if p:IsMovementAllowed() then
					if not p:IsTouch() then
						local pos = InputComponent.GetPlacementPos()
						p:CalculateNewPosition(pos.p)
					end
					p:Calc(true)

					p:CheckHitbox(TargetFilter)
					p:EditColor()
				end
			end
		end
	end)
	return {
		Name = "PlacementSession";
		SubComp = PlacementSession;
	}	
end