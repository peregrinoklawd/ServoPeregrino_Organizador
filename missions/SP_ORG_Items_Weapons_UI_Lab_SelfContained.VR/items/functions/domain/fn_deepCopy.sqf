params ["_value"];

// Arrays e HashMaps são os dois agregados mutáveis usados pelos modelos runtime de Items.
// A cópia precisa ser recursiva: devolver a mesma referência de HashMap permite que um
// consumidor de leitura contamine current/baseline/cache autoritativos.
if (_value isEqualType []) exitWith {
    _value apply {[_x] call ServoPeregrino_Organizador_Items_fnc_deepCopy}
};

if (_value isEqualType createHashMap) exitWith {
    private _copy = createHashMap;
    {
        _copy set [_x, [(_value get _x)] call ServoPeregrino_Organizador_Items_fnc_deepCopy];
    } forEach (keys _value);
    _copy
};

_value
