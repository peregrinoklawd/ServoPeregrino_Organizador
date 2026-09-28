params [["_value",false]];
private _valid = [_value] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponConfigurationStructural;
if !(_valid get "success") exitWith {_valid};
private _copy = [_value] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
// Classnames are case-insensitive; canonical lowercase also stabilizes fingerprints.
{_copy set [_x,toLowerANSI (_copy get _x)]} forEach ["weaponClass","muzzle","pointer","optic","bipod"];
{
 private _mag = _copy get _x;
 if !(_mag isEqualTo []) then {_mag set [0,toLowerANSI (_mag select 0)]};
} forEach ["primaryMagazine","secondaryMagazine"];
[true,"WEAPONS_CONFIGURATION_NORMALIZED","Candidate configuration.",createHashMapFromArray [["configuration",_copy]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
