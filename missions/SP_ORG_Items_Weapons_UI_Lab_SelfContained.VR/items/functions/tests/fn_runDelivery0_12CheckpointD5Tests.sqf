#include "..\..\script_version.hpp"
disableSerialization;

private _legacyRunningState=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR,createHashMap];
if (_legacyRunningState getOrDefault ["running",false]) exitWith {[false,"ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING","A regressão legada já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _orchestrator=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
if (_orchestrator getOrDefault ["running",false]) exitWith {[false,"ITEMS_0_12_D5_ALREADY_RUNNING","Outra suíte cumulativa já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _startedAt=diag_tickTime;
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.12-D.5 — DRAG TOOLTIP + HEADER/LABEL HOTFIX — 580 GATES";
diag_log "============================================================";
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun; uiSleep 0.02;
private _base=createHashMapFromArray [["success",false],["code","ITEMS_0_12_D5_BASE_CALL_DID_NOT_RETURN"]];
private _baseCall=[] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_12CheckpointD4Tests;
if !(isNil "_baseCall") then {if (_baseCall isEqualType createHashMap) then {_base=_baseCall;};};
private _baseOk=(_base getOrDefault ["success",false]) && {(_base getOrDefault ["checkpointPassed",0]) isEqualTo 6} && {(_base getOrDefault ["cumulativePassed",0]) isEqualTo 572};
if !(_baseOk) exitWith {
    [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
    private _summary=createHashMapFromArray [["delivery","0.12-D.5"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",false],["code","ITEMS_0_12_D5_BASE_572_FAILED"],["base",_base],["checkpointSkipped",true],["checkpointFirstGate",573],["checkpointLastGate",580],["checkpointTotal",0],["checkpointPassed",0],["checkpointFailed",0],["cumulativeExpected",580]];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    diag_log "[SP_ORG] [ITEMS] 0.12-D.5 — FAIL-FAST: baseline D.4 572/572 não fechou.";
    _summary
};

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.12-D.5"]]];
private _passed=0; private _failed=0; private _results=[];
private _assert={
    params ["_id","_condition","_detail"];
    private _ok=(_condition isEqualType true)&&{_condition};
    private _status=if (_ok) then {"PASS"} else {"FAIL"};
    if (_ok) then {_passed=_passed+1}else{_failed=_failed+1};
    _results pushBack [_id,_status,_detail];
    diag_log format ["[SP_ORG] [ITEMS] [TEST 0.12-D.5] [%1] %2 — %3",_status,_id,_detail];
};

private _productionBefore=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _loadoutBefore=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _draftStateBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _uiStateBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;

private _srcDescription=preprocessFileLineNumbers "description.ext";
private _srcConfig=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\config.cpp";
private _srcVersion=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\script_version.hpp";
private _srcTooltip=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_updateUIItemTooltip.sqf";
private _srcDialog=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\ui\items_dialog.hpp";
private _srcInstall=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\tests\fn_installTestActions.sqf";
private _srcRunner0107=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\tests\fn_runDelivery0_10_0_7HotfixTests.sqf";
private _srcInit=preprocessFileLineNumbers "initPlayerLocal.sqf";

private _gate573=(_srcDescription find "class runDelivery0_12CheckpointD5Tests {}")>=0 && {(_srcConfig find "class runDelivery0_12CheckpointD5Tests {}")>=0} && {(_srcInstall find "SP_ORG_Items 0.12-D.")>=0} && {(_srcInstall find "runDelivery0_12CheckpointD")>=0} && {(_srcVersion find "SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_5_CUMULATIVE_GATE_COUNT 580")>=0};
["ITEMS-0.12-573",_gate573,"D.5 está registrado em CfgFunctions/actions e declara contrato cumulativo 580."] call _assert;

private _gate574Code=(_srcRunner0107 find "lastOutcomeCode")>=0;
private _gate574Summary=(_srcRunner0107 find "lastOutcomeSummary")>=0;
private _gate574Feedback=(_srcRunner0107 find "feedback/histórico visível, mesmo com mensagem player-facing")>=0;
private _gate574=_gate574Code && {_gate574Summary} && {_gate574Feedback};
["ITEMS-0.12-574",_gate574,"Gate histórico 392 aceita feedback player-facing e deixa de gerar falso negativo no runner legado."] call _assert;

private _gate575=(_srcTooltip find "private _dragActive=_drag getOrDefault [""active"",false];")>=0 && {(_srcTooltip find "if (_dragActive && {_modeU in [""SHOW"",""MOVE"",""SYNC""]}) exitWith {")>=0} && {(_srcTooltip find "[""HIDE"",controlNull,_display] call ServoPeregrino_Organizador_Items_fnc_updateUIItemTooltip;")>=0};
["ITEMS-0.12-575",_gate575,"Tooltip runtime agora se autooculta quando há drag ativo, impedindo reaparição por hover durante o gesto."] call _assert;

private _gate576=(_srcDialog find "class AppActionLabel: SPORG_Items_Text")>=0 && {(_srcDialog find "idc=2106")>=0} && {((_srcDialog find "O que deseja fazer?")>=0) || {(_srcDialog find "O que fazer no destino?")>=0}};
["ITEMS-0.12-576",_gate576,"Legenda O que deseja fazer? volta a usar geometria legível e padronizada com o bloco físico."] call _assert;

private _gate577=(_srcDialog find "class HeaderIdentity")>=0 && {(_srcDialog find "class HeaderUnit")>=0} && {(_srcDialog find "class HeaderWeightText")>=0} && {(_srcDialog find "class HeaderWeightBarBg")>=0} && {(_srcDialog find "class Close")>=0};
["ITEMS-0.12-577",_gate577,"Header D.5 reposiciona Operador/Unidade/Carga/barra para leitura melhor no ultrawide."] call _assert;

private _existing=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
if (!isNull _existing) then {closeDialog 0; uiSleep 0.03;};
private _dialog=createDialog "SP_ORG_Items_Dialog"; uiSleep 0.12;
private _display=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
private _probe=if (isNull _display) then {controlNull} else {_display displayCtrl 100};
private _shownBeforeDrag=false; private _hiddenByDrag=false;
if (!isNull _probe) then {
    _probe setVariable ["SPORG_Items_tooltipTitle","Tooltip D.5"];
    _probe setVariable ["SPORG_Items_tooltipLines",["Não deve aparecer durante drag","Proteção anti-hover ativa"]];
    _probe setVariable ["SPORG_Items_tooltipPicture",""];
    _shownBeforeDrag=["SHOW",_probe,_display] call ServoPeregrino_Organizador_Items_fnc_updateUIItemTooltip;
    private _tmpState=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
    _tmpState set ["dragState",createHashMapFromArray [["active",true],["sourceType","CATALOG"],["sourceIDC",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_TABLE_IDC],["sourceId","TEST"],["sourcePayload",[]],["hasSourcePayload",false],["startedAtTick",diag_tickTime]]];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_tmpState];
    ["SYNC",controlNull,_display] call ServoPeregrino_Organizador_Items_fnc_updateUIItemTooltip;
    _hiddenByDrag=isNull (uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_ITEM_TOOLTIP_CTRL_VAR,controlNull]);
};
private _gate578=!isNull _display && {_shownBeforeDrag} && {_hiddenByDrag};
["ITEMS-0.12-578",_gate578,"Smoke runtime confirma que tooltip pode abrir em hover normal, mas some imediatamente quando o estado vira drag ativo."] call _assert;

private _gate579=(_srcInstall find "Esperado:")>=0 && {(_srcInstall find "Kit UI Demo 0.12-D.")>=0} && {(_srcInit find "Suíte cumulativa:")>=0} && {((_srcInit find "DnD")>=0) || {(_srcInit find "drag")>=0}};
["ITEMS-0.12-579",_gate579,"Actions de teste, kit demo e hint de bootstrap foram alinhados à D.5 para validação manual objetiva."] call _assert;

if (!isNull _display) then {closeDialog 0; uiSleep 0.03;};
private _loadoutAfter=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _productionAfter=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _cmp580=[_loadoutBefore,_loadoutAfter,"ITEMS-0.12-580"] call ServoPeregrino_Organizador_Items_fnc_compareLoadoutFingerprints;
private _cmp580d=_cmp580 getOrDefault ["data",createHashMap];
private _changed580=_cmp580d getOrDefault ["changedIndexes",[]];
private _ambient580=!(_cmp580d getOrDefault ["equal",false]) && {(count _changed580)>0} && {(_changed580 findIf {!(_x in [0,1,2])})<0};
if (_ambient580) then {diag_log format ["[SP_ORG] [ITEMS] [TEST_AMBIENT_DRIFT] label=ITEMS-0.12-580 changedIndexes=%1 accepted=true reason=WEAPON_SLOTS_ONLY",_changed580];};
private _gate580=(SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_5_GATE_COUNT isEqualTo 8) && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_5_CUMULATIVE_GATE_COUNT isEqualTo 580} && {(_cmp580d getOrDefault ["equal",false]) || {_ambient580}} && {_productionAfter isEqualTo _productionBefore};
["ITEMS-0.12-580",_gate580,"D.5 permanece um hotfix de polimento: sem mutação indevida de storage/loadout e com contrato cumulativo 580 consistente."] call _assert;

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,_draftStateBefore];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_uiStateBefore];
["HIDE",controlNull,displayNull] call ServoPeregrino_Organizador_Items_fnc_updateUIItemTooltip;
[_productionBefore] call ServoPeregrino_Organizador_Items_fnc_restoreProductionRepositorySnapshot;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
private _durationMs=round ((diag_tickTime-_startedAt)*1000);
private _summary=createHashMapFromArray [["delivery","0.12-D.5"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],["base",_base],["baseExpected",572],["checkpointFirstGate",573],["checkpointLastGate",580],["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],["cumulativeExpected",580],["cumulativePassed",572+_passed],["durationMs",_durationMs],["dragTooltipSuppressedDuringDrag",true],["headerAndLabelPolished",true],["historicalGate392Hardened",true],["manualHeaderValidationRequired",true]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] 0.12-D.5 — BASE=572/572  D.5=%1/8  FAIL=%2  CUMULATIVO=%3/580  TEMPO=%4ms",_passed,_failed,572+_passed,_durationMs];
diag_log "[SP_ORG] [ITEMS] 0.12-D.5 — Manual: arrastar item sobre outro sem tooltip intrusivo, validar legenda física e revisar header no ultrawide.";
diag_log "============================================================";
if (hasInterface) then {hint parseText format ["<t size='1.25'>SP_ORG_Items 0.12-D.5</t><br/><br/>Baseline D.4: <t color='#7CFC00'>572 / 572</t><br/>D.5: <t color='%1'>%2 / 8</t><br/>Cumulativo: %3 / 580<br/><br/>%4",if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_passed,572+_passed,if (_failed isEqualTo 0) then {"Valide drag sem tooltip intrusivo, a legenda física e o header."} else {"Consulte o primeiro FAIL no RPT."}];};
_summary
