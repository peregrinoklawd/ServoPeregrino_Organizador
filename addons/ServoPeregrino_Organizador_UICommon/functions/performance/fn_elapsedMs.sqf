params [["_startedAt",-1,[0]],["_endedAt",-1,[0]]];
if (_startedAt < 0) exitWith {-1};
private _end = if (_endedAt < 0) then {diag_tickTime} else {_endedAt};
round (((_end - _startedAt) max 0) * 1000)
