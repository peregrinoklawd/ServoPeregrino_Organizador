#include "..\..\script_version.hpp"

params [
    ["_name", "Novo Kit", [""]],
    ["_preferredTarget", "ANY", [""]],
    ["_origin", ["MANUAL", "LOCAL"], [[]]],
    ["_entries", [], [[]]]
];

private _state = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR, createHashMap];
private _current = _state getOrDefault ["current", createHashMap];
if ((_state getOrDefault ["hasDraft", false]) && {_current getOrDefault ["dirty", false]}) exitWith {
    [false, "ITEMS_DRAFT_DIRTY_BLOCKS_REPLACE", "Existe um Draft dirty. Salve ou descarte explicitamente antes de abrir outro.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _target = toUpper _preferredTarget;
if (_target isEqualTo "U") then {_target = "UNIFORM";};
if (_target isEqualTo "C") then {_target = "VEST";};
if (_target isEqualTo "M") then {_target = "BACKPACK";};
if !(_target in ["ANY", "UNIFORM", "VEST", "BACKPACK"]) exitWith {
    [false, "ITEMS_DRAFT_TARGET_INVALID", "Target do Draft inválido.", createHashMapFromArray [["target", _preferredTarget]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if ((count _origin) isNotEqualTo 2 || {!((_origin # 0) isEqualType "")} || {!((_origin # 1) isEqualType "")} || {(_origin # 0) isEqualTo ""} || {(_origin # 1) isEqualTo ""}) exitWith {
    [false, "ITEMS_DRAFT_ORIGIN_INVALID", "Origin do Draft precisa ter exatamente duas strings não vazias.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _normalized = [_entries] call ServoPeregrino_Organizador_Items_fnc_normalizeItemEntries;
if !(_normalized getOrDefault ["success", false]) exitWith {_normalized};
private _now = systemTimeUTC;
private _draft = createHashMapFromArray [
    ["version", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_VERSION],
    ["mode", "NEW"],
    ["kitId", ""],
    ["baseUpdatedAtUTC", []],
    ["name", _name],
    ["preferredTarget", _target],
    ["origin", [_origin] call ServoPeregrino_Organizador_Items_fnc_deepCopy],
    ["entries", [((_normalized getOrDefault ["data", createHashMap]) getOrDefault ["entries", []])] call ServoPeregrino_Organizador_Items_fnc_deepCopy],
    ["dirty", true],
    ["createdFrom", "MANUAL"],
    ["openedAtUTC", +_now],
    ["lastModifiedAtUTC", +_now]
];
private _newState = createHashMapFromArray [
    ["ready", true], ["hasDraft", true], ["current", _draft], ["baseline", createHashMap],
    ["revision", (_state getOrDefault ["revision", 0]) + 1], ["lastAction", "CREATE_NEW"]
];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR, _newState];
[true, "ITEMS_DRAFT_NEW_CREATED", "Novo Draft NEW criado somente em memória.", createHashMapFromArray [["draft", [_draft] call ServoPeregrino_Organizador_Items_fnc_deepCopy]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
