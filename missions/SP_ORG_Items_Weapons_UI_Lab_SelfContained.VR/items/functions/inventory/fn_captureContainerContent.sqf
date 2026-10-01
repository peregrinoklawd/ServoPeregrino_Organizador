#include "..\..\script_version.hpp"

params [
    ["_container", objNull, [objNull]],
    ["_target", "", [""]],
    ["_containerClass", "", [""]]
];

if (isNull _container) exitWith {
    [false, "ITEMS_CONTAINER_NULL", "Container físico nulo não pode ser capturado.", createHashMapFromArray [["target", _target]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _class = _containerClass;
if (_class isEqualTo "") then {_class = typeOf _container;};
private _analyzed = [getItemCargo _container, magazinesAmmoCargo _container, getWeaponCargo _container, getBackpackCargo _container] call ServoPeregrino_Organizador_Items_fnc_analyzeContainerCargo;
if !(_analyzed getOrDefault ["success", false]) exitWith {_analyzed};
private _ad = _analyzed getOrDefault ["data", createHashMap];

[
    true,
    "ITEMS_CONTAINER_CONTENT_CAPTURED",
    "Conteúdo mutável e reservado do container foi capturado sem mutação.",
    createHashMapFromArray [
        ["target", toUpper _target],
        ["container", _container],
        ["containerClass", _class],
        ["entries", [_ad getOrDefault ["entries", []]] call ServoPeregrino_Organizador_Items_fnc_deepCopy],
        ["reservedCargo", [_ad getOrDefault ["reservedCargo", []]] call ServoPeregrino_Organizador_Items_fnc_deepCopy],
        ["nestedObserved", count (everyContainer _container)]
    ]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
