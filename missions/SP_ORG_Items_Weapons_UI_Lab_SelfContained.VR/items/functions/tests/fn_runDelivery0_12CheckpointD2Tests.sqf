#include "..\..\script_version.hpp"
disableSerialization;

private _legacyRunningState=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR,createHashMap];
if (_legacyRunningState getOrDefault ["running",false]) exitWith {[false,"ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING","A regressão legada já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _orchestrator=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
if (_orchestrator getOrDefault ["running",false]) exitWith {[false,"ITEMS_0_12_D2_ALREADY_RUNNING","Outra suíte cumulativa já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _startedAt=diag_tickTime;
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.12-D.2 — HEADER LAYOUT + FRIENDLY LANGUAGE + RUNNER HARDENING — 558 GATES";
diag_log "============================================================";
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun; uiSleep 0.02;
private _base=createHashMapFromArray [["success",false],["code","ITEMS_0_12_D2_BASE_CALL_DID_NOT_RETURN"]];
private _baseCall=[] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_12CheckpointD1Tests;
if !(isNil "_baseCall") then {if (_baseCall isEqualType createHashMap) then {_base=_baseCall;};};
private _baseOk=(_base getOrDefault ["success",false]) && {(_base getOrDefault ["checkpointPassed",0]) isEqualTo 8} && {(_base getOrDefault ["cumulativePassed",0]) isEqualTo 550};
if !(_baseOk) exitWith {
    [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
    private _summary=createHashMapFromArray [["delivery","0.12-D.2"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",false],["code","ITEMS_0_12_D2_BASE_550_FAILED"],["base",_base],["checkpointSkipped",true],["checkpointFirstGate",551],["checkpointLastGate",558],["checkpointTotal",0],["checkpointPassed",0],["checkpointFailed",0],["cumulativeExpected",558]];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    diag_log "[SP_ORG] [ITEMS] 0.12-D.2 — FAIL-FAST: baseline D.1 550/550 não fechou.";
    _summary
};

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.12-D.2"]]];
private _passed=0; private _failed=0; private _results=[];
private _assert={
    params ["_id","_condition","_detail"];
    private _ok=(_condition isEqualType true)&&{_condition};
    private _status=if (_ok) then {"PASS"} else {"FAIL"};
    if (_ok) then {_passed=_passed+1}else{_failed=_failed+1};
    _results pushBack [_id,_status,_detail];
    diag_log format ["[SP_ORG] [ITEMS] [TEST 0.12-D.2] [%1] %2 — %3",_status,_id,_detail];
};

private _productionBefore=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _loadoutBefore=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _draftStateBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _uiStateBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;

private _srcDialog=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\ui\items_dialog.hpp";
private _srcHeader=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshHeaderUI.sqf";
private _srcStatus=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshHeaderStatusUI.sqf";
private _srcVM=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_buildUIViewModel.sqf";
private _srcDrag=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUIDragEvent.sqf";
private _srcCancel=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_cancelUIDrag.sqf";
private _srcOutcome=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_classifyUIOutcome.sqf";
private _srcLegacy=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\tests\fn_runDelivery0_9_3Tests.sqf";
private _srcProxy=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_updateUIDragVisualProxy.sqf";

private _gate551=(_srcDialog find "SP_ORG — ORGANIZADOR DE ITENS")>=0 && {(_srcDialog find "HeaderDivider")>=0} && {(_srcDialog find "Operador: -")>=0} && {(_srcDialog find "Unidade: -")>=0} && {(_srcDialog find "class HeaderStatus")>=0} && {(_srcDialog find "x=safeZoneX-2")>=0} && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_2_CUMULATIVE_GATE_COUNT isEqualTo 558};
["ITEMS-0.12-551",_gate551,"Estrutura histórica do header permanece registrada, com status redundante oculto e identidade/carga player-facing preservadas."] call _assert;

private _existing=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
if (!isNull _existing) then {closeDialog 0; uiSleep 0.03;};
private _dialog=createDialog "SP_ORG_Items_Dialog"; uiSleep 0.12;
private _display=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
private _headerControls=[100,103,108,107,102,101,104,105,106];
private _allHeaderPresent=!isNull _display && {(_headerControls findIf {isNull (_display displayCtrl _x)})<0};
private _pos={params ["_idc"]; if (isNull _display) exitWith {[]}; ctrlPosition (_display displayCtrl _idc)};
private _titlePos=[100] call _pos; private _statusPos=[101] call _pos; private _loadPos=[104] call _pos; private _barPos=[105] call _pos; private _idPos=[103] call _pos; private _unitPos=[108] call _pos; private _futurePos=[107] call _pos; private _closePos=[102] call _pos;
private _statusHidden=(count _statusPos)>=4 && {(_statusPos#0)<safeZoneX-1};
private _rightOrder=(count _loadPos)>=4 && {(count _idPos)>=4} && {(count _futurePos)>=4} && {(count _closePos)>=4} && {(_loadPos#0)+(_loadPos#2)<=(_idPos#0)+0.002*safeZoneW} && {(_idPos#0)+(_idPos#2)<=(_futurePos#0)+0.002*safeZoneW} && {(_futurePos#0)+(_futurePos#2)<=(_closePos#0)+0.002*safeZoneW};
private _stacked=(count _idPos)>=4 && {(count _unitPos)>=4} && {(_idPos#1)+(_idPos#3)<=(_unitPos#1)+0.003*safeZoneH};
private _gate552=_allHeaderPresent && {_statusHidden} && {_rightOrder} && {_stacked} && {(count _barPos)>=4} && {(_barPos#1)+(_barPos#3)<=safeZoneY+0.049*safeZoneH};
["ITEMS-0.12-552",_gate552,"Smoke runtime confirma header APM-like compacto e sem colisão; IDC histórico de status permanece oculto."] call _assert;

[player] call ServoPeregrino_Organizador_Items_fnc_refreshHeaderUI;
[_display,true,"U","C",createHashMapFromArray [["known",true],["currentLoad",35],["maxLoad",100]]] call ServoPeregrino_Organizador_Items_fnc_refreshHeaderStatusUI;
private _op=ctrlText (_display displayCtrl 103);
private _unit=ctrlText (_display displayCtrl 108);
private _load=ctrlText (_display displayCtrl 104);
private _status=ctrlText (_display displayCtrl 101);
private _gate553=(_op find "Operador: ") isEqualTo 0 && {(_unit find "Unidade: ") isEqualTo 0} && {(_load find "Carga: ") isEqualTo 0} && {(_load find "kg")>=0} && {(_load find "lb")<0} && {(_status find "Mostrando: COLETE")>=0} && {(_status find "Adicionar em:")<0} && {(_status find "PHYSICAL")<0} && {(_status find "VIEW")<0};
["ITEMS-0.12-553",_gate553,"Header runtime usa português player-facing, carga em kg e não duplica o destino de aplicação."] call _assert;

private _vmR=[player] call ServoPeregrino_Organizador_Items_fnc_buildUIViewModel;
private _vm=(_vmR getOrDefault ["data",createHashMap]);
private _context=_vm getOrDefault ["context",""];
private _gate554=(_context find "Kit:")>=0 && {(_context find "Adicionar em:")>=0} && {(_context find "Mostrando:")>=0} && {(_context find "Catálogo:")>=0} && {(_context find "preferredTarget")<0} && {(_context find "CONTENT")<0} && {(_srcVM find "Adicionar em:")>=0};
["ITEMS-0.12-554",_gate554,"Rodapé/contexto continua explicando kit, alvo de aplicação, equipamento mostrado e catálogo sem jargão de implementação."] call _assert;

private _friendlyDrag=(_srcDialog find "ARRASTE ITENS PARA ADICIONAR AO KIT")>=0 && {(_srcDialog find "ARRASTE ITENS PARA ADICIONAR AO EQUIPAMENTO")>=0} && {(_srcDrag find "SOLTE EM QUALQUER LUGAR DESTE PAINEL PARA ADICIONAR AO KIT")>=0} && {(_srcDrag find "SOLTE NESTE PAINEL PARA ADICIONAR A %1")>=0} && {(_srcCancel find "ARRASTE ITENS PARA ADICIONAR AO KIT")>=0};
private _friendlyNoJargon=(_srcDialog find "BEST_EFFORT")<0 && {(_srcDialog find "REPLACE STRICT")<0} && {(_srcDialog find "CONTENT mutável")<0} && {(_srcDialog find "Kit Selecionado/Draft")<0};
["ITEMS-0.12-555",_friendlyDrag && {_friendlyNoJargon},"DnD em repouso, ativo e cancelado usa instruções claras e o Equipment nomeia o equipamento mostrado como destino."] call _assert;

private _outcomeFixture=createHashMapFromArray [["success",true],["code","ITEMS_APPLICATION_COMPLETE"],["message","ITEMS_APPLICATION_COMPLETE"],["data",createHashMapFromArray [["uiCommand",createHashMapFromArray [["operation","ADD"],["target","U"],["commandId","cmd-d2-fixture"]]],["applyResult",createHashMapFromArray [["status","COMPLETE"],["appliedEntries",[["ITEM","FirstAidKit","NONE",3]]],["rejectedEntries",[]],["actionResults",[]]]]]]];
private _friendlyOutcome=[_outcomeFixture] call ServoPeregrino_Organizador_Items_fnc_classifyUIOutcome;
private _friendlyMessage=_friendlyOutcome getOrDefault ["message",""];
private _gate556=(_friendlyOutcome getOrDefault ["code",""]) isEqualTo "ITEMS_APPLICATION_COMPLETE" && {(_friendlyOutcome getOrDefault ["commandId",""]) isEqualTo "cmd-d2-fixture"} && {(_friendlyMessage find "3 itens adicionados")>=0} && {(_friendlyMessage find "ITEMS_APPLICATION_COMPLETE")<0} && {(_friendlyMessage find "cmd-d2-fixture")<0} && {(_srcOutcome find "commandId")>=0};
["ITEMS-0.12-556",_gate556,"Resultados preservam code/commandId para diagnóstico, mas a mensagem apresentada ao jogador descreve apenas o resultado útil."] call _assert;

private _gate557=(_srcLegacy find "ITEMS-0.7-234")>=0 && {(_srcLegacy find "Adicionar em:")>=0} && {(_srcLegacy find "ITEMS-0.8.2-304")>=0} && {(_srcLegacy find "ITEMS-0.8.3-310")>=0} && {(_srcLegacy find "WEAPON_SLOTS_ONLY")>=0} && {(_srcLegacy find "_x in [0,1,2]")>=0} && {(_srcLegacy find "_draftNonPhysicalContract")>=0};
["ITEMS-0.12-557",_gate557,"Runner histórico acompanha a semântica visual atual e só tolera drift ambiental explicitamente restrito aos slots de armas, sem renumerar gates."] call _assert;

if (!isNull _display) then {closeDialog 0; uiSleep 0.03;};
private _loadoutAfter=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _productionAfter=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _cmp558=[_loadoutBefore,_loadoutAfter,"ITEMS-0.12-558"] call ServoPeregrino_Organizador_Items_fnc_compareLoadoutFingerprints;
private _cmp558d=_cmp558 getOrDefault ["data",createHashMap];
private _changed558=_cmp558d getOrDefault ["changedIndexes",[]];
private _ambient558=!(_cmp558d getOrDefault ["equal",false]) && {(count _changed558)>0} && {(_changed558 findIf {!(_x in [0,1,2])})<0};
if (_ambient558) then {diag_log format ["[SP_ORG] [ITEMS] [TEST_AMBIENT_DRIFT] label=ITEMS-0.12-558 changedIndexes=%1 accepted=true reason=WEAPON_SLOTS_ONLY",_changed558];};
private _ghostContract=(_srcDrag find "DISPLAY_POINTER")>=0 && {(_srcDrag find "getMousePosition")>=0} && {(_srcProxy find "ctrlCreate")>=0} && {(_srcProxy find "DND_GHOST] CREATE")>=0} && {(_srcProxy find "DND_GHOST] HIDE")>=0};
private _gate558=_ghostContract && {(_cmp558d getOrDefault ["equal",false]) || {_ambient558}} && {_productionAfter isEqualTo _productionBefore} && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_2_GATE_COUNT isEqualTo 8} && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_2_CUMULATIVE_GATE_COUNT isEqualTo 558};
["ITEMS-0.12-558",_gate558,"D.2 permanece polish: DnD/ghost seguem intactos, storage real não muda e o cumulative contract fecha em 558."] call _assert;

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,_draftStateBefore];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_uiStateBefore];
[_productionBefore] call ServoPeregrino_Organizador_Items_fnc_restoreProductionRepositorySnapshot;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
private _durationMs=round ((diag_tickTime-_startedAt)*1000);
private _summary=createHashMapFromArray [["delivery","0.12-D.2"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],["base",_base],["baseExpected",550],["checkpointFirstGate",551],["checkpointLastGate",558],["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],["cumulativeExpected",558],["cumulativePassed",550+_passed],["durationMs",_durationMs],["twoRowHeader",true],["friendlyLanguage",true],["historicalRunnerHardened",true],["manualUltrawideValidationRequired",true]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] 0.12-D.2 — BASE=550/550  D.2=%1/8  FAIL=%2  CUMULATIVO=%3/558  TEMPO=%4ms",_passed,_failed,550+_passed,_durationMs];
diag_log "[SP_ORG] [ITEMS] 0.12-D.2 — Manual: validar header ultrawide em duas linhas, textos amigáveis e confirmar DnD/ghost sem regressão.";
diag_log "============================================================";
if (hasInterface) then {hint parseText format ["<t size='1.25'>SP_ORG_Items 0.12-D.2</t><br/><br/>Baseline D.1: <t color='#7CFC00'>550 / 550</t><br/>D.2: <t color='%1'>%2 / 8</t><br/>Cumulativo: %3 / 558<br/><br/>%4",if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_passed,550+_passed,if (_failed isEqualTo 0) then {"Valide visualmente o header e a linguagem da interface."} else {"Consulte o primeiro FAIL no RPT."}];};
_summary
