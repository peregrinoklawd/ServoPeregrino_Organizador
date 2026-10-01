#include "..\..\script_version.hpp"
disableSerialization;
private _legacyRunningState=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR,createHashMap];
if (_legacyRunningState getOrDefault ["running",false]) exitWith {[false,"ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING","A regressão legada já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _orchestrator=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
if (_orchestrator getOrDefault ["running",false]) exitWith {[false,"ITEMS_0_12_C7_ALREADY_RUNNING","Outra suíte cumulativa já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _startedAt=diag_tickTime;
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.12-C.7 — UNIFIED POINTER DND + COORDINATE-SAFE HIT TEST — 530 GATES";
diag_log "============================================================";
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun; uiSleep 0.02;
private _base=createHashMapFromArray [["success",false],["code","ITEMS_0_12_C7_BASE_CALL_DID_NOT_RETURN"]];
private _baseCall=[] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_12CheckpointC6Tests;
if !(isNil "_baseCall") then {if (_baseCall isEqualType createHashMap) then {_base=_baseCall;};};
private _baseOk=(_base getOrDefault ["success",false]) && {(_base getOrDefault ["checkpointPassed",0]) isEqualTo 10} && {(_base getOrDefault ["cumulativePassed",0]) isEqualTo 524};
if !(_baseOk) exitWith {
    [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
    private _summary=createHashMapFromArray [["delivery","0.12-C.7"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",false],["code","ITEMS_0_12_C7_BASE_524_FAILED"],["base",_base],["checkpointSkipped",true],["checkpointFirstGate",525],["checkpointLastGate",530],["checkpointTotal",0],["checkpointPassed",0],["checkpointFailed",0],["cumulativeExpected",530]];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    diag_log "[SP_ORG] [ITEMS] 0.12-C.7 — FAIL-FAST: baseline corrigida 0.12-C.6 524/524 não fechou."; _summary
};
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.12-C.7"]]];
private _passed=0; private _failed=0; private _results=[];
private _assert={params ["_id","_condition","_detail"]; private _ok=(_condition isEqualType true)&&{_condition}; private _status=if (_ok) then {"PASS"} else {"FAIL"}; if (_ok) then {_passed=_passed+1}else{_failed=_failed+1}; _results pushBack [_id,_status,_detail]; diag_log format ["[SP_ORG] [ITEMS] [TEST 0.12-C.7] [%1] %2 — %3",_status,_id,_detail];};

private _productionBefore=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _loadoutBefore=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _draftStateBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _uiStateBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;

private _srcDialog=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\ui\items_dialog.hpp";
private _srcDrag=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUIDragEvent.sqf";
private _srcPointer=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_resolveUIPointerSource.sqf";
private _srcTarget=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_resolveUIPanelDropTarget.sqf";
private _srcCancel=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_cancelUIDrag.sqf";
private _srcCat=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_renderCatalogRowsUI.sqf";
private _srcEq=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_renderEquipmentRowsUI.sqf";
private _srcDraft=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshDraftMutationUI.sqf";

["ITEMS-0.12-525",(_srcDialog find "onMouseButtonDown")>=0 && {(_srcDialog find "POINTER_DOWN")>=0} && {(_srcDialog find "POINTER_MOVE")>=0} && {(_srcDialog find "MOUSE_UP")>=0} && {(_srcDrag find "DISPLAY_POINTER")>=0} && {(_srcCat find "MouseButtonDown")<0} && {(_srcEq find "MouseButtonDown")<0} && {(_srcDraft find "DRAFT_ROW_DRAG_START")<0},"Display é a autoridade do ponteiro; renderers CT_CONTROLS_TABLE não instalam MouseButtonDown por filho e evitam a regressão em que o teste chamava um handler que o mouse humano não alcançava."] call _assert;

["ITEMS-0.12-526",(_srcPointer find "ctRowControls")>=0 && {(_srcPointer find "ctrlPosition _table")>=0} && {(_srcPointer find "ctrlPosition _child")>=0} && {(_srcPointer find "forEach [_pictureIndex,_nameIndex]")>=0} && {(_srcPointer find "CATALOG")>=0} && {(_srcPointer find "EQUIPMENT")>=0} && {(_srcPointer find "ENTRY")>=0},"Resolvedor de origem percorre linhas reais materializadas e só reconhece Picture/Name; botões, quantidade, +/−/X e setas não são alças de drag."] call _assert;

private _deltaContract=(_srcDrag find "private _dx=_args param [1,0,[0]]")>=0 && {(_srcDrag find "private _dy=_args param [2,0,[0]]")>=0} && {(_srcDrag find "pointerDragTravel")>=0} && {(_srcDrag find "_travel >=")>=0} && {(_srcDrag find "resolveUIPanelDropTarget")>=0} && {(_srcTarget find "getMousePosition")>=0} && {(_srcTarget find "GET_MOUSE_POSITION")>=0};
["ITEMS-0.12-527",_deltaContract,"MouseMoving do display é tratado exclusivamente como DELTA para medir viagem; posição corrente de hover/drop vem de getMousePosition em coordenadas UI."] call _assert;

private _existing=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD; if (!isNull _existing) then {closeDialog 0; uiSleep 0.03;};
private _draftR=[] call ServoPeregrino_Organizador_Items_fnc_getDraftState;
private _draftD=_draftR getOrDefault ["data",createHashMap];
if !(_draftD getOrDefault ["hasDraft",false]) then {["C7 Pointer Fixture","ANY",["TEST","C7_POINTER"],[]] call ServoPeregrino_Organizador_Items_fnc_createNewDraft; ["FirstAidKit",1] call ServoPeregrino_Organizador_Items_fnc_addCatalogItemToDraft;};
private _ui=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]; _ui set ["catalogQuery",""]; _ui set ["catalogCategory","ALL"]; _ui set ["catalogOffset",0]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_ui];
private _dialog=createDialog "SP_ORG_Items_Dialog"; uiSleep 0.12;
private _display=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
private _rowPoint={params ["_table","_row","_child"]; if (isNull _table) exitWith {[-1000,-1000]}; private _cs=_table ctRowControls _row; private _c=_cs param [_child,controlNull,[controlNull]]; if (isNull _c) exitWith {[-1000,-1000]}; private _tp=ctrlPosition _table; private _cp=ctrlPosition _c; [(_tp#0)+(_cp#0)+(_cp#2)*0.5,(_tp#1)+(_cp#1)+(_cp#3)*0.5]};
private _resolveAt={params ["_table","_row","_child"]; private _pt=[_table,_row,_child] call _rowPoint; [_display,_pt#0,_pt#1,false] call ServoPeregrino_Organizador_Items_fnc_resolveUIPointerSource};
private _catTable=if (isNull _display) then {controlNull} else {_display displayCtrl SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_TABLE_IDC};
private _eqTable=if (isNull _display) then {controlNull} else {_display displayCtrl SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_EQUIPMENT_TABLE_IDC};
private _draftTable=if (isNull _display) then {controlNull} else {_display displayCtrl SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAFT_TABLE_IDC};
private _catName=if (!isNull _catTable && {(ctRowCount _catTable)>0}) then {[_catTable,0,3] call _resolveAt} else {createHashMap};
private _catPic=if (!isNull _catTable && {(ctRowCount _catTable)>0}) then {[_catTable,0,2] call _resolveAt} else {createHashMap};
private _catLeft=if (!isNull _catTable && {(ctRowCount _catTable)>0}) then {[_catTable,0,1] call _resolveAt} else {createHashMap};
private _catRight=if (!isNull _catTable && {(ctRowCount _catTable)>0}) then {[_catTable,0,4] call _resolveAt} else {createHashMap};
private _eqName=if (!isNull _eqTable && {(ctRowCount _eqTable)>0}) then {[_eqTable,0,3] call _resolveAt} else {createHashMap};
private _eqMinus=if (!isNull _eqTable && {(ctRowCount _eqTable)>0}) then {[_eqTable,0,4] call _resolveAt} else {createHashMap};
private _draftName=if (!isNull _draftTable && {(ctRowCount _draftTable)>0}) then {[_draftTable,0,2] call _resolveAt} else {createHashMap};
private _draftPlus=if (!isNull _draftTable && {(ctRowCount _draftTable)>0}) then {[_draftTable,0,5] call _resolveAt} else {createHashMap};
private _gate528=(_catName getOrDefault ["sourceType",""]) isEqualTo "CATALOG" && {(_catPic getOrDefault ["sourceType",""]) isEqualTo "CATALOG"} && {!(_catLeft getOrDefault ["found",false])} && {!(_catRight getOrDefault ["found",false])} && {(_eqName getOrDefault ["sourceType",""]) isEqualTo "EQUIPMENT"} && {!(_eqMinus getOrDefault ["found",false])} && {(_draftName getOrDefault ["sourceType",""]) isEqualTo "ENTRY"} && {!(_draftPlus getOrDefault ["found",false])};
["ITEMS-0.12-528",_gate528,"Smoke runtime resolve Picture/Name das linhas reais de Catálogo, Equipment e Draft, enquanto centros de botões visíveis permanecem fora da superfície de drag."] call _assert;

private _stateMatrix=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]; private _readyBefore=_stateMatrix getOrDefault ["physicalCommandEnabled",false]; _stateMatrix set ["physicalCommandEnabled",true]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_stateMatrix];
private _dp=[SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAFT_PANEL_X+SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAFT_PANEL_W*0.68,SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAFT_PANEL_Y+SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAFT_PANEL_H*0.78];
private _ep=[SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_EQUIPMENT_PANEL_X+SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_EQUIPMENT_PANEL_W*0.48,SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_EQUIPMENT_PANEL_Y+SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_EQUIPMENT_PANEL_H*0.78];
private _dc=[_dp#0,_dp#1,"CATALOG",_display,false] call ServoPeregrino_Organizador_Items_fnc_resolveUIPanelDropTarget;
private _de=[_dp#0,_dp#1,"EQUIPMENT",_display,false] call ServoPeregrino_Organizador_Items_fnc_resolveUIPanelDropTarget;
private _dk=[_dp#0,_dp#1,"KIT",_display,false] call ServoPeregrino_Organizador_Items_fnc_resolveUIPanelDropTarget;
private _pc=[_ep#0,_ep#1,"CATALOG",_display,false] call ServoPeregrino_Organizador_Items_fnc_resolveUIPanelDropTarget;
private _pk=[_ep#0,_ep#1,"KIT",_display,false] call ServoPeregrino_Organizador_Items_fnc_resolveUIPanelDropTarget;
private _pe=[_ep#0,_ep#1,"ENTRY",_display,false] call ServoPeregrino_Organizador_Items_fnc_resolveUIPanelDropTarget;
private _px=[_ep#0,_ep#1,"EQUIPMENT",_display,false] call ServoPeregrino_Organizador_Items_fnc_resolveUIPanelDropTarget;
private _gate529=(_dc getOrDefault ["destination",""]) isEqualTo "DRAFT" && {(_de getOrDefault ["destination",""]) isEqualTo "DRAFT"} && {(_dk getOrDefault ["destination",""]) isEqualTo "DRAFT"} && {(_pc getOrDefault ["destination",""]) isEqualTo "PHYSICAL"} && {(_pk getOrDefault ["destination",""]) isEqualTo "PHYSICAL"} && {(_pe getOrDefault ["destination",""]) isEqualTo "PHYSICAL"} && {(_px getOrDefault ["destination",""]) isEqualTo ""} && {(_dc getOrDefault ["coordinateSource",""]) isEqualTo "EXPLICIT_UI"} && {(_pc getOrDefault ["coordinateSource",""]) isEqualTo "EXPLICIT_UI"};
["ITEMS-0.12-529",_gate529,"Matriz de destino usa um único sistema de coordenadas: painéis completos aceitam as origens contratadas e Equipment→Equipment continua bloqueado."] call _assert;
_stateMatrix=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]; _stateMatrix set ["physicalCommandEnabled",_readyBefore]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_stateMatrix];

private _stateCancel=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
_stateCancel set ["pointerDragCandidate",createHashMapFromArray [["found",true],["sourceType","CATALOG"]]]; _stateCancel set ["pointerDragTravel",99]; _stateCancel set ["pointerButtonDown",true]; _stateCancel set ["pointerCandidateTick",diag_tickTime]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_stateCancel];
["C7_TEST_PENDING_CANCEL"] call ServoPeregrino_Organizador_Items_fnc_cancelUIDrag;
private _stateCancelled=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _loadoutAfter=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _productionAfter=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _gate530=(count (_stateCancelled getOrDefault ["pointerDragCandidate",createHashMap])) isEqualTo 0 && {(_stateCancelled getOrDefault ["pointerDragTravel",-1]) isEqualTo 0} && {!(_stateCancelled getOrDefault ["pointerButtonDown",true])} && {(_stateCancelled getOrDefault ["pointerCandidateTick",0]) isEqualTo -1} && {(_loadoutAfter getOrDefault ["serialized","B"]) isEqualTo (_loadoutBefore getOrDefault ["serialized","A"])} && {_productionAfter isEqualTo _productionBefore} && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_C_7_CUMULATIVE_GATE_COUNT isEqualTo 530};
["ITEMS-0.12-530",_gate530,"Cancelar limpa inclusive candidato de ponteiro que ainda não virou drag; C.7 não toca loadout/storage nos gates e publica alvo cumulativo 530/530."] call _assert;

private _displayEnd=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD; if (!isNull _displayEnd) then {closeDialog 0; uiSleep 0.03;};
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,_draftStateBefore];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_uiStateBefore];
[_productionBefore] call ServoPeregrino_Organizador_Items_fnc_restoreProductionRepositorySnapshot;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
private _durationMs=round ((diag_tickTime-_startedAt)*1000);
private _summary=createHashMapFromArray [["delivery","0.12-C.7"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],["base",_base],["baseExpected",524],["checkpointFirstGate",525],["checkpointLastGate",530],["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],["cumulativeExpected",530],["cumulativePassed",524+_passed],["durationMs",_durationMs],["displayPointerAuthority",true],["mouseMovingDeltaSafe",true],["renderedSourceHitTest",true],["panelCoordinateSystem","UI"],["manualHumanGestureStillRequired",true]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] 0.12-C.7 — BASE=524/524  C.7=%1/6  FAIL=%2  CUMULATIVO=%3/530  TEMPO=%4ms",_passed,_failed,524+_passed,_durationMs];
diag_log "[SP_ORG] [ITEMS] 0.12-C.7 — Manual obrigatório: Catálogo→Draft, Equipment→Draft, Draft→Equipment, Kit→Draft/Equipment; clique sem mover não arrasta e botões nunca iniciam drag.";
diag_log "============================================================";
if (hasInterface) then {hint parseText format ["<t size='1.25'>SP_ORG_Items 0.12-C.7</t><br/><br/>Baseline C.6 corrigida: <t color='#7CFC00'>524 / 524</t><br/>C.7: <t color='%1'>%2 / 6</t><br/>Cumulativo: %3 / 530<br/><br/>%4",if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_passed,524+_passed,if (_failed isEqualTo 0) then {"Execute agora o smoke manual do gesto real."} else {"Consulte o primeiro FAIL no RPT."}];};
_summary
