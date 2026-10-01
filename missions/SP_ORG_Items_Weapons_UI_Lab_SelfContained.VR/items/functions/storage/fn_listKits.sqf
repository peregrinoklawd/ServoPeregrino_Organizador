#include "..\..\script_version.hpp"

private _state = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_REPOSITORY_VAR, createHashMap];
private _loadFailed = false;
private _loadFailure = createHashMap;
if !(_state getOrDefault ["ready", false]) then {
    private _load = [] call ServoPeregrino_Organizador_Items_fnc_loadStorage;
    if (_load getOrDefault ["success", false]) then {
        _state = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_REPOSITORY_VAR, createHashMap];
    } else {
        _loadFailed = true;
        _loadFailure = _load;
    };
};
if (_loadFailed) exitWith {_loadFailure};

private _storage = _state getOrDefault ["storage", []];
private _sortable = [];
{
    private _summary = createHashMapFromArray [
        ["id", _x # 2],
        ["name", _x # 3],
        ["preferredTarget", _x # 4],
        ["entryCount", count (_x # 8)],
        ["createdAtUTC", +(_x # 6)],
        ["updatedAtUTC", +(_x # 7)]
    ];
    _sortable pushBack [toLower (_x # 3), _x # 2, _summary];
} forEach (_storage # 2);
_sortable sort true;
private _summaries = _sortable apply {_x # 2};

[
    true,
    "ITEMS_KITS_LISTED",
    "ItemKits listados pelo Repository sem expor o storage serializado.",
    createHashMapFromArray [["kits", _summaries], ["count", count _summaries]]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
