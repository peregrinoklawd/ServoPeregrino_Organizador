#include "..\..\script_version.hpp"
// UC-001-C R1 cumulative auto-check. D2/R5/B2 runners retain their own
// isolated fixtures; new C checks are logical/read-only only.
if (!canSuspend || {!isServer} || {isRemoteExecuted} || {!(missionNamespace getVariable ["SP_ORG_Weapons_LabEnabled",false])}) exitWith {
 [false,"WEAPONS_UC001C_TEST_LAB_ONLY","Run from local mission-first lab."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if (!isNull (findDisplay SP_ORG_WEAPONS_UI_DISPLAY_IDD)) exitWith {
 [false,"WEAPONS_UC001C_UI_MUST_BE_CLOSED","Close the Weapons UI before cumulative test."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _b=[] call ServoPeregrino_Organizador_Weapons_fnc_runUC001BTests;
private _bd=_b getOrDefault ["data",createHashMap];
private _checks=[];
private _assert={
 params ["_label","_pass"];
 _checks pushBack [_label,_pass];
 diag_log format ["[SP_ORG] [WEAPONS] [AUTO_TEST] mode=MISSION_FIRST_UC001C_R1 %1 | %2",if (_pass) then {"PASS"} else {"FAIL"},_label];
};
["C inherited B R2 1518 regression intact",
 _b getOrDefault ["success",false] && {(_bd getOrDefault ["passed",0]) isEqualTo 1518}
 && {(_bd getOrDefault ["failed",1]) isEqualTo 0}
] call _assert;
private _oldLoadout=getUnitLoadout player;
private _kitsR=[] call ServoPeregrino_Organizador_Weapons_fnc_listWeaponKits;
private _oldKits=if (_kitsR getOrDefault ["success",false]) then {((_kitsR get "data") get "kits")} else {[]};
private _magRoot=configFile >> "CfgMagazines";
private _samples=["arifle_MX_F","arifle_MX_GL_F","hgun_P07_F","launch_NLAW_F"];
{
 private _weapon=_x;
 private _r=[_weapon] call ServoPeregrino_Organizador_Weapons_fnc_resolveMagazineCompatibility;
 private _d=_r getOrDefault ["data",createHashMap];
 private _catalogR=[_weapon] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponCompatibility;
 private _catalog=_catalogR getOrDefault ["data",createHashMap];
 private _mags=_d getOrDefault ["magazines",[]];
 private _muzzles=_d getOrDefault ["muzzles",[]];
 private _by=_d getOrDefault ["magazinesByMuzzle",createHashMap];
 private _wells=_d getOrDefault ["magazineWellsByMuzzle",createHashMap];
 private _sources=_d getOrDefault ["sourcesByMuzzle",createHashMap];
 private _again=[_weapon] call ServoPeregrino_Organizador_Weapons_fnc_resolveMagazineCompatibility;
 private _engine=compatibleMagazines _weapon;
 private _resolvedCI=_mags apply {toLowerANSI _x};
 private _validPublic=_mags findIf {
  private _cfg=_magRoot >> _x;
  !(isClass _cfg) || {getNumber (_cfg >> "scope")<2} || {(configName _cfg) isNotEqualTo _x}
 } < 0;
 private _keyset=createHashMap;
 private _noDuplicates=true;
 {
  private _key=toLowerANSI _x;
  if (_keyset getOrDefault [_key,false]) then {_noDuplicates=false};
  _keyset set [_key,true];
 } forEach _mags;
 private _enginePublic=_engine select {
  isClass (_magRoot >> _x) && {getNumber ((_magRoot >> _x) >> "scope")>=2}
 };
 private _muzzleAllRecognized=true;
 private _wellsDiagnostic=true;
 {
  private _muzzle=_x;
  private _muzzlePublic=(compatibleMagazines [_weapon,_muzzle]) select {
   isClass (_magRoot >> _x) && {getNumber ((_magRoot >> _x) >> "scope")>=2}
  };
  private _resolved=_by getOrDefault [_muzzle,[]];
  private _ci=_resolved apply {toLowerANSI _x};
  if (_muzzlePublic findIf {!((toLowerANSI _x) in _ci)} >= 0) then {_muzzleAllRecognized=false};
  private _meta=_sources getOrDefault [_muzzle,createHashMap];
  if ((_meta getOrDefault ["policy",""]) isNotEqualTo "ENGINE_FIRST_MAGWELL_DIAGNOSTIC_WITH_TYPE4_VARIANTS") then {_wellsDiagnostic=false};
  if (_resolved findIf {!((toLowerANSI _x) in _resolvedCI)} >= 0) then {_wellsDiagnostic=false};
 } forEach _muzzles;
 private _configR=[_weapon] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponConfiguration;
 private _config=(_configR getOrDefault ["data",createHashMap]) getOrDefault ["configuration",createHashMap];
 private _magCandidate=if (count _mags>0) then {_mags select 0} else {""};
 private _recipeR=if (_configR getOrDefault ["success",false]) then {
  [_config,_magCandidate] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponRecipe
 } else {_configR};
 private _selectorR=[_weapon] call ServoPeregrino_Organizador_Weapons_fnc_buildCompatibilitySelectorModel;
 private _selectorD=_selectorR getOrDefault ["data",createHashMap];
 private _selector=(_selectorD getOrDefault ["model",createHashMap]) getOrDefault ["selectors",createHashMap];
 private _selectorMags=_selector getOrDefault ["magazineClass",createHashMap];
 ["C resolve "+_weapon,_r getOrDefault ["success",false]] call _assert;
 ["C catalog "+_weapon,_catalogR getOrDefault ["success",false]] call _assert;
 ["C catalog magazines parity "+_weapon,(_catalog getOrDefault ["magazines",[]]) isEqualTo _mags] call _assert;
 ["C catalog muzzles parity "+_weapon,(_catalog getOrDefault ["muzzles",[]]) isEqualTo _muzzles] call _assert;
 ["C catalog magazines by muzzle parity "+_weapon,(_catalog getOrDefault ["magazinesByMuzzle",createHashMap]) isEqualTo _by] call _assert;
 ["C source marker preserved "+_weapon,(_catalog getOrDefault ["source",""]) isEqualTo "ENGINE_COMPATIBLE_COMMANDS"] call _assert;
 ["C magazine source parity "+_weapon,(_catalog getOrDefault ["magazineSource",""]) isEqualTo (_d getOrDefault ["magazineSource",""])] call _assert;
 ["C magazine well metadata per muzzle "+_weapon,count (keys _wells) isEqualTo count _muzzles] call _assert;
 ["C magazine source metadata per muzzle "+_weapon,count (keys _sources) isEqualTo count _muzzles] call _assert;
 ["C known engine public magazines present "+_weapon,(_enginePublic findIf {!((toLowerANSI _x) in _resolvedCI)})<0] call _assert;
 ["C only public canonical magazine classes "+_weapon,_validPublic] call _assert;
 ["C magazine names deduplicated "+_weapon,_noDuplicates] call _assert;
 ["C muzzle scoped parity and no leak "+_weapon,_muzzleAllRecognized && {_wellsDiagnostic}] call _assert;
 ["C compatible recipe accepted "+_weapon,_recipeR getOrDefault ["success",false]] call _assert;
 ["C UI selector magazine parity "+_weapon,_selectorR getOrDefault ["success",false] && {(_selectorMags getOrDefault ["optionCount",0]) isEqualTo (count _mags+1)}] call _assert;
 ["C stable cache "+_weapon,_again getOrDefault ["success",false] && {(_again getOrDefault ["data",createHashMap]) isEqualTo _d}] call _assert;
} forEach _samples;
private _glR=["arifle_MX_GL_F"] call ServoPeregrino_Organizador_Weapons_fnc_resolveMagazineCompatibility;
private _glD=_glR getOrDefault ["data",createHashMap];
private _glMuzzles=_glD getOrDefault ["muzzles",[]];
["C GL distinct muzzles detected",_glR getOrDefault ["success",false] && {count _glMuzzles>1} && {"this" in _glMuzzles}] call _assert;
private _nlawR=["launch_NLAW_F"] call ServoPeregrino_Organizador_Weapons_fnc_resolveMagazineCompatibility;
private _nlawD=_nlawR getOrDefault ["data",createHashMap];
["C type4 baseWeapon family metadata emitted",_nlawR getOrDefault ["success",false] && {count (_nlawD getOrDefault ["secondaryVariantClasses",[]])>0}] call _assert;
private _unknown=["SPORG_UC001C_UNKNOWN_WEAPON"] call ServoPeregrino_Organizador_Weapons_fnc_resolveMagazineCompatibility;
["C unknown class fail closed",!(_unknown getOrDefault ["success",true])] call _assert;
private _empty=[""] call ServoPeregrino_Organizador_Weapons_fnc_resolveMagazineCompatibility;
["C empty class fail closed",!(_empty getOrDefault ["success",true])] call _assert;
private _kitsAfter=[] call ServoPeregrino_Organizador_Weapons_fnc_listWeaponKits;
["C player WeaponKits unchanged",_kitsAfter getOrDefault ["success",false] && {((_kitsAfter get "data") get "kits") isEqualTo _oldKits}] call _assert;
["C physical player loadout unchanged",getUnitLoadout player isEqualTo _oldLoadout] call _assert;
private _passedNew={_x select 1} count _checks;
private _failedNew=count _checks-_passedNew;
private _passed=(_bd getOrDefault ["passed",0])+_passedNew;
private _failed=(_bd getOrDefault ["failed",0])+_failedNew;
private _blocked=_bd getOrDefault ["blocked",0];
private _total=(_bd getOrDefault ["total",0])+count _checks;
private _expected=1589; // B R2 1518 + 71 UC-001-C assertions
diag_log format ["[SP_ORG] [WEAPONS] [AUTO_TEST_SUMMARY] mode=MISSION_FIRST_UC001C_R1 passed=%1 failed=%2 blocked=%3 total=%4 expected=%5 new=%6",_passed,_failed,_blocked,_total,_expected,count _checks];
hint format ["UC-001-C R1: %1/%2 PASS, %3 FAIL, %4 BLOCKED. Envie o RPT.",_passed,_total,_failed,_blocked];
[_b getOrDefault ["success",false] && {_failed isEqualTo 0} && {_blocked isEqualTo 0} && {_total isEqualTo _expected},
 "WEAPONS_UC001C_R1_AUTO_TEST_COMPLETE","Cumulative B R2 plus magazine/magwell/variant policy tests. D2 unchanged.",
 createHashMapFromArray [
  ["passed",_passed],["failed",_failed],["blocked",_blocked],["total",_total],["expected",_expected],
  ["newChecks",count _checks],["checks",_checks],["manual","PENDING"]
 ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
