#include "..\..\script_version.hpp"
params [
    ["_movement","ADD",[""]],
    ["_options",createHashMap,[createHashMap]]
];
private _orchEarly=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
private _testTelemetryEarly=_orchEarly getOrDefault ["running",false];
if ((SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_AUDIO_PERFORMANCE_HOLD > 0) && {!_testTelemetryEarly}) exitWith {
    createHashMapFromArray [
        ["movement",toUpper _movement],["resolvedPath",""],["soundClass",""],["provider","AUDIO_PERFORMANCE_HOLD"],
        ["configReference",""],["classScope","NONE"],["classAvailable",false],["enabled",false],
        ["attempted",false],["played",false],["suppressedByTests",false],["suppressedByPerformanceHold",true],
        ["silent",true],["method","PERFORMANCE_HOLD_NO_LOOKUP"],["soundId",-1],["volume",0],["pitch",1],["realInventoryAvailable",false]
    ]
};
private _profile=[_movement] call ServoPeregrino_Organizador_Items_fnc_getUIMovementSoundProfile;
private _state=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
if ((count _state) isEqualTo 0) then {_state=[] call ServoPeregrino_Organizador_Items_fnc_createUIState;};
private _enabled=_state getOrDefault ["soundEnabled",true];
private _orch=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
private _suppressTests=(_orch getOrDefault ["running",false]) && {!(_options getOrDefault ["allowDuringTests",false])};
private _forceSilent=_options getOrDefault ["silent",false];
private _played=false;
private _attempted=false;
private _soundId=-1;
private _method="NONE";
private _soundClass=_profile getOrDefault ["soundClass",""];
private _scope=_profile getOrDefault ["classScope","MAIN"];
private _volume=_profile getOrDefault ["volume",1];
private _pitch=_profile getOrDefault ["pitch",1];
private _classAvailable=_profile getOrDefault ["classAvailable",false];
private _resolvedPath=_profile getOrDefault ["resolvedPath",""];

if (_enabled && {!_suppressTests} && {!_forceSilent} && {hasInterface}) then {
    _attempted=true;
    if (_classAvailable) then {
        _method=if (_scope isEqualTo "MAIN") then {"MAIN_CFGSOUNDS_CLASS"} else {"MISSION_CFGSOUNDS_CLASS"};
        _soundId=playSoundUI [_soundClass,_volume,_pitch];
        _played=_soundId >= 0;
    } else {
        // O provider já foi resolvido/cacheado. Se ele não for válido, não fazemos novo lookup no frame do gesto.
        _method="NO_RESOLVABLE_CLASS";
    };
};

private _hist=+(_state getOrDefault ["movementSoundHistory",[]]);
_hist pushBack [_profile getOrDefault ["movement","ADD"],_resolvedPath,_played,diag_tickTime,_soundClass,_method,_soundId,_profile getOrDefault ["provider",""],_scope];
while {(count _hist)>16} do {_hist deleteAt 0;};
_state set ["movementSoundHistory",_hist];
private _legacyHist=+(_state getOrDefault ["soundHistory",[]]);
private _legacyOutcome=format ["MOVE_%1",_profile getOrDefault ["movement","ADD"]];
_legacyHist pushBack [_legacyOutcome,_soundClass,_played,diag_tickTime];
while {(count _legacyHist)>12} do {_legacyHist deleteAt 0;};
_state set ["soundHistory",_legacyHist];
_state set ["lastSoundOutcome",_legacyOutcome];
_state set ["lastSoundClass",_soundClass];
_state set ["lastSoundPlayed",_played];
_state set ["lastSoundTick",diag_tickTime];
_state set ["lastMovementSound",_profile getOrDefault ["movement",""]];
_state set ["lastMovementSoundPath",_resolvedPath];
_state set ["lastMovementSoundClass",_soundClass];
_state set ["lastMovementSoundProvider",_profile getOrDefault ["provider",""]];
_state set ["lastMovementSoundScope",_scope];
_state set ["lastMovementSoundMethod",_method];
_state set ["lastMovementSoundId",_soundId];
_state set ["lastMovementSoundPlayed",_played];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state];

diag_log format ["[SP_ORG] [ITEMS] [UX_MOVE_SOUND] movement=%1 provider=%2 class=%3 scope=%4 classAvailable=%5 resolvedPath=%6 volume=%7 pitch=%8 enabled=%9 attempted=%10 played=%11 method=%12 id=%13 suppressedTests=%14 silent=%15",_profile getOrDefault ["movement",""],_profile getOrDefault ["provider",""],_soundClass,_scope,_classAvailable,_resolvedPath,_volume,_pitch,_enabled,_attempted,_played,_method,_soundId,_suppressTests,_forceSilent];
createHashMapFromArray [
    ["movement",_profile getOrDefault ["movement",""]],["resolvedPath",_resolvedPath],["soundClass",_soundClass],
    ["provider",_profile getOrDefault ["provider",""]],["configReference",_profile getOrDefault ["configReference",""]],["classScope",_scope],
    ["classAvailable",_classAvailable],["enabled",_enabled],["attempted",_attempted],["played",_played],
    ["suppressedByTests",_suppressTests],["silent",_forceSilent],["method",_method],["soundId",_soundId],
    ["volume",_volume],["pitch",_pitch],["realInventoryAvailable",_profile getOrDefault ["realInventoryAvailable",false]]
]
