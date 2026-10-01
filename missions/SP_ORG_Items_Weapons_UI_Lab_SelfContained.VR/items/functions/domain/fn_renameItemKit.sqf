params [
    ["_kit", [], [[]]],
    ["_newName", "", [""]]
];

private _validation = [_kit] call ServoPeregrino_Organizador_Items_fnc_validateItemKitSemantic;
if !(_validation getOrDefault ["success", false]) exitWith {_validation};

private _renamed = [_kit] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
_renamed set [3, _newName];
_renamed set [7, systemTimeUTC];

private _renamedValidation = [_renamed] call ServoPeregrino_Organizador_Items_fnc_validateItemKitSemantic;
if !(_renamedValidation getOrDefault ["success", false]) exitWith {_renamedValidation};

[
    true,
    "ITEMS_KIT_RENAMED",
    "ItemKit renomeado em memória preservando o ID imutável.",
    createHashMapFromArray [["kit", _renamed], ["originalId", _kit # 2]]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
