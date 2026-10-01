#include "..\..\script_version.hpp"

params [["_token", "", [""]]];

private _registry = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_NEXUS_EVENT_REGISTRY_VAR, createHashMap];
private _removed = false;

{
    private _eventName = _x;
    private _subscriptions = _registry getOrDefault [_eventName, []];
    private _remaining = _subscriptions select {!((_x getOrDefault ["token", ""]) isEqualTo _token)};
    if ((count _remaining) < (count _subscriptions)) then {
        _removed = true;
        _registry set [_eventName, _remaining];
    };
} forEach (keys _registry);

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_NEXUS_EVENT_REGISTRY_VAR, _registry];

if (!_removed) exitWith {
    [false, "EVENT_SUBSCRIPTION_NOT_FOUND", "Assinatura de evento não encontrada."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
[true, "EVENT_UNSUBSCRIBED", "Assinatura removida."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
