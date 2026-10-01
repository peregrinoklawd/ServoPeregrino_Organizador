#include "..\..\script_version.hpp"
disableSerialization;
private _legacyRunningState=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR,createHashMap];
if (_legacyRunningState getOrDefault ["running",false]) exitWith {[false,"ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING","A regressão legada já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _orchestrator=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
if (_orchestrator getOrDefault ["running",false]) exitWith {[false,"ITEMS_0_11_CP_B1_ALREADY_RUNNING","Outra suíte cumulativa já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _startedAt=diag_tickTime;
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.11 CP-B.1 — VANILLA INVENTORY SOUNDS + DELETE COVERAGE — 420 GATES";
diag_log "============================================================";
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
uiSleep 0.02;
private _base=[] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_11CheckpointBTests;
private _baseOk=(_base isEqualType createHashMap) && {_base getOrDefault ["success",false]} && {(_base getOrDefault ["checkpointPassed",0]) isEqualTo 8} && {(_base getOrDefault ["cumulativePassed",0]) isEqualTo 414};
if !(_baseOk) exitWith {
    [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
    private _summary=createHashMapFromArray [["delivery","0.11 CP-B.1"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",false],["code","ITEMS_0_11_CP_B1_BASE_414_FAILED"],["base",_base],["checkpointSkipped",true],["checkpointFirstGate",415],["checkpointLastGate",420],["checkpointTotal",0],["checkpointPassed",0],["checkpointFailed",0],["cumulativeExpected",420]];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    diag_log "[SP_ORG] [ITEMS] 0.11 CP-B.1 — FAIL-FAST: baseline 414/414 não fechou; gates 415..420 NÃO executados.";
    if (hasInterface) then {hint "SP_ORG_Items 0.11 CP-B.1 reprovado na baseline 414/414. Consulte o primeiro FAIL no RPT.";};
    _summary
};
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.11 CP-B.1"]]];
private _passed=0; private _failed=0; private _results=[];
private _assert={params ["_id","_condition","_detail"]; private _status=if (_condition) then {"PASS"} else {"FAIL"}; if (_condition) then {_passed=_passed+1;} else {_failed=_failed+1;}; _results pushBack [_id,_status,_detail]; diag_log format ["[SP_ORG] [ITEMS] [TEST 0.11 CP-B.1] [%1] %2 — %3",_status,_id,_detail];};
private _oldUIState=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _oldDraftState=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _resetUI={missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]; [] call ServoPeregrino_Organizador_Items_fnc_createUIState;};
private _mkPhysicalResult={params ["_ok","_code","_operation","_status"]; [_ok,_code,_code,createHashMapFromArray [["uiCommand",createHashMapFromArray [["operation",_operation],["target","U"],["commandId",format ["TEST-B1-%1",_operation]],["singleDispatch",true]]],["applyResult",createHashMapFromArray [["status",_status],["appliedEntries",if (_ok) then {[[1,"ITEM","FirstAidKit",1,"NONE",[]]]} else {[]}],["rejectedEntries",[]],["actionResults",[createHashMapFromArray [["success",_ok]]]]]]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult};

// 415 — perfil normal usa assets vanilla conhecidos e diferencia entrada/saída.
private _add415=["ADD"] call ServoPeregrino_Organizador_Items_fnc_getUIMovementSoundProfile;
private _rem415=["REMOVE"] call ServoPeregrino_Organizador_Items_fnc_getUIMovementSoundProfile;
private _gate415=(_add415 getOrDefault ["provider",""]) isEqualTo "ARMA3_VANILLA_UI" && {(_rem415 getOrDefault ["provider",""]) isEqualTo "ARMA3_VANILLA_UI"} && {toLower (_add415 getOrDefault ["path",""]) find "a3\ui_f\data\sound\rscbutton" >= 0} && {toLower (_rem415 getOrDefault ["path",""]) find "a3\ui_f\data\sound\rscbutton" >= 0} && {(_add415 getOrDefault ["path",""]) isNotEqualTo (_rem415 getOrDefault ["path",""])};
["ITEMS-0.11-415",_gate415,"Movimentação normal usa samples vanilla A3\ui_f e diferencia ADD de REMOVE sem depender de mod externo."] call _assert;

// 416 — serviço vanilla respeita supressão da suíte e mantém exatamente um cue/gesto na telemetria antiga e nova.
call _resetUI;
private _m416=["REMOVE"] call ServoPeregrino_Organizador_Items_fnc_playUIMovementSound;
private _u416=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _gate416=(_m416 getOrDefault ["suppressedByTests",false]) && {!(_m416 getOrDefault ["played",true])} && {(count (_u416 getOrDefault ["movementSoundHistory",[]])) isEqualTo 1} && {(count (_u416 getOrDefault ["soundHistory",[]])) isEqualTo 1} && {(_u416 getOrDefault ["lastSoundOutcome",""]) isEqualTo "MOVE_REMOVE"};
["ITEMS-0.11-416",_gate416,"Serviço de movimento registra um único cue vanilla, é silencioso na suíte e preserva telemetria CP-B."] call _assert;

// 417 — SUCCESS físico usa movimento vanilla; PARTIAL continua cue excepcional.
call _resetUI;
private _s417=[true,"ITEMS_APPLICATION_COMPLETE","ADD","COMPLETE"] call _mkPhysicalResult;
[_s417,true] call ServoPeregrino_Organizador_Items_fnc_presentUIResult;
private _u417a=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _moveCount417=count (_u417a getOrDefault ["movementSoundHistory",[]]);
private _p417=[true,"ITEMS_APPLICATION_PARTIAL","ADD","PARTIAL"] call _mkPhysicalResult;
private _pd417=_p417 getOrDefault ["data",createHashMap]; private _pa417=_pd417 getOrDefault ["applyResult",createHashMap]; _pa417 set ["rejectedEntries",[[1,"ITEM","ToolKit",1,"NONE",[]]]]; _pd417 set ["applyResult",_pa417]; _p417 set ["data",_pd417];
[_p417,true] call ServoPeregrino_Organizador_Items_fnc_presentUIResult;
private _u417b=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _gate417=_moveCount417 isEqualTo 1 && {(count (_u417b getOrDefault ["movementSoundHistory",[]])) isEqualTo 1} && {(_u417b getOrDefault ["lastSoundOutcome",""]) isEqualTo "PARTIAL"};
["ITEMS-0.11-417",_gate417,"SUCCESS físico toca movimento vanilla; PARTIAL/falha/rollback continuam reservados aos cues excepcionais."] call _assert;

// 418 — Delete lógico e quantidade 0 têm REMOVE audível via helper central, sem fabricar mutação física.
call _resetUI;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMap];
["CP-B.1 Delete Test","ANY",["TEST","B1"],[]] call ServoPeregrino_Organizador_Items_fnc_createNewDraft;
private _e418=["ITEM","FirstAidKit",1,"NONE",[]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
if (_e418 getOrDefault ["success",false]) then {[((_e418 getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]])] call ServoPeregrino_Organizador_Items_fnc_addEntryToDraft;};
private _d418=["DELETE",["ITEM","FirstAidKit","NONE"]] call ServoPeregrino_Organizador_Items_fnc_handleDraftRowAction;
[_d418,"REMOVE",true] call ServoPeregrino_Organizador_Items_fnc_presentLogicalMutationResult;
private _u418=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _gate418=(_d418 getOrDefault ["success",false]) && {(_d418 getOrDefault ["code",""]) isEqualTo "ITEMS_DRAFT_ENTRY_REMOVED"} && {(count (_u418 getOrDefault ["movementSoundHistory",[]])) isEqualTo 1} && {((_u418 getOrDefault ["movementSoundHistory",[]])#0)#0 isEqualTo "REMOVE"};
["ITEMS-0.11-418",_gate418,"Delete/remoção lógica usa o mesmo cue vanilla REMOVE e continua mutatesInventory=false no Draft."] call _assert;

// 419 — caminhos reais de Delete, -, + e quantidade passam pelo apresentador central; Equipment Delete usa presentUIResult.
private _srcKey419=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUIKeyDown.sqf";
private _srcRefresh419=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshInterface.sqf";
private _srcQty419=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_commitDraftQuantityFromControl.sqf";
private _gate419=(_srcKey419 find "fnc_presentUIResult" >= 0) && {_srcKey419 find "fnc_presentLogicalMutationResult" >= 0} && {_srcRefresh419 find "fnc_presentLogicalMutationResult" >= 0} && {_srcQty419 find "fnc_presentLogicalMutationResult" >= 0} && {_srcQty419 find "ITEMS_DRAFT_ENTRY_REMOVED" >= 0};
["ITEMS-0.11-419",_gate419,"DELETE Equipment, DELETE Draft, +/- e quantidade 0 estão ligados à camada sonora central em vez de pushUIFeedback silencioso."] call _assert;

// 420 — scanner do runtime é estruturado e seleção/refresh não cria cue de movimento.
call _resetUI;
private _before420=count ((missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]) getOrDefault ["movementSoundHistory",[]]);
["APP_TARGET","C"] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent;
["EQUIPMENT_VIEW","M"] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent;
["REFRESH"] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent;
private _after420=count ((missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]) getOrDefault ["movementSoundHistory",[]]);
private _scan420=[false] call ServoPeregrino_Organizador_Items_fnc_scanVanillaInventorySounds;
private _sd420=_scan420 getOrDefault ["data",createHashMap];
private _gate420=_before420 isEqualTo 0 && {_after420 isEqualTo 0} && {_scan420 getOrDefault ["success",false]} && {(_sd420 getOrDefault ["cfgSoundCandidates",[]]) isEqualType []} && {(_sd420 getOrDefault ["inventorySoundProperties",[]]) isEqualType []};
["ITEMS-0.11-420",_gate420,"Troca de target/view/refresh continua silenciosa e scanner vanilla retorna diagnóstico estruturado sem depender de mods."] call _assert;

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,_oldDraftState];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_oldUIState];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
private _durationMs=round ((diag_tickTime-_startedAt)*1000);
private _summary=createHashMapFromArray [["delivery","0.11 CP-B.1"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],["base",_base],["baseExpected",414],["checkpointFirstGate",415],["checkpointLastGate",420],["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],["cumulativeExpected",420],["cumulativePassed",414+_passed],["durationMs",_durationMs]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] 0.11 CP-B.1 — BASE=414/414  CP-B.1=%1/6  FAIL=%2  CUMULATIVO=%3/420  TEMPO=%4ms",_passed,_failed,414+_passed,_durationMs];
diag_log "[SP_ORG] [ITEMS] 0.11 CP-B.1 — Manual: validar Delete/-, quantidade 0, APLICAR/REMOVER e executar scanner VANILLA_SOUND_SCAN.";
diag_log "============================================================";
if (hasInterface) then {hint parseText format ["<t size='1.25'>SP_ORG_Items 0.11 CP-B.1</t><br/><br/>Baseline: <t color='#7CFC00'>414 / 414</t><br/>Vanilla sounds + Delete: <t color='%1'>%2 / 6</t><br/>Cumulativo: %3 / 420<br/><br/>%4",if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_passed,414+_passed,if (_failed isEqualTo 0) then {"420/420 concluído. Teste os sons manuais e envie o RPT do scanner."} else {"Consulte o primeiro FAIL no RPT."}];};
_summary
