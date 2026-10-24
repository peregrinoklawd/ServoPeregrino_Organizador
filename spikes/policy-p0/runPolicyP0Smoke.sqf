/*
    SP_ORG Policy P0 — smoke técnico independente, NÃO é runtime do addon Policy.
    Copiar ESTE arquivo para a raiz de uma missão de teste.
    Debug Console (SP): [] execVM "runPolicyP0Smoke.sqf";
    Verificar Arma3_x64_*.rpt: [SPORG_POLICY_P0] ...
    Requer Arma >= 2.18 (fromJSON / toJSON). Não executa compile, nem escreve dados.
*/
private _cases = [
    ["OPEN", [], [], "FirstAidKit", true],
    ["BLACKLIST_DENY", [], ["ItemGPS"], "ItemGPS", false],
    ["BLACKLIST_ALLOW_OTHER", [], ["ItemGPS"], "FirstAidKit", true],
    ["WHITELIST_ALLOW", ["FirstAidKit"], [], "FirstAidKit", true],
    ["WHITELIST_DENY", ["FirstAidKit"], [], "ItemGPS", false],
    ["COMBINED_BLACK_WINS", ["ItemGPS", "FirstAidKit"], ["ItemGPS"], "ItemGPS", false],
    ["COMBINED_ALLOW", ["ItemGPS", "FirstAidKit"], ["ItemGPS"], "FirstAidKit", true],
    ["CASE_INSENSITIVE", ["firstaidkit"], [], "FirstAidKit", true]
];

private _pass = 0;
private _fail = 0;
{
    _x params ["_caseId", "_white", "_black", "_className", "_expected"];
    private _key = toLowerANSI _className;
    private _whiteIndex = _white apply {toLowerANSI _x};
    private _blackIndex = _black apply {toLowerANSI _x};
    private _actual = !(_key in _blackIndex) && {((count _whiteIndex) isEqualTo 0) || {_key in _whiteIndex}};
    private _ok = _actual isEqualTo _expected;
    if (_ok) then {_pass = _pass + 1;} else {_fail = _fail + 1;};
    diag_log format ["[SPORG_POLICY_P0] [DECISION] %1 %2 expected=%3 actual=%4", if (_ok) then {"PASS"} else {"FAIL"}, _caseId, _expected, _actual];
} forEach _cases;

private _export = createHashMapFromArray [
    ["schema", "SPORG_POLICY_EXPORT"],
    ["schemaVersion", 1],
    ["whitelist", ["FirstAidKit", "ItemGPS"]],
    ["blacklist", ["ItemGPS"]]
];
private _encoded = toJSON _export;
private _decoded = fromJSON _encoded;
private _jsonOk = (_decoded isEqualType createHashMap)
    && {(_decoded getOrDefault ["schema", ""]) isEqualTo "SPORG_POLICY_EXPORT"}
    && {(_decoded getOrDefault ["schemaVersion", 0]) isEqualTo 1}
    && {(_decoded getOrDefault ["blacklist", []]) isEqualTo ["ItemGPS"]}
    && {(_decoded getOrDefault ["whitelist", []]) isEqualTo ["FirstAidKit", "ItemGPS"]};
if (_jsonOk) then {_pass = _pass + 1;} else {_fail = _fail + 1;};
diag_log format ["[SPORG_POLICY_P0] [JSON] %1 textLength=%2", if (_jsonOk) then {"PASS"} else {"FAIL"}, count _encoded];

private _mission = missionConfigFile >> "CfgSPORGPolicy";
private _addon = configFile >> "CfgSPORGPolicy";
private _missionPresent = isClass _mission;
private _addonPresent = isClass _addon;
private _enabled = if (_missionPresent) then {getNumber (_mission >> "enabled")} else {0};
private _whitelist = if (_missionPresent && {isArray (_mission >> "whitelist")}) then {getArray (_mission >> "whitelist")} else {[]};
private _blacklist = if (_missionPresent && {isArray (_mission >> "blacklist")}) then {getArray (_mission >> "blacklist")} else {[]};
diag_log format [
    "[SPORG_POLICY_P0] [CONFIG] missionPresent=%1 missionEnabled=%2 addonPresent=%3 whitelist=%4 blacklist=%5",
    _missionPresent, _enabled, _addonPresent, _whitelist, _blacklist
];
diag_log "[SPORG_POLICY_P0] [CLIPBOARD] copyFromClipboard bloqueado no MP conforme documentação; não executado aqui";
diag_log format ["[SPORG_POLICY_P0] [SUMMARY] pass=%1 fail=%2 scope=SP_SPIKE_ONLY", _pass, _fail];

createHashMapFromArray [
    ["schema", "SPORG_POLICY_P0_SMOKE"],
    ["pass", _pass],
    ["fail", _fail],
    ["missionConfigDetected", _missionPresent],
    ["addonConfigDetected", _addonPresent]
]
