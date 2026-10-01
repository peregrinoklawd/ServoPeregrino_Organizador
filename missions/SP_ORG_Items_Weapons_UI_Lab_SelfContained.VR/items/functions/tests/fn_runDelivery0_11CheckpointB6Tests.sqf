#include "..\..\script_version.hpp"
disableSerialization;

private _legacyRunningState=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR,createHashMap];
if (_legacyRunningState getOrDefault ["running",false]) exitWith {[false,"ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING","A regressão legada já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _orchestrator=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
if (_orchestrator getOrDefault ["running",false]) exitWith {[false,"ITEMS_0_11_CP_B6_ALREADY_RUNNING","Outra suíte cumulativa já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};

private _startedAt=diag_tickTime;
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.11 CP-B.6 — FOCUSED EQUIPMENT VIEW + CATALOG PERFORMANCE — 436 GATES";
diag_log "============================================================";

[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
uiSleep 0.02;
private _base=[] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_11CheckpointB5Tests;
private _baseOk=(_base isEqualType createHashMap) && {_base getOrDefault ["success",false]} && {(_base getOrDefault ["checkpointPassed",0]) isEqualTo 14} && {(_base getOrDefault ["cumulativePassed",0]) isEqualTo 428};
if !(_baseOk) exitWith {
    [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
    private _summary=createHashMapFromArray [["delivery","0.11 CP-B.6"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",false],["code","ITEMS_0_11_CP_B6_BASE_428_FAILED"],["base",_base],["checkpointSkipped",true],["checkpointFirstGate",429],["checkpointLastGate",436],["checkpointTotal",0],["checkpointPassed",0],["checkpointFailed",0],["cumulativeExpected",436]];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    diag_log "[SP_ORG] [ITEMS] 0.11 CP-B.6 — FAIL-FAST: baseline CP-B.5 428/428 não fechou.";
    if (hasInterface) then {hint "SP_ORG_Items 0.11 CP-B.6 reprovado na baseline 428/428. Consulte o primeiro FAIL no RPT.";};
    _summary
};

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.11 CP-B.6"]]];
private _passed=0;
private _failed=0;
private _results=[];
private _assert={
    params ["_id","_condition","_detail"];
    private _ok=(_condition isEqualType true) && {_condition};
    private _status=if (_ok) then {"PASS"} else {"FAIL"};
    if (_ok) then {_passed=_passed+1;} else {_failed=_failed+1;};
    _results pushBack [_id,_status,_detail];
    diag_log format ["[SP_ORG] [ITEMS] [TEST 0.11 CP-B.6] [%1] %2 — %3",_status,_id,_detail];
};
private _productionBefore=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _oldUIState=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _oldDraftState=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _oldProjection=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_PROJECTION_VAR,createHashMap];

// 429 — wiring: eventos de VIEW e Catálogo não pedem mais refresh global.
private _srcEvent429=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUIEvent.sqf";
private _gate429=(_srcEvent429 find "EQUIPMENT_FOCUSED" >= 0 || {_srcEvent429 find "refreshEquipmentViewUI" >= 0})
    && {(_srcEvent429 find "CATALOG_FOCUSED" >= 0 || {_srcEvent429 find "refreshCatalogWindowUI" >= 0})}
    && {(_srcEvent429 find "EQUIPMENT_VIEW" >= 0)} && {(_srcEvent429 find "CATALOG_CATEGORY" >= 0)};
["ITEMS-0.11-429",_gate429,"EQUIPMENT_VIEW e filtros/paginação do Catálogo estão ligados a refreshes focais, não ao refresh global dos quatro painéis."] call _assert;

// Prepara UI real para os smoke tests 430..435.
private _existing=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
if (!isNull _existing) then {closeDialog 0; uiSleep 0.03;};
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_PROJECTION_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_createUIState;
private _dialog=createDialog "SP_ORG_Items_Dialog";
uiSleep 0.12;
private _display=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
private _ui0=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _full0=_ui0 getOrDefault ["fullRefreshCount",0];
private _eqFocus0=_ui0 getOrDefault ["equipmentFocusedRefreshCount",0];
private _eqCapture0=_ui0 getOrDefault ["equipmentCaptureCount",0];
private _catFocus0=_ui0 getOrDefault ["catalogFocusedRefreshCount",0];
private _catCtrl=if (isNull _display) then {controlNull} else {_display displayCtrl 3120};
private _draftCtrl=if (isNull _display) then {controlNull} else {_display displayCtrl 2104};
private _catSize0=if (isNull _catCtrl) then {-1} else {lbSize _catCtrl};
private _draftRows0=if (isNull _draftCtrl) then {-1} else {ctRowCount _draftCtrl};

// 430 — clicar U quando U já está ativo é NOOP de captura e não full refresh.
private _viewBefore430=_ui0 getOrDefault ["equipmentView","U"];
["EQUIPMENT_VIEW",_viewBefore430] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent;
private _ui430=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _gate430=_dialog && {!isNull _display} && {(_ui430 getOrDefault ["fullRefreshCount",-1]) isEqualTo _full0} && {(_ui430 getOrDefault ["equipmentFocusedRefreshCount",-1]) isEqualTo (_eqFocus0+1)} && {(_ui430 getOrDefault ["equipmentCaptureCount",-1]) isEqualTo _eqCapture0} && {!(_ui430 getOrDefault ["lastEquipmentFocusedCaptured",true])};
["ITEMS-0.11-430",_gate430,"VIEW U→U usa EQUIPMENT_FOCUSED sem recapturar container e sem incrementar FULL; clique redundante vira NOOP leve."] call _assert;

// 431 — trocar U/C/M recaptura somente Equipment e preserva Catálogo/Draft.
private _targetView431=if (_viewBefore430 isEqualTo "U") then {"C"} else {"U"};
private _catSize431a=if (isNull _catCtrl) then {-1} else {lbSize _catCtrl};
private _draftRows431a=if (isNull _draftCtrl) then {-1} else {ctRowCount _draftCtrl};
private _full431a=_ui430 getOrDefault ["fullRefreshCount",0];
private _cap431a=_ui430 getOrDefault ["equipmentCaptureCount",0];
["EQUIPMENT_VIEW",_targetView431] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent;
private _ui431=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _catSize431b=if (isNull _catCtrl) then {-2} else {lbSize _catCtrl};
private _draftRows431b=if (isNull _draftCtrl) then {-2} else {ctRowCount _draftCtrl};
private _gate431=(_ui431 getOrDefault ["fullRefreshCount",-1]) isEqualTo _full431a && {(_ui431 getOrDefault ["equipmentCaptureCount",-1]) isEqualTo (_cap431a+1)} && {_ui431 getOrDefault ["lastEquipmentFocusedCaptured",false]} && {_catSize431b isEqualTo _catSize431a} && {_draftRows431b isEqualTo _draftRows431a};
["ITEMS-0.11-431",_gate431,"Troca real de VIEW recaptura somente Equipment; Catálogo e Draft permanecem estruturalmente intactos e FULL não roda."] call _assert;

// 432 — categoria do Catálogo usa CATALOG_FOCUSED e não recaptura Equipment.
private _ui432a=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _full432a=_ui432a getOrDefault ["fullRefreshCount",0];
private _cap432a=_ui432a getOrDefault ["equipmentCaptureCount",0];
private _catFocus432a=_ui432a getOrDefault ["catalogFocusedRefreshCount",0];
["CATALOG_CATEGORY","MEDICAL"] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent;
private _ui432b=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _gate432=(_ui432b getOrDefault ["fullRefreshCount",-1]) isEqualTo _full432a && {(_ui432b getOrDefault ["equipmentCaptureCount",-1]) isEqualTo _cap432a} && {(_ui432b getOrDefault ["catalogFocusedRefreshCount",-1]) isEqualTo (_catFocus432a+1)} && {(_ui432b getOrDefault ["lastRefreshMode",""]) isEqualTo "CATALOG_FOCUSED"};
["ITEMS-0.11-432",_gate432,"Filtro de categoria atualiza somente a janela do Catálogo; não recaptura Equipment e não reconstrói os quatro painéis."] call _assert;

// 433 — caminho focal do Catálogo acessa o cache diretamente e só copia a janela visível.
private _srcWindow433=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_getUICatalogWindow.sqf";
private _forbidden433=["fnc_getCatalog","fnc_filterCatalog","fnc_listKits","fnc_getDraftState","fnc_capturePlayerContainer","fnc_refreshInterface","saveProfileNamespace","fnc_saveStorage"];
private _gate433=(_srcWindow433 find "UI_CATALOG_PROJECTION" >= 0 || {_srcWindow433 find "uiCatalogProjection" >= 0}) && {(_srcWindow433 find "copyCatalogItem" >= 0)} && {({_srcWindow433 find _x >= 0} count _forbidden433) isEqualTo 0};
["ITEMS-0.11-433",_gate433,"Projeção focal lê referências do cache CONFIG_ALL e faz defensive copy somente das linhas da janela; não chama getCatalog/filterCatalog nem serviços de outros painéis."] call _assert;

// 434 — índice por categoria é construído uma vez e reutilizado entre filtros.
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_PROJECTION_VAR,createHashMap];
private _w434a=["","ALL",0,10] call ServoPeregrino_Organizador_Items_fnc_getUICatalogWindow;
private _d434a=_w434a getOrDefault ["data",createHashMap];
private _w434b=["","MEDICAL",0,10] call ServoPeregrino_Organizador_Items_fnc_getUICatalogWindow;
private _d434b=_w434b getOrDefault ["data",createHashMap];
private _gate434=(_w434a getOrDefault ["success",false]) && {_w434b getOrDefault ["success",false]} && {_d434a getOrDefault ["projectionBuiltNow",false]} && {!(_d434b getOrDefault ["projectionBuiltNow",true])} && {(_d434a getOrDefault ["projectionBuildCount",0]) isEqualTo (_d434b getOrDefault ["projectionBuildCount",-1])} && {(_d434b getOrDefault ["defensiveCopies",9999]) <= 10};
["ITEMS-0.11-434",_gate434,"Índice UI por categoria nasce uma vez por cache/build e é reutilizado; filtro seguinte copia no máximo a janela solicitada."] call _assert;

// 435 — busca e paginação também permanecem focais e silenciosas para Equipment/FULL.
private _ui435a=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _full435a=_ui435a getOrDefault ["fullRefreshCount",0];
private _cap435a=_ui435a getOrDefault ["equipmentCaptureCount",0];
private _catFocus435a=_ui435a getOrDefault ["catalogFocusedRefreshCount",0];
["CATALOG_SEARCH","FirstAidKit"] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent;
["CATALOG_PAGE",1] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent;
private _ui435b=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _gate435=(_ui435b getOrDefault ["fullRefreshCount",-1]) isEqualTo _full435a && {(_ui435b getOrDefault ["equipmentCaptureCount",-1]) isEqualTo _cap435a} && {(_ui435b getOrDefault ["catalogFocusedRefreshCount",-1]) isEqualTo (_catFocus435a+2)};
["ITEMS-0.11-435",_gate435,"Busca e paginação do Catálogo permanecem CATALOG_FOCUSED; não provocam FULL nem recaptura do equipamento."] call _assert;

// 436 — áudio continua ativo; refreshes focais não geram cue por conta própria e storage real fica intacto.
private _soundBefore436=count ((missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]) getOrDefault ["movementSoundHistory",[]]);
[createHashMapFromArray [["reason","TEST_SAME_VIEW"],["sameView",true]]] call ServoPeregrino_Organizador_Items_fnc_refreshEquipmentViewUI;
["TEST_CATALOG_FOCUSED"] call ServoPeregrino_Organizador_Items_fnc_refreshCatalogWindowUI;
private _soundAfter436=count ((missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]) getOrDefault ["movementSoundHistory",[]]);
private _productionAfter=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _gate436=(_soundAfter436 isEqualTo _soundBefore436) && {_productionAfter isEqualTo _productionBefore};
["ITEMS-0.11-436",_gate436,"EQUIPMENT_FOCUSED/CATALOG_FOCUSED puros são silenciosos e não tocam storage real; áudio permanece reservado a gestos de movimentação."] call _assert;

private _displayEnd=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
if (!isNull _displayEnd) then {closeDialog 0; uiSleep 0.03;};
[_productionBefore] call ServoPeregrino_Organizador_Items_fnc_restoreProductionRepositorySnapshot;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,_oldDraftState];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_oldUIState];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_PROJECTION_VAR,_oldProjection];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;

private _durationMs=round ((diag_tickTime-_startedAt)*1000);
private _summary=createHashMapFromArray [["delivery","0.11 CP-B.6"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],["base",_base],["baseExpected",428],["checkpointFirstGate",429],["checkpointLastGate",436],["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],["cumulativeExpected",436],["cumulativePassed",428+_passed],["durationMs",_durationMs],["focusedEquipmentView",true],["focusedCatalog",true],["audioEnabled",true]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] 0.11 CP-B.6 — BASE=428/428  CP-B.6=%1/8  FAIL=%2  CUMULATIVO=%3/436  TEMPO=%4ms",_passed,_failed,428+_passed,_durationMs];
diag_log "[SP_ORG] [ITEMS] 0.11 CP-B.6 — Esperado manual: U→U sem recaptura; U/C/M com EQUIPMENT_FOCUSED; filtros com CATALOG_FOCUSED; sem micro-stutter perceptível.";
diag_log "============================================================";
if (hasInterface) then {hint parseText format ["<t size='1.25'>SP_ORG_Items 0.11 CP-B.6</t><br/><br/>Baseline CP-B.5: <t color='#7CFC00'>428 / 428</t><br/>CP-B.6: <t color='%1'>%2 / 8</t><br/>Cumulativo: %3 / 436<br/><br/>%4",if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_passed,428+_passed,if (_failed isEqualTo 0) then {"Teste VIEW U/C/M e filtros do Catálogo; envie o RPT com UI_PERF."} else {"Consulte o primeiro FAIL no RPT."}];};
_summary
