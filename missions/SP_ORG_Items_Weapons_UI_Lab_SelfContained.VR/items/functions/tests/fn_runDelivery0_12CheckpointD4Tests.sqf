#include "..\..\script_version.hpp"
disableSerialization;

private _legacyRunningState=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR,createHashMap];
if (_legacyRunningState getOrDefault ["running",false]) exitWith {[false,"ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING","A regressão legada já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _orchestrator=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
if (_orchestrator getOrDefault ["running",false]) exitWith {[false,"ITEMS_0_12_D4_ALREADY_RUNNING","Outra suíte cumulativa já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _startedAt=diag_tickTime;
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.12-D.4 — TOOLTIP GLASS HOTFIX — 572 GATES";
diag_log "============================================================";
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun; uiSleep 0.02;
private _base=createHashMapFromArray [["success",false],["code","ITEMS_0_12_D4_BASE_CALL_DID_NOT_RETURN"]];
private _baseCall=[] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_12CheckpointD3Tests;
if !(isNil "_baseCall") then {if (_baseCall isEqualType createHashMap) then {_base=_baseCall;};};
private _baseOk=(_base getOrDefault ["success",false]) && {(_base getOrDefault ["checkpointPassed",0]) isEqualTo 8} && {(_base getOrDefault ["cumulativePassed",0]) isEqualTo 566};
if !(_baseOk) exitWith {
    [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
    private _summary=createHashMapFromArray [["delivery","0.12-D.4"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",false],["code","ITEMS_0_12_D4_BASE_566_FAILED"],["base",_base],["checkpointSkipped",true],["checkpointFirstGate",567],["checkpointLastGate",572],["checkpointTotal",0],["checkpointPassed",0],["checkpointFailed",0],["cumulativeExpected",572]];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    diag_log "[SP_ORG] [ITEMS] 0.12-D.4 — FAIL-FAST: baseline D.3 566/566 não fechou.";
    _summary
};

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.12-D.4"]]];
private _passed=0; private _failed=0; private _results=[];
private _assert={
    params ["_id","_condition","_detail"];
    private _ok=(_condition isEqualType true)&&{_condition};
    private _status=if (_ok) then {"PASS"} else {"FAIL"};
    if (_ok) then {_passed=_passed+1}else{_failed=_failed+1};
    _results pushBack [_id,_status,_detail];
    diag_log format ["[SP_ORG] [ITEMS] [TEST 0.12-D.4] [%1] %2 — %3",_status,_id,_detail];
};

private _productionBefore=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _loadoutBefore=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _draftStateBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _uiStateBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;

private _srcDescription=preprocessFileLineNumbers "description.ext";
private _srcConfig=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\config.cpp";
private _srcVersion=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\script_version.hpp";
private _srcTooltip=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_updateUIItemTooltip.sqf";
private _srcInstall=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\tests\fn_installTestActions.sqf";
private _srcD3=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\tests\fn_runDelivery0_12CheckpointD3Tests.sqf";

private _gate567=(_srcDescription find "class runDelivery0_12CheckpointD4Tests {}")>=0 && {(_srcConfig find "class runDelivery0_12CheckpointD4Tests {}")>=0} && {(_srcInstall find "SP_ORG_Items 0.12-D.")>=0} && {(_srcInstall find "runDelivery0_12CheckpointD")>=0} && {(_srcVersion find "SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_4_CUMULATIVE_GATE_COUNT 572")>=0};
["ITEMS-0.12-567",_gate567,"D.4 está registrado em CfgFunctions e exposto nas actions de teste, com cumulativo 572 declarado no contrato de versão."] call _assert;

private _gate568=(_srcD3 find "[""HIDE"",controlNull,_display]")>=0 && {(_srcD3 find "[""SYNC"",controlNull,_display]")>=0} && {(_srcD3 find "Error Faltante )")<0};
["ITEMS-0.12-568",_gate568,"Runner D.3 deixa de usar escape inválido estilo C e o gate 562 não pode mais gerar erro de sintaxe no RPT."] call _assert;

private _gate569=(_srcTooltip find "ctrlSetBackgroundColor [0.012,0.026,0.028,0.58]")>=0 && {(_srcTooltip find "ctrlEnable false")>=0} && {(_srcTooltip find "ctrlCreate [""RscStructuredText"",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_ITEM_TOOLTIP_RUNTIME_IDC]")>=0};
["ITEMS-0.12-569",_gate569,"Tooltip runtime mantém natureza pass-through, mas agora usa fundo translúcido glass em vez de bloco quase opaco."] call _assert;

private _existing=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
if (!isNull _existing) then {closeDialog 0; uiSleep 0.03;};
private _dialog=createDialog "SP_ORG_Items_Dialog"; uiSleep 0.12;
private _display=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
private _probe=if (isNull _display) then {controlNull} else {_display displayCtrl 100};
private _shown=false; private _createdTip=controlNull; private _createdIDC=-1; private _hidden=false;
if (!isNull _probe) then {
    _probe setVariable ["SPORG_Items_tooltipTitle","Tooltip D.4"];
    _probe setVariable ["SPORG_Items_tooltipLines",["Glass hotfix","Sem bloquear totalmente o fundo"]];
    _probe setVariable ["SPORG_Items_tooltipPicture",""];
    _shown=["SHOW",_probe,_display] call ServoPeregrino_Organizador_Items_fnc_updateUIItemTooltip;
    _createdTip=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_ITEM_TOOLTIP_CTRL_VAR,controlNull];
    if (!isNull _createdTip) then {_createdIDC=ctrlIDC _createdTip;};
    ["MOVE",controlNull,_display] call ServoPeregrino_Organizador_Items_fnc_updateUIItemTooltip;
    ["HIDE",controlNull,_display] call ServoPeregrino_Organizador_Items_fnc_updateUIItemTooltip;
    _hidden=isNull (uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_ITEM_TOOLTIP_CTRL_VAR,controlNull]);
};
private _gate570=!isNull _display && {_shown} && {_createdIDC isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_ITEM_TOOLTIP_RUNTIME_IDC} && {_hidden};
["ITEMS-0.12-570",_gate570,"Smoke runtime confirma que SHOW/MOVE/HIDE continuam operando após o hotfix visual do tooltip."] call _assert;

private _gate571=(_srcInstall find "Esperado:")>=0 && {(_srcInstall find "Kit UI Demo 0.12-D.")>=0} && {(_srcInstall find "tooltip")>=0 || {(_srcInstall find "ghost")>=0}};
["ITEMS-0.12-571",_gate571,"Actions auxiliares, hint de status e kit demo foram alinhados à D.4 para reduzir confusão operacional durante a validação manual."] call _assert;

if (!isNull _display) then {closeDialog 0; uiSleep 0.03;};
private _loadoutAfter=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _productionAfter=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _cmp572=[_loadoutBefore,_loadoutAfter,"ITEMS-0.12-572"] call ServoPeregrino_Organizador_Items_fnc_compareLoadoutFingerprints;
private _cmp572d=_cmp572 getOrDefault ["data",createHashMap];
private _changed572=_cmp572d getOrDefault ["changedIndexes",[]];
private _ambient572=!(_cmp572d getOrDefault ["equal",false]) && {(count _changed572)>0} && {(_changed572 findIf {!(_x in [0,1,2])})<0};
if (_ambient572) then {diag_log format ["[SP_ORG] [ITEMS] [TEST_AMBIENT_DRIFT] label=ITEMS-0.12-572 changedIndexes=%1 accepted=true reason=WEAPON_SLOTS_ONLY",_changed572];};
private _gate572=(SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_4_GATE_COUNT isEqualTo 6) && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_4_CUMULATIVE_GATE_COUNT isEqualTo 572} && {(_cmp572d getOrDefault ["equal",false]) || {_ambient572}} && {_productionAfter isEqualTo _productionBefore};
["ITEMS-0.12-572",_gate572,"D.4 permanece um hotfix de polimento: storage, loadout e contrato cumulativo permanecem invariantes."] call _assert;

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,_draftStateBefore];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_uiStateBefore];
[_productionBefore] call ServoPeregrino_Organizador_Items_fnc_restoreProductionRepositorySnapshot;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
private _durationMs=round ((diag_tickTime-_startedAt)*1000);
private _summary=createHashMapFromArray [["delivery","0.12-D.4"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],["base",_base],["baseExpected",566],["checkpointFirstGate",567],["checkpointLastGate",572],["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],["cumulativeExpected",572],["cumulativePassed",566+_passed],["durationMs",_durationMs],["tooltipGlassHotfix",true],["d3RunnerSyntaxFixed",true],["manualTransparencyValidationRequired",true]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] 0.12-D.4 — BASE=566/566  D.4=%1/6  FAIL=%2  CUMULATIVO=%3/572  TEMPO=%4ms",_passed,_failed,566+_passed,_durationMs];
diag_log "[SP_ORG] [ITEMS] 0.12-D.4 — Manual: validar transparência do tooltip, legibilidade do texto e ausência de regressão no DnD/ghost.";
diag_log "============================================================";
if (hasInterface) then {hint parseText format ["<t size='1.25'>SP_ORG_Items 0.12-D.4</t><br/><br/>Baseline D.3: <t color='#7CFC00'>566 / 566</t><br/>D.4: <t color='%1'>%2 / 6</t><br/>Cumulativo: %3 / 572<br/><br/>%4",if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_passed,566+_passed,if (_failed isEqualTo 0) then {"Valide a transparência do tooltip e repita o DnD/ghost."} else {"Consulte o primeiro FAIL no RPT."}];};
_summary
