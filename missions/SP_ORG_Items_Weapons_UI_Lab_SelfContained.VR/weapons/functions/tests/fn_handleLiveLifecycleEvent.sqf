#include "..\..\script_version.hpp"
params [
 ["_unit",objNull,[objNull]],
 ["_transition","",[""]],
 ["_container",objNull,[objNull]],
 ["_item","",[""]]
];

if (!isServer) exitWith {
 [false,"WEAPONS_SERVER_ONLY","Live lifecycle event analysis is server-only."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _direction = toUpperANSI _transition;
if !(_direction in ["TAKE","PUT"]) exitWith {
 [false,"WEAPONS_LIVE_EVENT_INVALID","Expected TAKE or PUT."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _weaponType = getNumber (configFile >> "CfgWeapons" >> _item >> "type");
if !(_weaponType in [1,2,4]) exitWith {
 [true,"WEAPONS_LIVE_NON_WEAPON_IGNORED","Non-weapon inventory event ignored."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _state = missionNamespace getVariable [SP_ORG_WEAPONS_LIVE_TEST,createHashMap];
if (count _state isEqualTo 0) exitWith {
 [false,"WEAPONS_LIVE_TEST_NOT_READY","Live lifecycle test has not been initialized."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _phase = _state getOrDefault ["phase",""];
private _transfer = missionNamespace getVariable ["SP_ORG_Weapons_Box_TRANSFER",objNull];
private _duplicates = missionNamespace getVariable ["SP_ORG_Weapons_Box_DUPLICATES",objNull];

private _expectedTransition = "";
private _expectedContainer = objNull;
private _expectedStatus = "";
private _expectedCandidates = -1;
private _evidenceInstanceId = "";

switch (_phase) do {
 case "BC_TAKE": {
  _expectedTransition = "TAKE";
  _expectedContainer = _transfer;
  _expectedStatus = "CORRELATED";
  _expectedCandidates = 1;
  _evidenceInstanceId = _state getOrDefault ["bcInstanceId",""];
 };
 case "BC_PUT": {
  _expectedTransition = "PUT";
  _expectedContainer = _transfer;
  _expectedStatus = "CORRELATED";
  _expectedCandidates = 1;
  _evidenceInstanceId = _state getOrDefault ["bcInstanceId",""];
 };
 case "E_TAKE": {
  _expectedTransition = "TAKE";
  _expectedContainer = _duplicates;
  _expectedStatus = "AMBIGUOUS";
  _expectedCandidates = 2;
  _evidenceInstanceId = "";
 };
 default {};
};

if (_expectedTransition isEqualTo "") exitWith {
 [true,"WEAPONS_LIVE_TEST_NO_ACTIVE_STEP","No active manual step."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

if !(_direction isEqualTo _expectedTransition && {_container isEqualTo _expectedContainer}) exitWith {
 [true,"WEAPONS_LIVE_EVENT_OUT_OF_STEP","Weapon event does not belong to the current manual step."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _before = _state getOrDefault ["beforeObservations",[]];
private _beforeCaptured = _state getOrDefault ["beforeCaptured",false];
if (_state getOrDefault ["activeContainer",""] != netId _container) then {
 _beforeCaptured = false;
};

if (!_beforeCaptured) exitWith {
 private _msg = "Missing BEFORE snapshot. Close/reopen the correct box or reset the manual test.";
 _state set ["failed",(_state get "failed") + 1];
 _state set ["phase","FAILED"];
 diag_log format ["[SP_ORG] [WEAPONS] [LIVE_RESULT] phase=%1 transition=%2 result=FAIL reason=NO_BEFORE_SNAPSHOT",_phase,_direction];
 [false,"WEAPONS_LIVE_BEFORE_MISSING",_msg] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _afterResult = [_container] call ServoPeregrino_Organizador_Weapons_fnc_inspectWeaponCarrier;
if !(_afterResult get "success") exitWith {_afterResult};
private _after = (_afterResult get "data") get "observations";

private _delta = [_direction,_before,_after] call ServoPeregrino_Organizador_Weapons_fnc_detectLifecycleDelta;
if !(_delta get "success") exitWith {
 _state set ["failed",(_state get "failed") + 1];
 _state set ["phase","FAILED"];
 diag_log format ["[SP_ORG] [WEAPONS] [LIVE_RESULT] phase=%1 transition=%2 result=FAIL reason=DELTA code=%3 before=%4 after=%5",_phase,_direction,_delta get "code",_before,_after];
 _delta
};

private _fingerprint = (_delta get "data") get "fingerprint";
private _expectedFingerprint = _state getOrDefault ["expectedFingerprint",""];
if !(_fingerprint isEqualTo _expectedFingerprint) exitWith {
 _state set ["failed",(_state get "failed") + 1];
 _state set ["phase","FAILED"];
 diag_log format ["[SP_ORG] [WEAPONS] [LIVE_RESULT] phase=%1 transition=%2 result=FAIL reason=UNEXPECTED_FINGERPRINT expected=%3 actual=%4",_phase,_direction,_expectedFingerprint,_fingerprint];
 [false,"WEAPONS_LIVE_UNEXPECTED_WEAPON","The moved weapon does not match the controlled test configuration."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _from = createHashMapFromArray [
 ["kind",if (_direction isEqualTo "TAKE") then {"CONTAINER"} else {"UNIT_SLOT"}],
 ["id",if (_direction isEqualTo "TAKE") then {netId _container} else {netId _unit}]
];
private _to = createHashMapFromArray [
 ["kind",if (_direction isEqualTo "TAKE") then {"UNIT_SLOT"} else {"CONTAINER"}],
 ["id",if (_direction isEqualTo "TAKE") then {netId _unit} else {netId _container}]
];

private _analysis = [
 _direction,_before,_after,_fingerprint,_evidenceInstanceId,_from,_to
] call ServoPeregrino_Organizador_Weapons_fnc_analyzeLifecycleTransition;
if !(_analysis get "success") exitWith {_analysis};

private _evidence = (_analysis get "data") get "evidence";
private _actualStatus = _evidence get "continuityStatus";
private _actualCandidates = _evidence get "candidateCount";
private _physicalClaim = _evidence get "physicalIdentityProven";

private _pass =
 _actualStatus isEqualTo _expectedStatus
 && {_actualCandidates isEqualTo _expectedCandidates}
 && {!_physicalClaim};

if (_phase isEqualTo "E_TAKE") then {
 _pass = _pass && {(_evidence get "instanceId") isEqualTo ""};
};

private _record = createHashMapFromArray [
 ["phase",_phase],
 ["transition",_direction],
 ["status",_actualStatus],
 ["candidateCount",_actualCandidates],
 ["instanceId",_evidence get "instanceId"],
 ["physicalIdentityProven",_physicalClaim],
 ["pass",_pass],
 ["evidence",_evidence]
];

private _results = _state get "results";
_results pushBack _record;

if (_pass) then {
 _state set ["passed",(_state get "passed") + 1];
 private _next = switch (_phase) do {
  case "BC_TAKE": {"BC_PUT"};
  case "BC_PUT": {"E_TAKE"};
  case "E_TAKE": {"COMPLETE"};
  default {_phase};
 };
 _state set ["phase",_next];
 if (_next isEqualTo "COMPLETE") then {_state set ["complete",true]};
} else {
 _state set ["failed",(_state get "failed") + 1];
 _state set ["phase","FAILED"];
};

_state set ["beforeObservations",[_after] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy];
_state set ["beforeCaptured",true];
_state set ["activeContainer",netId _container];

diag_log format [
 "[SP_ORG] [WEAPONS] [LIVE_RESULT] phase=%1 transition=%2 expected=%3/%4 actual=%5/%6 pass=%7 instanceId=%8 physicalIdentityProven=%9 candidateLogicalIds=%10",
 _phase,_direction,_expectedStatus,_expectedCandidates,_actualStatus,_actualCandidates,_pass,
 _evidence get "instanceId",_physicalClaim,_state getOrDefault ["duplicateLogicalIds",[]]
];

if (_state get "complete") then {
 diag_log format [
  "[SP_ORG] [WEAPONS] [MANUAL_LIFECYCLE_SUMMARY] passed=%1 failed=%2 total=%3 phase=COMPLETE physicalIdentityProven=false results=%4",
  _state get "passed",_state get "failed",count (_state get "results"),_state get "results"
 ];
};

[true,if (_pass) then {"WEAPONS_LIVE_STEP_PASS"} else {"WEAPONS_LIVE_STEP_FAIL"},"Live lifecycle step analyzed.",createHashMapFromArray [
 ["pass",_pass],["phase",_phase],["nextPhase",_state get "phase"],["evidence",_evidence]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
