#include "..\..\script_version.hpp"

params [
    ["_storage", [], [[]]],
    ["_source", "MEMORY", [""]],
    ["_recovered", false, [false]]
];

private _validation = [_storage] call ServoPeregrino_Organizador_Items_fnc_validateStorageSemantic;
if !(_validation getOrDefault ["success", false]) exitWith {_validation};

private _storageCopy = [_storage] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _index = createHashMap;
{
    _index set [_x # 2, [_x] call ServoPeregrino_Organizador_Items_fnc_deepCopy];
} forEach (_storageCopy # 2);

private _state = createHashMapFromArray [
    ["ready", true],
    ["storageVersion", _storageCopy # 1],
    ["storage", _storageCopy],
    ["index", _index],
    ["kitCount", count (_storageCopy # 2)],
    ["source", _source],
    ["recovered", _recovered],
    ["loadedAtUTC", systemTimeUTC],
    ["testMode", (missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_STORAGE_TEST_SUFFIX_VAR, ""]) != ""]
];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_REPOSITORY_VAR, _state];

[
    true,
    "ITEMS_REPOSITORY_STATE_READY",
    "Repository runtime construído a partir de storage validado.",
    createHashMapFromArray [["repository", _state]]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
