return {

    Events = {
        "KillAdded";
        "PlayerAdded";
		"ItemEquipped";
    };
    CollisionPairs = {
		{"PlayerRagdoll", "HRPRagdoll", false};
		{"Wheel", "Player", false};
		{"Default","Player",true};
		{"Default","PlayerLimbs",false};
		{"Default","Map",true};
		{"NPC","NPC",false};
		{"Player","Player",false};
		{"Player","NPC",false};
		{"Player","Map",true};
		{"Wheel","NPC",false};

	};
	CharacterStats = {
		MaxStamina = 100;
		CurrentStamina = 100;
		Sprinting = false;
		walkPenalty = 0;
		offsetSpeed = 0;
		MaxOxygen = 1000;
		Oxygen = 1000;
		walkSpeedMult = 1;
		Stance = "Stand";
		PrevStance = "Stand";
		Animation = "None";
	};
};