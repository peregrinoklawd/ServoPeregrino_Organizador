params [
    ["_unit", objNull, [objNull]],
    ["_target", "", [""]],
    ["_operation", "ADD", [""]],
    ["_entry", [], [[]]],
    ["_policy", "BEST_EFFORT", [""]],
    ["_options", createHashMap, [createHashMap]]
];
private _resolved = [_unit, _target] call ServoPeregrino_Organizador_Items_fnc_resolvePlayerContainer;
if !(_resolved getOrDefault ["success", false]) exitWith {_resolved};
private _rd = _resolved getOrDefault ["data", createHashMap];
private _canonical = _rd getOrDefault ["canonicalTarget", ""];
private _ctx = createHashMapFromArray [["containerClass", _rd getOrDefault ["className", ""]], ["gearClass", _rd getOrDefault ["className", ""]], ["sourceProvider", "VIRTUAL"]];
private _planR = [_rd getOrDefault ["container", objNull], _canonical, _operation, [_entry], _policy, _ctx] call ServoPeregrino_Organizador_Items_fnc_createApplicationPlan;
if !(_planR getOrDefault ["success", false]) exitWith {_planR};
private _plan = ((_planR getOrDefault ["data", createHashMap]) getOrDefault ["plan", createHashMap]);
[_plan, _options] call ServoPeregrino_Organizador_Items_fnc_executeApplicationPlan
