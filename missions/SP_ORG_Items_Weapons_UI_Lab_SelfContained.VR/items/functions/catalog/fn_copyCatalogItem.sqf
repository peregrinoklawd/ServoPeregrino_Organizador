params [["_item", createHashMap, [createHashMap]]];

private _copy = createHashMap;
{
    private _key = _x;
    private _value = _item get _key;
    if (_value isEqualType []) then {
        _copy set [_key, +_value];
    } else {
        _copy set [_key, _value];
    };
} forEach (keys _item);
_copy
