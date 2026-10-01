#include "..\..\script_version.hpp"

params [["_kit", [], [[]]]];
private _validation = [_kit] call ServoPeregrino_Organizador_Items_fnc_validateItemKitSemantic;
if !(_validation getOrDefault ["success", false]) exitWith {
    [false, _validation getOrDefault ["code", "ITEMS_KIT_SAVE_REJECTED"], "Repository recusou ItemKit inválido.", createHashMapFromArray [["validation", _validation]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
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
private _kitId = _kit # 2;
private _existingIndex = _kits findIf {(_x # 2) isEqualTo _kitId};
private _candidate = [_kit] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _created = _existingIndex < 0;
if (_existingIndex >= 0) then {
    _candidate set [6, +((_kits # _existingIndex) # 6)];
};
_candidate set [7, systemTimeUTC];
private _candidateValidation = [_candidate] call ServoPeregrino_Organizador_Items_fnc_validateItemKitSemantic;
if !(_candidateValidation getOrDefault ["success", false]) exitWith {_candidateValidation};

if (_existingIndex >= 0) then {
    _kits set [_existingIndex, _candidate];
} else {
    _kits pushBack _candidate;
};
_storage set [2, _kits];
private _save = [_storage] call ServoPeregrino_Organizador_Items_fnc_saveStorage;
if !(_save getOrDefault ["success", false]) exitWith {_save};

[
    true,
    if (_created) then {"ITEMS_KIT_PERSISTED_CREATED"} else {"ITEMS_KIT_PERSISTED_UPDATED"},
    if (_created) then {"Novo ItemKit persistido."} else {"ItemKit existente atualizado preservando createdAt e ID."},
    createHashMapFromArray [["kit", _candidate], ["kitId", _kitId], ["created", _created], ["storageResult", _save]]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
