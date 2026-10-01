#include "..\..\script_version.hpp"
params [
    ["_plan", createHashMap, [createHashMap]],
    ["_options", createHashMap, [createHashMap]]
];
private _validation = [_plan] call ServoPeregrino_Organizador_Items_fnc_validateApplicationPlan;
if !(_validation getOrDefault ["success", false]) exitWith {_validation};

private _lockR = [_plan getOrDefault ["planId", ""], _options getOrDefault ["lockOwner", "LOCAL"], _options getOrDefault ["lockTimeoutSeconds", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_LOCK_TIMEOUT]] call ServoPeregrino_Organizador_Items_fnc_acquireApplicationLock;
if !(_lockR getOrDefault ["success", false]) exitWith {_lockR};
private _lockData = _lockR getOrDefault ["data", createHashMap];
private _lockToken = _lockData getOrDefault ["token", ""];
private _lockRecovered = _lockData getOrDefault ["recovered", false];

private _finish = {
    params ["_result"];
    private _release = [_lockToken, _result] call ServoPeregrino_Organizador_Items_fnc_releaseApplicationLock;
    if !(_release getOrDefault ["success", false]) then {
        diag_log format ["[SP_ORG] [ITEMS] [APPLICATION] Lock release recusado token=%1 code=%2", _lockToken, _release getOrDefault ["code", "UNKNOWN"]];
        private _d = _result getOrDefault ["data", createHashMap];
        _d set ["lockRelease", _release];
        _result set ["data", _d];
    };
    _result
};
private _safeRollback = {
    params ["_snapshotArg", "_reasonArg"];
    private _rb = createHashMap;
    private _rawRb = [_snapshotArg, _reasonArg] call ServoPeregrino_Organizador_Items_fnc_rollbackApplication;
    if !(isNil "_rawRb") then {if (_rawRb isEqualType createHashMap) then {_rb = _rawRb;};};
    if ((count _rb) isEqualTo 0) then {
        _rb = [false, "ITEMS_INTERNAL_ROLLBACK_RESULT_INVALID", "Rollback interno não devolveu Result HashMap válido; estado físico deve ser tratado como crítico.", createHashMapFromArray [["reason", _reasonArg]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult;
    };
    _rb
};

private _container = _plan getOrDefault ["container", objNull];
private _target = _plan getOrDefault ["target", ""];
private _class = _plan getOrDefault ["containerClass", ""];
private _fpNowR = [_container, _target, _class] call ServoPeregrino_Organizador_Items_fnc_getMutableContentFingerprint;
if !(_fpNowR getOrDefault ["success", false]) exitWith {[_fpNowR] call _finish};
private _fpNow = ((_fpNowR getOrDefault ["data", createHashMap]) getOrDefault ["fingerprint", createHashMap]);
private _fpPlan = _plan getOrDefault ["containerFingerprint", createHashMap];
if ((_fpNow getOrDefault ["serialized", "A"]) isNotEqualTo (_fpPlan getOrDefault ["serialized", "B"])) exitWith {
    [[false, "ITEMS_PLAN_STALE", "Fingerprint mudou entre plan e commit; nenhuma mutação foi iniciada.", createHashMapFromArray [["planFingerprint", _fpPlan], ["currentFingerprint", _fpNow], ["lockRecovered", _lockRecovered]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult] call _finish
};

private _snapshotR = [_container, _target, _class] call ServoPeregrino_Organizador_Items_fnc_captureContainerSnapshot;
if !(_snapshotR getOrDefault ["success", false]) exitWith {[_snapshotR] call _finish};
private _snapshot = ((_snapshotR getOrDefault ["data", createHashMap]) getOrDefault ["snapshot", createHashMap]);
private _mutationFailed = false;
private _mutationFailure = createHashMap;
private _injectedDuring = false;
private _injectAfterIndex = _options getOrDefault ["injectFailureAfterActionIndex", -1];
private _actionResults = [];
{
    private _mr = createHashMap;
    private _rawMr = [_container, _x getOrDefault ["operation", ""], _x getOrDefault ["entry", []]] call ServoPeregrino_Organizador_Items_fnc_mutateContainerEntry;
    if !(isNil "_rawMr") then {if (_rawMr isEqualType createHashMap) then {_mr = _rawMr;};};
    if ((count _mr) isEqualTo 0) then {
        _mr = [false, "ITEMS_INTERNAL_MUTATION_RESULT_INVALID", "Mutação física interna não devolveu Result HashMap válido; commit será revertido.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult;
    };
    _actionResults pushBack createHashMapFromArray [["index", _forEachIndex], ["operation", _x getOrDefault ["operation", ""]], ["entry", [_x getOrDefault ["entry", []]] call ServoPeregrino_Organizador_Items_fnc_deepCopy], ["success", _mr getOrDefault ["success", false]], ["code", _mr getOrDefault ["code", ""]]];
    if !(_mr getOrDefault ["success", false]) exitWith {_mutationFailed = true; _mutationFailure = _mr;};
    if (_injectAfterIndex >= 0 && {_forEachIndex isEqualTo _injectAfterIndex}) exitWith {_injectedDuring = true;};
} forEach (_plan getOrDefault ["actions", []]);

if (_mutationFailed || {_injectedDuring} || {_options getOrDefault ["injectFailureAfterCommit", false]}) exitWith {
    private _reason = if (_mutationFailed) then {"ITEMS_COMMIT_ACTION_FAILED"} else {if (_injectedDuring) then {"ITEMS_TEST_INJECTED_DURING_COMMIT"} else {"ITEMS_TEST_INJECTED_FAILURE"}};
    private _rb = [_snapshot, _reason] call _safeRollback;
    private _ok = _rb getOrDefault ["success", false];
    [[false, if (_ok) then {"ITEMS_ROLLED_BACK"} else {"ITEMS_ROLLBACK_FAILED"}, if (_ok) then {"Commit interrompido e rollback comprovado."} else {"Commit interrompido e rollback falhou."}, createHashMapFromArray [["status", if (_ok) then {"ROLLED_BACK"} else {"ROLLBACK_FAILED"}], ["operation", _plan getOrDefault ["operation", ""]], ["rolledBack", true], ["rollbackSucceeded", _ok], ["rollbackResult", _rb], ["mutationFailure", _mutationFailure], ["actionResults", _actionResults], ["snapshot", _snapshot], ["lockRecovered", _lockRecovered]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult] call _finish
};

private _afterR = [_container, _target, _class] call ServoPeregrino_Organizador_Items_fnc_getMutableContentFingerprint;
if !(_afterR getOrDefault ["success", false]) exitWith {
    private _rb = [_snapshot, "ITEMS_POST_VALIDATE_CAPTURE_FAILED"] call _safeRollback;
    [[false, if (_rb getOrDefault ["success", false]) then {"ITEMS_ROLLED_BACK"} else {"ITEMS_ROLLBACK_FAILED"}, "Falha no post-validate exigiu rollback.", createHashMapFromArray [["operation", _plan getOrDefault ["operation", ""]], ["rollbackResult", _rb], ["actionResults", _actionResults]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult] call _finish
};
private _afterFp = ((_afterR getOrDefault ["data", createHashMap]) getOrDefault ["fingerprint", createHashMap]);
private _expectedFp = _plan getOrDefault ["expectedFingerprint", createHashMap];
if ((_afterFp getOrDefault ["serialized", "A"]) isNotEqualTo (_expectedFp getOrDefault ["serialized", "B"])) exitWith {
    private _rb = [_snapshot, "ITEMS_RUNTIME_DIVERGENCE"] call _safeRollback;
    private _ok = _rb getOrDefault ["success", false];
    [[false, if (_ok) then {"ITEMS_ROLLED_BACK"} else {"ITEMS_ROLLBACK_FAILED"}, "Post-validate detectou runtime divergence.", createHashMapFromArray [["status", if (_ok) then {"ROLLED_BACK"} else {"ROLLBACK_FAILED"}], ["operation", _plan getOrDefault ["operation", ""]], ["rolledBack", true], ["rollbackSucceeded", _ok], ["actualFingerprint", _afterFp], ["expectedFingerprint", _expectedFp], ["rollbackResult", _rb], ["actionResults", _actionResults]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult] call _finish
};

private _partial = (count (_plan getOrDefault ["rejectedEntries", []])) > 0;
private _appliedEntries = (_plan getOrDefault ["actions", []]) apply {[_x getOrDefault ["entry", []]] call ServoPeregrino_Organizador_Items_fnc_deepCopy};
private _applyResult = createHashMapFromArray [
    ["version", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLY_RESULT_VERSION], ["status", if (_partial) then {"PARTIAL"} else {"COMPLETE"}],
    ["planId", _plan getOrDefault ["planId", ""]], ["scope", _plan getOrDefault ["scope", "ENTRY_OR_SET"]], ["operation", _plan getOrDefault ["operation", ""]],
    ["target", _target], ["requestedEntries", [_plan getOrDefault ["requestedEntries", []]] call ServoPeregrino_Organizador_Items_fnc_deepCopy],
    ["appliedEntries", _appliedEntries], ["actionResults", _actionResults], ["rejectedEntries", [_plan getOrDefault ["rejectedEntries", []]] call ServoPeregrino_Organizador_Items_fnc_deepCopy],
    ["rolledBack", false], ["rollbackSucceeded", false], ["fingerprint", _afterFp], ["lockRecovered", _lockRecovered]
];
[[true, if (_partial) then {"ITEMS_APPLICATION_PARTIAL"} else {"ITEMS_APPLICATION_COMPLETE"}, if (_partial) then {"Transação concluída parcialmente conforme BEST_EFFORT."} else {"Transação física concluída e validada."}, createHashMapFromArray [["applyResult", _applyResult], ["snapshot", _snapshot]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult] call _finish
