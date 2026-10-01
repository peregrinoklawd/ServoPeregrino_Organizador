#include "..\..\script_version.hpp"

params [["_storage", [], [[]]]];

if !(_storage isEqualType []) exitWith {
    [false, "ITEMS_STORAGE_STRUCTURAL_INVALID", "Storage não é um array serializável.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if ((count _storage) < 2) exitWith {
    [false, "ITEMS_STORAGE_STRUCTURAL_INVALID", "Storage não possui magic/version mínimos para migração.", createHashMapFromArray [["storage", _storage]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if !((_storage # 0) isEqualType "") exitWith {
    [false, "ITEMS_STORAGE_STRUCTURAL_INVALID", "Magic do storage possui tipo inválido.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if !((_storage # 1) isEqualType 0) exitWith {
    [false, "ITEMS_STORAGE_STRUCTURAL_INVALID", "Versão do storage possui tipo inválido.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if !((_storage # 0) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_STORAGE_MAGIC) exitWith {
    [false, "ITEMS_STORAGE_INVALID_MAGIC", "Storage não pertence ao domínio SP_ORG_Items.", createHashMapFromArray [["magic", _storage # 0]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _version = _storage # 1;
private _result = createHashMap;
if (_version isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_STORAGE_VERSION) then {
    private _validation = [_storage] call ServoPeregrino_Organizador_Items_fnc_validateStorageSemantic;
    if (_validation getOrDefault ["success", false]) then {
        _result = [
            true,
            "ITEMS_STORAGE_MIGRATION_NOT_REQUIRED",
            "Storage já está na versão persistente atual.",
            createHashMapFromArray [["storage", [_storage] call ServoPeregrino_Organizador_Items_fnc_deepCopy], ["fromVersion", _version], ["toVersion", _version], ["migrated", false]]
        ] call ServoPeregrino_Organizador_Nexus_fnc_createResult;
    } else {
        _result = _validation;
    };
} else {
    // Não existe storage SP_ORG_Items anterior ao v1. Não inventamos migração histórica.
    _result = [
        false,
        "ITEMS_STORAGE_UNSUPPORTED_VERSION",
        "Versão persistente sem caminho de migração conhecido.",
        createHashMapFromArray [["fromVersion", _version], ["supportedVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_STORAGE_VERSION]]
    ] call ServoPeregrino_Organizador_Nexus_fnc_createResult;
};

_result
