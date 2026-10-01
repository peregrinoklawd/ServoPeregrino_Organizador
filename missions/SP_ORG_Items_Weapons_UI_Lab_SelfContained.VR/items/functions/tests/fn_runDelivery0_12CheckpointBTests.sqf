#include "..\..\script_version.hpp"
disableSerialization;
private _legacyRunningState=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR,createHashMap];
if (_legacyRunningState getOrDefault ["running",false]) exitWith {[false,"ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING","A regressão legada já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _orchestrator=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
if (_orchestrator getOrDefault ["running",false]) exitWith {[false,"ITEMS_0_12_B_ALREADY_RUNNING","Outra suíte cumulativa já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _startedAt=diag_tickTime;
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.12-B — EQUIPMENT ROW CONTROLS + CAPACITY UX — 478 GATES";
diag_log "============================================================";
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun; uiSleep 0.02;
private _base=[] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_12CheckpointATests;
private _baseOk=(_base isEqualType createHashMap) && {_base getOrDefault ["success",false]} && {(_base getOrDefault ["checkpointPassed",0]) isEqualTo 8} && {(_base getOrDefault ["cumulativePassed",0]) isEqualTo 468};
if !(_baseOk) exitWith {
    [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
    private _summary=createHashMapFromArray [["delivery","0.12-B"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",false],["code","ITEMS_0_12_B_BASE_468_FAILED"],["base",_base],["checkpointSkipped",true],["checkpointFirstGate",469],["checkpointLastGate",478],["checkpointTotal",0],["checkpointPassed",0],["checkpointFailed",0],["cumulativeExpected",478]];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    diag_log "[SP_ORG] [ITEMS] 0.12-B — FAIL-FAST: baseline 0.12-A 468/468 não fechou."; _summary
};
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.12-B"]]];
private _passed=0; private _failed=0; private _results=[];
private _assert={params ["_id","_condition","_detail"]; private _ok=(_condition isEqualType true)&&{_condition}; private _status=if (_ok) then {"PASS"} else {"FAIL"}; if (_ok) then {_passed=_passed+1}else{_failed=_failed+1}; _results pushBack [_id,_status,_detail]; diag_log format ["[SP_ORG] [ITEMS] [TEST 0.12-B] [%1] %2 — %3",_status,_id,_detail];};
private _productionBefore=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _loadoutBefore=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _srcDialog=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\ui\items_dialog.hpp";
private _srcRender=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_renderEquipmentRowsUI.sqf";
private _srcEq=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshEquipmentViewUI.sqf";
private _srcPhys=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshPhysicalMutationUI.sqf";
private _srcFull=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshInterface.sqf";
private _srcDrag=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUIDragEvent.sqf";
private _srcCapture=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_captureEquipmentRowToDraft.sqf";

["ITEMS-0.12-469",(_srcDialog find "class SPORG_Items_EquipmentTable")>=0 && {(_srcDialog find "idc=4140")>=0} && {(_srcDialog find "class Capture")>=0} && {(_srcDialog find "class Quantity")>=0},"Equipment usa CT_CONTROLS_TABLE com ←, imagem, nome, - / quantidade / + / X por linha."] call _assert;
["ITEMS-0.12-470",(_srcRender find "fnc_requestEquipmentRowAction")>=0 && {(_srcRender find "fnc_commitEquipmentQuantityFromControl")>=0} && {(_srcRender find "SPORG_Items_equipmentView")>=0},"Controles por linha reutilizam request/executor físico CP-D e carregam VIEW congelado."] call _assert;
["ITEMS-0.12-471",(_srcRender find "EXACT")>=0 && {(_srcRender find "magazine cheio")>=0} && {(_srcRender find "stateData")>=0},"Render/UX preserva distinção EXACT e não esconde a regra de magazine cheio separado no +."] call _assert;
["ITEMS-0.12-472",(_srcDialog find "idc=4142")>=0 && {(_srcDialog find "idc=4143")>=0} && {(_srcDialog find "idc=4144")>=0} && {(_srcRender find "availableLoad")>=0} && {(_srcRender find "ctrlSetPosition")>=0},"Capacidade possui barra dedicada e leitura usada/total/livre baseada nas métricas reais do container."] call _assert;
["ITEMS-0.12-473",(_srcCapture find "EQUIPMENT_ROW_CAPTURE")>=0 && {(_srcCapture find "DRAFT")>=0} && {(_srcCapture find "refreshDraftMutationUI")>=0},"Seta ← de cada linha captura logicamente para o Draft sem usar o caminho físico."] call _assert;
["ITEMS-0.12-474",(_srcDialog find "onMouseMoving")>=0 && {(_srcDrag find "EQUIPMENT_ROW_DRAG_START")>=0} && {(_srcDrag find "DND_EQUIPMENT_TABLE")>=0} && {(_srcDrag find "customPointerDrag")>=0},"DnD Equipment→Draft permanece disponível mesmo com CT_CONTROLS_TABLE, usando drag customizado scoped ao display."] call _assert;
["ITEMS-0.12-475",(_srcFull find "fnc_renderEquipmentRowsUI")>=0 && {(_srcEq find "fnc_renderEquipmentRowsUI")>=0} && {(_srcPhys find "fnc_renderEquipmentRowsUI")>=0},"FULL, EQUIPMENT_FOCUSED e PHYSICAL_FOCUSED convergem ao mesmo renderer de linhas Equipment."] call _assert;
["ITEMS-0.12-476",(_srcDialog find "safeZoneX-1")>=0 && {(_srcDialog find "idc=4120")>=0} && {(_srcDialog find "idc=4130")>=0} && {(_srcDialog find "idc=4133")>=0},"Superfície legada CP-D permanece somente fora da tela para compatibilidade; controles visíveis são os de cada linha."] call _assert;
private _existing=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD; if (!isNull _existing) then {closeDialog 0; uiSleep 0.03;};
private _dialog=createDialog "SP_ORG_Items_Dialog"; uiSleep 0.08;
private _state=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _fullBefore=_state getOrDefault ["fullRefreshCount",0]; ["REFRESH"] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent; uiSleep 0.03;
private _stateAfter=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
["ITEMS-0.12-477",_dialog && {(_stateAfter getOrDefault ["lastRefreshMode",""]) isEqualTo "EQUIPMENT_FOCUSED"} && {(_stateAfter getOrDefault ["fullRefreshCount",-1]) isEqualTo _fullBefore},"ATUALIZAR continua focal: novo renderer de linhas não reintroduz FULL."] call _assert;
private _loadoutAfter=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap]; private _productionAfter=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
["ITEMS-0.12-478",(_loadoutAfter getOrDefault ["serialized","B"]) isEqualTo (_loadoutBefore getOrDefault ["serialized","A"]) && {_productionAfter isEqualTo _productionBefore} && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_B_CUMULATIVE_GATE_COUNT isEqualTo 478},"0.12-B fecha sem mutação física/storage durante a suíte e publica 478/478."] call _assert;
private _displayEnd=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD; if (!isNull _displayEnd) then {closeDialog 0; uiSleep 0.03;};
[_productionBefore] call ServoPeregrino_Organizador_Items_fnc_restoreProductionRepositorySnapshot; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap]; [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
private _durationMs=round ((diag_tickTime-_startedAt)*1000);
private _summary=createHashMapFromArray [["delivery","0.12-B"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],["base",_base],["baseExpected",468],["checkpointFirstGate",469],["checkpointLastGate",478],["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],["cumulativeExpected",478],["cumulativePassed",468+_passed],["durationMs",_durationMs],["equipmentRowCapacityUX",true]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================"; diag_log format ["[SP_ORG] [ITEMS] 0.12-B — BASE=468/468  0.12-B=%1/10  FAIL=%2  CUMULATIVO=%3/478  TEMPO=%4ms",_passed,_failed,468+_passed,_durationMs]; diag_log "[SP_ORG] [ITEMS] 0.12-B — Manual: validar controles por linha, EXACT, ←/DnD para Draft, barra de capacidade e fluidez dos refreshes focais."; diag_log "============================================================";
if (hasInterface) then {hint parseText format ["<t size='1.25'>SP_ORG_Items 0.12-B</t><br/><br/>Baseline 0.12-A: <t color='#7CFC00'>468 / 468</t><br/>0.12-B: <t color='%1'>%2 / 10</t><br/>Cumulativo: %3 / 478<br/><br/>%4",if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_passed,468+_passed,if (_failed isEqualTo 0) then {"Valide Equipment por linha e capacidade."} else {"Consulte o primeiro FAIL no RPT."}];};
_summary
