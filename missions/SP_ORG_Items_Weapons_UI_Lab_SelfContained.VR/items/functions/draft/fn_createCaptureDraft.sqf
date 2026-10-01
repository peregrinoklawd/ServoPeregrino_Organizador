#include "..\..\script_version.hpp"

params [
    ["_entries", [], [[]]],
    ["_target", "ANY", [""]],
    ["_name", "Captura de equipamento", [""]]
];

private _normalizedResult = [_entries] call ServoPeregrino_Organizador_Items_fnc_normalizeItemEntries;
if !(_normalizedResult getOrDefault ["success", false]) exitWith {_normalizedResult};
private _normalizedEntries = (_normalizedResult getOrDefault ["data", createHashMap]) getOrDefault ["entries", []];
private _t = toUpper _target;
if (_t isEqualTo "U") then {_t = "UNIFORM";};
if (_t isEqualTo "C") then {_t = "VEST";};
if (_t isEqualTo "M") then {_t = "BACKPACK";};
if !(_t in ["ANY", "UNIFORM", "VEST", "BACKPACK"]) then {_t = "ANY";};

private _draft = createHashMapFromArray [
    ["version", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CAPTURE_DRAFT_VERSION],
    ["mode", "NEW"],
    ["kitId", ""],
    ["baseUpdatedAtUTC", []],
    ["name", _name],
    ["preferredTarget", _t],
    ["origin", ["CAPTURE", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CONTAINER_PROVIDER]],
    ["entries", [_normalizedEntries] call ServoPeregrino_Organizador_Items_fnc_deepCopy],
    ["dirty", true],
    ["createdFrom", "CAPTURE"],
    ["capturedAtUTC", systemTimeUTC]
];

[
    true,
    "ITEMS_CAPTURE_DRAFT_CREATED",
    "Draft NEW de captura criado somente em memória; Repository não foi alterado.",
    createHashMapFromArray [["draft", _draft]]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
