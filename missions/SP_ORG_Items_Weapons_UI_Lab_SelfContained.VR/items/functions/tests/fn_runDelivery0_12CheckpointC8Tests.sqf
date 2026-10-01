#include "..\..\script_version.hpp"
disableSerialization;
private _legacyRunningState=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR,createHashMap];
if (_legacyRunningState getOrDefault ["running",false]) exitWith {[false,"ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING","A regressão legada já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _orchestrator=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
if (_orchestrator getOrDefault ["running",false]) exitWith {[false,"ITEMS_0_12_C8_ALREADY_RUNNING","Outra suíte cumulativa já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _startedAt=diag_tickTime;
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.12-C.8 — DRAG VISUAL PROXY / ITEM GHOST — 536 GATES";
diag_log "============================================================";
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun; uiSleep 0.02;
private _base=createHashMapFromArray [["success",false],["code","ITEMS_0_12_C8_BASE_CALL_DID_NOT_RETURN"]];
private _baseCall=[] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_12CheckpointC7Tests;
if !(isNil "_baseCall") then {if (_baseCall isEqualType createHashMap) then {_base=_baseCall;};};
private _baseOk=(_base getOrDefault ["success",false]) && {(_base getOrDefault ["checkpointPassed",0]) isEqualTo 6} && {(_base getOrDefault ["cumulativePassed",0]) isEqualTo 530};
if !(_baseOk) exitWith {
    [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
    private _summary=createHashMapFromArray [["delivery","0.12-C.8"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",false],["code","ITEMS_0_12_C8_BASE_530_FAILED"],["base",_base],["checkpointSkipped",true],["checkpointFirstGate",531],["checkpointLastGate",536],["checkpointTotal",0],["checkpointPassed",0],["checkpointFailed",0],["cumulativeExpected",536]];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    diag_log "[SP_ORG] [ITEMS] 0.12-C.8 — FAIL-FAST: baseline 0.12-C.7 530/530 não fechou.";
    _summary
};
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.12-C.8"]]];
private _passed=0; private _failed=0; private _results=[];
private _assert={params ["_id","_condition","_detail"]; private _ok=(_condition isEqualType true)&&{_condition}; private _status=if (_ok) then {"PASS"} else {"FAIL"}; if (_ok) then {_passed=_passed+1}else{_failed=_failed+1}; _results pushBack [_id,_status,_detail]; diag_log format ["[SP_ORG] [ITEMS] [TEST 0.12-C.8] [%1] %2 — %3",_status,_id,_detail];};

private _productionBefore=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _loadoutBefore=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _draftStateBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _uiStateBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;

private _srcDialog=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\ui\items_dialog.hpp";
private _srcProxy=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_updateUIDragVisualProxy.sqf";
private _srcDrag=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUIDragEvent.sqf";
private _srcCancel=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_cancelUIDrag.sqf";
private _srcPointer=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_resolveUIPointerSource.sqf";

// 531 modernizado na C.8.1: o requisito continua sendo proxy pass-through, mas a implementação correta agora é runtime/top-layer.
private _gate531=(_srcDialog find "DragGhostBg")<0 && {(_srcDialog find "DragGhostIcon")<0} && {(_srcDialog find "DragGhostText")<0} && {(_srcProxy find "ctrlCreate")>=0} && {(_srcProxy find "RscStructuredText")>=0} && {(_srcProxy find "ctrlEnable false")>=0} && {(_srcProxy find "ctrlShow true")>=0} && {(_srcProxy find "getMousePosition")>=0} && {(_srcProxy find "ctrlDelete")>=0} && {(_srcDrag find "updateUIDragVisualProxy")>=0} && {(_srcCancel find "updateUIDragVisualProxy")>=0};
["ITEMS-0.12-531",_gate531,"Proxy visual permanece não interativo e ligado a START/MOVE/CANCEL, agora criado em runtime acima das tabelas e destruído deterministicamente no fim do gesto."] call _assert;

private _snap=["CATALOG",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_TABLE_IDC,"FirstAidKit","FirstAidKit","Kit de Primeiros Socorros","\A3\ui_f\data\igui\cfg\simpletasks\types\heal_ca.paa"] call ServoPeregrino_Organizador_Items_fnc_createUIDragSnapshot;
private _snapDrag=((_snap getOrDefault ["data",createHashMap]) getOrDefault ["drag",createHashMap]);
private _gate532=(_snap getOrDefault ["success",false]) && {(_snapDrag getOrDefault ["sourceText",""]) isEqualTo "Kit de Primeiros Socorros"} && {(_snapDrag getOrDefault ["sourcePicture",""]) isEqualTo "\A3\ui_f\data\igui\cfg\simpletasks\types\heal_ca.paa"};
["ITEMS-0.12-532",_gate532,"Snapshot do drag congela picture + texto junto com identidade/payload; o proxy não reconsulta catálogo/inventário a cada movimento."] call _assert;

private _stateForUI=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
_stateForUI set ["catalogQuery",""]; _stateForUI set ["catalogCategory","ALL"]; _stateForUI set ["catalogOffset",0]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_stateForUI];
private _existing=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD; if (!isNull _existing) then {closeDialog 0; uiSleep 0.03;};
private _dialog=createDialog "SP_ORG_Items_Dialog"; uiSleep 0.12;
private _display=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
private _showOk=if (isNull _display) then {false} else {["SHOW",_snapDrag,_display,safeZoneX+0.40*safeZoneW,safeZoneY+0.40*safeZoneH,false] call ServoPeregrino_Organizador_Items_fnc_updateUIDragVisualProxy};
private _ghost=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAG_GHOST_CTRL_VAR,controlNull];
private _p1=if (isNull _ghost) then {[]} else {ctrlPosition _ghost};
private _gate533=_showOk && {!isNull _ghost} && {ctrlShown _ghost} && {!(ctrlEnabled _ghost)} && {(ctrlIDC _ghost) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAG_GHOST_RUNTIME_IDC} && {(count _p1) isEqualTo 4};
["ITEMS-0.12-533",_gate533,"Smoke runtime: SHOW cria um único StructuredText runtime, visível e disabled/pass-through, em vez de depender de três controles estáticos do diálogo."] call _assert;

private _moveBefore=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAG_GHOST_MOVE_COUNT_VAR,0];
private _moveOk=if (isNull _display) then {false} else {["MOVE",_snapDrag,_display,safeZoneX+0.78*safeZoneW,safeZoneY+0.72*safeZoneH,false] call ServoPeregrino_Organizador_Items_fnc_updateUIDragVisualProxy};
private _p2=if (isNull _ghost) then {[]} else {ctrlPosition _ghost};
private _moveAfter=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAG_GHOST_MOVE_COUNT_VAR,0];
private _gate534=_moveOk && {_moveAfter>_moveBefore} && {(count _p1) isEqualTo 4} && {(count _p2) isEqualTo 4} && {abs ((_p2#0)-(_p1#0)) > (20*pixelW)} && {abs ((_p2#1)-(_p1#1)) > (20*pixelH)} && {(_p2#0)>=safeZoneX} && {(_p2#1)>=safeZoneY} && {((_p2#0)+(_p2#2))<=(safeZoneX+safeZoneW+0.0001)} && {((_p2#1)+(_p2#3))<=(safeZoneY+safeZoneH+0.0001)};
["ITEMS-0.12-534",_gate534,"Proxy runtime aceita MOVE, incrementa telemetria e muda de posição mantendo clamp dentro da safeZone; não executa transferência."] call _assert;

private _catTable=if (isNull _display) then {controlNull} else {_display displayCtrl SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_TABLE_IDC};
private _sourceWithPicture=createHashMap;
if (!isNull _catTable && {(ctRowCount _catTable)>0}) then {
    private _tp=ctrlPosition _catTable;
    for "_ri" from 0 to ((ctRowCount _catTable)-1) do {
        private _cs=_catTable ctRowControls _ri;
        private _nameCtrl=_cs param [3,controlNull,[controlNull]];
        private _picCtrl=_cs param [2,controlNull,[controlNull]];
        if (!isNull _nameCtrl && {!isNull _picCtrl} && {(ctrlText _picCtrl) isNotEqualTo ""}) exitWith {
            private _np=ctrlPosition _nameCtrl;
            _sourceWithPicture=[_display,(_tp#0)+(_np#0)+(_np#2)*0.5,(_tp#1)+(_np#1)+(_np#3)*0.5,false] call ServoPeregrino_Organizador_Items_fnc_resolveUIPointerSource;
        };
    };
};
private _gate535=(_srcPointer find "sourcePicture")>=0 && {(_sourceWithPicture getOrDefault ["found",false])} && {(_sourceWithPicture getOrDefault ["sourceType",""]) isEqualTo "CATALOG"} && {(_sourceWithPicture getOrDefault ["sourcePicture",""]) isNotEqualTo ""};
["ITEMS-0.12-535",_gate535,"Resolvedor da CatalogTable entrega o picture materializado à mesma origem que fornece texto/payload; ghost e operação representam a mesma linha."] call _assert;

private _state=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
_state set ["dragState",_snapDrag]; _state set ["pointerDragCandidate",createHashMapFromArray [["found",true],["sourceType","CATALOG"]]]; _state set ["pointerDragTravel",42]; _state set ["pointerButtonDown",true]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state];
["C8_PROXY_CLEANUP_TEST"] call ServoPeregrino_Organizador_Items_fnc_cancelUIDrag;
private _stateAfter=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _ghostAfter=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAG_GHOST_CTRL_VAR,controlNull];
private _loadoutAfter=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _productionAfter=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _gate536=(isNull _ghostAfter) && {!((_stateAfter getOrDefault ["dragState",createHashMap]) getOrDefault ["active",true])} && {!(_stateAfter getOrDefault ["pointerButtonDown",true])} && {(_srcProxy find "executeUITransferCommand")<0} && {(_srcProxy find "refreshPhysicalMutationUI")<0} && {(_srcProxy find "refreshDraftMutationUI")<0} && {(_loadoutAfter getOrDefault ["serialized","B"]) isEqualTo (_loadoutBefore getOrDefault ["serialized","A"])} && {_productionAfter isEqualTo _productionBefore} && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_C_8_CUMULATIVE_GATE_COUNT isEqualTo 536};
["ITEMS-0.12-536",_gate536,"CANCEL destrói o controle runtime, limpa gesto e mantém a camada visual isolada de dispatcher/refresh mutável/loadout/storage; baseline histórica permanece 536/536."] call _assert;

private _displayEnd=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD; if (!isNull _displayEnd) then {closeDialog 0; uiSleep 0.03;};
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,_draftStateBefore];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_uiStateBefore];
[_productionBefore] call ServoPeregrino_Organizador_Items_fnc_restoreProductionRepositorySnapshot;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
private _durationMs=round ((diag_tickTime-_startedAt)*1000);
private _summary=createHashMapFromArray [["delivery","0.12-C.8"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],["base",_base],["baseExpected",530],["checkpointFirstGate",531],["checkpointLastGate",536],["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],["cumulativeExpected",536],["cumulativePassed",530+_passed],["durationMs",_durationMs],["visualProxy",true],["runtimeTopLayer",true],["proxyPassThrough",true],["pointerAuthorityPreserved","DISPLAY_POINTER"],["manualVisualValidationRequired",true]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] 0.12-C.8 — BASE=530/530  C.8=%1/6  FAIL=%2  CUMULATIVO=%3/536  TEMPO=%4ms",_passed,_failed,530+_passed,_durationMs];
diag_log "[SP_ORG] [ITEMS] 0.12-C.8 — Requisito visual preservado, implementação modernizada para ghost runtime/top-layer na descendente C.8.1.";
diag_log "============================================================";
_summary
