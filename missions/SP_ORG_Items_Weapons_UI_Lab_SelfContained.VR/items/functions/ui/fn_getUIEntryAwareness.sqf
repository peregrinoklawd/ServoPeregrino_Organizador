params [
    ["_entry", [], [[]]],
    ["_metadata", createHashMap, [createHashMap]]
];

if !(_entry isEqualType [] && {(count _entry) >= 6}) exitWith {
    createHashMapFromArray [
        ["known", false], ["unitMass", 0], ["totalMass", 0], ["quantity", 0],
        ["className", ""], ["stateMode", "NONE"]
    ]
};

private _className = _entry # 2;
private _quantity = (_entry # 3) max 0;
private _unitMass = 0;
private _known = false;

if ((count _metadata) > 0) then {
    _unitMass = _metadata getOrDefault ["massEstimate", 0];
    _known = _unitMass > 0;
};

// Fallback direto só quando metadata/cache não conhece a massa.
// Não existe scan global aqui; getEntryUnitMass acessa somente o config da classe informada.
if (!_known) then {
    private _massData = [_entry] call ServoPeregrino_Organizador_Items_fnc_getEntryUnitMass;
    _known = _massData getOrDefault ["known", false];
    _unitMass = _massData getOrDefault ["mass", 0];
};

createHashMapFromArray [
    ["known", _known],
    ["unitMass", _unitMass max 0],
    ["totalMass", if (_known) then {(_unitMass max 0) * _quantity} else {0}],
    ["quantity", _quantity],
    ["className", _className],
    ["stateMode", _entry # 4]
]
