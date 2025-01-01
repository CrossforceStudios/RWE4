return {
	["Default"] = {
		Name = "Default";
		Title = "Default Lighting";
		Periods = {
			["Dawn"] = {
				TimeStart = 5,
				TimeEnd = 6.3,
				Ambient = Color3.fromRGB(115, 78, 0),
				OutdoorAmbient = Color3.fromRGB(128, 124, 81),
				ShadowSoftness = 0.4,
				LightsOn = false,
				SunRaysEnabled = true,
			},
			["Day"] = {
				TimeStart = 6.3,
				TimeEnd = 17.3,
				Ambient = Color3.fromRGB(136, 95, 0),
				OutdoorAmbient = Color3.fromRGB(128, 128, 128),
				ShadowSoftness = 0.65,
				LightsOn = false,
				SunRaysEnabled = true,
				
			},
			["Dusk"] = {
				TimeStart = 17.3,
				TimeEnd = 18.5,
				Ambient = Color3.fromRGB(156, 136, 176),
				OutdoorAmbient = Color3.fromRGB(156, 136, 176),
				ShadowSoftness = 0.3,
				LightsOn = false,
				SunRaysEnabled = false,
			},
			["Night"] = {
				TimeStart = 18.5,
				TimeEnd = 5,
				Ambient = Color3.fromRGB(104, 67, 0),
				OutdoorAmbient = Color3.fromRGB(95, 100, 128),
				ShadowSoftness = 0.1,
				LightsOn = true,
				SunRaysEnabled = false,
			},			
		}
	};
	["Tactical"] = {
		Name = "Tactical";
		Title = "Tactical Lighting";
		Periods = {
			["Dawn"] = {
				TimeStart = 5,
				TimeEnd = 6.3,
				Ambient = Color3.fromRGB(75, 38, 0),
				OutdoorAmbient = Color3.fromRGB(88, 84, 61),
				ShadowSoftness = 0.1,
				LightsOn = false,
				SunRaysEnabled = true,
				
			},
			["Day"] = {
				TimeStart = 6.3,
				TimeEnd = 17.3,
				Ambient = Color3.fromRGB(136, 95, 0),
				OutdoorAmbient = Color3.fromRGB(128, 128, 128),
				ShadowSoftness = 0.2,
				LightsOn = false,
				SunRaysEnabled = true,
				
			},
			["Dusk"] = {
				TimeStart = 17.3,
				TimeEnd = 18.5,
				Ambient = Color3.fromRGB(75, 38, 0),
				OutdoorAmbient = Color3.fromRGB(88, 69, 66),
				ShadowSoftness = 0.3,
				LightsOn = false,
				SunRaysEnabled = true,
			},
			["NightOne"] = {
				TimeStart = 18.5,
				TimeEnd = 23.992500305175,
				Ambient = Color3.fromRGB(5, 5, 5),
				OutdoorAmbient = Color3.fromRGB(50, 50, 50),
				ShadowSoftness = 0.1,
				LightsOn = true,
				SunRaysEnabled = true,
				Brightness = .15,

			},		
			["NightTwo"] = {
				TimeStart = 0,
				TimeEnd = 5,
				Ambient = Color3.fromRGB(5, 5, 5),
				OutdoorAmbient = Color3.fromRGB(50, 50, 50),
				ShadowSoftness = 0.1,
				LightsOn = true,
				SunRaysEnabled = true,
				Brightness = .15,

			},		
		}
	}

};