#include "..\..\script_version.hpp"

params [["_kit", [], [[]]]];

private _fail = {
    params ["_reason"];
    [
        false,
        "ITEMS_KIT_STRUCTURAL_INVALID",
        "ItemKit inválido estruturalmente.",
        createHashMapFromArray [["level", "STRUCTURAL"], ["reason", _reason], ["kit", _kit]]
    ] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

if ((count _kit) != 10) exitWith {["FIELD_COUNT"] call _fail};
if !((_kit # 0) isEqualType "") exitWith {["MAGIC_TYPE"] call _fail};
if !((_kit # 1) isEqualType 0) exitWith {["VERSION_TYPE"] call _fail};
if !((_kit # 2) isEqualType "") exitWith {["ID_TYPE"] call _fail};
if !((_kit # 3) isEqualType "") exitWith {["NAME_TYPE"] call _fail};
if !((_kit # 4) isEqualType "") exitWith {["TARGET_TYPE"] call _fail};
if !((_kit # 5) isEqualType []) exitWith {["ORIGIN_TYPE"] call _fail};
if !((_kit # 6) isEqualType []) exitWith {["CREATED_AT_TYPE"] call _fail};
if !((_kit # 7) isEqualType []) exitWith {["UPDATED_AT_TYPE"] call _fail};
if !((_kit # 8) isEqualType []) exitWith {["ENTRIES_TYPE"] call _fail};
if !((_kit # 9) isEqualType []) exitWith {["METADATA_TYPE"] call _fail};

private _origin = _kit # 5;
if ((count _origin) != 2) exitWith {["ORIGIN_FIELD_COUNT"] call _fail};
if ((_origin findIf {!(_x isEqualType "")}) >= 0) exitWith {["ORIGIN_VALUE_TYPE"] call _fail};

if ((count (_kit # 6)) != 7) exitWith {["CREATED_AT_FIELD_COUNT"] call _fail};
if ((count (_kit # 7)) != 7) exitWith {["UPDATED_AT_FIELD_COUNT"] call _fail};
if (((_kit # 6) findIf {!(_x isEqualType 0)}) >= 0) exitWith {["CREATED_AT_VALUE_TYPE"] call _fail};
if (((_kit # 7) findIf {!(_x isEqualType 0)}) >= 0) exitWith {["UPDATED_AT_VALUE_TYPE"] call _fail};

private _badEntryIndex = -1;
{
    private _entryResult = [_x] call ServoPeregrino_Organizador_Items_fnc_validateItemEntryStructural;
    if !(_entryResult getOrDefault ["success", false]) exitWith {_badEntryIndex = _forEachIndex;};
} forEach (_kit # 8);
if (_badEntryIndex >= 0) exitWith {[format ["ENTRY_%1", _badEntryIndex]] call _fail};

[
    true,
    "ITEMS_KIT_STRUCTURAL_VALID",
    "ItemKit estruturalmente válido.",
    createHashMapFromArray [["level", "STRUCTURAL"], ["kit", _kit]]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
