return {
	VictoryMsgs = {
		[game.Teams["Red Team"]] = "The Red Team";
		[game.Teams["Blue Team"]] = "The Blue Team";

	};
	TeamTypes = {
		Conventional = {"Red Team","Blue Team"};
	};
    OppositeAlliances = {
        ["BluFor"] = "OpFor";
    };
    Nemeses = {
            [game.Teams["Blue Team"]] = game.Teams["Red Team"];
            [game.Teams["Red Team"]] = game.Teams["Blue Team"];
    };
	TeamInfos = {
		["Blue Team"] = {
			Name = "Blue Team";
			ShortName = "Blue";
			Color = Color3.fromRGB(119, 158, 203);
			FlagName = "BlueFlag";
		};
		["Red Team"] = {
			Name = "Red Team";
			ShortName = "Red";
			Color = Color3.fromRGB(185, 105, 97);
			FlagName = "RedFlag";
		};
	};
	SpawnCodes = {
		["RT"] = game.Teams["Red Team"];
		["BT"] = game.Teams["Blue Team"];

	};
	FactionNouns = {
		[game.Teams["Red Team"]] = "RED TEAM";
		[game.Teams["Blue Team"]] = "BLUE TEAM";

	};
	OwnerMsgs = {
		[game.Teams["Red Team"]] = {"The Red Team";game.Teams["Red Team"].TeamColor};
		[game.Teams["Blue Team"]] = {"The Blue Team";game.Teams["Blue Team"].TeamColor};

	};
}