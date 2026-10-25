/* P1 pure PolicyExport validator. No I/O, config lookup, or authority. */
params ["_payload"];
private _fail = {
    params ["_code"];
    [false, _code, "PolicyExport v1 invalid."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if !(_payload isEqualType createHashMap) exitWith {["POLICY_INVALID_ROOT"] call _fail};
private _keys = keys _payload;
private _expected = ["schema", "schemaVersion", "whitelist", "blacklist"];
if ((count _keys) != 4 || {(_keys findIf {!(_x in _expected)}) >= 0}) exitWith {["POLICY_INVALID_FIELDS"] call _fail};
if !((_payload get "schema") isEqualTo "SPORG_POLICY_EXPORT") exitWith {["POLICY_INVALID_SCHEMA"] call _fail};
private _version = _payload get "schemaVersion";
if !(_version isEqualType 0 && {_version isEqualTo 1}) exitWith {["POLICY_INVALID_VERSION"] call _fail};
private _whiteInput = _payload get "whitelist";
private _blackInput = _payload get "blacklist";
if !(_whiteInput isEqualType [] && {_blackInput isEqualType []}) exitWith {["POLICY_INVALID_LIST_TYPE"] call _fail};
if ((count _whiteInput > 4096) || {(count _blackInput > 4096)}) exitWith {["POLICY_INVALID_LIST_SIZE"] call _fail};
/* P0 engine-validated serialization is used for a bounded payload, not code evaluation. */
if ((count (toArray (toJSON _payload))) > 524288) exitWith {["POLICY_INVALID_PAYLOAD_SIZE"] call _fail};
private _white = [];
private _black = [];
private _whiteIndex = createHashMap;
private _blackIndex = createHashMap;
private _error = "";
{
    private _side = _x;
    private _input = _payload get _side;
    private _seen = createHashMap;
    private _items = [];
    {
        if !(_x isEqualType "") exitWith {_error = "POLICY_INVALID_ENTRY_TYPE"};
        private _name = trim _x;
        if !([_name] call ServoPeregrino_Organizador_Policy_fnc_isValidClassname) exitWith {_error = "POLICY_INVALID_CLASSNAME"};
        private _key = toLowerANSI _name;
        if (_seen getOrDefault [_key, false]) exitWith {_error = "POLICY_DUPLICATE_CLASSNAME"};
        _seen set [_key, true];
        _items pushBack _name;
    } forEach _input;
    if !(_error isEqualTo "") exitWith {};
    if (_side isEqualTo "whitelist") then {
        _white = _items;
        _whiteIndex = _seen;
    } else {
        _black = _items;
        _blackIndex = _seen;
    };
} forEach ["whitelist", "blacklist"];
if !(_error isEqualTo "") exitWith {[_error] call _fail};
/* Sorted original spellings for repeatable snapshots independent of import ordering. */
_white = [_white, [], {toLowerANSI _x}, "ASCEND"] call BIS_fnc_sortBy;
_black = [_black, [], {toLowerANSI _x}, "ASCEND"] call BIS_fnc_sortBy;
private _conflicts = _white select {_blackIndex getOrDefault [toLowerANSI _x, false]};
private _normalized = createHashMapFromArray [
    ["schema", "SPORG_POLICY_EXPORT"], ["schemaVersion", 1],
    ["whitelist", _white], ["blacklist", _black]
];
[true, "POLICY_EXPORT_VALID", "PolicyExport validated.", createHashMapFromArray [
    ["export", _normalized], ["whiteIndex", _whiteIndex],
    ["blackIndex", _blackIndex], ["conflicts", _conflicts]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
