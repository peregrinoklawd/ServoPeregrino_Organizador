#include "..\..\script_version.hpp"

private _formatUnsignedInteger = {
    params [
        ["_value", 0, [0]],
        ["_minWidth", 1, [0]]
    ];

    private _number = floor (abs _value);
    private _text = "";

    if (_number isEqualTo 0) then {
        _text = "0";
    } else {
        while {_number > 0} do {
            private _digit = _number mod 10;
            _text = (str _digit) + _text;
            _number = floor (_number / 10);
        };
    };

    while {(count _text) < _minWidth} do {
        _text = "0" + _text;
    };
    _text
};

private _now = systemTimeUTC;
private _year = [_now # 0, 4] call _formatUnsignedInteger;
private _month = [_now # 1, 2] call _formatUnsignedInteger;
private _day = [_now # 2, 2] call _formatUnsignedInteger;
private _hour = [_now # 3, 2] call _formatUnsignedInteger;
private _minute = [_now # 4, 2] call _formatUnsignedInteger;
private _second = [floor (_now # 5), 2] call _formatUnsignedInteger;
private _timestamp = format ["%1%2%3T%4%5%6", _year, _month, _day, _hour, _minute, _second];

// Não usa str/format sobre o inteiro aleatório inteiro. Cada dígito é
// materializado isoladamente para nunca produzir notação científica.
private _randomText = "";
for "_i" from 1 to 8 do {
    _randomText = _randomText + str (floor (random 10));
};

private _counter = (missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_ITEMKIT_COUNTER_VAR, 0]) + 1;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_ITEMKIT_COUNTER_VAR, _counter];
private _counterText = [_counter, 4] call _formatUnsignedInteger;

format ["sporg-itemkit-%1-%2-%3", _timestamp, _randomText, _counterText]
