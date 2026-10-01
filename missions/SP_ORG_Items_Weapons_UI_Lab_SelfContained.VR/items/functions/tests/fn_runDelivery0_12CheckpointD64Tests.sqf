#include "..\..\script_version.hpp"
disableSerialization;

private _legacyRunningState=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR,createHashMap];
if (_legacyRunningState getOrDefault ["running",false]) exitWith {[false,"ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING","A regressão legada já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _orchestrator=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
if (_orchestrator getOrDefault ["running",false]) exitWith {[false,"ITEMS_0_12_D64_ALREADY_RUNNING","Outra suíte cumulativa já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _startedAt=diag_tickTime;
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.12-D.6.4 — AUTO DRAFT ARROW PARITY + REGRESSION CLOSE — 617 GATES";
diag_log "============================================================";
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun; uiSleep 0.02;
private _base=createHashMapFromArray [["success",false],["code","ITEMS_0_12_D64_BASE_CALL_DID_NOT_RETURN"]];
private _baseCall=[] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_12CheckpointD63Tests;
if !(isNil "_baseCall") then {if (_baseCall isEqualType createHashMap) then {_base=_baseCall;};};
private _baseOk=(_base getOrDefault ["success",false]) && {(_base getOrDefault ["checkpointPassed",0]) isEqualTo 8} && {(_base getOrDefault ["cumulativePassed",0]) isEqualTo 610};
if !(_baseOk) exitWith {
    [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
    private _summary=createHashMapFromArray [["delivery","0.12-D.6.4"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",false],["code","ITEMS_0_12_D64_BASE_610_FAILED"],["base",_base],["checkpointSkipped",true],["checkpointFirstGate",611],["checkpointLastGate",617],["checkpointTotal",0],["checkpointPassed",0],["checkpointFailed",0],["cumulativeExpected",617]];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    diag_log "[SP_ORG] [ITEMS] 0.12-D.6.4 — FAIL-FAST: baseline D.6.3 610/610 não fechou.";
    _summary
};

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.12-D.6.4"]]];
private _passed=0; private _failed=0; private _results=[];
private _assert={
    params ["_id","_condition","_detail"];
    private _ok=(_condition isEqualType true)&&{_condition};
    private _status=if (_ok) then {"PASS"} else {"FAIL"};
    if (_ok) then {_passed=_passed+1}else{_failed=_failed+1};
    _results pushBack [_id,_status,_detail];
    diag_log format ["[SP_ORG] [ITEMS] [TEST 0.12-D.6.4] [%1] %2 — %3",_status,_id,_detail];
};
private _emptyDraftState={createHashMapFromArray [["ready",true],["hasDraft",false],["current",createHashMap],["baseline",createHashMap],["revision",0],["lastAction","NONE"]]};
private _qtyClass={params ["_entries","_class"]; private _q=0; {if ((_x param [2,"",[""]]) isEqualTo _class) then {_q=_q+(_x param [3,0,[0]]);};} forEach _entries; _q};

private _productionBefore=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _loadoutBefore=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _draftStateBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _uiStateBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;

private _srcDescription=preprocessFileLineNumbers "description.ext";
private _srcConfig=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\config.cpp";
private _srcTransfer=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUITransferToDraft.sqf";
private _srcEvent=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUIEvent.sqf";
private _srcEquipmentCapture=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_captureEquipmentRowToDraft.sqf";
private _srcPointerDrop=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_finalizeUIPointerDrop.sqf";
private _srcC5=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\tests\fn_runDelivery0_12CheckpointC5Tests.sqf";
private _srcRefresh=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshInterface.sqf";

private _gate611=(_srcDescription find "class runDelivery0_12CheckpointD64Tests {}")>=0 && {(_srcConfig find "class runDelivery0_12CheckpointD64Tests {}")>=0} && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_6_4_GATE_COUNT isEqualTo 7} && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_6_4_CUMULATIVE_GATE_COUNT isEqualTo 617} && {(SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DISPLAY_VERSION find "0.12-D.") isEqualTo 0};
["ITEMS-0.12-611",_gate611,"D.6.4 está registrada, versionada e declara contrato cumulativo 617/617."] call _assert;

private _gate612=(_srcC5 find "Clique para abrir em edição; arraste para combinar no Rascunho atual")>=0 && {(_srcRefresh find "Clique para abrir em edição; arraste para combinar no Rascunho atual")>=0} && {(_srcC5 find "Clique para abrir em edição; arraste para combinar no Draft atual")<0};
["ITEMS-0.12-612",_gate612,"Gate histórico 510 acompanha a padronização Draft -> Rascunho e deixa de interromper a cadeia por copy obsoleta."] call _assert;

private _gate613=(_srcTransfer find "autoCreateDraftIfMissing")>=0 && {(_srcTransfer find "autoCreateDraftOnDrop")>=0} && {(_srcTransfer find "autoDraftTrigger")>=0} && {(_srcEvent find "autoCreateDraftIfMissing")>=0} && {(_srcEquipmentCapture find "autoCreateDraftIfMissing")>=0} && {(_srcPointerDrop find "autoCreateDraftIfMissing")>=0};
["ITEMS-0.12-613",_gate613,"DnD e setas explícitas usam o mesmo opt-in central de auto-Rascunho, mantendo um único executor e rollback transacional."] call _assert;

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,call _emptyDraftState];
private _catalogArrow=["CATALOG","FirstAidKit","DRAFT","AUTO",player,"",createHashMapFromArray [["commandOrigin","CATALOG_BUTTON_TO_DRAFT"],["autoCreateDraftIfMissing",true]]] call ServoPeregrino_Organizador_Items_fnc_executeUITransferCommand;
private _catalogState=([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap];
private _catalogDraft=_catalogState getOrDefault ["current",createHashMap];
private _catalogData=_catalogArrow getOrDefault ["data",createHashMap];
private _gate614=(_catalogArrow getOrDefault ["success",false]) && {_catalogState getOrDefault ["hasDraft",false]} && {(_catalogDraft getOrDefault ["mode",""]) isEqualTo "NEW"} && {([_catalogDraft getOrDefault ["entries",[]],"FirstAidKit"] call _qtyClass)>=1} && {_catalogData getOrDefault ["autoDraftCreated",false]} && {(_catalogData getOrDefault ["autoDraftTrigger",""]) isEqualTo "EXPLICIT_ADD"};
["ITEMS-0.12-614",_gate614,"Seta ← do Catálogo cria um novo Rascunho quando o painel está vazio e adiciona o item no mesmo gesto."] call _assert;

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,call _emptyDraftState];
private _equipmentPayload=["ITEM","FirstAidKit",1,"NONE",[]];
private _equipmentArrow=["EQUIPMENT",_equipmentPayload,"DRAFT","AUTO",player,"",createHashMapFromArray [["commandOrigin","EQUIPMENT_ROW_CAPTURE"],["autoCreateDraftIfMissing",true]]] call ServoPeregrino_Organizador_Items_fnc_executeUITransferCommand;
private _equipmentState=([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap];
private _equipmentDraft=_equipmentState getOrDefault ["current",createHashMap];
private _equipmentData=_equipmentArrow getOrDefault ["data",createHashMap];
private _gate615=(_equipmentArrow getOrDefault ["success",false]) && {_equipmentState getOrDefault ["hasDraft",false]} && {([_equipmentDraft getOrDefault ["entries",[]],"FirstAidKit"] call _qtyClass)>=1} && {_equipmentData getOrDefault ["autoDraftCreated",false]} && {(_equipmentData getOrDefault ["autoDraftTrigger",""]) isEqualTo "EXPLICIT_ADD"};
["ITEMS-0.12-615",_gate615,"Seta ← do Conteúdo do Equipamento possui a mesma paridade: cria Rascunho e copia logicamente o item sem exigir NOVO prévio."] call _assert;

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,call _emptyDraftState];
private _neutral=["CATALOG","FirstAidKit","DRAFT","AUTO",player,"",createHashMapFromArray [["commandOrigin","DIRECT_INTERNAL"]]] call ServoPeregrino_Organizador_Items_fnc_executeUITransferCommand;
private _neutralState=([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap];
private _gate616=!(_neutral getOrDefault ["success",true]) && {(_neutral getOrDefault ["code",""]) isEqualTo "ITEMS_UI_DRAFT_REQUIRED"} && {!(_neutralState getOrDefault ["hasDraft",false])};
["ITEMS-0.12-616",_gate616,"Auto-criação continua restrita a gestos explícitos de adição; chamada lógica neutra sem opt-in não fabrica Rascunho."] call _assert;

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,_draftStateBefore];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_uiStateBefore];
[_productionBefore] call ServoPeregrino_Organizador_Items_fnc_restoreProductionRepositorySnapshot;
private _loadoutAfter=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _productionAfter=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _cmp617=[_loadoutBefore,_loadoutAfter,"ITEMS-0.12-617"] call ServoPeregrino_Organizador_Items_fnc_compareLoadoutFingerprints;
private _cmp617d=_cmp617 getOrDefault ["data",createHashMap];
private _changed617=_cmp617d getOrDefault ["changedIndexes",[]];
private _ambient617=!(_cmp617d getOrDefault ["equal",false]) && {(count _changed617)>0} && {(_changed617 findIf {!(_x in [0,1,2])})<0};
if (_ambient617) then {diag_log format ["[SP_ORG] [ITEMS] [TEST_AMBIENT_DRIFT] label=ITEMS-0.12-617 changedIndexes=%1 accepted=true reason=WEAPON_SLOTS_ONLY",_changed617];};
private _gate617=((_cmp617d getOrDefault ["equal",false]) || {_ambient617}) && {_productionAfter isEqualTo _productionBefore};
["ITEMS-0.12-617",_gate617,"D.6.4 fecha sem mutar loadout/storage e restaura o Rascunho após os smokes de paridade das setas."] call _assert;

["HIDE",controlNull,displayNull] call ServoPeregrino_Organizador_Items_fnc_updateUIItemTooltip;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
private _durationMs=round ((diag_tickTime-_startedAt)*1000);
private _summary=createHashMapFromArray [["delivery","0.12-D.6.4"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],["base",_base],["baseExpected",610],["checkpointFirstGate",611],["checkpointLastGate",617],["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],["cumulativeExpected",617],["cumulativePassed",610+_passed],["durationMs",_durationMs],["autoDraftOnDrop",true],["autoDraftOnCatalogArrow",true],["autoDraftOnEquipmentArrow",true],["historical510Hardened",true]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] 0.12-D.6.4 — BASE=610/610  D.6.4=%1/7  FAIL=%2  CUMULATIVO=%3/617  TEMPO=%4ms",_passed,_failed,610+_passed,_durationMs];
diag_log "[SP_ORG] [ITEMS] 0.12-D.6.4 — Manual: sem Rascunho, clicar ← no Catálogo cria e adiciona; descarte e repita ← no Equipment; DnD D.6.3 e header permanecem.";
diag_log "============================================================";
if (hasInterface) then {hint parseText format ["<t size='1.25'>SP_ORG_Items 0.12-D.6.4</t><br/><br/>Baseline D.6.3: <t color='#7CFC00'>610 / 610</t><br/>D.6.4: <t color='%1'>%2 / 7</t><br/>Cumulativo: %3 / 617<br/><br/>%4",if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_passed,610+_passed,if (_failed isEqualTo 0) then {"Valide a criação automática também pelas setas ← do Catálogo e do Equipment."} else {"Consulte o primeiro FAIL no RPT."}];};
_summary
