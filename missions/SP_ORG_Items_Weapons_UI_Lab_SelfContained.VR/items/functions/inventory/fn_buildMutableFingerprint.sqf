params [
    ["_entries", [], [[]]],
    ["_reservedCargo", [], [[]]],
    ["_containerClass", "", [""]],
    ["_target", "", [""]]
];

private _entryTokens = [];
{
    if (_x isEqualType [] && {(count _x) >= 6}) then {
        private _type = _x # 1;
        private _className = _x # 2;
        private _qty = _x # 3;
        private _mode = _x # 4;
        private _states = +(_x # 5);
        if (_mode isEqualTo "EXACT") then {_states sort true;};
        _entryTokens pushBack format ["%1|%2|%3|%4|%5", _type, _className, _mode, _qty, str _states];
    };
} forEach _entries;
_entryTokens sort true;

private _reservedTokens = [];
{
    if (_x isEqualType createHashMap) then {
        _reservedTokens pushBack format ["%1|%2|%3|%4", _x getOrDefault ["kind", ""], _x getOrDefault ["className", ""], _x getOrDefault ["count", 0], _x getOrDefault ["reason", ""]];
    };
} forEach _reservedCargo;
_reservedTokens sort true;

private _serialized = format ["TARGET=%1;CLASS=%2;MUT=%3;RES=%4", toUpper _target, _containerClass, str _entryTokens, str _reservedTokens];
createHashMapFromArray [
    ["serialized", _serialized],
    ["target", toUpper _target],
    ["containerClass", _containerClass],
    ["mutableTokens", _entryTokens],
    ["reservedTokens", _reservedTokens]
]
