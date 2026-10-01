#include "..\..\script_version.hpp"

params [["_entry", [], [[]]]];

private _structural = [_entry] call ServoPeregrino_Organizador_Items_fnc_validateItemEntryStructural;
if !(_structural getOrDefault ["success", false]) exitWith {_structural};

private _fail = {
    params [
        ["_code", "ITEMS_ENTRY_INVALID", [""]],
        ["_reason", "", [""]]
    ];
    [
        false,
        _code,
        "ItemEntry inválida semanticamente.",
        createHashMapFromArray [["level", "SEMANTIC"], ["reason", _reason], ["entry", _entry]]
    ] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _version = _entry # 0;
private _entryType = _entry # 1;
private _className = _entry # 2;
private _quantity = _entry # 3;
private _stateMode = _entry # 4;
private _stateData = _entry # 5;

if !(_version isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_ENTRY_VERSION) exitWith {["ITEMS_ENTRY_INVALID", "VERSION"] call _fail};
if !(_entryType in ["ITEM", "MAGAZINE"]) exitWith {["ITEMS_ENTRY_INVALID", "ENTRY_TYPE"] call _fail};

private _classChars = toArray _className;
private _nonWhitespace = _classChars findIf {!(_x in [9, 10, 13, 32])};
if ((_className isEqualTo "") || {_nonWhitespace < 0}) exitWith {["ITEMS_ENTRY_INVALID", "CLASSNAME_EMPTY"] call _fail};

if ((_quantity <= 0) || {!(_quantity isEqualTo floor _quantity)}) exitWith {["ITEMS_ENTRY_INVALID", "QUANTITY"] call _fail};

if (_entryType isEqualTo "ITEM") exitWith {
    if !(_stateMode isEqualTo "NONE") exitWith {["ITEMS_ENTRY_INVALID", "ITEM_STATE_MODE"] call _fail};
    if ((count _stateData) != 0) exitWith {["ITEMS_ENTRY_INVALID", "ITEM_STATE_DATA"] call _fail};
    [
        true,
        "ITEMS_ENTRY_SEMANTIC_VALID",
        "ItemEntry semanticamente válida.",
        createHashMapFromArray [["level", "SEMANTIC"], ["entry", _entry]]
    ] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

if !(_stateMode in ["DEFAULT_FULL", "EXACT"]) exitWith {["ITEMS_ENTRY_INVALID", "MAGAZINE_STATE_MODE"] call _fail};

if (_stateMode isEqualTo "DEFAULT_FULL") exitWith {
    if ((count _stateData) != 0) exitWith {["ITEMS_ENTRY_INVALID", "DEFAULT_FULL_STATE_DATA"] call _fail};
    [
        true,
        "ITEMS_ENTRY_SEMANTIC_VALID",
        "ItemEntry semanticamente válida.",
        createHashMapFromArray [["level", "SEMANTIC"], ["entry", _entry]]
    ] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

if !(_quantity isEqualTo count _stateData) exitWith {
    ["ITEMS_MAG_EXACT_COUNT_MISMATCH", "EXACT_COUNT_MISMATCH"] call _fail
};

private _badAmmo = _stateData findIf {(_x < 0) || {!(_x isEqualTo floor _x)}};
if (_badAmmo >= 0) exitWith {["ITEMS_ENTRY_INVALID", "EXACT_AMMO_VALUE"] call _fail};

[
    true,
    "ITEMS_ENTRY_SEMANTIC_VALID",
    "ItemEntry semanticamente válida.",
    createHashMapFromArray [["level", "SEMANTIC"], ["entry", _entry]]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
