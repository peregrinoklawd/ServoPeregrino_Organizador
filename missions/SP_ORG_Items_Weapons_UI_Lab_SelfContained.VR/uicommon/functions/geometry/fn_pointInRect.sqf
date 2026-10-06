params [
    ["_x", 0, [0]],
    ["_y", 0, [0]],
    ["_rect", [], [[]]]
];

if ((count _rect) < 4) exitWith {false};

private _rx = _rect param [0, 0, [0]];
private _ry = _rect param [1, 0, [0]];
private _rw = _rect param [2, 0, [0]];
private _rh = _rect param [3, 0, [0]];

if (_rw < 0 || {_rh < 0}) exitWith {false};

_x >= _rx
&& {_x <= (_rx + _rw)}
&& {_y >= _ry}
&& {_y <= (_ry + _rh)}
