#include "..\..\script_version.hpp"
disableSerialization;
private _legacyRunningState=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR,createHashMap];
if (_legacyRunningState getOrDefault ["running",false]) exitWith {[false,"ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING","A regressão legada já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _orchestrator=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
if (_orchestrator getOrDefault ["running",false]) exitWith {[false,"ITEMS_0_12_C_ALREADY_RUNNING","Outra suíte cumulativa já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _startedAt=diag_tickTime;
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.12-C.1 — RUNNER SYNTAX + HISTORICAL GATE HARDENING — 488 GATES";
diag_log "============================================================";
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun; uiSleep 0.02;
private _base=createHashMapFromArray [["success",false],["code","ITEMS_0_12_B_CALL_DID_NOT_RETURN"]];
private _baseCall=[] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_12CheckpointBTests;
if !(isNil "_baseCall") then {if (_baseCall isEqualType createHashMap) then {_base=_baseCall;};};
private _baseOk=(_base getOrDefault ["success",false]) && {(_base getOrDefault ["checkpointPassed",0]) isEqualTo 10} && {(_base getOrDefault ["cumulativePassed",0]) isEqualTo 478};
if !(_baseOk) exitWith {
    [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
    private _summary=createHashMapFromArray [["delivery","0.12-C.1"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",false],["code","ITEMS_0_12_C_BASE_478_FAILED"],["base",_base],["checkpointSkipped",true],["checkpointFirstGate",479],["checkpointLastGate",488],["checkpointTotal",0],["checkpointPassed",0],["checkpointFailed",0],["cumulativeExpected",488]];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    diag_log "[SP_ORG] [ITEMS] 0.12-C.1 — FAIL-FAST: baseline 0.12-B 478/478 não fechou."; _summary
};
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.12-C.1"]]];
private _passed=0; private _failed=0; private _results=[];
private _assert={params ["_id","_condition","_detail"]; private _ok=(_condition isEqualType true)&&{_condition}; private _status=if (_ok) then {"PASS"} else {"FAIL"}; if (_ok) then {_passed=_passed+1}else{_failed=_failed+1}; _results pushBack [_id,_status,_detail]; diag_log format ["[SP_ORG] [ITEMS] [TEST 0.12-C.1] [%1] %2 — %3",_status,_id,_detail];};
private _productionBefore=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _loadoutBefore=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _srcDialog=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\ui\items_dialog.hpp";
private _srcWindow=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_getUICatalogWindow.sqf";
private _srcCatalog=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshCatalogWindowUI.sqf";
private _srcDetails=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshCatalogSelectionDetails.sqf";
private _srcEvent=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUIEvent.sqf";
private _srcWheel=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUIWheel.sqf";
private _srcFull=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_buildUIViewModel.sqf";
private _srcEqRequest=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_requestEquipmentRowAction.sqf";
private _srcCatalogRenderer=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_renderCatalogRowsUI.sqf";

["ITEMS-0.12-479",(_srcDialog find "idc=3124")>=0 && {(_srcDialog find "CatalogScrollUp")>=0} && {(_srcDialog find "CatalogScrollDown")>=0} && {(_srcDialog find "CATALOG_PAGE',-1")<0} && {(_srcDialog find "CATALOG_PAGE',1")<0},"Paginação visível foi removida; Catálogo expõe setas verticais e slider contínuo próprio."] call _assert;
["ITEMS-0.12-480",(_srcWindow find "((_total-_safeWindow) max 0)")>=0 && {(_srcWindow find "floor ((_total-1)/_safeWindow)")<0},"Janela virtual aceita offset contínuo e clampa no último offset válido, sem alinhar a múltiplos de página."] call _assert;
["ITEMS-0.12-481",(_srcEvent find "CATALOG_SCROLL_ABSOLUTE")>=0 && {(_srcEvent find "catalogContinuousScrollCount")>=0} && {(_srcWheel find "CATALOG_SCROLL")>=0} && {(_srcCatalog find "sliderSetPosition")>=0},"Wheel, setas e slider convergem ao scroll contínuo e ao refresh CATALOG_FOCUSED."] call _assert;
["ITEMS-0.12-482",((_srcCatalog find "fnc_renderCatalogRowsUI")>=0 && {(_srcCatalogRenderer find "_toDraft ctrlSetText")>=0} && {(_srcCatalogRenderer find "_toPhysical ctrlSetText")>=0}) || {((_srcCatalog find "lbAdd format [""←   %1")>=0) && {(_srcCatalog find "lbSetTextRight [_i,""→""]")>=0}},"Cada linha do Catálogo materializa as duas ações laterais ← Draft e → aplicação física; descendentes podem usar botões reais em renderer compartilhado."] call _assert;
private _catalogActionStart483=_srcEvent find "private _executeCatalogClassAction";
private _catalogActionEnd483=_srcEvent find "private _clickCatalogAction";
private _catalogActionSrc483=if (_catalogActionStart483>=0 && {_catalogActionEnd483>_catalogActionStart483}) then {_srcEvent select [_catalogActionStart483,_catalogActionEnd483-_catalogActionStart483]} else {""};
["ITEMS-0.12-483",(_srcEvent find "CATALOG_ARROW_TO_DRAFT")>=0 && {(_srcEvent find "CATALOG_ARROW_TO_PHYSICAL")>=0} && {(_catalogActionSrc483 find "equipmentView")>=0} && {(_catalogActionSrc483 find "applicationTarget")<0},"Rail dual do Catálogo usa o dispatcher central: botão esquerdo copia ao Kit Selecionado e botão direito adiciona ao equipamento exibido em Mostrar."] call _assert;
private _friendlyPhysicalCopy484=((_srcDetails find "equipamento escolhido")>=0) || {(_srcDetails find "Destino de Aplicação")>=0} || {(_srcDetails find "equipamento exibido em Mostrar")>=0};
["ITEMS-0.12-484",(_srcDetails find "Peso:")>=0 && {(_srcDetails find "Kit Selecionado")>=0} && {_friendlyPhysicalCopy484} && {(_srcDetails find "Classe:")<0} && {(_srcDetails find "Addon:")<0} && {(_srcCatalog find "Classe:")<0} && {(_srcCatalog find "Addon:")<0},"Tooltip e descrição inferior do Catálogo mantêm apenas informações úteis ao jogador, sem classe/addon técnico, aceitando a copy atual baseada em Mostrar."] call _assert;
["ITEMS-0.12-485",(_srcFull find "fnc_getUICatalogWindow")>=0 && {(_srcFull find "fnc_filterCatalog")<0},"FULL reutiliza janela virtual do Catálogo e não volta a copiar/filtrar os milhares de itens do CONFIG_ALL."] call _assert;
["ITEMS-0.12-486",(_srcEqRequest find "private _needsConfirm=(_actionU isEqualTo ""QUANTITY"")")>=0 && {(_srcEqRequest find "EQUIPMENT_DELETE_DIRECT")>=0} && {(_srcEqRequest find "EQUIPMENT_DELETE_CONFIRMED")<0} && {(_srcEqRequest find "EQUIPMENT_QUANTITY_ZERO_CONFIRMED")>=0},"X/Delete do Equipment é imediato; quantidade digitada 0 mantém confirmação explícita."] call _assert;

private _existing=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD; if (!isNull _existing) then {closeDialog 0; uiSleep 0.03;};
private _dialog=createDialog "SP_ORG_Items_Dialog"; uiSleep 0.08;
private _runtimeState=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
_runtimeState set ["catalogQuery",""]; _runtimeState set ["catalogCategory","ALL"]; _runtimeState set ["catalogOffset",0]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_runtimeState];
["TEST_0_12_C_PRIME"] call ServoPeregrino_Organizador_Items_fnc_refreshCatalogWindowUI; uiSleep 0.02;
private _beforeScroll=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _fullBefore=_beforeScroll getOrDefault ["fullRefreshCount",0]; private _maxBefore=_beforeScroll getOrDefault ["catalogMaxOffset",0];
["CATALOG_SCROLL",6] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent; uiSleep 0.02;
private _afterScroll=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
["ITEMS-0.12-487",_dialog && {_maxBefore>0} && {(_afterScroll getOrDefault ["catalogOffset",0])>0} && {(_afterScroll getOrDefault ["lastRefreshMode",""]) isEqualTo "CATALOG_FOCUSED"} && {(_afterScroll getOrDefault ["fullRefreshCount",-1]) isEqualTo _fullBefore},"Smoke runtime: scroll contínuo muda offset em CATALOG_FOCUSED sem incrementar FULL."] call _assert;

private _loadoutAfter=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap]; private _productionAfter=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
["ITEMS-0.12-488",(_loadoutAfter getOrDefault ["serialized","B"]) isEqualTo (_loadoutBefore getOrDefault ["serialized","A"]) && {_productionAfter isEqualTo _productionBefore} && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_C_CUMULATIVE_GATE_COUNT isEqualTo 488},"0.12-C.1 preserva a funcionalidade 0.12-C, fecha sem mutação física/storage durante a suíte e publica 488/488."] call _assert;
private _displayEnd=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD; if (!isNull _displayEnd) then {closeDialog 0; uiSleep 0.03;};
[_productionBefore] call ServoPeregrino_Organizador_Items_fnc_restoreProductionRepositorySnapshot; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap]; [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
private _durationMs=round ((diag_tickTime-_startedAt)*1000);
private _summary=createHashMapFromArray [["delivery","0.12-C.1"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],["base",_base],["baseExpected",478],["checkpointFirstGate",479],["checkpointLastGate",488],["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],["cumulativeExpected",488],["cumulativePassed",478+_passed],["durationMs",_durationMs],["catalogContinuousList",true],["equipmentDeleteImmediate",true]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================"; diag_log format ["[SP_ORG] [ITEMS] 0.12-C.1 — BASE=478/478  0.12-C=%1/10  FAIL=%2  CUMULATIVO=%3/488  TEMPO=%4ms",_passed,_failed,478+_passed,_durationMs]; diag_log "[SP_ORG] [ITEMS] 0.12-C.1 — Manual: lista contínua, ← Draft, → físico, slider/wheel e X Equipment sem confirmação."; diag_log "============================================================";
if (hasInterface) then {hint parseText format ["<t size='1.25'>SP_ORG_Items 0.12-C.1</t><br/><br/>Baseline 0.12-B: <t color='#7CFC00'>478 / 478</t><br/>0.12-C: <t color='%1'>%2 / 10</t><br/>Cumulativo: %3 / 488<br/><br/>%4",if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_passed,478+_passed,if (_failed isEqualTo 0) then {"Valide lista contínua, ações ←/→ e X imediato no Equipment."} else {"Consulte o primeiro FAIL no RPT."}];};
_summary
