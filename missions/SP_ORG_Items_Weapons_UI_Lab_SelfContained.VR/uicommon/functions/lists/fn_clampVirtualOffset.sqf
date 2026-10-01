params [
    ["_offset", 0, [0]],
    ["_totalCount", 0, [0]],
    ["_windowSize", 1, [0]]
];

private _total = (floor _totalCount) max 0;
private _window = (floor _windowSize) max 1;
private _candidate = (floor _offset) max 0;
private _maxOffset = (_total - _window) max 0;

_candidate min _maxOffset
