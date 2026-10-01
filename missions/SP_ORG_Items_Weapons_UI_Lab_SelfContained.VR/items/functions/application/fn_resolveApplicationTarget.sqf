params [
    ["_unit", objNull, [objNull]],
    ["_requestedTarget", "ANY", [""]],
    ["_preferredTarget", "ANY", [""]]
];
if (isNull _unit) exitWith {[false, "ITEMS_UNIT_NULL", "Unidade nula não pode resolver target de aplicação.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _available = [];
private _resolvedByTarget = createHashMap;
{
    private _r = [_unit, _x] call ServoPeregrino_Organizador_Items_fnc_resolvePlayerContainer;
    if (_r getOrDefault ["success", false]) then {
        private _d = _r getOrDefault ["data", createHashMap];
        private _canonical = _d getOrDefault ["canonicalTarget", ""];
        _available pushBack _canonical;
        _resolvedByTarget set [_canonical, _d];
    };
} forEach ["U", "C", "M"];
private _choice = [_requestedTarget, _preferredTarget, _available] call ServoPeregrino_Organizador_Items_fnc_chooseApplicationTarget;
if !(_choice getOrDefault ["success", false]) exitWith {_choice};
private _choiceData = _choice getOrDefault ["data", createHashMap];
private _target = _choiceData getOrDefault ["target", ""];
private _resolved = _resolvedByTarget getOrDefault [_target, createHashMap];
[true, "ITEMS_APPLICATION_TARGET_RESOLVED", "Target físico foi resolvido sem misturar containers.", createHashMapFromArray [["target", _target], ["reason", _choiceData getOrDefault ["reason", ""]], ["container", _resolved getOrDefault ["container", objNull]], ["className", _resolved getOrDefault ["className", ""]], ["availableTargets", _available]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
