#include "..\..\script_version.hpp"
params [
    ["_token", "", [""]],
    ["_lastResult", createHashMap, [createHashMap]]
];
private _state = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_STATE_VAR, createHashMap];
private _currentToken = _state getOrDefault ["lockToken", ""];
if (_token isEqualTo "" || {!(_currentToken isEqualTo _token)}) exitWith {
    [false, "ITEMS_APPLICATION_LOCK_NOT_OWNER", "Tentativa de liberar lock pertencente a outro token foi recusada.", createHashMapFromArray [["requestedToken", _token], ["currentToken", _currentToken], ["activePlanId", _state getOrDefault ["activePlanId", ""]]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
_state set ["executing", false];
_state set ["activePlanId", ""];
_state set ["lockToken", ""];
_state set ["lockOwner", ""];
_state set ["lockAcquiredAtTick", -1];
_state set ["lastResult", _lastResult];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_STATE_VAR, _state];
[true, "ITEMS_APPLICATION_LOCK_RELEASED", "Lock transacional liberado pelo próprio token.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult
