#include "..\..\script_version.hpp"

if (missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_NEXUS_INITIALIZED_VAR, false]) exitWith {
    [true, "NEXUS_ALREADY_INITIALIZED", "O Nexus já estava inicializado.", createHashMapFromArray [["build", [] call ServoPeregrino_Organizador_Nexus_fnc_getBuildInfo]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_NEXUS_CAPABILITY_REGISTRY_VAR, createHashMap];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_NEXUS_CONTRACT_REGISTRY_VAR, createHashMap];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_NEXUS_EVENT_REGISTRY_VAR, createHashMap];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_NEXUS_LOG_LEVEL_VAR, 2];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_NEXUS_INITIALIZED_VAR, true];

[
    "nexus.runtime",
    1,
    "ServoPeregrino_Organizador_Nexus",
    createHashMapFromArray [["description", "Registro, contratos, eventos, resultados e diagnósticos."]]
] call ServoPeregrino_Organizador_Nexus_fnc_registerCapability;

[
    "nexus.runtime.status",
    1,
    "ServoPeregrino_Organizador_Nexus",
    ["status", "build"],
    createHashMapFromArray [["description", "Estado de execução do Nexus."]]
] call ServoPeregrino_Organizador_Nexus_fnc_registerContractDefinition;

[
    "NEXUS",
    "INFO",
    "Nexus inicializado.",
    createHashMapFromArray [["build", SERVO_PEREGRINO_ORGANIZADOR_NEXUS_BUILD]]
] call ServoPeregrino_Organizador_Nexus_fnc_log;

[true, "NEXUS_INITIALIZED", "Nexus inicializado com sucesso.", createHashMapFromArray [["build", [] call ServoPeregrino_Organizador_Nexus_fnc_getBuildInfo]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
