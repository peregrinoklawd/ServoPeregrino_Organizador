#include "..\..\script_version.hpp"

params [
    ["_name", "", [""]],
    ["_entries", [], [[]]],
    ["_preferredTarget", "ANY", [""]],
    ["_origin", ["MANUAL", "LOCAL"], [[]]],
    ["_kitId", "", [""]]
];

private _normalizedResult = [_entries] call ServoPeregrino_Organizador_Items_fnc_normalizeItemEntries;
if !(_normalizedResult getOrDefault ["success", false]) exitWith {_normalizedResult};
private _normalizedEntries = (_normalizedResult getOrDefault ["data", createHashMap]) getOrDefault ["entries", []];

if ((count _normalizedEntries) isEqualTo 0) exitWith {
    [
        false,
        "ITEMS_KIT_PAYLOAD_EMPTY",
        "Um ItemKit persistível precisa conter ao menos uma ItemEntry.",
        createHashMapFromArray [["name", _name]]
    ] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _resolvedId = _kitId;
if (_resolvedId isEqualTo "") then {
    _resolvedId = [] call ServoPeregrino_Organizador_Items_fnc_generateItemKitId;
};

private _now = systemTimeUTC;
private _kit = [
    SERVO_PEREGRINO_ORGANIZADOR_ITEMS_KIT_MAGIC,
    SERVO_PEREGRINO_ORGANIZADOR_ITEMS_KIT_VERSION,
    _resolvedId,
    _name,
    toUpper _preferredTarget,
    [_origin] call ServoPeregrino_Organizador_Items_fnc_deepCopy,
    +_now,
    +_now,
    _normalizedEntries,
    []
];

private _validation = [_kit] call ServoPeregrino_Organizador_Items_fnc_validateItemKitSemantic;
if !(_validation getOrDefault ["success", false]) exitWith {_validation};

[
    true,
    "ITEMS_KIT_CREATED",
    "ItemKit v1 criado em memória.",
    createHashMapFromArray [["kit", _kit]]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
