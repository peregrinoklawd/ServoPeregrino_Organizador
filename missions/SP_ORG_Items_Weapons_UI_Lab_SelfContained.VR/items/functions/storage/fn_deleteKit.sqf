#include "..\..\script_version.hpp"

params [["_kitId", "", [""]]];
if !([_kitId] call ServoPeregrino_Organizador_Items_fnc_isValidItemKitId) exitWith {
    [false, "ITEMS_KIT_ID_INVALID", "ID informado ao Repository é inválido.", createHashMapFromArray [["kitId", _kitId]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

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
private _storage = [_state getOrDefault ["storage", []]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _kits = _storage # 2;
private _index = _kits findIf {(_x # 2) isEqualTo _kitId};
if (_index < 0) exitWith {
    [false, "ITEMS_KIT_NOT_FOUND", "ItemKit não foi encontrado para exclusão.", createHashMapFromArray [["kitId", _kitId]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _deleted = [_kits # _index] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
_kits deleteAt _index;
_storage set [2, _kits];
private _save = [_storage] call ServoPeregrino_Organizador_Items_fnc_saveStorage;
if !(_save getOrDefault ["success", false]) exitWith {_save};
[
    true,
    "ITEMS_KIT_PERSISTED_DELETED",
    "ItemKit excluído por ID imutável; nenhum índice visual foi usado como identidade.",
    createHashMapFromArray [["kitId", _kitId], ["deletedKit", _deleted], ["storageResult", _save]]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
