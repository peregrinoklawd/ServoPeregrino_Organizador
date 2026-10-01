#include "..\..\script_version.hpp"

params [
    ["_entryType", "ITEM", [""]],
    ["_className", "", [""]],
    ["_quantity", 1, [0]],
    ["_stateMode", "NONE", [""]],
    ["_stateData", [], [[]]]
];

private _entry = [
    SERVO_PEREGRINO_ORGANIZADOR_ITEMS_ENTRY_VERSION,
    toUpper _entryType,
    _className,
    _quantity,
    toUpper _stateMode,
    [_stateData] call ServoPeregrino_Organizador_Items_fnc_deepCopy
];

private _validation = [_entry] call ServoPeregrino_Organizador_Items_fnc_validateItemEntrySemantic;
if !(_validation getOrDefault ["success", false]) exitWith {_validation};

[
    true,
    "ITEMS_ENTRY_CREATED",
    "ItemEntry criada em memória.",
    createHashMapFromArray [["entry", _entry]]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
