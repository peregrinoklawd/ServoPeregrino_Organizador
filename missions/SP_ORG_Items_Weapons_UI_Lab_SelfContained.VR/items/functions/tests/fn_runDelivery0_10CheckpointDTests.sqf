#include "..\..\script_version.hpp"
disableSerialization;

private _legacyRunningState = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR, createHashMap];
if (_legacyRunningState getOrDefault ["running", false]) exitWith {
    [false, "ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING", "A regressão 0.9.3 já está em execução.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _orchestrator = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR, createHashMap];
if (_orchestrator getOrDefault ["running", false]) exitWith {
    [false, "ITEMS_0_10_FINAL_ALREADY_RUNNING", "Outro checkpoint de testes já está em execução.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _startedAt = diag_tickTime;
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.10 FINAL — REGRESSÃO COMPLETA 390/390";
diag_log "============================================================";

// Evita que um display antigo / handlers assíncronos contaminem uma segunda execução consecutiva.
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
uiSleep 0.02;

// CP-C.1 já compõe 363 + 18 + 7. Se qualquer baseline falhar, os gates finais 389..390 não executam.
private _base = [] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_10CheckpointCTests;
private _baseOk = (_base isEqualType createHashMap)
    && {_base getOrDefault ["success", false]}
    && {(_base getOrDefault ["checkpointPassed", 0]) isEqualTo 7}
    && {(_base getOrDefault ["cumulativePassed", 0]) isEqualTo 388};
if !(_baseOk) exitWith {
    [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
    private _summary = createHashMapFromArray [
        ["delivery","0.10-FINAL"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",false],
        ["code","ITEMS_0_10_FINAL_BASE_388_FAILED"],["base",_base],["checkpointSkipped",true],
        ["checkpointFirstGate",389],["checkpointLastGate",390],["checkpointTotal",0],["checkpointPassed",0],["checkpointFailed",0],
        ["cumulativeExpected",390]
    ];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    diag_log "[SP_ORG] [ITEMS] 0.10 FINAL — FAIL-FAST: baseline 388/388 não fechou; gates 389..390 NÃO executados.";
    if (hasInterface) then {hint "SP_ORG_Items 0.10 FINAL reprovado no gate-base 388/388. Consulte o primeiro FAIL no RPT.";};
    _summary
};

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR, createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.10-FINAL"]]];
private _passed = 0;
private _failed = 0;
private _results = [];
private _assert = {
    params ["_id","_condition","_detail"];
    private _status = if (_condition) then {"PASS"} else {"FAIL"};
    if (_condition) then {_passed = _passed + 1;} else {_failed = _failed + 1;};
    _results pushBack [_id,_status,_detail];
    diag_log format ["[SP_ORG] [ITEMS] [TEST 0.10 FINAL] [%1] %2 — %3",_status,_id,_detail];
};
private _oldAppState = [missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _appState = [_oldAppState] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
if ((count _appState) isEqualTo 0) then {_appState = createHashMap;};
_appState set ["ready",true]; _appState set ["executing",false]; _appState set ["lockToken",""]; _appState set ["lockOwner",""]; _appState set ["activePlanId",""];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_STATE_VAR,_appState];

private _entryMatches = {
    params ["_entries","_type","_className","_mode","_quantity","_states"];
    (_entries findIf {
        (_x isEqualType []) && {(count _x) isEqualTo 6}
        && {(_x#1) isEqualTo _type}
        && {(_x#2) isEqualTo _className}
        && {(_x#4) isEqualTo _mode}
        && {(_x#3) isEqualTo _quantity}
        && {if (_mode isEqualTo "EXACT") then {(_x#5) isEqualTo _states} else {true}}
    }) >= 0
};

// -------------------------------------------------------------------------
// 389 — refresh físico focal preserva catálogo/seleção/scroll e seleção pura não faz full refresh.
// -------------------------------------------------------------------------
// Gate 389 não depende do CONFIG_ALL real: o runner 0.9.3 limpa o cache no encerramento
// e initialize é lazy. Em modsets grandes, abrir a UI dispara rebuild assíncrono (~20s),
// portanto esperar poucos ms tornava lbSize==0 e gerava falso FAIL. Usamos um cache
// sintético isolado, suficiente para scroll/seleção, e restauramos o estado original ao final.
private _catalogCacheBefore389 = [missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_CACHE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _catalogMetricsBefore389 = [missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_METRICS_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _catalogBuildStateBefore389 = [missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_BUILD_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _seedDefs389 = [
    ["FirstAidKit","First Aid Kit","MEDICAL"],
    ["ToolKit","Toolkit","TOOLS"],
    ["MineDetector","Mine Detector","TOOLS"],
    ["Medikit","Medikit","MEDICAL"]
];
private _seedItems389 = [];
private _seedIndex389 = createHashMap;
for "_i389" from 0 to 79 do {
    private _def389 = _seedDefs389 # (_i389 mod (count _seedDefs389));
    private _item389 = createHashMapFromArray [
        ["className",_def389#0],["displayName",format ["%1 · fixture %2",_def389#1,_i389]],
        ["addon","SP_ORG_TEST_FIXTURE"],["categoryId",_def389#2],["picture",""]
    ];
    _seedItems389 pushBack _item389;
    if ((count (_seedIndex389 getOrDefault [_def389#0,createHashMap])) isEqualTo 0) then {_seedIndex389 set [_def389#0,_item389];};
};
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_CACHE_VAR,createHashMapFromArray [
    ["provider",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_PROVIDER],
    ["catalogModelVersion",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_MODEL_VERSION],
    ["buildKey",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["builtAtUTC",systemTimeUTC],
    ["items",_seedItems389],["index",_seedIndex389]
]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_BUILD_STATE_VAR,createHashMapFromArray [
    ["running",false],["completed",true],["currentRoot",""],["visitedConfigClasses",0],["candidateCount",80],["itemCount",80]
]];
private _fixture389 = createVehicleLocal ["GroundWeaponHolder_Scripted",[0,0,0],[],0,"CAN_COLLIDE"];
private _fixture389Ready = !isNull _fixture389;
if (_fixture389Ready) then {_fixture389 addItemCargoGlobal ["FirstAidKit",1];};
private _testResolved389 = createHashMapFromArray [["target","TEST_CONTAINER"],["container",_fixture389],["containerClass","GroundWeaponHolder_Scripted"]];
private _options389 = createHashMapFromArray [["testResolvedTarget",_testResolved389],["commandOrigin","TEST_389"]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _ui389 = [] call ServoPeregrino_Organizador_Items_fnc_createUIState;
_ui389 set ["applicationTarget","U"];
_ui389 set ["equipmentView","U"];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_ui389];
private _open389 = [] call ServoPeregrino_Organizador_Items_fnc_openInterface;
uiSleep 0.04;
private _display389 = findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
private _uiReady389 = (_open389 getOrDefault ["success",false]) && {!isNull _display389};
private _catalogStable389 = false;
private _selectionPure389 = false;
private _focusedMode389 = false;
private _physicalApplied389 = false;
if (_uiReady389) then {
    [] call ServoPeregrino_Organizador_Items_fnc_refreshInterface;
    uiSleep 0.01;
    private _cat389 = _display389 displayCtrl 3120;
    private _size389 = lbSize _cat389;
    if (_size389 > 2) then {
        private _sel389 = 20 min (_size389 - 1);
        _cat389 lbSetCurSel _sel389;
        ["CATALOG_SELECT",_sel389] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent;
        _cat389 ctrlSetScrollValues [0.55,-1];
        uiSleep 0.01;
        private _selectedDataBefore389 = _cat389 lbData (lbCurSel _cat389);
        private _scrollBefore389 = ctrlScrollValues _cat389;
        private _uiBefore389 = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
        private _fullBefore389 = _uiBefore389 getOrDefault ["fullRefreshCount",0];
        private _focusedBefore389 = _uiBefore389 getOrDefault ["focusedRefreshCount",0];
        private _entry389R = ["ITEM","FirstAidKit",1,"NONE",[]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
        private _entry389 = ((_entry389R getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]]);
        private _cmd389 = ["ENTRY",_entry389,"PHYSICAL","ADD",player,"",_options389] call ServoPeregrino_Organizador_Items_fnc_executeUITransferCommand;
        private _cap389R = [_fixture389,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_captureContainerContent;
        private _cap389 = _cap389R getOrDefault ["data",createHashMap];
        private _readiness389 = createHashMapFromArray [["physicalMutationEnabled",true],["resolvedTarget","TEST_CONTAINER"]];
        if (_cmd389 getOrDefault ["success",false]) then {
            [_cmd389,createHashMapFromArray [["forceEquipmentRefresh",true],["captureOverride",_cap389],["readinessOverride",_readiness389]]] call ServoPeregrino_Organizador_Items_fnc_refreshPhysicalMutationUI;
        };
        uiSleep 0.01;
        private _uiAfter389 = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
        private _scrollAfter389 = ctrlScrollValues _cat389;
        private _selectedDataAfter389 = if ((lbCurSel _cat389)>=0) then {_cat389 lbData (lbCurSel _cat389)} else {""};
        private _sameScroll389 = ((count _scrollBefore389)>=2) && {(count _scrollAfter389)>=2} && {abs ((_scrollBefore389#0)-(_scrollAfter389#0)) < 0.02};
        _catalogStable389 = (_selectedDataBefore389 isNotEqualTo "") && {_selectedDataAfter389 isEqualTo _selectedDataBefore389} && {_sameScroll389} && {(_uiAfter389 getOrDefault ["fullRefreshCount",-1]) isEqualTo _fullBefore389};
        _focusedMode389 = (_uiAfter389 getOrDefault ["lastRefreshMode",""]) isEqualTo "PHYSICAL_FOCUSED" && {(_uiAfter389 getOrDefault ["focusedRefreshCount",0]) isEqualTo (_focusedBefore389+1)} && {(_uiAfter389 getOrDefault ["lastFocusedRefreshTarget",""]) isEqualTo "TEST_CONTAINER"};
        private _entries389 = _cap389 getOrDefault ["entries",[]];
        _physicalApplied389 = [_entries389,"ITEM","FirstAidKit","NONE",2,[]] call _entryMatches;
        private _fullPureBefore389 = _uiAfter389 getOrDefault ["fullRefreshCount",0];
        private _pureIndex389 = if (_size389 > 30) then {30} else {1};
        _cat389 lbSetCurSel _pureIndex389;
        ["CATALOG_SELECT",_pureIndex389] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent;
        private _uiPureAfter389 = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
        _selectionPure389 = (_uiPureAfter389 getOrDefault ["fullRefreshCount",-1]) isEqualTo _fullPureBefore389;
    };
};
private _gate389Ok = _fixture389Ready && {_uiReady389} && {_catalogStable389} && {_selectionPure389} && {_focusedMode389} && {_physicalApplied389};
diag_log format ["[SP_ORG] [ITEMS] [0.10 FINAL 389 DIAG] fixture=%1 ui=%2 catalogStable=%3 selectionPure=%4 focused=%5 physical=%6 rows=%7",_fixture389Ready,_uiReady389,_catalogStable389,_selectionPure389,_focusedMode389,_physicalApplied389,if (isNull _display389) then {-1} else {lbSize (_display389 displayCtrl 3120)}];
["ITEMS-0.10-389", _gate389Ok, "Mutação física usa refresh focal, preserva seleção/scroll do Catálogo e seleção pura continua sem full refresh; fixture de catálogo é isolado do CONFIG_ALL real."] call _assert;
if (!isNull _display389) then {_display389 closeDisplay 2;};
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_CACHE_VAR,_catalogCacheBefore389];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_METRICS_VAR,_catalogMetricsBefore389];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_BUILD_STATE_VAR,_catalogBuildStateBefore389];
if (!isNull _fixture389) then {deleteVehicle _fixture389;};
uiNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR,displayNull];
uiSleep 0.01;

// -------------------------------------------------------------------------
// 390 — end-to-end final via UI dispatcher: ADD/REMOVE/REPLACE/CLEAR, target isolation,
//       saved kit immutable, EXACT, reserved cargo e rollback focal.
// -------------------------------------------------------------------------
private _suffix390 = "AUTO_0_10_FINAL";
[_suffix390,true] call ServoPeregrino_Organizador_Items_fnc_configureRepositoryTestMode;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMapFromArray [["ready",true],["hasDraft",false],["current",createHashMap],["baseline",createHashMap],["revision",0],["lastAction","NONE"]]];
private _targetA390 = createVehicleLocal ["GroundWeaponHolder_Scripted",[0,0,0],[],0,"CAN_COLLIDE"];
private _targetB390 = createVehicleLocal ["GroundWeaponHolder_Scripted",[0,0,0],[],0,"CAN_COLLIDE"];
private _fixtures390 = !isNull _targetA390 && {!isNull _targetB390};
if (_fixtures390) then {
    _targetA390 addItemCargoGlobal ["FirstAidKit",1];
    _targetA390 addMagazineAmmoCargo ["30Rnd_65x39_caseless_mag",1,30];
    _targetA390 addWeaponCargoGlobal ["arifle_MX_F",1];
    _targetA390 addBackpackCargoGlobal ["B_AssaultPack_khk",1];
    _targetB390 addItemCargoGlobal ["ToolKit",1];
    _targetB390 addWeaponCargoGlobal ["arifle_MX_F",1];
};
private _resolved390 = createHashMapFromArray [["target","TEST_CONTAINER"],["container",_targetA390],["containerClass","GroundWeaponHolder_Scripted"]];
private _opts390 = createHashMapFromArray [["testResolvedTarget",_resolved390],["commandOrigin","DND"]];
private _reservedWeapons390 = if (_fixtures390) then {str (getWeaponCargo _targetA390)} else {""};
private _reservedBackpacks390 = if (_fixtures390) then {str (getBackpackCargo _targetA390)} else {""};
private _bBefore390 = if (_fixtures390) then {((([_targetB390,"TEST_TARGET_B","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_getMutableContentFingerprint) getOrDefault ["data",createHashMap]) getOrDefault ["fingerprint",createHashMap])} else {createHashMap};

private _fak390R = ["ITEM","FirstAidKit",2,"NONE",[]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _mag390R = ["MAGAZINE","30Rnd_65x39_caseless_mag",2,"EXACT",[17,6]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _fak390 = ((_fak390R getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]]);
private _mag390 = ((_mag390R getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]]);
private _kit390R = ["0.10 FINAL Saved E2E",[_fak390,_mag390],"ANY",["TEST","FINAL_0_10"]] call ServoPeregrino_Organizador_Items_fnc_createItemKit;
private _kit390 = ((_kit390R getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]]);
private _save390 = if (_kit390R getOrDefault ["success",false]) then {[_kit390] call ServoPeregrino_Organizador_Items_fnc_saveKit} else {_kit390R};
private _kitId390 = ((_save390 getOrDefault ["data",createHashMap]) getOrDefault ["kitId",""]);
private _savedBefore390 = if (_kitId390 isNotEqualTo "") then {((([_kitId390] call ServoPeregrino_Organizador_Items_fnc_getKit) getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]])} else {[]};

private _add390 = if (_fixtures390 && {_kitId390 isNotEqualTo ""}) then {["KIT",_kitId390,"PHYSICAL","ADD",player,"",_opts390] call ServoPeregrino_Organizador_Items_fnc_executeUITransferCommand} else {createHashMap};
private _capAdd390 = if (_fixtures390) then {([_targetA390,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_captureContainerContent) getOrDefault ["data",createHashMap]} else {createHashMap};
private _entriesAdd390 = _capAdd390 getOrDefault ["entries",[]];
private _addState390 = [_entriesAdd390,"ITEM","FirstAidKit","NONE",3,[]] call _entryMatches;
_addState390 = _addState390 && {[_entriesAdd390,"MAGAZINE","30Rnd_65x39_caseless_mag","EXACT",3,[30,17,6]] call _entryMatches};
private _remove390 = if (_add390 getOrDefault ["success",false]) then {["KIT",_kitId390,"PHYSICAL","REMOVE",player,"",_opts390] call ServoPeregrino_Organizador_Items_fnc_executeUITransferCommand} else {createHashMap};
private _capRemove390 = if (_fixtures390) then {([_targetA390,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_captureContainerContent) getOrDefault ["data",createHashMap]} else {createHashMap};
private _entriesRemove390 = _capRemove390 getOrDefault ["entries",[]];
private _removeState390 = [_entriesRemove390,"ITEM","FirstAidKit","NONE",1,[]] call _entryMatches;
_removeState390 = _removeState390 && {[_entriesRemove390,"MAGAZINE","30Rnd_65x39_caseless_mag","EXACT",1,[30]] call _entryMatches};
private _addAgain390 = if (_remove390 getOrDefault ["success",false]) then {["KIT",_kitId390,"PHYSICAL","ADD",player,"",_opts390] call ServoPeregrino_Organizador_Items_fnc_executeUITransferCommand} else {createHashMap};

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMapFromArray [["ready",true],["hasDraft",false],["current",createHashMap],["baseline",createHashMap],["revision",0],["lastAction","NONE"]]];
private _tool390R = ["ITEM","ToolKit",1,"NONE",[]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _magReplace390R = ["MAGAZINE","30Rnd_65x39_caseless_mag",1,"EXACT",[6]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _tool390 = ((_tool390R getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]]);
private _magReplace390 = ((_magReplace390R getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]]);
private _draft390 = ["0.10 FINAL Replace", "ANY", ["TEST","FINAL_0_10"], [_tool390,_magReplace390]] call ServoPeregrino_Organizador_Items_fnc_createNewDraft;
private _replace390 = if (_draft390 getOrDefault ["success",false]) then {["DRAFT",[],"PHYSICAL","REPLACE",player,"",_opts390] call ServoPeregrino_Organizador_Items_fnc_executeUITransferCommand} else {_draft390};
private _capReplace390 = if (_fixtures390) then {([_targetA390,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_captureContainerContent) getOrDefault ["data",createHashMap]} else {createHashMap};
private _entriesReplace390 = _capReplace390 getOrDefault ["entries",[]];
private _replaceState390 = (count _entriesReplace390) isEqualTo 2 && {[_entriesReplace390,"ITEM","ToolKit","NONE",1,[]] call _entryMatches} && {[_entriesReplace390,"MAGAZINE","30Rnd_65x39_caseless_mag","EXACT",1,[6]] call _entryMatches};
private _fpReplace390 = if (_fixtures390) then {((([_targetA390,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_getMutableContentFingerprint) getOrDefault ["data",createHashMap]) getOrDefault ["fingerprint",createHashMap])} else {createHashMap};

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMapFromArray [["ready",true],["hasDraft",false],["current",createHashMap],["baseline",createHashMap],["revision",0],["lastAction","NONE"]]];
private _failFak390R = ["ITEM","FirstAidKit",3,"NONE",[]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _failMag390R = ["MAGAZINE","30Rnd_65x39_caseless_mag",1,"EXACT",[17]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _failFak390 = ((_failFak390R getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]]);
private _failMag390 = ((_failMag390R getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]]);
private _draftFail390 = ["0.10 FINAL Rollback", "ANY", ["TEST","FINAL_0_10"], [_failFak390,_failMag390]] call ServoPeregrino_Organizador_Items_fnc_createNewDraft;
private _failOpts390 = [_opts390] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
_failOpts390 set ["injectFailureAfterCommit",true];
private _replaceFail390 = if (_draftFail390 getOrDefault ["success",false]) then {["DRAFT",[],"PHYSICAL","REPLACE",player,"",_failOpts390] call ServoPeregrino_Organizador_Items_fnc_executeUITransferCommand} else {_draftFail390};
private _fpAfterFail390 = if (_fixtures390) then {((([_targetA390,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_getMutableContentFingerprint) getOrDefault ["data",createHashMap]) getOrDefault ["fingerprint",createHashMap])} else {createHashMap};
private _rollback390 = !(_replaceFail390 getOrDefault ["success",true]) && {((_replaceFail390 getOrDefault ["data",createHashMap]) getOrDefault ["rollbackSucceeded",false])} && {(_fpReplace390 getOrDefault ["serialized","A"]) isEqualTo (_fpAfterFail390 getOrDefault ["serialized","B"])};

private _clear390 = if (_replace390 getOrDefault ["success",false]) then {["DRAFT",[],"PHYSICAL","CLEAR",player,"",_opts390] call ServoPeregrino_Organizador_Items_fnc_executeUITransferCommand} else {createHashMap};
private _capClear390 = if (_fixtures390) then {([_targetA390,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_captureContainerContent) getOrDefault ["data",createHashMap]} else {createHashMap};
private _clearState390 = (_clear390 getOrDefault ["success",false]) && {(count (_capClear390 getOrDefault ["entries",[]])) isEqualTo 0};
private _reservedSame390 = _fixtures390 && {(str (getWeaponCargo _targetA390)) isEqualTo _reservedWeapons390} && {(str (getBackpackCargo _targetA390)) isEqualTo _reservedBackpacks390};
private _bAfter390 = if (_fixtures390) then {((([_targetB390,"TEST_TARGET_B","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_getMutableContentFingerprint) getOrDefault ["data",createHashMap]) getOrDefault ["fingerprint",createHashMap])} else {createHashMap};
private _targetIsolation390 = (_bBefore390 getOrDefault ["serialized","A"]) isEqualTo (_bAfter390 getOrDefault ["serialized","B"]);
private _savedAfter390 = if (_kitId390 isNotEqualTo "") then {((([_kitId390] call ServoPeregrino_Organizador_Items_fnc_getKit) getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]])} else {[]};
private _savedImmutable390 = (_savedBefore390 isNotEqualTo []) && {_savedAfter390 isEqualTo _savedBefore390};
private _singleDispatch390 = {
    params ["_r"];
    private _cmd = ((_r getOrDefault ["data",createHashMap]) getOrDefault ["uiCommand",createHashMap]);
    (_cmd getOrDefault ["singleDispatch",false]) && {(_cmd getOrDefault ["target",""]) isEqualTo "TEST_CONTAINER"}
};
private _dispatches390 = [_add390] call _singleDispatch390;
_dispatches390 = _dispatches390 && {[_remove390] call _singleDispatch390} && {[_replace390] call _singleDispatch390} && {[_clear390] call _singleDispatch390};

["ITEMS-0.10-390", _fixtures390 && {(_save390 getOrDefault ["success",false])} && {(_add390 getOrDefault ["success",false])} && {_addState390} && {(_remove390 getOrDefault ["success",false])} && {_removeState390} && {(_addAgain390 getOrDefault ["success",false])} && {(_replace390 getOrDefault ["success",false])} && {_replaceState390} && {_rollback390} && {_clearState390} && {_reservedSame390} && {_targetIsolation390} && {_savedImmutable390} && {_dispatches390}, "End-to-end pelo dispatcher de UI cobre ADD/REMOVE/REPLACE/CLEAR no único target contratado, preserva EXACT/reserved/kit salvo/outro target e restaura rollback focal."] call _assert;

if (!isNull _targetA390) then {deleteVehicle _targetA390;};
if (!isNull _targetB390) then {deleteVehicle _targetB390;};
[_suffix390,true] call ServoPeregrino_Organizador_Items_fnc_configureRepositoryTestMode;
["",false] call ServoPeregrino_Organizador_Items_fnc_configureRepositoryTestMode;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_STATE_VAR,_oldAppState];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;

private _durationMs = round ((diag_tickTime - _startedAt) * 1000);
private _summary = createHashMapFromArray [
    ["delivery","0.10-FINAL"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],
    ["base",_base],["baseExpected",388],["checkpointFirstGate",389],["checkpointLastGate",390],
    ["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],
    ["cumulativeExpected",390],["cumulativePassed",388+_passed],["durationMs",_durationMs],["repeatSafePreparation",true]
];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] 0.10 FINAL — BASE=388/388  FINAL=%1/2  FAIL=%2  CUMULATIVO=%3/390  TEMPO=%4ms",_passed,_failed,388+_passed,_durationMs];
diag_log "[SP_ORG] [ITEMS] 0.10 FINAL — Gate automático concluído. Para homologação, exigir 390/390 em duas execuções consecutivas, RPT limpo e smoke manual.";
diag_log "============================================================";
if (hasInterface) then {
    hint parseText format ["<t size='1.25'>SP_ORG_Items 0.10 FINAL</t><br/><br/>Baseline CP-C.1: <t color='#7CFC00'>388 / 388</t><br/>Refresh focal + End-to-End: <t color='%1'>%2 / 2</t><br/>Cumulativo: %3 / 390<br/><br/>%4",if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_passed,388+_passed,if (_failed isEqualTo 0) then {"Suíte final 390/390 concluída. Repita na mesma sessão para validar repeat-safe."} else {"Consulte o primeiro FAIL no RPT."}];
};
_summary
