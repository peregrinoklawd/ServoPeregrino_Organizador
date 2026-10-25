/* Pure evaluation. Consumer is responsible for class existence and MP authorization. */
params ["_context", "_className", ["_required", false, [false]]];
private _snapshot = createHashMap;
private _whiteIndex = createHashMap;
private _blackIndex = createHashMap;
if (_context isEqualType createHashMap) then {
    _snapshot = _context getOrDefault ["snapshot", createHashMap];
    _whiteIndex = _context getOrDefault ["whiteIndex", createHashMap];
    _blackIndex = _context getOrDefault ["blackIndex", createHashMap];
};
if !(_snapshot isEqualType createHashMap) then {_snapshot = createHashMap};
if !(_whiteIndex isEqualType createHashMap) then {_whiteIndex = createHashMap};
if !(_blackIndex isEqualType createHashMap) then {_blackIndex = createHashMap};
private _state = _snapshot getOrDefault ["state", "INVALID"];
if !(_state in ["ACTIVE", "PENDING", "INVALID", "ABSENT"]) then {_state = "INVALID"};
if !((_snapshot getOrDefault ["schema", ""]) isEqualTo "SPORG_POLICY_SNAPSHOT" && {(_snapshot getOrDefault ["schemaVersion", 0]) isEqualTo 1}) then {_state = "INVALID"};
private _code = "POLICY_INVALID";
private _allowed = false;
if !([_className] call ServoPeregrino_Organizador_Policy_fnc_isValidClassname) then {
    _state = "INVALID";
} else {
    switch (_state) do {
        case "ABSENT": {
            if (_required) then {_code = "POLICY_NOT_READY"} else {_code = "POLICY_ALLOW_OPEN"; _allowed = true};
        };
        case "PENDING": {_code = "POLICY_NOT_READY"};
        case "INVALID": {_code = "POLICY_INVALID"};
        case "ACTIVE": {
            private _key = toLowerANSI (trim _className);
            if (_blackIndex getOrDefault [_key, false]) then {
                _code = "POLICY_DENY_BLACKLIST";
            } else {
                if ((count (_snapshot getOrDefault ["whitelist", []])) > 0) then {
                    if (_whiteIndex getOrDefault [_key, false]) then {
                        _code = "POLICY_ALLOW_WHITELIST";
                        _allowed = true;
                    } else {_code = "POLICY_DENY_NOT_WHITELIST"};
                } else {
                    _code = "POLICY_ALLOW_OPEN";
                    _allowed = true;
                };
            };
        };
    };
};
private _decision = createHashMapFromArray [
    ["schema", "SPORG_POLICY_DECISION"], ["schemaVersion", 1],
    ["className", if (_className isEqualType "") then {trim _className} else {""}],
    ["allowed", _allowed], ["code", _code],
    ["source", _snapshot getOrDefault ["source", "NONE"]],
    ["revision", _snapshot getOrDefault ["revision", 0]],
    ["fingerprint", _snapshot getOrDefault ["fingerprint", "P1_NON_AUTHORITATIVE"]]
];
[true, _code, "Policy evaluation complete (P1, non-authoritative).", createHashMapFromArray [
    ["decision", _decision]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
