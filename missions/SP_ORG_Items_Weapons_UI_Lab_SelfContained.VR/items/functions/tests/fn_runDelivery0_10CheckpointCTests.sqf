#include "..\..\script_version.hpp"

private _legacyRunningState = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR, createHashMap];
if (_legacyRunningState getOrDefault ["running", false]) exitWith {
    [false, "ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING", "A regressão 0.9.3 já está em execução.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _orchestrator = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR, createHashMap];
if (_orchestrator getOrDefault ["running", false]) exitWith {
    [false, "ITEMS_0_10_CP_C_ALREADY_RUNNING", "Outro checkpoint de testes já está em execução.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _startedAt = diag_tickTime;
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.10 CP-C.1 — GATE 381/381 + UI PHYSICAL/FULL DND 382..388";
diag_log "============================================================";

// Primeiro prova toda a fundação homologada. O próprio CP-B.1 compõe 363 + 18.
private _base = createHashMapFromArray [["success",false],["code","ITEMS_0_10_CP_B_CALL_DID_NOT_RETURN"]];
private _baseCall = [] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_10CheckpointBTests;
if !(isNil "_baseCall") then {if (_baseCall isEqualType createHashMap) then {_base=_baseCall;};};
private _baseOk = (_base getOrDefault ["success",false]) && {(_base getOrDefault ["checkpointPassed",0]) isEqualTo 18} && {((_base getOrDefault ["legacy",createHashMap]) getOrDefault ["passed",0]) isEqualTo 363};
if !(_baseOk) exitWith {
    private _summary = createHashMapFromArray [["delivery","0.10-CP-C.1"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",false],["code","ITEMS_0_10_CP_C_BASE_381_FAILED"],["base",_base],["checkpointSkipped",true],["checkpointFirstGate",382],["checkpointLastGate",388],["checkpointTotal",0],["checkpointPassed",0],["checkpointFailed",0],["cumulativeExpected",388]];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    diag_log "[SP_ORG] [ITEMS] 0.10 CP-C.1 — FAIL-FAST: fundação 381/381 não fechou; gates 382..388 NÃO executados.";
    if (hasInterface) then {hint "SP_ORG_Items CP-C.1 reprovado no gate-base 381/381. Gates 382..388 não executados; consulte o primeiro erro no RPT.";};
    _summary
};

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR, createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.10-CP-C.1"]]];
private _passed = 0;
private _failed = 0;
private _results = [];
private _assert = {
    params ["_id","_condition","_detail"];
    private _status = if (_condition) then {"PASS"} else {"FAIL"};
    if (_condition) then {_passed = _passed + 1;} else {_failed = _failed + 1;};
    _results pushBack [_id,_status,_detail];
    diag_log format ["[SP_ORG] [ITEMS] [TEST 0.10 CP-C.1] [%1] %2 — %3",_status,_id,_detail];
};

private _oldAppState = [missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
// Fixture hermética: nunca criar/equipar CAManBase nos testes automáticos.
// Mods externos podem reagir a loadout de entidades sintéticas; GroundWeaponHolder evita esse acoplamento.
private _fixture = createVehicleLocal ["GroundWeaponHolder_Scripted",[0,0,0],[],0,"CAN_COLLIDE"];
private _fixtureTarget = "TEST_CONTAINER";
private _fixtureClass = "GroundWeaponHolder_Scripted";
private _fixtureReady = !isNull _fixture;
private _testResolved = createHashMapFromArray [["target",_fixtureTarget],["container",_fixture],["containerClass",_fixtureClass]];
private _testOptions = createHashMapFromArray [["testResolvedTarget",_testResolved],["commandOrigin","TEST"]];

// 382 — readiness físico depende de Engine + target e não muta durante a consulta.
private _fp382a = createHashMap;
private _fp382b = createHashMap;
if (_fixtureReady) then {
    _fp382a = ((([_fixture,_fixtureTarget,_fixtureClass] call ServoPeregrino_Organizador_Items_fnc_getMutableContentFingerprint) getOrDefault ["data",createHashMap]) getOrDefault ["fingerprint",createHashMap]);
};
private _stateOff = [_oldAppState] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
_stateOff set ["ready",false]; _stateOff set ["executing",false]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_STATE_VAR,_stateOff];
private _r382off = [_fixture,_fixtureTarget,"ANY",_testOptions] call ServoPeregrino_Organizador_Items_fnc_getUIPhysicalReadiness;
private _stateOn = [_oldAppState] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
_stateOn set ["ready",true]; _stateOn set ["executing",false]; _stateOn set ["lockToken",""]; _stateOn set ["lockOwner",""]; _stateOn set ["activePlanId",""]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_STATE_VAR,_stateOn];
private _r382on = [_fixture,_fixtureTarget,"ANY",_testOptions] call ServoPeregrino_Organizador_Items_fnc_getUIPhysicalReadiness;
if (_fixtureReady) then {
    _fp382b = ((([_fixture,_fixtureTarget,_fixtureClass] call ServoPeregrino_Organizador_Items_fnc_getMutableContentFingerprint) getOrDefault ["data",createHashMap]) getOrDefault ["fingerprint",createHashMap]);
};
private _d382off = _r382off getOrDefault ["data",createHashMap]; private _d382on = _r382on getOrDefault ["data",createHashMap];
["ITEMS-0.10-382", _fixtureReady && {!(_d382off getOrDefault ["physicalMutationEnabled",true])} && {(_d382on getOrDefault ["physicalMutationEnabled",false])} && {(_d382on getOrDefault ["resolvedTarget",""]) isEqualTo _fixtureTarget} && {(_fp382a getOrDefault ["serialized","A"]) isEqualTo (_fp382b getOrDefault ["serialized","B"])}, "UI física só habilita quando Engine e target resolvem; a consulta de readiness não muta o container."] call _assert;

// 383 — snapshot do drag congela identidade/payload no START.
private _payload383 = ["MAGAZINE","30Rnd_65x39_caseless_mag",2,"EXACT",[17,6]];
private _snap383R = ["EQUIPMENT",4120,"row-A",_payload383,"Magazine A"] call ServoPeregrino_Organizador_Items_fnc_createUIDragSnapshot;
_payload383 set [1,"FirstAidKit"]; _payload383 set [4,[1,2]];
private _snap383 = ((_snap383R getOrDefault ["data",createHashMap]) getOrDefault ["drag",createHashMap]);
private _frozen383 = _snap383 getOrDefault ["sourcePayload",[]];
["ITEMS-0.10-383", (_snap383R getOrDefault ["success",false]) && {(_snap383 getOrDefault ["sourceId",""]) isEqualTo "row-A"} && {(_frozen383 param [1,""]) isEqualTo "30Rnd_65x39_caseless_mag"} && {(_frozen383 param [4,[]]) isEqualTo [17,6]}, "Full DnD congela identidade e payload no START; mudança posterior da seleção/origem lógica não troca o objeto arrastado."] call _assert;

// Fixtures de repository/draft isoladas para 384..388.
private _suffix = format ["CPC_%1",round (diag_tickTime * 1000)];
[_suffix,true] call ServoPeregrino_Organizador_Items_fnc_configureRepositoryTestMode;
private _entryKitR = ["ITEM","FirstAidKit",1,"NONE",[]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _entryKit = ((_entryKitR getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]]);
private _kitR = ["Kit CP-C",[_entryKit],"UNIFORM",["MANUAL","CPC_TEST"],""] call ServoPeregrino_Organizador_Items_fnc_createItemKit;
private _kit = ((_kitR getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]]);
private _saveKit = [_kit] call ServoPeregrino_Organizador_Items_fnc_saveKit;
private _kitId = ((_saveKit getOrDefault ["data",createHashMap]) getOrDefault ["kitId",""]);

// 384 — todos os drops no Draft são lógicos; Equipment EXACT preserva estado e inventário não muda.
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMapFromArray [["ready",true],["hasDraft",false],["current",createHashMap],["baseline",createHashMap],["revision",0],["lastAction","NONE"]]];
["Draft CP-C Logical","ANY",["MANUAL","CPC_TEST"],[]] call ServoPeregrino_Organizador_Items_fnc_createNewDraft;
_fixture addMagazineAmmoCargo ["30Rnd_65x39_caseless_mag",1,17];
private _fp384a = ((([_fixture,_fixtureTarget,_fixtureClass] call ServoPeregrino_Organizador_Items_fnc_getMutableContentFingerprint) getOrDefault ["data",createHashMap]) getOrDefault ["fingerprint",createHashMap]);
private _l384a = ["CATALOG","FirstAidKit","DRAFT","AUTO",_fixture,"",createHashMapFromArray [["commandOrigin","DND"]]] call ServoPeregrino_Organizador_Items_fnc_executeUITransferCommand;
private _l384b = ["EQUIPMENT",["MAGAZINE","30Rnd_65x39_caseless_mag",1,"EXACT",[17]],"DRAFT","AUTO",_fixture,"",createHashMapFromArray [["commandOrigin","DND"]]] call ServoPeregrino_Organizador_Items_fnc_executeUITransferCommand;
private _l384c = ["KIT",_kitId,"DRAFT","AUTO",_fixture,"",createHashMapFromArray [["commandOrigin","DND"]]] call ServoPeregrino_Organizador_Items_fnc_executeUITransferCommand;
private _fp384b = ((([_fixture,_fixtureTarget,_fixtureClass] call ServoPeregrino_Organizador_Items_fnc_getMutableContentFingerprint) getOrDefault ["data",createHashMap]) getOrDefault ["fingerprint",createHashMap]);
private _draft384 = ((([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap]) getOrDefault ["current",createHashMap]);
private _entries384 = _draft384 getOrDefault ["entries",[]];
private _hasExact384 = (_entries384 findIf {(_x#1) isEqualTo "MAGAZINE" && {(_x#2) isEqualTo "30Rnd_65x39_caseless_mag"} && {(_x#4) isEqualTo "EXACT"} && {(_x#5) isEqualTo [17]}}) >= 0;
["ITEMS-0.10-384", (_l384a getOrDefault ["success",false]) && {(_l384b getOrDefault ["success",false])} && {(_l384c getOrDefault ["success",false])} && {_hasExact384} && {(_fp384a getOrDefault ["serialized","A"]) isEqualTo (_fp384b getOrDefault ["serialized","B"])}, "Catálogo/Equipment/Kit -> Draft permanecem operações lógicas; Equipment EXACT é capturado sem remover a origem física."] call _assert;

// 385 — drop físico de entrada unitária e kit inteiro é target-scoped e não consome a origem lógica.
private _before385 = (([_fixture,_fixtureTarget,_fixtureClass] call ServoPeregrino_Organizador_Items_fnc_captureContainerContent) getOrDefault ["data",createHashMap]) getOrDefault ["entries",[]];
private _p385a = ["CATALOG","FirstAidKit","PHYSICAL","ADD",_fixture,_fixtureTarget,createHashMapFromArray [["commandOrigin","DND"],["testResolvedTarget",_testResolved]]] call ServoPeregrino_Organizador_Items_fnc_executeUITransferCommand;
private _p385b = ["KIT",_kitId,"PHYSICAL","ADD",_fixture,_fixtureTarget,createHashMapFromArray [["commandOrigin","DND"],["testResolvedTarget",_testResolved]]] call ServoPeregrino_Organizador_Items_fnc_executeUITransferCommand;
private _after385 = (([_fixture,_fixtureTarget,_fixtureClass] call ServoPeregrino_Organizador_Items_fnc_captureContainerContent) getOrDefault ["data",createHashMap]) getOrDefault ["entries",[]];
private _fakQty385 = 0; {if ((_x#1) isEqualTo "ITEM" && {(_x#2) isEqualTo "FirstAidKit"}) then {_fakQty385 = _fakQty385 + (_x#3);};} forEach _after385;
private _cmd385a = ((_p385a getOrDefault ["data",createHashMap]) getOrDefault ["uiCommand",createHashMap]);
private _cmd385b = ((_p385b getOrDefault ["data",createHashMap]) getOrDefault ["uiCommand",createHashMap]);
private _kitStill385 = [_kitId] call ServoPeregrino_Organizador_Items_fnc_getKit;
["ITEMS-0.10-385", (_p385a getOrDefault ["success",false]) && {(_p385b getOrDefault ["success",false])} && {_fakQty385 >= 2} && {(_cmd385a getOrDefault ["target",""]) isEqualTo _fixtureTarget} && {(_cmd385b getOrDefault ["target",""]) isEqualTo _fixtureTarget} && {(_cmd385a getOrDefault ["singleDispatch",false])} && {(_cmd385b getOrDefault ["singleDispatch",false])} && {(_kitStill385 getOrDefault ["success",false])}, "Drop físico materializa entrada unitária e kit inteiro somente no target resolvido, usando um dispatch por gesto e sem consumir o kit salvo."] call _assert;

// 386 — Arrow e DnD convergem para o mesmo comando lógico; uma invocação produz delta 1, sem duplicação.
private _runLogical386 = {
    params ["_origin"];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMapFromArray [["ready",true],["hasDraft",false],["current",createHashMap],["baseline",createHashMap],["revision",0],["lastAction","NONE"]]];
    [format ["Draft 386 %1",_origin],"ANY",["MANUAL","CPC_TEST"],[]] call ServoPeregrino_Organizador_Items_fnc_createNewDraft;
    private _r=["CATALOG","FirstAidKit","DRAFT","AUTO",_fixture,"",createHashMapFromArray [["commandOrigin",_origin]]] call ServoPeregrino_Organizador_Items_fnc_executeUITransferCommand;
    private _cur=((([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap]) getOrDefault ["current",createHashMap]);
    private _qty=0; {if ((_x#1) isEqualTo "ITEM" && {(_x#2) isEqualTo "FirstAidKit"}) then {_qty=_qty+(_x#3);};} forEach (_cur getOrDefault ["entries",[]]);
    [_r,_qty]
};
private _a386=["ARROW"] call _runLogical386; private _d386=["DND"] call _runLogical386;
private _ca386=(((_a386#0) getOrDefault ["data",createHashMap]) getOrDefault ["uiCommand",createHashMap]);
private _cd386=(((_d386#0) getOrDefault ["data",createHashMap]) getOrDefault ["uiCommand",createHashMap]);
["ITEMS-0.10-386", ((_a386#0) getOrDefault ["success",false]) && {((_d386#0) getOrDefault ["success",false])} && {(_a386#1) isEqualTo 1} && {(_d386#1) isEqualTo 1} && {(_ca386 getOrDefault ["operation",""]) isEqualTo "LOGICAL_COPY"} && {(_cd386 getOrDefault ["operation",""]) isEqualTo "LOGICAL_COPY"} && {!(_ca386 getOrDefault ["mutatesInventory",true])} && {!(_cd386 getOrDefault ["mutatesInventory",true])}, "Seta e DnD usam o mesmo UI Transfer Command; cada gesto lógico adiciona exatamente uma unidade e não duplica a mutação."] call _assert;

// 387 — DELETE/MINUS/quantidade 0 convergem para REMOVE e preservam estados EXACT individuais.
private _exact387R=["MAGAZINE","30Rnd_65x39_caseless_mag",3,"EXACT",[30,17,6]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _exact387=((_exact387R getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]]);
private _del387=["DELETE",_exact387,0] call ServoPeregrino_Organizador_Items_fnc_createUIPhysicalRowCommand;
private _min387=["MINUS",_exact387,-1] call ServoPeregrino_Organizador_Items_fnc_createUIPhysicalRowCommand;
private _zero387=["QUANTITY",_exact387,0] call ServoPeregrino_Organizador_Items_fnc_createUIPhysicalRowCommand;
private _dd387=_del387 getOrDefault ["data",createHashMap]; private _dm387=_min387 getOrDefault ["data",createHashMap]; private _dz387=_zero387 getOrDefault ["data",createHashMap];
private _ed387=_dd387 getOrDefault ["entry",[]]; private _em387=_dm387 getOrDefault ["entry",[]]; private _ez387=_dz387 getOrDefault ["entry",[]];
["ITEMS-0.10-387", (_del387 getOrDefault ["success",false]) && {(_min387 getOrDefault ["success",false])} && {(_zero387 getOrDefault ["success",false])} && {(_dd387 getOrDefault ["operation",""]) isEqualTo "REMOVE"} && {(_dm387 getOrDefault ["operation",""]) isEqualTo "REMOVE"} && {(_dz387 getOrDefault ["operation",""]) isEqualTo "REMOVE"} && {(_ed387#3) isEqualTo 3} && {(_ed387#5) isEqualTo [30,17,6]} && {(_em387#3) isEqualTo 1} && {(_em387#5) isEqualTo [30]} && {(_ez387#3) isEqualTo 3} && {(_ez387#5) isEqualTo [30,17,6]}, "Delete, decremento e quantidade 0 normalizam para REMOVE; magazine EXACT preserva estados individuais em vez de virar DEFAULT_FULL."] call _assert;

// 388 — cancelamento/target inválido não altera Draft, storage nem inventário.
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMapFromArray [["ready",true],["hasDraft",false],["current",createHashMap],["baseline",createHashMap],["revision",0],["lastAction","NONE"]]];
["Draft 388","ANY",["MANUAL","CPC_TEST"],[_entryKit]] call ServoPeregrino_Organizador_Items_fnc_createNewDraft;
private _draft388a=[(([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap])] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _kit388a=((([_kitId] call ServoPeregrino_Organizador_Items_fnc_getKit) getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]]);
private _fp388a=((([_fixture,_fixtureTarget,_fixtureClass] call ServoPeregrino_Organizador_Items_fnc_getMutableContentFingerprint) getOrDefault ["data",createHashMap]) getOrDefault ["fingerprint",createHashMap]);
private _snap388R=["CATALOG",3120,"FirstAidKit","FirstAidKit","FAK"] call ServoPeregrino_Organizador_Items_fnc_createUIDragSnapshot;
private _snap388=((_snap388R getOrDefault ["data",createHashMap]) getOrDefault ["drag",createHashMap]);
private _ui388=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]; _ui388 set ["dragState",_snap388]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_ui388];
["TEST_CANCEL"] call ServoPeregrino_Organizador_Items_fnc_cancelUIDrag;
private _invalid388=["CATALOG","FirstAidKit","INVALID_TARGET","ADD",_fixture,_fixtureTarget,createHashMap] call ServoPeregrino_Organizador_Items_fnc_executeUITransferCommand;
private _draft388b=[(([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap])] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _kit388b=((([_kitId] call ServoPeregrino_Organizador_Items_fnc_getKit) getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]]);
private _fp388b=((([_fixture,_fixtureTarget,_fixtureClass] call ServoPeregrino_Organizador_Items_fnc_getMutableContentFingerprint) getOrDefault ["data",createHashMap]) getOrDefault ["fingerprint",createHashMap]);
private _uiState388 = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _drag388=_uiState388 getOrDefault ["dragState",createHashMap];
private _uiCopy388=[_uiState388] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _dragCopy388=_uiCopy388 getOrDefault ["dragState",createHashMap];
["ITEMS-0.10-388", !(_invalid388 getOrDefault ["success",true]) && {!(_drag388 getOrDefault ["active",true])} && {!(_drag388 getOrDefault ["hasSourcePayload",true])} && {(_drag388 getOrDefault ["sourcePayload",["INVALID"]]) isEqualTo []} && {!(_dragCopy388 getOrDefault ["active",true])} && {_draft388a isEqualTo _draft388b} && {_kit388a isEqualTo _kit388b} && {(_fp388a getOrDefault ["serialized","A"]) isEqualTo (_fp388b getOrDefault ["serialized","B"])}, "Drop/cancelamento inválido encerra o gesto sem alterar Draft/storage/inventário e mantém dragState nil-free/deep-copy safe."] call _assert;

// Cleanup CP-C.
if (!isNull _fixture) then {deleteVehicle _fixture;};
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_STATE_VAR,_oldAppState];
[_suffix,true] call ServoPeregrino_Organizador_Items_fnc_configureRepositoryTestMode;
["",false] call ServoPeregrino_Organizador_Items_fnc_configureRepositoryTestMode;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMapFromArray [["ready",true],["hasDraft",false],["current",createHashMap],["baseline",createHashMap],["revision",0],["lastAction","NONE"]]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];

private _durationMs = round ((diag_tickTime - _startedAt) * 1000);
private _summary = createHashMapFromArray [
    ["delivery","0.10-CP-C.1"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],
    ["base",_base],["baseExpected",381],["checkpointFirstGate",382],["checkpointLastGate",388],
    ["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],
    ["cumulativeExpected",388],["cumulativePassed",381+_passed],["durationMs",_durationMs]
];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] 0.10 CP-C.1 — BASE=381/381  CP-C=%1/7  FAIL=%2  CUMULATIVO=%3/388  TEMPO=%4ms",_passed,_failed,381+_passed,_durationMs];
diag_log "[SP_ORG] [ITEMS] CP-D permanece pendente: gates 389..390 (refresh focal + end-to-end).";
diag_log "============================================================";
if (hasInterface) then {
    hint parseText format ["<t size='1.25'>SP_ORG_Items 0.10 — Checkpoint C.1</t><br/><br/>Fundação CP-B.1: <t color='#7CFC00'>381 / 381</t><br/>Physical UI + Full DnD: <t color='%1'>%2 / 7</t><br/>Cumulativo: %3 / 388<br/><br/>Próximo gate: CP-D 389..390.",if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_passed,381+_passed];
};
_summary
