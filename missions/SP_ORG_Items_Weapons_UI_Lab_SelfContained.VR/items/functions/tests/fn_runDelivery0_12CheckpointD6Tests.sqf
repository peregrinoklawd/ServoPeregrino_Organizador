#include "..\..\script_version.hpp"
disableSerialization;

private _legacyRunningState=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR,createHashMap];
if (_legacyRunningState getOrDefault ["running",false]) exitWith {[false,"ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING","A regressão legada já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _orchestrator=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
if (_orchestrator getOrDefault ["running",false]) exitWith {[false,"ITEMS_0_12_D6_ALREADY_RUNNING","Outra suíte cumulativa já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _startedAt=diag_tickTime;
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.12-D.6 — UI COHESION + VANILLA WEIGHT POLISH — 590 GATES";
diag_log "============================================================";
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun; uiSleep 0.02;
private _base=createHashMapFromArray [["success",false],["code","ITEMS_0_12_D6_BASE_CALL_DID_NOT_RETURN"]];
private _baseCall=[] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_12CheckpointD5Tests;
if !(isNil "_baseCall") then {if (_baseCall isEqualType createHashMap) then {_base=_baseCall;};};
private _baseOk=(_base getOrDefault ["success",false]) && {(_base getOrDefault ["checkpointPassed",0]) isEqualTo 8} && {(_base getOrDefault ["cumulativePassed",0]) isEqualTo 580};
if !(_baseOk) exitWith {
    [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
    private _summary=createHashMapFromArray [["delivery","0.12-D.6"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",false],["code","ITEMS_0_12_D6_BASE_580_FAILED"],["base",_base],["checkpointSkipped",true],["checkpointFirstGate",581],["checkpointLastGate",590],["checkpointTotal",0],["checkpointPassed",0],["checkpointFailed",0],["cumulativeExpected",590]];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    diag_log "[SP_ORG] [ITEMS] 0.12-D.6 — FAIL-FAST: baseline D.5 580/580 não fechou.";
    _summary
};

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.12-D.6"]]];
private _passed=0; private _failed=0; private _results=[];
private _assert={
    params ["_id","_condition","_detail"];
    private _ok=(_condition isEqualType true)&&{_condition};
    private _status=if (_ok) then {"PASS"} else {"FAIL"};
    if (_ok) then {_passed=_passed+1}else{_failed=_failed+1};
    _results pushBack [_id,_status,_detail];
    diag_log format ["[SP_ORG] [ITEMS] [TEST 0.12-D.6] [%1] %2 — %3",_status,_id,_detail];
};

private _productionBefore=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _loadoutBefore=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _draftStateBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _uiStateBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;

private _srcDescription=preprocessFileLineNumbers "description.ext";
private _srcConfig=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\config.cpp";
private _srcVersion=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\script_version.hpp";
private _srcDialog=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\ui\items_dialog.hpp";
private _srcProxy=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_updateUIDragVisualProxy.sqf";
private _srcTooltip=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_updateUIItemTooltip.sqf";
private _srcFormatter=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_formatUIMass.sqf";
private _srcHeader=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshHeaderUI.sqf";
private _srcCatalog=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_renderCatalogRowsUI.sqf";
private _srcEquipment=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_renderEquipmentRowsUI.sqf";
private _srcDraft=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshDraftMutationUI.sqf";
private _srcD5=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\tests\fn_runDelivery0_12CheckpointD5Tests.sqf";
private _srcLegacy=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\tests\fn_runDelivery0_9_3Tests.sqf";
private _srcInstall=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\tests\fn_installTestActions.sqf";
private _srcInit=preprocessFileLineNumbers "initPlayerLocal.sqf";

private _gate581=(_srcDescription find "class runDelivery0_12CheckpointD6Tests {}")>=0 && {(_srcConfig find "class runDelivery0_12CheckpointD6Tests {}")>=0} && {(_srcConfig find "class formatUIMass {}")>=0} && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_6_GATE_COUNT isEqualTo 10} && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_6_CUMULATIVE_GATE_COUNT isEqualTo 590};
["ITEMS-0.12-581",_gate581,"D.6 está registrada, publica formatUIMass e declara contrato cumulativo 590/590."] call _assert;

private _d5SyntaxHardened=(_srcD5 find "private _gate574Code=")>=0 && {(_srcD5 find "private _gate574Summary=")>=0} && {(_srcD5 find "private _gate574Feedback=")>=0};
private _gate314Narrowed=(_srcLegacy find "private _segBefore083EnterR=")>=0 && {(_srcLegacy find "[_segBefore083Enter,_pFinalData083")>=0};
["ITEMS-0.12-582",_d5SyntaxHardened && {_gate314Narrowed},"Runner D.5 elimina a expressão frágil que gerava 'Faltante )' e gate 314 compara somente o intervalo estrito do Enter/Numpad Enter."] call _assert;

private _ghostAlphaOk=(_srcProxy find "ctrlSetBackgroundColor [0.012,0.030,0.032,0.72]")>=0;
private _tooltipGlassPreserved=(_srcTooltip find "ctrlSetBackgroundColor [0.012,0.026,0.028,0.58]")>=0;
["ITEMS-0.12-583",_ghostAlphaOk && {_tooltipGlassPreserved},"Ghost de DnD fica mais translúcido (0.72) sem alterar o glass do tooltip normal dos itens (0.58)."] call _assert;

private _existing=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
if (!isNull _existing) then {closeDialog 0; uiSleep 0.03;};
private _dialog=createDialog "SP_ORG_Items_Dialog"; uiSleep 0.12;
private _display=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
private _pos={params ["_idc"]; if (isNull _display) exitWith {[]}; ctrlPosition (_display displayCtrl _idc)};
private _after={params ["_a","_b"]; (count _a)>=4 && {(count _b)>=4} && {(_a#1)+(_a#3) <= (_b#1)+0.001*safeZoneH}};
private _targetLabel=[2105] call _pos; private _targetButtons=[2111] call _pos; private _actionLabel=[2106] call _pos; private _physicalButtons=[2150] call _pos;
private _gate584=!isNull _display && {[_targetLabel,_targetButtons] call _after} && {[_targetButtons,_actionLabel] call _after} && {[_actionLabel,_physicalButtons] call _after} && {(ctrlText (_display displayCtrl 2106)) isEqualTo "O que fazer no destino?"};
["ITEMS-0.12-584",_gate584,"Kit Selecionado separa rótulos e botões em quatro faixas sem sobreposição: destino, destinos, ação, ações físicas."] call _assert;

[player] call ServoPeregrino_Organizador_Items_fnc_refreshHeaderUI;
private _idPos=[103] call _pos; private _unitPos=[108] call _pos; private _futurePos=[107] call _pos; private _closePos=[102] call _pos; private _statusPos=[101] call _pos; private _loadPos=[104] call _pos; private _barPos=[105] call _pos;
private _rightOrder=(count _loadPos)>=4 && {(count _idPos)>=4} && {(count _futurePos)>=4} && {(count _closePos)>=4} && {(_loadPos#0)+(_loadPos#2)<=(_idPos#0)+0.002*safeZoneW} && {(_idPos#0)+(_idPos#2)<=(_futurePos#0)+0.002*safeZoneW} && {(_futurePos#0)+(_futurePos#2)<=(_closePos#0)+0.002*safeZoneW};
private _identityStack=(count _idPos)>=4 && {(count _unitPos)>=4} && {abs((_idPos#0)-(_unitPos#0))<0.002*safeZoneW} && {(_idPos#1)+(_idPos#3)<=(_unitPos#1)+0.003*safeZoneH};
private _statusHidden=(count _statusPos)>=4 && {(_statusPos#0)<safeZoneX-1};
private _loadText=if (isNull _display) then {""} else {ctrlText (_display displayCtrl 104)};
private _gate585=!isNull _display && {_rightOrder} && {_identityStack} && {_statusHidden} && {(count _barPos)>=4} && {(_loadText find "kg")>=0} && {(_loadText find "lb")<0};
["ITEMS-0.12-585",_gate585,"Header forma cluster APM-like à direita ancorado no Fechar e apresenta a linha de carga em kg."] call _assert;

private _upPos=[3121] call _pos; private _downPos=[3123] call _pos; private _sliderPos=[3124] call _pos; private _tablePos=[SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_TABLE_IDC] call _pos;
private _offscreen= (count _upPos)>=4 && {(count _downPos)>=4} && {(_upPos#0)<(safeZoneX-1)} && {(_downPos#0)<(safeZoneX-1)};
private _sliderFull=(count _sliderPos)>=4 && {(count _tablePos)>=4} && {abs((_sliderPos#1)-(_tablePos#1))<0.001*safeZoneH} && {abs((_sliderPos#3)-(_tablePos#3))<0.001*safeZoneH} && {ctrlShown (_display displayCtrl 3124)};
private _gate586=_offscreen && {_sliderFull};
["ITEMS-0.12-586",_gate586,"Opção A aplicada: botões quadrados ▲/▼ saem da área visível e a barra contínua ocupa toda a altura útil do Catálogo."] call _assert;

private _probeMetric=[220.462262185,true,2] call ServoPeregrino_Organizador_Items_fnc_formatUIMass;
private _probeCompact=[10,false,2] call ServoPeregrino_Organizador_Items_fnc_formatUIMass;
private _gate587=(_probeMetric isEqualTo "10.00 kg (22.05 lb)") && {_probeCompact isEqualTo "0.45 kg"} && {(_srcFormatter find "/22.0462262185")>=0} && {(_srcFormatter find "/10")>=0};
["ITEMS-0.12-587",_gate587,"Conversão player-facing valida 220.462262185u = 10.00 kg (22.05 lb) e 10u = 0.45 kg; massa interna permanece inalterada."] call _assert;

private _massSourcesOk=(_srcHeader find "fnc_formatUIMass")>=0 && {(_srcCatalog find "fnc_formatUIMass")>=0} && {(_srcEquipment find "fnc_formatUIMass")>=0} && {(_srcDraft find "fnc_formatUIMass")>=0};
private _oldVisibleUnits=(_srcHeader find "%1/%2u")>=0 || {(_srcCatalog find "%1u")>=0} || {(_srcEquipment find "%1u")>=0} || {(_srcDraft find "%1u")>=0};
private _gate588=_massSourcesOk && {!_oldVisibleUnits};
["ITEMS-0.12-588",_gate588,"Header, Catálogo, Kit e Equipamento usam o formatter de peso e não expõem mais a unidade técnica u nas superfícies principais."] call _assert;

private _gate589=(_srcInstall find "Esperado:")>=0 && {(_srcInstall find "runDelivery0_12CheckpointD")>=0} && {(_srcInit find "Suíte cumulativa:")>=0} && {(_srcInit find "kg/lb")>=0};
["ITEMS-0.12-589",_gate589,"Ações de teste/bootstrap permanecem alinhadas à entrega cumulativa ativa sem prender D.6 ao número da release mais nova."] call _assert;

if (!isNull _display) then {closeDialog 0; uiSleep 0.03;};
private _loadoutAfter=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _productionAfter=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _cmp590=[_loadoutBefore,_loadoutAfter,"ITEMS-0.12-590"] call ServoPeregrino_Organizador_Items_fnc_compareLoadoutFingerprints;
private _cmp590d=_cmp590 getOrDefault ["data",createHashMap];
private _changed590=_cmp590d getOrDefault ["changedIndexes",[]];
private _ambient590=!(_cmp590d getOrDefault ["equal",false]) && {(count _changed590)>0} && {(_changed590 findIf {!(_x in [0,1,2])})<0};
if (_ambient590) then {diag_log format ["[SP_ORG] [ITEMS] [TEST_AMBIENT_DRIFT] label=ITEMS-0.12-590 changedIndexes=%1 accepted=true reason=WEAPON_SLOTS_ONLY",_changed590];};
private _gate590=(SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_6_GATE_COUNT isEqualTo 10) && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_6_CUMULATIVE_GATE_COUNT isEqualTo 590} && {(_cmp590d getOrDefault ["equal",false]) || {_ambient590}} && {_productionAfter isEqualTo _productionBefore};
["ITEMS-0.12-590",_gate590,"D.6 permanece polish de UI/apresentação: sem mutação indevida de storage/loadout e contrato 590 consistente."] call _assert;

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,_draftStateBefore];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_uiStateBefore];
["HIDE",controlNull,displayNull] call ServoPeregrino_Organizador_Items_fnc_updateUIItemTooltip;
[_productionBefore] call ServoPeregrino_Organizador_Items_fnc_restoreProductionRepositorySnapshot;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
private _durationMs=round ((diag_tickTime-_startedAt)*1000);
private _summary=createHashMapFromArray [["delivery","0.12-D.6"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],["base",_base],["baseExpected",580],["checkpointFirstGate",581],["checkpointLastGate",590],["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],["cumulativeExpected",590],["cumulativePassed",580+_passed],["durationMs",_durationMs],["catalogNavigationSimplified",true],["vanillaWeightPresentation",true],["headerClusterRefined",true],["dragGhostOpacity",0.72],["manualUltrawideValidationRequired",true]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] 0.12-D.6 — BASE=580/580  D.6=%1/10  FAIL=%2  CUMULATIVO=%3/590  TEMPO=%4ms",_passed,_failed,580+_passed,_durationMs];
diag_log "[SP_ORG] [ITEMS] 0.12-D.6 — Manual: validar ghost translúcido; bloco de ações sem overlap; header compacto; Catálogo sem botões quadrados redundantes; pesos em kg/lb.";
diag_log "============================================================";
if (hasInterface) then {hint parseText format ["<t size='1.25'>SP_ORG_Items 0.12-D.6</t><br/><br/>Baseline D.5: <t color='#7CFC00'>580 / 580</t><br/>D.6: <t color='%1'>%2 / 10</t><br/>Cumulativo: %3 / 590<br/><br/>%4",if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_passed,580+_passed,if (_failed isEqualTo 0) then {"Valide visualmente o ghost, ações, header, navegação do Catálogo e kg/lb."} else {"Consulte o primeiro FAIL no RPT."}];};
_summary
