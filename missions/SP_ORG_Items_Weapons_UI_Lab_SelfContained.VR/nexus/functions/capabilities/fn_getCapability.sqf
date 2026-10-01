#include "..\..\script_version.hpp"

params [["_capabilityId", "", [""]]];

private _normalizedId = toLowerANSI _capabilityId;
private _registry = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_NEXUS_CAPABILITY_REGISTRY_VAR, createHashMap];
private _entry = _registry getOrDefault [_normalizedId, createHashMap];

if ((count _entry) isEqualTo 0) exitWith {
    [false, "CAPABILITY_NOT_FOUND", format ["Capacidade não registrada: %1.", _normalizedId]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

[true, "CAPABILITY_FOUND", "Capacidade encontrada.", createHashMapFromArray [["capability", _entry]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
