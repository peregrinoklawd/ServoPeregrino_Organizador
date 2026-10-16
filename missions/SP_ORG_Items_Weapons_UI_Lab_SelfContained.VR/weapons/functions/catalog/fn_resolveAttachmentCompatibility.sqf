#include "..\..\script_version.hpp"
// UC-001-B R1: one source policy for every WeaponConfiguration attachment field.
// Engine compatibility + public, validated CBA slot-specific augmentations.
// This is logical eligibility only: D2 physical postvalidation and rollback
// remain the final authority. Cached for this mission's immutable addon config.
params [["_weaponClass","",[""]]];
private _weaponCfg=configFile >> "CfgWeapons" >> _weaponClass;
if (_weaponClass isEqualTo "" || {!isClass _weaponCfg} || {!(getNumber (_weaponCfg >> "type") in [1,2,4])}) exitWith {
 [false,"WEAPONS_ATTACH_RESOLVER_INVALID_WEAPON","A registered rifle, handgun or launcher is required."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _weapon=configName _weaponCfg;
private _key=toLowerANSI _weapon;
private _cacheVar="SP_ORG_Weapons_AttachmentCompatibilityCache_UC001B_R1";
private _cache=missionNamespace getVariable [_cacheVar,createHashMap];
private _cached=_cache getOrDefault [_key,createHashMap];
if (count _cached>0) exitWith {
 [true,"WEAPONS_ATTACH_COMPATIBILITY_RESOLVED","Attachment source policy loaded from this mission's config cache.",
  [_cached] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy
 ] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _root=configFile >> "CfgWeapons";
private _cbaAvailable=!(isNil "CBA_fnc_compatibleItems");
private _defs=[
 ["muzzle","MuzzleSlot","muzzle"],
 ["pointer","PointerSlot","pointer"],
 ["optic","CowsSlot","optic"],
 ["bipod","UnderBarrelSlot","bipod"]
];
private _slots=createHashMap;
private _sources=createHashMap;
private _allAdded=0;
{
 _x params ["_field","_engineSlot","_cbaType"];
 private _seen=createHashMap;
 private _out=[];
 private _normalizeAdd={
  params ["_name",["_mustBePublic",false]];
  if !(_name isEqualType "" && {_name isNotEqualTo ""}) exitWith {false};
  private _cfg=_root >> _name;
  if !isClass _cfg exitWith {false};
  if (_mustBePublic && {getNumber (_cfg >> "scope")<2}) exitWith {false};
  private _canonical=configName _cfg;
  private _lower=toLowerANSI _canonical;
  if (_seen getOrDefault [_lower,false]) exitWith {false};
  _seen set [_lower,true];
  _out pushBack _canonical;
  true
 };
 private _engine=compatibleItems [_weapon,_engineSlot];
 if !(_engine isEqualType []) then {_engine=[]};
 {[_x,false] call _normalizeAdd} forEach _engine;
 private _engineCount=count _out;
 private _cba=[];
 if (_cbaAvailable) then {
  _cba=[_weapon,_cbaType] call CBA_fnc_compatibleItems;
  if !(_cba isEqualType []) then {_cba=[]};
 };
 private _added=[];
 {
  private _candidate=_x;
  if ([_candidate,true] call _normalizeAdd) then {
   _added pushBack (configName (_root >> _candidate));
  };
 } forEach _cba;
 _out sort true;
 _allAdded=_allAdded+count _added;
 private _source=if (count _added>0) then {"ENGINE_PLUS_CBA"} else {"ENGINE"};
 private _sourceData=createHashMapFromArray [
  ["field",_field],["engineSlot",_engineSlot],["cbaFilter",_cbaType],
  ["source",_source],["engineCount",_engineCount],
  ["cbaAvailable",_cbaAvailable],["cbaCount",count _cba],
  ["cbaAdded",_added],["cbaAddedCount",count _added],
  ["candidateCount",count _out],
  ["resolutionMode","ENGINE_PLUS_PUBLIC_CBA_SLOT_SPECIFIC"]
 ];
 _slots set [_field,_out];
 _sources set [_field,_sourceData];
 if (count _added>0) then {
  private _sample=+_added;
  _sample resize ((count _sample) min 12);
  diag_log format [
   "[SP_ORG] [WEAPONS] [COMPAT_SOURCE_DIFF] weapon=%1 field=%2 engine=%3 cbaTotal=%4 publicCbaAdded=%5 cbaOnlySample=%6",
   _weapon,_field,_engineCount,count _cba,count _added,_sample
  ];
 };
} forEach _defs;
private _data=createHashMapFromArray [
 ["weaponClass",_weapon],
 ["slots",_slots],
 ["sourcesBySlot",_sources],
 ["cbaAvailable",_cbaAvailable],
 ["cbaAddedTotal",_allAdded],
 ["resolutionMode","UC001B_R1_ENGINE_PLUS_PUBLIC_CBA"],
 ["cacheScope","MISSION_CONFIG"],
 ["physicalAuthority","D2_POSTVALIDATION_AND_ROLLBACK"]
];
_cache set [_key,[_data] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy];
missionNamespace setVariable [_cacheVar,_cache];
diag_log format [
 "[SP_ORG] [WEAPONS] [COMPAT_RESOLVE] weapon=%1 cbaPresent=%2 added=%3 muzzle=%4 pointer=%5 optic=%6 bipod=%7 cache=MISS physicalApply=false",
 _weapon,_cbaAvailable,_allAdded,
 count (_slots get "muzzle"),count (_slots get "pointer"),
 count (_slots get "optic"),count (_slots get "bipod")
];
[true,"WEAPONS_ATTACH_COMPATIBILITY_RESOLVED","Arma and public CBA source policy resolved for four attachment fields.",_data] call ServoPeregrino_Organizador_Nexus_fnc_createResult
