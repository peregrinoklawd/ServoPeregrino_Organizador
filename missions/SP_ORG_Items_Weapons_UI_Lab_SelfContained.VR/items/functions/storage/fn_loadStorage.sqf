#include "..\..\script_version.hpp"

private _keys = [] call ServoPeregrino_Organizador_Items_fnc_getRepositoryKeys;
private _primaryKey = _keys get "primary";
private _lastGoodKey = _keys get "lastGood";
private _primary = profileNamespace getVariable [_primaryKey, []];
private _lastGood = profileNamespace getVariable [_lastGoodKey, []];
private _primaryPresent = _primary isEqualType [] && {(count _primary) > 0};
private _lastGoodPresent = _lastGood isEqualType [] && {(count _lastGood) > 0};

private _loadCandidate = {
    params ["_payload", "_source", "_recovered"];
    private _migration = [_payload] call ServoPeregrino_Organizador_Items_fnc_migrateStorage;
    if !(_migration getOrDefault ["success", false]) exitWith {_migration};
    private _migrated = ((_migration getOrDefault ["data", createHashMap]) getOrDefault ["storage", []]);
    private _stateResult = [_migrated, _source, _recovered] call ServoPeregrino_Organizador_Items_fnc_buildRepositoryState;
    if !(_stateResult getOrDefault ["success", false]) exitWith {_stateResult};
    [
        true,
        if (_recovered) then {"ITEMS_STORAGE_RECOVERED_LAST_GOOD"} else {"ITEMS_STORAGE_LOADED"},
        if (_recovered) then {"Primary inválido/ausente; Repository foi recuperado de lastGood sem sobrescrever o primary."} else {"Storage primary carregado e validado."},
        createHashMapFromArray [
            ["source", _source],
            ["recovered", _recovered],
            ["storage", _migrated],
            ["repository", ((_stateResult getOrDefault ["data", createHashMap]) getOrDefault ["repository", createHashMap])]
        ]
    ] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _result = createHashMap;
if (_primaryPresent) then {
    _result = [_primary, "PRIMARY", false] call _loadCandidate;
    if !(_result getOrDefault ["success", false]) then {
        private _primaryFailure = _result;
        if (_lastGoodPresent) then {
            private _lastGoodResult = [_lastGood, "LAST_GOOD", true] call _loadCandidate;
            if (_lastGoodResult getOrDefault ["success", false]) then {
                _result = _lastGoodResult;
            } else {
                missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_REPOSITORY_VAR, createHashMap];
                _result = [
                    false,
                    "ITEMS_STORAGE_UNRECOVERABLE",
                    "Primary e lastGood existem, mas ambos são inválidos. Nenhum deles foi sobrescrito.",
                    createHashMapFromArray [["primaryResult", _primaryFailure], ["lastGoodResult", _lastGoodResult]]
                ] call ServoPeregrino_Organizador_Nexus_fnc_createResult;
            };
        } else {
            missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_REPOSITORY_VAR, createHashMap];
            _result = [
                false,
                "ITEMS_STORAGE_UNRECOVERABLE",
                "Primary persistido é inválido e não existe lastGood recuperável. O storage inválido foi preservado para diagnóstico.",
                createHashMapFromArray [["primaryResult", _primaryFailure]]
            ] call ServoPeregrino_Organizador_Nexus_fnc_createResult;
        };
    };
} else {
    if (_lastGoodPresent) then {
        _result = [_lastGood, "LAST_GOOD", true] call _loadCandidate;
        if !(_result getOrDefault ["success", false]) then {
            private _lastGoodFailure = _result;
            missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_REPOSITORY_VAR, createHashMap];
            _result = [
                false,
                "ITEMS_STORAGE_UNRECOVERABLE",
                "Primary está ausente e lastGood é inválido. Nenhum storage foi criado automaticamente.",
                createHashMapFromArray [["lastGoodResult", _lastGoodFailure]]
            ] call ServoPeregrino_Organizador_Nexus_fnc_createResult;
        };
    } else {
        private _emptyResult = [[], []] call ServoPeregrino_Organizador_Items_fnc_createStoragePayload;
        if !(_emptyResult getOrDefault ["success", false]) then {
            _result = _emptyResult;
        } else {
            private _empty = ((_emptyResult getOrDefault ["data", createHashMap]) getOrDefault ["storage", []]);
            private _stateResult = [_empty, "EMPTY", false] call ServoPeregrino_Organizador_Items_fnc_buildRepositoryState;
            if !(_stateResult getOrDefault ["success", false]) then {
                _result = _stateResult;
            } else {
                _result = [
                    true,
                    "ITEMS_STORAGE_EMPTY_READY",
                    "Nenhum storage persistido foi encontrado; Repository iniciou vazio em memória sem gravar profileNamespace.",
                    createHashMapFromArray [["source", "EMPTY"], ["storage", _empty], ["repository", ((_stateResult getOrDefault ["data", createHashMap]) getOrDefault ["repository", createHashMap])]]
                ] call ServoPeregrino_Organizador_Nexus_fnc_createResult;
            };
        };
    };
};

_result
