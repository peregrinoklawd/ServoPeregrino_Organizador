#include "..\..\script_version.hpp"

params [
    ["_unit", objNull, [objNull]],
    ["_target", "", [""]]
];

private _resolved = [_unit, _target] call ServoPeregrino_Organizador_Items_fnc_resolvePlayerContainer;
if !(_resolved getOrDefault ["success", false]) exitWith {_resolved};
private _rd = _resolved getOrDefault ["data", createHashMap];
private _container = _rd getOrDefault ["container", objNull];

private _before = [_unit] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint;
if !(_before getOrDefault ["success", false]) exitWith {_before};
private _beforeData = _before getOrDefault ["data", createHashMap];

private _itemCargo = getItemCargo _container;
private _magCargo = magazinesAmmoCargo _container;
private _weaponCargo = getWeaponCargo _container;
private _backpackCargo = getBackpackCargo _container;
private _nestedObserved = count (everyContainer _container);

private _analyzed = [_itemCargo, _magCargo, _weaponCargo, _backpackCargo] call ServoPeregrino_Organizador_Items_fnc_analyzeContainerCargo;
if !(_analyzed getOrDefault ["success", false]) exitWith {_analyzed};

private _after = [_unit] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint;
if !(_after getOrDefault ["success", false]) exitWith {_after};
private _afterData = _after getOrDefault ["data", createHashMap];
private _unchanged = (_beforeData getOrDefault ["serialized", ""]) isEqualTo (_afterData getOrDefault ["serialized", "__DIFFERENT__"]);
if (!_unchanged) exitWith {
    [
        false,
        "ITEMS_CAPTURE_MUTATED_LOADOUT",
        "A captura detectou alteração do loadout entre início e fim e foi recusada.",
        createHashMapFromArray [["target", _rd getOrDefault ["target", ""]], ["before", _beforeData], ["after", _afterData]]
    ] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _ad = _analyzed getOrDefault ["data", createHashMap];
private _capacityR = [_container, _rd getOrDefault ["canonicalTarget", ""], createHashMapFromArray [["gearClass", _rd getOrDefault ["className", ""]]]] call ServoPeregrino_Organizador_Items_fnc_getContainerCapacityMetrics;
private _capacity = if (_capacityR getOrDefault ["success", false]) then {_capacityR getOrDefault ["data", createHashMap]} else {createHashMapFromArray [["known", false],["maxLoad",0],["currentLoad",loadAbs _container],["availableLoad",-1]]};
[
    true,
    "ITEMS_CONTAINER_CAPTURED_READ_ONLY",
    "Container capturado em modo somente leitura.",
    createHashMapFromArray [
        ["provider", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CONTAINER_PROVIDER],
        ["target", _rd getOrDefault ["target", ""]],
        ["canonicalTarget", _rd getOrDefault ["canonicalTarget", ""]],
        ["containerClass", _rd getOrDefault ["className", ""]],
        ["entries", _ad getOrDefault ["entries", []]],
        ["reservedCargo", _ad getOrDefault ["reservedCargo", []]],
        ["nestedObserved", _nestedObserved],
        ["loadoutUnchanged", true],
        ["capacity", _capacity],
        ["fingerprintBefore", _beforeData],
        ["fingerprintAfter", _afterData]
    ]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
