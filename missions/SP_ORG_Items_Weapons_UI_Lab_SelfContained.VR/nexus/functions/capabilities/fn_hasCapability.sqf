#include "..\..\script_version.hpp"

params [
    ["_capabilityId", "", [""]],
    ["_minimumVersion", 1, [0]]
];

private _registry = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_NEXUS_CAPABILITY_REGISTRY_VAR, createHashMap];
private _entry = _registry getOrDefault [toLowerANSI _capabilityId, createHashMap];

(count _entry) > 0 && {(_entry getOrDefault ["version", 0]) >= _minimumVersion}
