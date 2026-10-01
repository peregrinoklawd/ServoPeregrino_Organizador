#include "..\..\script_version.hpp"

params [
    ["_kits", [], [[]]],
    ["_metadata", [], [[]]]
];

private _resolvedMetadata = [_metadata] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
if ((count _resolvedMetadata) isEqualTo 0) then {
    _resolvedMetadata = [
        ["lastWriteUTC", systemTimeUTC],
        ["build", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD]
    ];
};

private _storage = [
    SERVO_PEREGRINO_ORGANIZADOR_ITEMS_STORAGE_MAGIC,
    SERVO_PEREGRINO_ORGANIZADOR_ITEMS_STORAGE_VERSION,
    [_kits] call ServoPeregrino_Organizador_Items_fnc_deepCopy,
    _resolvedMetadata
];

private _validation = [_storage] call ServoPeregrino_Organizador_Items_fnc_validateStorageSemantic;
if !(_validation getOrDefault ["success", false]) exitWith {_validation};

[
    true,
    "ITEMS_STORAGE_CREATED",
    "Storage v1 criado em memória; nenhuma persistência foi executada.",
    createHashMapFromArray [["storage", _storage]]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
