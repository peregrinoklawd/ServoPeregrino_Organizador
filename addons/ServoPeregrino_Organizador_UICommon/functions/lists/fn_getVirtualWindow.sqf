params [
    ["_values", [], [[]]],
    ["_offset", 0, [0]],
    ["_windowSize", 32, [0]]
];

private _total = count _values;
private _size = (floor _windowSize) max 1;
private _start = [_offset, _total, _size] call ServoPeregrino_Organizador_UICommon_fnc_clampVirtualOffset;
private _count = (_total - _start) min _size;

createHashMapFromArray [
    ["offset", _start],
    ["windowSize", _size],
    ["totalCount", _total],
    ["visibleCount", _count],
    ["rows", _values select [_start, _count]]
]
