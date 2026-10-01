params [
    ["_requestedTarget", "ANY", [""]],
    ["_preferredTarget", "ANY", [""]],
    ["_availableTargets", [], [[]]]
];
private _canon = {
    params ["_v"];
    private _x = toUpper _v;
    if (_x isEqualTo "U") then {_x = "UNIFORM";};
    if (_x isEqualTo "C") then {_x = "VEST";};
    if (_x isEqualTo "M") then {_x = "BACKPACK";};
    _x
};
private _req = [_requestedTarget] call _canon;
private _pref = [_preferredTarget] call _canon;
private _available = _availableTargets apply {[_x] call _canon};
_available = _available arrayIntersect _available;
if !(_req in ["ANY", "UNIFORM", "VEST", "BACKPACK"]) exitWith {
    [false, "ITEMS_CONTAINER_TARGET_INVALID", "Target de aplicação inválido.", createHashMapFromArray [["target", _requestedTarget]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if !(_pref in ["ANY", "UNIFORM", "VEST", "BACKPACK"]) then {_pref = "ANY";};
if !(_req isEqualTo "ANY") exitWith {
    if (_req in _available) then {
        [true, "ITEMS_APPLICATION_TARGET_SELECTED", "Target explícito respeitado.", createHashMapFromArray [["target", _req], ["reason", "EXPLICIT"]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
    } else {
        [false, "ITEMS_CONTAINER_ABSENT", "Target explícito não está disponível.", createHashMapFromArray [["target", _req]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
    }
};
private _preferredAvailable = !(_pref isEqualTo "ANY") && {_pref in _available};
if (_preferredAvailable) exitWith {
    [true, "ITEMS_APPLICATION_TARGET_SELECTED", "ANY resolveu pelo preferredTarget disponível.", createHashMapFromArray [["target", _pref], ["reason", "PREFERRED"]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _selected = "";
{
    if (_x in _available && {_selected isEqualTo ""}) then {_selected = _x;};
} forEach ["UNIFORM", "VEST", "BACKPACK"];
if (_selected isEqualTo "") exitWith {
    [false, "ITEMS_CONTAINER_ABSENT", "ANY não encontrou nenhum U/C/M disponível.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
[true, "ITEMS_APPLICATION_TARGET_SELECTED", "ANY resolveu deterministicamente pela ordem U/C/M.", createHashMapFromArray [["target", _selected], ["reason", "DETERMINISTIC_FALLBACK"]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
