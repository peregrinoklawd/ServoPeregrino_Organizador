params [
    ["_container", objNull, [objNull]], ["_target", "", [""]], ["_operation", "ADD", [""]],
    ["_policy", "BEST_EFFORT", [""]], ["_context", createHashMap, [createHashMap]], ["_options", createHashMap, [createHashMap]]
];
private _sourceR = [] call ServoPeregrino_Organizador_Items_fnc_getDraftApplicationSource;
if !(_sourceR getOrDefault ["success", false]) exitWith {_sourceR};
private _source = ((_sourceR getOrDefault ["data", createHashMap]) getOrDefault ["source", createHashMap]);
private _exec = [_container, _target, _operation, _source getOrDefault ["entries", []], _policy, _context, _options] call ServoPeregrino_Organizador_Items_fnc_executeContentOperation;
if !(_exec isEqualType createHashMap) exitWith {_exec};
private _data = _exec getOrDefault ["data", createHashMap];
_data set ["applicationSource", _source];
_exec set ["data", _data];
_exec
