#include "..\..\script_version.hpp"

params [
    ["_minimumCapabilityVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_REQUIRED_NEXUS_VERSION, [0]]
];

private _localResult = {
    params [
        ["_success", false, [false]],
        ["_code", "", [""]],
        ["_message", "", [""]],
        ["_data", createHashMap, [createHashMap]]
    ];

    createHashMapFromArray [
        ["success", _success],
        ["code", _code],
        ["message", _message],
        ["data", _data],
        ["createdAtUTC", systemTimeUTC]
    ]
};

if (_minimumCapabilityVersion < 1) exitWith {
    [false, "ITEMS_NEXUS_VERSION_INVALID", "A versão mínima requerida do Nexus deve ser maior ou igual a 1."] call _localResult
};

private _requiredFunctions = [
    "ServoPeregrino_Organizador_Nexus_fnc_initialize",
    "ServoPeregrino_Organizador_Nexus_fnc_createResult",
    "ServoPeregrino_Organizador_Nexus_fnc_registerCapability",
    "ServoPeregrino_Organizador_Nexus_fnc_unregisterCapability",
    "ServoPeregrino_Organizador_Nexus_fnc_hasCapability",
    "ServoPeregrino_Organizador_Nexus_fnc_getCapability",
    "ServoPeregrino_Organizador_Nexus_fnc_log",
    "ServoPeregrino_Organizador_Nexus_fnc_publishEvent"
];

private _missingFunctions = _requiredFunctions select {isNil _x};
if ((count _missingFunctions) > 0) exitWith {
    [
        false,
        "ITEMS_NEXUS_REQUIRED",
        "O Nexus 1.1 não está disponível ou sua API mínima não foi carregada.",
        createHashMapFromArray [["missingFunctions", _missingFunctions]]
    ] call _localResult
};

private _nexusInit = [] call ServoPeregrino_Organizador_Nexus_fnc_initialize;
if !(_nexusInit getOrDefault ["success", false]) exitWith {
    [
        false,
        "ITEMS_NEXUS_INITIALIZATION_FAILED",
        "O Nexus existe, mas não pôde ser inicializado.",
        createHashMapFromArray [["nexusResult", _nexusInit]]
    ] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

if !([SERVO_PEREGRINO_ORGANIZADOR_ITEMS_REQUIRED_NEXUS_CAPABILITY, _minimumCapabilityVersion] call ServoPeregrino_Organizador_Nexus_fnc_hasCapability) exitWith {
    [
        false,
        "ITEMS_NEXUS_INCOMPATIBLE",
        format [
            "O Nexus não oferece %1 v%2 ou superior.",
            SERVO_PEREGRINO_ORGANIZADOR_ITEMS_REQUIRED_NEXUS_CAPABILITY,
            _minimumCapabilityVersion
        ],
        createHashMapFromArray [
            ["requiredCapability", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_REQUIRED_NEXUS_CAPABILITY],
            ["requiredVersion", _minimumCapabilityVersion]
        ]
    ] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _capabilityResult = [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_REQUIRED_NEXUS_CAPABILITY] call ServoPeregrino_Organizador_Nexus_fnc_getCapability;
if !(_capabilityResult getOrDefault ["success", false]) exitWith {
    [
        false,
        "ITEMS_NEXUS_CAPABILITY_LOOKUP_FAILED",
        "A capability obrigatória do Nexus não pôde ser consultada.",
        createHashMapFromArray [["nexusResult", _capabilityResult]]
    ] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _capability = (_capabilityResult getOrDefault ["data", createHashMap]) getOrDefault ["capability", createHashMap];
if !((_capability getOrDefault ["provider", ""]) isEqualTo "ServoPeregrino_Organizador_Nexus") exitWith {
    [
        false,
        "ITEMS_NEXUS_PROVIDER_INVALID",
        "A capability nexus.runtime foi registrada por um provedor inesperado.",
        createHashMapFromArray [["capability", _capability]]
    ] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

[
    true,
    "ITEMS_NEXUS_COMPATIBLE",
    "Nexus compatível com SP_ORG_Items.",
    createHashMapFromArray [["capability", _capability]]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
