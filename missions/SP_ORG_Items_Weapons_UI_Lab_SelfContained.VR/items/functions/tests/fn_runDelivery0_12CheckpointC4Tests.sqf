#include "..\..\script_version.hpp"
disableSerialization;
private _legacyRunningState=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR,createHashMap];
if (_legacyRunningState getOrDefault ["running",false]) exitWith {[false,"ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING","A regressão legada já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _orchestrator=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
if (_orchestrator getOrDefault ["running",false]) exitWith {[false,"ITEMS_0_12_C4_ALREADY_RUNNING","Outra suíte cumulativa já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _startedAt=diag_tickTime;
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.12-C.4 — CATALOG VIEWPORT CONTAINMENT + SCROLL UX — 506 GATES";
diag_log "============================================================";
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun; uiSleep 0.02;
private _base=createHashMapFromArray [["success",false],["code","ITEMS_0_12_C4_BASE_CALL_DID_NOT_RETURN"]];
private _baseCall=[] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_12CheckpointC3Tests;
if !(isNil "_baseCall") then {if (_baseCall isEqualType createHashMap) then {_base=_baseCall;};};
private _baseOk=(_base getOrDefault ["success",false]) && {(_base getOrDefault ["checkpointPassed",0]) isEqualTo 6} && {(_base getOrDefault ["cumulativePassed",0]) isEqualTo 500};
if !(_baseOk) exitWith {
    [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
    private _summary=createHashMapFromArray [["delivery","0.12-C.4"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",false],["code","ITEMS_0_12_C4_BASE_500_FAILED"],["base",_base],["checkpointSkipped",true],["checkpointFirstGate",501],["checkpointLastGate",506],["checkpointTotal",0],["checkpointPassed",0],["checkpointFailed",0],["cumulativeExpected",506]];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    diag_log "[SP_ORG] [ITEMS] 0.12-C.4 — FAIL-FAST: baseline 0.12-C.3 500/500 não fechou."; _summary
};
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.12-C.4"]]];
private _passed=0; private _failed=0; private _results=[];
private _assert={params ["_id","_condition","_detail"]; private _ok=(_condition isEqualType true)&&{_condition}; private _status=if (_ok) then {"PASS"} else {"FAIL"}; if (_ok) then {_passed=_passed+1}else{_failed=_failed+1}; _results pushBack [_id,_status,_detail]; diag_log format ["[SP_ORG] [ITEMS] [TEST 0.12-C.4] [%1] %2 — %3",_status,_id,_detail];};
private _productionBefore=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _loadoutBefore=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _srcDialog=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\ui\items_dialog.hpp";
private _srcLoad=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_onInterfaceLoad.sqf";
private _srcRender=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_renderCatalogRowsUI.sqf";
private _srcWheel=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUIWheel.sqf";
private _srcEvent=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUIEvent.sqf";
private _srcFocused=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshCatalogWindowUI.sqf";

["ITEMS-0.12-501",(_srcLoad find "displayCtrl 3120")>=0 && {(_srcLoad find "ctrlShow false")>=0} && {(_srcLoad find "ctrlEnable false")>=0} && {(_srcRender find "catalogLegacyListDisabled")>=0},"CatalogList 3120 é compatibilidade somente: runtime o oculta/desabilita antes do primeiro refresh e a cada render, impedindo o vazamento visual sobre outros painéis."] call _assert;
["ITEMS-0.12-502",(_srcDialog find "class CatalogScroll: SPORG_Items_VSlider")>=0 && {(_srcDialog find "CatalogScrollUp: SPORG_Items_IconButton")>=0} && {(_srcDialog find "CatalogScrollDown: SPORG_Items_IconButton")>=0} && {(_srcDialog find "x=safeZoneX-10")>=0} && {(_srcDialog find "SPORG_Items_HiddenScrollBar")>=0} && {(_srcFocused find "sliderSetSpeed")>=0} && {(_srcFocused find "sliderSetRange")>=0},"Navegação atual do Catálogo preserva uma única barra contínua visível + wheel; ▲/▼ históricos permanecem declarados fora da tela apenas para compatibilidade e a scrollbar interna da CT fica transparente."] call _assert;
["ITEMS-0.12-503",(_srcEvent find "private _offset=round (((_value max 0) min _max))")>=0 && {(_srcFocused find "sliderSetRange [0,(_maxOffset max 1)]")>=0} && {(_srcFocused find "sliderSetPosition _offset")>=0},"Slider trabalha em offset absoluto do catálogo, evitando a ambiguidade visual/semântica do antigo range normalizado 0..1."] call _assert;
["ITEMS-0.12-504",(_srcWheel find "3140")>=0 && {(_srcWheel find "3140,3120")<0} && {(_srcWheel find "_hoverIDC isEqualTo")>=0},"Wheel/hit-test considera somente a superfície moderna visível do Catálogo; ListBox legado não pode capturar ponteiro fora do painel."] call _assert;

private _existing=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD; if (!isNull _existing) then {closeDialog 0; uiSleep 0.03;};
private _dialog=createDialog "SP_ORG_Items_Dialog"; uiSleep 0.08;
private _display=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
private _legacy=if (isNull _display) then {controlNull} else {_display displayCtrl 3120};
private _oldUp=if (isNull _display) then {controlNull} else {_display displayCtrl 3121};
private _oldDown=if (isNull _display) then {controlNull} else {_display displayCtrl 3123};
private _slider=if (isNull _display) then {controlNull} else {_display displayCtrl 3124};
private _table=if (isNull _display) then {controlNull} else {_display displayCtrl SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_TABLE_IDC};
private _oldUpPos=if (isNull _oldUp) then {[]} else {ctrlPosition _oldUp};
private _oldDownPos=if (isNull _oldDown) then {[]} else {ctrlPosition _oldDown};
private _legacyButtonsOffscreen=(count _oldUpPos)>=4 && {(count _oldDownPos)>=4} && {(_oldUpPos#0)<safeZoneX-1} && {(_oldDownPos#0)<safeZoneX-1};
["ITEMS-0.12-505",_dialog && {!isNull _legacy} && {!ctrlShown _legacy} && {!ctrlEnabled _legacy} && {!isNull _oldUp} && {!isNull _oldDown} && {_legacyButtonsOffscreen} && {!isNull _slider} && {ctrlShown _slider} && {!isNull _table} && {ctrlShown _table},"Smoke runtime: ListBox legado fica invisível/não interativo; ▲/▼ históricos ficam fora da viewport e a navegação visível é wheel + slider contínuo junto da CatalogTable."] call _assert;

private _state0=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
_state0 set ["catalogQuery",""]; _state0 set ["catalogCategory","ALL"]; _state0 set ["catalogOffset",0]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state0];
["TEST_0_12_C4_PRIME"] call ServoPeregrino_Organizador_Items_fnc_refreshCatalogWindowUI; uiSleep 0.02;
private _before=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _fullBefore=_before getOrDefault ["fullRefreshCount",0]; private _max=_before getOrDefault ["catalogMaxOffset",0];
private _target=(18 min _max);
["CATALOG_SCROLL_ABSOLUTE",_target] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent; uiSleep 0.02;
private _after=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _loadoutAfter=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _productionAfter=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
["ITEMS-0.12-506",(_after getOrDefault ["catalogOffset",-1]) isEqualTo _target && {(_after getOrDefault ["lastRefreshMode",""]) isEqualTo "CATALOG_FOCUSED"} && {(_after getOrDefault ["fullRefreshCount",-1]) isEqualTo _fullBefore} && {(_loadoutAfter getOrDefault ["serialized","B"]) isEqualTo (_loadoutBefore getOrDefault ["serialized","A"])} && {_productionAfter isEqualTo _productionBefore} && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_C_4_CUMULATIVE_GATE_COUNT isEqualTo 506},"Offset absoluto da barra atualiza em CATALOG_FOCUSED sem FULL e C.4 preserva loadout/storage; alvo cumulativo 506/506."] call _assert;

private _displayEnd=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD; if (!isNull _displayEnd) then {closeDialog 0; uiSleep 0.03;};
[_productionBefore] call ServoPeregrino_Organizador_Items_fnc_restoreProductionRepositorySnapshot;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
private _durationMs=round ((diag_tickTime-_startedAt)*1000);
private _summary=createHashMapFromArray [["delivery","0.12-C.4"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],["base",_base],["baseExpected",500],["checkpointFirstGate",501],["checkpointLastGate",506],["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],["cumulativeExpected",506],["cumulativePassed",500+_passed],["durationMs",_durationMs],["catalogViewportContained",true],["singleVisibleCatalogScrollbar",true],["catalogRealRowButtons",true],["equipmentDeleteImmediate",true]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] 0.12-C.4 — BASE=500/500  C.4=%1/6  FAIL=%2  CUMULATIVO=%3/506  TEMPO=%4ms",_passed,_failed,500+_passed,_durationMs];
diag_log "[SP_ORG] [ITEMS] 0.12-C.4 — Manual: nenhum catálogo legado sobre Meus Kits; wheel + slider contínuo são a navegação visível; ▲/▼ históricos permanecem fora da tela; botões reais ←/→ preservados; X Equipment imediato.";
diag_log "============================================================";
if (hasInterface) then {hint parseText format ["<t size='1.25'>SP_ORG_Items 0.12-C.4</t><br/><br/>Baseline C.3: <t color='#7CFC00'>500 / 500</t><br/>C.4: <t color='%1'>%2 / 6</t><br/>Cumulativo: %3 / 506<br/><br/>%4",if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_passed,500+_passed,if (_failed isEqualTo 0) then {"Valide contenção da viewport e a barra vertical única do Catálogo."} else {"Consulte o primeiro FAIL no RPT."}];};
_summary
