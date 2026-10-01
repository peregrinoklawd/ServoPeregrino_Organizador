#include "..\..\script_version.hpp"

params [
    ["_eventName", "", [""]],
    ["_handler", {}, [{}]],
    ["_owner", "", [""]]
];

private _normalizedEvent = toLowerANSI _eventName;
if (_normalizedEvent isEqualTo "") exitWith {
    [false, "EVENT_NAME_REQUIRED", "O nome do evento é obrigatório."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if (_owner isEqualTo "") exitWith {
    [false, "EVENT_OWNER_REQUIRED", "O proprietário da assinatura é obrigatório."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _registry = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_NEXUS_EVENT_REGISTRY_VAR, createHashMap];
private _subscriptions = _registry getOrDefault [_normalizedEvent, []];
private _token = format ["subscription-%1-%2", floor (diag_tickTime * 1000), floor (random 1000000000)];
private _subscription = createHashMapFromArray [
    ["token", _token],
    ["event", _normalizedEvent],
    ["owner", _owner],
    ["handler", _handler],
    ["subscribedAtUTC", systemTimeUTC]
];

_subscriptions pushBack _subscription;
_registry set [_normalizedEvent, _subscriptions];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_NEXUS_EVENT_REGISTRY_VAR, _registry];

[true, "EVENT_SUBSCRIBED", format ["Assinatura criada para %1.", _normalizedEvent], createHashMapFromArray [["token", _token], ["subscription", _subscription]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
