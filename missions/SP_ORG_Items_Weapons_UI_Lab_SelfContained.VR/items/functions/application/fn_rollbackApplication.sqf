params [["_snapshot", createHashMap, [createHashMap]], ["_reason", "ITEMS_RUNTIME_DIVERGENCE", [""]]];
private _restore = createHashMap;
private _rawRestore = [_snapshot] call ServoPeregrino_Organizador_Items_fnc_restoreContainerSnapshot;
if !(isNil "_rawRestore") then {if (_rawRestore isEqualType createHashMap) then {_restore = _rawRestore;};};
if ((count _restore) isEqualTo 0) then {
    _restore = [false, "ITEMS_INTERNAL_RESTORE_RESULT_INVALID", "Restauração interna não devolveu Result HashMap válido.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult;
};
private _ok = _restore getOrDefault ["success", false];
[
    _ok,
    if (_ok) then {"ITEMS_ROLLED_BACK"} else {"ITEMS_ROLLBACK_FAILED"},
    if (_ok) then {"Transação revertida para o snapshot focal."} else {"Rollback não pôde ser comprovado; estado físico é crítico."},
    createHashMapFromArray [["reason", _reason], ["rollbackSucceeded", _ok], ["restoreResult", _restore]]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
