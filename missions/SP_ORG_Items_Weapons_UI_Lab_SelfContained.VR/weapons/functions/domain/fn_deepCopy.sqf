params ["_value"];
if (_value isEqualType []) exitWith {_value apply {[_x] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy}};
if (_value isEqualType createHashMap) exitWith {
 private _copy = createHashMap;
 {_copy set [_x,[_value get _x] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy]} forEach keys _value;
 _copy
};
_value
