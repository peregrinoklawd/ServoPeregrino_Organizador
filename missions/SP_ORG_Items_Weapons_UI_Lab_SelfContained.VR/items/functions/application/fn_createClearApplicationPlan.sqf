#include "..\..\script_version.hpp"
params [
    ["_container", objNull, [objNull]],
    ["_target", "", [""]],
    ["_context", createHashMap, [createHashMap]]
];

private _canonicalTarget = toUpper _target;
if !(_canonicalTarget in ["UNIFORM", "VEST", "BACKPACK", "TEST_CONTAINER"]) exitWith {
    [false, "ITEMS_CONTAINER_TARGET_INVALID", "CLEAR exige target físico explícito; ANY nunca é target de commit.", createHashMapFromArray [["target", _target]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if (isNull _container) exitWith {[false, "ITEMS_CONTAINER_NULL", "CLEAR não pode planejar container nulo.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};

private _captureR = [_container, _canonicalTarget, _context getOrDefault ["containerClass", ""]] call ServoPeregrino_Organizador_Items_fnc_captureContainerContent;
if !(_captureR getOrDefault ["success", false]) exitWith {_captureR};
private _capture = _captureR getOrDefault ["data", createHashMap];
private _current = [_capture getOrDefault ["entries", []]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _reserved = [_capture getOrDefault ["reservedCargo", []]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _class = _capture getOrDefault ["containerClass", ""];
private _beforeFp = [_current, _reserved, _class, _canonicalTarget] call ServoPeregrino_Organizador_Items_fnc_buildMutableFingerprint;
private _actions = _current apply {createHashMapFromArray [["operation", "REMOVE"], ["entry", [_x] call ServoPeregrino_Organizador_Items_fnc_deepCopy], ["sourceEntry", [_x] call ServoPeregrino_Organizador_Items_fnc_deepCopy], ["plannedQuantity", _x # 3]]};
private _expectedEntries = [];
private _expectedFp = [_expectedEntries, _reserved, _class, _canonicalTarget] call ServoPeregrino_Organizador_Items_fnc_buildMutableFingerprint;
private _planId = format ["sporg-items-clear-%1-%2", round (diag_tickTime * 1000), floor (random 1000000)];
private _plan = createHashMapFromArray [
    ["version", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_PLAN_VERSION], ["planId", _planId], ["status", "READY"],
    ["scope", "WHOLE_KIT"], ["operation", "CLEAR"], ["policy", "STRICT"], ["target", _canonicalTarget],
    ["container", _container], ["containerClass", _class], ["sourceProvider", _context getOrDefault ["sourceProvider", "VIRTUAL"]],
    ["requestedEntries", []], ["actions", _actions], ["rejectedEntries", []], ["containerFingerprint", _beforeFp],
    ["expectedFingerprint", _expectedFp], ["expectedEntries", _expectedEntries], ["reservedCargo", _reserved],
    ["noOp", (count _actions) isEqualTo 0], ["createdAtTick", diag_tickTime]
];
[true, "ITEMS_CLEAR_PLAN_READY", "CLEAR STRICT planejado sem tocar no estado físico.", createHashMapFromArray [["plan", _plan]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
