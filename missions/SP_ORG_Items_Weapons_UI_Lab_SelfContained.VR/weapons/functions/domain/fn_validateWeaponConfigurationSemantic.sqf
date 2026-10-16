params [["_value",false]];
private _valid = [_value] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponConfigurationStructural;
if !(_valid get "success") exitWith {_valid};
private _class = _value get "weaponClass";
private _cfg = configFile >> "CfgWeapons" >> _class;
if !(isClass _cfg && {getNumber (_cfg >> "type") in [1,2,4]}) exitWith {[false,"WEAPONS_CLASS_INVALID","Expected rifle, handgun or launcher in CfgWeapons."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
// UC-001-B: semantic validation shares the catalog's four-slot authority.
private _resolved=[_class] call ServoPeregrino_Organizador_Weapons_fnc_resolveAttachmentCompatibility;
if !(_resolved getOrDefault ["success",false]) exitWith {_resolved};
private _slots=(_resolved get "data") getOrDefault ["slots",createHashMap];
private _errors=[];
{
 private _field=_x;
 private _item=toLowerANSI (_value get _field);
 private _allowed=(_slots getOrDefault [_field,[]]) apply {toLowerANSI _x};
 if (_item isNotEqualTo "" && {!(_item in _allowed)}) then {
  _errors pushBack _field;
  diag_log format ["[SP_ORG] [WEAPONS] [COMPAT_REJECT] weapon=%1 field=%2 item=%3 reason=NOT_IN_SLOT_AWARE_ENGINE_CBA_SOURCES",_class,_field,_item];
 };
} forEach ["muzzle","pointer","optic","bipod"];
[_errors isEqualTo [],if (_errors isEqualTo []) then {"WEAPONS_CONFIGURATION_SEMANTIC_VALID"} else {"WEAPONS_CONFIGURATION_INCOMPATIBLE"},
 "Four-slot logical attachment policy uses the same resolver as the catalog; D2 physical validation remains authoritative.",
 createHashMapFromArray [["invalidFields",_errors]]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
