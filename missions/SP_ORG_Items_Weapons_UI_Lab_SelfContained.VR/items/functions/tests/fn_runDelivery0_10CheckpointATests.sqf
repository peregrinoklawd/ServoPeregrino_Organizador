#include "..\..\script_version.hpp"

private _legacyRunningState = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR, createHashMap];
if (_legacyRunningState getOrDefault ["running",false]) exitWith {
    private _elapsedLegacy = round ((diag_tickTime - (_legacyRunningState getOrDefault ["startedAtTick",diag_tickTime])) * 1000);
    private _busyLegacy = createHashMapFromArray [["success",false],["code","ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING"],["elapsedMs",_elapsedLegacy]];
    if (hasInterface) then {hint format ["A regressão 0.9.3 já está em execução (%1 ms). Execute o CP-A depois do resumo final.",_elapsedLegacy];};
    _busyLegacy
};

private _orchestrator = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR, createHashMap];
private _orchestratorRunning = _orchestrator getOrDefault ["running",false];
private _orchestratorElapsed = if (_orchestratorRunning) then {diag_tickTime - (_orchestrator getOrDefault ["startedAtTick",diag_tickTime])} else {0};
if (_orchestratorRunning && {_orchestratorElapsed < 900}) exitWith {
    private _busy = createHashMapFromArray [["success",false],["code","ITEMS_0_10_CP_A_ALREADY_RUNNING"],["elapsedMs",round (_orchestratorElapsed*1000)]];
    if (hasInterface) then {hint format ["SP_ORG_Items 0.10 CP-A já está em execução (%1 ms).",_busy getOrDefault ["elapsedMs",0]];};
    _busy
};
if (_orchestratorRunning) then {
    diag_log format ["[SP_ORG] [ITEMS] [0.10 CP-A] Recuperando lock stale do orquestrador após %1 s.",round _orchestratorElapsed];
};

private _startedAt = diag_tickTime;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.10-CP-A"]]];

diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.10 CP-A — INICIANDO REGRESSÃO IMUTÁVEL 0.9.3 (363 gates)";
diag_log "============================================================";

private _legacy = [] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_9_3Tests;
private _checkpointResults = [];
private _cpPassed = 0;
private _cpFailed = 0;
private _assert = {
    params ["_id","_condition","_detail"];
    private _status = if (_condition) then {"PASS"} else {"FAIL"};
    if (_condition) then {_cpPassed=_cpPassed+1;} else {_cpFailed=_cpFailed+1;};
    _checkpointResults pushBack [_id,_status,_detail];
    diag_log format ["[SP_ORG] [ITEMS] [0.10 CP-A] [%1] %2 — %3",_status,_id,_detail];
};

private _legacyOk = (_legacy isEqualType createHashMap)
    && {_legacy getOrDefault ["success",false]}
    && {(_legacy getOrDefault ["total",0]) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_LEGACY_GATE_COUNT}
    && {(_legacy getOrDefault ["passed",0]) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_LEGACY_GATE_COUNT}
    && {(_legacy getOrDefault ["failed",-1]) isEqualTo 0};
["ITEMS-0.10-CP-A-001",_legacyOk,"Baseline 0.9.3 é executada por composição, sem copiar o runner: gate esperado 363/363."] call _assert;

private _contract = [] call ServoPeregrino_Organizador_Items_fnc_getDelivery0_10TestContract;
["ITEMS-0.10-CP-A-002",(count _contract) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_10_NEW_GATE_COUNT,"Contrato final 0.10 contém exatamente 27 novos gates."] call _assert;

private _ids = _contract apply {_x param [0,"",[""]]};
private _uniqueIds = _ids arrayIntersect _ids;
["ITEMS-0.10-CP-A-003",(count _uniqueIds) isEqualTo (count _ids),"IDs 364..390 são únicos."] call _assert;

private _sequenceOk = true;
for "_i" from 0 to ((count _contract)-1) do {
    private _expected = format ["ITEMS-0.10-%1",364+_i];
    if !((_ids param [_i,"",[""]]) isEqualTo _expected) exitWith {_sequenceOk=false;};
};
["ITEMS-0.10-CP-A-004",_sequenceOk,"Contrato mantém sequência contínua ITEMS-0.10-364 até ITEMS-0.10-390."] call _assert;

private _checkpoints = _contract apply {_x param [2,"",[""]]};
private _checkpointCoverage = ("CP-B" in _checkpoints) && {"CP-C" in _checkpoints} && {"CP-D" in _checkpoints};
["ITEMS-0.10-CP-A-005",_checkpointCoverage,"Novos gates estão distribuídos entre motor Whole-Kit, UI/DnD e hardening final."] call _assert;

private _appR = [] call ServoPeregrino_Organizador_Items_fnc_getApplicationStatus;
private _appD = _appR getOrDefault ["data",createHashMap];
private _uiR = [] call ServoPeregrino_Organizador_Items_fnc_getUIState;
private _uiD = (_uiR getOrDefault ["data",createHashMap]) getOrDefault ["state",createHashMap];
private _baselineFrozen = (_appD getOrDefault ["planVersion",0]) isEqualTo 1
    && {(_appD getOrDefault ["snapshotVersion",0]) isEqualTo 1}
    && {(_appD getOrDefault ["applyResultVersion",0]) isEqualTo 1}
    && {!(_uiD getOrDefault ["physicalMutationEnabled",true])};
["ITEMS-0.10-CP-A-006",_baselineFrozen,"Checkpoint A mantém ApplicationPlan/Snapshot/ApplyResult v1 e UI physical OFF; nenhuma feature 0.10 é ativada prematuramente."] call _assert;

private _buildR = [] call ServoPeregrino_Organizador_Items_fnc_getBuildInfo;
private _buildOk = (_buildR getOrDefault ["displayVersion",""]) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DISPLAY_VERSION
    && {(_buildR getOrDefault ["semanticVersion",""]) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_SEMANTIC_VERSION}
    && {(SERVO_PEREGRINO_ORGANIZADOR_ITEMS_LEGACY_GATE_COUNT + SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_10_NEW_GATE_COUNT) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_10_FINAL_GATE_COUNT};
["ITEMS-0.10-CP-A-007",_buildOk,"Build CP-A é identificável e o gate final planejado permanece 363 + 27 = 390."] call _assert;

private _durationMs = round ((diag_tickTime-_startedAt)*1000);
private _summary = createHashMapFromArray [
    ["delivery","0.10-CP-A"],
    ["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],
    ["success",_legacyOk && {_cpFailed isEqualTo 0}],
    ["legacy",_legacy],
    ["legacyExpected",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_LEGACY_GATE_COUNT],
    ["newFinalContractCount",count _contract],
    ["finalExpected",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_10_FINAL_GATE_COUNT],
    ["checkpointTotal",_cpPassed+_cpFailed],
    ["checkpointPassed",_cpPassed],
    ["checkpointFailed",_cpFailed],
    ["checkpointResults",_checkpointResults],
    ["durationMs",_durationMs]
];

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];

diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] 0.10 CP-A — LEGACY=%1/%2  CP-A=%3/%4  FAIL=%5  TEMPO=%6ms",_legacy getOrDefault ["passed",0],SERVO_PEREGRINO_ORGANIZADOR_ITEMS_LEGACY_GATE_COUNT,_cpPassed,_cpPassed+_cpFailed,_cpFailed,_durationMs];
diag_log "[SP_ORG] [ITEMS] 0.10 FINAL CONTRACT — 27 novos gates; gate final planejado 390/390.";
diag_log "============================================================";

if (hasInterface) then {
    hint parseText format ["<t size='1.25'>SP_ORG_Items 0.10 — Checkpoint A</t><br/><br/>Baseline 0.9.3: <t color='%1'>%2 / 363</t><br/>Checks CP-A: <t color='%3'>%4 / %5</t><br/>Contrato 0.10 congelado: 27 gates<br/>Gate final planejado: 390 / 390<br/><br/>Physical UI continua OFF neste checkpoint.",if (_legacyOk) then {"#7CFC00"} else {"#FF6B6B"},_legacy getOrDefault ["passed",0],if (_cpFailed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_cpPassed,_cpPassed+_cpFailed];
};
_summary
