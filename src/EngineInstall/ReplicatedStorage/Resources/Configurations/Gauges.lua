return {

    --[[ 
    Gauges (or Cartridge Groups) are tables that contain necessary modifications to the original cartridge as well as a list of cartridge types that 
    are linked to it.
    ]]--
    --[[ Examples:

	["12Gauge"] = {
		Velocity = 150;
		Range = 300;
		Color = BrickColor.new("Baby blue");
		Acceleration = workspace.Gravity * (1/6);
		Length = 1/6;
		ShotAmount = 12;
		Damage = NumberRange.new(100/12,100/6);
		Penetration = 0.1;
		Density = 0.25;
		GaugeTypes = {
			"No. 00 Buckshot";
			"2 3/4 Flechette";
			"Brenneke Slug";
			"No.6 Birdshot";
			"2 3/4 Armor Piercing Sabot";
			"Dragon's Breath";
			"No.000 Buckshot";
		}
	};
	["7.62x51mm"] = {
		GaugeTypes = {
			"7.62x51mmRemigage";
			"7.62x51mmCETME";

		};
	};

    ]]--
}