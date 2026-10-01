#include "..\..\script_version.hpp"

params [
    ["_eventName", "", [""]],
    ["_payload", createHashMap, [createHashMap]],
    ["_source", "", [""]],
    ["_version", 1, [0]]
];

private _normalizedEvent = toLowerANSI _eventName;
if (_normalizedEvent isEqualTo "") exitWith {
    [false, "EVENT_NAME_REQUIRED", "O nome do evento é obrigatório."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if (_version < 1) exitWith {
    [false, "EVENT_VERSION_INVALID", "A versão do evento deve ser maior ou igual a 1."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _envelope = createHashMapFromArray [
    ["event", _normalizedEvent],
    ["version", _version],
    ["source", _source],
    ["payload", _payload],
    ["publishedAtUTC", systemTimeUTC]
];
private _registry = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_NEXUS_EVENT_REGISTRY_VAR, createHashMap];
private _subscriptions = +(_registry getOrDefault [_normalizedEvent, []]);
private _invoked = 0;
private _failedOwners = [];

{
    private _subscription = _x;
    private _handler = _subscription getOrDefault ["handler", {}];
    private _completed = false;

    isNil {
        [_envelope] call _handler;
        _completed = true;
    };

    if (_completed) then {
        _invoked = _invoked + 1;
    } else {
        _failedOwners pushBack (_subscription getOrDefault ["owner", "UNKNOWN"]);
    };
} forEach _subscriptions;

private _diagnostics = [];
if ((count _failedOwners) > 0) then {
    _diagnostics pushBack ([
        "ERROR",
        "EVENT_HANDLER_FAILED",
        "Uma ou mais assinaturas falharam durante a publicação.",
        createHashMapFromArray [["owners", _failedOwners]]
    ] call ServoPeregrino_Organizador_Nexus_fnc_createDiagnostic);
};

[
    (count _failedOwners) isEqualTo 0,
    if ((count _failedOwners) isEqualTo 0) then {"EVENT_PUBLISHED"} else {"EVENT_PUBLISHED_WITH_FAILURES"},
    format ["Evento %1 publicado: %2 sucesso(s), %3 falha(s).", _normalizedEvent, _invoked, count _failedOwners],
    createHashMapFromArray [["event", _envelope], ["subscriberCount", _invoked], ["failedOwners", _failedOwners]],
    _diagnostics
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
