#include "..\..\script_version.hpp"
disableSerialization;

private _legacyRunningState=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR,createHashMap];
if (_legacyRunningState getOrDefault ["running",false]) exitWith {[false,"ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING","A regressão legada já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _orchestrator=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
if (_orchestrator getOrDefault ["running",false]) exitWith {[false,"ITEMS_0_12_D61_ALREADY_RUNNING","Outra suíte cumulativa já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _startedAt=diag_tickTime;
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.12-D.6.1 — CAPACITY READABILITY + REGRESSION CLOSE — 594 GATES";
diag_log "============================================================";
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun; uiSleep 0.02;
private _base=createHashMapFromArray [["success",false],["code","ITEMS_0_12_D61_BASE_CALL_DID_NOT_RETURN"]];
private _baseCall=[] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_12CheckpointD6Tests;
if !(isNil "_baseCall") then {if (_baseCall isEqualType createHashMap) then {_base=_baseCall;};};
private _baseOk=(_base getOrDefault ["success",false]) && {(_base getOrDefault ["checkpointPassed",0]) isEqualTo 10} && {(_base getOrDefault ["cumulativePassed",0]) isEqualTo 590};
if !(_baseOk) exitWith {
    [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
    private _summary=createHashMapFromArray [["delivery","0.12-D.6.1"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",false],["code","ITEMS_0_12_D61_BASE_590_FAILED"],["base",_base],["checkpointSkipped",true],["checkpointFirstGate",591],["checkpointLastGate",594],["checkpointTotal",0],["checkpointPassed",0],["checkpointFailed",0],["cumulativeExpected",594]];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    diag_log "[SP_ORG] [ITEMS] 0.12-D.6.1 — FAIL-FAST: baseline D.6 590/590 não fechou.";
    _summary
};

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.12-D.6.1"]]];
private _passed=0; private _failed=0; private _results=[];
private _assert={
    params ["_id","_condition","_detail"];
    private _ok=(_condition isEqualType true)&&{_condition};
    private _status=if (_ok) then {"PASS"} else {"FAIL"};
    if (_ok) then {_passed=_passed+1}else{_failed=_failed+1};
    _results pushBack [_id,_status,_detail];
    diag_log format ["[SP_ORG] [ITEMS] [TEST 0.12-D.6.1] [%1] %2 — %3",_status,_id,_detail];
};

private _productionBefore=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _loadoutBefore=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _draftStateBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _uiStateBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;

private _srcDescription=preprocessFileLineNumbers "description.ext";
private _srcConfig=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\config.cpp";
private _srcVersion=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\script_version.hpp";
private _srcDialog=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\ui\items_dialog.hpp";
private _srcCPB=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\tests\fn_runDelivery0_11CheckpointBTests.sqf";
private _srcD6=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\tests\fn_runDelivery0_12CheckpointD6Tests.sqf";

private _gate591=(_srcDescription find "class runDelivery0_12CheckpointD61Tests {}")>=0 && {(_srcConfig find "class runDelivery0_12CheckpointD61Tests {}")>=0} && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_6_1_GATE_COUNT isEqualTo 4} && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_6_1_CUMULATIVE_GATE_COUNT isEqualTo 594} && {(SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DISPLAY_VERSION find "0.12-D.") isEqualTo 0};
["ITEMS-0.12-591",_gate591,"D.6.1 está registrada e declara contrato cumulativo 594/594."] call _assert;

private _gate592=(_srcCPB find "actionCount")>=0 && {(_srcCPB find "TEST-408")>=0} && {(_srcCPB find "rollbackSucceeded")>=0} && {(_srcCPB find "TEST-411A")>=0} && {(_srcCPB find "estado focal restaurado")<0} && {(_srcD6 find "SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DISPLAY_VERSION")<0};
["ITEMS-0.12-592",_gate592,"Gates históricos 408/411 validam contrato semântico atual e D.6 não fica preso à string exata da própria versão."] call _assert;

private _existing=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
if (!isNull _existing) then {closeDialog 0; uiSleep 0.03;};
private _dialog=createDialog "SP_ORG_Items_Dialog"; uiSleep 0.12;
private _display=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
private _capacityLabelPos=if (isNull _display) then {[]} else {ctrlPosition (_display displayCtrl 4141)};
private _capacityBarPos=if (isNull _display) then {[]} else {ctrlPosition (_display displayCtrl 4142)};
private _capacityPos=if (isNull _display) then {[]} else {ctrlPosition (_display displayCtrl 4144)};
private _buttonsPos=if (isNull _display) then {[]} else {ctrlPosition (_display displayCtrl 4121)};
private _singleLine=(count _capacityLabelPos)>=4 && {(count _capacityBarPos)>=4} && {(count _capacityPos)>=4} && {abs((_capacityLabelPos#1)-(_capacityPos#1))<0.002*safeZoneH} && {(_capacityLabelPos#0)+(_capacityLabelPos#2)<=(_capacityBarPos#0)+0.002*safeZoneW} && {(_capacityBarPos#0)+(_capacityBarPos#2)<=(_capacityPos#0)+0.002*safeZoneW};
private _capacityReadable=(_srcDialog find "class EquipmentCapacityText")>=0 && {(_srcDialog find "sizeEx=0.0125*safeZoneH")>=0} && {(_srcDialog find "style=1; text=""n/d""")>=0};
private _noOverlap=(count _capacityPos)>=4 && {(count _buttonsPos)>=4} && {(_capacityPos#1)+(_capacityPos#3) <= (_buttonsPos#1)+0.001*safeZoneH};
private _gate593=!isNull _display && {_capacityReadable} && {_singleLine} && {_noOverlap};
["ITEMS-0.12-593",_gate593,"Capacidade permanece legível sem overlap e pode evoluir para a linha única label/bar/kg do layout APM-like."] call _assert;

if (!isNull _display) then {closeDialog 0; uiSleep 0.03;};
private _loadoutAfter=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _productionAfter=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _cmp594=[_loadoutBefore,_loadoutAfter,"ITEMS-0.12-594"] call ServoPeregrino_Organizador_Items_fnc_compareLoadoutFingerprints;
private _cmp594d=_cmp594 getOrDefault ["data",createHashMap];
private _changed594=_cmp594d getOrDefault ["changedIndexes",[]];
private _ambient594=!(_cmp594d getOrDefault ["equal",false]) && {(count _changed594)>0} && {(_changed594 findIf {!(_x in [0,1,2])})<0};
if (_ambient594) then {diag_log format ["[SP_ORG] [ITEMS] [TEST_AMBIENT_DRIFT] label=ITEMS-0.12-594 changedIndexes=%1 accepted=true reason=WEAPON_SLOTS_ONLY",_changed594];};
private _gate594=(SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_6_1_CUMULATIVE_GATE_COUNT isEqualTo 594) && {(_cmp594d getOrDefault ["equal",false]) || {_ambient594}} && {_productionAfter isEqualTo _productionBefore};
["ITEMS-0.12-594",_gate594,"D.6.1 permanece hotfix de UI/testes: storage e loadout não sofrem mutação indevida."] call _assert;

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,_draftStateBefore];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_uiStateBefore];
["HIDE",controlNull,displayNull] call ServoPeregrino_Organizador_Items_fnc_updateUIItemTooltip;
[_productionBefore] call ServoPeregrino_Organizador_Items_fnc_restoreProductionRepositorySnapshot;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
private _durationMs=round ((diag_tickTime-_startedAt)*1000);
private _summary=createHashMapFromArray [["delivery","0.12-D.6.1"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],["base",_base],["baseExpected",590],["checkpointFirstGate",591],["checkpointLastGate",594],["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],["cumulativeExpected",594],["cumulativePassed",590+_passed],["durationMs",_durationMs],["capacityReadabilityPolish",true],["historicalFeedbackGatesAligned",true]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] 0.12-D.6.1 — BASE=590/590  D.6.1=%1/4  FAIL=%2  CUMULATIVO=%3/594  TEMPO=%4ms",_passed,_failed,590+_passed,_durationMs];
diag_log "[SP_ORG] [ITEMS] 0.12-D.6.1 — Manual: confirmar leitura do texto usado/livre abaixo da barra de Capacidade; nenhuma outra mudança visual é intencional.";
diag_log "============================================================";
if (hasInterface) then {hint parseText format ["<t size='1.25'>SP_ORG_Items 0.12-D.6.1</t><br/><br/>Baseline D.6: <t color='#7CFC00'>590 / 590</t><br/>D.6.1: <t color='%1'>%2 / 4</t><br/>Cumulativo: %3 / 594<br/><br/>%4",if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_passed,590+_passed,if (_failed isEqualTo 0) then {"Valide visualmente apenas a leitura do texto de Capacidade."} else {"Consulte o primeiro FAIL no RPT."}];};
_summary
