#include "..\..\script_version.hpp"
disableSerialization;

private _legacyRunningState=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR,createHashMap];
if (_legacyRunningState getOrDefault ["running",false]) exitWith {[false,"ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING","A regressão legada já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _orchestrator=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
if (_orchestrator getOrDefault ["running",false]) exitWith {[false,"ITEMS_0_12_D72_ALREADY_RUNNING","Outra suíte cumulativa já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _startedAt=diag_tickTime;
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.12-D.7.2 — LIBRARY SELECTION & AUDIO HOTFIX — 638 GATES";
diag_log "============================================================";
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun; uiSleep 0.02;
private _base=createHashMapFromArray [["success",false],["code","ITEMS_0_12_D72_BASE_CALL_DID_NOT_RETURN"]];
private _baseCall=[] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_12CheckpointD71Tests;
if !(isNil "_baseCall") then {if (_baseCall isEqualType createHashMap) then {_base=_baseCall;};};
private _baseOk=(_base getOrDefault ["success",false]) && {(_base getOrDefault ["checkpointPassed",0]) isEqualTo 6} && {(_base getOrDefault ["cumulativePassed",0]) isEqualTo 633};
if !(_baseOk) exitWith {
    [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
    private _summary=createHashMapFromArray [["delivery","0.12-D.7.2"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",false],["code","ITEMS_0_12_D72_BASE_633_FAILED"],["base",_base],["checkpointSkipped",true],["checkpointFirstGate",634],["checkpointLastGate",638],["checkpointTotal",0],["checkpointPassed",0],["checkpointFailed",0],["cumulativeExpected",638]];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    diag_log "[SP_ORG] [ITEMS] 0.12-D.7.2 — FAIL-FAST: baseline D.7.1 633/633 não fechou.";
    _summary
};

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.12-D.7.2"]]];
private _passed=0; private _failed=0; private _results=[];
private _assert={params ["_id","_condition","_detail"]; private _ok=(_condition isEqualType true)&&{_condition}; private _status=if (_ok) then {"PASS"} else {"FAIL"}; if (_ok) then {_passed=_passed+1}else{_failed=_failed+1}; _results pushBack [_id,_status,_detail]; diag_log format ["[SP_ORG] [ITEMS] [TEST 0.12-D.7.2] [%1] %2 — %3",_status,_id,_detail];};

private _productionBefore=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _loadoutBefore=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _draftBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _uiBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _publicBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VAR,[]]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;

private _srcDesc=preprocessFileLineNumbers "description.ext";
private _srcCfg=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\config.cpp";
private _srcEvent=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUIEvent.sqf";
private _srcKitSwitch=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshKitSwitchUI.sqf";
private _srcReconcile=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_reconcilePrivateKitSelectionAfterDelete.sqf";

private _gate634=(_srcDesc find "class runDelivery0_12CheckpointD72Tests {}")>=0
    && {(_srcCfg find "class runDelivery0_12CheckpointD72Tests {}")>=0}
    && {(_srcDesc find "class reconcilePrivateKitSelectionAfterDelete {}")>=0}
    && {(_srcCfg find "class reconcilePrivateKitSelectionAfterDelete {}")>=0}
    && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_7_2_GATE_COUNT isEqualTo 5}
    && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_7_2_CUMULATIVE_GATE_COUNT isEqualTo 638}
    && {(SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DISPLAY_VERSION find "0.12-D.7.") isEqualTo 0};
["ITEMS-0.12-634",_gate634,"D.7.2 está registrada, versionada e declara contrato cumulativo 638/638 com helper de reconciliação da seleção."] call _assert;

// Fixtures privados independentes.
private _entryR=["ITEM","FirstAidKit",1,"NONE",[]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _entry=((_entryR getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]]);
private _makeKit={params ["_name","_tag"]; private _kr=[_name,[_entry],"ANY",["TEST",_tag]] call ServoPeregrino_Organizador_Items_fnc_createItemKit; private _k=((_kr getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]]); private _sr=[_k] call ServoPeregrino_Organizador_Items_fnc_saveKit; ((_sr getOrDefault ["data",createHashMap]) getOrDefault ["kitId",""])};
private _idA=["D72 Reconcile A","D72-A"] call _makeKit;
private _idB=["D72 Reconcile B","D72-B"] call _makeKit;
private _idSound=["D72 Sound Source","D72-SOUND"] call _makeKit;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VAR,[SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_MAGIC,SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VERSION,0,[]]];

private _display=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR,displayNull];
if (isNull _display && {hasInterface}) then {createDialog "SP_ORG_Items_Dialog"; uiSleep 0.03; _display=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR,displayNull];};

// 635 — selecionar/carregar kit por refresh focado deve reavaliar PUBLICAR imediatamente; não há dependência de Catálogo.
private _loadA=[_idA] call ServoPeregrino_Organizador_Items_fnc_loadDraftFromKit;
private _state635=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
_state635 set ["kitLibraryMode","PRIVATE"];
_state635 set ["selectedKitId",_idA];
_state635 set ["kitQuery","D72 Reconcile"];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state635];
if (!isNull _display) then {[] call ServoPeregrino_Organizador_Items_fnc_refreshInterface; (_display displayCtrl 1113) ctrlEnable false; ["D72_TEST"] call ServoPeregrino_Organizador_Items_fnc_refreshKitSwitchUI;};
private _publishEnabled635=!isNull _display && {ctrlEnabled (_display displayCtrl 1113)};
private _gate635=(_loadA getOrDefault ["success",false]) && {_publishEnabled635} && {(_srcKitSwitch find "displayCtrl 1113")>=0} && {(_srcKitSwitch find "ctrlEnable")>=0} && {(_srcKitSwitch find "full refresh")>=0};
["ITEMS-0.12-635",_gate635,"PUBLICAR é habilitado no próprio KIT_SWITCH_FOCUSED após selecionar kit privado; Catálogo/full refresh deixam de ser dependência incidental."] call _assert;

// 636 — copiar público para privado deve produzir cue SUCCESS mesmo com áudio suprimido pelo runner.
private _pub=[_idSound,player,"PLAYER","Teste D72","TEST-AUTHOR-D72"] call ServoPeregrino_Organizador_Items_fnc_publishKitToPublic;
private _publicId=((_pub getOrDefault ["data",createHashMap]) getOrDefault ["publicId",""]);
private _state636=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
_state636 set ["kitLibraryMode","PUBLIC"];
_state636 set ["selectedPublicKitId",_publicId];
_state636 set ["kitLibraryActionStatus",""];
_state636 set ["soundHistory",[]];
_state636 set ["lastSoundOutcome",""];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state636];
["SAVE_PUBLIC_PRIVATE"] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent;
private _after636=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _hist636=_after636 getOrDefault ["soundHistory",[]];
private _gate636=(_pub getOrDefault ["success",false]) && {_publicId isNotEqualTo ""} && {(toUpper (_after636 getOrDefault ["kitLibraryActionStatus",""])) isEqualTo "COPIADO"} && {(toUpper (_after636 getOrDefault ["lastSoundOutcome",""])) isEqualTo "SUCCESS"} && {(count _hist636)>=1} && {(_srcEvent find "[_result,true] call _publishResult")>=0};
["ITEMS-0.12-636",_gate636,"SALVAR NO PRIVADO confirma a persistência com feedback visual COPIADO e cue sonoro SUCCESS."] call _assert;

// 637 — após excluir A, a linha visual seguinte B também precisa ser a seleção lógica, sem LOAD_KIT automático.
private _loadA2=[_idA] call ServoPeregrino_Organizador_Items_fnc_loadDraftFromKit;
private _state637=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
_state637 set ["kitLibraryMode","PRIVATE"];
_state637 set ["selectedKitId",_idA];
_state637 set ["kitQuery","D72 Reconcile"];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state637];
if (!isNull _display) then {[] call ServoPeregrino_Organizador_Items_fnc_refreshInterface;};
private _kitsCtrl637=if (isNull _display) then {controlNull} else {_display displayCtrl 1102};
private _idxA637=-1;
if (!isNull _kitsCtrl637) then {for "_i" from 0 to ((lbSize _kitsCtrl637)-1) do {if ((_kitsCtrl637 lbData _i) isEqualTo _idA) exitWith {_idxA637=_i;};};};
private _del637=[_idA] call ServoPeregrino_Organizador_Items_fnc_deleteKitPreservingDraft;
private _state637b=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
_state637b set ["selectedKitId",""];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state637b];
if (!isNull _display) then {[] call ServoPeregrino_Organizador_Items_fnc_refreshInterface;};
private _rec637=if (!isNull _display) then {[_idxA637,_display] call ServoPeregrino_Organizador_Items_fnc_reconcilePrivateKitSelectionAfterDelete} else {createHashMap};
private _after637=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _sel637=if (isNull _kitsCtrl637) then {-1} else {lbCurSel _kitsCtrl637};
private _visibleId637=if (_sel637>=0) then {_kitsCtrl637 lbData _sel637} else {""};
private _gate637=(_loadA2 getOrDefault ["success",false]) && {_idxA637>=0} && {(_del637 getOrDefault ["success",false])} && {(_rec637 getOrDefault ["success",false])} && {(_after637 getOrDefault ["selectedKitId",""]) isEqualTo _idB} && {_visibleId637 isEqualTo _idB} && {ctrlEnabled (_display displayCtrl 1113)} && {(_srcEvent find "fnc_reconcilePrivateKitSelectionAfterDelete")>=0} && {(_srcReconcile find "não destruir o")>=0};
["ITEMS-0.12-637",_gate637,"Excluir um kit reconcilia highlight + selectedKitId no próximo kit visível, mantendo o Rascunho preservado e permitindo excluir/publicar imediatamente."] call _assert;

if (!isNull _display) then {_display closeDisplay 2; uiNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR,displayNull];};
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VAR,_publicBefore];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,_draftBefore];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_uiBefore];
[_productionBefore] call ServoPeregrino_Organizador_Items_fnc_restoreProductionRepositorySnapshot;
private _loadoutAfter=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _productionAfter=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _cmp=[_loadoutBefore,_loadoutAfter,"ITEMS-0.12-638"] call ServoPeregrino_Organizador_Items_fnc_compareLoadoutFingerprints;
private _cmpD=_cmp getOrDefault ["data",createHashMap];
private _changed=_cmpD getOrDefault ["changedIndexes",[]];
private _ambient=!(_cmpD getOrDefault ["equal",false]) && {(count _changed)>0} && {(_changed findIf {!(_x in [0,1,2])})<0};
if (_ambient) then {diag_log format ["[SP_ORG] [ITEMS] [TEST_AMBIENT_DRIFT] label=ITEMS-0.12-638 changedIndexes=%1 accepted=true reason=WEAPON_SLOTS_ONLY",_changed];};
private _gate638=((_cmpD getOrDefault ["equal",false]) || {_ambient}) && {_productionAfter isEqualTo _productionBefore} && {(missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VAR,[]]) isEqualTo _publicBefore};
["ITEMS-0.12-638",_gate638,"D.7.2 restaura Repository/biblioteca/UI/Draft e não deixa mutação física após os smokes de estado/áudio."] call _assert;

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
private _durationMs=round ((diag_tickTime-_startedAt)*1000);
private _summary=createHashMapFromArray [["delivery","0.12-D.7.2"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],["base",_base],["baseExpected",633],["checkpointFirstGate",634],["checkpointLastGate",638],["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],["cumulativeExpected",638],["cumulativePassed",633+_passed],["durationMs",_durationMs],["publishFocusedSync",true],["publicCopySuccessSound",true],["deleteSelectionReconcile",true]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] 0.12-D.7.2 — BASE=633/633  D.7.2=%1/5  FAIL=%2  CUMULATIVO=%3/638  TEMPO=%4ms",_passed,_failed,633+_passed,_durationMs];
diag_log "[SP_ORG] [ITEMS] 0.12-D.7.2 — Manual: PUBLICAR imediato após clique; cópia pública toca confirmação; exclusões consecutivas acompanham seleção visual.";
diag_log "============================================================";
if (hasInterface) then {hint parseText format ["<t size='1.25'>SP_ORG_Items 0.12-D.7.2</t><br/><br/>Baseline D.7.1: <t color='#7CFC00'>633 / 633</t><br/>D.7.2: <t color='%1'>%2 / 5</t><br/>Cumulativo: %3 / 638<br/><br/>%4",if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_passed,633+_passed,if (_failed isEqualTo 0) then {"Valide os três hotfixes manualmente."} else {"Consulte o primeiro FAIL no RPT."}];};
_summary
