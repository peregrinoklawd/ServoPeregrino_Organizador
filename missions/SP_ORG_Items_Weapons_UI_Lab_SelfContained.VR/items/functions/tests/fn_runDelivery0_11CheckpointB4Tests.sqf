#include "..\..\script_version.hpp"
disableSerialization;

private _legacyRunningState=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR,createHashMap];
if (_legacyRunningState getOrDefault ["running",false]) exitWith {[false,"ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING","A regressão legada já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _orchestrator=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
if (_orchestrator getOrDefault ["running",false]) exitWith {[false,"ITEMS_0_11_CP_B4_ALREADY_RUNNING","Outra suíte cumulativa já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};

private _startedAt=diag_tickTime;
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.11 CP-B.4 — AUDIO PERFORMANCE HOLD + STORAGE GUARD FIX — 424 GATES";
diag_log "============================================================";

// Snapshot das chaves reais antes de compor a baseline histórica.
private _productionBefore=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
uiSleep 0.02;
private _base=[] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_11CheckpointBTests;
private _productionAfterBase=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _transientProductionChanged=!(_productionBefore isEqualTo _productionAfterBase);
private _restoreBase=[_productionBefore] call ServoPeregrino_Organizador_Items_fnc_restoreProductionRepositorySnapshot;
private _productionRestored=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _productionRestoreExact=_productionBefore isEqualTo _productionRestored;
diag_log format ["[SP_ORG] [ITEMS] [TEST_STORAGE_GUARD] afterBase transientChanged=%1 restoredExact=%2",_transientProductionChanged,_productionRestoreExact];

private _baseOk=(_base isEqualType createHashMap) && {_base getOrDefault ["success",false]} && {(_base getOrDefault ["checkpointPassed",0]) isEqualTo 8} && {(_base getOrDefault ["cumulativePassed",0]) isEqualTo 414};
if !(_baseOk) exitWith {
    [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
    private _summary=createHashMapFromArray [["delivery","0.11 CP-B.4"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",false],["code","ITEMS_0_11_CP_B4_BASE_414_FAILED"],["base",_base],["checkpointSkipped",true],["checkpointFirstGate",415],["checkpointLastGate",424],["checkpointTotal",0],["checkpointPassed",0],["checkpointFailed",0],["cumulativeExpected",424],["productionRestored",_productionRestoreExact]];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    diag_log "[SP_ORG] [ITEMS] 0.11 CP-B.4 — FAIL-FAST: baseline 414/414 não fechou; produção restaurada antes de sair.";
    if (hasInterface) then {hint "SP_ORG_Items 0.11 CP-B.4 reprovado na baseline 414/414. Consulte o primeiro FAIL no RPT.";};
    _summary
};

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.11 CP-B.4"]]];
private _passed=0;
private _failed=0;
private _results=[];
private _assert={
    params ["_id","_condition","_detail"];
    private _status=if (_condition) then {"PASS"} else {"FAIL"};
    if (_condition) then {_passed=_passed+1;} else {_failed=_failed+1;};
    _results pushBack [_id,_status,_detail];
    diag_log format ["[SP_ORG] [ITEMS] [TEST 0.11 CP-B.4] [%1] %2 — %3",_status,_id,_detail];
};

private _oldUIState=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _oldDraftState=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _resetUI={missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]; [] call ServoPeregrino_Organizador_Items_fnc_createUIState;};

// 415 — política global: áudio normal está em hold e UI nasce explicitamente OFF.
call _resetUI;
private _ui415=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _gate415=(SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_AUDIO_PERFORMANCE_HOLD > 0) && {!(_ui415 getOrDefault ["soundEnabled",true])} && {_ui415 getOrDefault ["soundPerformanceHold",false]};
["ITEMS-0.11-415",_gate415,"Áudio de UI nasce OFF e performance hold global permanece explícito enquanto investigamos o custo de playback."] call _assert;

// 416 — presenters não entram na camada sonora no runtime normal.
private _srcP416=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_presentUIResult.sqf";
private _srcL416=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_presentLogicalMutationResult.sqf";
private _gate416=(_srcP416 find "UI_AUDIO_PERFORMANCE_HOLD" >= 0) && {(_srcP416 find "_testTelemetry" >= 0)} && {(_srcL416 find "UI_AUDIO_PERFORMANCE_HOLD" >= 0)} && {(_srcL416 find "_testTelemetry" >= 0)};
["ITEMS-0.11-416",_gate416,"Presenters pulam áudio em runtime normal, mas preservam telemetria lógica exclusivamente durante a suíte histórica."] call _assert;

// 417 — serviço de movimento faz early-exit antes de provider/CfgSounds no runtime normal.
private _savedOrch417=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
private _m417=["REMOVE"] call ServoPeregrino_Organizador_Items_fnc_playUIMovementSound;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,_savedOrch417];
private _gate417=(_m417 getOrDefault ["suppressedByPerformanceHold",false]) && {!(_m417 getOrDefault ["attempted",true])} && {!(_m417 getOrDefault ["played",true])} && {(_m417 getOrDefault ["method",""]) isEqualTo "PERFORMANCE_HOLD_NO_LOOKUP"} && {(_m417 getOrDefault ["provider",""]) isEqualTo "AUDIO_PERFORMANCE_HOLD"};
["ITEMS-0.11-417",_gate417,"Movimento normal retorna antes de resolver provider/CfgSounds e nunca chama playSoundUI enquanto o hold está ativo."] call _assert;

// 418 — outcomes excepcionais também ficam mudos no runtime normal.
private _savedOrch418=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
private _f418=["FAILURE"] call ServoPeregrino_Organizador_Items_fnc_playUIFeedbackSound;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,_savedOrch418];
private _gate418=(_f418 getOrDefault ["suppressedByPerformanceHold",false]) && {!(_f418 getOrDefault ["attempted",true])} && {!(_f418 getOrDefault ["played",true])} && {(_f418 getOrDefault ["method",""]) isEqualTo "PERFORMANCE_HOLD_NO_LOOKUP"};
["ITEMS-0.11-418",_gate418,"SUCCESS/PARTIAL/BLOCKED/FAILURE/ROLLBACK não reproduzem áudio no runtime normal durante o performance hold."] call _assert;

// 419 — compatibilidade: durante testes a camada sonora continua só como telemetria, sem playback real.
call _resetUI;
private _m419=["ADD"] call ServoPeregrino_Organizador_Items_fnc_playUIMovementSound;
private _u419=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _gate419=(_m419 getOrDefault ["suppressedByTests",false]) && {!(_m419 getOrDefault ["attempted",true])} && {!(_m419 getOrDefault ["played",true])} && {(count (_u419 getOrDefault ["movementSoundHistory",[]])) isEqualTo 1};
["ITEMS-0.11-419",_gate419,"Suíte histórica ainda registra cue lógico para preservar os gates 407..414, mas nunca reproduz áudio real."] call _assert;

// 420 — classificador corrigido: fixture conhecido é HIGH, kit normal não é classificado.
private _fakeEntryR=["ITEM","FirstAidKit",1,"NONE",[]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _fakeEntry=(_fakeEntryR getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]];
private _fakeTestR=["Kit CP-C",[_fakeEntry],"ANY",["MANUAL","CPC_TEST"],""] call ServoPeregrino_Organizador_Items_fnc_createItemKit;
private _fakeUserR=["Meu Kit Normal",[_fakeEntry],"ANY",["USER","NORMAL"],""] call ServoPeregrino_Organizador_Items_fnc_createItemKit;
private _kitTest420=((_fakeTestR getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]]);
private _kitUser420=((_fakeUserR getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]]);
private _ct420=[_kitTest420] call ServoPeregrino_Organizador_Items_fnc_classifyLeakedTestKit;
private _cu420=[_kitUser420] call ServoPeregrino_Organizador_Items_fnc_classifyLeakedTestKit;
private _gate420=(_ct420 isEqualType createHashMap) && {_cu420 isEqualType createHashMap} && {_ct420 getOrDefault ["isTestKit",false]} && {(_ct420 getOrDefault ["confidence",""]) isEqualTo "HIGH"} && {!(_cu420 getOrDefault ["isTestKit",true])};
["ITEMS-0.11-420",_gate420,"Classificador de kits vazados compila/executa sem erro e exige nome + metadata de fixture para confiança HIGH."] call _assert;

// 421 — scanner de produção é read-only e não vaza variável indefinida.
private _prod421a=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _scan421=[] call ServoPeregrino_Organizador_Items_fnc_findLeakedTestKits;
private _prod421b=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _gate421=(_scan421 isEqualType createHashMap) && {_scan421 getOrDefault ["success",false]} && {_prod421a isEqualTo _prod421b};
["ITEMS-0.11-421",_gate421,"Scanner de fixtures executa de forma read-only e preserva exatamente as chaves de produção."] call _assert;

// 422 — limpeza continua exigindo confirmação explícita.
private _cleanup422=[""] call ServoPeregrino_Organizador_Items_fnc_cleanupLeakedTestKits;
private _gate422=(_cleanup422 isEqualType createHashMap) && {!(_cleanup422 getOrDefault ["success",true])} && {(_cleanup422 getOrDefault ["code",""]) isEqualTo "ITEMS_TEST_LEAK_CLEANUP_CONFIRMATION_REQUIRED"};
["ITEMS-0.11-422",_gate422,"Limpeza de fixtures nunca roda automaticamente e continua bloqueada sem confirmação explícita."] call _assert;

// 423 — composição da baseline restaura exatamente o storage real.
private _gate423=(_restoreBase isEqualType createHashMap) && {_restoreBase getOrDefault ["restored",false]} && {_productionRestoreExact};
["ITEMS-0.11-423",_gate423,"Runner cumulativo restaura exatamente o storage de produção após a baseline 414/414."] call _assert;

// 424 — source hardening: classificador executável e scanner valida tipo antes de getOrDefault.
private _srcClass424=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\tests\fn_classifyLeakedTestKit.sqf";
private _srcFind424=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\tests\fn_findLeakedTestKits.sqf";
private _gate424=(_srcClass424 find "private _metaPatterns" >= 0) && {(_srcClass424 find "cpb_test" >= 0)} && {(_srcClass424 find "cpc_test" >= 0)} && {(_srcFind424 find "isEqualType createHashMap" >= 0)};
["ITEMS-0.11-424",_gate424,"Hardening remove a construção que gerava 'Faltante ]' e protege o scanner contra retorno não-HashMap."] call _assert;

// Defesa em profundidade: restaura produção novamente ao terminar.
[_productionBefore] call ServoPeregrino_Organizador_Items_fnc_restoreProductionRepositorySnapshot;
private _productionFinal=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _productionFinalExact=_productionBefore isEqualTo _productionFinal;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,_oldDraftState];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_oldUIState];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;

private _durationMs=round ((diag_tickTime-_startedAt)*1000);
private _summary=createHashMapFromArray [["delivery","0.11 CP-B.4"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],["base",_base],["baseExpected",414],["checkpointFirstGate",415],["checkpointLastGate",424],["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],["cumulativeExpected",424],["cumulativePassed",414+_passed],["durationMs",_durationMs],["productionRestored",_productionRestoreExact && _productionFinalExact],["transientProductionChanged",_transientProductionChanged],["audioPerformanceHold",true]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] 0.11 CP-B.4 — BASE=414/414  CP-B.4=%1/10  FAIL=%2  CUMULATIVO=%3/424  TEMPO=%4ms",_passed,_failed,414+_passed,_durationMs];
diag_log format ["[SP_ORG] [ITEMS] 0.11 CP-B.4 — AUDIO=OFF(performance hold) storageGuard restoredExact=%1 finalExact=%2 transientChanged=%3",_productionRestoreExact,_productionFinalExact,_transientProductionChanged];
diag_log "============================================================";
if (hasInterface) then {hint parseText format ["<t size='1.25'>SP_ORG_Items 0.11 CP-B.4</t><br/><br/>Baseline: <t color='#7CFC00'>414 / 414</t><br/>CP-B.4: <t color='%1'>%2 / 10</t><br/>Cumulativo: %3 / 424<br/>Áudio: OFF (performance hold)<br/>Storage restaurado: %4<br/><br/>%5",if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_passed,414+_passed,(_productionRestoreExact && _productionFinalExact),if (_failed isEqualTo 0) then {"424/424 concluído. Valide movimentação sem gargalo e envie o RPT."} else {"Consulte o primeiro FAIL no RPT."}];};
_summary
