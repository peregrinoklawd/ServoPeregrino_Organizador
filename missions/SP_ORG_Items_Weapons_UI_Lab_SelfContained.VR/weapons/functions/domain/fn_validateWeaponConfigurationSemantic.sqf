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
 // R4: validate through the SAME authoritative CBA-aware underbarrel source
 // used by the catalog. Never accept a class absent from both sources.
 private _allowed=compatibleItems [_class,_slot];
 if (_field isEqualTo "bipod") then {
  private _underbarrel=[_class] call ServoPeregrino_Organizador_Weapons_fnc_getUnderbarrelCompatibility;
  _allowed=if (_underbarrel getOrDefault ["success",false]) then {((_underbarrel get "data") get "items")} else {[]};
 };
 if (_item != "" && {!(_item in (_allowed apply {toLowerANSI _x}))}) then {_errors pushBack _field};
} forEach [["muzzle","MuzzleSlot"],["pointer","PointerSlot"],["optic","CowsSlot"],["bipod","UnderBarrelSlot"]];
[_errors isEqualTo [],if (_errors isEqualTo []) then {"WEAPONS_CONFIGURATION_SEMANTIC_VALID"} else {"WEAPONS_CONFIGURATION_INCOMPATIBLE"},"Engine attachment compatibility, extended for underbarrel when CBA is present.",createHashMapFromArray [["invalidFields",_errors]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
