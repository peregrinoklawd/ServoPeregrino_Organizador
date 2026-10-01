params [
    ["_itemCargo", [[], []], [[]]],
    ["_magazinesAmmoCargo", [], [[]]],
    ["_weaponCargo", [[], []], [[]]],
    ["_backpackCargo", [[], []], [[]]]
];

private _entries = [];
private _reserved = [];
private _diagnostics = [];
private _fatal = createHashMap;

private _itemClasses = _itemCargo param [0, [], [[]]];
private _itemCounts = _itemCargo param [1, [], [[]]];
{
    private _className = _x;
    private _count = _itemCounts param [_forEachIndex, 0, [0]];
    if ((_className isEqualType "") && {!(_className isEqualTo "")} && {_count > 0}) then {
        private _classification = [_className] call ServoPeregrino_Organizador_Items_fnc_classifyCargoClass;
        private _cd = _classification getOrDefault ["data", createHashMap];
        private _ownership = _cd getOrDefault ["ownership", "RESERVED"];
        if (_ownership isEqualTo "CONTENT") then {
            private _entryResult = ["ITEM", _className, _count, "NONE", []] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
            if !(_entryResult getOrDefault ["success", false]) exitWith {_fatal = _entryResult;};
            _entries pushBack (((_entryResult getOrDefault ["data", createHashMap]) getOrDefault ["entry", []]));
        } else {
            _reserved pushBack createHashMapFromArray [
                ["kind", if ((_cd getOrDefault ["reason", ""]) isEqualTo "EQUIPMENT_DOMAIN") then {"EQUIPMENT"} else {"UNSUPPORTED"}],
                ["className", _className], ["count", _count], ["reason", _cd getOrDefault ["reason", "RESERVED"]], ["itemType", _cd getOrDefault ["itemType", []]]
            ];
        };
    };
    if ((count _fatal) > 0) exitWith {};
} forEach _itemClasses;

if ((count _fatal) > 0) exitWith {
    [false, _fatal getOrDefault ["code", "ITEMS_CAPTURE_ENTRY_FAILED"], "Falha ao representar item de cargo elegível.", createHashMapFromArray [["cause", _fatal]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _magClasses = [];
private _magStates = [];
{
    if (_x isEqualType [] && {(count _x) >= 2}) then {
        private _className = _x param [0, "", [""]];
        private _ammo = _x param [1, -1, [0]];
        if ((_className isEqualTo "") || {_ammo < 0}) exitWith {
            _fatal = [false, "ITEMS_CAPTURE_MAGAZINE_STATE_INVALID", "Magazine físico não pôde ser representado como EXACT.", createHashMapFromArray [["magazine", _x]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult;
        };
        private _idx = _magClasses find _className;
        if (_idx < 0) then {
            _magClasses pushBack _className;
            _magStates pushBack [_ammo];
        } else {
            (_magStates # _idx) pushBack _ammo;
        };
    };
    if ((count _fatal) > 0) exitWith {};
} forEach _magazinesAmmoCargo;

if ((count _fatal) > 0) exitWith {_fatal};
{
    private _states = _magStates # _forEachIndex;
    private _entryResult = ["MAGAZINE", _x, count _states, "EXACT", _states] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
    if !(_entryResult getOrDefault ["success", false]) exitWith {_fatal = _entryResult;};
    _entries pushBack (((_entryResult getOrDefault ["data", createHashMap]) getOrDefault ["entry", []]));
} forEach _magClasses;
if ((count _fatal) > 0) exitWith {_fatal};

private _weaponClasses = _weaponCargo param [0, [], [[]]];
private _weaponCounts = _weaponCargo param [1, [], [[]]];
{
    private _count = _weaponCounts param [_forEachIndex, 0, [0]];
    if (_count > 0) then {_reserved pushBack createHashMapFromArray [["kind", "WEAPON"], ["className", _x], ["count", _count], ["reason", "WEAPON_DOMAIN"]];};
} forEach _weaponClasses;

private _backpackClasses = _backpackCargo param [0, [], [[]]];
private _backpackCounts = _backpackCargo param [1, [], [[]]];
{
    private _count = _backpackCounts param [_forEachIndex, 0, [0]];
    if (_count > 0) then {_reserved pushBack createHashMapFromArray [["kind", "NESTED_CONTAINER"], ["className", _x], ["count", _count], ["reason", "EQUIPMENT_DOMAIN"]];};
} forEach _backpackClasses;

private _normalizedResult = [_entries] call ServoPeregrino_Organizador_Items_fnc_normalizeItemEntries;
if !(_normalizedResult getOrDefault ["success", false]) exitWith {_normalizedResult};
private _normalized = (_normalizedResult getOrDefault ["data", createHashMap]) getOrDefault ["entries", []];

[
    true,
    "ITEMS_CONTAINER_CARGO_ANALYZED",
    "Cargo convertido em CONTENT + reserved cargo sem mutação física.",
    createHashMapFromArray [
        ["entries", _normalized],
        ["reservedCargo", _reserved],
        ["diagnostics", _diagnostics],
        ["entryCount", count _normalized],
        ["reservedCount", count _reserved]
    ]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
