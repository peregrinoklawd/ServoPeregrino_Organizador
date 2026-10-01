#include "..\..\script_version.hpp"
params [
    ["_container", objNull, [objNull]],
    ["_target", "", [""]],
    ["_desiredEntries", [], [[]]],
    ["_context", createHashMap, [createHashMap]]
];

private _canonicalTarget = toUpper _target;
if !(_canonicalTarget in ["UNIFORM", "VEST", "BACKPACK", "TEST_CONTAINER"]) exitWith {
    [false, "ITEMS_CONTAINER_TARGET_INVALID", "REPLACE exige target físico explícito; ANY nunca é target de commit.", createHashMapFromArray [["target", _target]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if (isNull _container) exitWith {[false, "ITEMS_CONTAINER_NULL", "REPLACE não pode planejar container nulo.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};

private _normalizedR = [_desiredEntries] call ServoPeregrino_Organizador_Items_fnc_normalizeItemEntries;
if !(_normalizedR getOrDefault ["success", false]) exitWith {_normalizedR};
private _desired = ((_normalizedR getOrDefault ["data", createHashMap]) getOrDefault ["entries", []]);
private _captureR = [_container, _canonicalTarget, _context getOrDefault ["containerClass", ""]] call ServoPeregrino_Organizador_Items_fnc_captureContainerContent;
if !(_captureR getOrDefault ["success", false]) exitWith {_captureR};
private _capture = _captureR getOrDefault ["data", createHashMap];
private _current = [_capture getOrDefault ["entries", []]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _reserved = [_capture getOrDefault ["reservedCargo", []]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _class = _capture getOrDefault ["containerClass", ""];
private _beforeFp = [_current, _reserved, _class, _canonicalTarget] call ServoPeregrino_Organizador_Items_fnc_buildMutableFingerprint;

private _physicalDesired = [];
private _invalid = createHashMap;
{
    private _entry = [_x] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
    private _env = [_entry] call ServoPeregrino_Organizador_Items_fnc_validateItemEntryEnvironmental;
    if !(_env getOrDefault ["success", false]) exitWith {_invalid = _env;};
    if ((_entry # 1) isEqualTo "MAGAZINE" && {(_entry # 4) isEqualTo "DEFAULT_FULL"}) then {
        private _maxAmmo = getNumber (configFile >> "CfgMagazines" >> (_entry # 2) >> "count");
        if (_maxAmmo <= 0) then {_maxAmmo = 1;};
        private _states = [];
        for "_i" from 1 to (_entry # 3) do {_states pushBack _maxAmmo;};
        _entry set [4, "EXACT"];
        _entry set [5, _states];
    };
    _physicalDesired pushBack _entry;
} forEach _desired;
if ((count _invalid) > 0) exitWith {
    [false, "ITEMS_PLAN_FAILED", "REPLACE STRICT recusado: existe classe/entrada indisponível.", createHashMapFromArray [["cause", _invalid]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _capacityR = [_container, _canonicalTarget, _context] call ServoPeregrino_Organizador_Items_fnc_getContainerCapacityMetrics;
private _capacity = if (_capacityR getOrDefault ["success", false]) then {_capacityR getOrDefault ["data", createHashMap]} else {createHashMapFromArray [["known", false], ["availableLoad", -1]]};
if (_capacity getOrDefault ["known", false]) then {
    private _reclaimable = 0;
    {
        private _massD = [_x] call ServoPeregrino_Organizador_Items_fnc_getEntryUnitMass;
        if (_massD getOrDefault ["known", false]) then {_reclaimable = _reclaimable + ((_massD getOrDefault ["mass", 0]) * (_x # 3));};
    } forEach _current;
    private _required = 0;
    private _massUnknown = false;
    {
        private _massD = [_x] call ServoPeregrino_Organizador_Items_fnc_getEntryUnitMass;
        if !(_massD getOrDefault ["known", false]) then {_massUnknown = true;} else {_required = _required + ((_massD getOrDefault ["mass", 0]) * (_x # 3));};
    } forEach _physicalDesired;
    if (!_massUnknown) then {
        private _availableAfterClear = (_capacity getOrDefault ["availableLoad", 0]) + _reclaimable;
        if (_required > (_availableAfterClear + 0.001)) exitWith {
            _invalid = [false, "ITEMS_TARGET_CAPACITY_INSUFFICIENT", "REPLACE STRICT não cabe integralmente após remover o CONTENT mutável atual.", createHashMapFromArray [["requiredLoad", _required], ["availableAfterClear", _availableAfterClear], ["capacity", _capacity]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult;
        };
    };
};
if ((count _invalid) > 0) exitWith {_invalid};

private _actions = [];
{
    _actions pushBack createHashMapFromArray [["operation", "REMOVE"], ["entry", [_x] call ServoPeregrino_Organizador_Items_fnc_deepCopy], ["sourceEntry", [_x] call ServoPeregrino_Organizador_Items_fnc_deepCopy], ["plannedQuantity", _x # 3]];
} forEach _current;
{
    _actions pushBack createHashMapFromArray [["operation", "ADD"], ["entry", [_x] call ServoPeregrino_Organizador_Items_fnc_deepCopy], ["sourceEntry", [_x] call ServoPeregrino_Organizador_Items_fnc_deepCopy], ["plannedQuantity", _x # 3]];
} forEach _physicalDesired;

private _expectedNormalizedR = [_physicalDesired] call ServoPeregrino_Organizador_Items_fnc_normalizeItemEntries;
if !(_expectedNormalizedR getOrDefault ["success", false]) exitWith {_expectedNormalizedR};
private _expectedEntries = ((_expectedNormalizedR getOrDefault ["data", createHashMap]) getOrDefault ["entries", []]);
private _expectedFp = [_expectedEntries, _reserved, _class, _canonicalTarget] call ServoPeregrino_Organizador_Items_fnc_buildMutableFingerprint;
private _planId = format ["sporg-items-replace-%1-%2", round (diag_tickTime * 1000), floor (random 1000000)];
private _plan = createHashMapFromArray [
    ["version", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_PLAN_VERSION], ["planId", _planId], ["status", "READY"],
    ["scope", "WHOLE_KIT"], ["operation", "REPLACE"], ["policy", "STRICT"], ["target", _canonicalTarget],
    ["container", _container], ["containerClass", _class], ["sourceProvider", _context getOrDefault ["sourceProvider", "VIRTUAL"]],
    ["requestedEntries", [_desired] call ServoPeregrino_Organizador_Items_fnc_deepCopy], ["actions", _actions], ["rejectedEntries", []],
    ["containerFingerprint", _beforeFp], ["expectedFingerprint", _expectedFp], ["expectedEntries", _expectedEntries],
    ["reservedCargo", _reserved], ["capacity", _capacity], ["noOp", (count _actions) isEqualTo 0], ["createdAtTick", diag_tickTime]
];
[true, "ITEMS_REPLACE_PLAN_READY", "REPLACE STRICT planejado como uma única transação remove+add.", createHashMapFromArray [["plan", _plan]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
