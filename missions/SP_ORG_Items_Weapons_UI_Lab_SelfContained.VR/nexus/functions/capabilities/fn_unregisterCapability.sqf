#include "..\..\script_version.hpp"

params [
    ["_capabilityId", "", [""]],
    ["_provider", "", [""]]
];

private _normalizedId = toLowerANSI _capabilityId;
private _registry = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_NEXUS_CAPABILITY_REGISTRY_VAR, createHashMap];
private _entry = _registry getOrDefault [_normalizedId, createHashMap];

if ((count _entry) isEqualTo 0) exitWith {
    [false, "CAPABILITY_NOT_FOUND", format ["Capacidade não registrada: %1.", _normalizedId]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if !(_provider isEqualTo (_entry getOrDefault ["provider", ""])) exitWith {
    [false, "CAPABILITY_PROVIDER_MISMATCH", "Somente o provedor proprietário pode remover a capacidade."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

_registry deleteAt _normalizedId;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_NEXUS_CAPABILITY_REGISTRY_VAR, _registry];
[true, "CAPABILITY_UNREGISTERED", format ["Capacidade removida: %1.", _normalizedId]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
