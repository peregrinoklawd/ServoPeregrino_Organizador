#include "..\..\script_version.hpp"
disableSerialization;

private _legacyRunningState=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR,createHashMap];
if (_legacyRunningState getOrDefault ["running",false]) exitWith {[false,"ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING","A regressão legada já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _orchestrator=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
if (_orchestrator getOrDefault ["running",false]) exitWith {[false,"ITEMS_0_11_CP_B7_ALREADY_RUNNING","Outra suíte cumulativa já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};

private _startedAt=diag_tickTime;
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.11 CP-B.7 — FOCUSED KIT SWITCH — 442 GATES";
diag_log "============================================================";

[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
uiSleep 0.02;
private _base=[] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_11CheckpointB61Tests;
private _baseOk=(_base isEqualType createHashMap) && {_base getOrDefault ["success",false]} && {(_base getOrDefault ["checkpointPassed",0]) isEqualTo 8} && {(_base getOrDefault ["cumulativePassed",0]) isEqualTo 436};
if !(_baseOk) exitWith {
    [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
    private _summary=createHashMapFromArray [["delivery","0.11 CP-B.7"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",false],["code","ITEMS_0_11_CP_B7_BASE_436_FAILED"],["base",_base],["checkpointSkipped",true],["checkpointFirstGate",437],["checkpointLastGate",442],["checkpointTotal",0],["checkpointPassed",0],["checkpointFailed",0],["cumulativeExpected",442]];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    diag_log "[SP_ORG] [ITEMS] 0.11 CP-B.7 — FAIL-FAST: baseline CP-B.6.1 436/436 não fechou.";
    if (hasInterface) then {hint "SP_ORG_Items 0.11 CP-B.7 reprovado na baseline 436/436. Consulte o primeiro FAIL no RPT.";};
    _summary
};

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.11 CP-B.7"]]];
private _passed=0;
private _failed=0;
private _results=[];
private _assert={
    params ["_id","_condition","_detail"];
    private _ok=(_condition isEqualType true) && {_condition};
    private _status=if (_ok) then {"PASS"} else {"FAIL"};
    if (_ok) then {_passed=_passed+1;} else {_failed=_failed+1;};
    _results pushBack [_id,_status,_detail];
    diag_log format ["[SP_ORG] [ITEMS] [TEST 0.11 CP-B.7] [%1] %2 — %3",_status,_id,_detail];
};
private _productionBefore=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _loadoutBefore=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];

// 437 — wiring estático: LOAD_KIT usa caminho focal e o próprio refresh focal não depende dos serviços caros.
private _srcTransition=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_requestDraftTransition.sqf";
private _srcFocused=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshKitSwitchUI.sqf";
private _forbiddenFocused=["fnc_refreshInterface;","fnc_getCatalog;","fnc_filterCatalog;","fnc_listKits;","fnc_capturePlayerContainer;","lbClear"];
private _gate437=(_srcTransition find "refreshKitSwitchUI" >= 0)
    && {(_srcTransition find "LOAD_KIT" >= 0)}
    && {(_srcFocused find "refreshDraftMutationUI" >= 0)}
    && {(_srcFocused find "refreshPhysicalTargetUI" >= 0)}
    && {({_srcFocused find _x >= 0} count _forbiddenFocused) isEqualTo 0};
["ITEMS-0.11-437",_gate437,"LOAD_KIT está ligado a KIT_SWITCH_FOCUSED; o caminho focal não chama FULL, Catálogo, Repository list ou recaptura Equipment."] call _assert;

// Fixture persistente isolado: nenhuma escrita desta fase usa as chaves reais do jogador.
["AUTO_0_11_B7",true] call ServoPeregrino_Organizador_Items_fnc_configureRepositoryTestMode;
private _e1=( ["ITEM","FirstAidKit",2,"NONE",[]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry) getOrDefault ["data",createHashMap];
private _e2=( ["ITEM","ToolKit",1,"NONE",[]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry) getOrDefault ["data",createHashMap];
private _entry1=_e1 getOrDefault ["entry",[]];
private _entry2=_e2 getOrDefault ["entry",[]];
private _k1r=["CP-B.7 Alpha",[_entry1],"UNIFORM",["TEST","CP_B7"]] call ServoPeregrino_Organizador_Items_fnc_createItemKit;
private _k2r=["CP-B.7 Bravo",[_entry1,_entry2],"VEST",["TEST","CP_B7"]] call ServoPeregrino_Organizador_Items_fnc_createItemKit;
private _create1Ok=_k1r getOrDefault ["success",false];
private _create2Ok=_k2r getOrDefault ["success",false];
private _kit1=if (_create1Ok) then {(_k1r getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]]} else {[]};
private _kit2=if (_create2Ok) then {(_k2r getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]]} else {[]};
private _save1=if (_create1Ok && {(count _kit1)>0}) then {[_kit1] call ServoPeregrino_Organizador_Items_fnc_saveKit} else {createHashMapFromArray [["success",false],["code","ITEMS_TEST_FIXTURE_CREATE_ALPHA_FAILED"]]};
private _save2=if (_create2Ok && {(count _kit2)>0}) then {[_kit2] call ServoPeregrino_Organizador_Items_fnc_saveKit} else {createHashMapFromArray [["success",false],["code","ITEMS_TEST_FIXTURE_CREATE_BRAVO_FAILED"]]};
private _id1=if (_create1Ok && {(count _kit1)>2}) then {_kit1#2} else {""};
private _id2=if (_create2Ok && {(count _kit2)>2}) then {_kit2#2} else {""};
diag_log format ["[SP_ORG] [ITEMS] [TEST_FIXTURE] CP-B.7 alpha create=%1/%2 save=%3/%4 id=%5 target=UNIFORM | bravo create=%6/%7 save=%8/%9 id=%10 target=VEST",_create1Ok,_k1r getOrDefault ["code","-"],_save1 getOrDefault ["success",false],_save1 getOrDefault ["code","-"],_id1,_create2Ok,_k2r getOrDefault ["code","-"],_save2 getOrDefault ["success",false],_save2 getOrDefault ["code","-"],_id2];

// Abre UI já no primeiro kit. O FULL inicial é permitido e vira a baseline do segmento.
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMap];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_createUIState;
private _load1=if (_id1 isNotEqualTo "") then {[_id1] call ServoPeregrino_Organizador_Items_fnc_loadDraftFromKit} else {createHashMap};
private _uiSeed=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
_uiSeed set ["selectedKitId",_id1];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_uiSeed];
private _existing=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
if (!isNull _existing) then {closeDialog 0; uiSleep 0.03;};
private _dialog=createDialog "SP_ORG_Items_Dialog";
uiSleep 0.12;
private _display=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
private _kitsCtrl=if (isNull _display) then {controlNull} else {_display displayCtrl 1102};
private _catCtrl=if (isNull _display) then {controlNull} else {_display displayCtrl 3120};
private _eqCtrl=if (isNull _display) then {controlNull} else {_display displayCtrl 4120};
private _listSnapshot={
    params ["_ctrl"];
    private _rows=[];
    if !(isNull _ctrl) then {for "_i" from 0 to ((lbSize _ctrl)-1) do {_rows pushBack [_ctrl lbText _i,_ctrl lbData _i];};};
    _rows
};

// Seleções não destrutivas ajudam a provar preservação visual.
if (!isNull _catCtrl && {(lbSize _catCtrl)>2}) then {_catCtrl lbSetCurSel 2;};
if (!isNull _eqCtrl && {(lbSize _eqCtrl)>0}) then {_eqCtrl lbSetCurSel 0;};
private _catRowsBefore=[_catCtrl] call _listSnapshot;
private _catSelBefore=if (isNull _catCtrl) then {-1} else {lbCurSel _catCtrl};
private _catScrollBefore=if (isNull _catCtrl) then {[]} else {ctrlScrollValues _catCtrl};
private _eqRowsBefore=[_eqCtrl] call _listSnapshot;
private _eqSelBefore=if (isNull _eqCtrl) then {-1} else {lbCurSel _eqCtrl};
private _eqScrollBefore=if (isNull _eqCtrl) then {[]} else {ctrlScrollValues _eqCtrl};
private _stateBefore=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _fullBefore=_stateBefore getOrDefault ["fullRefreshCount",0];
private _kitFocusBefore=_stateBefore getOrDefault ["kitSwitchFocusedRefreshCount",0];
private _catFocusBefore=_stateBefore getOrDefault ["catalogFocusedRefreshCount",0];
private _eqFocusBefore=_stateBefore getOrDefault ["equipmentFocusedRefreshCount",0];
private _eqCaptureBefore=_stateBefore getOrDefault ["equipmentCaptureCount",0];
private _targetBefore=_stateBefore getOrDefault ["targetRefreshCount",0];
private _soundBefore=count (_stateBefore getOrDefault ["movementSoundHistory",[]]);

private _switchR=if (_id2 isNotEqualTo "") then {["LOAD_KIT",_id2] call ServoPeregrino_Organizador_Items_fnc_requestDraftTransition} else {createHashMap};
private _stateAfter=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _draftAfter=([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap];
private _currentAfter=_draftAfter getOrDefault ["current",createHashMap];
private _fullAfter=_stateAfter getOrDefault ["fullRefreshCount",-1];

// 438 — núcleo: troca real de kit usa um refresh focal e zero FULL.
private _gate438=_dialog && {!isNull _display} && {(_save1 getOrDefault ["success",false])} && {(_save2 getOrDefault ["success",false])}
    && {(_switchR getOrDefault ["success",false])}
    && {_fullAfter isEqualTo _fullBefore}
    && {(_stateAfter getOrDefault ["kitSwitchFocusedRefreshCount",-1]) isEqualTo (_kitFocusBefore+1)}
    && {(_stateAfter getOrDefault ["lastRefreshMode",""]) isEqualTo "KIT_SWITCH_FOCUSED"}
    && {(_stateAfter getOrDefault ["lastKitSwitchFullDelta",-1]) isEqualTo 0}
    && {(_stateAfter getOrDefault ["selectedKitId",""]) isEqualTo _id2}
    && {(_currentAfter getOrDefault ["kitId",""]) isEqualTo _id2}
    && {(_currentAfter getOrDefault ["mode",""]) isEqualTo "EDIT"};
["ITEMS-0.11-438",_gate438,"Troca real Alpha→Bravo usa KIT_SWITCH_FOCUSED, mantém fullDelta=0 e sincroniza selectedKitId + Draft EDIT."] call _assert;

// 439 — Catálogo permanece byte/logicamente idêntico na tela; sem CATALOG_FOCUSED implícito.
private _catRowsAfter=[_catCtrl] call _listSnapshot;
private _catSelAfter=if (isNull _catCtrl) then {-2} else {lbCurSel _catCtrl};
private _catScrollAfter=if (isNull _catCtrl) then {[]} else {ctrlScrollValues _catCtrl};
private _gate439=(_catRowsAfter isEqualTo _catRowsBefore)
    && {_catSelAfter isEqualTo _catSelBefore}
    && {_catScrollAfter isEqualTo _catScrollBefore}
    && {(_stateAfter getOrDefault ["catalogFocusedRefreshCount",-1]) isEqualTo _catFocusBefore}
    && {_stateAfter getOrDefault ["lastKitSwitchCatalogUntouched",false]};
["ITEMS-0.11-439",_gate439,"KIT_SWITCH_FOCUSED preserva exatamente conteúdo, seleção e scroll do Catálogo; nenhuma projeção/filtro é reexecutado."] call _assert;

// 440 — Equipment também fica congelado; nada é recapturado.
private _eqRowsAfter=[_eqCtrl] call _listSnapshot;
private _eqSelAfter=if (isNull _eqCtrl) then {-2} else {lbCurSel _eqCtrl};
private _eqScrollAfter=if (isNull _eqCtrl) then {[]} else {ctrlScrollValues _eqCtrl};
private _gate440=(_eqRowsAfter isEqualTo _eqRowsBefore)
    && {_eqSelAfter isEqualTo _eqSelBefore}
    && {_eqScrollAfter isEqualTo _eqScrollBefore}
    && {(_stateAfter getOrDefault ["equipmentFocusedRefreshCount",-1]) isEqualTo _eqFocusBefore}
    && {(_stateAfter getOrDefault ["equipmentCaptureCount",-1]) isEqualTo _eqCaptureBefore}
    && {(_stateAfter getOrDefault ["lastKitSwitchEquipmentCaptureDelta",-1]) isEqualTo 0}
    && {_stateAfter getOrDefault ["lastKitSwitchEquipmentUntouched",false]};
["ITEMS-0.11-440",_gate440,"KIT_SWITCH_FOCUSED preserva Equipment e não recaptura o container visualizado."] call _assert;

// 441 — preferredTarget pode mudar com o kit; por isso readiness é recalculada sem trocar applicationTarget/view.
private _gate441=(_stateAfter getOrDefault ["targetRefreshCount",-1]) isEqualTo (_targetBefore+1)
    && {(_stateAfter getOrDefault ["lastKitSwitchTargetRefreshDelta",-1]) isEqualTo 1}
    && {(_stateAfter getOrDefault ["applicationTarget",""]) isEqualTo (_stateBefore getOrDefault ["applicationTarget",""])}
    && {(_stateAfter getOrDefault ["equipmentView",""]) isEqualTo (_stateBefore getOrDefault ["equipmentView",""])}
    && {(_currentAfter getOrDefault ["preferredTarget",""]) isEqualTo "VEST"};
["ITEMS-0.11-441",_gate441,"Troca de kit recalcula somente readiness física derivada do novo preferredTarget canônico; applicationTarget e Equipment View permanecem independentes."] call _assert;

// 442 — troca é lógica: sem áudio de movimento, sem loadout, sem storage de produção.
private _soundAfter=count (_stateAfter getOrDefault ["movementSoundHistory",[]]);
private _loadoutAfter=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _productionMid=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _gate442=(_soundAfter isEqualTo _soundBefore)
    && {(_loadoutAfter getOrDefault ["serialized","B"]) isEqualTo (_loadoutBefore getOrDefault ["serialized","A"])}
    && {_productionMid isEqualTo _productionBefore};
["ITEMS-0.11-442",_gate442,"KIT_SWITCH_FOCUSED é silencioso e não toca loadout nem storage real; fixtures permanecem no namespace isolado de teste."] call _assert;

private _displayEnd=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
if (!isNull _displayEnd) then {closeDialog 0; uiSleep 0.03;};
["AUTO_0_11_B7",true] call ServoPeregrino_Organizador_Items_fnc_configureRepositoryTestMode;
["",false] call ServoPeregrino_Organizador_Items_fnc_configureRepositoryTestMode;
[_productionBefore] call ServoPeregrino_Organizador_Items_fnc_restoreProductionRepositorySnapshot;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;

private _durationMs=round ((diag_tickTime-_startedAt)*1000);
private _summary=createHashMapFromArray [["delivery","0.11 CP-B.7"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],["base",_base],["baseExpected",436],["checkpointFirstGate",437],["checkpointLastGate",442],["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],["cumulativeExpected",442],["cumulativePassed",436+_passed],["durationMs",_durationMs],["focusedKitSwitch",true],["manualTargetMs",50]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] 0.11 CP-B.7 — BASE=436/436  CP-B.7=%1/6  FAIL=%2  CUMULATIVO=%3/442  TEMPO=%4ms",_passed,_failed,436+_passed,_durationMs];
diag_log "[SP_ORG] [ITEMS] 0.11 CP-B.7 — Manual: com CONFIG_ALL pronto, trocar kits rapidamente. Esperado UI_PERF_KIT_SWITCH fullDelta=0 e KIT_SWITCH_FOCUSED idealmente <50ms.";
diag_log "============================================================";
if (hasInterface) then {hint parseText format ["<t size='1.25'>SP_ORG_Items 0.11 CP-B.7</t><br/><br/>Baseline CP-B.6.1: <t color='#7CFC00'>436 / 436</t><br/>CP-B.7: <t color='%1'>%2 / 6</t><br/>Cumulativo: %3 / 442<br/><br/>%4",if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_passed,436+_passed,if (_failed isEqualTo 0) then {"Abra a UI e troque kits com o Catálogo pronto. Envie UI_PERF_KIT_SWITCH; esperado fullDelta=0."} else {"Consulte o primeiro FAIL no RPT."}];};
_summary
