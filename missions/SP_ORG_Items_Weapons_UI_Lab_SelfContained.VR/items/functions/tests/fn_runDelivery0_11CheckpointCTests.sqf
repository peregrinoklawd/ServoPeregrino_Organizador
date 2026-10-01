#include "..\..\script_version.hpp"
disableSerialization;

private _legacyRunningState=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR,createHashMap];
if (_legacyRunningState getOrDefault ["running",false]) exitWith {[false,"ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING","A regressão legada já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _orchestrator=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
if (_orchestrator getOrDefault ["running",false]) exitWith {[false,"ITEMS_0_11_CP_C_ALREADY_RUNNING","Outra suíte cumulativa já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};

private _startedAt=diag_tickTime;
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.11 CP-C — CAPACITY + ITEM AWARENESS — 450 GATES";
diag_log "============================================================";

[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
uiSleep 0.02;
private _base=[] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_11CheckpointB7Tests;
private _baseOk=(_base isEqualType createHashMap) && {_base getOrDefault ["success",false]} && {(_base getOrDefault ["checkpointPassed",0]) isEqualTo 6} && {(_base getOrDefault ["cumulativePassed",0]) isEqualTo 442};
if !(_baseOk) exitWith {
    [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
    private _summary=createHashMapFromArray [["delivery","0.11 CP-C"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",false],["code","ITEMS_0_11_CP_C_BASE_442_FAILED"],["base",_base],["checkpointSkipped",true],["checkpointFirstGate",443],["checkpointLastGate",450],["checkpointTotal",0],["checkpointPassed",0],["checkpointFailed",0],["cumulativeExpected",450]];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    diag_log "[SP_ORG] [ITEMS] 0.11 CP-C — FAIL-FAST: baseline CP-B.7 442/442 não fechou.";
    if (hasInterface) then {hint "SP_ORG_Items 0.11 CP-C reprovado na baseline 442/442. Consulte o primeiro FAIL no RPT.";};
    _summary
};

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.11 CP-C"]]];
private _passed=0;
private _failed=0;
private _results=[];
private _assert={
    params ["_id","_condition","_detail"];
    private _ok=(_condition isEqualType true) && {_condition};
    private _status=if (_ok) then {"PASS"} else {"FAIL"};
    if (_ok) then {_passed=_passed+1;} else {_failed=_failed+1;};
    _results pushBack [_id,_status,_detail];
    diag_log format ["[SP_ORG] [ITEMS] [TEST 0.11 CP-C] [%1] %2 — %3",_status,_id,_detail];
};

private _productionBefore=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _loadoutBefore=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _catalogBefore=([] call ServoPeregrino_Organizador_Items_fnc_getCatalogStatus) getOrDefault ["data",createHashMap];

// 443 — massa unitária nasce da metadata cacheada e a linha usa quantidade sem novo scan global.
private _fakR=["ITEM","FirstAidKit",2,"NONE",[]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _fak=((_fakR getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]]);
private _fakMeta=["FirstAidKit"] call ServoPeregrino_Organizador_Items_fnc_resolveUIItemMetadata;
private _fakAware=[_fak,_fakMeta] call ServoPeregrino_Organizador_Items_fnc_getUIEntryAwareness;
private _catalogAfterAware=([] call ServoPeregrino_Organizador_Items_fnc_getCatalogStatus) getOrDefault ["data",createHashMap];
private _gate443=(_fakR getOrDefault ["success",false])
    && {(_fakMeta getOrDefault ["massEstimate",0])>0}
    && {_fakAware getOrDefault ["known",false]}
    && {(_fakAware getOrDefault ["unitMass",0]) isEqualTo (_fakMeta getOrDefault ["massEstimate",-1])}
    && {(_fakAware getOrDefault ["totalMass",0]) isEqualTo (2*(_fakAware getOrDefault ["unitMass",0]))}
    && {(_catalogAfterAware getOrDefault ["configScanCount",-1]) isEqualTo (_catalogBefore getOrDefault ["configScanCount",-2])};
["ITEMS-0.11-443",_gate443,"Item Awareness reutiliza massEstimate/cache e calcula massa da linha por quantidade sem revarrer CONFIG_ALL."] call _assert;

// 444 — EXACT continua sendo EXACT; awareness é somente derivado e não altera stateData.
private _exactR=["MAGAZINE","30Rnd_65x39_caseless_mag",3,"EXACT",[30,17,6]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _exact=((_exactR getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]]);
private _exactBefore=+(_exact#5);
private _exactMeta=["30Rnd_65x39_caseless_mag"] call ServoPeregrino_Organizador_Items_fnc_resolveUIItemMetadata;
private _exactAware=[_exact,_exactMeta] call ServoPeregrino_Organizador_Items_fnc_getUIEntryAwareness;
private _gate444=(_exactR getOrDefault ["success",false])
    && {_exactAware getOrDefault ["known",false]}
    && {(_exactAware getOrDefault ["quantity",0]) isEqualTo 3}
    && {(_exactAware getOrDefault ["totalMass",0]) isEqualTo (3*(_exactAware getOrDefault ["unitMass",0]))}
    && {(_exact#4) isEqualTo "EXACT"}
    && {(_exact#5) isEqualTo _exactBefore};
["ITEMS-0.11-444",_gate444,"Massa de magazine EXACT usa quantidade sem converter, reordenar ou fabricar stateData; [30,17,6] permanece intacto."] call _assert;

// 445 — capacidade usa a mesma unidade nativa de carga e permanece read-only.
private _fixture=createVehicleLocal ["GroundWeaponHolder_Scripted",[0,0,0],[],0,"CAN_COLLIDE"];
private _fixtureOk=!isNull _fixture;
private _capR=if (_fixtureOk) then {[_fixture,"TEST_CP_C",createHashMapFromArray [["maxLoadOverride",100],["currentLoadOverride",35]]] call ServoPeregrino_Organizador_Items_fnc_getContainerCapacityMetrics} else {createHashMap};
private _cap=_capR getOrDefault ["data",createHashMap];
private _gate445=_fixtureOk && {(_capR getOrDefault ["success",false])} && {_cap getOrDefault ["known",false]} && {(_cap getOrDefault ["maxLoad",0]) isEqualTo 100} && {(_cap getOrDefault ["currentLoad",0]) isEqualTo 35} && {(_cap getOrDefault ["availableLoad",0]) isEqualTo 65};
["ITEMS-0.11-445",_gate445,"Capacity Awareness expõe usada/máxima/disponível na unidade nativa do Arma e aceita fixture determinístico sem mutação."] call _assert;

// 446 — readiness publica solicitado vs resolvido e capacidade do target resolvido.
private _readinessR=if (_fixtureOk) then {
    [player,"U","VEST",createHashMapFromArray [["testResolvedTarget",createHashMapFromArray [["target","TEST_CP_C"],["container",_fixture],["containerClass","GroundWeaponHolder_Scripted"],["capacityContext",createHashMapFromArray [["maxLoadOverride",100],["currentLoadOverride",35]]]]]]] call ServoPeregrino_Organizador_Items_fnc_getUIPhysicalReadiness
} else {createHashMap};
private _readiness=_readinessR getOrDefault ["data",createHashMap];
private _readyCap=_readiness getOrDefault ["capacity",createHashMap];
private _gate446=(_readinessR getOrDefault ["success",false])
    && {_readiness getOrDefault ["physicalMutationEnabled",false]}
    && {(_readiness getOrDefault ["requestedTarget",""]) isEqualTo "U"}
    && {(_readiness getOrDefault ["resolvedTarget",""]) isEqualTo "TEST_CP_C"}
    && {(_readiness getOrDefault ["preferredTarget",""]) isEqualTo "VEST"}
    && {_readyCap getOrDefault ["known",false]}
    && {(_readyCap getOrDefault ["availableLoad",0]) isEqualTo 65};
["ITEMS-0.11-446",_gate446,"Readiness mantém target solicitado, target resolvido e preferredTarget separados e anexa capacidade ao target físico resolvido."] call _assert;

// 447 — View-model do Draft publica massa por linha e total do kit, inclusive EXACT.
["AUTO_0_11_C",true] call ServoPeregrino_Organizador_Items_fnc_configureRepositoryTestMode;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMap];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_createUIState;
private _newDraft=["CP-C Awareness Fixture","ANY",["TEST","CP_C"],[]] call ServoPeregrino_Organizador_Items_fnc_createNewDraft;
private _addFak=["FirstAidKit",2] call ServoPeregrino_Organizador_Items_fnc_addCatalogItemToDraft;
private _addExact=if (_exactR getOrDefault ["success",false]) then {[_exact] call ServoPeregrino_Organizador_Items_fnc_addEntryToDraft} else {createHashMap};
private _vmR=[objNull] call ServoPeregrino_Organizador_Items_fnc_buildUIViewModel;
private _vm=_vmR getOrDefault ["data",createHashMap];
private _draftVM=_vm getOrDefault ["draft",createHashMap];
private _draftRows=_draftVM getOrDefault ["rows",[]];
private _exactRows=_draftRows select {(_x getOrDefault ["className",""]) isEqualTo "30Rnd_65x39_caseless_mag" && {(_x getOrDefault ["stateMode",""]) isEqualTo "EXACT"}};
private _gate447=(_newDraft getOrDefault ["success",false]) && {(_addFak getOrDefault ["success",false])} && {(_addExact getOrDefault ["success",false])} && {(_vmR getOrDefault ["success",false])}
    && {(_draftVM getOrDefault ["totalMass",0])>0}
    && {(count _draftRows)>=2}
    && {({_x getOrDefault ["massKnown",false]} count _draftRows)>=2}
    && {(count _exactRows) isEqualTo 1}
    && {((_exactRows#0) getOrDefault ["stateData",[]]) isEqualTo [30,17,6]};
["ITEMS-0.11-447",_gate447,"View-model expõe massa unitária/linha e massa total do Draft sem perder a semântica EXACT."] call _assert;

// 448 — focused paths mostram awareness sem cair no FULL ou serviços caros.
private _srcDraft=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshDraftMutationUI.sqf";
private _srcEquip=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshEquipmentViewUI.sqf";
private _srcCat=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshCatalogWindowUI.sqf";
private _srcAware=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_getUIEntryAwareness.sqf";
private _gate448=(_srcDraft find "totalMass" >= 0) && {(_srcEquip find "capacity" >= 0)} && {(_srcCat find "massEstimate" >= 0)}
    && {(_srcDraft find "fnc_refreshInterface;" < 0)} && {(_srcEquip find "fnc_refreshInterface;" < 0)}
    && {(_srcAware find "fnc_getCatalog;" < 0)} && {(_srcAware find "fnc_filterCatalog;" < 0)} && {(_srcAware find "fnc_buildCatalog;" < 0)};
["ITEMS-0.11-448",_gate448,"Draft/Equipment/Catálogo exibem awareness nos refreshes focais; helper de massa não chama FULL nem build/filter/getCatalog."] call _assert;

// 449 — smoke runtime: Draft Awareness continua DRAFT_FOCUSED e não incrementa FULL.
private _existing=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
if (!isNull _existing) then {closeDialog 0; uiSleep 0.03;};
private _dialog=createDialog "SP_ORG_Items_Dialog";
uiSleep 0.12;
private _stateSeed=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _fullBefore=_stateSeed getOrDefault ["fullRefreshCount",0];
private _focusedOk=["CP_C_AWARENESS"] call ServoPeregrino_Organizador_Items_fnc_refreshDraftMutationUI;
private _stateAfter=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _gate449=_dialog && {_focusedOk} && {(_stateAfter getOrDefault ["fullRefreshCount",-1]) isEqualTo _fullBefore} && {(_stateAfter getOrDefault ["lastRefreshMode",""]) isEqualTo "DRAFT_FOCUSED"} && {(_stateAfter getOrDefault ["lastDraftTotalMass",0])>0};
["ITEMS-0.11-449",_gate449,"Smoke runtime mantém Item Awareness dentro de DRAFT_FOCUSED; massa total atualiza sem novo FULL."] call _assert;

// 450 — toda a CP-C é derivada/read-only fora do Draft de teste: sem novo scan, sem loadout e sem storage real.
private _catalogAfter=([] call ServoPeregrino_Organizador_Items_fnc_getCatalogStatus) getOrDefault ["data",createHashMap];
private _loadoutAfter=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _productionMid=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _gate450=(_catalogAfter getOrDefault ["configScanCount",-1]) isEqualTo (_catalogBefore getOrDefault ["configScanCount",-2])
    && {(_catalogAfter getOrDefault ["buildCount",-1]) isEqualTo (_catalogBefore getOrDefault ["buildCount",-2])}
    && {(_loadoutAfter getOrDefault ["serialized","B"]) isEqualTo (_loadoutBefore getOrDefault ["serialized","A"])}
    && {_productionMid isEqualTo _productionBefore};
["ITEMS-0.11-450",_gate450,"CP-C não cria scan/build extra, não altera loadout e mantém Storage Guard: awareness é derivado/runtime."] call _assert;

private _displayEnd=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
if (!isNull _displayEnd) then {closeDialog 0; uiSleep 0.03;};
if (_fixtureOk) then {deleteVehicle _fixture;};
["AUTO_0_11_C",true] call ServoPeregrino_Organizador_Items_fnc_configureRepositoryTestMode;
["",false] call ServoPeregrino_Organizador_Items_fnc_configureRepositoryTestMode;
[_productionBefore] call ServoPeregrino_Organizador_Items_fnc_restoreProductionRepositorySnapshot;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;

private _durationMs=round ((diag_tickTime-_startedAt)*1000);
private _summary=createHashMapFromArray [["delivery","0.11 CP-C"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],["base",_base],["baseExpected",442],["checkpointFirstGate",443],["checkpointLastGate",450],["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],["cumulativeExpected",450],["cumulativePassed",442+_passed],["durationMs",_durationMs],["capacityItemAwareness",true]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] 0.11 CP-C — BASE=442/442  CP-C=%1/8  FAIL=%2  CUMULATIVO=%3/450  TEMPO=%4ms",_passed,_failed,442+_passed,_durationMs];
diag_log "[SP_ORG] [ITEMS] 0.11 CP-C — Manual: validar massa por linha, total do Draft, quantidade/massa do Equipment e carga usada/máxima/livre; trocar kits deve continuar KIT_SWITCH_FOCUSED/fullDelta=0.";
diag_log "============================================================";
if (hasInterface) then {hint parseText format ["<t size='1.25'>SP_ORG_Items 0.11 CP-C</t><br/><br/>Baseline CP-B.7: <t color='#7CFC00'>442 / 442</t><br/>CP-C: <t color='%1'>%2 / 8</t><br/>Cumulativo: %3 / 450<br/><br/>%4",if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_passed,442+_passed,if (_failed isEqualTo 0) then {"Valide massa/capacidade na UI e confirme a fluidez da troca de kits."} else {"Consulte o primeiro FAIL no RPT."}];};
_summary
