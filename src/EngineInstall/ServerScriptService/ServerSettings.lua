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
};