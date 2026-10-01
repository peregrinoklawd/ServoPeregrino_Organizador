params [
    ["_kit", [], [[]]],
    ["_newName", "", [""]]
];

private _validation = [_kit] call ServoPeregrino_Organizador_Items_fnc_validateItemKitSemantic;
if !(_validation getOrDefault ["success", false]) exitWith {_validation};

private _clone = [_kit] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _newId = [] call ServoPeregrino_Organizador_Items_fnc_generateItemKitId;
private _now = systemTimeUTC;
_clone set [2, _newId];
if !(_newName isEqualTo "") then {_clone set [3, _newName];};
_clone set [6, +_now];
_clone set [7, +_now];

private _cloneValidation = [_clone] call ServoPeregrino_Organizador_Items_fnc_validateItemKitSemantic;
if !(_cloneValidation getOrDefault ["success", false]) exitWith {_cloneValidation};

[
    true,
    "ITEMS_KIT_CLONED",
    "ItemKit clonado em memória com novo ID imutável.",
    createHashMapFromArray [["kit", _clone], ["sourceId", _kit # 2], ["cloneId", _newId]]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
