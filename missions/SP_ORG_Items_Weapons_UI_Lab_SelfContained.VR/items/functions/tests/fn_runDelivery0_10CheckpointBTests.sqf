#include "..\..\script_version.hpp"

private _legacyRunningState = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR, createHashMap];
if (_legacyRunningState getOrDefault ["running", false]) exitWith {
    [false, "ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING", "A regressão 0.9.3 já está em execução.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _orchestrator = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR, createHashMap];
private _running = _orchestrator getOrDefault ["running", false];
private _elapsed = if (_running) then {diag_tickTime - (_orchestrator getOrDefault ["startedAtTick", diag_tickTime])} else {0};
if (_running && {_elapsed < 900}) exitWith {
    [false, "ITEMS_0_10_CP_B_ALREADY_RUNNING", "Checkpoint B já está em execução.", createHashMapFromArray [["elapsedMs", round (_elapsed * 1000)]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _startedAt = diag_tickTime;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR, createHashMapFromArray [["running", true], ["startedAtTick", _startedAt], ["delivery", "0.10-CP-B.1"]]];
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.10 CP-B.1 — REGRESSÃO 0.9.3 + GATES 364..381";
diag_log "============================================================";

private _legacy = createHashMapFromArray [["success",false],["passed",0],["failed",363],["code","ITEMS_LEGACY_CALL_DID_NOT_RETURN"]];
private _legacyCall = [] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_9_3Tests;
if !(isNil "_legacyCall") then {if (_legacyCall isEqualType createHashMap) then {_legacy=_legacyCall;};};
private _legacyOk = (_legacy getOrDefault ["success", false]) && {(_legacy getOrDefault ["passed", 0]) isEqualTo 363} && {(_legacy getOrDefault ["failed", -1]) isEqualTo 0};
private _passed = 0;
private _failed = 0;
private _results = [];
private _assert = {
    params ["_id", "_condition", "_detail"];
    private _status = if (_condition) then {"PASS"} else {"FAIL"};
    if (_condition) then {_passed = _passed + 1;} else {_failed = _failed + 1;};
    _results pushBack [_id, _status, _detail];
    diag_log format ["[SP_ORG] [ITEMS] [TEST 0.10 CP-B.1] [%1] %2 — %3", _status, _id, _detail];
};
// CP-B.1: não executar gates novos sobre uma baseline já vermelha.
// Isso evita falhas em cascata e mantém o primeiro erro real observável.
if !(_legacyOk) exitWith {
    private _durationMs = round ((diag_tickTime - _startedAt) * 1000);
    private _summary = createHashMapFromArray [
        ["delivery","0.10-CP-B.1"], ["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD], ["success",false],
        ["code","ITEMS_0_10_CP_B_LEGACY_GATE_FAILED"], ["legacy",_legacy], ["legacyExpected",363],
        ["checkpointSkipped",true], ["checkpointFirstGate",364], ["checkpointLastGate",381],
        ["checkpointTotal",0], ["checkpointPassed",0], ["checkpointFailed",0], ["checkpointResults",[]],
        ["cumulativeExpected",381], ["durationMs",_durationMs]
    ];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
    diag_log "============================================================";
    diag_log format ["[SP_ORG] [ITEMS] 0.10 CP-B.1 — FAIL-FAST: regressão 0.9.3 = %1/363; gates 364..381 NÃO executados.",_legacy getOrDefault ["passed",0]];
    diag_log "[SP_ORG] [ITEMS] Corrija primeiro a regressão legada; o CP-B não mascara causa raiz com falhas em cascata.";
    diag_log "============================================================";
    if (hasInterface) then {
        hint parseText format ["<t size='1.25'>SP_ORG_Items 0.10 — CP-B.1 REPROVADO</t><br/><br/>Baseline 0.9.3: <t color='#FF6B6B'>%1 / 363</t><br/>Gates CP-B 364..381: NÃO EXECUTADOS<br/><br/>Fail-fast preservou a causa raiz. Verifique o primeiro erro SP_ORG no RPT.",_legacy getOrDefault ["passed",0]];
    };
    _summary
};

private _fixtures = [];
private _makeFixture = {
    params [["_fak", 0, [0]], ["_magAmmo", -1, [0]], ["_reserved", false, [false]]];
    private _o = createVehicleLocal ["GroundWeaponHolder_Scripted", [0,0,0], [], 0, "CAN_COLLIDE"];
    if (_fak > 0) then {_o addItemCargoGlobal ["FirstAidKit", _fak];};
    if (_magAmmo >= 0) then {_o addMagazineAmmoCargo ["30Rnd_65x39_caseless_mag", 1, _magAmmo];};
    if (_reserved) then {_o addWeaponCargoGlobal ["arifle_MX_F", 1]; _o addBackpackCargoGlobal ["B_AssaultPack_khk", 1];};
    _fixtures pushBack _o;
    _o
};
private _mkEntry = {
    params ["_type", "_class", "_qty", "_mode", "_states"];
    private _r = [_type, _class, _qty, _mode, _states] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
    ((_r getOrDefault ["data", createHashMap]) getOrDefault ["entry", []])
};
private _ctxHuge = createHashMapFromArray [["containerClass", "GroundWeaponHolder_Scripted"], ["maxLoadOverride", 100000], ["currentLoadOverride", 0], ["sourceProvider", "TEST"]];
private _fak1 = ["ITEM", "FirstAidKit", 1, "NONE", []] call _mkEntry;
private _fak2 = ["ITEM", "FirstAidKit", 2, "NONE", []] call _mkEntry;
private _fak3 = ["ITEM", "FirstAidKit", 3, "NONE", []] call _mkEntry;
private _fak4 = ["ITEM", "FirstAidKit", 4, "NONE", []] call _mkEntry;
private _tool1 = ["ITEM", "ToolKit", 1, "NONE", []] call _mkEntry;
private _mag17 = ["MAGAZINE", "30Rnd_65x39_caseless_mag", 1, "EXACT", [17]] call _mkEntry;
private _magFull = ["MAGAZINE", "30Rnd_65x39_caseless_mag", 1, "DEFAULT_FULL", []] call _mkEntry;

// 364 — Whole-Kit ADD dry-run único.
private _fx364 = [1,17,true] call _makeFixture;
private _before364R = [_fx364,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_getMutableContentFingerprint;
private _plan364R = [_fx364,"TEST_CONTAINER","ADD",[_fak2,_tool1,_magFull],"BEST_EFFORT",_ctxHuge] call ServoPeregrino_Organizador_Items_fnc_createWholeKitApplicationPlan;
private _after364R = [_fx364,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_getMutableContentFingerprint;
private _plan364 = ((_plan364R getOrDefault ["data",createHashMap]) getOrDefault ["plan",createHashMap]);
private _fp364a = ((_before364R getOrDefault ["data",createHashMap]) getOrDefault ["fingerprint",createHashMap]);
private _fp364b = ((_after364R getOrDefault ["data",createHashMap]) getOrDefault ["fingerprint",createHashMap]);
["ITEMS-0.10-364", (_plan364R getOrDefault ["success",false]) && {(count (_plan364 getOrDefault ["actions",[]])) isEqualTo 3} && {(_plan364 getOrDefault ["scope",""]) isEqualTo "WHOLE_KIT"} && {(_fp364a getOrDefault ["serialized","A"]) isEqualTo (_fp364b getOrDefault ["serialized","B"])}, "Whole-Kit ADD cria um único plan dry-run para o conjunto e não muta durante planejamento."] call _assert;

// 365 — BEST_EFFORT parcial por capacidade.
private _massFak = ([_fak1] call ServoPeregrino_Organizador_Items_fnc_getEntryUnitMass) getOrDefault ["mass",0];
private _fx365 = [0,-1,false] call _makeFixture;
private _ctxSmall = createHashMapFromArray [["containerClass","GroundWeaponHolder_Scripted"],["maxLoadOverride",_massFak * 1.5],["currentLoadOverride",0],["sourceProvider","TEST"]];
private _plan365R = [_fx365,"TEST_CONTAINER","ADD",[_fak3,_tool1],"BEST_EFFORT",_ctxSmall] call ServoPeregrino_Organizador_Items_fnc_createWholeKitApplicationPlan;
private _exec365 = if (_plan365R getOrDefault ["success",false]) then {[((_plan365R getOrDefault ["data",createHashMap]) getOrDefault ["plan",createHashMap]),createHashMap] call ServoPeregrino_Organizador_Items_fnc_executeApplicationPlan} else {_plan365R};
private _apply365 = ((_exec365 getOrDefault ["data",createHashMap]) getOrDefault ["applyResult",createHashMap]);
["ITEMS-0.10-365", (_exec365 getOrDefault ["success",false]) && {(_apply365 getOrDefault ["status",""]) isEqualTo "PARTIAL"} && {(count (_apply365 getOrDefault ["rejectedEntries",[]])) > 0} && {(count (_apply365 getOrDefault ["appliedEntries",[]])) > 0}, "Whole-Kit ADD BEST_EFFORT aplica o subconjunto possível e agrega rejeições por capacidade."] call _assert;

// 366 — STRICT recusa antes de commit.
private _fx366 = [0,-1,false] call _makeFixture;
private _fp366a = ((([_fx366,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_getMutableContentFingerprint) getOrDefault ["data",createHashMap]) getOrDefault ["fingerprint",createHashMap]);
private _strict366 = [_fx366,"TEST_CONTAINER","ADD",[_fak3,_tool1],"STRICT",_ctxSmall] call ServoPeregrino_Organizador_Items_fnc_createWholeKitApplicationPlan;
private _fp366b = ((([_fx366,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_getMutableContentFingerprint) getOrDefault ["data",createHashMap]) getOrDefault ["fingerprint",createHashMap]);
["ITEMS-0.10-366", !(_strict366 getOrDefault ["success",true]) && {(_fp366a getOrDefault ["serialized","A"]) isEqualTo (_fp366b getOrDefault ["serialized","B"])}, "Whole-Kit ADD STRICT falha atomicamente no planning quando qualquer entrada não cabe."] call _assert;

// 367 — REMOVE BEST_EFFORT.
private _fx367 = [2,17,false] call _makeFixture;
private _plan367R = [_fx367,"TEST_CONTAINER","REMOVE",[_fak4,_mag17,_tool1],"BEST_EFFORT",createHashMapFromArray [["containerClass","GroundWeaponHolder_Scripted"],["sourceProvider","TEST"]]] call ServoPeregrino_Organizador_Items_fnc_createWholeKitApplicationPlan;
private _exec367 = if (_plan367R getOrDefault ["success",false]) then {[((_plan367R getOrDefault ["data",createHashMap]) getOrDefault ["plan",createHashMap]),createHashMap] call ServoPeregrino_Organizador_Items_fnc_executeApplicationPlan} else {_plan367R};
private _apply367 = ((_exec367 getOrDefault ["data",createHashMap]) getOrDefault ["applyResult",createHashMap]);
["ITEMS-0.10-367", (_exec367 getOrDefault ["success",false]) && {(_apply367 getOrDefault ["status",""]) isEqualTo "PARTIAL"} && {(count (_apply367 getOrDefault ["actionResults",[]])) >= 2} && {(count (_apply367 getOrDefault ["rejectedEntries",[]])) > 0}, "Whole-Kit REMOVE BEST_EFFORT remove o disponível e mantém relatório agregado dos faltantes."] call _assert;

// 368 — REMOVE STRICT sem mutação.
private _fx368 = [2,17,false] call _makeFixture;
private _fp368a = ((([_fx368,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_getMutableContentFingerprint) getOrDefault ["data",createHashMap]) getOrDefault ["fingerprint",createHashMap]);
private _plan368 = [_fx368,"TEST_CONTAINER","REMOVE",[_fak4,_mag17,_tool1],"STRICT",createHashMapFromArray [["containerClass","GroundWeaponHolder_Scripted"]]] call ServoPeregrino_Organizador_Items_fnc_createWholeKitApplicationPlan;
private _fp368b = ((([_fx368,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_getMutableContentFingerprint) getOrDefault ["data",createHashMap]) getOrDefault ["fingerprint",createHashMap]);
["ITEMS-0.10-368", !(_plan368 getOrDefault ["success",true]) && {(_fp368a getOrDefault ["serialized","A"]) isEqualTo (_fp368b getOrDefault ["serialized","B"])}, "Whole-Kit REMOVE STRICT não toca no container se qualquer requisito estiver ausente."] call _assert;

// 369/370 — REPLACE STRICT plan + commit.
private _fx369 = [3,17,true] call _makeFixture;
private _fp369a = ((([_fx369,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_getMutableContentFingerprint) getOrDefault ["data",createHashMap]) getOrDefault ["fingerprint",createHashMap]);
private _replace369R = [_fx369,"TEST_CONTAINER",[_tool1,_magFull],_ctxHuge] call ServoPeregrino_Organizador_Items_fnc_createReplaceApplicationPlan;
private _replace369 = ((_replace369R getOrDefault ["data",createHashMap]) getOrDefault ["plan",createHashMap]);
private _fp369b = ((([_fx369,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_getMutableContentFingerprint) getOrDefault ["data",createHashMap]) getOrDefault ["fingerprint",createHashMap]);
["ITEMS-0.10-369", (_replace369R getOrDefault ["success",false]) && {(_replace369 getOrDefault ["operation",""]) isEqualTo "REPLACE"} && {(_replace369 getOrDefault ["policy",""]) isEqualTo "STRICT"} && {(_fp369a getOrDefault ["serialized","A"]) isEqualTo (_fp369b getOrDefault ["serialized","B"])}, "REPLACE possui planner dedicado, é sempre STRICT e permanece dry-run."] call _assert;
private _exec370 = if (_replace369R getOrDefault ["success",false]) then {[_replace369,createHashMap] call ServoPeregrino_Organizador_Items_fnc_executeApplicationPlan} else {_replace369R};
private _fp370 = ((([_fx369,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_getMutableContentFingerprint) getOrDefault ["data",createHashMap]) getOrDefault ["fingerprint",createHashMap]);
private _expected370 = _replace369 getOrDefault ["expectedFingerprint",createHashMap];
["ITEMS-0.10-370", (_exec370 getOrDefault ["success",false]) && {(_fp370 getOrDefault ["serialized","A"]) isEqualTo (_expected370 getOrDefault ["serialized","B"])}, "REPLACE concluído deixa o CONTENT físico exatamente no estado materializado do kit desejado."] call _assert;

// 371 — rollback durante REPLACE.
private _fx371 = [3,17,true] call _makeFixture;
private _before371 = ((([_fx371,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_getMutableContentFingerprint) getOrDefault ["data",createHashMap]) getOrDefault ["fingerprint",createHashMap]);
private _r371 = [_fx371,"TEST_CONTAINER",[_tool1,_magFull],_ctxHuge] call ServoPeregrino_Organizador_Items_fnc_createReplaceApplicationPlan;
private _e371 = if (_r371 getOrDefault ["success",false]) then {[((_r371 getOrDefault ["data",createHashMap]) getOrDefault ["plan",createHashMap]),createHashMapFromArray [["injectFailureAfterActionIndex",0]]] call ServoPeregrino_Organizador_Items_fnc_executeApplicationPlan} else {_r371};
private _after371 = ((([_fx371,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_getMutableContentFingerprint) getOrDefault ["data",createHashMap]) getOrDefault ["fingerprint",createHashMap]);
["ITEMS-0.10-371", !(_e371 getOrDefault ["success",true]) && {(_e371 getOrDefault ["code",""]) isEqualTo "ITEMS_ROLLED_BACK"} && {(_before371 getOrDefault ["serialized","A"]) isEqualTo (_after371 getOrDefault ["serialized","B"])}, "Falha injetada no meio de REPLACE restaura integralmente o fingerprint focal anterior."] call _assert;

// 372/373 — CLEAR + reserved preservado.
private _fx372 = [3,17,true] call _makeFixture;
private _cap372 = [_fx372,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_captureContainerContent;
private _reserved372a = [((_cap372 getOrDefault ["data",createHashMap]) getOrDefault ["reservedCargo",[]])] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _clear372R = [_fx372,"TEST_CONTAINER",createHashMapFromArray [["containerClass","GroundWeaponHolder_Scripted"],["sourceProvider","TEST"]]] call ServoPeregrino_Organizador_Items_fnc_createClearApplicationPlan;
private _exec372 = if (_clear372R getOrDefault ["success",false]) then {[((_clear372R getOrDefault ["data",createHashMap]) getOrDefault ["plan",createHashMap]),createHashMap] call ServoPeregrino_Organizador_Items_fnc_executeApplicationPlan} else {_clear372R};
private _cap372b = [_fx372,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_captureContainerContent;
private _data372b = _cap372b getOrDefault ["data",createHashMap];
private _reserved372b = _data372b getOrDefault ["reservedCargo",[]];
["ITEMS-0.10-372", (_exec372 getOrDefault ["success",false]) && {(count (_data372b getOrDefault ["entries",[]])) isEqualTo 0}, "CLEAR remove todo CONTENT mutável do target."] call _assert;
["ITEMS-0.10-373", _reserved372a isEqualTo _reserved372b && {(_reserved372b findIf {(_x getOrDefault ["kind",""]) isEqualTo "WEAPON"}) >= 0} && {(_reserved372b findIf {(_x getOrDefault ["kind",""]) isEqualTo "NESTED_CONTAINER"}) >= 0}, "CLEAR não possui nem reconstrói weapon/nested reserved cargo."] call _assert;

// 374 — rollback durante CLEAR.
private _fx374 = [3,17,true] call _makeFixture;
private _before374 = ((([_fx374,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_getMutableContentFingerprint) getOrDefault ["data",createHashMap]) getOrDefault ["fingerprint",createHashMap]);
private _r374 = [_fx374,"TEST_CONTAINER",createHashMapFromArray [["containerClass","GroundWeaponHolder_Scripted"]]] call ServoPeregrino_Organizador_Items_fnc_createClearApplicationPlan;
private _e374 = if (_r374 getOrDefault ["success",false]) then {[((_r374 getOrDefault ["data",createHashMap]) getOrDefault ["plan",createHashMap]),createHashMapFromArray [["injectFailureAfterActionIndex",0]]] call ServoPeregrino_Organizador_Items_fnc_executeApplicationPlan} else {_r374};
private _after374 = ((([_fx374,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_getMutableContentFingerprint) getOrDefault ["data",createHashMap]) getOrDefault ["fingerprint",createHashMap]);
["ITEMS-0.10-374", !(_e374 getOrDefault ["success",true]) && {(_e374 getOrDefault ["code",""]) isEqualTo "ITEMS_ROLLED_BACK"} && {(_before374 getOrDefault ["serialized","A"]) isEqualTo (_after374 getOrDefault ["serialized","B"])}, "Falha injetada durante CLEAR reconstitui o fingerprint focal anterior."] call _assert;

// 375 — stale revalidation.
private _fx375 = [0,-1,false] call _makeFixture;
private _p375R = [_fx375,"TEST_CONTAINER","ADD",[_tool1],"BEST_EFFORT",_ctxHuge] call ServoPeregrino_Organizador_Items_fnc_createWholeKitApplicationPlan;
_fx375 addItemCargoGlobal ["FirstAidKit",1];
private _e375 = if (_p375R getOrDefault ["success",false]) then {[((_p375R getOrDefault ["data",createHashMap]) getOrDefault ["plan",createHashMap]),createHashMap] call ServoPeregrino_Organizador_Items_fnc_executeApplicationPlan} else {_p375R};
private _entries375 = (([_fx375,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_captureContainerContent) getOrDefault ["data",createHashMap]) getOrDefault ["entries",[]];
["ITEMS-0.10-375", !(_e375 getOrDefault ["success",true]) && {(_e375 getOrDefault ["code",""]) isEqualTo "ITEMS_PLAN_STALE"} && {(_entries375 findIf {(_x # 2) isEqualTo "ToolKit"}) < 0}, "Revalidation stale acontece antes do snapshot/commit e não deixa a ação planejada vazar."] call _assert;

// 376 — token/owner/stale lock hardening.
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_STATE_VAR, createHashMapFromArray [["ready",true],["executing",false],["activePlanId",""],["lockToken",""],["lockOwner",""],["lockAcquiredAtTick",-1],["lastResult",createHashMap],["planVersion",1],["snapshotVersion",1],["applyResultVersion",1]]];
private _lockA = ["plan-A","owner-A",30] call ServoPeregrino_Organizador_Items_fnc_acquireApplicationLock;
private _tokenA = ((_lockA getOrDefault ["data",createHashMap]) getOrDefault ["token",""]);
private _lockB = ["plan-B","owner-B",30] call ServoPeregrino_Organizador_Items_fnc_acquireApplicationLock;
private _wrongRelease = ["wrong-token",createHashMap] call ServoPeregrino_Organizador_Items_fnc_releaseApplicationLock;
private _state376 = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_STATE_VAR,createHashMap];
private _ownerPreserved = (_state376 getOrDefault ["lockToken",""]) isEqualTo _tokenA && {_state376 getOrDefault ["executing",false]};
_state376 set ["lockAcquiredAtTick",diag_tickTime - 60]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_STATE_VAR,_state376];
private _lockC = ["plan-C","owner-C",1] call ServoPeregrino_Organizador_Items_fnc_acquireApplicationLock;
private _tokenC = ((_lockC getOrDefault ["data",createHashMap]) getOrDefault ["token",""]);
private _releaseC = [_tokenC,createHashMap] call ServoPeregrino_Organizador_Items_fnc_releaseApplicationLock;
private _recoveredC = ((_lockC getOrDefault ["data",createHashMap]) getOrDefault ["recovered",false]);
private _lock376Ok = (_lockA getOrDefault ["success",false]) && {!(_lockB getOrDefault ["success",true])} && {(_lockB getOrDefault ["code",""]) isEqualTo "ITEMS_APPLICATION_BUSY"} && {!(_wrongRelease getOrDefault ["success",true])} && {_ownerPreserved} && {(_lockC getOrDefault ["success",false])} && {_recoveredC} && {_releaseC getOrDefault ["success",false]};
["ITEMS-0.10-376", _lock376Ok, "Lock possui token/owner, recusa concorrência, não libera owner alheio e recupera somente lock stale identificável."] call _assert;

// 377 — Draft NEW não salvo é fonte aplicável.
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR, createHashMapFromArray [["ready",true],["hasDraft",false],["current",createHashMap],["baseline",createHashMap],["revision",0],["lastAction","NONE"]]];
private _d377 = ["Draft CP-B NEW","ANY",["MANUAL","CPB_TEST"],[_fak1]] call ServoPeregrino_Organizador_Items_fnc_createNewDraft;
private _fx377 = [0,-1,false] call _makeFixture;
private _e377 = [_fx377,"TEST_CONTAINER","ADD","BEST_EFFORT",_ctxHuge,createHashMap] call ServoPeregrino_Organizador_Items_fnc_executeDraftApplication;
private _state377 = (([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap]) getOrDefault ["current",createHashMap];
private _entries377 = (([_fx377,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_captureContainerContent) getOrDefault ["data",createHashMap]) getOrDefault ["entries",[]];
["ITEMS-0.10-377", (_d377 getOrDefault ["success",false]) && {(_e377 getOrDefault ["success",false])} && {(_state377 getOrDefault ["mode",""]) isEqualTo "NEW"} && {(_state377 getOrDefault ["kitId","A"]) isEqualTo ""} && {_state377 getOrDefault ["dirty",false]} && {(_entries377 findIf {(_x # 2) isEqualTo "FirstAidKit" && {(_x # 3) isEqualTo 1}}) >= 0}, "Draft NEW é aplicado a partir da memória sem Save implícito e permanece NEW/dirty."] call _assert;

// 378/379 — Draft dirty atual vs kit salvo + snapshot lógico sem mutação do repository.
private _suffix = format ["CPB_%1",round (diag_tickTime * 1000)];
[_suffix,true] call ServoPeregrino_Organizador_Items_fnc_configureRepositoryTestMode;
private _kit378R = ["Kit Persistido CP-B",[_fak1],"ANY",["MANUAL","CPB_TEST"],""] call ServoPeregrino_Organizador_Items_fnc_createItemKit;
private _kit378 = ((_kit378R getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]]);
private _save378 = [_kit378] call ServoPeregrino_Organizador_Items_fnc_saveKit;
private _kitId378 = ((_save378 getOrDefault ["data",createHashMap]) getOrDefault ["kitId",""]);
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR, createHashMapFromArray [["ready",true],["hasDraft",false],["current",createHashMap],["baseline",createHashMap],["revision",0],["lastAction","NONE"]]];
private _load378 = [_kitId378] call ServoPeregrino_Organizador_Items_fnc_loadDraftFromKit;
private _inc378 = ["ITEM","FirstAidKit","NONE"] call ServoPeregrino_Organizador_Items_fnc_incrementDraftEntry;
private _fx378 = [0,-1,false] call _makeFixture;
private _e378 = [_fx378,"TEST_CONTAINER","ADD","BEST_EFFORT",_ctxHuge,createHashMap] call ServoPeregrino_Organizador_Items_fnc_executeDraftApplication;
private _entries378 = (([_fx378,"TEST_CONTAINER","GroundWeaponHolder_Scripted"] call ServoPeregrino_Organizador_Items_fnc_captureContainerContent) getOrDefault ["data",createHashMap]) getOrDefault ["entries",[]];
private _persisted378R = [_kitId378] call ServoPeregrino_Organizador_Items_fnc_getKit;
private _persisted378 = ((_persisted378R getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]]);
private _persistedQty378 = if ((count _persisted378) > 8) then {((_persisted378 # 8) # 0) # 3} else {-1};
["ITEMS-0.10-378", (_load378 getOrDefault ["success",false]) && {(_inc378 getOrDefault ["success",false])} && {(_e378 getOrDefault ["success",false])} && {(_entries378 findIf {(_x # 2) isEqualTo "FirstAidKit" && {(_x # 3) isEqualTo 2}}) >= 0} && {_persistedQty378 isEqualTo 1}, "Draft EDIT dirty corrente é a autoridade da aplicação; backing kit salvo antigo não sobrescreve o experimento."] call _assert;
private _before379 = [_persisted378] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _fx379 = [0,-1,false] call _makeFixture;
private _e379 = [_fx379,"TEST_CONTAINER",_kitId378,"ADD","BEST_EFFORT",_ctxHuge,createHashMap] call ServoPeregrino_Organizador_Items_fnc_executeSavedKitApplication;
private _after379R = [_kitId378] call ServoPeregrino_Organizador_Items_fnc_getKit;
private _after379 = ((_after379R getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]]);
private _source379 = ((_e379 getOrDefault ["data",createHashMap]) getOrDefault ["applicationSource",createHashMap]);
["ITEMS-0.10-379", (_e379 getOrDefault ["success",false]) && {(_source379 getOrDefault ["identity",""]) isEqualTo _kitId378} && {_before379 isEqualTo _after379}, "Aplicar kit salvo usa cópia lógica e não altera ID, timestamps ou payload persistido."] call _assert;

// 380 — target explícito, preferred e fallback determinístico.
private _t380a = ["VEST","BACKPACK",["UNIFORM","VEST","BACKPACK"]] call ServoPeregrino_Organizador_Items_fnc_chooseApplicationTarget;
private _t380b = ["ANY","BACKPACK",["UNIFORM","VEST","BACKPACK"]] call ServoPeregrino_Organizador_Items_fnc_chooseApplicationTarget;
private _t380c = ["ANY","VEST",["BACKPACK","UNIFORM"]] call ServoPeregrino_Organizador_Items_fnc_chooseApplicationTarget;
private _d380a = _t380a getOrDefault ["data",createHashMap]; private _d380b = _t380b getOrDefault ["data",createHashMap]; private _d380c = _t380c getOrDefault ["data",createHashMap];
["ITEMS-0.10-380", (_d380a getOrDefault ["target",""]) isEqualTo "VEST" && {(_d380a getOrDefault ["reason",""]) isEqualTo "EXPLICIT"} && {(_d380b getOrDefault ["target",""]) isEqualTo "BACKPACK"} && {(_d380b getOrDefault ["reason",""]) isEqualTo "PREFERRED"} && {(_d380c getOrDefault ["target",""]) isEqualTo "UNIFORM"}, "Target explícito vence; ANY usa preferred disponível e depois ordem determinística U/C/M sem misturar containers."] call _assert;

// 381 — ApplyResult agregado por kit.
private _fx381 = [0,-1,false] call _makeFixture;
private _r381 = [_fx381,"TEST_CONTAINER","ADD",[_fak2,_mag17],"BEST_EFFORT",_ctxHuge] call ServoPeregrino_Organizador_Items_fnc_createWholeKitApplicationPlan;
private _e381 = if (_r381 getOrDefault ["success",false]) then {[((_r381 getOrDefault ["data",createHashMap]) getOrDefault ["plan",createHashMap]),createHashMap] call ServoPeregrino_Organizador_Items_fnc_executeApplicationPlan} else {_r381};
private _a381 = ((_e381 getOrDefault ["data",createHashMap]) getOrDefault ["applyResult",createHashMap]);
["ITEMS-0.10-381", (_e381 getOrDefault ["success",false]) && {(_a381 getOrDefault ["operation",""]) isEqualTo "ADD"} && {(_a381 getOrDefault ["status",""]) isEqualTo "COMPLETE"} && {(count (_a381 getOrDefault ["requestedEntries",[]])) isEqualTo 2} && {(count (_a381 getOrDefault ["appliedEntries",[]])) isEqualTo 2} && {(count (_a381 getOrDefault ["actionResults",[]])) isEqualTo 2} && {(count (_a381 getOrDefault ["rejectedEntries",[]])) isEqualTo 0}, "ApplyResult Whole-Kit preserva pedido, ações por entrada, aplicadas, rejeitadas, status e operação."] call _assert;

// Cleanup isolado.
{if (!isNull _x) then {deleteVehicle _x;};} forEach _fixtures;
[_suffix,true] call ServoPeregrino_Organizador_Items_fnc_configureRepositoryTestMode;
["",false] call ServoPeregrino_Organizador_Items_fnc_configureRepositoryTestMode;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR, createHashMapFromArray [["ready",true],["hasDraft",false],["current",createHashMap],["baseline",createHashMap],["revision",0],["lastAction","NONE"]]];

private _durationMs = round ((diag_tickTime - _startedAt) * 1000);
private _summary = createHashMapFromArray [
    ["delivery","0.10-CP-B.1"], ["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD], ["success",_legacyOk && {_failed isEqualTo 0}],
    ["legacy",_legacy], ["legacyExpected",363], ["checkpointFirstGate",364], ["checkpointLastGate",381],
    ["checkpointTotal",_passed + _failed], ["checkpointPassed",_passed], ["checkpointFailed",_failed], ["checkpointResults",_results],
    ["cumulativeExpected",381], ["durationMs",_durationMs]
];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] 0.10 CP-B.1 — LEGACY=%1/363  CP-B=%2/18  FAIL=%3  CUMULATIVO=%4/381  TEMPO=%5ms",_legacy getOrDefault ["passed",0],_passed,_failed,(_legacy getOrDefault ["passed",0]) + _passed,_durationMs];
diag_log "[SP_ORG] [ITEMS] CP-C permanece pendente: gates 382..388. CP-D: 389..390.";
diag_log "============================================================";
if (hasInterface) then {
    hint parseText format ["<t size='1.25'>SP_ORG_Items 0.10 — Checkpoint B.1</t><br/><br/>Baseline 0.9.3: <t color='%1'>%2 / 363</t><br/>Whole-Kit Engine: <t color='%3'>%4 / 18</t><br/>Cumulativo atual: %5 / 381<br/><br/>ADD/REMOVE kit, REPLACE, CLEAR, lock e fontes Draft/Kit: CP-B.<br/>UI física / Full DnD continuam OFF até CP-C.",if (_legacyOk) then {"#7CFC00"} else {"#FF6B6B"},_legacy getOrDefault ["passed",0],if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_passed,(_legacy getOrDefault ["passed",0]) + _passed];
};
_summary
