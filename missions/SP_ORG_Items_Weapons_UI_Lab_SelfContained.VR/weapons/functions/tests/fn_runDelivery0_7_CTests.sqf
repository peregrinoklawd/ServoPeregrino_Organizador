#include "..\..\script_version.hpp"
if (!canSuspend || {!isServer} || {isRemoteExecuted} || {!(missionNamespace getVariable ["SP_ORG_Weapons_LabEnabled",false])}) exitWith {
 [false,"WEAPONS_TEST_SCHEDULED_LAB_ONLY","Use scheduled local LAB action."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _legacy = [] call ServoPeregrino_Organizador_Weapons_fnc_runDelivery0_7_BTests;
private _ld = _legacy getOrDefault ["data",createHashMap];
private _checks = [];
private _blocked = _ld getOrDefault ["blocked",0];
private _assert = {
 params ["_name","_ok"];
 _checks pushBack [_name,_ok];
 diag_log format ["[SP_ORG] [WEAPONS] [AUTO_TEST] mode=MISSION_FIRST_0_7_C %1 | %2",if (_ok) then {"PASS"} else {"FAIL"},_name];
};
["B2 cumulative baseline",_legacy getOrDefault ["success",false] && {(_ld getOrDefault ["passed",0]) isEqualTo 890}] call _assert;
private _playerBefore = getUnitLoadout player;
private _group = createGroup [west,true];
private _unit = _group createUnit ["B_Soldier_F",getPosATL player,[],0,"NONE"];
["C isolated local target",!isNull _unit && {local _unit}] call _assert;
private _run = {
 params ["_fault"];
 if (isNull _unit) exitWith {};
 _unit allowDamage false;
 _unit hideObject true;
 _unit enableSimulation false;
 _unit setVariable ["SP_ORG_Weapons_IsolatedFaultTarget",true];
 private _baseline = getUnitLoadout _unit;
 _baseline set [1,["launch_NLAW_F","","","",["NLAW_F",1],[],""]];
 _baseline set [2,["hgun_P07_F","","","",["16Rnd_9x21_Mag",7],[],""]];
 _baseline set [3,["U_B_CombatUniform_mcam",[["FirstAidKit",2],["16Rnd_9x21_Mag",1,7]]]];
 _baseline set [4,["V_PlateCarrier1_rgr",[["30Rnd_65x39_caseless_mag",2,9]]]];
 _baseline set [5,["B_AssaultPack_mcamo",[["FirstAidKit",3],["SmokeShell",1,1]]]];
 _baseline set [6,"H_HelmetB"];
 _baseline set [7,"G_Combat"];
 _baseline set [8,["Binocular","","","",[],[],""]];
 _baseline set [9,["ItemMap","ItemCompass","ItemWatch","ItemRadio","ItemGPS","NVGoggles"]];
 _baseline set [0,["arifle_MX_F","","","",["30Rnd_65x39_caseless_mag",17],[],""]];
 _unit setUnitLoadout [_baseline,false];
 _unit setAnimSpeedCoef 0.9;
 private _cfgR = ["arifle_MX_F"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponConfiguration;
 ["C configuration "+_fault,_cfgR getOrDefault ["success",false]] call _assert;
 if !(_cfgR getOrDefault ["success",false]) exitWith {};
 private _cfg = (_cfgR get "data") get "configuration";
 _cfg set ["optic","optic_Hamr"];
 private _recipeR = [_cfg,"30Rnd_65x39_caseless_mag"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponRecipe;
 ["C Recipe "+_fault,_recipeR getOrDefault ["success",false]] call _assert;
 if !(_recipeR getOrDefault ["success",false]) exitWith {};
 private _kit = createHashMapFromArray [["schemaVersion","0.5-kit-candidate"],["kitId","WKT-LAB-C"],["name","LAB rollback"],["targetSlot","PRIMARY"],["recipe",(_recipeR get "data") get "recipe"]];
 private _planR = [_unit,_kit] call ServoPeregrino_Organizador_Weapons_fnc_createApplicationPlan;
 ["C plan "+_fault,_planR getOrDefault ["success",false]] call _assert;
 if !(_planR getOrDefault ["success",false]) exitWith {};
 private _plan = (_planR get "data") get "plan";
 private _snapshotR = [_unit,_plan] call ServoPeregrino_Organizador_Weapons_fnc_captureApplicationSnapshot;
 ["C snapshot "+_fault,_snapshotR getOrDefault ["success",false]] call _assert;
 if !(_snapshotR getOrDefault ["success",false]) exitWith {};
 private _snapshot = (_snapshotR get "data") get "snapshot";
 private _result = [_unit,_plan,_snapshot,_fault] call ServoPeregrino_Organizador_Weapons_fnc_applyApplicationPlan;
 private _d = _result getOrDefault ["data",createHashMap];
 private _post = _d getOrDefault ["postValidation",createHashMap];
 ["C FAILED after fault "+_fault,!(_result getOrDefault ["success",true])] call _assert;
 ["C mutation really precedes fault "+_fault,!((_d getOrDefault ["mutatedBeforeFault",[]]) isEqualTo (_snapshot get "capturedLoadout")) && {count (_d getOrDefault ["mutatedBeforeFault",[]]) >= 10}] call _assert;
 ["C mutation reported "+_fault,_d getOrDefault ["mutationPerformed",false]] call _assert;
 ["C rollback attempted "+_fault,_d getOrDefault ["rollbackAttempted",false]] call _assert;
 ["C exact restoration reported "+_fault,_d getOrDefault ["rollbackRestoredExactly",false]] call _assert;
 ["C rollback success phase "+_fault,(_d getOrDefault ["failurePhase",""]) isEqualTo "POST_MUTATION_ROLLBACK_SUCCEEDED"] call _assert;
 ["C final loadout exact "+_fault,(getUnitLoadout _unit) isEqualTo (_snapshot get "capturedLoadout")] call _assert;
 ["C animation restored "+_fault,(getAnimSpeedCoef _unit) isEqualTo (_snapshot get "animSpeedCoef")] call _assert;
 private _verify = [_unit,_snapshot] call ServoPeregrino_Organizador_Weapons_fnc_validateApplicationRollback;
 ["C independent rollback validation "+_fault,_verify getOrDefault ["success",false]] call _assert;
 ["C protected fingerprint restored "+_fault,((_verify getOrDefault ["data",createHashMap]) getOrDefault ["preservationMatched",false])] call _assert;
 ["C fault observable divergence "+_fault,if (_fault isEqualTo "PROTECTED_DIVERGENCE") then {!(_post getOrDefault ["preservationMatched",true])} else {if (_fault isEqualTo "AMMO_DIVERGENCE") then {!(_post getOrDefault ["primaryMagazineMatched",true])} else {!(_post getOrDefault ["configurationMatched",true])}}] call _assert;
 for "_i" from 0 to 9 do {
  [format ["C domain %1 restored %2",_i,_fault],((getUnitLoadout _unit) param [_i,false]) isEqualTo ((_snapshot get "capturedLoadout") param [_i,true])] call _assert;
 };
 // A fault request against an untagged local object must fail before mutation.
 _unit setVariable ["SP_ORG_Weapons_IsolatedFaultTarget",false];
 private _refused = [_unit,_plan,_snapshot,_fault] call ServoPeregrino_Organizador_Weapons_fnc_applyApplicationPlan;
 ["C untagged fault refused "+_fault,(_refused getOrDefault ["code",""]) isEqualTo "WEAPONS_LAB_FAULT_REFUSED"] call _assert;
 ["C refused fault no mutation "+_fault,(getUnitLoadout _unit) isEqualTo (_snapshot get "capturedLoadout")] call _assert;
 ["C refused fault PRE_MUTATION "+_fault,((_refused getOrDefault ["data",createHashMap]) getOrDefault ["failurePhase",""]) isEqualTo "PRE_MUTATION"] call _assert;
 diag_log format ["[SP_ORG] [WEAPONS] [ROLLBACK_DIAGNOSTIC] fault=%1 result=%2",_fault,_result];
};
{
 private _start = count _checks;
 [_x] call _run;
 private _missing = 28 - (count _checks - _start);
 for "_i" from 1 to _missing do {
  _checks pushBack [format ["C %1 dependent %2",_x,_i],false,"BLOCKED"];
  _blocked = _blocked + 1;
  diag_log format ["[SP_ORG] [WEAPONS] [AUTO_TEST] BLOCKED | C %1 dependent %2",_x,_i];
 };
} forEach ["TARGET_DIVERGENCE","PROTECTED_DIVERGENCE","AMMO_DIVERGENCE"];
if (!isNull _unit) then {deleteVehicle _unit};
private _deadline = diag_tickTime + 5;
waitUntil {sleep 0.01; isNull _unit || {diag_tickTime >= _deadline}};
["C no isolated object leak",isNull _unit && {!(_unit in allUnits)} && {!(_unit in (allMissionObjects "CAManBase"))}] call _assert;
deleteGroup _group;
["C player untouched",(getUnitLoadout player) isEqualTo _playerBefore] call _assert;
private _lp = {_x select 1} count _checks;
private _lb = {(_x param [2,""]) isEqualTo "BLOCKED"} count _checks;
private _lf = count _checks - _lp - _lb;
private _passed = (_ld getOrDefault ["passed",0]) + _lp;
private _failed = (_ld getOrDefault ["failed",1]) + _lf;
private _total = (_ld getOrDefault ["total",0]) + count _checks;
diag_log format ["[SP_ORG] [WEAPONS] [AUTO_TEST_SUMMARY] mode=MISSION_FIRST_0_7_C passed=%1 failed=%2 blocked=%3 total=%4 expected=978",_passed,_failed,_blocked,_total];
hint format ["Weapons 0.7-C: %1/%2; falhas=%3; bloqueados=%4",_passed,_total,_failed,_blocked];
[_failed isEqualTo 0 && {_blocked isEqualTo 0} && {_total isEqualTo 978},"WEAPONS_0_7_C_AUTO_TEST_COMPLETE","Explicit post-mutation rollback gate; runtime required.",createHashMapFromArray [["passed",_passed],["failed",_failed],["blocked",_blocked],["total",_total],["expected",978],["checks",_checks]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
