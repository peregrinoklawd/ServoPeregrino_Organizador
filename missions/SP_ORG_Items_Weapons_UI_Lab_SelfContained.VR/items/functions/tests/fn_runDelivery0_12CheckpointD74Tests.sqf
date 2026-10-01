#include "..\..\script_version.hpp"
disableSerialization;

private _legacyRunningState=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR,createHashMap];
if (_legacyRunningState getOrDefault ["running",false]) exitWith {[false,"ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING","A regressão legada já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _orchestrator=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
if (_orchestrator getOrDefault ["running",false]) exitWith {[false,"ITEMS_0_12_D74_ALREADY_RUNNING","Outra suíte cumulativa já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _startedAt=diag_tickTime;
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.12-D.7.4 — PLAYER LOAD SEMANTICS + HISTORICAL GATE HARDENING — 654 GATES";
diag_log "============================================================";
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun; uiSleep 0.02;
private _base=createHashMapFromArray [["success",false],["code","ITEMS_0_12_D74_BASE_CALL_DID_NOT_RETURN"]];
private _baseCall=[] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_12CheckpointD73Tests;
if !(isNil "_baseCall") then {if (_baseCall isEqualType createHashMap) then {_base=_baseCall;};};
private _baseOk=(_base getOrDefault ["success",false]) && {(_base getOrDefault ["checkpointPassed",0]) isEqualTo 8} && {(_base getOrDefault ["cumulativePassed",0]) isEqualTo 646};
if !(_baseOk) exitWith {
    [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
    private _summary=createHashMapFromArray [["delivery","0.12-D.7.4"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",false],["code","ITEMS_0_12_D74_BASE_646_FAILED"],["base",_base],["checkpointSkipped",true],["checkpointFirstGate",647],["checkpointLastGate",654],["checkpointTotal",0],["checkpointPassed",0],["checkpointFailed",0],["cumulativeExpected",654]];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    diag_log "[SP_ORG] [ITEMS] 0.12-D.7.4 — FAIL-FAST: baseline D.7.3 646/646 não fechou.";
    _summary
};

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.12-D.7.4"]]];
private _passed=0; private _failed=0; private _results=[];
private _assert={params ["_id","_condition","_detail"]; private _ok=(_condition isEqualType true)&&{_condition}; private _status=if (_ok) then {"PASS"} else {"FAIL"}; if (_ok) then {_passed=_passed+1}else{_failed=_failed+1}; _results pushBack [_id,_status,_detail]; diag_log format ["[SP_ORG] [ITEMS] [TEST 0.12-D.7.4] [%1] %2 — %3",_status,_id,_detail];};

private _productionBefore=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _loadoutBefore=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _draftBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _uiBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _publicBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VAR,[]]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _catalogBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_CACHE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _projectionBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_PROJECTION_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;

private _srcDesc=preprocessFileLineNumbers "description.ext";
private _srcCfg=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\config.cpp";
private _srcHeader=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshHeaderUI.sqf";
private _srcContainerCapacity=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\inventory\fn_getContainerCapacityMetrics.sqf";
private _srcDialog=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\ui\items_dialog.hpp";
private _srcC4=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\tests\fn_runDelivery0_12CheckpointC4Tests.sqf";
private _srcD71=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\tests\fn_runDelivery0_12CheckpointD71Tests.sqf";
private _srcD72=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\tests\fn_runDelivery0_12CheckpointD72Tests.sqf";
private _srcD73=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\tests\fn_runDelivery0_12CheckpointD73Tests.sqf";

// 647 — registro/versionamento e continuidade cumulativa.
private _gate647=(_srcDesc find "class runDelivery0_12CheckpointD74Tests {}")>=0
    && {(_srcCfg find "class runDelivery0_12CheckpointD74Tests {}")>=0}
    && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_7_4_GATE_COUNT isEqualTo 8}
    && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_7_4_CUMULATIVE_GATE_COUNT isEqualTo 654}
    && {(SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DISPLAY_VERSION in ["0.12-D.7.4","0.12 FINAL"]) || {(SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DISPLAY_VERSION find "0.13-") isEqualTo 0}}
    && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_SEMANTIC_VERSION in ["0.12.0.27","0.12.0.28","0.13.0.1"]};
["ITEMS-0.12-647",_gate647,"D.7.4, 0.12 FINAL ou sucessora 0.13.x está registrada sem renumerar gates anteriores; o contrato histórico permanece reconhecido."] call _assert;

// 648 — o gate histórico C.4 valida o contrato atual, não a UI antiga com ▲/▼ visíveis.
private _gate648=(_srcC4 find "CatalogScrollUp: SPORG_Items_IconButton")>=0
    && {(_srcC4 find "x=safeZoneX-10")>=0}
    && {(_srcC4 find "legacyButtonsOffscreen")>=0}
    && {(_srcC4 find "wheel + slider")>=0}
    && {(_srcC4 find "Subir 6 itens na lista contínua")<0}
    && {(_srcDialog find "class CatalogScroll: SPORG_Items_VSlider")>=0};
["ITEMS-0.12-648",_gate648,"Historical Gate Hardening: C.4 protege wheel + slider único visível e aceita ▲/▼ legados fora da viewport, alinhado ao contrato D.6+."] call _assert;

// 649 — carga global segue a semântica nativa do UNIT; clamp existe somente para a largura visual.
private _gate649=(_srcHeader find "loadAbs _unit")>=0
    && {(_srcHeader find "load _unit")>=0}
    && {(_srcHeader find "maxSoldierLoad")>=0}
    && {(_srcHeader find "private _rawFraction")>=0}
    && {(_srcHeader find "private _visualFraction=(_rawFraction min 1) max 0")>=0}
    && {(_srcHeader find "private _rawPercent=round (_rawFraction*100)")>=0}
    && {(_srcHeader find "private _overloaded=(_rawFraction>1.0005)")>=0};
["ITEMS-0.12-649",_gate649,"Player Load Semantics separa ratio bruto da fração visual: loadAbs/maxSoldierLoad permanece autoritativo e só a barra é limitada a 100% de largura."] call _assert;

// 650 — apresentação normal e de sobrecarga são explícitas; não existe falso 100% silencioso.
private _gate650=(_srcHeader find "Carga: %1 / %2 kg - %3%%")>=0
    && {(_srcHeader find "100%%+ · SOBRECARGA")>=0}
    && {(_srcHeader find "private _excessLoad")>=0}
    && {(_srcHeader find "O Arma pode exceder o limite quando scripts/mods inserem carga diretamente")>=0};
["ITEMS-0.12-650",_gate650,"Header mantém percentual normal até o limite; acima dele mostra 100%+ · SOBRECARGA e calcula o excesso real em vez de mascará-lo com clamp semântico."] call _assert;

// 651 — smoke runtime do texto/barra para o loadout real do jogador, funcionando tanto normal quanto sobrecarregado.
private _existing=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
if (!isNull _existing) then {closeDialog 0; uiSleep 0.03;};
private _dialog=createDialog "SP_ORG_Items_Dialog"; uiSleep 0.08;
private _display=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
if (!isNull _display) then {[player] call ServoPeregrino_Organizador_Items_fnc_refreshHeaderUI; uiSleep 0.02;};
private _current=(loadAbs player) max 0;
private _maxLoad=(getNumber (configFile >> "CfgInventoryGlobalVariable" >> "maxSoldierLoad")) max 0;
private _ratio=if (_maxLoad>0) then {_current/_maxLoad} else {(load player) max 0};
private _rawPercent=round ((_ratio max 0)*100);
private _overloaded=_ratio>1.0005;
private _loadText=if (isNull _display) then {""} else {ctrlText (_display displayCtrl 104)};
private _runtimeSemanticOk=if (_overloaded) then {
    (_loadText find "100%+")>=0 && {(_loadText find "SOBRECARGA")>=0}
} else {
    (_loadText find (format ["%1%%",_rawPercent]))>=0 && {(_loadText find "SOBRECARGA")<0}
};
private _gate651=_dialog && {!isNull _display} && {(_loadText find "Carga: ") isEqualTo 0} && {(_loadText find "kg")>=0} && {(_loadText find "lb")<0} && {_runtimeSemanticOk};
["ITEMS-0.12-651",_gate651,"Smoke runtime: o header representa coerentemente o loadout real, usando percentual normal ou marcador explícito de sobrecarga conforme o estado do engine."] call _assert;

// 652 — a barra não ultrapassa fisicamente seu trilho mesmo quando o ratio semântico é > 1.
private _bg=if (isNull _display) then {controlNull} else {_display displayCtrl 105};
private _fill=if (isNull _display) then {controlNull} else {_display displayCtrl 106};
private _bgPos=if (isNull _bg) then {[]} else {ctrlPosition _bg};
private _fillPos=if (isNull _fill) then {[]} else {ctrlPosition _fill};
private _expectedFraction=((_ratio max 0) min 1);
private _barOk=(count _bgPos)>=4 && {(count _fillPos)>=4} && {(_fillPos#2)>=0} && {(_fillPos#2)<=(_bgPos#2)+0.0005} && {abs((_fillPos#2)-((_bgPos#2)*_expectedFraction))<0.002*safeZoneW};
["ITEMS-0.12-652",_barOk,"A barra usa somente a fração visual clampada; sobrecarga é informada no texto/tooltip sem desenhar além do trilho."] call _assert;

// 653 — scope da carga e gates D.7.x ficam semanticamente explícitos/future-proof.
private _gate653=(_srcHeader find "Inclui armas, itens vinculados e conteúdo de Uniforme/Colete/Mochila")>=0
    && {(_srcContainerCapacity find "loadAbs _container")>=0}
    && {(_srcContainerCapacity find "maximumLoad")>=0}
    && {(_srcD71 find "DISPLAY_VERSION find")>=0} && {(_srcD71 find "0.12-D.7.")>=0}
    && {(_srcD72 find "DISPLAY_VERSION find")>=0} && {(_srcD72 find "0.12-D.7.")>=0}
    && {(_srcD73 find "DISPLAY_VERSION find")>=0} && {(_srcD73 find "0.12-D.7.")>=0};
["ITEMS-0.12-653",_gate653,"Carga global deixa claro que inclui armas/itens vinculados/conteúdo U-C-M, enquanto capacidade por container continua separada; runners D.7.x não congelam versão intermediária."] call _assert;

// 654 — D.7.4 é leitura/apresentação + hardening: restaura estado e não deixa mutação física/persistente.
private _displayEnd=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
if (!isNull _displayEnd) then {closeDialog 0; uiSleep 0.03;};
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VAR,_publicBefore];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,_draftBefore];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_uiBefore];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_CACHE_VAR,_catalogBefore];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_PROJECTION_VAR,_projectionBefore];
[_productionBefore] call ServoPeregrino_Organizador_Items_fnc_restoreProductionRepositorySnapshot;
private _loadoutAfter=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _productionAfter=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _cmp=[_loadoutBefore,_loadoutAfter,"ITEMS-0.12-654"] call ServoPeregrino_Organizador_Items_fnc_compareLoadoutFingerprints;
private _cmpD=_cmp getOrDefault ["data",createHashMap];
private _changed=_cmpD getOrDefault ["changedIndexes",[]];
private _ambient=!(_cmpD getOrDefault ["equal",false]) && {(count _changed)>0} && {(_changed findIf {!(_x in [0,1,2])})<0};
if (_ambient) then {diag_log format ["[SP_ORG] [ITEMS] [TEST_AMBIENT_DRIFT] label=ITEMS-0.12-654 changedIndexes=%1 accepted=true reason=WEAPON_SLOTS_ONLY",_changed];};
private _gate654=((_cmpD getOrDefault ["equal",false]) || {_ambient})
    && {_productionAfter isEqualTo _productionBefore}
    && {(missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VAR,[]]) isEqualTo _publicBefore}
    && {(missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_CACHE_VAR,createHashMap]) isEqualTo _catalogBefore};
["ITEMS-0.12-654",_gate654,"D.7.4 preserva loadout, Repository, biblioteca e Catálogo: mudança restrita à leitura/apresentação da carga e hardening de testes históricos."] call _assert;

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
private _durationMs=round ((diag_tickTime-_startedAt)*1000);
private _summary=createHashMapFromArray [["delivery","0.12-D.7.4"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],["base",_base],["baseExpected",646],["checkpointFirstGate",647],["checkpointLastGate",654],["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],["cumulativeExpected",654],["cumulativePassed",646+_passed],["durationMs",_durationMs],["playerLoadSemantics",true],["overloadExplicit",true],["visualLoadBarClamped",true],["historicalCatalogGateHardened",true],["d7VersionGatesFutureProof",true]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] 0.12-D.7.4 — BASE=646/646  D.7.4=%1/8  FAIL=%2  CUMULATIVO=%3/654  TEMPO=%4ms",_passed,_failed,646+_passed,_durationMs];
diag_log "[SP_ORG] [ITEMS] 0.12-D.7.4 — Manual: validar Carga normal/sobrecarga; wheel+slider do Catálogo; DnD/ghost; setas; Equipment; biblioteca/áudio sem regressão.";
diag_log "============================================================";
if (hasInterface) then {hint parseText format ["<t size='1.25'>SP_ORG_Items 0.12-D.7.4</t><br/><br/>Baseline D.7.3: <t color='#7CFC00'>646 / 646</t><br/>D.7.4: <t color='%1'>%2 / 8</t><br/>Cumulativo: %3 / 654<br/><br/>%4",if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_passed,646+_passed,if (_failed isEqualTo 0) then {"Valide carga normal/sobrecarga e um smoke curto das funções preservadas."} else {"Consulte o primeiro FAIL no RPT."}];};
_summary
