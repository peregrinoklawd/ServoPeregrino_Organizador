#include "..\..\script_version.hpp"

params [["_storage", [], [[]]]];

private _validation = [_storage] call ServoPeregrino_Organizador_Items_fnc_validateStorageSemantic;
if !(_validation getOrDefault ["success", false]) exitWith {
    [
        false,
        _validation getOrDefault ["code", "ITEMS_STORAGE_SAVE_REJECTED"],
        "Repository recusou persistir storage inválido.",
        createHashMapFromArray [["validation", _validation]]
    ] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _kits = [_storage # 2] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _canonicalResult = [_kits, [["lastWriteUTC", systemTimeUTC], ["build", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD]]] call ServoPeregrino_Organizador_Items_fnc_createStoragePayload;
if !(_canonicalResult getOrDefault ["success", false]) exitWith {_canonicalResult};
private _canonical = ((_canonicalResult getOrDefault ["data", createHashMap]) getOrDefault ["storage", []]);

private _keys = [] call ServoPeregrino_Organizador_Items_fnc_getRepositoryKeys;
private _primaryKey = _keys get "primary";
private _lastGoodKey = _keys get "lastGood";
private _oldPrimary = profileNamespace getVariable [_primaryKey, []];
private _oldLastGood = profileNamespace getVariable [_lastGoodKey, []];
private _oldPrimaryValid = false;
if (_oldPrimary isEqualType [] && {(count _oldPrimary) > 0}) then {
    private _oldValidation = [_oldPrimary] call ServoPeregrino_Organizador_Items_fnc_migrateStorage;
    _oldPrimaryValid = _oldValidation getOrDefault ["success", false];
};

if (_oldPrimaryValid) then {
    profileNamespace setVariable [_lastGoodKey, [_oldPrimary] call ServoPeregrino_Organizador_Items_fnc_deepCopy];
};
profileNamespace setVariable [_primaryKey, [_canonical] call ServoPeregrino_Organizador_Items_fnc_deepCopy];
saveProfileNamespace;

private _readBack = profileNamespace getVariable [_primaryKey, []];
private _readBackValidation = [_readBack] call ServoPeregrino_Organizador_Items_fnc_validateStorageSemantic;
if !(_readBackValidation getOrDefault ["success", false]) exitWith {
    if (_oldPrimary isEqualType [] && {(count _oldPrimary) > 0}) then {
        profileNamespace setVariable [_primaryKey, _oldPrimary];
    } else {
        profileNamespace setVariable [_primaryKey, nil];
    };
    if (_oldLastGood isEqualType [] && {(count _oldLastGood) > 0}) then {
        profileNamespace setVariable [_lastGoodKey, _oldLastGood];
    } else {
        profileNamespace setVariable [_lastGoodKey, nil];
    };
    saveProfileNamespace;
    [
        false,
        "ITEMS_STORAGE_WRITE_VERIFY_FAILED",
        "Leitura pós-gravação não validou; primary/lastGood anteriores foram restaurados.",
        createHashMapFromArray [["validation", _readBackValidation]]
    ] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _stateResult = [_readBack, "PRIMARY", false] call ServoPeregrino_Organizador_Items_fnc_buildRepositoryState;
if !(_stateResult getOrDefault ["success", false]) exitWith {_stateResult};
[
    true,
    "ITEMS_STORAGE_SAVED",
    "Storage validado foi persistido e revalidado com sucesso.",
    createHashMapFromArray [
        ["storage", _readBack],
        ["lastGoodUpdated", _oldPrimaryValid],
        ["testMode", _keys getOrDefault ["testMode", false]],
        ["repository", ((_stateResult getOrDefault ["data", createHashMap]) getOrDefault ["repository", createHashMap])]
    ]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
