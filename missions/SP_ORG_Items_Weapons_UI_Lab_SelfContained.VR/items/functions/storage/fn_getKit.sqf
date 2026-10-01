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
private _index = _state getOrDefault ["index", createHashMap];
if !(_kitId in _index) exitWith {
    [false, "ITEMS_KIT_NOT_FOUND", "ItemKit não foi encontrado no Repository.", createHashMapFromArray [["kitId", _kitId]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

[
    true,
    "ITEMS_KIT_FOUND",
    "ItemKit retornado por ID como cópia runtime.",
    createHashMapFromArray [["kit", [(_index get _kitId)] call ServoPeregrino_Organizador_Items_fnc_deepCopy]]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
