params [
    ["_container", objNull, [objNull]],
    ["_target", "", [""]],
    ["_context", createHashMap, [createHashMap]]
];

if (isNull _container) exitWith {
    [false, "ITEMS_CONTAINER_NULL", "Container nulo não possui métricas de capacidade.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _maxLoad = _context getOrDefault ["maxLoadOverride", -1];
private _currentLoad = _context getOrDefault ["currentLoadOverride", -1];
private _gearClass = _context getOrDefault ["gearClass", ""];
private _canonical = toUpper _target;

if (_currentLoad < 0) then {_currentLoad = loadAbs _container;};
if (_maxLoad < 0) then {
    switch (_canonical) do {
        case "UNIFORM": {
            private _containerClass = if (_gearClass isEqualTo "") then {""} else {getText (configFile >> "CfgWeapons" >> _gearClass >> "ItemInfo" >> "containerClass")};
            if !(_containerClass isEqualTo "") then {_maxLoad = getNumber (configFile >> "CfgVehicles" >> _containerClass >> "maximumLoad");};
        };
        case "VEST": {
            private _containerClass = if (_gearClass isEqualTo "") then {""} else {getText (configFile >> "CfgWeapons" >> _gearClass >> "ItemInfo" >> "containerClass")};
            if !(_containerClass isEqualTo "") then {_maxLoad = getNumber (configFile >> "CfgVehicles" >> _containerClass >> "maximumLoad");};
        };
        case "BACKPACK": {
            if !(_gearClass isEqualTo "") then {_maxLoad = getNumber (configFile >> "CfgVehicles" >> _gearClass >> "maximumLoad");};
        };
        default {
            private _type = typeOf _container;
            if !(_type isEqualTo "") then {_maxLoad = getNumber (configFile >> "CfgVehicles" >> _type >> "maximumLoad");};
        };
    };
};
private _known = _maxLoad > 0;
private _available = if (_known) then {(_maxLoad - _currentLoad) max 0} else {-1};
[
    true,
    "ITEMS_CONTAINER_CAPACITY_READY",
    "Métricas de capacidade do container calculadas.",
    createHashMapFromArray [["known", _known], ["maxLoad", _maxLoad max 0], ["currentLoad", _currentLoad max 0], ["availableLoad", _available], ["target", _canonical], ["gearClass", _gearClass]]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
