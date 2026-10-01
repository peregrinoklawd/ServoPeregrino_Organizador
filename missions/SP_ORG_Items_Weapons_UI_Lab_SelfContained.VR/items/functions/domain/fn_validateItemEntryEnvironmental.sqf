params [["_entry", [], [[]]]];

private _semantic = [_entry] call ServoPeregrino_Organizador_Items_fnc_validateItemEntrySemantic;
if !(_semantic getOrDefault ["success", false]) exitWith {_semantic};

private _entryType = _entry # 1;
private _className = _entry # 2;
private _configRoot = if (_entryType isEqualTo "MAGAZINE") then {"CfgMagazines"} else {"CfgWeapons"};
private _available = isClass (configFile >> _configRoot >> _className);

if (!_available) exitWith {
    [
        false,
        "ITEMS_CLASS_UNAVAILABLE",
        "A classe persistida não está disponível na sessão atual.",
        createHashMapFromArray [
            ["level", "ENVIRONMENTAL"],
            ["available", false],
            ["className", _className],
            ["configRoot", _configRoot],
            ["entry", _entry]
        ]
    ] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

[
    true,
    "ITEMS_CLASS_AVAILABLE",
    "A classe persistida está disponível na sessão atual.",
    createHashMapFromArray [
        ["level", "ENVIRONMENTAL"],
        ["available", true],
        ["className", _className],
        ["configRoot", _configRoot],
        ["entry", _entry]
    ]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
