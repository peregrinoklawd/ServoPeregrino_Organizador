#include "..\..\script_version.hpp"
disableSerialization;

private _legacyRunningState = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR, createHashMap];
if (_legacyRunningState getOrDefault ["running", false]) exitWith {
    [false, "ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING", "A regressão legada já está em execução.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _orchestrator = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR, createHashMap];
if (_orchestrator getOrDefault ["running", false]) exitWith {
    [false, "ITEMS_0_10_0_7_ALREADY_RUNNING", "Outra suíte cumulativa já está em execução.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _startedAt = diag_tickTime;
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.10.0.7 — PHYSICAL FLOW RELIABILITY — 398 GATES";
diag_log "============================================================";

[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
uiSleep 0.02;
private _base = [] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_10CheckpointDTests;
private _baseOk = (_base isEqualType createHashMap)
    && {_base getOrDefault ["success",false]}
    && {(_base getOrDefault ["checkpointPassed",0]) isEqualTo 2}
    && {(_base getOrDefault ["cumulativePassed",0]) isEqualTo 390};
if !(_baseOk) exitWith {
    [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
    private _summary = createHashMapFromArray [
        ["delivery","0.10.0.7"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",false],
        ["code","ITEMS_0_10_0_7_BASE_390_FAILED"],["base",_base],["checkpointSkipped",true],
        ["checkpointFirstGate",391],["checkpointLastGate",398],["checkpointTotal",0],["checkpointPassed",0],["checkpointFailed",0],
        ["cumulativeExpected",398]
    ];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    diag_log "[SP_ORG] [ITEMS] 0.10.0.7 — FAIL-FAST: baseline 390/390 não fechou; gates 391..398 NÃO executados.";
    if (hasInterface) then {hint "SP_ORG_Items 0.10.0.7 reprovado na baseline 390/390. Consulte o primeiro FAIL no RPT.";};
    _summary
};

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.10.0.7"]]];
private _passed = 0;
private _failed = 0;
private _results = [];
private _assert = {
    params ["_id","_condition","_detail"];
    private _status = if (_condition) then {"PASS"} else {"FAIL"};
    if (_condition) then {_passed = _passed + 1;} else {_failed = _failed + 1;};
    _results pushBack [_id,_status,_detail];
    diag_log format ["[SP_ORG] [ITEMS] [TEST 0.10.0.7] [%1] %2 — %3",_status,_id,_detail];
};
private _oldAppState = [missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _oldDraftState = [missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _oldUIState = [missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _oldCatalogCache = [missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_CACHE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _oldCatalogMetrics = [missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_METRICS_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _oldCatalogBuildState = [missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_BUILD_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;

private _setAppReady = {
    params ["_ready"];
    private _s = [missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
    if ((count _s) isEqualTo 0) then {_s=createHashMap;};
    _s set ["ready",_ready]; _s set ["executing",false]; _s set ["lockToken",""]; _s set ["lockOwner",""]; _s set ["activePlanId",""];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_STATE_VAR,_s];
};
[true] call _setAppReady;

private _resetDraft = {
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMapFromArray [["ready",true],["hasDraft",false],["current",createHashMap],["baseline",createHashMap],["revision",0],["lastAction","NONE"]]];
};
private _makeEntry = {
    params ["_type","_class","_qty","_mode","_states"];
    private _r=[_type,_class,_qty,_mode,_states] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
    ((_r getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]])
};
private _fingerprint = {
    params ["_obj"];
    private _r=[_obj,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_getMutableContentFingerprint;
    private _d=_r getOrDefault ["data",createHashMap];
    private _fp=_d getOrDefault ["fingerprint",createHashMap];
    _fp getOrDefault ["serialized",""]
};
private _entries = {
    params ["_obj"];
    private _r=[_obj,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_captureContainerContent;
    (_r getOrDefault ["data",createHashMap]) getOrDefault ["entries",[]]
};
private _entryMatches = {
    params ["_entriesV","_type","_className","_mode","_quantity","_states"];
    (_entriesV findIf {
        (_x isEqualType []) && {(count _x) isEqualTo 6}
        && {(_x#1) isEqualTo _type}
        && {(_x#2) isEqualTo _className}
        && {(_x#4) isEqualTo _mode}
        && {(_x#3) isEqualTo _quantity}
        && {if (_mode isEqualTo "EXACT") then {(_x#5) isEqualTo _states} else {true}}
    }) >= 0
};
private _optsFor = {
    params ["_obj","_origin"];
    createHashMapFromArray [["testResolvedTarget",createHashMapFromArray [["target","TEST_CONTAINER"],["container",_obj],["containerClass","GroundWeaponHolder_Scripted"]]],["commandOrigin",_origin]]
};
private _commandIdOf = {
    params ["_r"];
    (((_r getOrDefault ["data",createHashMap]) getOrDefault ["uiCommand",createHashMap]) getOrDefault ["commandId",""])
};
private _traceOk = {
    params ["_r"];
    private _d=_r getOrDefault ["data",createHashMap];
    private _cmd=_d getOrDefault ["uiCommand",createHashMap];
    private _tr=_d getOrDefault ["physicalTrace",createHashMap];
    (_cmd getOrDefault ["singleDispatch",false])
        && {(_cmd getOrDefault ["commandId",""]) isNotEqualTo ""}
        && {(_tr getOrDefault ["commandId",""]) isEqualTo (_cmd getOrDefault ["commandId",""])}
        && {(_tr getOrDefault ["durationMs",-1]) >= 0}
};

// -------------------------------------------------------------------------
// 391 — applicationTarget é seleção pura: target-only refresh, sem recapture,
//       sem full refresh e sem mutação do loadout real.
// -------------------------------------------------------------------------
private _seedItems391=[]; private _seedIndex391=createHashMap;
{
    _x params ["_class","_name","_cat"];
    private _item=createHashMapFromArray [["className",_class],["displayName",_name],["addon","SP_ORG_TEST_FIXTURE"],["categoryId",_cat],["picture",""]];
    _seedItems391 pushBack _item; _seedIndex391 set [_class,_item];
} forEach [["FirstAidKit","First Aid Kit","MEDICAL"],["ToolKit","Toolkit","TOOLS"],["MineDetector","Mine Detector","TOOLS"],["Medikit","Medikit","MEDICAL"]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_CACHE_VAR,createHashMapFromArray [["provider",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_PROVIDER],["catalogModelVersion",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_MODEL_VERSION],["buildKey",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["builtAtUTC",systemTimeUTC],["items",_seedItems391],["index",_seedIndex391]]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_BUILD_STATE_VAR,createHashMapFromArray [["running",false],["completed",true],["currentRoot",""],["visitedConfigClasses",0],["candidateCount",4],["itemCount",4]]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _ui391=[] call ServoPeregrino_Organizador_Items_fnc_createUIState;
_ui391 set ["applicationTarget","U"]; _ui391 set ["equipmentView","U"];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_ui391];
private _open391=[] call ServoPeregrino_Organizador_Items_fnc_openInterface;
uiSleep 0.04;
private _display391=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
private _gate391=false;
if ((_open391 getOrDefault ["success",false]) && {!isNull _display391}) then {
    private _eq391=_display391 displayCtrl 4120;
    lbClear _eq391;
    private _sentinel391=_eq391 lbAdd "SPORG_SENTINEL x9";
    _eq391 lbSetData [_sentinel391,str ["ITEM","FirstAidKit",9,"NONE",[]]];
    _eq391 lbSetCurSel _sentinel391;
    private _uiBefore391=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
    private _fullBefore391=_uiBefore391 getOrDefault ["fullRefreshCount",0];
    private _targetBefore391=_uiBefore391 getOrDefault ["targetRefreshCount",0];
    private _loadBefore391=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
    ["APP_TARGET","C"] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent;
    uiSleep 0.01;
    private _uiAfter391=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
    private _loadAfter391=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
    _gate391=(_uiAfter391 getOrDefault ["applicationTarget",""]) isEqualTo "C"
        && {(_uiAfter391 getOrDefault ["equipmentView",""]) isEqualTo "U"}
        && {(_uiAfter391 getOrDefault ["fullRefreshCount",-1]) isEqualTo _fullBefore391}
        && {(_uiAfter391 getOrDefault ["targetRefreshCount",0]) isEqualTo (_targetBefore391+1)}
        && {(_uiAfter391 getOrDefault ["lastRefreshMode",""]) isEqualTo "TARGET_ONLY"}
        && {(lbSize _eq391) isEqualTo 1}
        && {(_eq391 lbData 0) isEqualTo str ["ITEM","FirstAidKit",9,"NONE",[]]}
        && {(_loadBefore391 getOrDefault ["serialized","A"]) isEqualTo (_loadAfter391 getOrDefault ["serialized","B"])};
};
["ITEMS-0.10.0.7-391",_gate391,"Trocar applicationTarget usa TARGET_ONLY, preserva equipmentView/lista, não incrementa full refresh e não muta loadout."] call _assert;

// -------------------------------------------------------------------------
// 392 — estado bloqueado continua clicável e produz feedback visível.
// -------------------------------------------------------------------------
private _gate392=false;
if (!isNull _display391) then {
    call _resetDraft;
    private _fak392=["ITEM","FirstAidKit",1,"NONE",[]] call _makeEntry;
    ["Blocked feedback", "ANY", ["TEST","391_392"], [_fak392]] call ServoPeregrino_Organizador_Items_fnc_createNewDraft;
    [false] call _setAppReady;
    [] call ServoPeregrino_Organizador_Items_fnc_refreshPhysicalTargetUI;
    private _buttonsEnabled392=true;
    {_buttonsEnabled392=_buttonsEnabled392 && {ctrlEnabled (_display391 displayCtrl _x)};} forEach [2150,2151,2152,2153];
    private _histBefore392=count ((missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]) getOrDefault ["history",[]]);
    ["PHYSICAL_APPLY",0] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent;
    uiSleep 0.01;
    private _uiAfter392=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
    private _hist392=_uiAfter392 getOrDefault ["history",[]];
    private _msg392=_uiAfter392 getOrDefault ["temporaryMessage",""];
    private _code392=_uiAfter392 getOrDefault ["lastOutcomeCode",""];
    private _summary392=_uiAfter392 getOrDefault ["lastOutcomeSummary",""];
    _gate392=_buttonsEnabled392
        && {(count _hist392) > _histBefore392}
        && {(_code392 isEqualTo "ITEMS_UI_PHYSICAL_NOT_READY") || {(_msg392 find "ITEMS_UI_PHYSICAL_NOT_READY") >= 0} || {!(_summary392 isEqualTo "")}}
        && {(_uiAfter392 getOrDefault ["lastRefreshMode",""]) isEqualTo "TARGET_ONLY"};
    [true] call _setAppReady;
};
["ITEMS-0.10.0.7-392",_gate392,"APLICAR/REMOVER/SUBSTITUIR/LIMPAR permanecem clicáveis quando bloqueados e o clique deixa feedback/histórico visível, mesmo com mensagem player-facing."] call _assert;
if (!isNull _display391) then {_display391 closeDisplay 2;};
uiNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR,displayNull];
uiSleep 0.01;

// -------------------------------------------------------------------------
// 393 — ADD→REMOVE de Draft misto ITEM + MAGAZINE EXACT volta ao fingerprint exato.
// -------------------------------------------------------------------------
call _resetDraft;
private _target393=createVehicleLocal ["GroundWeaponHolder_Scripted",[0,0,0],[],0,"CAN_COLLIDE"];
private _fixture393=!isNull _target393;
if (_fixture393) then {_target393 addItemCargoGlobal ["FirstAidKit",1]; _target393 addMagazineAmmoCargo ["30Rnd_65x39_caseless_mag",1,30];};
private _baseline393=if (_fixture393) then {[_target393] call _fingerprint} else {""};
private _fak393=["ITEM","FirstAidKit",2,"NONE",[]] call _makeEntry;
private _mag393=["MAGAZINE","30Rnd_65x39_caseless_mag",2,"EXACT",[17,6]] call _makeEntry;
private _draft393=["Round Trip 393","ANY",["TEST","393"],[_fak393,_mag393]] call ServoPeregrino_Organizador_Items_fnc_createNewDraft;
private _opts393=[_target393,"TEST_393"] call _optsFor;
private _add393=if (_fixture393 && {_draft393 getOrDefault ["success",false]}) then {["DRAFT",[],"PHYSICAL","ADD",player,"",_opts393] call ServoPeregrino_Organizador_Items_fnc_executeUITransferCommand} else {createHashMap};
private _remove393=if (_add393 getOrDefault ["success",false]) then {["DRAFT",[],"PHYSICAL","REMOVE",player,"",_opts393] call ServoPeregrino_Organizador_Items_fnc_executeUITransferCommand} else {createHashMap};
private _after393=if (_fixture393) then {[_target393] call _fingerprint} else {"X"};
private _gate393=_fixture393 && {_add393 getOrDefault ["success",false]} && {_remove393 getOrDefault ["success",false]} && {_baseline393 isEqualTo _after393};
["ITEMS-0.10.0.7-393",_gate393,"Draft misto ITEM + MAGAZINE EXACT faz ADD→REMOVE e retorna exatamente ao fingerprint físico inicial."] call _assert;

// -------------------------------------------------------------------------
// 394 — aritmética repetida sem phantom +1: +kit,+kit,-kit,-kit = baseline.
// -------------------------------------------------------------------------
call _resetDraft;
private _target394=createVehicleLocal ["GroundWeaponHolder_Scripted",[0,0,0],[],0,"CAN_COLLIDE"];
private _fixture394=!isNull _target394;
private _baseline394=if (_fixture394) then {[_target394] call _fingerprint} else {""};
private _fak394=["ITEM","FirstAidKit",1,"NONE",[]] call _makeEntry;
private _mag394=["MAGAZINE","30Rnd_65x39_caseless_mag",1,"EXACT",[17]] call _makeEntry;
private _draft394=["Arithmetic 394","ANY",["TEST","394"],[_fak394,_mag394]] call ServoPeregrino_Organizador_Items_fnc_createNewDraft;
private _opts394=[_target394,"TEST_394"] call _optsFor;
private _a394=if (_fixture394 && {_draft394 getOrDefault ["success",false]}) then {["DRAFT",[],"PHYSICAL","ADD",player,"",_opts394] call ServoPeregrino_Organizador_Items_fnc_executeUITransferCommand} else {createHashMap};
private _b394=if (_a394 getOrDefault ["success",false]) then {["DRAFT",[],"PHYSICAL","ADD",player,"",_opts394] call ServoPeregrino_Organizador_Items_fnc_executeUITransferCommand} else {createHashMap};
private _entriesPlus2=if (_fixture394) then {[_target394] call _entries} else {[]};
private _plus2=([_entriesPlus2,"ITEM","FirstAidKit","NONE",2,[]] call _entryMatches) && {[_entriesPlus2,"MAGAZINE","30Rnd_65x39_caseless_mag","EXACT",2,[17,17]] call _entryMatches};
private _c394=if (_b394 getOrDefault ["success",false]) then {["DRAFT",[],"PHYSICAL","REMOVE",player,"",_opts394] call ServoPeregrino_Organizador_Items_fnc_executeUITransferCommand} else {createHashMap};
private _entriesPlus1=if (_fixture394) then {[_target394] call _entries} else {[]};
private _plus1=([_entriesPlus1,"ITEM","FirstAidKit","NONE",1,[]] call _entryMatches) && {[_entriesPlus1,"MAGAZINE","30Rnd_65x39_caseless_mag","EXACT",1,[17]] call _entryMatches};
private _d394=if (_c394 getOrDefault ["success",false]) then {["DRAFT",[],"PHYSICAL","REMOVE",player,"",_opts394] call ServoPeregrino_Organizador_Items_fnc_executeUITransferCommand} else {createHashMap};
private _after394=if (_fixture394) then {[_target394] call _fingerprint} else {"X"};
private _gate394=_fixture394 && {_a394 getOrDefault ["success",false]} && {_b394 getOrDefault ["success",false]} && {_plus2} && {_c394 getOrDefault ["success",false]} && {_plus1} && {_d394 getOrDefault ["success",false]} && {_baseline394 isEqualTo _after394};
["ITEMS-0.10.0.7-394",_gate394,"Duas aplicações e duas remoções produzem +2,+1,baseline sem quantidade fantasma +1, inclusive magazine EXACT."] call _assert;

// -------------------------------------------------------------------------
// 395 — troca lógica de target entre comandos não desfaz o target anterior e não mistura containers.
// -------------------------------------------------------------------------
call _resetDraft;
private _targetA395=createVehicleLocal ["GroundWeaponHolder_Scripted",[0,0,0],[],0,"CAN_COLLIDE"];
private _targetB395=createVehicleLocal ["GroundWeaponHolder_Scripted",[0,0,0],[],0,"CAN_COLLIDE"];
private _fixtures395=!isNull _targetA395 && {!isNull _targetB395};
private _fak395=["ITEM","FirstAidKit",1,"NONE",[]] call _makeEntry;
private _draft395=["Target Isolation 395","ANY",["TEST","395"],[_fak395]] call ServoPeregrino_Organizador_Items_fnc_createNewDraft;
private _optsA395=[_targetA395,"TEST_395_A"] call _optsFor;
private _optsB395=[_targetB395,"TEST_395_B"] call _optsFor;
private _addA395=if (_fixtures395 && {_draft395 getOrDefault ["success",false]}) then {["DRAFT",[],"PHYSICAL","ADD",player,"U",_optsA395] call ServoPeregrino_Organizador_Items_fnc_executeUITransferCommand} else {createHashMap};
private _fpAAfterAdd395=if (_fixtures395) then {[_targetA395] call _fingerprint} else {""};
private _fpBBeforeSwitch395=if (_fixtures395) then {[_targetB395] call _fingerprint} else {""};
private _ui395=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]; if ((count _ui395) isEqualTo 0) then {_ui395=[] call ServoPeregrino_Organizador_Items_fnc_createUIState;}; _ui395 set ["applicationTarget","C"]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_ui395];
private _fpAAfterSwitch395=if (_fixtures395) then {[_targetA395] call _fingerprint} else {"X"};
private _fpBAfterSwitch395=if (_fixtures395) then {[_targetB395] call _fingerprint} else {"X"};
private _addB395=if (_addA395 getOrDefault ["success",false]) then {["DRAFT",[],"PHYSICAL","ADD",player,"C",_optsB395] call ServoPeregrino_Organizador_Items_fnc_executeUITransferCommand} else {createHashMap};
private _entriesA395=if (_fixtures395) then {[_targetA395] call _entries} else {[]};
private _entriesB395=if (_fixtures395) then {[_targetB395] call _entries} else {[]};
private _gate395=_fixtures395 && {_addA395 getOrDefault ["success",false]} && {_fpAAfterAdd395 isEqualTo _fpAAfterSwitch395} && {_fpBBeforeSwitch395 isEqualTo _fpBAfterSwitch395} && {_addB395 getOrDefault ["success",false]} && {[_entriesA395,"ITEM","FirstAidKit","NONE",1,[]] call _entryMatches} && {[_entriesB395,"ITEM","FirstAidKit","NONE",1,[]] call _entryMatches};
["ITEMS-0.10.0.7-395",_gate395,"Trocar seleção de destino entre comandos não faz rollback e cada dispatcher muta somente o fixture explicitamente resolvido."] call _assert;

// -------------------------------------------------------------------------
// 396 — REPLACE permanece após target switch; CLEAR afeta apenas o target atual.
// -------------------------------------------------------------------------
call _resetDraft;
private _targetA396=createVehicleLocal ["GroundWeaponHolder_Scripted",[0,0,0],[],0,"CAN_COLLIDE"];
private _targetB396=createVehicleLocal ["GroundWeaponHolder_Scripted",[0,0,0],[],0,"CAN_COLLIDE"];
private _fixtures396=!isNull _targetA396 && {!isNull _targetB396};
if (_fixtures396) then {_targetA396 addItemCargoGlobal ["FirstAidKit",2]; _targetB396 addItemCargoGlobal ["ToolKit",2];};
private _med396=["ITEM","Medikit",1,"NONE",[]] call _makeEntry;
private _mag396=["MAGAZINE","30Rnd_65x39_caseless_mag",1,"EXACT",[6]] call _makeEntry;
private _draft396=["Replace Switch Clear 396","ANY",["TEST","396"],[_med396,_mag396]] call ServoPeregrino_Organizador_Items_fnc_createNewDraft;
private _optsA396=[_targetA396,"TEST_396_REPLACE"] call _optsFor;
private _optsB396=[_targetB396,"TEST_396_CLEAR"] call _optsFor;
private _replace396=if (_fixtures396 && {_draft396 getOrDefault ["success",false]}) then {["DRAFT",[],"PHYSICAL","REPLACE",player,"U",_optsA396] call ServoPeregrino_Organizador_Items_fnc_executeUITransferCommand} else {createHashMap};
private _fpAReplace396=if (_fixtures396) then {[_targetA396] call _fingerprint} else {""};
private _ui396=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]; if ((count _ui396) isEqualTo 0) then {_ui396=[] call ServoPeregrino_Organizador_Items_fnc_createUIState;}; _ui396 set ["applicationTarget","C"]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_ui396];
private _fpAAfterSwitch396=if (_fixtures396) then {[_targetA396] call _fingerprint} else {"X"};
private _clear396=if (_replace396 getOrDefault ["success",false]) then {["DRAFT",[],"PHYSICAL","CLEAR",player,"C",_optsB396] call ServoPeregrino_Organizador_Items_fnc_executeUITransferCommand} else {createHashMap};
private _entriesA396=if (_fixtures396) then {[_targetA396] call _entries} else {[]};
private _entriesB396=if (_fixtures396) then {[_targetB396] call _entries} else {[]};
private _gate396=_fixtures396 && {_replace396 getOrDefault ["success",false]} && {_fpAReplace396 isEqualTo _fpAAfterSwitch396} && {_clear396 getOrDefault ["success",false]} && {(count _entriesB396) isEqualTo 0} && {[_entriesA396,"ITEM","Medikit","NONE",1,[]] call _entryMatches} && {[_entriesA396,"MAGAZINE","30Rnd_65x39_caseless_mag","EXACT",1,[6]] call _entryMatches};
["ITEMS-0.10.0.7-396",_gate396,"REPLACE não é revertido ao trocar seleção; CLEAR limpa somente o target explicitamente selecionado e preserva o anterior."] call _assert;

// -------------------------------------------------------------------------
// 397 — divergência EXACT no momento da mutação falha explicitamente e não reconstrói cargo.
// -------------------------------------------------------------------------
private _target397=createVehicleLocal ["GroundWeaponHolder_Scripted",[0,0,0],[],0,"CAN_COLLIDE"];
private _fixture397=!isNull _target397;
if (_fixture397) then {_target397 addMagazineAmmoCargo ["30Rnd_65x39_caseless_mag",1,30];};
private _fpBefore397=if (_fixture397) then {[_target397] call _fingerprint} else {""};
private _missing397=["MAGAZINE","30Rnd_65x39_caseless_mag",1,"EXACT",[17]] call _makeEntry;
private _r397=if (_fixture397) then {[_target397,"REMOVE",_missing397] call ServoPeregrino_Organizador_Items_fnc_mutateContainerEntry} else {createHashMap};
private _fpAfter397=if (_fixture397) then {[_target397] call _fingerprint} else {"X"};
private _gate397=_fixture397 && {!(_r397 getOrDefault ["success",true])} && {(_r397 getOrDefault ["code",""]) isEqualTo "ITEMS_MAGAZINE_EXACT_STATE_MISSING"} && {_fpBefore397 isEqualTo _fpAfter397};
["ITEMS-0.10.0.7-397",_gate397,"REMOVE de magazine EXACT ausente falha com código explícito e não altera/reconstrói o cargo."] call _assert;

// -------------------------------------------------------------------------
// 398 — todo comando físico tem commandId/trace; IDs são únicos e ação agregada é coerente.
// -------------------------------------------------------------------------
private _traceResults398=[_add393,_remove393,_a394,_b394,_c394,_d394,_addA395,_addB395,_replace396,_clear396];
private _traceAll398=true; private _ids398=[];
{
    _traceAll398=_traceAll398 && {[_x] call _traceOk};
    private _id398=[_x] call _commandIdOf;
    if (_id398 isNotEqualTo "") then {_ids398 pushBack _id398;};
} forEach _traceResults398;
private _unique398=[]; {_unique398 pushBackUnique _x;} forEach _ids398;
private _apply393=((_add393 getOrDefault ["data",createHashMap]) getOrDefault ["applyResult",createHashMap]);
private _applyRemove393=((_remove393 getOrDefault ["data",createHashMap]) getOrDefault ["applyResult",createHashMap]);
private _coherent398=(count (_apply393 getOrDefault ["actionResults",[]])) isEqualTo 2 && {(count (_applyRemove393 getOrDefault ["actionResults",[]])) isEqualTo 2};
private _gate398=_traceAll398 && {(count _ids398) isEqualTo (count _traceResults398)} && {(count _unique398) isEqualTo (count _ids398)} && {_coherent398};
diag_log format ["[SP_ORG] [ITEMS] [0.10.0.7 TRACE DIAG] results=%1 ids=%2 unique=%3 coherent=%4",count _traceResults398,count _ids398,count _unique398,_coherent398];
["ITEMS-0.10.0.7-398",_gate398,"Cada comando físico produz commandId/physicalTrace único, singleDispatch e agregação de ações coerente para correlação PRE/POST no RPT."] call _assert;

// Cleanup dos fixtures e estado transitório.
{if (!isNull _x) then {deleteVehicle _x;};} forEach [_target393,_target394,_targetA395,_targetB395,_targetA396,_targetB396,_target397];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_STATE_VAR,_oldAppState];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,_oldDraftState];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_oldUIState];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_CACHE_VAR,_oldCatalogCache];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_METRICS_VAR,_oldCatalogMetrics];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_BUILD_STATE_VAR,_oldCatalogBuildState];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;

private _durationMs=round ((diag_tickTime-_startedAt)*1000);
private _summary=createHashMapFromArray [
    ["delivery","0.10.0.7"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],
    ["base",_base],["baseExpected",390],["checkpointFirstGate",391],["checkpointLastGate",398],
    ["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],
    ["cumulativeExpected",398],["cumulativePassed",390+_passed],["durationMs",_durationMs],["physicalFlowTrace",true]
];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] 0.10.0.7 — BASE=390/390  HOTFIX=%1/8  FAIL=%2  CUMULATIVO=%3/398  TEMPO=%4ms",_passed,_failed,390+_passed,_durationMs];
diag_log "[SP_ORG] [ITEMS] 0.10.0.7 — Procure [PHYSICAL_FLOW] PRE/POST para cada clique físico manual.";
diag_log "============================================================";
if (hasInterface) then {
    hint parseText format ["<t size='1.25'>SP_ORG_Items 0.10.0.7</t><br/><br/>Baseline: <t color='#7CFC00'>390 / 390</t><br/>Physical Flow Hotfix: <t color='%1'>%2 / 8</t><br/>Cumulativo: %3 / 398<br/><br/>%4",if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_passed,390+_passed,if (_failed isEqualTo 0) then {"398/398 concluído. Faça o fluxo manual encadeado e envie o RPT."} else {"Consulte o primeiro FAIL no RPT."}];
};
_summary
