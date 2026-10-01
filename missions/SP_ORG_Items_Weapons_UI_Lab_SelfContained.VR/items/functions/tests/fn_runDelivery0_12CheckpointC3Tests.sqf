#include "..\..\script_version.hpp"
disableSerialization;
private _legacyRunningState=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR,createHashMap];
if (_legacyRunningState getOrDefault ["running",false]) exitWith {[false,"ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING","A regressão legada já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _orchestrator=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
if (_orchestrator getOrDefault ["running",false]) exitWith {[false,"ITEMS_0_12_C3_ALREADY_RUNNING","Outra suíte cumulativa já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _startedAt=diag_tickTime;
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.12-C.3 — CATALOG REAL ROW BUTTONS + GATE HARDENING — 500 GATES";
diag_log "============================================================";
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun; uiSleep 0.02;
private _base=createHashMapFromArray [["success",false],["code","ITEMS_0_12_C2_CALL_DID_NOT_RETURN"]];
private _baseCall=[] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_12CheckpointC2Tests;
if !(isNil "_baseCall") then {if (_baseCall isEqualType createHashMap) then {_base=_baseCall;};};
private _baseOk=(_base getOrDefault ["success",false]) && {(_base getOrDefault ["checkpointPassed",0]) isEqualTo 6} && {(_base getOrDefault ["cumulativePassed",0]) isEqualTo 494};
if !(_baseOk) exitWith {
    [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
    private _summary=createHashMapFromArray [["delivery","0.12-C.3"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",false],["code","ITEMS_0_12_C3_BASE_494_FAILED"],["base",_base],["checkpointSkipped",true],["checkpointFirstGate",495],["checkpointLastGate",500],["checkpointTotal",0],["checkpointPassed",0],["checkpointFailed",0],["cumulativeExpected",500]];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    diag_log "[SP_ORG] [ITEMS] 0.12-C.3 — FAIL-FAST: baseline 0.12-C.2 494/494 não fechou."; _summary
};
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.12-C.3"]]];
private _passed=0; private _failed=0; private _results=[];
private _assert={params ["_id","_condition","_detail"]; private _ok=(_condition isEqualType true)&&{_condition}; private _status=if (_ok) then {"PASS"} else {"FAIL"}; if (_ok) then {_passed=_passed+1}else{_failed=_failed+1}; _results pushBack [_id,_status,_detail]; diag_log format ["[SP_ORG] [ITEMS] [TEST 0.12-C.3] [%1] %2 — %3",_status,_id,_detail];};
private _productionBefore=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _loadoutBefore=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _srcDialog=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\ui\items_dialog.hpp";
private _srcRender=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_renderCatalogRowsUI.sqf";
private _srcEvent=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUIEvent.sqf";
private _srcDrag=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUIDragEvent.sqf";
private _srcWheel=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUIWheel.sqf";
private _srcWindow=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_getUICatalogWindow.sqf";
private _srcFocused=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshCatalogWindowUI.sqf";
private _srcFull=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshInterface.sqf";

["ITEMS-0.12-495",(_srcDialog find "class CatalogTable: SPORG_Items_CatalogTable")>=0 && {(_srcDialog find "idc=3140")>=0} && {(_srcDialog find "class CatalogList: SPORG_Items_List")>=0} && {(_srcDialog find "safeZoneX-1")>=0},"Catálogo visível usa CT_CONTROLS_TABLE 3140; ListBox 3120 permanece apenas legado/invisível para compatibilidade histórica."] call _assert;
["ITEMS-0.12-496",(_srcDialog find "class SPORG_Items_CatalogRowDraft: SPORG_Items_EquipmentRowCapture")>=0 && {(_srcDialog find "class SPORG_Items_CatalogRowPhysical: SPORG_Items_EquipmentRowButton")>=0} && {(_srcRender find "ctAddRow")>=0} && {(_srcRender find "_toDraft ctrlSetText")>=0} && {(_srcRender find "_toPhysical ctrlSetText")>=0} && {(_srcRender find "CATALOG_ROW_BUTTON")>=0},"Cada linha materializa dois controles Button reais da mesma família visual do Equipment/APM: ← no início e → no fim, com hit-area/hover próprios."] call _assert;
["ITEMS-0.12-497",(_srcEvent find "CATALOG_ROW_BUTTON")>=0 && {(_srcEvent find "CATALOG_BUTTON_TO_DRAFT")>=0} && {(_srcEvent find "CATALOG_BUTTON_TO_PHYSICAL")>=0} && {(_srcEvent find "fnc_executeUITransferCommand")>=0} && {(_srcEvent find "CATALOG_ROW_SELECT")>=0},"Botões reais convergem ao dispatcher central; nome/ícone permanecem seleção focal e não viram transferência implícita."] call _assert;
["ITEMS-0.12-498",(_srcDrag find "CATALOG_ROW_DRAG_START")>=0 && {(_srcDrag find "fnc_createUIDragSnapshot")>=0} && {(_srcDrag find "DND_CATALOG_TABLE_DRAFT")>=0} && {(_srcDrag find "DND_CATALOG_TABLE_PHYSICAL")>=0},"DnD do Catálogo moderno nasce no nome/ícone, congela classname no START e continua aceitando Draft ou destino físico sem depender do ListBox invisível."] call _assert;
["ITEMS-0.12-499",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_WINDOW_SIZE isEqualTo 32 && {(_srcWindow find "_safeWindow")>=0} && {(_srcWindow find "fnc_copyCatalogItem")>=0} && {(_srcFocused find "CATALOG_FOCUSED")>=0} && {(_srcFocused find "fnc_renderCatalogRowsUI")>=0} && {(_srcFull find "fnc_filterCatalog")<0} && {(_srcWheel find "CATALOG_SCROLL")>=0} && {(_srcWheel find "3140")>=0},"Botões reais continuam virtualizados: no máximo 32 linhas por janela, defensive copy só da janela, wheel focal e nenhum retorno a filterCatalog/scan global."] call _assert;

private _existing=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD; if (!isNull _existing) then {closeDialog 0; uiSleep 0.03;};
private _dialog=createDialog "SP_ORG_Items_Dialog"; uiSleep 0.08;
private _runtimeStateC3=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]; _runtimeStateC3 set ["catalogQuery",""]; _runtimeStateC3 set ["catalogCategory","ALL"]; _runtimeStateC3 set ["catalogOffset",0]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_runtimeStateC3];
["TEST_0_12_C3_REAL_BUTTONS"] call ServoPeregrino_Organizador_Items_fnc_refreshCatalogWindowUI; uiSleep 0.03;
private _display=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
private _table=if (isNull _display) then {controlNull} else {_display displayCtrl SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_TABLE_IDC};
private _controls=if (isNull _table) then {[]} else {_table ctRowControls 0};
private _realButtons=false;
if ((count _controls)>=5) then {
    private _left=_controls#1; private _name=_controls#3; private _right=_controls#4;
    private _classLeft=_left getVariable ["SPORG_Items_catalogClass",""];
    private _classRight=_right getVariable ["SPORG_Items_catalogClass",""];
    _realButtons=(ctrlText _left) isEqualTo "←" && {(ctrlText _right) isEqualTo "→"} && {_classLeft isNotEqualTo ""} && {_classLeft isEqualTo _classRight} && {(_name getVariable ["SPORG_Items_catalogClass",""]) isEqualTo _classLeft};
};
private _stateBefore=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _fullBefore=_stateBefore getOrDefault ["fullRefreshCount",0];
if ((count _controls)>=5) then {["CATALOG_ROW_SELECT",_controls#3] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent;}; uiSleep 0.01;
private _stateAfter=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _loadoutAfter=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _productionAfter=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
["ITEMS-0.12-500",_dialog && {!isNull _table} && {_realButtons} && {(_stateAfter getOrDefault ["fullRefreshCount",-1]) isEqualTo _fullBefore} && {(_loadoutAfter getOrDefault ["serialized","B"]) isEqualTo (_loadoutBefore getOrDefault ["serialized","A"])} && {_productionAfter isEqualTo _productionBefore} && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_C_3_CUMULATIVE_GATE_COUNT isEqualTo 500},"Smoke runtime confirma dois botões reais por linha, seleção sem FULL e invariância de loadout/storage; alvo cumulativo 500/500."] call _assert;

private _displayEnd=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD; if (!isNull _displayEnd) then {closeDialog 0; uiSleep 0.03;};
[_productionBefore] call ServoPeregrino_Organizador_Items_fnc_restoreProductionRepositorySnapshot;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
private _durationMs=round ((diag_tickTime-_startedAt)*1000);
private _summary=createHashMapFromArray [["delivery","0.12-C.3"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],["base",_base],["baseExpected",494],["checkpointFirstGate",495],["checkpointLastGate",500],["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],["cumulativeExpected",500],["cumulativePassed",494+_passed],["durationMs",_durationMs],["catalogRealRowButtons",true],["catalogWindowSize",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_WINDOW_SIZE],["equipmentDeleteImmediate",true]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] 0.12-C.3 — BASE=494/494  C.3=%1/6  FAIL=%2  CUMULATIVO=%3/500  TEMPO=%4ms",_passed,_failed,494+_passed,_durationMs];
diag_log "[SP_ORG] [ITEMS] 0.12-C.3 — Manual: botões retangulares reais ←/→ nas bordas das linhas; nome/ícone selecionam/arrastam; X Equipment continua imediato.";
diag_log "============================================================";
if (hasInterface) then {hint parseText format ["<t size='1.25'>SP_ORG_Items 0.12-C.3</t><br/><br/>Baseline C.2: <t color='#7CFC00'>494 / 494</t><br/>C.3: <t color='%1'>%2 / 6</t><br/>Cumulativo: %3 / 500<br/><br/>%4",if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_passed,494+_passed,if (_failed isEqualTo 0) then {"Valide visualmente os botões reais do Catálogo e a fluidez da lista contínua."} else {"Consulte o primeiro FAIL no RPT."}];};
_summary
