#include "..\..\script_version.hpp"

params [
    ["_contractId", "", [""]],
    ["_version", 1, [0]],
    ["_source", "", [""]],
    ["_payload", createHashMap, [createHashMap]],
    ["_correlationId", "", [""]]
];

if (_correlationId isEqualTo "") then {
    _correlationId = format ["contract-%1-%2", floor (diag_tickTime * 1000), floor (random 1000000000)];
};

createHashMapFromArray [
    ["schema", SERVO_PEREGRINO_ORGANIZADOR_NEXUS_CONTRACT_MAGIC],
    ["contract", toLowerANSI _contractId],
    ["version", _version],
    ["source", _source],
    ["correlationId", _correlationId],
    ["payload", _payload],
    ["createdAtUTC", systemTimeUTC]
]
