#include "..\..\script_version.hpp"

params [["_level", "INFO", [""]]];

private _levels = createHashMapFromArray [
    ["TRACE", 0],
    ["DEBUG", 1],
    ["INFO", 2],
    ["WARN", 3],
    ["ERROR", 4],
    ["NONE", 5]
];
private _normalized = toUpperANSI _level;

if !(_normalized in (keys _levels)) exitWith {
    [false, "INVALID_LOG_LEVEL", format ["Nível de log inválido: %1", _level]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_NEXUS_LOG_LEVEL_VAR, _levels get _normalized];
[true, "LOG_LEVEL_UPDATED", format ["Nível de log alterado para %1.", _normalized], createHashMapFromArray [["level", _normalized]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
