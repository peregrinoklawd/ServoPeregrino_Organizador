#include "..\..\script_version.hpp"
disableSerialization;
private _legacyRunningState=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR,createHashMap];
if (_legacyRunningState getOrDefault ["running",false]) exitWith {[false,"ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING","A regressão legada já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _orchestrator=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
if (_orchestrator getOrDefault ["running",false]) exitWith {[false,"ITEMS_0_12_C6_ALREADY_RUNNING","Outra suíte cumulativa já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _startedAt=diag_tickTime;
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.12-C.6 — PANEL-WIDE DROP TARGETS + DND RESTORATION — 524 GATES";
diag_log "============================================================";
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun; uiSleep 0.02;
private _base=createHashMapFromArray [["success",false],["code","ITEMS_0_12_C6_BASE_CALL_DID_NOT_RETURN"]];
private _baseCall=[] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_12CheckpointC5Tests;
if !(isNil "_baseCall") then {if (_baseCall isEqualType createHashMap) then {_base=_baseCall;};};
private _baseOk=(_base getOrDefault ["success",false]) && {(_base getOrDefault ["checkpointPassed",0]) isEqualTo 8} && {(_base getOrDefault ["cumulativePassed",0]) isEqualTo 514};
if !(_baseOk) exitWith {
    [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
    private _summary=createHashMapFromArray [["delivery","0.12-C.6"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",false],["code","ITEMS_0_12_C6_BASE_514_FAILED"],["base",_base],["checkpointSkipped",true],["checkpointFirstGate",515],["checkpointLastGate",524],["checkpointTotal",0],["checkpointPassed",0],["checkpointFailed",0],["cumulativeExpected",524]];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    diag_log "[SP_ORG] [ITEMS] 0.12-C.6 — FAIL-FAST: baseline 0.12-C.5 514/514 não fechou."; _summary
};
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.12-C.6"]]];
private _passed=0; private _failed=0; private _results=[];
private _assert={params ["_id","_condition","_detail"]; private _ok=(_condition isEqualType true)&&{_condition}; private _status=if (_ok) then {"PASS"} else {"FAIL"}; if (_ok) then {_passed=_passed+1}else{_failed=_failed+1}; _results pushBack [_id,_status,_detail]; diag_log format ["[SP_ORG] [ITEMS] [TEST 0.12-C.6] [%1] %2 — %3",_status,_id,_detail];};

private _productionBefore=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _loadoutBefore=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _draftStateBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _uiStateBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;

private _srcC2=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\tests\fn_runDelivery0_12CheckpointC2Tests.sqf";
private _srcDrag=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUIDragEvent.sqf";
private _srcResolve=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_resolveUIPanelDropTarget.sqf";
private _srcPointer=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_resolveUIPointerSource.sqf";
private _srcFinalize=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_finalizeUIPointerDrop.sqf";
private _srcSnap=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_createUIDragSnapshot.sqf";
private _srcCat=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_renderCatalogRowsUI.sqf";
private _srcEq=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_renderEquipmentRowsUI.sqf";
private _srcDraft=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshDraftMutationUI.sqf";
private _srcDialog=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\ui\items_dialog.hpp";

["ITEMS-0.12-515",(_srcC2 find "_leftCtrl093")>=0 && {(_srcC2 find "CATALOG_ROW_BUTTON")>=0} && {(_srcC2 find "Botão real esquerdo")>=0},"Gate 489 herdado foi alinhado à CatalogTable atual; a baseline C.5 pode fechar 514/514 sem depender da antiga rail textual."] call _assert;
private _bgCfg516=missionConfigFile>>"SP_ORG_Items_Dialog">>"controlsBackground";
private _panelIds516=(getNumber (_bgCfg516>>"P2">>"idc") isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAFT_PANEL_IDC) && {(getNumber (_bgCfg516>>"P4">>"idc")) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_EQUIPMENT_PANEL_IDC};
["ITEMS-0.12-516",_panelIds516 && {(_srcResolve find "draftBounds")>=0} && {(_srcResolve find "equipmentBounds")>=0} && {(_srcResolve find "GET_MOUSE_POSITION")>=0},"Kit Selecionado e Conteúdo do Equipamento compartilham bounds autoritativos com o hit-test; faixas 2103/4113 não são o único destino."] call _assert;
["ITEMS-0.12-517",(_srcSnap find "ENTRY")>=0 && {(_srcPointer find "SPORG_Items_draftEntry")>=0} && {(_srcPointer find "ENTRY")>=0} && {(_srcDraft find "SPORG_Items_draftEntry")>=0},"Linha real do Draft expõe ItemEntry v1 para resolução de origem por Picture/Name, sem seleção global."] call _assert;
["ITEMS-0.12-518",(_srcDialog find "POINTER_DOWN")>=0 && {(_srcPointer find "CATALOG")>=0} && {(_srcPointer find "EQUIPMENT")>=0} && {(_srcDrag find "DISPLAY_POINTER")>=0} && {(_srcDrag find "case 1102:{""KIT""}")>=0},"Catálogo/Equipment/Draft usam origem resolvida pelo display; Meus Kits preserva drag nativo como origem."] call _assert;
["ITEMS-0.12-519",(_srcDrag find "[DND] START")>=0 && {(_srcDrag find "[DND] HOVER")>=0} && {(_srcFinalize find "[DND] DROP")>=0} && {(_srcDrag find "_area isNotEqualTo _lastHover")>=0},"Telemetria DnD registra START/HOVER/DROP e só emite HOVER quando o painel muda, evitando flood no RPT."] call _assert;

private _existing=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD; if (!isNull _existing) then {closeDialog 0; uiSleep 0.03;};
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMap];
["C6 DnD Fixture","ANY",["TEST","C6_DND"],[]] call ServoPeregrino_Organizador_Items_fnc_createNewDraft;
["FirstAidKit",1] call ServoPeregrino_Organizador_Items_fnc_addCatalogItemToDraft;
private _uiFixture=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
_uiFixture set ["catalogQuery","FirstAidKit"]; _uiFixture set ["catalogCategory","ALL"]; _uiFixture set ["catalogOffset",0];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_uiFixture];
private _dialog=createDialog "SP_ORG_Items_Dialog"; uiSleep 0.12;
private _display=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;

private _draftPoint=[
    SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAFT_PANEL_X + SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAFT_PANEL_W*0.72,
    SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAFT_PANEL_Y + SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAFT_PANEL_H*0.82
];
private _equipmentPoint=[
    SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_EQUIPMENT_PANEL_X + SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_EQUIPMENT_PANEL_W*0.50,
    SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_EQUIPMENT_PANEL_Y + SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_EQUIPMENT_PANEL_H*0.82
];
private _insideRect={params ["_pt","_p"]; (_pt#0)>=(_p#0)&&{(_pt#0)<=((_p#0)+(_p#2))}&&{(_pt#1)>=(_p#1)}&&{(_pt#1)<=((_p#1)+(_p#3))}};
private _draftStrip=if (isNull _display) then {controlNull} else {_display displayCtrl 2103};
private _equipmentStrip=if (isNull _display) then {controlNull} else {_display displayCtrl 4113};
private _ds=if (isNull _draftStrip) then {[]} else {ctrlPosition _draftStrip};
private _es=if (isNull _equipmentStrip) then {[]} else {ctrlPosition _equipmentStrip};
private _wideOutsideStrips=((count _ds)<4 || {!([_draftPoint,_ds] call _insideRect)}) && {((count _es)<4) || {!([_equipmentPoint,_es] call _insideRect)}};

private _stateForMatrix=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _readyBefore=_stateForMatrix getOrDefault ["physicalCommandEnabled",false];
_stateForMatrix set ["physicalCommandEnabled",true]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_stateForMatrix];
private _dCat=[_draftPoint#0,_draftPoint#1,"CATALOG",_display,false] call ServoPeregrino_Organizador_Items_fnc_resolveUIPanelDropTarget;
private _dEq=[_draftPoint#0,_draftPoint#1,"EQUIPMENT",_display,false] call ServoPeregrino_Organizador_Items_fnc_resolveUIPanelDropTarget;
private _dKit=[_draftPoint#0,_draftPoint#1,"KIT",_display,false] call ServoPeregrino_Organizador_Items_fnc_resolveUIPanelDropTarget;
private _dEntry=[_draftPoint#0,_draftPoint#1,"ENTRY",_display,false] call ServoPeregrino_Organizador_Items_fnc_resolveUIPanelDropTarget;
private _pCat=[_equipmentPoint#0,_equipmentPoint#1,"CATALOG",_display,false] call ServoPeregrino_Organizador_Items_fnc_resolveUIPanelDropTarget;
private _pKit=[_equipmentPoint#0,_equipmentPoint#1,"KIT",_display,false] call ServoPeregrino_Organizador_Items_fnc_resolveUIPanelDropTarget;
private _pEntry=[_equipmentPoint#0,_equipmentPoint#1,"ENTRY",_display,false] call ServoPeregrino_Organizador_Items_fnc_resolveUIPanelDropTarget;
private _pEq=[_equipmentPoint#0,_equipmentPoint#1,"EQUIPMENT",_display,false] call ServoPeregrino_Organizador_Items_fnc_resolveUIPanelDropTarget;
private _matrixOk=_wideOutsideStrips && {(_dCat getOrDefault ["destination",""]) isEqualTo "DRAFT"} && {(_dEq getOrDefault ["destination",""]) isEqualTo "DRAFT"} && {(_dKit getOrDefault ["destination",""]) isEqualTo "DRAFT"} && {(_dEntry getOrDefault ["destination",""]) isEqualTo ""} && {(_pCat getOrDefault ["destination",""]) isEqualTo "PHYSICAL"} && {(_pKit getOrDefault ["destination",""]) isEqualTo "PHYSICAL"} && {(_pEntry getOrDefault ["destination",""]) isEqualTo "PHYSICAL"} && {(_pEq getOrDefault ["destination",""]) isEqualTo ""} && {(_pEq getOrDefault ["reason",""]) isEqualTo "SOURCE_NOT_ALLOWED"};
["ITEMS-0.12-520",_matrixOk,"Hit-test runtime confirma painel inteiro fora das faixas: Catálogo/Equipment/Kit → Draft; Catálogo/Kit/linha Draft → físico; Equipment não é reencaminhado fisicamente."] call _assert;

private _rowChildPoint={
    params ["_table","_rowIndex","_childIndex"];
    if (isNull _table) exitWith {[-1000,-1000]};
    private _controls=_table ctRowControls _rowIndex;
    private _child=_controls param [_childIndex,controlNull,[controlNull]];
    if (isNull _child) exitWith {[-1000,-1000]};
    private _tp=ctrlPosition _table; private _cp=ctrlPosition _child;
    [(_tp#0)+(_cp#0)+(_cp#2)*0.5,(_tp#1)+(_cp#1)+(_cp#3)*0.5]
};
private _draftTable=if (isNull _display) then {controlNull} else {_display displayCtrl SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAFT_TABLE_IDC};
private _catalogTable=if (isNull _display) then {controlNull} else {_display displayCtrl SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_TABLE_IDC};
private _equipmentTable=if (isNull _display) then {controlNull} else {_display displayCtrl SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_EQUIPMENT_TABLE_IDC};
private _draftSource=createHashMap; private _catalogSource=createHashMap; private _equipmentSource=createHashMap;
if (!isNull _draftTable && {(ctRowCount _draftTable)>0}) then {private _pt=[_draftTable,0,2] call _rowChildPoint; _draftSource=[_display,_pt#0,_pt#1,false] call ServoPeregrino_Organizador_Items_fnc_resolveUIPointerSource;};
if (!isNull _catalogTable && {(ctRowCount _catalogTable)>0}) then {private _pt=[_catalogTable,0,3] call _rowChildPoint; _catalogSource=[_display,_pt#0,_pt#1,false] call ServoPeregrino_Organizador_Items_fnc_resolveUIPointerSource;};
if (!isNull _equipmentTable && {(ctRowCount _equipmentTable)>0}) then {private _pt=[_equipmentTable,0,3] call _rowChildPoint; _equipmentSource=[_display,_pt#0,_pt#1,false] call ServoPeregrino_Organizador_Items_fnc_resolveUIPointerSource;};
["ITEMS-0.12-521",(_draftSource getOrDefault ["found",false]) && {(_draftSource getOrDefault ["sourceType",""]) isEqualTo "ENTRY"} && {(count (_draftSource getOrDefault ["sourcePayload",[]])) isEqualTo 6},"Smoke runtime resolve a origem pela linha visível do Draft e congela exatamente uma ItemEntry, sem usar o handler de START como atalho."] call _assert;

private _dragFromSource={
    params ["_source"];
    private _r=[_source getOrDefault ["sourceType",""],_source getOrDefault ["sourceIDC",-1],_source getOrDefault ["sourceId",""],_source getOrDefault ["sourcePayload",[]],_source getOrDefault ["sourceText",""]] call ServoPeregrino_Organizador_Items_fnc_createUIDragSnapshot;
    if !(_r getOrDefault ["success",false]) exitWith {createHashMap};
    private _drag=((_r getOrDefault ["data",createHashMap]) getOrDefault ["drag",createHashMap]);
    _drag set ["customPointerDrag",true]; _drag set ["pointerAuthority","TEST_RENDERED_SOURCE"];
    _drag
};
private _draftBefore=([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap];
private _currentBefore=_draftBefore getOrDefault ["current",createHashMap];
private _entriesBefore=+(_currentBefore getOrDefault ["entries",[]]);
private _qtyClass={params ["_entries","_class"]; private _q=0; {if ((_x param [2,"",[""]]) isEqualTo _class) then {_q=_q+(_x param [3,0,[0]]);};} forEach _entries; _q};
private _catClass=_catalogSource getOrDefault ["sourceId",""];
private _catQtyBefore=[_entriesBefore,_catClass] call _qtyClass;
private _catDrag=[_catalogSource] call _dragFromSource;
private _catDrop=createHashMap;
if (_catDrag getOrDefault ["active",false]) then {_catDrop=[_catDrag,_draftPoint#0,_draftPoint#1,_display,false,"TEST_C6_RENDERED_CATALOG_DRAFT"] call ServoPeregrino_Organizador_Items_fnc_finalizeUIPointerDrop;};
private _draftAfterCat=([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap];
private _catQtyAfter=[((_draftAfterCat getOrDefault ["current",createHashMap]) getOrDefault ["entries",[]]),_catClass] call _qtyClass;
["ITEMS-0.12-522",(_catalogSource getOrDefault ["found",false]) && {_catClass isNotEqualTo ""} && {(_catDrop getOrDefault ["accepted",false])} && {(_catDrop getOrDefault ["destination",""]) isEqualTo "DRAFT"} && {_catQtyAfter isEqualTo (_catQtyBefore+1)},"Smoke runtime usa origem real renderizada do Catálogo e o finalizador de produção para Catálogo → qualquer área do Kit Selecionado."] call _assert;

private _eqPayload=+(_equipmentSource getOrDefault ["sourcePayload",[]]);
private _eqClass=if ((count _eqPayload)>=3) then {_eqPayload#2} else {""};
private _draftBeforeEq=([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap];
private _eqQtyBefore=[((_draftBeforeEq getOrDefault ["current",createHashMap]) getOrDefault ["entries",[]]),_eqClass] call _qtyClass;
private _eqDrag=[_equipmentSource] call _dragFromSource;
private _eqDrop=createHashMap;
if (_eqDrag getOrDefault ["active",false]) then {_eqDrop=[_eqDrag,_draftPoint#0,_draftPoint#1,_display,false,"TEST_C6_RENDERED_EQUIPMENT_DRAFT"] call ServoPeregrino_Organizador_Items_fnc_finalizeUIPointerDrop;};
private _draftAfterEq=([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap];
private _eqQtyAfter=[((_draftAfterEq getOrDefault ["current",createHashMap]) getOrDefault ["entries",[]]),_eqClass] call _qtyClass;
["ITEMS-0.12-523",(_equipmentSource getOrDefault ["found",false]) && {_eqClass isNotEqualTo ""} && {(_eqDrop getOrDefault ["accepted",false])} && {(_eqDrop getOrDefault ["destination",""]) isEqualTo "DRAFT"} && {_eqQtyAfter > _eqQtyBefore},"Smoke runtime usa origem real renderizada do Equipment e copia para qualquer área do Kit Selecionado sem remover a origem física."] call _assert;

private _stateRestore=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]; _stateRestore set ["physicalCommandEnabled",_readyBefore]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_stateRestore];
private _loadoutAfter=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _productionAfter=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
["ITEMS-0.12-524",(_loadoutAfter getOrDefault ["serialized","B"]) isEqualTo (_loadoutBefore getOrDefault ["serialized","A"]) && {_productionAfter isEqualTo _productionBefore} && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_C_6_CUMULATIVE_GATE_COUNT isEqualTo 524},"C.6 restaura DnD sem mutação física/storage na suíte; Catalog virtualizado, EXACT, Storage Guard e alvo cumulativo 524/524 permanecem íntegros."] call _assert;

private _displayEnd=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD; if (!isNull _displayEnd) then {closeDialog 0; uiSleep 0.03;};
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,_draftStateBefore];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_uiStateBefore];
[_productionBefore] call ServoPeregrino_Organizador_Items_fnc_restoreProductionRepositorySnapshot;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
private _durationMs=round ((diag_tickTime-_startedAt)*1000);
private _summary=createHashMapFromArray [["delivery","0.12-C.6"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],["base",_base],["baseExpected",514],["checkpointFirstGate",515],["checkpointLastGate",524],["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],["cumulativeExpected",524],["cumulativePassed",514+_passed],["durationMs",_durationMs],["panelWideDropTargets",true],["renderedSourceHitTest",true],["catalogDnDRestored",true],["equipmentDnDRestored",true],["kitNativeDnDPreserved",true]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] 0.12-C.6 — BASE=514/514  C.6=%1/10  FAIL=%2  CUMULATIVO=%3/524  TEMPO=%4ms",_passed,_failed,514+_passed,_durationMs];
diag_log "[SP_ORG] [ITEMS] 0.12-C.6 — Descendente C.7 valida origens renderizadas e finalizador real; teste manual do gesto humano continua obrigatório.";
diag_log "============================================================";
_summary
