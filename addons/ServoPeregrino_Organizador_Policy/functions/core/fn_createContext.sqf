/* Explicit local test/application context. No server authority and no global state. */
params [
    ["_payload", createHashMap, [createHashMap]],
    ["_state", "ACTIVE", [""]],
    ["_source", "NONE", [""]]
];
if !(_state in ["ACTIVE", "PENDING", "INVALID", "ABSENT"]) exitWith {
    [false, "POLICY_STATE_INVALID", "Unsupported PolicySnapshot state."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if !(_source in ["NONE", "ADDON_FALLBACK", "MISSION_EXPLICIT", "SERVER_ACTIVE"]) exitWith {
    [false, "POLICY_SOURCE_INVALID", "Unsupported snapshot source."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _validated = createHashMap;
if (_state isEqualTo "ACTIVE") then {
    _validated = [_payload] call ServoPeregrino_Organizador_Policy_fnc_validateExport;
};
private _activeValid = _state isEqualTo "ACTIVE" && {_validated getOrDefault ["success", false]};
private _effectiveState = if (_state isEqualTo "ACTIVE" && {!_activeValid}) then {"INVALID"} else {_state};
private _cleanLists = if (_activeValid) then {(_validated get "data") get "export"} else {
    createHashMapFromArray [["whitelist", []], ["blacklist", []]]
};
/* P1 placeholder: revision and fingerprint are NOT client-supplied or authoritative. */
private _snapshot = createHashMapFromArray [
    ["schema", "SPORG_POLICY_SNAPSHOT"], ["schemaVersion", 1],
    ["state", _effectiveState], ["source", _source],
    ["revision", 0], ["fingerprint", "P1_NON_AUTHORITATIVE"],
    ["whitelist", +(_cleanLists get "whitelist")],
    ["blacklist", +(_cleanLists get "blacklist")]
];
private _indexData = if (_activeValid) then {_validated get "data"} else {createHashMap};
private _context = createHashMapFromArray [
    ["snapshot", _snapshot],
    ["whiteIndex", _indexData getOrDefault ["whiteIndex", createHashMap]],
    ["blackIndex", _indexData getOrDefault ["blackIndex", createHashMap]],
    ["conflicts", +(_indexData getOrDefault ["conflicts", []])]
];
if (_state isEqualTo "ACTIVE" && {!_activeValid}) exitWith {
    [false, "POLICY_INVALID", "Invalid active payload: context fails closed.", createHashMapFromArray [
        ["context", _context], ["cause", _validated getOrDefault ["code", "POLICY_INVALID"]]
    ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
[true, "POLICY_CONTEXT_CREATED", "Non-authoritative P1 Policy context created.", createHashMapFromArray [
    ["context", _context]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
