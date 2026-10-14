#include "..\..\script_version.hpp"
// UC-001-A: laboratory-only SOURCE INVENTORY, never a production compatibility resolver.
// Read-only: no setUnitLoadout, no dummy, no inventory/repository mutation.
// Run on an equipped, local unit; caller may repeat for PRIMARY/HANDGUN/SECONDARY.
params [["_unit",objNull,[objNull]],["_slot","PRIMARY",[""]]];
private _slotU=toUpperANSI _slot;
if (
 isNull _unit || {!local _unit} || {!(_unit isKindOf "CAManBase")}
 || {!(_slotU in ["PRIMARY","HANDGUN","SECONDARY"])}
) exitWith {
 [false,"WEAPONS_UC001A_INVALID_TARGET","Use a unidade local e um slot de arma valido."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _before=getUnitLoadout _unit;
private _snapshotR=[_unit,_slotU] call ServoPeregrino_Organizador_Weapons_fnc_getEquipmentSlotSnapshot;
if !(_snapshotR getOrDefault ["success",false]) exitWith {_snapshotR};
private _snapshot=(_snapshotR getOrDefault ["data",createHashMap]) getOrDefault ["snapshot",createHashMap];
if !(_snapshot getOrDefault ["equipped",false]) exitWith {
 [true,"WEAPONS_UC001A_EMPTY_SLOT","Nenhuma arma equipada neste slot; omitido.",createHashMapFromArray [
  ["slot",_slotU],["skipped",true],["loadoutUnchanged",_before isEqualTo (getUnitLoadout _unit)]
 ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _cfgData=_snapshot getOrDefault ["configuration",createHashMap];
private _weapon=_cfgData getOrDefault ["weaponClass",""];
private _weaponCfg=configFile >> "CfgWeapons" >> _weapon;
if !isClass _weaponCfg exitWith {
 [false,"WEAPONS_UC001A_UNKNOWN_WEAPON","A arma observada nao possui CfgWeapons valida."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
_weapon=configName _weaponCfg;
private _base=getText (_weaponCfg >> "baseWeapon");
if (_base isEqualTo "") then {_base=_weapon};
private _rootW=configFile >> "CfgWeapons";
private _rootM=configFile >> "CfgMagazines";
private _cbaItemsAvailable=!(isNil "CBA_fnc_compatibleItems");
private _cbaMagAvailable=!(isNil "CBA_fnc_compatibleMagazines");
private _aceArsenalPatch=isClass (configFile >> "CfgPatches" >> "ace_arsenal");
private _aceArsenalApi=!(isNil "ace_arsenal_fnc_initBox");
diag_log format [
 "[SP_ORG] [WEAPONS] [UC001A_CONTEXT] slot=%1 weapon=%2 baseWeapon=%3 aceArsenalPatch=%4 aceArsenalApi=%5 cbaItems=%6 cbaMagazines=%7 aceCompatibilityAuthority=UNVERIFIED",
 _slotU,_weapon,_base,_aceArsenalPatch,_aceArsenalApi,_cbaItemsAvailable,_cbaMagAvailable
];

private _normal={
 params ["_values","_root"];
 private _out=[];private _seen=createHashMap;
 if !(_values isEqualType []) exitWith {_out};
 {
  if (_x isEqualType "" && {_x isNotEqualTo ""}) then {
   private _c=_root >> _x;
   if (isClass _c) then {
    private _canonical=configName _c;
    private _key=toLowerANSI _canonical;
    if !(_seen getOrDefault [_key,false]) then {
     _seen set [_key,true];
     _out pushBack _canonical;
    };
   };
  };
 } forEach _values;
 _out sort true;
 _out
};
private _rows=[];
private _diffTotal=0;
// CBA type filters are defined publicly: muzzle / pointer / optic / bipod.
// BIS_fnc_compatibleItems is NOT queried as per-slot authority.
{
 _x params ["_field","_engineSlot","_cbaFilter"];
 private _engRaw=compatibleItems [_weapon,_engineSlot];
 private _eng=[_engRaw,_rootW] call _normal;
 private _cbaRaw=[];
 if (_cbaItemsAvailable) then {
  _cbaRaw=[_weapon,_cbaFilter] call CBA_fnc_compatibleItems;
  if !(_cbaRaw isEqualType []) then {_cbaRaw=[]};
 };
 private _cba=if (_cbaItemsAvailable) then {[_cbaRaw,_rootW] call _normal} else {[]};
 private _cbaOnly=if (_cbaItemsAvailable) then {_cba-_eng} else {[]};
 private _engOnly=if (_cbaItemsAvailable) then {_eng-_cba} else {[]};
 _diffTotal=_diffTotal+count _cbaOnly+count _engOnly;
 private _sample=+_cbaOnly;
 _sample resize ((count _sample) min 12);
 private _observed=_cfgData getOrDefault [_field,""];
 private _row=createHashMapFromArray [
  ["field",_field],["engineSlot",_engineSlot],["cbaFilter",_cbaFilter],
  ["engineCount",count _eng],["engineRawCount",count _engRaw],
  ["cbaAvailable",_cbaItemsAvailable],["cbaCount",count _cba],
  ["cbaRawCount",count _cbaRaw],["cbaOnly",count _cbaOnly],
  ["engineOnly",count _engOnly],["cbaOnlySample",_sample],
  ["observedClass",_observed],
  ["observedByEngine",_observed isEqualTo "" || {_observed in _eng}],
  ["observedByCBA",_cbaItemsAvailable && {_observed isEqualTo "" || {_observed in _cba}}]
 ];
 _rows pushBack _row;
 diag_log format [
  "[SP_ORG] [WEAPONS] [UC001A_SOURCE] slot=%1 weapon=%2 field=%3 engineSlot=%4 engine=%5 cbaPresent=%6 cba=%7 cbaOnly=%8 engineOnly=%9 cbaOnlySample=%10 observed=%11",
  _slotU,_weapon,_field,_engineSlot,count _eng,_cbaItemsAvailable,count _cba,count _cbaOnly,count _engOnly,_sample,_observed
 ];
} forEach [
 ["muzzle","MuzzleSlot","muzzle"],
 ["pointer","PointerSlot","pointer"],
 ["optic","CowsSlot","optic"],
 ["bipod","UnderBarrelSlot","bipod"]
];
// Magazine comparison is diagnostic only. CBA accepts weapon + allMuzzles BOOL.
// For muzzles with an actual config class, CBA also accepts a muzzle CONFIG.
private _muzzles=getArray (_weaponCfg >> "muzzles");
if ((count _muzzles) isEqualTo 0) then {_muzzles=["this"]};
private _allEng=[compatibleMagazines _weapon,_rootM] call _normal;
private _allCba=[];
if (_cbaMagAvailable) then {
 private _raw=[_weapon,true] call CBA_fnc_compatibleMagazines;
 _allCba=[_raw,_rootM] call _normal;
};
private _cbaOnlyAll=if (_cbaMagAvailable) then {_allCba-_allEng} else {[]};
private _engOnlyAll=if (_cbaMagAvailable) then {_allEng-_allCba} else {[]};
_diffTotal=_diffTotal+count _cbaOnlyAll+count _engOnlyAll;
private _magRows=[];
{
 private _muzzle=_x;
 private _eng=[compatibleMagazines [_weapon,_muzzle],_rootM] call _normal;
 private _muzzleCfg=if (_muzzle isEqualTo "this") then {_weaponCfg} else {_weaponCfg >> _muzzle};
 private _wells=getArray (_muzzleCfg >> "magazineWell");
 private _cba=[];
 private _probe="UNAVAILABLE";
 if (_cbaMagAvailable && {isClass _muzzleCfg}) then {
  private _rawM=[_muzzleCfg] call CBA_fnc_compatibleMagazines;
  _cba=[_rawM,_rootM] call _normal;
  _probe="CBA_CONFIG_MUZZLE";
 };
 private _sample=+_cba;
 _sample=_sample-_eng;
 _sample resize ((count _sample) min 12);
 private _row=createHashMapFromArray [
  ["muzzle",_muzzle],["magazineWells",_wells],["engineCount",count _eng],
  ["cbaCount",count _cba],["cbaProbe",_probe],["cbaOnlySample",_sample]
 ];
 _magRows pushBack _row;
 diag_log format [
  "[SP_ORG] [WEAPONS] [UC001A_MAGAZINE] slot=%1 weapon=%2 muzzle=%3 magWells=%4 engine=%5 cba=%6 cbaProbe=%7 cbaOnlySample=%8",
  _slotU,_weapon,_muzzle,_wells,count _eng,count _cba,_probe,_sample
 ];
} forEach _muzzles;
private _allSample=+_cbaOnlyAll;
_allSample resize ((count _allSample) min 12);
private _unchanged=_before isEqualTo (getUnitLoadout _unit);
diag_log format [
 "[SP_ORG] [WEAPONS] [UC001A_SUMMARY] slot=%1 weapon=%2 baseWeapon=%3 cbaItems=%4 cbaMagazines=%5 engineMags=%6 cbaMags=%7 cbaOnlyMags=%8 engineOnlyMags=%9 cbaOnlyMagSample=%10 sourceDiffCount=%11 loadoutUnchanged=%12",
 _slotU,_weapon,_base,_cbaItemsAvailable,_cbaMagAvailable,count _allEng,count _allCba,count _cbaOnlyAll,count _engOnlyAll,_allSample,_diffTotal,_unchanged
];
[_unchanged,"WEAPONS_UC001A_SOURCE_AUDIT_COMPLETE","Auditoria por fontes concluida. Nenhuma mutacao do inventario.",createHashMapFromArray [
 ["slot",_slotU],["weaponClass",_weapon],["baseWeapon",_base],
 ["slots",_rows],["muzzles",_magRows],
 ["cbaItemsAvailable",_cbaItemsAvailable],["cbaMagazinesAvailable",_cbaMagAvailable],
 ["aceArsenalPatchDetected",_aceArsenalPatch],["aceArsenalPublicApiDetected",_aceArsenalApi],
 ["engineMagazineCount",count _allEng],["cbaMagazineCount",count _allCba],
 ["cbaOnlyMagazineSample",_allSample],["sourceDiffCount",_diffTotal],
 ["loadoutUnchanged",_unchanged],["skipped",false],
 ["mode","DIAGNOSTIC_ONLY_NOT_COMPATIBILITY_AUTHORITY"]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
