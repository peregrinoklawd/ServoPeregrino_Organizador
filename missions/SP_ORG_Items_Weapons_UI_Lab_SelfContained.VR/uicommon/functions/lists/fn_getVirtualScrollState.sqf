params [
    ["_offset", 0, [0]],
    ["_totalCount", 0, [0]],
    ["_windowSize", 1, [0]]
];

private _total = (floor _totalCount) max 0;
private _window = (floor _windowSize) max 1;
private _clampedOffset = [_offset, _total, _window] call ServoPeregrino_Organizador_UICommon_fnc_clampVirtualOffset;
private _maxOffset = (_total - _window) max 0;
private _visibleCount = ((_total - _clampedOffset) min _window) max 0;
private _ratio = if (_maxOffset > 0) then {_clampedOffset / _maxOffset} else {0};
private _firstIndex = if (_visibleCount > 0) then {_clampedOffset} else {-1};
private _lastIndex = if (_visibleCount > 0) then {_clampedOffset + _visibleCount - 1} else {-1};

createHashMapFromArray [
    ["offset", _clampedOffset],
    ["windowSize", _window],
    ["totalCount", _total],
    ["maxOffset", _maxOffset],
    ["visibleCount", _visibleCount],
    ["scrollRatio", _ratio],
    ["firstIndex", _firstIndex],
    ["lastIndex", _lastIndex]
]
