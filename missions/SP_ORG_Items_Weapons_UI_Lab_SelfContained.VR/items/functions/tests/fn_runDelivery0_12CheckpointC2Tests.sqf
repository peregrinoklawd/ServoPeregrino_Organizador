#include "..\..\script_version.hpp"
disableSerialization;
private _legacyRunningState=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR,createHashMap];
if (_legacyRunningState getOrDefault ["running",false]) exitWith {[false,"ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING","A regressão legada já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _orchestrator=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
if (_orchestrator getOrDefault ["running",false]) exitWith {[false,"ITEMS_0_12_C2_ALREADY_RUNNING","Outra suíte cumulativa já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _startedAt=diag_tickTime;
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.12-C.2 — RUNNER COMPLETION + CATALOG ARROW PARITY — 494 GATES";
diag_log "============================================================";
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun; uiSleep 0.02;
private _base=createHashMapFromArray [["success",false],["code","ITEMS_0_12_C1_CALL_DID_NOT_RETURN"]];
private _baseCall=[] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_12CheckpointCTests;
if !(isNil "_baseCall") then {if (_baseCall isEqualType createHashMap) then {_base=_baseCall;};};
private _baseOk=(_base getOrDefault ["success",false]) && {(_base getOrDefault ["checkpointPassed",0]) isEqualTo 10} && {(_base getOrDefault ["cumulativePassed",0]) isEqualTo 488};
if !(_baseOk) exitWith {
    [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
    private _summary=createHashMapFromArray [["delivery","0.12-C.2"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",false],["code","ITEMS_0_12_C2_BASE_488_FAILED"],["base",_base],["checkpointSkipped",true],["checkpointFirstGate",489],["checkpointLastGate",494],["checkpointTotal",0],["checkpointPassed",0],["checkpointFailed",0],["cumulativeExpected",494]];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    diag_log "[SP_ORG] [ITEMS] 0.12-C.2 — FAIL-FAST: baseline 0.12-C.1 488/488 não fechou."; _summary
};
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.12-C.2"]]];
private _passed=0; private _failed=0; private _results=[];
private _assert={params ["_id","_condition","_detail"]; private _ok=(_condition isEqualType true)&&{_condition}; private _status=if (_ok) then {"PASS"} else {"FAIL"}; if (_ok) then {_passed=_passed+1}else{_failed=_failed+1}; _results pushBack [_id,_status,_detail]; diag_log format ["[SP_ORG] [ITEMS] [TEST 0.12-C.2] [%1] %2 — %3",_status,_id,_detail];};
private _productionBefore=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _loadoutBefore=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _srcCatalog=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshCatalogWindowUI.sqf";
private _srcFull=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshInterface.sqf";
private _srcEvent=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUIEvent.sqf";
private _srcWindow=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_getUICatalogWindow.sqf";
private _srcEqRequest=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_requestEquipmentRowAction.sqf";
private _srcLegacy=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\tests\fn_runDelivery0_9_3Tests.sqf";
private _srcRenderer=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_renderCatalogRowsUI.sqf";

["ITEMS-0.12-489",(_srcLegacy find "CatalogScrollUp")>=0 && {(_srcLegacy find "CatalogScrollDown")>=0} && {(_srcLegacy find "_selDisplayName092")>=0} && {(_srcLegacy find "_leftCtrl093")>=0} && {(_srcLegacy find "CATALOG_ROW_BUTTON")>=0} && {(_srcLegacy find "Botão real esquerdo")>=0} && {(_srcLegacy find "_leftArrowX093")<0},"Os gates históricos 244/296/351/358 reconhecem a navegação contínua, detalhes player-facing e o botão real esquerdo Draft sem renumerar IDs."] call _assert;
["ITEMS-0.12-490",(_srcCatalog find "fnc_renderCatalogRowsUI")>=0 && {(_srcFull find "fnc_renderCatalogRowsUI")>=0} && {(_srcRenderer find "_toDraft ctrlSetText")>=0} && {(_srcRenderer find "_toPhysical ctrlSetText")>=0},"Render focal e FULL convergem ao renderer atual, mantendo ação Draft no começo da linha e ação física no fim; em descendentes são botões reais independentes."] call _assert;
["ITEMS-0.12-491",(_srcEvent find "private _leftStart=_pictureW")>=0 && {(_srcEvent find "private _rightStart=(_p#2)-_sideHitW")>=0} && {(_srcEvent find "private _destination=if (_hitLeft) then {""DRAFT""} else {""PHYSICAL""}")>=0},"Hit-test lateral separa ← Draft e → físico; o picture e o corpo intermediário permanecem seleção pura."] call _assert;
["ITEMS-0.12-492",(_srcWindow find "_safeWindow")>=0 && {(_srcWindow find "_windowIndices")>=0} && {(_srcWindow find "fnc_copyCatalogItem")>=0} && {(_srcCatalog find "CATALOG_FOCUSED")>=0} && {(_srcCatalog find "filterCatalog")<0} && {(_srcFull find "fnc_filterCatalog")<0},"Paridade das ações mantém janela virtual limitada/defensive-copy por janela e não reintroduz filterCatalog/scan global; gate não depende do nome de macro após preprocess."] call _assert;

private _existing=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD; if (!isNull _existing) then {closeDialog 0; uiSleep 0.03;};
private _dialog=createDialog "SP_ORG_Items_Dialog"; uiSleep 0.08;
["TEST_0_12_C2_VISUAL"] call ServoPeregrino_Organizador_Items_fnc_refreshCatalogWindowUI; uiSleep 0.02;
private _display=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
private _cat=if (isNull _display) then {controlNull} else {_display displayCtrl 3120};
private _visualOk=!isNull _cat && {(lbSize _cat)>0} && {((_cat lbText 0) find "←") isEqualTo 0} && {(_cat lbTextRight 0) isEqualTo "→"};
["ITEMS-0.12-493",_dialog && {_visualOk},"Smoke runtime confirma as affordances laterais materializadas na linha real do Catálogo."] call _assert;

private _stateBeforeScroll=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _fullBefore=_stateBeforeScroll getOrDefault ["fullRefreshCount",0];
["CATALOG_SCROLL",6] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent; uiSleep 0.02;
private _stateAfterScroll=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _loadoutAfter=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _productionAfter=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
["ITEMS-0.12-494",(_stateAfterScroll getOrDefault ["lastRefreshMode",""]) isEqualTo "CATALOG_FOCUSED" && {(_stateAfterScroll getOrDefault ["fullRefreshCount",-1]) isEqualTo _fullBefore} && {(_srcEqRequest find "EQUIPMENT_DELETE_DIRECT")>=0} && {(_loadoutAfter getOrDefault ["serialized","B"]) isEqualTo (_loadoutBefore getOrDefault ["serialized","A"])} && {_productionAfter isEqualTo _productionBefore} && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_C_2_CUMULATIVE_GATE_COUNT isEqualTo 494},"C.2 preserva CATALOG_FOCUSED, X/Delete imediato, loadout/storage e publica o alvo cumulativo 494/494."] call _assert;
private _displayEnd=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD; if (!isNull _displayEnd) then {closeDialog 0; uiSleep 0.03;};
[_productionBefore] call ServoPeregrino_Organizador_Items_fnc_restoreProductionRepositorySnapshot; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap]; [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
private _durationMs=round ((diag_tickTime-_startedAt)*1000);
private _summary=createHashMapFromArray [["delivery","0.12-C.2"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],["base",_base],["baseExpected",488],["checkpointFirstGate",489],["checkpointLastGate",494],["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],["cumulativeExpected",494],["cumulativePassed",488+_passed],["durationMs",_durationMs],["catalogSideArrows",true],["equipmentDeleteImmediate",true]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================"; diag_log format ["[SP_ORG] [ITEMS] 0.12-C.2 — BASE=488/488  C.2=%1/6  FAIL=%2  CUMULATIVO=%3/494  TEMPO=%4ms",_passed,_failed,488+_passed,_durationMs]; diag_log "[SP_ORG] [ITEMS] 0.12-C.2 — Manual: ← no início = Draft; → no fim = físico; corpo/ícone apenas selecionam; X Equipment continua imediato."; diag_log "============================================================";
if (hasInterface) then {hint parseText format ["<t size='1.25'>SP_ORG_Items 0.12-C.2</t><br/><br/>Baseline C.1: <t color='#7CFC00'>488 / 488</t><br/>C.2: <t color='%1'>%2 / 6</t><br/>Cumulativo: %3 / 494<br/><br/>%4",if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_passed,488+_passed,if (_failed isEqualTo 0) then {"Valide as setas laterais do Catálogo e a exclusão imediata do Equipment."} else {"Consulte o primeiro FAIL no RPT."}];};
_summary
