params [["_history",[],[[]]],["_sample",[],[[]]],["_maxSamples",24,[0]]];
private _limit = (floor _maxSamples) max 0;
if (_limit isEqualTo 0) exitWith {[]};
private _out = +_history;
_out pushBack (+_sample);
while {(count _out) > _limit} do {_out deleteAt 0;};
_out
