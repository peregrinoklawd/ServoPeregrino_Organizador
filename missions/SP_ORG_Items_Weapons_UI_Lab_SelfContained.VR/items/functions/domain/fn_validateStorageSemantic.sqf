#include "..\..\script_version.hpp"

params [["_storage", [], [[]]]];

private _structural = [_storage] call ServoPeregrino_Organizador_Items_fnc_validateStorageStructural;
if !(_structural getOrDefault ["success", false]) exitWith {_structural};

private _fail = {
    params [
        ["_code", "ITEMS_STORAGE_SEMANTIC_INVALID", [""]],
        ["_reason", "", [""]]
    ];
    [
        false,
        _code,
        "Storage v1 inválido semanticamente.",
        createHashMapFromArray [["level", "SEMANTIC"], ["reason", _reason], ["storage", _storage]]
    ] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

if !((_storage # 0) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_STORAGE_MAGIC) exitWith {["ITEMS_STORAGE_INVALID_MAGIC", "MAGIC"] call _fail};
if !((_storage # 1) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_STORAGE_VERSION) exitWith {["ITEMS_STORAGE_UNSUPPORTED_VERSION", "VERSION"] call _fail};

private _kits = _storage # 2;
private _badKitResult = createHashMap;
private _badKitIndex = -1;
private _ids = [];
private _duplicateId = "";
{
    private _kitResult = [_x] call ServoPeregrino_Organizador_Items_fnc_validateItemKitSemantic;
    if !(_kitResult getOrDefault ["success", false]) exitWith {
        _badKitResult = _kitResult;
        _badKitIndex = _forEachIndex;
    };
    private _kitId = _x # 2;
    if (_kitId in _ids) exitWith {_duplicateId = _kitId;};
    _ids pushBack _kitId;
} forEach _kits;

if (_badKitIndex >= 0) exitWith {
    [
        false,
        _badKitResult getOrDefault ["code", "ITEMS_STORAGE_SEMANTIC_INVALID"],
        "Storage contém ItemKit inválido.",
        createHashMapFromArray [["level", "SEMANTIC"], ["kitIndex", _badKitIndex], ["kitResult", _badKitResult]]
    ] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if !(_duplicateId isEqualTo "") exitWith {["ITEMS_STORAGE_DUPLICATE_KIT_ID", _duplicateId] call _fail};

[
    true,
    "ITEMS_STORAGE_SEMANTIC_VALID",
    "Storage v1 semanticamente válido.",
    createHashMapFromArray [["level", "SEMANTIC"], ["kitCount", count _kits], ["storage", _storage]]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
