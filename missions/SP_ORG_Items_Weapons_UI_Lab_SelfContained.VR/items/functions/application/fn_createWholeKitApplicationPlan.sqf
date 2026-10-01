params [
    ["_container", objNull, [objNull]],
    ["_target", "", [""]],
    ["_operation", "ADD", [""]],
    ["_entries", [], [[]]],
    ["_policy", "BEST_EFFORT", [""]],
    ["_context", createHashMap, [createHashMap]]
];

private _op = toUpper _operation;
if !(_op in ["ADD", "REMOVE"]) exitWith {
    [false, "ITEMS_WHOLE_KIT_OPERATION_INVALID", "Whole-Kit v1 aceita ADD ou REMOVE; REPLACE/CLEAR possuem planners dedicados.", createHashMapFromArray [["operation", _op]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _planR = [_container, _target, _op, _entries, _policy, _context] call ServoPeregrino_Organizador_Items_fnc_createApplicationPlan;
if !(_planR getOrDefault ["success", false]) exitWith {_planR};
private _data = _planR getOrDefault ["data", createHashMap];
private _plan = _data getOrDefault ["plan", createHashMap];
_plan set ["scope", "WHOLE_KIT"];
_plan set ["sourceEntryCount", count _entries];
_data set ["plan", _plan];
[true, "ITEMS_WHOLE_KIT_PLAN_READY", "ApplicationPlan Whole-Kit criado em dry-run.", _data] call ServoPeregrino_Organizador_Nexus_fnc_createResult
