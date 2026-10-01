params [
    ["_unit", objNull, [objNull]],
    ["_target", "", [""]]
];

if (isNull _unit) exitWith {
    [false, "ITEMS_CAPTURE_UNIT_NULL", "Unidade nula não possui containers PLAYER_CONTAINERS.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if (!local _unit) exitWith {
    [false, "ITEMS_CAPTURE_UNIT_NOT_LOCAL", "PLAYER_CONTAINERS só resolve a unidade local nesta baseline.", createHashMapFromArray [["target", _target]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _normalized = toUpper _target;
if (_normalized isEqualTo "UNIFORM") then {_normalized = "U";};
if (_normalized isEqualTo "VEST") then {_normalized = "C";};
if (_normalized isEqualTo "BACKPACK") then {_normalized = "M";};
if !(_normalized in ["U", "C", "M"]) exitWith {
    [false, "ITEMS_CONTAINER_TARGET_INVALID", "Target de container inválido; use U/C/M.", createHashMapFromArray [["target", _target]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _container = objNull;
private _className = "";
private _canonical = "";
switch (_normalized) do {
    case "U": {_container = uniformContainer _unit; _className = uniform _unit; _canonical = "UNIFORM";};
    case "C": {_container = vestContainer _unit; _className = vest _unit; _canonical = "VEST";};
    case "M": {_container = backpackContainer _unit; _className = backpack _unit; _canonical = "BACKPACK";};
};

if ((_className isEqualTo "") || {isNull _container}) exitWith {
    [
        false,
        "ITEMS_CONTAINER_ABSENT",
        "O container solicitado não está equipado; nenhum estado foi alterado.",
        createHashMapFromArray [["target", _normalized], ["canonicalTarget", _canonical], ["present", false], ["className", _className]]
    ] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

[
    true,
    "ITEMS_CONTAINER_RESOLVED",
    "Container PLAYER_CONTAINERS resolvido.",
    createHashMapFromArray [["target", _normalized], ["canonicalTarget", _canonical], ["present", true], ["className", _className], ["container", _container]]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
