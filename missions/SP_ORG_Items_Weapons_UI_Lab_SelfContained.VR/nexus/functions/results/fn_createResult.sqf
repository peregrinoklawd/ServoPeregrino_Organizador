#include "..\..\script_version.hpp"

params [
    ["_success", false, [false]],
    ["_code", "", [""]],
    ["_message", "", [""]],
    ["_data", createHashMap, [createHashMap]],
    ["_diagnostics", [], [[]]]
];

createHashMapFromArray [
    ["schema", SERVO_PEREGRINO_ORGANIZADOR_NEXUS_RESULT_MAGIC],
    ["version", 1],
    ["success", _success],
    ["code", _code],
    ["message", _message],
    ["data", _data],
    ["diagnostics", _diagnostics],
    ["createdAtUTC", systemTimeUTC]
]
