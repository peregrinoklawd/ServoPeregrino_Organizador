#include "..\..\script_version.hpp"
if (!isServer || {isRemoteExecuted} || {!(missionNamespace getVariable ["SP_ORG_Weapons_LabEnabled",false])}) exitWith {
 [false,"WEAPONS_TEST_SERVER_LAB_ONLY","Run locally on mission-first lab server/host."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _legacy = [] call ServoPeregrino_Organizador_Weapons_fnc_runDelivery0_6_FR6Tests;
private _legacyData = _legacy getOrDefault ["data",createHashMap];
private _legacyPassed = _legacyData getOrDefault ["passed",0];
private _legacyFailed = _legacyData getOrDefault ["failed",1];
private _legacyObservations = _legacyData getOrDefault ["observations",[]];

private _checks = [];
private _assert = {
 params [
  ["_name","UNNAMED_CHECK",[""]],
  ["_ok",false,[false]]
 ];
 _checks pushBack [_name,_ok];
 diag_log format ["[SP_ORG] [WEAPONS] [AUTO_TEST] mode=MISSION_FIRST_0_7_A %1 | %2",if (_ok) then {"PASS"} else {"FAIL"},_name];
};

["0.6-F R6 frozen baseline remains green",_legacy getOrDefault ["success",false] && {_legacyPassed isEqualTo 594} && {_legacyFailed isEqualTo 0}] call _assert;
["0.7-A createApplicationPlan loaded",!isNil "ServoPeregrino_Organizador_Weapons_fnc_createApplicationPlan"] call _assert;
["0.7-A validateApplicationPlan loaded",!isNil "ServoPeregrino_Organizador_Weapons_fnc_validateApplicationPlan"] call _assert;
["0.7-A captureApplicationSnapshot loaded",!isNil "ServoPeregrino_Organizador_Weapons_fnc_captureApplicationSnapshot"] call _assert;
["0.7-A validateApplicationSnapshot loaded",!isNil "ServoPeregrino_Organizador_Weapons_fnc_validateApplicationSnapshot"] call _assert;
["0.7-A preservation fingerprint loaded",!isNil "ServoPeregrino_Organizador_Weapons_fnc_getApplicationPreservationFingerprint"] call _assert;
["0.7-A simulateApplicationPlan loaded",!isNil "ServoPeregrino_Organizador_Weapons_fnc_simulateApplicationPlan"] call _assert;

private _unit = player;
["0.7-A test unit available",!isNull _unit && {_unit isKindOf "CAManBase"}] call _assert;
if (isNull _unit || {!(_unit isKindOf "CAManBase")}) exitWith {
 [false,"WEAPONS_0_7_A_TEST_TARGET_MISSING","Player unit unavailable for 0.7-A dry-run tests."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _primaryPlan = createHashMap;
private _primarySnapshot = createHashMap;
private _scenarioResults = [];

private _runScenario = {
 params ["_label","_weaponClass","_slot","_magazineClass"];

 private _before = [getUnitLoadout _unit] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 private _cfgResult = [_weaponClass] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponConfiguration;
 [format ["0.7-A %1 configuration prerequisite",_label],_cfgResult getOrDefault ["success",false]] call _assert;
 if !(_cfgResult getOrDefault ["success",false]) exitWith {false};

 private _cfg = (_cfgResult get "data") get "configuration";
 private _recipeResult = [_cfg,_magazineClass] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponRecipe;
 [format ["0.7-A %1 Recipe prerequisite",_label],_recipeResult getOrDefault ["success",false]] call _assert;
 if !(_recipeResult getOrDefault ["success",false]) exitWith {false};

 private _nameResult = [format ["0.7-A Dry Run %1",_label]] call ServoPeregrino_Organizador_Weapons_fnc_getUniqueWeaponKitName;
 [format ["0.7-A %1 unique kit name",_label],_nameResult getOrDefault ["success",false]] call _assert;
 if !(_nameResult getOrDefault ["success",false]) exitWith {false};

 private _kitResult = [
  ((_nameResult get "data") get "name"),
  _slot,
  ((_recipeResult get "data") get "recipe")
 ] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponKit;
 [format ["0.7-A %1 WeaponKit prerequisite",_label],_kitResult getOrDefault ["success",false]] call _assert;
 if !(_kitResult getOrDefault ["success",false]) exitWith {false};
 private _kit = (_kitResult get "data") get "kit";

 private _planResult = [_unit,_kit] call ServoPeregrino_Organizador_Weapons_fnc_createApplicationPlan;
 [format ["0.7-A %1 plan creates",_label],_planResult getOrDefault ["success",false]] call _assert;
 if !(_planResult getOrDefault ["success",false]) exitWith {false};
 private _plan = (_planResult get "data") get "plan";
 [format ["0.7-A %1 plan schema",_label],(_plan getOrDefault ["schemaVersion",""]) isEqualTo "0.7-A-application-plan-candidate"] call _assert;
 [format ["0.7-A %1 plan target slot",_label],(_plan getOrDefault ["targetSlot",""]) isEqualTo _slot] call _assert;
 [format ["0.7-A %1 plan forbids mutation",_label],_plan getOrDefault ["dryRunOnly",false] && {!(_plan getOrDefault ["mutationAuthorized",true])}] call _assert;
 [format ["0.7-A %1 plan freezes fullMagazines=false",_label],!(_plan getOrDefault ["fullMagazines",true])] call _assert;
 [format ["0.7-A %1 plan validates",_label],([_plan] call ServoPeregrino_Organizador_Weapons_fnc_validateApplicationPlan) getOrDefault ["success",false]] call _assert;

 private _snapshotResult = [_unit,_plan] call ServoPeregrino_Organizador_Weapons_fnc_captureApplicationSnapshot;
 [format ["0.7-A %1 snapshot captures",_label],_snapshotResult getOrDefault ["success",false]] call _assert;
 if !(_snapshotResult getOrDefault ["success",false]) exitWith {false};
 private _snapshot = (_snapshotResult get "data") get "snapshot";
 [format ["0.7-A %1 snapshot schema",_label],(_snapshot getOrDefault ["schemaVersion",""]) isEqualTo "0.7-A-application-snapshot-candidate"] call _assert;
 [format ["0.7-A %1 snapshot validates",_label],([_snapshot] call ServoPeregrino_Organizador_Weapons_fnc_validateApplicationSnapshot) getOrDefault ["success",false]] call _assert;

 private _domainNames = (_snapshot getOrDefault ["preservationDomains",[]]) apply {_x param [0,""]};
 [format ["0.7-A %1 snapshot preserves non-target domains",_label],
  ({_x in _domainNames} count ["UNIFORM","VEST","BACKPACK","HEADGEAR","GOGGLES","BINOCULAR","ASSIGNED_ITEMS"]) isEqualTo 7
 ] call _assert;

 private _simulation = [_unit,_plan,_snapshot] call ServoPeregrino_Organizador_Weapons_fnc_simulateApplicationPlan;
 [format ["0.7-A %1 dry-run succeeds",_label],_simulation getOrDefault ["success",false]] call _assert;
 if (_simulation getOrDefault ["success",false]) then {
  private _simData = _simulation get "data";
  [format ["0.7-A %1 dry-run mutationPerformed=false",_label],!(_simData getOrDefault ["mutationPerformed",true])] call _assert;
  [format ["0.7-A %1 dry-run reports unchanged loadout",_label],_simData getOrDefault ["loadoutUnchanged",false]] call _assert;
 };

 private _after = getUnitLoadout _unit;
 [format ["0.7-A %1 exact engine loadout unchanged",_label],_before isEqualTo _after] call _assert;

 if (_slot isEqualTo "PRIMARY") then {
  _primaryPlan = [_plan] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
  _primarySnapshot = [_snapshot] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 };

 _scenarioResults pushBack createHashMapFromArray [
  ["label",_label],
  ["slot",_slot],
  ["operation",_plan getOrDefault ["operation",""]],
  ["preservationFingerprint",_snapshot getOrDefault ["preservationFingerprint",""]]
 ];
 true
};

["PRIMARY","arifle_MX_F","PRIMARY","30Rnd_65x39_caseless_mag"] call _runScenario;
["HANDGUN","hgun_P07_F","HANDGUN","16Rnd_9x21_Mag"] call _runScenario;
["SECONDARY","launch_NLAW_F","SECONDARY","NLAW_F"] call _runScenario;

private _loadoutForFp = [getUnitLoadout _unit] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
private _fpBaseResult = [_loadoutForFp,"PRIMARY"] call ServoPeregrino_Organizador_Weapons_fnc_getApplicationPreservationFingerprint;
["0.7-A preservation fingerprint baseline creates",_fpBaseResult getOrDefault ["success",false]] call _assert;
if (_fpBaseResult getOrDefault ["success",false]) then {
 private _fpBase = ((_fpBaseResult get "data") get "fingerprint");

 private _targetOnly = [_loadoutForFp] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 _targetOnly set [0,["SP_ORG_DRY_RUN_TARGET_ONLY"]];
 private _fpTarget = [_targetOnly,"PRIMARY"] call ServoPeregrino_Organizador_Weapons_fnc_getApplicationPreservationFingerprint;
 ["0.7-A target-slot changes are excluded from preservation fingerprint",
  _fpTarget getOrDefault ["success",false] && {(((_fpTarget get "data") get "fingerprint") isEqualTo _fpBase)}
 ] call _assert;

 private _nonTarget = [_loadoutForFp] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 _nonTarget set [6,"SP_ORG_DRY_RUN_NON_TARGET_CHANGE"];
 private _fpNonTarget = [_nonTarget,"PRIMARY"] call ServoPeregrino_Organizador_Weapons_fnc_getApplicationPreservationFingerprint;
 ["0.7-A non-target changes alter preservation fingerprint",
  _fpNonTarget getOrDefault ["success",false] && {!(((_fpNonTarget get "data") get "fingerprint") isEqualTo _fpBase)}
 ] call _assert;
};

["0.7-A invalid loadout fingerprint rejected",!(([[],"PRIMARY"] call ServoPeregrino_Organizador_Weapons_fnc_getApplicationPreservationFingerprint) getOrDefault ["success",false])] call _assert;
["0.7-A invalid target slot fingerprint rejected",!(([_loadoutForFp,"INVALID"] call ServoPeregrino_Organizador_Weapons_fnc_getApplicationPreservationFingerprint) getOrDefault ["success",false])] call _assert;

if (count _primaryPlan > 0) then {
 private _badDryRun = [_primaryPlan] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 _badDryRun set ["dryRunOnly",false];
 ["0.7-A plan cannot disable dry-run",!(([_badDryRun] call ServoPeregrino_Organizador_Weapons_fnc_validateApplicationPlan) getOrDefault ["success",false])] call _assert;

 private _badMutation = [_primaryPlan] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 _badMutation set ["mutationAuthorized",true];
 ["0.7-A plan cannot authorize mutation",!(([_badMutation] call ServoPeregrino_Organizador_Weapons_fnc_validateApplicationPlan) getOrDefault ["success",false])] call _assert;

 private _badFullMag = [_primaryPlan] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 _badFullMag set ["fullMagazines",true];
 ["0.7-A plan rejects fullMagazines=true",!(([_badFullMag] call ServoPeregrino_Organizador_Weapons_fnc_validateApplicationPlan) getOrDefault ["success",false])] call _assert;

 private _badStrategy = [_primaryPlan] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 _badStrategy set ["strategy","MUTATING_STRATEGY"];
 ["0.7-A plan rejects non-candidate strategy",!(([_badStrategy] call ServoPeregrino_Organizador_Weapons_fnc_validateApplicationPlan) getOrDefault ["success",false])] call _assert;

 private _badIndex = [_primaryPlan] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 _badIndex set ["targetSlotIndex",2];
 ["0.7-A plan rejects slot/index mismatch",!(([_badIndex] call ServoPeregrino_Organizador_Weapons_fnc_validateApplicationPlan) getOrDefault ["success",false])] call _assert;

 private _badMagazine = [_primaryPlan] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 _badMagazine set ["desiredMagazineClass","SP_ORG_FAKE_MAG"];
 ["0.7-A plan rejects Recipe/magazine drift",!(([_badMagazine] call ServoPeregrino_Organizador_Weapons_fnc_validateApplicationPlan) getOrDefault ["success",false])] call _assert;
};

if (count _primarySnapshot > 0) then {
 private _badSnapshot = [_primarySnapshot] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 _badSnapshot set ["preservationFingerprint","TAMPERED"];
 ["0.7-A snapshot rejects tampered preservation fingerprint",!(([_badSnapshot] call ServoPeregrino_Organizador_Weapons_fnc_validateApplicationSnapshot) getOrDefault ["success",false])] call _assert;

 private _badSpeed = [_primarySnapshot] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 _badSpeed set ["animSpeedCoef",-1];
 ["0.7-A snapshot rejects invalid animation speed",!(([_badSpeed] call ServoPeregrino_Organizador_Weapons_fnc_validateApplicationSnapshot) getOrDefault ["success",false])] call _assert;
};

private _runtime = [] call ServoPeregrino_Organizador_Weapons_fnc_getRuntimeStatus;
private _runtimeData = _runtime getOrDefault ["data",createHashMap];
["0.7-A planning contract remains available in forward runtimes",(_runtimeData getOrDefault ["kitApplication",""]) in ["DRY_RUN_ONLY_0_7_A","SLOT_SAFE_APPLY_0_7_B"]] call _assert;
// Authority belongs to the later executor, never to this descriptive Plan.
private _forwardBefore = [getUnitLoadout _unit] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
private _forwardDry = [_unit,_primaryPlan,_primarySnapshot] call ServoPeregrino_Organizador_Weapons_fnc_simulateApplicationPlan;
["0.7-A descriptive Plan and dry-run remain non-mutating in forward runtimes",
 (_primaryPlan getOrDefault ["schemaVersion",""]) isEqualTo "0.7-A-application-plan-candidate"
 && {(_primarySnapshot getOrDefault ["schemaVersion",""]) isEqualTo "0.7-A-application-snapshot-candidate"}
 && {_primaryPlan getOrDefault ["dryRunOnly",false]}
 && {!(_primaryPlan getOrDefault ["mutationAuthorized",true])}
 && {_forwardDry getOrDefault ["success",false]}
 && {!((_forwardDry getOrDefault ["data",createHashMap]) getOrDefault ["mutationPerformed",true])}
 && {(getUnitLoadout _unit) isEqualTo _forwardBefore}
] call _assert;
["0.7-A runtime plan schema marker",(_runtimeData getOrDefault ["applicationPlanSchema",""]) isEqualTo "0.7-A-application-plan-candidate"] call _assert;
["0.7-A runtime snapshot schema marker",(_runtimeData getOrDefault ["applicationSnapshotSchema",""]) isEqualTo "0.7-A-application-snapshot-candidate"] call _assert;

private _localPassed = {_x select 1} count _checks;
private _localFailed = count _checks - _localPassed;
private _passed = _legacyPassed + _localPassed;
private _failed = _legacyFailed + _localFailed;
private _total = _legacyPassed + _legacyFailed + count _checks;

diag_log format [
 "[SP_ORG] [WEAPONS] [AUTO_TEST_SUMMARY] mode=MISSION_FIRST_0_7_A passed=%1 failed=%2 total=%3 legacy=%4/%5 local=%6/%7 | APPLICATION_GATE=PLAN_SNAPSHOT_DRY_RUN | MUTATION=FORBIDDEN | STRATEGY=FULL_LOADOUT_CLONE_SETUNITLOADOUT_FALSE_CANDIDATE | NEXT=0_7_B_SLOT_SAFE_APPLY | MP_GATE=DEFERRED_0_8",
 _passed,_failed,_total,_legacyPassed,_legacyPassed+_legacyFailed,_localPassed,count _checks
];

hint format [
 "Weapons 0.7-A AUTO TEST: %1/%2; falhas=%3. Gate atual = Plan + Snapshot + Dry-Run. Nenhuma mutação física deve ocorrer.",
 _passed,_total,_failed
];

[_failed isEqualTo 0,"WEAPONS_0_7_A_AUTO_TEST_COMPLETE","0.7-A validates slot-safe ApplicationPlan, read-only Snapshot, non-target preservation fingerprints and Dry-Run simulation while keeping physical mutation forbidden.",createHashMapFromArray [
 ["passed",_passed],
 ["failed",_failed],
 ["total",_total],
 ["legacyPassed",_legacyPassed],
 ["legacyFailed",_legacyFailed],
 ["localPassed",_localPassed],
 ["localFailed",_localFailed],
 ["checks",_checks],
 ["legacyObservations",_legacyObservations],
 ["scenarios",_scenarioResults],
 ["applicationGate","PLAN_SNAPSHOT_DRY_RUN"],
 ["mutation","FORBIDDEN"],
 ["strategy","FULL_LOADOUT_CLONE_SETUNITLOADOUT_FALSE_CANDIDATE"],
 ["nextGate","0_7_B_SLOT_SAFE_APPLY"],
 ["mpGate","DEFERRED_0_8"],
 ["executionMode","MISSION_FIRST"]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
