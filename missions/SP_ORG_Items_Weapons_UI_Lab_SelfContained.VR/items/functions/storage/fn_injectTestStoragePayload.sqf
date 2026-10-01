#include "..\..\script_version.hpp"

params [
    ["_target", "PRIMARY", [""]],
    ["_payload", [], [[]]]
];
private _suffix = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_STORAGE_TEST_SUFFIX_VAR, ""];
if (_suffix isEqualTo "") exitWith {
    [false, "ITEMS_STORAGE_TEST_INJECTION_REFUSED", "Injeção de payload só é permitida em namespace isolado de teste.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _resolvedTarget = toUpper _target;
if !(_resolvedTarget in ["PRIMARY", "LASTGOOD"]) exitWith {
    [false, "ITEMS_STORAGE_TEST_TARGET_INVALID", "Target de injeção de teste inválido.", createHashMapFromArray [["target", _target]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _keys = [] call ServoPeregrino_Organizador_Items_fnc_getRepositoryKeys;
private _key = if (_resolvedTarget isEqualTo "PRIMARY") then {_keys get "primary"} else {_keys get "lastGood"};
profileNamespace setVariable [_key, [_payload] call ServoPeregrino_Organizador_Items_fnc_deepCopy];
saveProfileNamespace;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_REPOSITORY_VAR, createHashMap];
[
    true,
    "ITEMS_STORAGE_TEST_PAYLOAD_INJECTED",
    "Payload de teste foi injetado exclusivamente no namespace isolado.",
    createHashMapFromArray [["target", _resolvedTarget], ["suffix", _suffix]]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
