params [["_value",false]];
private _valid = [_value] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponRecipeStructural;
if !(_valid get "success") exitWith {_valid};

private _normalizedCfg = [_value get "configuration"] call ServoPeregrino_Organizador_Weapons_fnc_normalizeWeaponConfiguration;
if !(_normalizedCfg get "success") exitWith {_normalizedCfg};

private _copy = [_value] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
_copy set ["configuration",(_normalizedCfg get "data") get "configuration"];

// Preserve engine/config spelling. Case folding is only for comparison/fingerprints.
[true,"WEAPONS_RECIPE_NORMALIZED","Candidate recipe normalized without engine mutation.",createHashMapFromArray [
 ["recipe",_copy]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
