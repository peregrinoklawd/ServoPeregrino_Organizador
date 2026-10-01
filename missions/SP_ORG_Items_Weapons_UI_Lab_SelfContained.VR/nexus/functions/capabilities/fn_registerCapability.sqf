#include "..\..\script_version.hpp"

params [
    ["_capabilityId", "", [""]],
    ["_version", 1, [0]],
    ["_provider", "", [""]],
    ["_metadata", createHashMap, [createHashMap]]
];

private _normalizedId = toLowerANSI _capabilityId;
if (_normalizedId isEqualTo "") exitWith {
    [false, "CAPABILITY_ID_REQUIRED", "O identificador da capacidade é obrigatório."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if (_version < 1) exitWith {
    [false, "CAPABILITY_VERSION_INVALID", "A versão da capacidade deve ser maior ou igual a 1."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if (_provider isEqualTo "") exitWith {
    [false, "CAPABILITY_PROVIDER_REQUIRED", "O provedor da capacidade é obrigatório."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _registry = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_NEXUS_CAPABILITY_REGISTRY_VAR, createHashMap];
private _existing = _registry getOrDefault [_normalizedId, createHashMap];

if ((count _existing) > 0) exitWith {
    if (
        (_existing getOrDefault ["provider", ""]) isEqualTo _provider
        && {(_existing getOrDefault ["version", 0]) isEqualTo _version}
    ) then {
        [true, "CAPABILITY_ALREADY_REGISTERED", "A capacidade já estava registrada com o mesmo provedor e versão.", createHashMapFromArray [["capability", _existing]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
    } else {
        [false, "CAPABILITY_CONFLICT", format ["A capacidade %1 já pertence a outro provedor ou versão.", _normalizedId], createHashMapFromArray [["capability", _existing]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
    }
};

private _entry = createHashMapFromArray [
    ["id", _normalizedId],
    ["version", _version],
    ["provider", _provider],
    ["metadata", _metadata],
    ["registeredAtUTC", systemTimeUTC]
];
_registry set [_normalizedId, _entry];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_NEXUS_CAPABILITY_REGISTRY_VAR, _registry];

[true, "CAPABILITY_REGISTERED", format ["Capacidade registrada: %1 v%2.", _normalizedId, _version], createHashMapFromArray [["capability", _entry]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
