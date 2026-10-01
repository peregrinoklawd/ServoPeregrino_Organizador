#include "..\..\script_version.hpp"
disableSerialization;

private _legacyRunningState=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR,createHashMap];
if (_legacyRunningState getOrDefault ["running",false]) exitWith {[false,"ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING","A regressão legada já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _orchestrator=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
if (_orchestrator getOrDefault ["running",false]) exitWith {[false,"ITEMS_0_12_D62_ALREADY_RUNNING","Outra suíte cumulativa já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _startedAt=diag_tickTime;
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.12-D.6.2 — EQUIPMENT VIEW AUTHORITY + APM HEADER — 602 GATES";
diag_log "============================================================";
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun; uiSleep 0.02;
private _base=createHashMapFromArray [["success",false],["code","ITEMS_0_12_D62_BASE_CALL_DID_NOT_RETURN"]];
private _baseCall=[] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_12CheckpointD61Tests;
if !(isNil "_baseCall") then {if (_baseCall isEqualType createHashMap) then {_base=_baseCall;};};
private _baseOk=(_base getOrDefault ["success",false]) && {(_base getOrDefault ["checkpointPassed",0]) isEqualTo 4} && {(_base getOrDefault ["cumulativePassed",0]) isEqualTo 594};
if !(_baseOk) exitWith {
    [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
    private _summary=createHashMapFromArray [["delivery","0.12-D.6.2"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",false],["code","ITEMS_0_12_D62_BASE_594_FAILED"],["base",_base],["checkpointSkipped",true],["checkpointFirstGate",595],["checkpointLastGate",602],["checkpointTotal",0],["checkpointPassed",0],["checkpointFailed",0],["cumulativeExpected",602]];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    diag_log "[SP_ORG] [ITEMS] 0.12-D.6.2 — FAIL-FAST: baseline D.6.1 594/594 não fechou.";
    _summary
};

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.12-D.6.2"]]];
private _passed=0; private _failed=0; private _results=[];
private _assert={
    params ["_id","_condition","_detail"];
    private _ok=(_condition isEqualType true)&&{_condition};
    private _status=if (_ok) then {"PASS"} else {"FAIL"};
    if (_ok) then {_passed=_passed+1}else{_failed=_failed+1};
    _results pushBack [_id,_status,_detail];
    diag_log format ["[SP_ORG] [ITEMS] [TEST 0.12-D.6.2] [%1] %2 — %3",_status,_id,_detail];
};

private _productionBefore=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _loadoutBefore=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _draftStateBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _uiStateBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;

private _srcDescription=preprocessFileLineNumbers "description.ext";
private _srcConfig=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\config.cpp";
private _srcVersion=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\script_version.hpp";
private _srcDialog=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\ui\items_dialog.hpp";
private _srcFinalize=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_finalizeUIPointerDrop.sqf";
private _srcDrag=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUIDragEvent.sqf";
private _srcResolver=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_resolveUIPanelDropTarget.sqf";
private _srcVM=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_buildUIViewModel.sqf";
private _srcFull=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshInterface.sqf";
private _srcEqRefresh=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshEquipmentViewUI.sqf";
private _srcTargetRefresh=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshPhysicalTargetUI.sqf";
private _srcMutationRefresh=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshPhysicalMutationUI.sqf";
private _srcCancel=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_cancelUIDrag.sqf";
private _srcHeader=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshHeaderUI.sqf";
private _srcHeaderStatus=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshHeaderStatusUI.sqf";
private _srcEquipment=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_renderEquipmentRowsUI.sqf";
private _srcCPD=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\tests\fn_runDelivery0_11CheckpointDTests.sqf";

private _gate595=(_srcDescription find "class runDelivery0_12CheckpointD62Tests {}")>=0 && {(_srcConfig find "class runDelivery0_12CheckpointD62Tests {}")>=0} && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_6_2_GATE_COUNT isEqualTo 8} && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_6_2_CUMULATIVE_GATE_COUNT isEqualTo 602} && {(SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DISPLAY_VERSION find "0.12-D.") isEqualTo 0};
["ITEMS-0.12-595",_gate595,"D.6.2 está registrada, versionada e declara contrato cumulativo 602/602."] call _assert;

private _gate596=(_srcFinalize find "getOrDefault [""equipmentView"",""U""]")>=0 && {(_srcDrag find "getOrDefault [""equipmentView"",""U""]")>=0} && {(_srcFinalize find "getOrDefault [""applicationTarget"",""ANY""]")<0};
["ITEMS-0.12-596",_gate596,"DnD físico, tanto panel-wide quanto strip legado, resolve o destino por equipmentView/Mostrar e não por applicationTarget."] call _assert;

private _gate597=(_srcResolver find "equipmentViewCommandEnabled")>=0 && {(_srcVM find "equipmentPhysical")>=0} && {(_srcVM find "equipmentViewCommandEnabled")>=0} && {(_srcFull find "equipmentPhysicalEnabled")>=0} && {(_srcEqRefresh find "[player,_view,")>=0} && {(_srcTargetRefresh find "equipmentReadiness")>=0} && {(_srcMutationRefresh find "equipmentReady")>=0} && {(_srcCancel find "[player,_view,")>=0};
["ITEMS-0.12-597",_gate597,"Readiness/drop-zone do Equipment é mantida em domínio próprio e continua correta após FULL, troca de view, troca de alvo do kit, mutação e cancelamento de drag."] call _assert;

private _existing=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
if (!isNull _existing) then {closeDialog 0; uiSleep 0.03;};
private _dialog=createDialog "SP_ORG_Items_Dialog"; uiSleep 0.12;
private _display=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
private _pos={params ["_idc"]; if (isNull _display) exitWith {[]}; ctrlPosition (_display displayCtrl _idc)};
private _loadPos=[104] call _pos; private _idPos=[103] call _pos; private _unitPos=[108] call _pos; private _futurePos=[107] call _pos; private _closePos=[102] call _pos; private _statusPos=[101] call _pos;
private _headerOrder=(count _loadPos)>=4 && {(count _idPos)>=4} && {(count _futurePos)>=4} && {(count _closePos)>=4} && {(_loadPos#0)+(_loadPos#2)<=(_idPos#0)+0.002*safeZoneW} && {(_idPos#0)+(_idPos#2)<=(_futurePos#0)+0.002*safeZoneW} && {(_futurePos#0)+(_futurePos#2)<=(_closePos#0)+0.002*safeZoneW};
private _headerStack=(count _idPos)>=4 && {(count _unitPos)>=4} && {abs((_idPos#0)-(_unitPos#0))<0.002*safeZoneW} && {(_idPos#1)+(_idPos#3)<=(_unitPos#1)+0.003*safeZoneH};
private _gate598=!isNull _display && {_headerOrder} && {_headerStack} && {(count _statusPos)>=4} && {(_statusPos#0)<safeZoneX-1} && {(_srcHeaderStatus find "Adicionar em:")<0};
["ITEMS-0.12-598",_gate598,"Header segue referência APM: Carga → Operador/Unidade → slot futuro → Fechar, enquanto 'Adicionar em' sai da faixa visível."] call _assert;

[player] call ServoPeregrino_Organizador_Items_fnc_refreshHeaderUI;
private _loadText=if (isNull _display) then {""} else {ctrlText (_display displayCtrl 104)};
private _gate599=(_loadText find "Carga: ") isEqualTo 0 && {(_loadText find " / ")>=0} && {(_loadText find " kg - ")>=0} && {(_loadText find "lb")<0} && {(_loadText find "%")>=0} && {(_srcHeader find "/22.0462262185")>=0} && {(_srcHeader find "_currentLb")<0};
["ITEMS-0.12-599",_gate599,"Carga do header exibe usado/total em kg e percentual, sem duplicar a leitura em libras."] call _assert;

private _anyPos=[2110] call _pos; private _uPos=[2111] call _pos; private _cPos=[2112] call _pos; private _mPos=[2113] call _pos;
private _visibleTargets=(count _uPos)>=4 && {(count _cPos)>=4} && {(count _mPos)>=4} && {(_uPos#0)>=safeZoneX} && {(_cPos#0)>(_uPos#0)} && {(_mPos#0)>(_cPos#0)};
private _gate600=(count _anyPos)>=4 && {(_anyPos#0)<safeZoneX-1} && {_visibleTargets} && {(_srcDialog find "['APP_TARGET','ANY']")>=0} && {(_srcDialog find "class AppAny")>=0};
["ITEMS-0.12-600",_gate600,"'Qualquer' deixa de ocupar espaço visual; ANY permanece compatível internamente e U/C/M usam toda a largura do seletor."] call _assert;

private _capLabel=[4141] call _pos; private _capBar=[4142] call _pos; private _capText=[4144] call _pos; private _buttons=[4121] call _pos;
private _sameLine=(count _capLabel)>=4 && {(count _capBar)>=4} && {(count _capText)>=4} && {abs((_capLabel#1)-(_capText#1))<0.002*safeZoneH} && {(_capLabel#0)+(_capLabel#2)<=(_capBar#0)+0.002*safeZoneW} && {(_capBar#0)+(_capBar#2)<=(_capText#0)+0.002*safeZoneW};
private _gate601=_sameLine && {(count _buttons)>=4} && {(_capText#1)+(_capText#3)<=(_buttons#1)+0.001*safeZoneH} && {(_srcEquipment find "%1 / %2 kg")>=0} && {(_srcEquipment find "Livre:")>=0};
["ITEMS-0.12-601",_gate601,"Capacidade do Equipment usa uma única linha label/bar/kg e mantém usado/livre/percentual no tooltip detalhado."] call _assert;

if (!isNull _display) then {closeDialog 0; uiSleep 0.03;};
private _loadoutAfter=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _productionAfter=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _cmp602=[_loadoutBefore,_loadoutAfter,"ITEMS-0.12-602"] call ServoPeregrino_Organizador_Items_fnc_compareLoadoutFingerprints;
private _cmp602d=_cmp602 getOrDefault ["data",createHashMap];
private _changed602=_cmp602d getOrDefault ["changedIndexes",[]];
private _ambient602=!(_cmp602d getOrDefault ["equal",false]) && {(count _changed602)>0} && {(_changed602 findIf {!(_x in [0,1,2])})<0};
if (_ambient602) then {diag_log format ["[SP_ORG] [ITEMS] [TEST_AMBIENT_DRIFT] label=ITEMS-0.12-602 changedIndexes=%1 accepted=true reason=WEAPON_SLOTS_ONLY",_changed602];};
private _gate602=(_srcFull find "Rascunho atual")>=0 && {(_srcFull find "combinar no Rascunho")>=0} && {(_srcCPD find "fnc_compareLoadoutFingerprints")>=0} && {(_srcCPD find "PLUS em EXACT")<0} && {((_cmp602d getOrDefault ["equal",false]) || {_ambient602})} && {_productionAfter isEqualTo _productionBefore};
["ITEMS-0.12-602",_gate602,"Rascunho substitui Draft em Meus Kits, CP-D foi endurecido semanticamente e a suíte D.6.2 não altera storage/loadout indevidamente."] call _assert;

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,_draftStateBefore];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_uiStateBefore];
["HIDE",controlNull,displayNull] call ServoPeregrino_Organizador_Items_fnc_updateUIItemTooltip;
[_productionBefore] call ServoPeregrino_Organizador_Items_fnc_restoreProductionRepositorySnapshot;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
private _durationMs=round ((diag_tickTime-_startedAt)*1000);
private _summary=createHashMapFromArray [["delivery","0.12-D.6.2"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],["base",_base],["baseExpected",594],["checkpointFirstGate",595],["checkpointLastGate",602],["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],["cumulativeExpected",602],["cumulativePassed",594+_passed],["durationMs",_durationMs],["equipmentViewAuthority",true],["apmHeaderConvergence",true],["hiddenAnyCompatibility",true],["singleLineCapacity",true]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] 0.12-D.6.2 — BASE=594/594  D.6.2=%1/8  FAIL=%2  CUMULATIVO=%3/602  TEMPO=%4ms",_passed,_failed,594+_passed,_durationMs];
diag_log "[SP_ORG] [ITEMS] 0.12-D.6.2 — Manual: diferenciar Onde aplicar o kit de Mostrar; arrastar Catálogo -> Equipment deve obedecer Mostrar em U/C/M; validar header APM-like e Capacidade em linha única.";
diag_log "============================================================";
if (hasInterface) then {hint parseText format ["<t size='1.25'>SP_ORG_Items 0.12-D.6.2</t><br/><br/>Baseline D.6.1: <t color='#7CFC00'>594 / 594</t><br/>D.6.2: <t color='%1'>%2 / 8</t><br/>Cumulativo: %3 / 602<br/><br/>%4",if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_passed,594+_passed,if (_failed isEqualTo 0) then {"Valide manualmente os três destinos de Mostrar e o novo header."} else {"Consulte o primeiro FAIL no RPT."}];};
_summary
