params [["_kitId", "", [""]]];

if (_kitId isEqualTo "") exitWith {false};

private _isDigits = {
    params [["_text", "", [""]]];
    if (_text isEqualTo "") exitWith {false};
    private _valid = true;
    {
        if ((_x < 48) || {_x > 57}) exitWith {_valid = false;};
    } forEach (toArray _text);
    _valid
};

private _parts = _kitId splitString "-";
if ((count _parts) != 5) exitWith {false};
if !((_parts # 0) isEqualTo "sporg") exitWith {false};
if !((_parts # 1) isEqualTo "itemkit") exitWith {false};

private _timestamp = _parts # 2;
private _randomPart = _parts # 3;
private _counterPart = _parts # 4;

if ((count _timestamp) != 15) exitWith {false};
if !((_timestamp select [8, 1]) isEqualTo "T") exitWith {false};
private _timestampDigits = (_timestamp select [0, 8]) + (_timestamp select [9, 6]);
if !([_timestampDigits] call _isDigits) exitWith {false};

if ((count _randomPart) != 8) exitWith {false};
if !([_randomPart] call _isDigits) exitWith {false};

if ((count _counterPart) < 4) exitWith {false};
if !([_counterPart] call _isDigits) exitWith {false};

true
