#include "..\..\script_version.hpp"

params [["_entry", [], [[]]]];

private _fail = {
    params ["_reason"];
    [
        false,
        "ITEMS_ENTRY_INVALID",
        "ItemEntry inválida estruturalmente.",
        createHashMapFromArray [["level", "STRUCTURAL"], ["reason", _reason], ["entry", _entry]]
    ] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

if ((count _entry) != 6) exitWith {["FIELD_COUNT"] call _fail};
if !((_entry # 0) isEqualType 0) exitWith {["VERSION_TYPE"] call _fail};
if !((_entry # 1) isEqualType "") exitWith {["ENTRY_TYPE_TYPE"] call _fail};
if !((_entry # 2) isEqualType "") exitWith {["CLASSNAME_TYPE"] call _fail};
if !((_entry # 3) isEqualType 0) exitWith {["QUANTITY_TYPE"] call _fail};
if !((_entry # 4) isEqualType "") exitWith {["STATE_MODE_TYPE"] call _fail};
if !((_entry # 5) isEqualType []) exitWith {["STATE_DATA_TYPE"] call _fail};

private _stateData = _entry # 5;
private _badStateType = _stateData findIf {!(_x isEqualType 0)};
if (_badStateType >= 0) exitWith {["STATE_DATA_VALUE_TYPE"] call _fail};

[
    true,
    "ITEMS_ENTRY_STRUCTURAL_VALID",
    "ItemEntry estruturalmente válida.",
    createHashMapFromArray [["level", "STRUCTURAL"], ["entry", _entry]]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
