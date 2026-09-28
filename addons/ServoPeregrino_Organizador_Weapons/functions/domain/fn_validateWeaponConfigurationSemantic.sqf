params [["_value",false]];
private _valid = [_value] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponConfigurationStructural;
if !(_valid get "success") exitWith {_valid};
private _class = _value get "weaponClass";
private _cfg = configFile >> "CfgWeapons" >> _class;
if !(isClass _cfg && {getNumber (_cfg >> "type") in [1,2,4]}) exitWith {[false,"WEAPONS_CLASS_INVALID","Expected rifle, handgun or launcher in CfgWeapons."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _errors = [];
{
 _x params ["_field","_slot"];
 private _item = toLowerANSI (_value get _field);
 if (_item != "" && {!(_item in ((compatibleItems [_class,_slot]) apply {toLowerANSI _x}))}) then {_errors pushBack _field};
} forEach [["muzzle","MuzzleSlot"],["pointer","PointerSlot"],["optic","CowsSlot"],["bipod","UnderBarrelSlot"]];
private _muzzles = getArray (_cfg >> "muzzles");
private _secondary = _muzzles select {toLowerANSI _x != "this"};
{
 _x params ["_field","_muzzle"];
 private _mag = _value get _field;
 if !(_mag isEqualTo []) then {
  private _name = _mag select 0;
  private _magCfg = configFile >> "CfgMagazines" >> _name;
  if (_muzzle isEqualTo "" || {!isClass _magCfg} || {!((toLowerANSI _name) in ((compatibleMagazines [_class,_muzzle]) apply {toLowerANSI _x}))} || {(_mag select 1) > getNumber (_magCfg >> "count")}) then {_errors pushBack _field};
 };
} forEach [["primaryMagazine","this"],["secondaryMagazine",_secondary param [0,""]]];
[_errors isEqualTo [],if (_errors isEqualTo []) then {"WEAPONS_CONFIGURATION_SEMANTIC_VALID"} else {"WEAPONS_CONFIGURATION_INCOMPATIBLE"},"Engine config compatibility; multi-secondary-muzzle models remain limited.",createHashMapFromArray [["invalidFields",_errors]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
