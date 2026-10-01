#include "..\..\script_version.hpp"
disableSerialization;

private _legacyRunningState=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR,createHashMap];
if (_legacyRunningState getOrDefault ["running",false]) exitWith {[false,"ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING","A regressão legada já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _orchestrator=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
if (_orchestrator getOrDefault ["running",false]) exitWith {[false,"ITEMS_0_11_CP_B3_ALREADY_RUNNING","Outra suíte cumulativa já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};

private _startedAt=diag_tickTime;
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.11 CP-B.3 — REAL INVENTORY SOUND + TEST STORAGE GUARD — 424 GATES";
diag_log "============================================================";

// Protege as chaves REAIS do jogador antes de chamar qualquer runner histórico.
private _productionBefore=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
uiSleep 0.02;
private _base=[] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_11CheckpointBTests;
private _productionAfterBase=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _transientProductionChanged=!(_productionBefore isEqualTo _productionAfterBase);
private _restoreBase=[_productionBefore] call ServoPeregrino_Organizador_Items_fnc_restoreProductionRepositorySnapshot;
private _productionRestored=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _productionRestoreExact=_productionBefore isEqualTo _productionRestored;
diag_log format ["[SP_ORG] [ITEMS] [TEST_STORAGE_GUARD] afterBase transientChanged=%1 restoredExact=%2",_transientProductionChanged,_productionRestoreExact];

private _baseOk=(_base isEqualType createHashMap) && {_base getOrDefault ["success",false]} && {(_base getOrDefault ["checkpointPassed",0]) isEqualTo 8} && {(_base getOrDefault ["cumulativePassed",0]) isEqualTo 414};
if !(_baseOk) exitWith {
    [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
    private _summary=createHashMapFromArray [["delivery","0.11 CP-B.3"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",false],["code","ITEMS_0_11_CP_B3_BASE_414_FAILED"],["base",_base],["checkpointSkipped",true],["checkpointFirstGate",415],["checkpointLastGate",424],["checkpointTotal",0],["checkpointPassed",0],["checkpointFailed",0],["cumulativeExpected",424],["productionRestored",_productionRestoreExact]];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    diag_log "[SP_ORG] [ITEMS] 0.11 CP-B.3 — FAIL-FAST: baseline aprovada 414/414 não fechou; produção foi restaurada antes de sair.";
    if (hasInterface) then {hint "SP_ORG_Items 0.11 CP-B.3 reprovado na baseline 414/414. Storage de produção restaurado; consulte o primeiro FAIL no RPT.";};
    _summary
};

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.11 CP-B.3"]]];
private _passed=0; private _failed=0; private _results=[];
private _assert={params ["_id","_condition","_detail"]; private _status=if (_condition) then {"PASS"} else {"FAIL"}; if (_condition) then {_passed=_passed+1;} else {_failed=_failed+1;}; _results pushBack [_id,_status,_detail]; diag_log format ["[SP_ORG] [ITEMS] [TEST 0.11 CP-B.3] [%1] %2 — %3",_status,_id,_detail];};
private _oldUIState=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _oldDraftState=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _resetUI={missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]; [] call ServoPeregrino_Organizador_Items_fnc_createUIState;};

// 415 — provider real_sfx_inventory_sounds quando presente; fallback sempre resolvível.
private _real415=isClass (configFile >> "CfgSounds" >> "real_bagclose");
private _p415=["REMOVE"] call ServoPeregrino_Organizador_Items_fnc_getUIMovementSoundProfile;
private _c415=_p415 getOrDefault ["soundClass",""];
private _s415=_p415 getOrDefault ["classScope","MAIN"];
private _avail415=if (_s415 isEqualTo "MAIN") then {isClass (configFile >> "CfgSounds" >> _c415)} else {isClass (missionConfigFile >> "CfgSounds" >> _c415)};
private _gate415=_avail415 && {if (_real415) then {_c415 isEqualTo "real_bagclose" && {(_p415 getOrDefault ["provider",""]) isEqualTo "BGD_REAL_SFX_INVENTORY_BAGCLOSE"}} else {!(_c415 isEqualTo "")}};
["ITEMS-0.11-415",_gate415,"Provider de movimento resolve real_bagclose do real_sfx_inventory_sounds quando disponível; fallback permanece classe CfgSounds válida."] call _assert;

// 416 — ADD/REMOVE/CLEAR/REPLACE compartilham o mesmo cue e nunca usam path direto relativo à missão.
private _profiles416=["ADD","REMOVE","CLEAR","REPLACE"] apply {[_x] call ServoPeregrino_Organizador_Items_fnc_getUIMovementSoundProfile};
private _classes416=_profiles416 apply {_x getOrDefault ["soundClass",""]};
private _src416=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_playUIMovementSound.sqf";
private _gate416=({ _x isEqualTo (_classes416#0) } count _classes416) isEqualTo 4 && {_src416 find "DIRECT_FILE_FALLBACK" < 0} && {_src416 find "playSoundUI [_soundClass" >= 0};
["ITEMS-0.11-416",_gate416,"Movimento normal usa um único CfgSounds class e não tenta mais tocar asset de addon como arquivo relativo da missão."] call _assert;

// 417 — nenhum fallback depende de path de addon; último recurso é cue local autocontido.
private _srcProfile417=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_getUIMovementSoundProfile.sqf";
private _desc417=preprocessFileLineNumbers "description.ext";
private _local417=isClass (missionConfigFile >> "CfgSounds" >> "SP_ORG_Items_UI_Success");
private _gate417=_local417 && {_srcProfile417 find "SPORG_LOCAL_SAFE_FALLBACK" >= 0} && {_desc417 find "SP_ORG_Items_UI_VanillaMenuEscape" < 0};
["ITEMS-0.11-417",_gate417,"Fallback não referencia mais arquivo A3 como mission-relative; último recurso é cue local autocontido."] call _assert;

// 418 — suíte registra o gesto mas não reproduz áudio real.
call _resetUI;
private _m418=["REMOVE"] call ServoPeregrino_Organizador_Items_fnc_playUIMovementSound;
private _u418=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _gate418=(_m418 getOrDefault ["suppressedByTests",false]) && {!(_m418 getOrDefault ["attempted",true])} && {!(_m418 getOrDefault ["played",true])} && {(count (_u418 getOrDefault ["movementSoundHistory",[]])) isEqualTo 1};
["ITEMS-0.11-418",_gate418,"Teste automático suprime áudio real, mas registra exatamente um cue lógico por gesto."] call _assert;

// 419 — Delete lógico produz REMOVE audível pela camada central.
call _resetUI;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMap];
["CP-B.3 Delete Test","ANY",["TEST","B3"],[]] call ServoPeregrino_Organizador_Items_fnc_createNewDraft;
private _e419=["ITEM","FirstAidKit",1,"NONE",[]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
if (_e419 getOrDefault ["success",false]) then {[((_e419 getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]])] call ServoPeregrino_Organizador_Items_fnc_addEntryToDraft;};
private _d419=["DELETE",["ITEM","FirstAidKit","NONE"]] call ServoPeregrino_Organizador_Items_fnc_handleDraftRowAction;
[_d419,"REMOVE",true] call ServoPeregrino_Organizador_Items_fnc_presentLogicalMutationResult;
private _mh419=(missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]) getOrDefault ["movementSoundHistory",[]];
private _gate419=(_d419 getOrDefault ["success",false]) && {(count _mh419) isEqualTo 1} && {((_mh419#0)#0) isEqualTo "REMOVE"};
["ITEMS-0.11-419",_gate419,"Delete no Draft continua ligado à camada central e produz exatamente um movimento REMOVE."] call _assert;

// 420 — Delete físico, +/- e quantidade 0 continuam nos apresentadores centrais.
private _srcKey420=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUIKeyDown.sqf";
private _srcRefresh420=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshInterface.sqf";
private _srcQty420=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_commitDraftQuantityFromControl.sqf";
private _gate420=(_srcKey420 find "fnc_presentUIResult" >= 0) && {_srcKey420 find "fnc_presentLogicalMutationResult" >= 0} && {_srcRefresh420 find "fnc_presentLogicalMutationResult" >= 0} && {_srcQty420 find "fnc_presentLogicalMutationResult" >= 0};
["ITEMS-0.11-420",_gate420,"Delete Equipment, Delete Draft, +/- e quantidade 0 permanecem conectados aos apresentadores que disparam o cue de movimento."] call _assert;

// 421 — navegação permanece silenciosa.
call _resetUI;
private _before421=count ((missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]) getOrDefault ["movementSoundHistory",[]]);
["APP_TARGET","C"] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent;
["EQUIPMENT_VIEW","M"] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent;
["REFRESH"] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent;
private _after421=count ((missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]) getOrDefault ["movementSoundHistory",[]]);
["ITEMS-0.11-421",_before421 isEqualTo 0 && {_after421 isEqualTo 0},"Seleção, target/view e refresh continuam silenciosos."] call _assert;

// 422 — outcomes excepcionais continuam separados do cue de inventário.
private _srcPresent422=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_presentUIResult.sqf";
private _gate422=(_srcPresent422 find "fnc_playUIMovementSound" >= 0) && {_srcPresent422 find "fnc_playUIFeedbackSound" >= 0};
["ITEMS-0.11-422",_gate422,"SUCCESS usa movimento de inventário; PARTIAL/BLOCKED/FAILURE/ROLLBACK continuam nos cues excepcionais."] call _assert;

// 423 — composição da baseline nunca deixa alterações persistentes nas chaves reais do jogador.
private _gate423=(_restoreBase getOrDefault ["restored",false]) && {_productionRestoreExact};
["ITEMS-0.11-423",_gate423,"Runner cumulativo captura e restaura exatamente o storage de produção, impedindo que fixtures de testes se acumulem em MEUS KITS."] call _assert;

// 424 — diagnóstico reconhece fixtures históricas e não classifica um kit normal; scanner é read-only.
private _fakeEntryR=["ITEM","FirstAidKit",1,"NONE",[]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _fakeEntry=(_fakeEntryR getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]];
private _fakeTestR=["Kit CP-C",[_fakeEntry],"ANY",["MANUAL","CPC_TEST"],""] call ServoPeregrino_Organizador_Items_fnc_createItemKit;
private _fakeUserR=["Meu Kit Normal",[_fakeEntry],"ANY",["USER","NORMAL"],""] call ServoPeregrino_Organizador_Items_fnc_createItemKit;
private _ct424=[((_fakeTestR getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]])] call ServoPeregrino_Organizador_Items_fnc_classifyLeakedTestKit;
private _cu424=[((_fakeUserR getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]])] call ServoPeregrino_Organizador_Items_fnc_classifyLeakedTestKit;
private _prod424a=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _scan424=[] call ServoPeregrino_Organizador_Items_fnc_findLeakedTestKits;
private _prod424b=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _gate424=(_ct424 getOrDefault ["isTestKit",false]) && {!(_cu424 getOrDefault ["isTestKit",true])} && {_scan424 getOrDefault ["success",false]} && {_prod424a isEqualTo _prod424b};
["ITEMS-0.11-424",_gate424,"Scanner de kits vazados reconhece fixtures conhecidas, ignora kit normal e não altera o Repository."] call _assert;

// Defesa em profundidade: restaura novamente a produção ao terminar TODOS os gates da CP-B.3.
[_productionBefore] call ServoPeregrino_Organizador_Items_fnc_restoreProductionRepositorySnapshot;
private _productionFinal=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _productionFinalExact=_productionBefore isEqualTo _productionFinal;
if (!_productionFinalExact) then {diag_log "[SP_ORG] [ITEMS] [TEST_STORAGE_GUARD] WARNING final restore not exact";};
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,_oldDraftState];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_oldUIState];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
private _durationMs=round ((diag_tickTime-_startedAt)*1000);
private _summary=createHashMapFromArray [["delivery","0.11 CP-B.3"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],["base",_base],["baseExpected",414],["checkpointFirstGate",415],["checkpointLastGate",424],["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],["cumulativeExpected",424],["cumulativePassed",414+_passed],["durationMs",_durationMs],["productionRestored",_productionRestoreExact && _productionFinalExact],["transientProductionChanged",_transientProductionChanged]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] 0.11 CP-B.3 — BASE=414/414  CP-B.3=%1/10  FAIL=%2  CUMULATIVO=%3/424  TEMPO=%4ms",_passed,_failed,414+_passed,_durationMs];
diag_log format ["[SP_ORG] [ITEMS] 0.11 CP-B.3 — storageGuard restoredExact=%1 finalExact=%2 transientChanged=%3",_productionRestoreExact,_productionFinalExact,_transientProductionChanged];
diag_log "[SP_ORG] [ITEMS] 0.11 CP-B.3 — Manual: ouvir provider detectado; mover/delete nos painéis; diagnosticar e, se desejado, remover fixtures vazadas antigas.";
diag_log "============================================================";
if (hasInterface) then {hint parseText format ["<t size='1.25'>SP_ORG_Items 0.11 CP-B.3</t><br/><br/>Baseline: <t color='#7CFC00'>414 / 414</t><br/>Sound + Storage Guard: <t color='%1'>%2 / 10</t><br/>Cumulativo: %3 / 424<br/>Storage produção restaurado: %4<br/><br/>%5",if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_passed,414+_passed,(_productionRestoreExact && _productionFinalExact),if (_failed isEqualTo 0) then {"424/424 concluído. Faça o teste manual do som e veja o diagnóstico de kits vazados."} else {"Consulte o primeiro FAIL no RPT."}];};
_summary
