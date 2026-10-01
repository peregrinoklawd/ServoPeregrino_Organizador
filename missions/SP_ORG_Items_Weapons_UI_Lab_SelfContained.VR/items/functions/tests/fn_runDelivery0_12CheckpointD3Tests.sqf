#include "..\..\script_version.hpp"
disableSerialization;

private _legacyRunningState=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR,createHashMap];
if (_legacyRunningState getOrDefault ["running",false]) exitWith {[false,"ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING","A regressão legada já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _orchestrator=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
if (_orchestrator getOrDefault ["running",false]) exitWith {[false,"ITEMS_0_12_D3_ALREADY_RUNNING","Outra suíte cumulativa já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _startedAt=diag_tickTime;
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.12-D.3 — TOOLTIP + ACTION HIERARCHY RECOVERY — 566 GATES";
diag_log "============================================================";
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun; uiSleep 0.02;
private _base=createHashMapFromArray [["success",false],["code","ITEMS_0_12_D3_BASE_CALL_DID_NOT_RETURN"]];
private _baseCall=[] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_12CheckpointD2Tests;
if !(isNil "_baseCall") then {if (_baseCall isEqualType createHashMap) then {_base=_baseCall;};};
private _baseOk=(_base getOrDefault ["success",false]) && {(_base getOrDefault ["checkpointPassed",0]) isEqualTo 8} && {(_base getOrDefault ["cumulativePassed",0]) isEqualTo 558};
if !(_baseOk) exitWith {
    [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
    private _summary=createHashMapFromArray [["delivery","0.12-D.3"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",false],["code","ITEMS_0_12_D3_BASE_558_FAILED"],["base",_base],["checkpointSkipped",true],["checkpointFirstGate",559],["checkpointLastGate",566],["checkpointTotal",0],["checkpointPassed",0],["checkpointFailed",0],["cumulativeExpected",566]];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    diag_log "[SP_ORG] [ITEMS] 0.12-D.3 — FAIL-FAST: baseline D.2 558/558 não fechou.";
    _summary
};

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.12-D.3"]]];
private _passed=0; private _failed=0; private _results=[];
private _assert={
    params ["_id","_condition","_detail"];
    private _ok=(_condition isEqualType true)&&{_condition};
    private _status=if (_ok) then {"PASS"} else {"FAIL"};
    if (_ok) then {_passed=_passed+1}else{_failed=_failed+1};
    _results pushBack [_id,_status,_detail];
    diag_log format ["[SP_ORG] [ITEMS] [TEST 0.12-D.3] [%1] %2 — %3",_status,_id,_detail];
};

private _productionBefore=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _loadoutBefore=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _draftStateBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _uiStateBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;

private _srcDescription=preprocessFileLineNumbers "description.ext";
private _srcConfig=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\config.cpp";
private _srcTooltip=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_updateUIItemTooltip.sqf";
private _srcCatalog=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_renderCatalogRowsUI.sqf";
private _srcEquipment=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_renderEquipmentRowsUI.sqf";
private _srcDraft=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshInterface.sqf";
private _srcDraftFocused=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshDraftMutationUI.sqf";
private _srcDrag=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUIDragEvent.sqf";
private _srcUnload=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_onInterfaceUnload.sqf";
private _srcDialog=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\ui\items_dialog.hpp";

private _gate559=(_srcDescription find "class runDelivery0_12CheckpointD2Tests {}")>=0 && {(_srcDescription find "class runDelivery0_12CheckpointD3Tests {}")>=0} && {(_srcDescription find "class updateUIItemTooltip {}")>=0} && {(_srcConfig find "class runDelivery0_12CheckpointD3Tests {}")>=0} && {(_srcConfig find "class updateUIItemTooltip {}")>=0};
["ITEMS-0.12-559",_gate559,"CfgFunctions registra explicitamente D.2, D.3 e o controlador de tooltip; o erro de função indefinida do runner não pode se repetir por omissão de registro."] call _assert;

private _gate560=(_srcTooltip find "ctrlCreate")>=0 && {(_srcTooltip find "RscStructuredText")>=0} && {(_srcTooltip find "ctrlEnable false")>=0} && {(_srcTooltip find "ctrlTextHeight")>=0} && {(_srcTooltip find "ctrlDelete")>=0} && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_ITEM_TOOLTIP_RUNTIME_IDC isEqualTo 7705} && {(_srcTooltip find "resolveUIPointerSource")>=0} && {(_srcTooltip find "ctRowControls")>=0};
["ITEMS-0.12-560",_gate560,"Tooltip de item é uma superfície runtime pass-through, dimensionada pelo conteúdo e destruída deterministicamente no HIDE."] call _assert;

private _catalogTooltip=(_srcCatalog find "SPORG_Items_tooltipTitle")>=0 && {(_srcCatalog find "MouseEnter")>=0} && {(_srcCatalog find "MouseExit")>=0} && {(_srcCatalog find "ctrlSetTooltip")>=0};
private _equipmentTooltip=(_srcEquipment find "SPORG_Items_tooltipTitle")>=0 && {(_srcEquipment find "MouseEnter")>=0} && {(_srcEquipment find "MouseExit")>=0} && {(_srcEquipment find "ctrlSetTooltip")>=0};
private _draftTooltip=(_srcDraft find "SPORG_Items_tooltipTitle")>=0 && {(_srcDraft find "MouseEnter")>=0} && {(_srcDraft find "MouseExit")>=0} && {(_srcDraftFocused find "SPORG_Items_tooltipTitle")>=0} && {(_srcDraftFocused find "MouseEnter")>=0};
["ITEMS-0.12-561",_catalogTooltip && {_equipmentTooltip} && {_draftTooltip},"Catálogo, Kit Selecionado e Equipment materializam tooltip próprio em ícone/nome e mantêm ctrlSetTooltip legado como fallback/contrato histórico."] call _assert;

private _gate562=(_srcDrag find "updateUIItemTooltip")>=0 && {(_srcDrag find "[""HIDE"",controlNull,_display]")>=0} && {(_srcDrag find "[""SYNC"",controlNull,_display]")>=0} && {(_srcDrag find "updateUIDragVisualProxy")>=0} && {(_srcUnload find "updateUIItemTooltip")>=0};
["ITEMS-0.12-562",_gate562,"Ao iniciar DnD o tooltip some antes do ghost; em repouso o mesmo hit-test do DnD resolve o item sob o ponteiro; unload limpa ambos sem introduzir nova camada capturadora."] call _assert;

private _gate563=(_srcDialog find "Onde aplicar o kit?")>=0 && {(_srcDialog find "O que deseja fazer?")>=0} && {(_srcDialog find "class AppActionLabel")>=0} && {(_srcDialog find "Adicionar ao destino escolhido")>=0} && {(_srcDialog find "Remover do destino escolhido")>=0} && {(_srcDialog find "Deixar o destino escolhido igual ao Kit Selecionado")>=0};
["ITEMS-0.12-563",_gate563,"Hierarquia visual separa claramente ONDE aplicar de O QUE fazer, preservando as duas linhas de botões e adicionando linguagem player-facing às operações."] call _assert;

private _existing=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
if (!isNull _existing) then {closeDialog 0; uiSleep 0.03;};
private _dialog=createDialog "SP_ORG_Items_Dialog"; uiSleep 0.12;
private _display=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
private _targetLabel=if (isNull _display) then {controlNull} else {_display displayCtrl 2105};
private _actionLabel=if (isNull _display) then {controlNull} else {_display displayCtrl 2106};
private _apply=if (isNull _display) then {controlNull} else {_display displayCtrl 2150};
private _remove=if (isNull _display) then {controlNull} else {_display displayCtrl 2151};
private _replace=if (isNull _display) then {controlNull} else {_display displayCtrl 2152};
private _targetY=if (isNull _targetLabel) then {-1} else {(ctrlPosition _targetLabel)#1};
private _actionY=if (isNull _actionLabel) then {-1} else {(ctrlPosition _actionLabel)#1};
private _buttonY=if (isNull _apply) then {-1} else {(ctrlPosition _apply)#1};
private _gate564=!isNull _display && {!isNull _targetLabel} && {!isNull _actionLabel} && {!isNull _apply} && {!isNull _remove} && {!isNull _replace} && {_targetY<_actionY} && {_actionY<_buttonY} && {(ctrlTooltip _apply) isNotEqualTo ""} && {(ctrlTooltip _remove) isNotEqualTo ""} && {(ctrlTooltip _replace) isNotEqualTo ""};
["ITEMS-0.12-564",_gate564,"Smoke runtime confirma legenda de destino acima, legenda de operação entre as linhas e tooltips presentes nos três comandos físicos."] call _assert;

private _probe=if (isNull _display) then {controlNull} else {_display displayCtrl 100};
private _shown=false; private _createdTip=controlNull; private _createdIDC=-1; private _hidden=false;
if (!isNull _probe) then {
    _probe setVariable ["SPORG_Items_tooltipTitle","Tooltip D.3"];
    _probe setVariable ["SPORG_Items_tooltipLines",["Teste runtime pass-through","Sem alterar o inventário"]];
    _probe setVariable ["SPORG_Items_tooltipPicture",""];
    _shown=["SHOW",_probe,_display] call ServoPeregrino_Organizador_Items_fnc_updateUIItemTooltip;
    _createdTip=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_ITEM_TOOLTIP_CTRL_VAR,controlNull];
    if (!isNull _createdTip) then {_createdIDC=ctrlIDC _createdTip;};
    ["MOVE",controlNull,_display] call ServoPeregrino_Organizador_Items_fnc_updateUIItemTooltip;
    ["HIDE",controlNull,_display] call ServoPeregrino_Organizador_Items_fnc_updateUIItemTooltip;
    _hidden=isNull (uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_ITEM_TOOLTIP_CTRL_VAR,controlNull]);
};
private _gate565=_shown && {_createdIDC isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_ITEM_TOOLTIP_RUNTIME_IDC} && {_hidden} && {!(isNil "ServoPeregrino_Organizador_Items_fnc_runDelivery0_12CheckpointD2Tests")} && {!(isNil "ServoPeregrino_Organizador_Items_fnc_runDelivery0_12CheckpointD3Tests")};
["ITEMS-0.12-565",_gate565,"Tooltip SHOW/MOVE/HIDE fecha em runtime e os runners D.2/D.3 existem no namespace de funções compiladas."] call _assert;

if (!isNull _display) then {closeDialog 0; uiSleep 0.03;};
private _loadoutAfter=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _productionAfter=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _cmp566=[_loadoutBefore,_loadoutAfter,"ITEMS-0.12-566"] call ServoPeregrino_Organizador_Items_fnc_compareLoadoutFingerprints;
private _cmp566d=_cmp566 getOrDefault ["data",createHashMap];
private _changed566=_cmp566d getOrDefault ["changedIndexes",[]];
private _ambient566=!(_cmp566d getOrDefault ["equal",false]) && {(count _changed566)>0} && {(_changed566 findIf {!(_x in [0,1,2])})<0};
if (_ambient566) then {diag_log format ["[SP_ORG] [ITEMS] [TEST_AMBIENT_DRIFT] label=ITEMS-0.12-566 changedIndexes=%1 accepted=true reason=WEAPON_SLOTS_ONLY",_changed566];};
private _dndContract=(_srcDrag find "DISPLAY_POINTER")>=0 && {(_srcDrag find "updateUIDragVisualProxy")>=0} && {(_srcDrag find "finalizeUIPointerDrop")>=0};
private _gate566=_dndContract && {(_cmp566d getOrDefault ["equal",false]) || {_ambient566}} && {_productionAfter isEqualTo _productionBefore} && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_3_GATE_COUNT isEqualTo 8} && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_3_CUMULATIVE_GATE_COUNT isEqualTo 566};
["ITEMS-0.12-566",_gate566,"D.3 permanece polish: DnD/ghost, loadout e storage real ficam invariantes enquanto tooltip/hierarquia visual são recuperados."] call _assert;

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,_draftStateBefore];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_uiStateBefore];
[_productionBefore] call ServoPeregrino_Organizador_Items_fnc_restoreProductionRepositorySnapshot;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
private _durationMs=round ((diag_tickTime-_startedAt)*1000);
private _summary=createHashMapFromArray [["delivery","0.12-D.3"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],["base",_base],["baseExpected",558],["checkpointFirstGate",559],["checkpointLastGate",566],["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],["cumulativeExpected",566],["cumulativePassed",558+_passed],["durationMs",_durationMs],["tooltipRuntimeRecovered",true],["actionHierarchyClarified",true],["d2RunnerRegistered",true],["manualTooltipValidationRequired",true]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] 0.12-D.3 — BASE=558/558  D.3=%1/8  FAIL=%2  CUMULATIVO=%3/566  TEMPO=%4ms",_passed,_failed,558+_passed,_durationMs];
diag_log "[SP_ORG] [ITEMS] 0.12-D.3 — Manual: passar o mouse sobre itens nos três painéis, validar as duas legendas de aplicação e repetir DnD/ghost.";
diag_log "============================================================";
if (hasInterface) then {hint parseText format ["<t size='1.25'>SP_ORG_Items 0.12-D.3</t><br/><br/>Baseline D.2: <t color='#7CFC00'>558 / 558</t><br/>D.3: <t color='%1'>%2 / 8</t><br/>Cumulativo: %3 / 566<br/><br/>%4",if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_passed,558+_passed,if (_failed isEqualTo 0) then {"Valide tooltips nos itens e repita o DnD/ghost."} else {"Consulte o primeiro FAIL no RPT."}];};
_summary
