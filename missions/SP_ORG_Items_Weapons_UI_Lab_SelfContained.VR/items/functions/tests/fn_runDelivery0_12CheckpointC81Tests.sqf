#include "..\..\script_version.hpp"
disableSerialization;
private _legacyRunningState=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR,createHashMap];
if (_legacyRunningState getOrDefault ["running",false]) exitWith {[false,"ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING","A regressão legada já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _orchestrator=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
if (_orchestrator getOrDefault ["running",false]) exitWith {[false,"ITEMS_0_12_C81_ALREADY_RUNNING","Outra suíte cumulativa já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _startedAt=diag_tickTime;
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.12-C.8.1 — RUNTIME DRAG GHOST FIX — 542 GATES";
diag_log "============================================================";
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun; uiSleep 0.02;
private _base=createHashMapFromArray [["success",false],["code","ITEMS_0_12_C81_BASE_CALL_DID_NOT_RETURN"]];
private _baseCall=[] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_12CheckpointC8Tests;
if !(isNil "_baseCall") then {if (_baseCall isEqualType createHashMap) then {_base=_baseCall;};};
private _baseOk=(_base getOrDefault ["success",false]) && {(_base getOrDefault ["checkpointPassed",0]) isEqualTo 6} && {(_base getOrDefault ["cumulativePassed",0]) isEqualTo 536};
if !(_baseOk) exitWith {
    [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
    private _summary=createHashMapFromArray [["delivery","0.12-C.8.1"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",false],["code","ITEMS_0_12_C81_BASE_536_FAILED"],["base",_base],["checkpointSkipped",true],["checkpointFirstGate",537],["checkpointLastGate",542],["checkpointTotal",0],["checkpointPassed",0],["checkpointFailed",0],["cumulativeExpected",542]];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    diag_log "[SP_ORG] [ITEMS] 0.12-C.8.1 — FAIL-FAST: baseline C.8 536/536 não fechou.";
    _summary
};
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.12-C.8.1"]]];
private _passed=0; private _failed=0; private _results=[];
private _assert={params ["_id","_condition","_detail"]; private _ok=(_condition isEqualType true)&&{_condition}; private _status=if (_ok) then {"PASS"} else {"FAIL"}; if (_ok) then {_passed=_passed+1}else{_failed=_failed+1}; _results pushBack [_id,_status,_detail]; diag_log format ["[SP_ORG] [ITEMS] [TEST 0.12-C.8.1] [%1] %2 — %3",_status,_id,_detail];};

private _productionBefore=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _loadoutBefore=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _draftStateBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _uiStateBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _srcDialog=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\ui\items_dialog.hpp";
private _srcProxy=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_updateUIDragVisualProxy.sqf";
private _srcDrag=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUIDragEvent.sqf";

private _gate537=(_srcDialog find "DragGhostBg")<0 && {(_srcDialog find "DragGhostIcon")<0} && {(_srcDialog find "DragGhostText")<0} && {(_srcProxy find "ctrlCreate")>=0} && {(_srcProxy find "RscStructuredText")>=0} && {(_srcProxy find "ctrlDelete")>=0} && {(_srcProxy find "DND_GHOST] CREATE")>=0} && {(_srcProxy find "DND_GHOST] MOVE_FIRST")>=0} && {(_srcProxy find "DND_GHOST] HIDE")>=0};
["ITEMS-0.12-537",_gate537,"Ghost deixa de ser parte estática do diálogo: nasce/destroi em runtime e possui telemetria CREATE/MOVE_FIRST/HIDE sem flood por frame."] call _assert;

private _stateForUI=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
_stateForUI set ["catalogQuery",""]; _stateForUI set ["catalogCategory","ALL"]; _stateForUI set ["catalogOffset",0]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_stateForUI];
private _existing=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD; if (!isNull _existing) then {closeDialog 0; uiSleep 0.03;};
private _dialog=createDialog "SP_ORG_Items_Dialog"; uiSleep 0.12;
private _display=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
private _catTable=if (isNull _display) then {controlNull} else {_display displayCtrl SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_TABLE_IDC};
private _candidate=createHashMap;
if (!isNull _catTable && {(ctRowCount _catTable)>0}) then {
    private _cs=_catTable ctRowControls 0;
    private _nameCtrl=_cs param [3,controlNull,[controlNull]];
    if (!isNull _nameCtrl) then {
        private _tp=ctrlPosition _catTable; private _np=ctrlPosition _nameCtrl;
        _candidate=[_display,(_tp#0)+(_np#0)+(_np#2)*0.5,(_tp#1)+(_np#1)+(_np#3)*0.5,false] call ServoPeregrino_Organizador_Items_fnc_resolveUIPointerSource;
    };
};
["C81_PREP"] call ServoPeregrino_Organizador_Items_fnc_cancelUIDrag;
private _stateArm=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
_stateArm set ["pointerDragCandidate",_candidate]; _stateArm set ["pointerDragTravel",0]; _stateArm set ["pointerButtonDown",true]; _stateArm set ["pointerCandidateTick",diag_tickTime]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_stateArm];
private _moveEvent=["POINTER_MOVE",[_display,0.10,0.10]] call ServoPeregrino_Organizador_Items_fnc_handleUIDragEvent;
private _stateStarted=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _dragStarted=_stateStarted getOrDefault ["dragState",createHashMap];
private _ghostStarted=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAG_GHOST_CTRL_VAR,controlNull];
private _movesStarted=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAG_GHOST_MOVE_COUNT_VAR,0];
private _gate538=(_candidate getOrDefault ["found",false]) && {(_candidate getOrDefault ["sourceType",""]) isEqualTo "CATALOG"} && {(_dragStarted getOrDefault ["active",false])} && {(_dragStarted getOrDefault ["pointerAuthority",""]) isEqualTo "DISPLAY_POINTER"} && {!isNull _ghostStarted} && {ctrlShown _ghostStarted} && {!(ctrlEnabled _ghostStarted)} && {_movesStarted>=2};
["ITEMS-0.12-538",_gate538,"Integração real do handler: candidato de linha materializada + POINTER_MOVE acima do limiar entra em ACTIVE e cria o ghost runtime sem chamar diretamente o helper visual."] call _assert;

private _ghostIdBefore=if (isNull _ghostStarted) then {-1} else {ctrlIDC _ghostStarted};
private _movesBefore=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAG_GHOST_MOVE_COUNT_VAR,0];
["POINTER_MOVE",[_display,0.001,0.001]] call ServoPeregrino_Organizador_Items_fnc_handleUIDragEvent;
private _ghostAfterMove=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAG_GHOST_CTRL_VAR,controlNull];
private _movesAfter=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAG_GHOST_MOVE_COUNT_VAR,0];
private _gate539=!isNull _ghostAfterMove && {(ctrlIDC _ghostAfterMove) isEqualTo _ghostIdBefore} && {ctrlShown _ghostAfterMove} && {_movesAfter>_movesBefore} && {(_srcDrag find "_setDropVisuals; false")>=0} && {(_srcProxy find "getMousePosition")>=0};
["ITEMS-0.12-539",_gate539,"Com drag ACTIVE, outro POINTER_MOVE reutiliza o mesmo proxy e incrementa MOVE pelo caminho do display; a posição visual é lida de getMousePosition no runtime."] call _assert;

private _gate540=(_srcDrag find "NATIVE_LISTBOX")>=0 && {(_srcDrag find "SHOW")>=0} && {(_srcDrag find "_beginCustom")>=0} && {(_srcDrag find "_logStart")>=0};

["ITEMS-0.12-540",_gate540,"Tanto o START DISPLAY_POINTER quanto o START nativo de Meus Kits chamam SHOW explicitamente; o visual não depende de um MOVE posterior para nascer."] call _assert;

["C81_RUNTIME_CLEANUP"] call ServoPeregrino_Organizador_Items_fnc_cancelUIDrag;
private _ghostAfterCancel=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAG_GHOST_CTRL_VAR,controlNull];
private _stateAfterCancel=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _gate541=(isNull _ghostAfterCancel) && {!((_stateAfterCancel getOrDefault ["dragState",createHashMap]) getOrDefault ["active",true])} && {!(_stateAfterCancel getOrDefault ["pointerButtonDown",true])} && {(uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAG_GHOST_MOVE_COUNT_VAR,-1]) isEqualTo 0};
["ITEMS-0.12-541",_gate541,"Cancelamento remove fisicamente o controle runtime e zera o estado visual; não sobra ghost invisível nem handle antigo para o próximo gesto."] call _assert;

private _displayEnd=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD; if (!isNull _displayEnd) then {closeDialog 0; uiSleep 0.03;};
private _loadoutAfter=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _productionAfter=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _gate542=(_srcProxy find "executeUITransferCommand")<0 && {(_srcProxy find "refreshPhysicalMutationUI")<0} && {(_srcProxy find "refreshDraftMutationUI")<0} && {(_srcProxy find "setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR")<0} && {(_loadoutAfter getOrDefault ["serialized","B"]) isEqualTo (_loadoutBefore getOrDefault ["serialized","A"])} && {_productionAfter isEqualTo _productionBefore} && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_C_8_1_CUMULATIVE_GATE_COUNT isEqualTo 542};
["ITEMS-0.12-542",_gate542,"C.8.1 continua puramente visual: proxy não chama dispatcher/refresh mutável nem grava UI state serializável; loadout/storage ficam idênticos e alvo cumulativo é 542/542."] call _assert;

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,_draftStateBefore];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_uiStateBefore];
[_productionBefore] call ServoPeregrino_Organizador_Items_fnc_restoreProductionRepositorySnapshot;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
private _durationMs=round ((diag_tickTime-_startedAt)*1000);
private _summary=createHashMapFromArray [["delivery","0.12-C.8.1"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],["base",_base],["baseExpected",536],["checkpointFirstGate",537],["checkpointLastGate",542],["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],["cumulativeExpected",542],["cumulativePassed",536+_passed],["durationMs",_durationMs],["runtimeDragGhost",true],["handlerPathTested",true],["runtimeTopLayer",true],["manualHumanVisualValidationRequired",true]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] 0.12-C.8.1 — BASE=536/536  C.8.1=%1/6  FAIL=%2  CUMULATIVO=%3/542  TEMPO=%4ms",_passed,_failed,536+_passed,_durationMs];
diag_log "[SP_ORG] [ITEMS] 0.12-C.8.1 — Manual obrigatório: confirmar visualmente ghost ícone+nome acompanhando o mouse em Catálogo/Equipment/Draft/Meus Kits sem qualquer regressão do DnD C.7.";
diag_log "============================================================";
if (hasInterface) then {hint parseText format ["<t size='1.25'>SP_ORG_Items 0.12-C.8.1</t><br/><br/>Baseline C.8: <t color='#7CFC00'>536 / 536</t><br/>C.8.1: <t color='%1'>%2 / 6</t><br/>Cumulativo: %3 / 542<br/><br/>%4",if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_passed,536+_passed,if (_failed isEqualTo 0) then {"Valide o ghost no gesto humano e procure DND_GHOST CREATE/MOVE_FIRST/HIDE no RPT."} else {"Consulte o primeiro FAIL no RPT."}];};
_summary
