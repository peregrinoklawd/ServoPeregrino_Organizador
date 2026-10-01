#include "..\..\script_version.hpp"
params [
    ["_result",createHashMap,[createHashMap]],
    ["_movement","",[""]],
    ["_audible",true,[true]]
];
private _ok=_result getOrDefault ["success",false];
private _code=toUpper (_result getOrDefault ["code","UNKNOWN"]);
private _message=_result getOrDefault ["message",_code];
[_message,if (_ok) then {"INFO"} else {"WARN"}] call ServoPeregrino_Organizador_Items_fnc_pushUIFeedback;
private _sound=createHashMap;
private _orch=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
private _testTelemetry=_orch getOrDefault ["running",false];
private _audioPerformanceHold=(SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_AUDIO_PERFORMANCE_HOLD > 0);
if (_audible && {(!_audioPerformanceHold) || {_testTelemetry}}) then {
    private _noop=(_code find "NOOP")>=0 || {(_code find "UNCHANGED")>=0};
    if (_ok) then {
        if (!_noop && {_movement isNotEqualTo ""}) then {_sound=[_movement] call ServoPeregrino_Organizador_Items_fnc_playUIMovementSound;};
    } else {
        _sound=["BLOCKED"] call ServoPeregrino_Organizador_Items_fnc_playUIFeedbackSound;
    };
} else {
    _sound=createHashMapFromArray [["played",false],["attempted",false],["suppressedByPerformanceHold",_audioPerformanceHold],["reason","AUDIO_PERFORMANCE_HOLD"]];
};
createHashMapFromArray [["success",_ok],["code",_code],["movement",toUpper _movement],["sound",_sound]]
