#include "..\..\script_version.hpp"

params [["_kit", [], [[]]]];

private _structural = [_kit] call ServoPeregrino_Organizador_Items_fnc_validateItemKitStructural;
if !(_structural getOrDefault ["success", false]) exitWith {_structural};

private _fail = {
    params [
        ["_code", "ITEMS_KIT_SEMANTIC_INVALID", [""]],
        ["_reason", "", [""]]
    ];
    [
        false,
        _code,
        "ItemKit inválido semanticamente.",
        createHashMapFromArray [["level", "SEMANTIC"], ["reason", _reason], ["kit", _kit]]
    ] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

if !((_kit # 0) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_KIT_MAGIC) exitWith {["ITEMS_KIT_SEMANTIC_INVALID", "MAGIC"] call _fail};
if !((_kit # 1) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_KIT_VERSION) exitWith {["ITEMS_KIT_SEMANTIC_INVALID", "VERSION"] call _fail};
if !([_kit # 2] call ServoPeregrino_Organizador_Items_fnc_isValidItemKitId) exitWith {["ITEMS_KIT_ID_INVALID", "ID"] call _fail};

private _name = _kit # 3;
private _nameChars = toArray _name;
private _nonWhitespace = _nameChars findIf {!(_x in [9, 10, 13, 32])};
if ((_name isEqualTo "") || {_nonWhitespace < 0} || {(count _name) > SERVO_PEREGRINO_ORGANIZADOR_ITEMS_KIT_NAME_MAX_LENGTH}) exitWith {["ITEMS_KIT_NAME_INVALID", "NAME"] call _fail};

if !((_kit # 4) in ["ANY", "UNIFORM", "VEST", "BACKPACK"]) exitWith {["ITEMS_KIT_SEMANTIC_INVALID", "PREFERRED_TARGET"] call _fail};

private _origin = _kit # 5;
if (((_origin # 0) isEqualTo "") || {(_origin # 1) isEqualTo ""}) exitWith {["ITEMS_KIT_SEMANTIC_INVALID", "ORIGIN_EMPTY"] call _fail};

private _entries = _kit # 8;
if ((count _entries) isEqualTo 0) exitWith {["ITEMS_KIT_PAYLOAD_EMPTY", "ENTRIES_EMPTY"] call _fail};

private _badEntryResult = createHashMap;
private _badEntryIndex = -1;
{
    private _entryResult = [_x] call ServoPeregrino_Organizador_Items_fnc_validateItemEntrySemantic;
    if !(_entryResult getOrDefault ["success", false]) exitWith {
        _badEntryResult = _entryResult;
        _badEntryIndex = _forEachIndex;
    };
} forEach _entries;
if (_badEntryIndex >= 0) exitWith {
    [
        false,
        _badEntryResult getOrDefault ["code", "ITEMS_ENTRY_INVALID"],
        "ItemKit contém ItemEntry semanticamente inválida.",
        createHashMapFromArray [["level", "SEMANTIC"], ["entryIndex", _badEntryIndex], ["entryResult", _badEntryResult]]
    ] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _normalizedResult = [_entries] call ServoPeregrino_Organizador_Items_fnc_normalizeItemEntries;
private _normalizedEntries = (_normalizedResult getOrDefault ["data", createHashMap]) getOrDefault ["entries", []];
if !(_entries isEqualTo _normalizedEntries) exitWith {["ITEMS_KIT_SEMANTIC_INVALID", "ENTRIES_NOT_NORMALIZED"] call _fail};

[
    true,
    "ITEMS_KIT_SEMANTIC_VALID",
    "ItemKit semanticamente válido.",
    createHashMapFromArray [["level", "SEMANTIC"], ["kit", _kit]]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
