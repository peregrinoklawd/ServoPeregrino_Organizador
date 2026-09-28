params [["_value",false]];
private _valid = [_value] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponConfigurationStructural;
if !(_valid get "success") exitWith {_valid};
// Preserve the engine/config representation. Case folding belongs to comparison/fingerprint only.
private _copy = [_value] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
[true,"WEAPONS_CONFIGURATION_NORMALIZED","Candidate configuration; class spelling preserved.",createHashMapFromArray [["configuration",_copy]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
