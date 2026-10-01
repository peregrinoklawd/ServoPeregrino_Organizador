#include "..\..\script_version.hpp"

params [
    ["_suffix", "", [""]],
    ["_clear", false, [false]]
];

private _normalized = _suffix;
private _previous = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_STORAGE_TEST_SUFFIX_VAR, ""];
private _changed = !(_previous isEqualTo _normalized);
private _invalid = -1;
if !(_normalized isEqualTo "") then {
    private _chars = toArray _normalized;
    _invalid = _chars findIf {
        private _c = _x;
        private _digit = (_c >= 48) && (_c <= 57);
        private _upper = (_c >= 65) && (_c <= 90);
        private _lower = (_c >= 97) && (_c <= 122);
        private _underscore = _c isEqualTo 95;
        !(_digit || _upper || _lower || _underscore)
    };
};
if (_invalid >= 0) exitWith {
    [
        false,
        "ITEMS_STORAGE_TEST_SUFFIX_INVALID",
        "Suffix de teste inválido; use apenas letras, números e underscore.",
        createHashMapFromArray [["suffix", _suffix]]
    ] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if (_clear && {_normalized isEqualTo ""}) exitWith {
    [
        false,
        "ITEMS_STORAGE_TEST_MODE_PRODUCTION_CLEAR_REFUSED",
        "Limpeza automática das chaves de produção foi recusada.",
        createHashMapFromArray [["testMode", false]]
    ] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_STORAGE_TEST_SUFFIX_VAR, _normalized];
if (_changed || {_clear}) then {
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_REPOSITORY_VAR, createHashMap];
};

if (_clear) then {
    private _keys = [] call ServoPeregrino_Organizador_Items_fnc_getRepositoryKeys;
    profileNamespace setVariable [_keys get "primary", nil];
    profileNamespace setVariable [_keys get "lastGood", nil];
    saveProfileNamespace;
};

[
    true,
    if (_normalized isEqualTo "") then {"ITEMS_STORAGE_TEST_MODE_DISABLED"} else {"ITEMS_STORAGE_TEST_MODE_ENABLED"},
    if (_normalized isEqualTo "") then {"Repository voltou a usar o namespace persistente de produção."} else {"Repository usa namespace isolado de testes."},
    createHashMapFromArray [["testMode", !(_normalized isEqualTo "")], ["suffix", _normalized], ["changed", _changed], ["cleared", _clear]]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
