return {
	Size = 50;
	StarDistance = 27500, -- Average Distance of stars
	Stars = 1024, -- Star count, large values can be demanding
	Color = { -- Color Settings
		Color = Color3.new(1, 1, 1),
		StartColor = Color3.fromRGB(255,100,100),
		EndColor = Color3.fromRGB(0,150,255),
	},
	StarDistanceThreshold = 10000, -- If star position's distance is under set value, it will use StarDistanceThresholdMultiplier to multiply the current position by the set value
	StarDistanceThresholdMultiplier = 3, -- Multiplier for StarDistanceThreshold, info ^^^
	MaxClock = 1, --  Ill do something about this eventually, for now ignore
	StarFlicker = { -- Star flickering! A lot of stars with the ability to flicker can be demanding
		Clock = 6, -- Ignore for now
		CurrentClock = 1, -- Ignore for now

		ConsiderRate = 8, -- Chance that a star will be selected for flickering, if not it will not flicker

		FlickAlphaMin = 0, -- Flicker lowest color alpha
		FlickAlphaMax = 0.5, -- Flicker highest color alpha
		FlickColor = Color3.new(0, 0, 0), -- Flickering will try to interpolate the stars base color to this using an alpha randomly generated (between the values above)

		TweenTime = 0.1, -- Time of color change tween

		FlickRate = 3, -- How likely it is for a star to start flickering
	},
	StarFalls = { -- Only works for method 1

		ActivateRate = 128, -- Chance of a falling star to appear, chance is done every frame and is basically just a 1 in X chance, X being whatever value you set at ActivateRate

		TimeMaxes = { -- Amount of ticks the nebulas will last for, 60 ticks is usually 1 second tho may vary depending on framerate
			Min = 50,
			Max = 260,
		},

		StarDistance = 27500, -- Average Falling star distance away from the camera
		SizeRangeMin = 70, -- Minimum Size
		SizeRangeMax = 450, -- Maximum Size

		TrailLifeTimes = {1,3.25}, -- Min and Max

		StarSpeed = 4, -- Speed of falling star
		StarSpeedMultiplier = 125, -- for speed multi (less life time =  faster)

		BrightnessLevels = {4,6.4}, -- Min and Max
	},
}