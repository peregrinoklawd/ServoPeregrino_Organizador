/* Return an isolated snapshot DTO, never mutable indexes or internal references. */
params ["_context"];
if !(_context isEqualType createHashMap) exitWith {
    [false, "POLICY_INVALID", "Missing policy context."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _original = _context getOrDefault ["snapshot", createHashMap];
if !(_original isEqualType createHashMap && {(_original getOrDefault ["schema", ""]) isEqualTo "SPORG_POLICY_SNAPSHOT"}) exitWith {
    [false, "POLICY_INVALID", "Missing/invalid PolicySnapshot."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _dto = createHashMapFromArray [
    ["schema", "SPORG_POLICY_SNAPSHOT"], ["schemaVersion", _original getOrDefault ["schemaVersion", 1]],
    ["state", _original getOrDefault ["state", "INVALID"]],
    ["source", _original getOrDefault ["source", "NONE"]],
    ["revision", _original getOrDefault ["revision", 0]],
    ["fingerprint", _original getOrDefault ["fingerprint", "P1_NON_AUTHORITATIVE"]],
    ["whitelist", +(_original getOrDefault ["whitelist", []])],
    ["blacklist", +(_original getOrDefault ["blacklist", []])]
];
[true, "POLICY_SNAPSHOT", "Read-only snapshot copy.", createHashMapFromArray [["snapshot", _dto]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
