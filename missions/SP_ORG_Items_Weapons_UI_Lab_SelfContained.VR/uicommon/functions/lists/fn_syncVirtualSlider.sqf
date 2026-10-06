disableSerialization;
params [
    ["_ctrl", controlNull, [controlNull]],
    ["_offset", 0, [0]],
    ["_totalCount", 0, [0]],
    ["_windowSize", 1, [0]],
    ["_smallStep", 6, [0]],
    ["_minLargeStep", 12, [0]],
    ["_show", true, [false]]
];

private _state = [_offset, _totalCount, _windowSize] call ServoPeregrino_Organizador_UICommon_fnc_getVirtualScrollState;

if (!isNull _ctrl) then {
    private _maxOffset = _state get "maxOffset";
    private _window = _state get "windowSize";
    _ctrl sliderSetRange [0, (_maxOffset max 1)];
    _ctrl sliderSetSpeed [(_smallStep max 1), (_window max (_minLargeStep max 1))];
    _ctrl sliderSetPosition (_state get "offset");
    _ctrl ctrlEnable (_maxOffset > 0);
    _ctrl ctrlShow _show;
};

_state
