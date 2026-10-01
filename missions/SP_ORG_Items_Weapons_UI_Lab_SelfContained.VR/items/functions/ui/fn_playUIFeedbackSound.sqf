#include "..\..\script_version.hpp"
params [
    ["_outcome","SUCCESS",[""]],
    ["_options",createHashMap,[createHashMap]]
];
private _o=toUpper _outcome;
private _class=switch _o do {
    case "SUCCESS":{"SP_ORG_Items_UI_Success"};
    case "PARTIAL":{"SP_ORG_Items_UI_Partial"};
    case "ROLLBACK":{"SP_ORG_Items_UI_Rollback"};
    case "BLOCKED":{"SP_ORG_Items_UI_Blocked"};
    case "ROLLBACK_FAILED":{"SP_ORG_Items_UI_Failure"};
    default {"SP_ORG_Items_UI_Failure"};
};
private _orchEarly=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
private _testTelemetryEarly=_orchEarly getOrDefault ["running",false];
if ((SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_AUDIO_PERFORMANCE_HOLD > 0) && {!_testTelemetryEarly}) exitWith {
    createHashMapFromArray [["outcome",_o],["soundClass",_class],["available",false],["enabled",false],["played",false],["attempted",false],["suppressedByTests",false],["suppressedByPerformanceHold",true],["silent",true],["method","PERFORMANCE_HOLD_NO_LOOKUP"]]
};
private _state=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
if ((count _state) isEqualTo 0) then {_state=[] call ServoPeregrino_Organizador_Items_fnc_createUIState;};
private _enabled=_state getOrDefault ["soundEnabled",true];
private _cfgOk=isClass (missionConfigFile >> "CfgSounds" >> _class);
private _orch=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
private _suppressTests=(_orch getOrDefault ["running",false]) && {!(_options getOrDefault ["allowDuringTests",false])};
private _forceSilent=_options getOrDefault ["silent",false];
private _played=false;
if (_enabled && {_cfgOk} && {!_suppressTests} && {!_forceSilent} && {hasInterface}) then {
    playSound _class;
    _played=true;
};
private _hist=+(_state getOrDefault ["soundHistory",[]]);
_hist pushBack [_o,_class,_played,diag_tickTime];
while {(count _hist)>12} do {_hist deleteAt 0;};
_state set ["soundHistory",_hist];
_state set ["lastSoundOutcome",_o];
_state set ["lastSoundClass",_class];
_state set ["lastSoundPlayed",_played];
_state set ["lastSoundTick",diag_tickTime];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state];
diag_log format ["[SP_ORG] [ITEMS] [UX_SOUND] outcome=%1 class=%2 available=%3 enabled=%4 played=%5 suppressedTests=%6 silent=%7",_o,_class,_cfgOk,_enabled,_played,_suppressTests,_forceSilent];
createHashMapFromArray [["outcome",_o],["soundClass",_class],["available",_cfgOk],["enabled",_enabled],["played",_played],["suppressedByTests",_suppressTests],["silent",_forceSilent]]
