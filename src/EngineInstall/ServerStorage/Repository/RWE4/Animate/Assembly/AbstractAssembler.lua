local Resources = require(game.ReplicatedStorage.Resources)
local Typer = Resources:LoadLibrary("Typer")
local Make = Resources:LoadLibrary("Make")
local PseudoInstance = Resources:LoadLibrary("PseudoInstance")
local inList = Resources:LoadLibrary("inList")
local Joint = Resources:LoadLibrary("Joint")
local AttachmentsList = Resources:LoadConfiguration("Attachment")
local WeapBuilder = Resources:LoadLibrary("WeapBuilder")
local CF = CFrame.new
local CFANG = CFrame.Angles
local RAD = math.rad
local ModelHelpers = {
	
}
local ItemAssembler = PseudoInstance:Register("AbstractAssembler",{
	Properties = {
		WeapBuilder = Typer.Any;	
		
		CFrames = Typer.Any;

		sheatheModel = Typer.InstanceOfClassModel;

		sheatheWeld = Typer.OptionalInstanceWhichIsAJointInstance;	
	};
	
	Methods = {
		
		
		makeSheatheWeld = function(self, item, Torso, LLeg, RLeg)
			
		end,
		
		GetAssemblyTable = function(self, item, part,  sType)
			
		end,


		Assemble = function(self, item, extras)
		
		end;
		
		destroySheatheModel = function(self)

		end;
		
		getSheatheData = function(self, Character, item)
			
		end,
		
		sheathe = function(self, Character, item, extras)
			
		end,



	};
	
	
	
	Call = function(self,...)
		self:Assemble(...)
	end;
	
	Init = function(self)	
		self:superinit()
	end;
})

return ItemAssembler;

