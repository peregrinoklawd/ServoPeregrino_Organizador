#include "..\..\script_version.hpp"

private _state = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_REPOSITORY_VAR, createHashMap];
private _ready = _state getOrDefault ["ready", false];
private _data = createHashMapFromArray [
    ["ready", _ready],
    ["kitCount", _state getOrDefault ["kitCount", 0]],
    ["source", _state getOrDefault ["source", "NONE"]],
    ["recovered", _state getOrDefault ["recovered", false]],
    ["storageVersion", _state getOrDefault ["storageVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_STORAGE_VERSION]],
    ["testMode", _state getOrDefault ["testMode", (missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_STORAGE_TEST_SUFFIX_VAR, ""]) != ""]],
    ["storage", if (_ready) then {[(_state getOrDefault ["storage", []])] call ServoPeregrino_Organizador_Items_fnc_deepCopy} else {[]}]
];

[
    _ready,
    if (_ready) then {"ITEMS_REPOSITORY_READY"} else {"ITEMS_REPOSITORY_NOT_READY"},
    if (_ready) then {"Repository SP_ORG_Items está pronto."} else {"Repository SP_ORG_Items ainda não foi carregado."},
    _data
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
