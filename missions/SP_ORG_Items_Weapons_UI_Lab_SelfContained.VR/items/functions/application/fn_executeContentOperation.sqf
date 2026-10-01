params [
    ["_container", objNull, [objNull]],
    ["_target", "", [""]],
    ["_operation", "ADD", [""]],
    ["_entries", [], [[]]],
    ["_policy", "BEST_EFFORT", [""]],
    ["_context", createHashMap, [createHashMap]],
    ["_options", createHashMap, [createHashMap]]
];
private _op = toUpper _operation;
private _planR = switch (_op) do {
    case "ADD": {[_container, _target, _op, _entries, _policy, _context] call ServoPeregrino_Organizador_Items_fnc_createWholeKitApplicationPlan};
    case "REMOVE": {[_container, _target, _op, _entries, _policy, _context] call ServoPeregrino_Organizador_Items_fnc_createWholeKitApplicationPlan};
    case "REPLACE": {[_container, _target, _entries, _context] call ServoPeregrino_Organizador_Items_fnc_createReplaceApplicationPlan};
    case "CLEAR": {[_container, _target, _context] call ServoPeregrino_Organizador_Items_fnc_createClearApplicationPlan};
    default {[false, "ITEMS_WHOLE_KIT_OPERATION_INVALID", "Operação física de conteúdo desconhecida.", createHashMapFromArray [["operation", _op]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
};
if !(_planR getOrDefault ["success", false]) exitWith {_planR};
private _plan = ((_planR getOrDefault ["data", createHashMap]) getOrDefault ["plan", createHashMap]);
[_plan, _options] call ServoPeregrino_Organizador_Items_fnc_executeApplicationPlan
