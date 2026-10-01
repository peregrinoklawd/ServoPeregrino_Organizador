#include "..\..\script_version.hpp"
params [
    ["_container", objNull, [objNull]],
    ["_target", "", [""]],
    ["_operation", "ADD", [""]],
    ["_requestedEntries", [], [[]]],
    ["_policy", "BEST_EFFORT", [""]],
    ["_context", createHashMap, [createHashMap]]
];

private _op = toUpper _operation;
private _pol = toUpper _policy;
private _canonicalTarget = toUpper _target;
if !(_op in ["ADD", "REMOVE"]) exitWith {[false, "ITEMS_OPERATION_DEFERRED_0_10", "A Entrega 0.9 executa somente ADD/REMOVE unitários; REPLACE/CLEAR permanecem para 0.10.", createHashMapFromArray [["operation", _op]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
if !(_pol in ["BEST_EFFORT", "STRICT"]) exitWith {[false, "ITEMS_APPLICATION_POLICY_INVALID", "Política inválida; use BEST_EFFORT ou STRICT.", createHashMapFromArray [["policy", _policy]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
if !(_canonicalTarget in ["UNIFORM", "VEST", "BACKPACK", "TEST_CONTAINER"]) exitWith {[false, "ITEMS_CONTAINER_TARGET_INVALID", "Target físico de aplicação inválido; ANY nunca é target de commit.", createHashMapFromArray [["target", _target]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
if (isNull _container) exitWith {[false, "ITEMS_CONTAINER_NULL", "Não é possível criar plano para container nulo.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};

private _normalizedR = [_requestedEntries] call ServoPeregrino_Organizador_Items_fnc_normalizeItemEntries;
if !(_normalizedR getOrDefault ["success", false]) exitWith {_normalizedR};
private _requested = ((_normalizedR getOrDefault ["data", createHashMap]) getOrDefault ["entries", []]);
if ((count _requested) isEqualTo 0) exitWith {[false, "ITEMS_PLAN_FAILED", "Plano físico precisa de ao menos uma ItemEntry solicitada.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};

private _captureR = [_container, _canonicalTarget, _context getOrDefault ["containerClass", ""]] call ServoPeregrino_Organizador_Items_fnc_captureContainerContent;
if !(_captureR getOrDefault ["success", false]) exitWith {_captureR};
private _capture = _captureR getOrDefault ["data", createHashMap];
private _fp = [_capture getOrDefault ["entries", []], _capture getOrDefault ["reservedCargo", []], _capture getOrDefault ["containerClass", ""], _canonicalTarget] call ServoPeregrino_Organizador_Items_fnc_buildMutableFingerprint;
private _capacityR = [_container, _canonicalTarget, _context] call ServoPeregrino_Organizador_Items_fnc_getContainerCapacityMetrics;
private _capacity = if (_capacityR getOrDefault ["success", false]) then {_capacityR getOrDefault ["data", createHashMap]} else {createHashMapFromArray [["known", false], ["availableLoad", -1]]};
private _availableLoad = _capacity getOrDefault ["availableLoad", -1];
private _actions = [];
private _rejected = [];
private _current = [_capture getOrDefault ["entries", []]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;

private _pushReject = {
    params ["_entry", "_requestedQty", "_plannedQty", "_code", "_message"];
    _rejected pushBack createHashMapFromArray [["entry", [_entry] call ServoPeregrino_Organizador_Items_fnc_deepCopy], ["requestedQuantity", _requestedQty], ["plannedQuantity", _plannedQty], ["code", _code], ["message", _message]];
};

{
    private _entry = [_x] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
    private _env = [_entry] call ServoPeregrino_Organizador_Items_fnc_validateItemEntryEnvironmental;
    if !(_env getOrDefault ["success", false]) then {
        [_entry, _entry # 3, 0, _env getOrDefault ["code", "ITEMS_CLASS_UNAVAILABLE"], _env getOrDefault ["message", "Classe indisponível."]] call _pushReject;
    } else {
        private _type = _entry # 1;
        private _className = _entry # 2;
        private _qty = _entry # 3;
        private _mode = _entry # 4;
        private _states = +(_entry # 5);
        private _physicalEntry = [_entry] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
        private _plannedQty = _qty;

        if (_op isEqualTo "ADD") then {
            if (_type isEqualTo "MAGAZINE" && {_mode isEqualTo "DEFAULT_FULL"}) then {
                private _maxAmmo = getNumber (configFile >> "CfgMagazines" >> _className >> "count");
                if (_maxAmmo <= 0) then {_maxAmmo = 1;};
                _physicalEntry set [4, "EXACT"];
                _physicalEntry set [5, []];
                for "_mi" from 1 to _qty do {(_physicalEntry # 5) pushBack _maxAmmo;};
            };
            private _massData = [_entry] call ServoPeregrino_Organizador_Items_fnc_getEntryUnitMass;
            private _unitMass = _massData getOrDefault ["mass", 0];
            if ((_availableLoad >= 0) && {_unitMass > 0}) then {
                _plannedQty = floor (_availableLoad / _unitMass);
                if (_plannedQty > _qty) then {_plannedQty = _qty;};
                if (_plannedQty < 0) then {_plannedQty = 0;};
                _availableLoad = (_availableLoad - (_plannedQty * _unitMass)) max 0;
            };
            if (_plannedQty > 0) then {
                _physicalEntry set [3, _plannedQty];
                if ((_physicalEntry # 4) isEqualTo "EXACT") then {_physicalEntry set [5, (+(_physicalEntry # 5)) select [0, _plannedQty]];};
                _actions pushBack createHashMapFromArray [["operation", "ADD"], ["entry", _physicalEntry], ["sourceEntry", _entry], ["plannedQuantity", _plannedQty]];
            };
            if (_plannedQty < _qty) then {[_entry, _qty, _plannedQty, "ITEMS_TARGET_CAPACITY_INSUFFICIENT", "Capacidade estimada não comporta toda a quantidade solicitada."] call _pushReject;};
        } else {
            if (_type isEqualTo "ITEM") then {
                private _idx = _current findIf {(_x # 1) isEqualTo "ITEM" && {(_x # 2) isEqualTo _className} && {(_x # 4) isEqualTo "NONE"}};
                private _availableQty = if (_idx < 0) then {0} else {(_current # _idx) # 3};
                _plannedQty = _qty min _availableQty;
                if (_plannedQty > 0) then {_physicalEntry set [3, _plannedQty]; _actions pushBack createHashMapFromArray [["operation", "REMOVE"], ["entry", _physicalEntry], ["sourceEntry", _entry], ["plannedQuantity", _plannedQty]];};
                if (_plannedQty < _qty) then {[_entry, _qty, _plannedQty, "ITEMS_CONTENT_NOT_PRESENT", "Container não possui toda a quantidade solicitada para remoção."] call _pushReject;};
            } else {
                private _idx = _current findIf {(_x # 1) isEqualTo "MAGAZINE" && {(_x # 2) isEqualTo _className} && {(_x # 4) isEqualTo "EXACT"}};
                private _availableStates = if (_idx < 0) then {[]} else {+((_current # _idx) # 5)};
                private _wantedStates = [];
                if (_mode isEqualTo "DEFAULT_FULL") then {
                    private _maxAmmo = getNumber (configFile >> "CfgMagazines" >> _className >> "count");
                    {if (_x isEqualTo _maxAmmo && {(count _wantedStates) < _qty}) then {_wantedStates pushBack _x;};} forEach _availableStates;
                } else {
                    private _pool = +_availableStates;
                    {
                        private _find = _pool find _x;
                        if (_find >= 0) then {_wantedStates pushBack _x; _pool deleteAt _find;};
                    } forEach _states;
                };
                _plannedQty = count _wantedStates;
                if (_plannedQty > 0) then {
                    _physicalEntry set [3, _plannedQty];
                    _physicalEntry set [4, "EXACT"];
                    _physicalEntry set [5, _wantedStates];
                    _actions pushBack createHashMapFromArray [["operation", "REMOVE"], ["entry", _physicalEntry], ["sourceEntry", _entry], ["plannedQuantity", _plannedQty]];
                };
                if (_plannedQty < _qty) then {[_entry, _qty, _plannedQty, "ITEMS_CONTENT_NOT_PRESENT", "Container não possui todos os magazines/estados solicitados para remoção."] call _pushReject;};
            };
        };
    };
} forEach _requested;

if (_pol isEqualTo "STRICT" && {(count _rejected) > 0}) exitWith {
    [false, "ITEMS_PLAN_FAILED", "Política STRICT recusou um plano com entradas rejeitadas.", createHashMapFromArray [["rejectedEntries", _rejected], ["capacity", _capacity]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if ((count _actions) isEqualTo 0) exitWith {
    [false, "ITEMS_PLAN_FAILED", "Nenhuma ação física executável foi produzida.", createHashMapFromArray [["rejectedEntries", _rejected], ["capacity", _capacity]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _simR = [_current, _actions] call ServoPeregrino_Organizador_Items_fnc_simulateApplicationEntries;
if !(_simR getOrDefault ["success", false]) exitWith {_simR};
private _expectedEntries = ((_simR getOrDefault ["data", createHashMap]) getOrDefault ["entries", []]);
private _expectedFp = [_expectedEntries, _capture getOrDefault ["reservedCargo", []], _capture getOrDefault ["containerClass", ""], _canonicalTarget] call ServoPeregrino_Organizador_Items_fnc_buildMutableFingerprint;
private _planId = format ["sporg-items-plan-%1-%2", round (diag_tickTime * 1000), floor (random 1000000)];
private _plan = createHashMapFromArray [
    ["version", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_PLAN_VERSION], ["planId", _planId], ["status", "READY"], ["operation", _op], ["policy", _pol], ["target", _canonicalTarget],
    ["container", _container], ["containerClass", _capture getOrDefault ["containerClass", ""]], ["sourceProvider", _context getOrDefault ["sourceProvider", "VIRTUAL"]],
    ["requestedEntries", [_requested] call ServoPeregrino_Organizador_Items_fnc_deepCopy], ["actions", _actions], ["rejectedEntries", _rejected],
    ["containerFingerprint", _fp], ["expectedFingerprint", _expectedFp], ["expectedEntries", _expectedEntries], ["capacity", _capacity],
    ["createdAtTick", diag_tickTime]
];
[
    true,
    "ITEMS_APPLICATION_PLAN_READY",
    "ApplicationPlan v1 criado sem mutação física.",
    createHashMapFromArray [["plan", _plan]]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
