#include "..\..\script_version.hpp"
disableSerialization;

private _legacyRunningState=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR,createHashMap];
if (_legacyRunningState getOrDefault ["running",false]) exitWith {[false,"ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING","A regressão legada já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _orchestrator=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
if (_orchestrator getOrDefault ["running",false]) exitWith {[false,"ITEMS_0_12_D71_ALREADY_RUNNING","Outra suíte cumulativa já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _startedAt=diag_tickTime;
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.12-D.7.1 — PRIVATE/PUBLIC LIBRARY UX CLOSE — 633 GATES";
diag_log "============================================================";
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun; uiSleep 0.02;
private _base=createHashMapFromArray [["success",false],["code","ITEMS_0_12_D71_BASE_CALL_DID_NOT_RETURN"]];
private _baseCall=[] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_12CheckpointD70Tests;
if !(isNil "_baseCall") then {if (_baseCall isEqualType createHashMap) then {_base=_baseCall;};};
private _baseOk=(_base getOrDefault ["success",false]) && {(_base getOrDefault ["checkpointPassed",0]) isEqualTo 10} && {(_base getOrDefault ["cumulativePassed",0]) isEqualTo 627};
if !(_baseOk) exitWith {
    [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
    private _summary=createHashMapFromArray [["delivery","0.12-D.7.1"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",false],["code","ITEMS_0_12_D71_BASE_627_FAILED"],["base",_base],["checkpointSkipped",true],["checkpointFirstGate",628],["checkpointLastGate",633],["checkpointTotal",0],["checkpointPassed",0],["checkpointFailed",0],["cumulativeExpected",633]];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    diag_log "[SP_ORG] [ITEMS] 0.12-D.7.1 — FAIL-FAST: baseline D.7.0 627/627 não fechou.";
    _summary
};

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.12-D.7.1"]]];
private _passed=0; private _failed=0; private _results=[];
private _assert={params ["_id","_condition","_detail"]; private _ok=(_condition isEqualType true)&&{_condition}; private _status=if (_ok) then {"PASS"} else {"FAIL"}; if (_ok) then {_passed=_passed+1}else{_failed=_failed+1}; _results pushBack [_id,_status,_detail]; diag_log format ["[SP_ORG] [ITEMS] [TEST 0.12-D.7.1] [%1] %2 — %3",_status,_id,_detail];};

private _productionBefore=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _loadoutBefore=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _draftBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _uiBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _publicBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VAR,[]]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;

private _srcDesc=preprocessFileLineNumbers "description.ext";
private _srcCfg=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\config.cpp";
private _srcDialog=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\ui\items_dialog.hpp";
private _srcEvent=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUIEvent.sqf";
private _srcRefresh=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshInterface.sqf";
private _srcHeader=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshHeaderUI.sqf";
private _srcCopy=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\library\fn_savePublicKitToPrivate.sqf";

private _gate628=(_srcDesc find "class runDelivery0_12CheckpointD71Tests {}")>=0 && {(_srcCfg find "class runDelivery0_12CheckpointD71Tests {}")>=0} && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_7_1_GATE_COUNT isEqualTo 6} && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_7_1_CUMULATIVE_GATE_COUNT isEqualTo 633} && {(SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DISPLAY_VERSION find "0.12-D.7.") isEqualTo 0};
["ITEMS-0.12-628",_gate628,"D.7.1 está registrada, versionada e declara contrato cumulativo 633/633."] call _assert;

private _display=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR,displayNull];
if (isNull _display && {hasInterface}) then {createDialog "SP_ORG_Items_Dialog"; uiSleep 0.03; _display=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR,displayNull];};
if (!isNull _display) then {[player] call ServoPeregrino_Organizador_Items_fnc_refreshHeaderUI;};
private _loadText=if (isNull _display) then {""} else {ctrlText (_display displayCtrl 104)};
private _gate629=!isNull _display && {(_loadText find "Carga: ") isEqualTo 0} && {(_loadText find " / ")>=0} && {(_loadText find " kg - ")>=0} && {(_loadText find "%")>=0} && {(_loadText find "lb")<0} && {(_srcHeader find "_currentLb")<0} && {(_srcHeader find "Carga: %1 / %2 kg - %3%%")>=0};
["ITEMS-0.12-629",_gate629,"Linha de Carga do header mantém usado/total + percentual em kg e remove lb da apresentação principal."] call _assert;

// Fixture isolado pela restauração integral ao final deste checkpoint.
private _entryR=["ITEM","FirstAidKit",1,"NONE",[]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _entry=((_entryR getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]]);
private _kitR=["Infantaria",[_entry],"ANY",["TEST","D71"]] call ServoPeregrino_Organizador_Items_fnc_createItemKit;
private _kit=((_kitR getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]]);
private _save=[_kit] call ServoPeregrino_Organizador_Items_fnc_saveKit;
private _privateId=((_save getOrDefault ["data",createHashMap]) getOrDefault ["kitId",""]);
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VAR,[SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_MAGIC,SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VERSION,0,[]]];
private _pub=[_privateId,player,"PLAYER","Teste D71","TEST-AUTHOR-D71"] call ServoPeregrino_Organizador_Items_fnc_publishKitToPublic;
private _publicId=((_pub getOrDefault ["data",createHashMap]) getOrDefault ["publicId",""]);
private _copy=[_publicId] call ServoPeregrino_Organizador_Items_fnc_savePublicKitToPrivate;
private _copyD=_copy getOrDefault ["data",createHashMap];
private _copyId=_copyD getOrDefault ["kitId",""];
private _copyGet=[_copyId] call ServoPeregrino_Organizador_Items_fnc_getKit;
private _copyKit=((_copyGet getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]]);
private _gate630=(_copy getOrDefault ["success",false]) && {_copyGet getOrDefault ["success",false]} && {_copyId isNotEqualTo _privateId} && {(_copyKit#3) isEqualTo "Cópia Infantaria"} && {((_copyKit#5)#0) isEqualTo "PUBLIC_COPY"} && {(_srcCopy find "Cópia ")>=0};
["ITEMS-0.12-630",_gate630,"SALVAR NO PRIVADO cria novo ID/origem PUBLIC_COPY e nomeia o clone como 'Cópia <nome público>'."] call _assert;

private _state=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
_state set ["kitLibraryMode","PUBLIC"];
_state set ["selectedPublicKitId",_publicId];
_state set ["kitQuery","inf"];
_state set ["kitLibraryActionStatus",""];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state];
["SAVE_PUBLIC_PRIVATE"] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent;
private _afterCopy=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _gate631=(_afterCopy getOrDefault ["kitLibraryMode",""]) isEqualTo "PUBLIC" && {(_afterCopy getOrDefault ["kitQuery",""]) isEqualTo "inf"} && {(_afterCopy getOrDefault ["selectedPublicKitId",""]) isEqualTo _publicId} && {(_afterCopy getOrDefault ["selectedKitId",""]) isNotEqualTo ""};
["ITEMS-0.12-631",_gate631,"Copiar da aba PÚBLICOS preserva a aba, a busca e a seleção pública para permitir várias cópias em sequência."] call _assert;

private _copyBadge=toUpper (_afterCopy getOrDefault ["kitLibraryActionStatus",""]);
private _statePublish=_afterCopy;
_statePublish set ["kitLibraryMode","PRIVATE"];
_statePublish set ["selectedKitId",_privateId];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_statePublish];
["PUBLISH_KIT"] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent;
private _afterPublish=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _publishBadge=toUpper (_afterPublish getOrDefault ["kitLibraryActionStatus",""]);
private _gate632=(_copyBadge isEqualTo "COPIADO") && {_publishBadge isEqualTo "PUBLICADO"} && {(_srcDialog find "KitsActionStatus")>=0} && {(_srcRefresh find "COPIADO")>=0} && {(_srcRefresh find "PUBLICADO")>=0};
["ITEMS-0.12-632",_gate632,"MEUS KITS materializa badge de ação e alterna para COPIADO/PUBLICADO somente após operações bem-sucedidas."] call _assert;

if (!isNull _display) then {_display closeDisplay 2; uiNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR,displayNull];};
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VAR,_publicBefore];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,_draftBefore];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_uiBefore];
[_productionBefore] call ServoPeregrino_Organizador_Items_fnc_restoreProductionRepositorySnapshot;
private _loadoutAfter=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _productionAfter=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _cmp=[_loadoutBefore,_loadoutAfter,"ITEMS-0.12-633"] call ServoPeregrino_Organizador_Items_fnc_compareLoadoutFingerprints;
private _cmpD=_cmp getOrDefault ["data",createHashMap];
private _changed=_cmpD getOrDefault ["changedIndexes",[]];
private _ambient=!(_cmpD getOrDefault ["equal",false]) && {(count _changed)>0} && {(_changed findIf {!(_x in [0,1,2])})<0};
if (_ambient) then {diag_log format ["[SP_ORG] [ITEMS] [TEST_AMBIENT_DRIFT] label=ITEMS-0.12-633 changedIndexes=%1 accepted=true reason=WEAPON_SLOTS_ONLY",_changed];};
private _gate633=((_cmpD getOrDefault ["equal",false]) || {_ambient}) && {_productionAfter isEqualTo _productionBefore} && {(missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VAR,[]]) isEqualTo _publicBefore};
["ITEMS-0.12-633",_gate633,"D.7.1 restaura Repository/biblioteca/UI/Draft e não deixa mutação física após os smokes de fechamento UX."] call _assert;

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
private _durationMs=round ((diag_tickTime-_startedAt)*1000);
private _summary=createHashMapFromArray [["delivery","0.12-D.7.1"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],["base",_base],["baseExpected",627],["checkpointFirstGate",628],["checkpointLastGate",633],["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],["cumulativeExpected",633],["cumulativePassed",627+_passed],["durationMs",_durationMs],["headerLoadKgOnly",true],["publicCopyPrefix","Cópia "],["stayOnPublicAfterCopy",true],["libraryActionBadge",true]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] 0.12-D.7.1 — BASE=627/627  D.7.1=%1/6  FAIL=%2  CUMULATIVO=%3/633  TEMPO=%4ms",_passed,_failed,627+_passed,_durationMs];
diag_log "[SP_ORG] [ITEMS] 0.12-D.7.1 — Manual: carga header só kg; cópia nomeada; permanecer em PÚBLICOS; badges COPIADO/PUBLICADO.";
diag_log "============================================================";
if (hasInterface) then {hint parseText format ["<t size='1.25'>SP_ORG_Items 0.12-D.7.1</t><br/><br/>Baseline D.7.0: <t color='#7CFC00'>627 / 627</t><br/>D.7.1: <t color='%1'>%2 / 6</t><br/>Cumulativo: %3 / 633<br/><br/>%4",if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_passed,627+_passed,if (_failed isEqualTo 0) then {"Valide o fechamento UX manualmente."} else {"Consulte o primeiro FAIL no RPT."}];};
_summary
