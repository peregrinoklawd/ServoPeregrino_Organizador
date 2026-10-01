#include "..\..\script_version.hpp"
disableSerialization;

private _legacyRunningState = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR, createHashMap];
if (_legacyRunningState getOrDefault ["running", false]) exitWith {
    [false,"ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING","A regressão legada já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _orchestrator = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR, createHashMap];
if (_orchestrator getOrDefault ["running", false]) exitWith {
    [false,"ITEMS_0_11_CP_A_ALREADY_RUNNING","Outra suíte cumulativa já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _startedAt=diag_tickTime;
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.11 CP-A.1 — CLEAR SEMANTICS & FEEDBACK — 406 GATES";
diag_log "============================================================";

[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
uiSleep 0.02;
private _base=[] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_10_0_7HotfixTests;
private _baseOk=(_base isEqualType createHashMap)
    && {_base getOrDefault ["success",false]}
    && {(_base getOrDefault ["checkpointPassed",0]) isEqualTo 8}
    && {(_base getOrDefault ["cumulativePassed",0]) isEqualTo 398};
if !(_baseOk) exitWith {
    [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
    private _summary=createHashMapFromArray [
        ["delivery","0.11 CP-A.1"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",false],
        ["code","ITEMS_0_11_CP_A_BASE_398_FAILED"],["base",_base],["checkpointSkipped",true],
        ["checkpointFirstGate",399],["checkpointLastGate",406],["checkpointTotal",0],["checkpointPassed",0],["checkpointFailed",0],
        ["cumulativeExpected",406]
    ];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    diag_log "[SP_ORG] [ITEMS] 0.11 CP-A.1 — FAIL-FAST: baseline 398/398 não fechou; gates 399..406 NÃO executados.";
    if (hasInterface) then {hint "SP_ORG_Items 0.11 CP-A.1 reprovado na baseline 398/398. Consulte o primeiro FAIL no RPT.";};
    _summary
};

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.11 CP-A.1"]]];
private _passed=0; private _failed=0; private _results=[];
private _assert={
    params ["_id","_condition","_detail"];
    private _status=if (_condition) then {"PASS"} else {"FAIL"};
    if (_condition) then {_passed=_passed+1;} else {_failed=_failed+1;};
    _results pushBack [_id,_status,_detail];
    diag_log format ["[SP_ORG] [ITEMS] [TEST 0.11 CP-A.1] [%1] %2 — %3",_status,_id,_detail];
};

private _oldAppState=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _oldDraftState=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _oldUIState=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _oldRepository=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_REPOSITORY_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _oldCatalogCache=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_CACHE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _oldCatalogMetrics=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_METRICS_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _oldCatalogBuildState=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_BUILD_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;

private _setAppReady={
    private _s=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
    if ((count _s) isEqualTo 0) then {_s=createHashMap;};
    _s set ["ready",true]; _s set ["executing",false]; _s set ["lockToken",""]; _s set ["lockOwner",""]; _s set ["activePlanId",""];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_STATE_VAR,_s];
};
call _setAppReady;
private _resetDraft={missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMapFromArray [["ready",true],["hasDraft",false],["current",createHashMap],["baseline",createHashMap],["revision",0],["lastAction","NONE"]]];};
private _makeEntry={
    params ["_type","_class","_qty","_mode","_states"];
    private _r=[_type,_class,_qty,_mode,_states] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
    ((_r getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]])
};
private _fingerprint={
    params ["_obj"];
    private _r=[_obj,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_getMutableContentFingerprint;
    (((_r getOrDefault ["data",createHashMap]) getOrDefault ["fingerprint",createHashMap]) getOrDefault ["serialized",""])
};
private _entriesOf={
    params ["_obj"];
    private _r=[_obj,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_captureContainerContent;
    (_r getOrDefault ["data",createHashMap]) getOrDefault ["entries",[]]
};
private _optsFor={
    params ["_obj","_origin"];
    createHashMapFromArray [["testResolvedTarget",createHashMapFromArray [["target","TEST_CONTAINER"],["container",_obj],["containerClass","GroundWeaponHolder_Scripted"]]],["commandOrigin",_origin]]
};

// 399 — LIMPAR Kit é lógico: zera entries e marca Draft dirty.
call _resetDraft;
private _e399a=["ITEM","FirstAidKit",2,"NONE",[]] call _makeEntry;
private _e399b=["MAGAZINE","30Rnd_65x39_caseless_mag",1,"EXACT",[17]] call _makeEntry;
private _new399=["Clear Draft 399","ANY",["TEST","399"],[_e399a,_e399b]] call ServoPeregrino_Organizador_Items_fnc_createNewDraft;
private _clear399=if (_new399 getOrDefault ["success",false]) then {[] call ServoPeregrino_Organizador_Items_fnc_clearDraftEntries} else {createHashMap};
private _d399=([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap];
private _cur399=_d399 getOrDefault ["current",createHashMap];
private _gate399=(_clear399 getOrDefault ["success",false])
    && {(_clear399 getOrDefault ["code",""]) isEqualTo "ITEMS_DRAFT_ENTRIES_CLEARED"}
    && {(count (_cur399 getOrDefault ["entries",[]])) isEqualTo 0}
    && {_cur399 getOrDefault ["dirty",false]}
    && {(_d399 getOrDefault ["lastAction",""]) isEqualTo "CLEAR_ENTRIES"};
["ITEMS-0.11-399",_gate399,"LIMPAR no Kit Selecionado zera somente entries do Draft e mantém estado dirty para SALVAR explícito."] call _assert;

// 400 — LIMPAR Draft não toca Repository nem conteúdo físico.
call _resetDraft;
private _target400=createVehicleLocal ["GroundWeaponHolder_Scripted",[0,0,0],[],0,"CAN_COLLIDE"];
if (!isNull _target400) then {_target400 addItemCargoGlobal ["ToolKit",1];};
private _fpBefore400=if (!isNull _target400) then {[_target400] call _fingerprint} else {""};
private _repoBefore400=str (missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_REPOSITORY_VAR,createHashMap]);
private _e400=["ITEM","Medikit",1,"NONE",[]] call _makeEntry;
private _new400=["Logical Only 400","ANY",["TEST","400"],[_e400]] call ServoPeregrino_Organizador_Items_fnc_createNewDraft;
private _clear400=if (_new400 getOrDefault ["success",false]) then {[] call ServoPeregrino_Organizador_Items_fnc_clearDraftEntries} else {createHashMap};
private _fpAfter400=if (!isNull _target400) then {[_target400] call _fingerprint} else {"X"};
private _repoAfter400=str (missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_REPOSITORY_VAR,createHashMap]);
private _clearData400=_clear400 getOrDefault ["data",createHashMap];
private _gate400=!isNull _target400 && {_clear400 getOrDefault ["success",false]} && {_fpBefore400 isEqualTo _fpAfter400} && {_repoBefore400 isEqualTo _repoAfter400} && {!(_clearData400 getOrDefault ["mutatesInventory",true])};
["ITEMS-0.11-400",_gate400,"LIMPAR Draft não muta Repository nem container físico e declara mutatesInventory=false."] call _assert;

// 401 — limpar Draft vazio é idempotente e não incrementa revisão.
private _revBefore401=_d399 getOrDefault ["revision",-1];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMapFromArray [["ready",true],["hasDraft",true],["current",[_cur399] call ServoPeregrino_Organizador_Items_fnc_deepCopy],["baseline",createHashMap],["revision",_revBefore401],["lastAction","CLEAR_ENTRIES"]]];
private _clear401=[] call ServoPeregrino_Organizador_Items_fnc_clearDraftEntries;
private _d401=([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap];
private _gate401=(_clear401 getOrDefault ["success",false]) && {(_clear401 getOrDefault ["code",""]) isEqualTo "ITEMS_DRAFT_CLEAR_NOOP"} && {(_d401 getOrDefault ["revision",-2]) isEqualTo _revBefore401};
["ITEMS-0.11-401",_gate401,"LIMPAR um Kit/Draft já vazio é NOOP idempotente e não fabrica nova revisão."] call _assert;

// 402 — LIMPAR Equipment usa CLEAR físico explícito do VIEW e gera trace.
private _target402=createVehicleLocal ["GroundWeaponHolder_Scripted",[0,0,0],[],0,"CAN_COLLIDE"];
if (!isNull _target402) then {_target402 addItemCargoGlobal ["FirstAidKit",2]; _target402 addMagazineAmmoCargo ["30Rnd_65x39_caseless_mag",1,17];};
private _opts402=[_target402,"TEST_EQUIPMENT_CLEAR_402"] call _optsFor;
private _clear402=if (!isNull _target402) then {[player,"U",_opts402] call ServoPeregrino_Organizador_Items_fnc_executeEquipmentClear} else {createHashMap};
private _entries402=if (!isNull _target402) then {[_target402] call _entriesOf} else {[1]};
private _cmd402=((_clear402 getOrDefault ["data",createHashMap]) getOrDefault ["uiCommand",createHashMap]);
private _trace402=((_clear402 getOrDefault ["data",createHashMap]) getOrDefault ["physicalTrace",createHashMap]);
private _gate402=(_clear402 getOrDefault ["success",false]) && {(count _entries402) isEqualTo 0} && {(_cmd402 getOrDefault ["operation",""]) isEqualTo "CLEAR"} && {(_cmd402 getOrDefault ["requestedTarget",""]) isEqualTo "U"} && {(_cmd402 getOrDefault ["commandOrigin",""]) isEqualTo "TEST_EQUIPMENT_CLEAR_402"} && {(_trace402 getOrDefault ["commandId",""]) isEqualTo (_cmd402 getOrDefault ["commandId","-"])};
["ITEMS-0.11-402",_gate402,"LIMPAR no Conteúdo do Equipamento executa CLEAR físico explícito do equipmentView e mantém commandId/trace."] call _assert;

// 403 — applicationTarget divergente não redireciona LIMPAR Equipment.
private _target403A=createVehicleLocal ["GroundWeaponHolder_Scripted",[0,0,0],[],0,"CAN_COLLIDE"];
private _target403B=createVehicleLocal ["GroundWeaponHolder_Scripted",[0,0,0],[],0,"CAN_COLLIDE"];
if (!isNull _target403A) then {_target403A addItemCargoGlobal ["FirstAidKit",1];};
if (!isNull _target403B) then {_target403B addItemCargoGlobal ["ToolKit",1];};
private _ui403=[] call ServoPeregrino_Organizador_Items_fnc_createUIState; _ui403 set ["applicationTarget","C"]; _ui403 set ["equipmentView","U"]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_ui403];
private _fpB403=if (!isNull _target403B) then {[_target403B] call _fingerprint} else {""};
private _clear403=if (!isNull _target403A) then {[player,"U",[_target403A,"TEST_VIEW_U_403"] call _optsFor] call ServoPeregrino_Organizador_Items_fnc_executeEquipmentClear} else {createHashMap};
private _afterA403=if (!isNull _target403A) then {[_target403A] call _entriesOf} else {[1]};
private _afterB403=if (!isNull _target403B) then {[_target403B] call _fingerprint} else {"X"};
private _cmd403=((_clear403 getOrDefault ["data",createHashMap]) getOrDefault ["uiCommand",createHashMap]);
private _gate403=(_clear403 getOrDefault ["success",false]) && {(count _afterA403) isEqualTo 0} && {_fpB403 isEqualTo _afterB403} && {(_cmd403 getOrDefault ["requestedTarget",""]) isEqualTo "U"};
["ITEMS-0.11-403",_gate403,"LIMPAR Equipment usa VIEW U mesmo com applicationTarget=C e não toca outro container."] call _assert;

// 404 — CLEAR Equipment preserva weapons/backpacks reservados.
private _target404=createVehicleLocal ["GroundWeaponHolder_Scripted",[0,0,0],[],0,"CAN_COLLIDE"];
if (!isNull _target404) then {_target404 addItemCargoGlobal ["FirstAidKit",2]; _target404 addWeaponCargoGlobal ["arifle_MX_F",1]; _target404 addBackpackCargoGlobal ["B_AssaultPack_khk",1];};
private _weaponsBefore404=if (!isNull _target404) then {getWeaponCargo _target404} else {[]};
private _packsBefore404=if (!isNull _target404) then {getBackpackCargo _target404} else {[]};
private _clear404=if (!isNull _target404) then {[player,"M",[_target404,"TEST_RESERVED_404"] call _optsFor] call ServoPeregrino_Organizador_Items_fnc_executeEquipmentClear} else {createHashMap};
private _weaponsAfter404=if (!isNull _target404) then {getWeaponCargo _target404} else {[1]};
private _packsAfter404=if (!isNull _target404) then {getBackpackCargo _target404} else {[1]};
private _mutableAfter404=if (!isNull _target404) then {[_target404] call _entriesOf} else {[1]};
private _gate404=(_clear404 getOrDefault ["success",false]) && {_weaponsBefore404 isEqualTo _weaponsAfter404} && {_packsBefore404 isEqualTo _packsAfter404} && {(count _mutableAfter404) isEqualTo 0};
["ITEMS-0.11-404",_gate404,"LIMPAR Equipment remove só CONTENT mutável e preserva weapons/backpacks reservados."] call _assert;

// 405 — feedback persiste severidade e usa paleta distinta.
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_createUIState;
["Operação concluída","SUCCESS"] call ServoPeregrino_Organizador_Items_fnc_pushUIFeedback;
private _uiSuccess405=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
// HashMaps são referências em SQF. Capture os valores do primeiro estado antes de registrar WARN;
// caso contrário a segunda chamada atualiza o mesmo mapa e transforma a suposta fotografia SUCCESS em WARN.
private _successKind405=_uiSuccess405 getOrDefault ["lastFeedbackKind",""];
private _successHistory405=+(_uiSuccess405 getOrDefault ["history",[]]);
private _palSuccess405=["SUCCESS"] call ServoPeregrino_Organizador_Items_fnc_getUIFeedbackPalette;
["Operação parcial","WARN"] call ServoPeregrino_Organizador_Items_fnc_pushUIFeedback;
private _uiWarn405=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _warnKind405=_uiWarn405 getOrDefault ["lastFeedbackKind",""];
private _palWarn405=["WARN"] call ServoPeregrino_Organizador_Items_fnc_getUIFeedbackPalette;
private _hist405=+(_uiWarn405 getOrDefault ["history",[]]);
private _gate405=_successKind405 isEqualTo "SUCCESS"
    && {_warnKind405 isEqualTo "WARN"}
    && {(count _successHistory405) isEqualTo 1}
    && {((_successHistory405 select 0)#0) isEqualTo "SUCCESS"}
    && {(count _hist405) >= 2}
    && {((_hist405 select ((count _hist405)-2))#0) isEqualTo "SUCCESS"}
    && {((_hist405 select ((count _hist405)-1))#0) isEqualTo "WARN"}
    && {(_palSuccess405 getOrDefault ["messageColor",""]) isNotEqualTo (_palWarn405 getOrDefault ["messageColor",""])};
["ITEMS-0.11-405",_gate405,"Feedback guarda SUCCESS/WARN no estado/histórico e paletas visuais são distintas."] call _assert;

// 406 — controles e textos visuais distinguem LIMPAR Kit de LIMPAR Equipment.
private _seed406=createHashMapFromArray [["className","FirstAidKit"],["displayName","First Aid Kit"],["addon","SP_ORG_TEST_FIXTURE"],["categoryId","MEDICAL"],["picture",""]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_CACHE_VAR,createHashMapFromArray [["provider",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_PROVIDER],["catalogModelVersion",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_MODEL_VERSION],["buildKey",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["builtAtUTC",systemTimeUTC],["items",[_seed406]],["index",createHashMapFromArray [["FirstAidKit",_seed406]]]]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_BUILD_STATE_VAR,createHashMapFromArray [["running",false],["completed",true],["currentRoot",""] ,["visitedConfigClasses",0],["candidateCount",1],["itemCount",1]]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _ui406=[] call ServoPeregrino_Organizador_Items_fnc_createUIState; _ui406 set ["applicationTarget","C"]; _ui406 set ["equipmentView","U"]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_ui406];
private _open406=[] call ServoPeregrino_Organizador_Items_fnc_openInterface;
uiSleep 0.04;
private _display406=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
private _gate406=false;
if ((_open406 getOrDefault ["success",false]) && {!isNull _display406}) then {
    private _save406=_display406 displayCtrl 2140;
    private _saveAs406=_display406 displayCtrl 2141;
    private _discard406=_display406 displayCtrl 2142;
    private _kitClear406=_display406 displayCtrl 2153;
    private _eqClear406=_display406 displayCtrl 4124;
    private _uiAfter406=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
    private _controls406=!isNull _save406 && {!isNull _saveAs406} && {!isNull _discard406} && {!isNull _kitClear406} && {!isNull _eqClear406};
    private _sameEditRow406=false;
    if (_controls406) then {
        private _pSave406=ctrlPosition _save406;
        private _pSaveAs406=ctrlPosition _saveAs406;
        private _pDiscard406=ctrlPosition _discard406;
        private _pKitClear406=ctrlPosition _kitClear406;
        _sameEditRow406=abs ((_pSave406#1)-(_pKitClear406#1)) < 0.002
            && {abs ((_pSaveAs406#1)-(_pKitClear406#1)) < 0.002}
            && {abs ((_pDiscard406#1)-(_pKitClear406#1)) < 0.002}
            && {(_pKitClear406#0) > (_pDiscard406#0)};
    };
    _gate406=_controls406
        && {(ctrlText _kitClear406) isEqualTo "LIMPAR"}
        && {(ctrlText _eqClear406) isEqualTo "LIMPAR"}
        && {ctrlEnabled _kitClear406}
        && {ctrlEnabled _eqClear406}
        && {_sameEditRow406}
        && {(_uiAfter406 getOrDefault ["applicationTarget",""]) isEqualTo "C"}
        && {(_uiAfter406 getOrDefault ["equipmentView",""]) isEqualTo "U"};
};
["ITEMS-0.11-406",_gate406,"UI expõe dois LIMPAR distintos; LIMPAR Kit fica agrupado com SALVAR/SALVAR COMO NOVO/DESCARTAR e Equipment continua físico pelo VIEW."] call _assert;
if (!isNull _display406) then {_display406 closeDisplay 2;};
uiNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR,displayNull];

{if (!isNull _x) then {deleteVehicle _x;};} forEach [_target400,_target402,_target403A,_target403B,_target404];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_STATE_VAR,_oldAppState];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,_oldDraftState];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_oldUIState];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_REPOSITORY_VAR,_oldRepository];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_CACHE_VAR,_oldCatalogCache];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_METRICS_VAR,_oldCatalogMetrics];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_BUILD_STATE_VAR,_oldCatalogBuildState];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;

private _durationMs=round ((diag_tickTime-_startedAt)*1000);
private _summary=createHashMapFromArray [
    ["delivery","0.11 CP-A.1"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],
    ["base",_base],["baseExpected",398],["checkpointFirstGate",399],["checkpointLastGate",406],
    ["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],
    ["cumulativeExpected",406],["cumulativePassed",398+_passed],["durationMs",_durationMs]
];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] 0.11 CP-A.1 — BASE=398/398  CP-A.1=%1/8  FAIL=%2  CUMULATIVO=%3/406  TEMPO=%4ms",_passed,_failed,398+_passed,_durationMs];
diag_log "[SP_ORG] [ITEMS] 0.11 CP-A.1 — Teste manual: LIMPAR Kit não toca U/C/M; LIMPAR Equipment usa VIEW e ignora applicationTarget.";
diag_log "============================================================";
if (hasInterface) then {
    hint parseText format ["<t size='1.25'>SP_ORG_Items 0.11 CP-A.1</t><br/><br/>Baseline: <t color='#7CFC00'>398 / 398</t><br/>Clear + Feedback: <t color='%1'>%2 / 8</t><br/>Cumulativo: %3 / 406<br/><br/>%4",if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_passed,398+_passed,if (_failed isEqualTo 0) then {"406/406 concluído. Faça os testes manuais dos dois botões LIMPAR."} else {"Consulte o primeiro FAIL no RPT."}];
};
_summary
