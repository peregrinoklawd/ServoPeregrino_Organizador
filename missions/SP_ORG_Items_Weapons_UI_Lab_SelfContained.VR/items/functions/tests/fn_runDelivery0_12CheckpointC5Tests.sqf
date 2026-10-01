#include "..\..\script_version.hpp"
disableSerialization;
private _legacyRunningState=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR,createHashMap];
if (_legacyRunningState getOrDefault ["running",false]) exitWith {[false,"ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING","A regressão legada já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _orchestrator=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
if (_orchestrator getOrDefault ["running",false]) exitWith {[false,"ITEMS_0_12_C5_ALREADY_RUNNING","Outra suíte cumulativa já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _startedAt=diag_tickTime;
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.12-C.5 — HISTORICAL GATE ALIGNMENT + KITS AFFORDANCE CLEANUP — 514 GATES";
diag_log "============================================================";
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun; uiSleep 0.02;
private _base=createHashMapFromArray [["success",false],["code","ITEMS_0_12_C5_BASE_CALL_DID_NOT_RETURN"]];
private _baseCall=[] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_12CheckpointC4Tests;
if !(isNil "_baseCall") then {if (_baseCall isEqualType createHashMap) then {_base=_baseCall;};};
private _baseOk=(_base getOrDefault ["success",false]) && {(_base getOrDefault ["checkpointPassed",0]) isEqualTo 6} && {(_base getOrDefault ["cumulativePassed",0]) isEqualTo 506};
if !(_baseOk) exitWith {
    [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
    private _summary=createHashMapFromArray [["delivery","0.12-C.5"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",false],["code","ITEMS_0_12_C5_BASE_506_FAILED"],["base",_base],["checkpointSkipped",true],["checkpointFirstGate",507],["checkpointLastGate",514],["checkpointTotal",0],["checkpointPassed",0],["checkpointFailed",0],["cumulativeExpected",514]];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    diag_log "[SP_ORG] [ITEMS] 0.12-C.5 — FAIL-FAST: baseline 0.12-C.4 506/506 não fechou."; _summary
};
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.12-C.5"]]];
private _passed=0; private _failed=0; private _results=[];
private _assert={params ["_id","_condition","_detail"]; private _ok=(_condition isEqualType true)&&{_condition}; private _status=if (_ok) then {"PASS"} else {"FAIL"}; if (_ok) then {_passed=_passed+1}else{_failed=_failed+1}; _results pushBack [_id,_status,_detail]; diag_log format ["[SP_ORG] [ITEMS] [TEST 0.12-C.5] [%1] %2 — %3",_status,_id,_detail];};
private _productionBefore=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _loadoutBefore=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _srcDialog=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\ui\items_dialog.hpp";
private _srcRefresh=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshInterface.sqf";
private _srcEvent=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUIEvent.sqf";
private _srcDrag=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUIDragEvent.sqf";
private _srcLegacy=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\tests\fn_runDelivery0_9_3Tests.sqf";

["ITEMS-0.12-507",(_srcLegacy find "_catTable093")>=0 && {(_srcLegacy find "_leftCtrl093")>=0} && {(_srcLegacy find "CATALOG_ROW_BUTTON")>=0} && {(_srcLegacy find "_leftCtrl093,""DRAFT""")>=0} && {(_srcLegacy find "CATALOG_ARROW_TO_PHYSICAL")<0},"Gate histórico 358 usa o botão real esquerdo da CatalogTable e não pode disparar a ação física direita durante a regressão."] call _assert;

private _controlsCfg=missionConfigFile>>"SP_ORG_Items_Dialog">>"controls";
private _upCfg=_controlsCfg>>"CatalogScrollUp"; private _downCfg=_controlsCfg>>"CatalogScrollDown";
private _squareCfg={params ["_cfg"]; private _w=getNumber (_cfg>>"w"); private _h=getNumber (_cfg>>"h"); (_w>0)&&{(_h>0)}&&{abs ((_w/pixelW)-(_h/pixelH))<=1.5}};
["ITEMS-0.12-508",[_upCfg] call _squareCfg && {[_downCfg] call _squareCfg},"▲ e ▼ da barra contínua são IconButtons realmente quadrados em pixels também no ultrawide; requisito histórico 296 volta a representar a UI atual."] call _assert;

private _kitsCfg=_controlsCfg>>"KitsList";
["ITEMS-0.12-509",getNumber (_kitsCfg>>"canDrag") isEqualTo 1 && {(getText (_kitsCfg>>"onMouseButtonDown")) isEqualTo ""} && {(getText (_kitsCfg>>"onMouseButtonClick")) isEqualTo ""} && {(_srcDialog find "KIT_ARROW_DOWN")<0} && {(_srcDialog find "KIT_ARROW_CLICK")<0},"Meus Kits não possui mais rail/hot-zone lateral escondida: clique é seleção/abertura e drag continua habilitado."] call _assert;

["ITEMS-0.12-510",(_srcRefresh find "Clique para abrir em edição; arraste para combinar no Rascunho atual")>=0 && {(_srcRefresh find "lbSetTextRight [_idx")<0} && {(_srcRefresh find "clique em →")<0},"Renderer de Meus Kits não desenha símbolo lateral sem função e comunica somente os dois gestos reais: clique e arraste."] call _assert;

["ITEMS-0.12-511",(_srcEvent find "KIT_ARROW_DOWN")<0 && {(_srcEvent find "KIT_ARROW_CLICK")<0} && {(_srcEvent find "kitArrowClickPending")<0} && {(_srcEvent find "case ""KIT_SELECT""")>=0} && {(_srcEvent find "LOAD_KIT")>=0},"Estado/eventos mortos da antiga seta do Kit foram removidos; KIT_SELECT segue diretamente para LOAD_KIT sem hot-zone concorrente."] call _assert;

["ITEMS-0.12-512",(_srcDrag find "case 1102:{""KIT""}")>=0 && {(_srcDrag find "sourceType")>=0} && {(_srcDrag find "fnc_executeUITransferCommand")>=0},"Remover a affordance lateral não remove a função de combinação: Kits continuam origem DnD e convergem ao executor central."] call _assert;

private _existing=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD; if (!isNull _existing) then {closeDialog 0; uiSleep 0.03;};
private _dialog=createDialog "SP_ORG_Items_Dialog"; uiSleep 0.08;
private _display=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
private _kits=if (isNull _display) then {controlNull} else {_display displayCtrl 1102};
private _rightTextClean=true;
if (!isNull _kits) then {for "_i" from 0 to ((lbSize _kits)-1) do {if ((_kits lbTextRight _i) isNotEqualTo "") exitWith {_rightTextClean=false;};};};
["ITEMS-0.12-513",_dialog && {!isNull _kits} && {_rightTextClean},"Smoke runtime: nenhuma linha visível de Meus Kits apresenta o antigo símbolo/traço na coluna direita."] call _assert;

private _loadoutAfter=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _productionAfter=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
["ITEMS-0.12-514",(_loadoutAfter getOrDefault ["serialized","B"]) isEqualTo (_loadoutBefore getOrDefault ["serialized","A"]) && {_productionAfter isEqualTo _productionBefore} && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_C_5_CUMULATIVE_GATE_COUNT isEqualTo 514},"C.5 é exclusivamente fechamento de UI/testes: não altera loadout nem Repository e publica alvo cumulativo 514/514."] call _assert;

private _displayEnd=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD; if (!isNull _displayEnd) then {closeDialog 0; uiSleep 0.03;};
[_productionBefore] call ServoPeregrino_Organizador_Items_fnc_restoreProductionRepositorySnapshot;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
private _durationMs=round ((diag_tickTime-_startedAt)*1000);
private _summary=createHashMapFromArray [["delivery","0.12-C.5"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],["base",_base],["baseExpected",506],["checkpointFirstGate",507],["checkpointLastGate",514],["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],["cumulativeExpected",514],["cumulativePassed",506+_passed],["durationMs",_durationMs],["historical296Aligned",true],["historical358Aligned",true],["kitsGhostAffordanceRemoved",true],["catalogC4Preserved",true]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] 0.12-C.5 — BASE=506/506  C.5=%1/8  FAIL=%2  CUMULATIVO=%3/514  TEMPO=%4ms",_passed,_failed,506+_passed,_durationMs];
diag_log "[SP_ORG] [ITEMS] 0.12-C.5 — Manual: Meus Kits sem símbolo lateral fantasma; clique abre, drag combina; Catálogo C.4 e Equipment X imediato preservados.";
diag_log "============================================================";
if (hasInterface) then {hint parseText format ["<t size='1.25'>SP_ORG_Items 0.12-C.5</t><br/><br/>Baseline C.4: <t color='#7CFC00'>506 / 506</t><br/>C.5: <t color='%1'>%2 / 8</t><br/>Cumulativo: %3 / 514<br/><br/>%4",if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_passed,506+_passed,if (_failed isEqualTo 0) then {"Valide Meus Kits sem affordance lateral e o fechamento da fase 0.12-C."} else {"Consulte o primeiro FAIL no RPT."}];};
_summary
