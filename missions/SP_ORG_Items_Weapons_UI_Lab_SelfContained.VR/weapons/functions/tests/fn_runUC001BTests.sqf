#include "..\..\script_version.hpp"
// Mission-first UC-001-B R1 cumulative test. No new physical mutation.
// The legacy R5 runner uses its own isolated physical fixture and restores state.
if (!canSuspend || {!isServer} || {isRemoteExecuted} || {!(missionNamespace getVariable ["SP_ORG_Weapons_LabEnabled",false])}) exitWith {
 [false,"WEAPONS_UC001B_TEST_LAB_ONLY","Run from the local SP_ORG laboratory mission."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if (!isNull (findDisplay SP_ORG_WEAPONS_UI_DISPLAY_IDD)) exitWith {
 [false,"WEAPONS_UC001B_UI_MUST_BE_CLOSED","Close Weapons UI before running the cumulative test."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _r5=[] call ServoPeregrino_Organizador_Weapons_fnc_runDelivery0_7_ETests;
private _r5Data=_r5 getOrDefault ["data",createHashMap];
private _checks=[];
private _assert={
 params ["_label","_pass"];
 _checks pushBack [_label,_pass];
 diag_log format ["[SP_ORG] [WEAPONS] [AUTO_TEST] mode=MISSION_FIRST_UC001B_R1 %1 | %2",if (_pass) then {"PASS"} else {"FAIL"},_label];
};
["B R5 unchanged cumulative regression",_r5 getOrDefault ["success",false] && {(_r5Data getOrDefault ["passed",0]) isEqualTo 1446} && {(_r5Data getOrDefault ["failed",1]) isEqualTo 0}] call _assert;
private _originalLoadout=getUnitLoadout player;
private _storeR=[] call ServoPeregrino_Organizador_Weapons_fnc_listWeaponKits;
private _originalKits=if (_storeR getOrDefault ["success",false]) then {((_storeR get "data") get "kits")} else {[]};
private _root=configFile >> "CfgWeapons";
private _defs=[
 ["muzzle","MuzzleSlot","muzzle"],
 ["pointer","PointerSlot","pointer"],
 ["optic","CowsSlot","optic"],
 ["bipod","UnderBarrelSlot","bipod"]
];
{
 private _weapon=_x;
 private _r=[_weapon] call ServoPeregrino_Organizador_Weapons_fnc_resolveAttachmentCompatibility;
 private _d=_r getOrDefault ["data",createHashMap];
 private _slots=_d getOrDefault ["slots",createHashMap];
 private _sources=_d getOrDefault ["sourcesBySlot",createHashMap];
 private _catalogR=[_weapon] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponCompatibility;
 private _catalogD=_catalogR getOrDefault ["data",createHashMap];
 private _catalogSlots=_catalogD getOrDefault ["slots",createHashMap];
 private _again=[_weapon] call ServoPeregrino_Organizador_Weapons_fnc_resolveAttachmentCompatibility;
 ["B resolver works "+_weapon,_r getOrDefault ["success",false]] call _assert;
 ["B catalog works "+_weapon,_catalogR getOrDefault ["success",false]] call _assert;
 ["B four field contract "+_weapon,count (keys _slots) isEqualTo 4 && {count (keys _sources) isEqualTo 4}] call _assert;
 ["B session cache deterministic "+_weapon,_again getOrDefault ["success",false] && {(_again getOrDefault ["data",createHashMap]) isEqualTo _d}] call _assert;
 {
  _x params ["_field","_engineSlot","_cbaType"];
  private _items=_slots getOrDefault [_field,[]];
  private _lowers=_items apply {toLowerANSI _x};
  private _eng=compatibleItems [_weapon,_engineSlot];
  private _engKnown=_eng select {isClass (_root >> _x)};
  ["B engine candidates preserved "+_weapon+" "+_field,(_engKnown findIf {!((toLowerANSI _x) in _lowers)})<0] call _assert;
  private _cba=[];
  if !(isNil "CBA_fnc_compatibleItems") then {
   _cba=[_weapon,_cbaType] call CBA_fnc_compatibleItems;
   if !(_cba isEqualType []) then {_cba=[]};
  };
  private _publicCba=_cba select {
   isClass (_root >> _x) && {getNumber ((_root >> _x) >> "scope")>=2}
  };
  ["B public CBA candidates preserved "+_weapon+" "+_field,(_publicCba findIf {!((toLowerANSI _x) in _lowers)})<0] call _assert;
  ["B catalog equals resolver "+_weapon+" "+_field,(_catalogSlots getOrDefault [_field,[]]) isEqualTo _items] call _assert;
  private _baseR=[_weapon] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponConfiguration;
  private _candidate=(_baseR getOrDefault ["data",createHashMap]) getOrDefault ["configuration",createHashMap];
  if (count _items>0) then {_candidate set [_field,_items select 0]};
  private _valid=if (_baseR getOrDefault ["success",false]) then {
   [_candidate] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponConfigurationSemantic
  } else {_baseR};
  ["B semantic recognizes resolver "+_weapon+" "+_field,_valid getOrDefault ["success",false]] call _assert;
 } forEach _defs;
 private _baseR=[_weapon] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponConfiguration;
 private _invalid=(_baseR getOrDefault ["data",createHashMap]) getOrDefault ["configuration",createHashMap];
 if (count _invalid>0) then {_invalid set ["optic","SPORG_UC001B_NONEXISTENT_OPTIC"]};
 private _v=if (_baseR getOrDefault ["success",false]) then {
  [_invalid] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponConfigurationSemantic
 } else {_baseR};
 ["B unknown optic rejected "+_weapon,!(_v getOrDefault ["success",true])] call _assert;
 ["B legacy R4 bipod parity "+_weapon,(([_weapon] call ServoPeregrino_Organizador_Weapons_fnc_getUnderbarrelCompatibility) getOrDefault ["data",createHashMap]) getOrDefault ["items",[]] isEqualTo (_slots getOrDefault ["bipod",[]])] call _assert;
} forEach ["arifle_MX_F","hgun_P07_F","launch_NLAW_F"];
private _unknown=["SPORG_UC001B_NONEXISTENT_WEAPON"] call ServoPeregrino_Organizador_Weapons_fnc_resolveAttachmentCompatibility;
["B resolver rejects unregistered weapon",!(_unknown getOrDefault ["success",true])] call _assert;
private _kitsAfter=[] call ServoPeregrino_Organizador_Weapons_fnc_listWeaponKits;
["B user kits preserved",_kitsAfter getOrDefault ["success",false] && {((_kitsAfter get "data") get "kits") isEqualTo _originalKits}] call _assert;
["B player physical loadout preserved",(getUnitLoadout player) isEqualTo _originalLoadout] call _assert;
private _passedNew={_x select 1} count _checks;
private _failedNew=count _checks-_passedNew;
private _passed=(_r5Data getOrDefault ["passed",0])+_passedNew;
private _failed=(_r5Data getOrDefault ["failed",0])+_failedNew;
private _total=(_r5Data getOrDefault ["total",0])+count _checks;
private _blocked=_r5Data getOrDefault ["blocked",0];
private _expected=1513;
diag_log format ["[SP_ORG] [WEAPONS] [AUTO_TEST_SUMMARY] mode=MISSION_FIRST_UC001B_R1 passed=%1 failed=%2 blocked=%3 total=%4 expected=%5",_passed,_failed,_blocked,_total,_expected];
hint format ["UC-001-B R1: %1/%2 PASS, %3 FAIL, %4 BLOCKED. Envie o RPT.",_passed,_total,_failed,_blocked];
[_r5 getOrDefault ["success",false] && {_failed isEqualTo 0} && {_blocked isEqualTo 0} && {_total isEqualTo _expected},
 "WEAPONS_UC001B_R1_AUTO_TEST_COMPLETE","Cumulative R5 plus logical attachment policy tests. Physical modded integration requires operator verification.",
 createHashMapFromArray [
  ["passed",_passed],["failed",_failed],["blocked",_blocked],["total",_total],
  ["expected",_expected],["newChecks",count _checks],["checks",_checks],
  ["manual","PENDING"]
 ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
