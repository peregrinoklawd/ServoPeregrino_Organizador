#include "..\..\script_version.hpp"
// E1 R4: single compatibility authority for the UnderBarrelSlot.
// CBA may legitimately augment Arma's config query (e.g. modded M-LOK grips).
// No per-addon whitelists. Unknown/hidden CBA entries are not authorized.
// This is DISCOVERY/SEMANTIC eligibility, not a physical-application guarantee.
// 0.7-D2 keeps exact post-validation and verified rollback unchanged.
params [["_weaponClass","",[""]]];
private _weaponCfg=configFile >> "CfgWeapons" >> _weaponClass;
if (_weaponClass isEqualTo "" || {!isClass _weaponCfg}) exitWith {
 [false,"WEAPONS_UNDERBARREL_WEAPON_INVALID","Expected a registered CfgWeapons class."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _weapon=configName _weaponCfg;
private _root=configFile >> "CfgWeapons";
private _seen=createHashMap;
private _engine=compatibleItems [_weapon,"UnderBarrelSlot"];
private _output=[];
private _add={
 params ["_value",["_requirePublic",false]];
 if !(_value isEqualType "" && {_value isNotEqualTo ""}) exitWith {false};
 private _cfg=_root >> _value;
 if !isClass _cfg exitWith {false};
 if (_requirePublic && {getNumber (_cfg >> "scope") < 2}) exitWith {false};
 private _canonical=configName _cfg;
 private _key=toLowerANSI _canonical;
 if (_seen getOrDefault [_key,false]) exitWith {false};
 _seen set [_key,true];
 _output pushBack _canonical;
 true
};
{[_x,false] call _add} forEach _engine;
private _engineCount=count _output;
private _cbaAvailable=!(isNil "CBA_fnc_compatibleItems");
private _cba=[];
if (_cbaAvailable) then {
 _cba=[_weapon,"bipod"] call CBA_fnc_compatibleItems;
 if !(_cba isEqualType []) then {_cba=[]};
};
private _added=[];
{
 private _entry=_x;
 if ([_entry,true] call _add) then {_added pushBack (configName (_root >> _entry))};
} forEach _cba;
_output sort true;
[true,"WEAPONS_UNDERBARREL_COMPATIBILITY_DISCOVERED","Engine and optional CBA underbarrel compatibility resolved with canonical class validation.",createHashMapFromArray [
 ["weaponClass",_weapon],["items",_output],["engineCount",_engineCount],
 ["cbaAvailable",_cbaAvailable],["cbaCount",count _cba],
 ["cbaAdded",_added],["cbaAddedCount",count _added],
 ["source",if (count _added>0) then {"ENGINE_PLUS_CBA_UNDERBARREL"} else {"ENGINE_UNDERBARREL"}]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
