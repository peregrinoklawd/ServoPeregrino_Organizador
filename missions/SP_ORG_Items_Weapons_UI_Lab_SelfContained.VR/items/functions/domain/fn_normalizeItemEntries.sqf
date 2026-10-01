params [["_entries", [], [[]]]];

private _normalized = [];
private _keys = [];
private _invalidResult = createHashMap;
private _invalidIndex = -1;

{
    private _entry = _x;
    private _validation = [_entry] call ServoPeregrino_Organizador_Items_fnc_validateItemEntrySemantic;
    if !(_validation getOrDefault ["success", false]) exitWith {
        _invalidResult = _validation;
        _invalidIndex = _forEachIndex;
    };

    private _entryCopy = [_entry] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
    private _key = format ["%1|%2|%3", _entryCopy # 1, _entryCopy # 2, _entryCopy # 4];
    private _existingIndex = _keys find _key;

    if (_existingIndex < 0) then {
        _keys pushBack _key;
        _normalized pushBack _entryCopy;
    } else {
        private _existing = _normalized # _existingIndex;
        if ((_existing # 4) isEqualTo "EXACT") then {
            private _states = (_existing # 5) + (_entryCopy # 5);
            _existing set [5, _states];
            _existing set [3, count _states];
        } else {
            _existing set [3, (_existing # 3) + (_entryCopy # 3)];
        };
        _normalized set [_existingIndex, _existing];
    };
} forEach _entries;

if (_invalidIndex >= 0) exitWith {
    [
        false,
        _invalidResult getOrDefault ["code", "ITEMS_ENTRY_INVALID"],
        "Não foi possível normalizar as entradas porque existe uma ItemEntry inválida.",
        createHashMapFromArray [["entryIndex", _invalidIndex], ["entryResult", _invalidResult]]
    ] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

[
    true,
    "ITEMS_ENTRIES_NORMALIZED",
    "ItemEntries normalizadas sem misturar modos de estado.",
    createHashMapFromArray [["entries", _normalized], ["inputCount", count _entries], ["outputCount", count _normalized]]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
