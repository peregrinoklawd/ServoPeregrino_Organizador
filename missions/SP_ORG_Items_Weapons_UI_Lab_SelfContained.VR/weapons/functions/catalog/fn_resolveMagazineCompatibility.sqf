#include "..\..\script_version.hpp"
// UC-001-C R1: authoritative magazine resolver, mission-first, read-only.
// Engine compatibleMagazines is the final logical source. CfgMagazineWells
// is inspected for provenance and mismatches, NOT blindly unioned.
// Type 4 family union preserves the previously approved launcher baseWeapon
// variant behavior. No profile, inventory, or physical D2 mutation.
params [["_weaponClass","",[""]]];
private _cfg=configFile >> "CfgWeapons" >> _weaponClass;
if (_weaponClass isEqualTo "" || {!isClass _cfg} || {!(getNumber (_cfg >> "type") in [1,2,4])}) exitWith {
 [false,"WEAPONS_MAG_RESOLVER_INVALID_WEAPON","An infantry rifle, handgun or launcher is required."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _weapon=configName _cfg;
private _type=getNumber (_cfg >> "type");
private _cacheVar="SP_ORG_Weapons_MagazineCompatibilityCache_UC001C_R1";
private _cache=missionNamespace getVariable [_cacheVar,createHashMap];
private _key=toLowerANSI _weapon;
private _cached=_cache getOrDefault [_key,createHashMap];
if (count _cached>0) exitWith {
 [true,"WEAPONS_MAG_COMPATIBILITY_RESOLVED","Magazine compatibility loaded from mission config cache.",
 [_cached] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy
 ] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _magRoot=configFile >> "CfgMagazines";
private _weaponRoot=configFile >> "CfgWeapons";
private _normalize={
 params ["_values"];
 private _seen=createHashMap;
 private _out=[];
 {
  if (_x isEqualType "" && {_x isNotEqualTo ""}) then {
   private _itemCfg=_magRoot >> _x;
   if (isClass _itemCfg && {getNumber (_itemCfg >> "scope") >= 2}) then {
    private _canonical=configName _itemCfg;
    private _id=toLowerANSI _canonical;
    if !(_seen getOrDefault [_id,false]) then {
     _seen set [_id,true];
     _out pushBack _canonical;
    };
   };
  };
 } forEach _values;
 _out sort true;
 _out
};
private _canonicalizeWeapons={
 params ["_values"];
 private _out=[];
 private _seen=createHashMap;
 {
  private _candidate=_weaponRoot >> _x;
  if (isClass _candidate) then {
   private _name=configName _candidate;
   private _id=toLowerANSI _name;
   if !(_seen getOrDefault [_id,false]) then {
    _seen set [_id,true];
    _out pushBack _name;
   };
  };
 } forEach _values;
 _out sort true;
 _out
};
private _engineAll=[compatibleMagazines _weapon] call _normalize;
private _all=+_engineAll;
private _magazineSource="ENGINE_COMPATIBLE_COMMANDS";
private _secondaryClasses=[];
private _secondaryMags=[];
private _secondaryAllKnown=[];
if (_type isEqualTo 4) then {
 private _base=getText (_cfg >> "baseWeapon");
 if (_base isEqualTo "") then {_base=_weapon};
 private _baseLower=toLowerANSI _base;
 private _candidates="getNumber (_x >> 'type') == 4" configClasses _weaponRoot;
 {
  private _candidateClass=configName _x;
  private _candidateBase=getText (_x >> "baseWeapon");
  if (_candidateBase isEqualTo "") then {_candidateBase=_candidateClass};
  if ((toLowerANSI _candidateBase) isEqualTo _baseLower) then {
   _secondaryClasses pushBackUnique _candidateClass;
   _secondaryMags append (compatibleMagazines _candidateClass);
   // Historical R5 branch fallback for hidden READY/USED launcher variants.
   // BIS helper is obsolete for general use; preserve only for this niche.
   _secondaryMags append ([_candidateClass,false] call BIS_fnc_compatibleMagazines);
  };
 } forEach _candidates;
 _secondaryClasses=[_secondaryClasses] call _canonicalizeWeapons;
 // Preserve historical R5 variant metadata (known config magazines can
 // include private runtime classes); only public classes enter catalog options.
 private _seenSecondary=createHashMap;
 {
  private _mCfg=_magRoot >> _x;
  if (isClass _mCfg) then {
   private _canonical=configName _mCfg;
   private _identity=toLowerANSI _canonical;
   if !(_seenSecondary getOrDefault [_identity,false]) then {
    _seenSecondary set [_identity,true];
    _secondaryAllKnown pushBack _canonical;
   };
  };
 } forEach _secondaryMags;
 _secondaryAllKnown sort true;
 _secondaryMags=[_secondaryMags] call _normalize;
 private _before=count _all;
 _all append _secondaryMags;
 _all=[_all] call _normalize;
 if (count _all>_before) then {
  _magazineSource="ENGINE_COMMANDS_PLUS_BASEWEAPON_RUNTIME_VARIANTS";
 };
};
private _muzzles=getArray (_cfg >> "muzzles");
if (_muzzles isEqualTo []) then {_muzzles=["this"]};
private _byMuzzle=createHashMap;
private _wellByMuzzle=createHashMap;
private _sourceByMuzzle=createHashMap;
{
 private _muzzle=_x;
 private _engineForMuzzle=[compatibleMagazines [_weapon,_muzzle]] call _normalize;
 private _resolved=+_engineForMuzzle;
 if (_type isEqualTo 4 && {count _muzzles isEqualTo 1} && {_muzzle isEqualTo "this"}) then {
  _resolved append _all;
  _resolved=[_resolved] call _normalize;
 };
 _byMuzzle set [_muzzle,_resolved];
 // Magazine wells are configured per actual muzzle (or weapon for "this").
 private _muzzleCfg=if (_muzzle isEqualTo "this") then {_cfg} else {_cfg >> _muzzle};
 private _wells=if (isClass _muzzleCfg) then {getArray (_muzzleCfg >> "magazineWell")} else {[]};
 private _wellRaw=[];
 {
  private _wellCfg=configFile >> "CfgMagazineWells" >> _x;
  if (isClass _wellCfg) then {
   {
    _wellRaw append (getArray _x);
   } forEach (configProperties [_wellCfg,"isArray _x",true]);
  };
 } forEach _wells;
 private _wellPublic=[_wellRaw] call _normalize;
 // The engine is the loading authority. A magwell declaration alone never
 // licenses an incompatible or hidden class, even if a mod declared it.
 private _engineLowers=_engineForMuzzle apply {toLowerANSI _x};
 private _wellOnly=_wellPublic select {!((toLowerANSI _x) in _engineLowers)};
 _wellByMuzzle set [_muzzle,_wells];
 _sourceByMuzzle set [_muzzle,createHashMapFromArray [
  ["muzzle",_muzzle],["engineCount",count _engineForMuzzle],
  ["resolvedCount",count _resolved],["magazineWells",+_wells],
  ["magwellPublicCount",count _wellPublic],["magwellNotInEngine",_wellOnly],
  ["magwellNotInEngineCount",count _wellOnly],
  ["familyVariantCount",count _secondaryMags],
  ["policy","ENGINE_FIRST_MAGWELL_DIAGNOSTIC_WITH_TYPE4_VARIANTS"]
 ]];
 if (count _wellOnly>0) then {
  private _sample=+_wellOnly;
  _sample resize ((count _sample) min 8);
  diag_log format [
   "[SP_ORG] [WEAPONS] [COMPAT_MAGWELL_DIFF] weapon=%1 muzzle=%2 engine=%3 wellPublic=%4 notEngine=%5 sample=%6 physicalApply=false",
   _weapon,_muzzle,count _engineForMuzzle,count _wellPublic,count _wellOnly,_sample
  ];
 };
} forEach _muzzles;
private _data=createHashMapFromArray [
 ["weaponClass",_weapon],["type",_type],
 ["magazines",_all],["muzzles",_muzzles],
 ["magazinesByMuzzle",_byMuzzle],
 ["magazineWellsByMuzzle",_wellByMuzzle],
 ["sourcesByMuzzle",_sourceByMuzzle],
 ["magazineSource",_magazineSource],
 ["secondaryVariantClasses",_secondaryClasses],
 ["secondaryVariantCount",count _secondaryClasses],
 ["secondaryVariantMagazineCount",count _secondaryAllKnown],
 ["secondaryVariantMagazines",_secondaryAllKnown],
 ["engineMagazines",_engineAll],
 ["resolutionMode","UC001C_R1_ENGINE_MAGWELLS_TYPE4_VARIANTS"],
 ["cacheScope","MISSION_CONFIG"],["physicalAuthority","D2_POSTVALIDATION_AND_ROLLBACK"]
];
_cache set [_key,[_data] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy];
missionNamespace setVariable [_cacheVar,_cache];
diag_log format [
 "[SP_ORG] [WEAPONS] [COMPAT_MAG_RESOLVE] weapon=%1 source=%2 engine=%3 resolved=%4 muzzles=%5 type4Variants=%6 cache=MISS physicalApply=false",
 _weapon,_magazineSource,count _engineAll,count _all,count _muzzles,count _secondaryClasses
];
[true,"WEAPONS_MAG_COMPATIBILITY_RESOLVED","Magazine and well metadata resolved. Engine and D2 remain physical authority.",_data] call ServoPeregrino_Organizador_Nexus_fnc_createResult
