#include "..\..\script_version.hpp"

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_NEXUS_INITIALIZED_VAR, false];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_NEXUS_CAPABILITY_REGISTRY_VAR, createHashMap];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_NEXUS_CONTRACT_REGISTRY_VAR, createHashMap];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_NEXUS_EVENT_REGISTRY_VAR, createHashMap];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_NEXUS_LOG_LEVEL_VAR, 2];
[] call ServoPeregrino_Organizador_Nexus_fnc_initialize
