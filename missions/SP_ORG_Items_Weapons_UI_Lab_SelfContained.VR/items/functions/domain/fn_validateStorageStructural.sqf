#include "..\..\script_version.hpp"

params [["_storage", [], [[]]]];

private _fail = {
    params ["_reason"];
    [
        false,
        "ITEMS_STORAGE_STRUCTURAL_INVALID",
        "Storage v1 inválido estruturalmente.",
        createHashMapFromArray [["level", "STRUCTURAL"], ["reason", _reason], ["storage", _storage]]
    ] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

if ((count _storage) != 4) exitWith {["FIELD_COUNT"] call _fail};
if !((_storage # 0) isEqualType "") exitWith {["MAGIC_TYPE"] call _fail};
if !((_storage # 1) isEqualType 0) exitWith {["VERSION_TYPE"] call _fail};
if !((_storage # 2) isEqualType []) exitWith {["KITS_TYPE"] call _fail};
if !((_storage # 3) isEqualType []) exitWith {["METADATA_TYPE"] call _fail};

private _badKitIndex = -1;
{
    private _kitResult = [_x] call ServoPeregrino_Organizador_Items_fnc_validateItemKitStructural;
    if !(_kitResult getOrDefault ["success", false]) exitWith {_badKitIndex = _forEachIndex;};
} forEach (_storage # 2);
if (_badKitIndex >= 0) exitWith {[format ["KIT_%1", _badKitIndex]] call _fail};

private _badMetadataIndex = (_storage # 3) findIf {
    !(_x isEqualType []) || {(count _x) != 2} || {!((_x # 0) isEqualType "")}
};
if (_badMetadataIndex >= 0) exitWith {[format ["METADATA_%1", _badMetadataIndex]] call _fail};

[
    true,
    "ITEMS_STORAGE_STRUCTURAL_VALID",
    "Storage v1 estruturalmente válido.",
    createHashMapFromArray [["level", "STRUCTURAL"], ["storage", _storage]]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
