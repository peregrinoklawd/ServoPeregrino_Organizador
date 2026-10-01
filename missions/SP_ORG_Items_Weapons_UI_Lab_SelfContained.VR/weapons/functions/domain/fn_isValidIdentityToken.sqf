params [["_token",false],["_prefix","WID-",[""]]];
if !(_token isEqualType "") exitWith {false};
if (count _token < 12 || {count _token > 240} || {!((_token select [0,count _prefix]) isEqualTo _prefix)}) exitWith {false};
private _suffix = toArray (_token select [count _prefix]);
(_suffix findIf {!(_x in [45,48,49,50,51,52,53,54,55,56,57])}) isEqualTo -1 && {(_suffix findIf {_x != 45}) >= 0}
