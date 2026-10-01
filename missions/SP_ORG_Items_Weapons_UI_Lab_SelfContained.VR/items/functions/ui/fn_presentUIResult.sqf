#include "..\..\script_version.hpp"
params [
    ["_result",createHashMap,[createHashMap]],
    ["_audible",true,[true]],
    ["_options",createHashMap,[createHashMap]]
];
private _outcome=[_result] call ServoPeregrino_Organizador_Items_fnc_classifyUIOutcome;
[_outcome getOrDefault ["message",_result getOrDefault ["message","UNKNOWN"]],_outcome getOrDefault ["severity","INFO"]] call ServoPeregrino_Organizador_Items_fnc_pushUIFeedback;
private _state=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
_state set ["lastOutcome",_outcome getOrDefault ["outcome",""]];
_state set ["lastOutcomeSummary",_outcome getOrDefault ["message",""]];
_state set ["lastOutcomeCode",_outcome getOrDefault ["code",""]];
_state set ["lastOutcomeMetrics",createHashMapFromArray [
    ["appliedQty",_outcome getOrDefault ["appliedQty",0]],
    ["rejectedCount",_outcome getOrDefault ["rejectedCount",0]],
    ["actionCount",_outcome getOrDefault ["actionCount",0]],
    ["commandId",_outcome getOrDefault ["commandId","-"]]
]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state];
private _sound=createHashMap;
private _orch=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
private _testTelemetry=_orch getOrDefault ["running",false];
private _audioPerformanceHold=(SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_AUDIO_PERFORMANCE_HOLD > 0);
if (_audible && {(!_audioPerformanceHold) || {_testTelemetry}}) then {
    private _movementHint=toUpper (_options getOrDefault ["movementHint",_outcome getOrDefault ["movementKey",""]]);
    if ((_outcome getOrDefault ["outcome",""]) isEqualTo "SUCCESS" && {_movementHint isNotEqualTo ""}) then {
        _sound=[_movementHint,_options] call ServoPeregrino_Organizador_Items_fnc_playUIMovementSound;
    } else {
        _sound=[_outcome getOrDefault ["soundKey","FAILURE"],_options] call ServoPeregrino_Organizador_Items_fnc_playUIFeedbackSound;
    };
} else {
    _sound=createHashMapFromArray [["played",false],["attempted",false],["suppressedByPerformanceHold",_audioPerformanceHold],["reason","AUDIO_PERFORMANCE_HOLD"]];
};
_outcome set ["sound",_sound];
_outcome
