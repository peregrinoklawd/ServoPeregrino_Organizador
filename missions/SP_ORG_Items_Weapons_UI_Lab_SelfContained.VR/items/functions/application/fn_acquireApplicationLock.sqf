#include "..\..\script_version.hpp"
params [
    ["_planId", "", [""]],
    ["_owner", "LOCAL", [""]],
    ["_timeoutSeconds", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_LOCK_TIMEOUT, [0]]
];
private _state = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_STATE_VAR, createHashMapFromArray [["ready", true], ["executing", false]]];
private _now = diag_tickTime;
private _recovered = false;
private _busyResult = createHashMap;
if (_state getOrDefault ["executing", false]) then {
    private _currentToken = _state getOrDefault ["lockToken", ""];
    private _acquiredAt = _state getOrDefault ["lockAcquiredAtTick", -1];
    private _age = if (_acquiredAt >= 0) then {_now - _acquiredAt} else {-1};
    private _recoverable = !(_currentToken isEqualTo "") && {_age >= 0} && {_age > _timeoutSeconds};
    if (_recoverable) then {
        _recovered = true;
    } else {
        _busyResult = [false, "ITEMS_APPLICATION_BUSY", "Já existe uma transação Items com lock local ativo.", createHashMapFromArray [["activePlanId", _state getOrDefault ["activePlanId", ""]], ["lockOwner", _state getOrDefault ["lockOwner", ""]], ["lockAgeSeconds", _age]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult;
    };
};
if ((count _busyResult) > 0) exitWith {_busyResult};
private _token = format ["sporg-items-lock-%1-%2", round (_now * 1000), floor (random 1000000)];
private _newState = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_STATE_VAR, createHashMap];
_newState set ["ready", true];
_newState set ["executing", true];
_newState set ["activePlanId", _planId];
_newState set ["lockToken", _token];
_newState set ["lockOwner", _owner];
_newState set ["lockAcquiredAtTick", _now];
_newState set ["lockRecovered", _recovered];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_STATE_VAR, _newState];
[true, if (_recovered) then {"ITEMS_APPLICATION_LOCK_STALE_RECOVERED"} else {"ITEMS_APPLICATION_LOCK_ACQUIRED"}, if (_recovered) then {"Lock stale anterior foi substituído com nova identidade."} else {"Lock transacional adquirido."}, createHashMapFromArray [["token", _token], ["owner", _owner], ["planId", _planId], ["recovered", _recovered]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
