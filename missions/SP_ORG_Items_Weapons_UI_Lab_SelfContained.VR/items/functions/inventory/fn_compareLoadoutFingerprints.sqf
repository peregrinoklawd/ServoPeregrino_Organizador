params [
    ["_before", createHashMap, [createHashMap]],
    ["_after", createHashMap, [createHashMap]],
    ["_label", "", [""]]
];

private _beforeSerialized = _before getOrDefault ["serialized", ""];
private _afterSerialized = _after getOrDefault ["serialized", ""];
private _beforeLoadout = _before getOrDefault ["loadout", []];
private _afterLoadout = _after getOrDefault ["loadout", []];
private _equal = _beforeSerialized isEqualTo _afterSerialized;
private _changes = [];

if (!_equal) then {
    private _maxCount = (count _beforeLoadout) max (count _afterLoadout);
    for "_i" from 0 to (_maxCount - 1) do {
        private _a = _beforeLoadout param [_i, "<AUSENTE>"];
        private _b = _afterLoadout param [_i, "<AUSENTE>"];
        if !(_a isEqualTo _b) then {
            _changes pushBack createHashMapFromArray [
                ["index", _i],
                ["before", [_a] call ServoPeregrino_Organizador_Items_fnc_deepCopy],
                ["after", [_b] call ServoPeregrino_Organizador_Items_fnc_deepCopy]
            ];
        };
    };
    diag_log format [
        "[SP_ORG] [ITEMS] [LOADOUT DIFF 0.9.3] label=%1 changedIndexes=%2",
        _label,
        _changes apply {_x getOrDefault ["index", -1]}
    ];
};

[
    true,
    if (_equal) then {"ITEMS_LOADOUT_FINGERPRINT_EQUAL"} else {"ITEMS_LOADOUT_FINGERPRINT_DIFFERENT"},
    if (_equal) then {"Fingerprints de loadout são idênticos."} else {"Fingerprints de loadout divergem; diagnóstico estrutural disponível."},
    createHashMapFromArray [
        ["equal", _equal],
        ["label", _label],
        ["changedIndexes", _changes apply {_x getOrDefault ["index", -1]}],
        ["changes", _changes],
        ["beforeSerialized", _beforeSerialized],
        ["afterSerialized", _afterSerialized]
    ]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
