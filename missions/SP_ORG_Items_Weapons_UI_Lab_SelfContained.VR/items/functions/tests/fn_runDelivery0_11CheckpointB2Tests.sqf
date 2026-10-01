#include "..\..\script_version.hpp"
disableSerialization;
private _legacyRunningState=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR,createHashMap];
if (_legacyRunningState getOrDefault ["running",false]) exitWith {[false,"ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING","A regressão legada já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _orchestrator=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
if (_orchestrator getOrDefault ["running",false]) exitWith {[false,"ITEMS_0_11_CP_B2_ALREADY_RUNNING","Outra suíte cumulativa já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _startedAt=diag_tickTime;
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.11 CP-B.2 — VANILLA MENU ESCAPE SOUND + AUDIBLE DELETE — 422 GATES";
diag_log "============================================================";
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
uiSleep 0.02;
private _base=[] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_11CheckpointBTests;
private _baseOk=(_base isEqualType createHashMap) && {_base getOrDefault ["success",false]} && {(_base getOrDefault ["checkpointPassed",0]) isEqualTo 8} && {(_base getOrDefault ["cumulativePassed",0]) isEqualTo 414};
if !(_baseOk) exitWith {
    [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
    private _summary=createHashMapFromArray [["delivery","0.11 CP-B.2"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",false],["code","ITEMS_0_11_CP_B2_BASE_414_FAILED"],["base",_base],["checkpointSkipped",true],["checkpointFirstGate",415],["checkpointLastGate",422],["checkpointTotal",0],["checkpointPassed",0],["checkpointFailed",0],["cumulativeExpected",422]];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    diag_log "[SP_ORG] [ITEMS] 0.11 CP-B.2 — FAIL-FAST: baseline aprovada 414/414 não fechou; gates 415..422 NÃO executados.";
    if (hasInterface) then {hint "SP_ORG_Items 0.11 CP-B.2 reprovado na baseline 414/414. Consulte o primeiro FAIL no RPT.";};
    _summary
};
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.11 CP-B.2"]]];
private _passed=0; private _failed=0; private _results=[];
private _assert={params ["_id","_condition","_detail"]; private _status=if (_condition) then {"PASS"} else {"FAIL"}; if (_condition) then {_passed=_passed+1;} else {_failed=_failed+1;}; _results pushBack [_id,_status,_detail]; diag_log format ["[SP_ORG] [ITEMS] [TEST 0.11 CP-B.2] [%1] %2 — %3",_status,_id,_detail];};
private _oldUIState=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _oldDraftState=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _resetUI={missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]; [] call ServoPeregrino_Organizador_Items_fnc_createUIState;};

// 415 — CfgSounds da missão referencia exatamente o sample vanilla RscButtonMenu soundEscape.
private _cfg415=missionConfigFile >> "CfgSounds" >> "SP_ORG_Items_UI_VanillaMenuEscape";
private _sound415=if (isClass _cfg415) then {getArray (_cfg415 >> "sound")} else {[]};
private _path415=toLower (_sound415 param [0,"",[""]]);
private _gate415=isClass _cfg415 && {_path415 find "a3\ui_f\data\sound\rscbuttonmenu\soundescape" >= 0} && {(_sound415 param [1,0,[0]]) isEqualTo 1} && {(_sound415 param [2,0,[0]]) isEqualTo 1};
["ITEMS-0.11-415",_gate415,"Alias CfgSounds resolve o mesmo sample vanilla RscButtonMenu.soundEscape em volume/pitch normais."] call _assert;

// 416 — todos os movimentos normais usam um único cue, como solicitado.
private _profiles416=["ADD","REMOVE","CLEAR","REPLACE"] apply {[_x] call ServoPeregrino_Organizador_Items_fnc_getUIMovementSoundProfile};
private _classes416=_profiles416 apply {_x getOrDefault ["soundClass",""]};
private _paths416=_profiles416 apply {_x getOrDefault ["path",""]};
private _gate416=({ _x isEqualTo "SP_ORG_Items_UI_VanillaMenuEscape" } count _classes416) isEqualTo 4 && {({ _x isEqualTo "A3\ui_f\data\sound\RscButtonMenu\soundEscape.wss" } count _paths416) isEqualTo 4} && {({ _x getOrDefault ["unifiedCue",false] } count _profiles416) isEqualTo 4};
["ITEMS-0.11-416",_gate416,"ADD/REMOVE/CLEAR/REPLACE compartilham o mesmo cue vanilla de fechamento/cancelamento de menu."] call _assert;

// 417 — fallback de arquivo possui extensão explícita .wss; playSoundUI exige extensão quando recebe path.
private _src417=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_playUIMovementSound.sqf";
private _prof417=["REMOVE"] call ServoPeregrino_Organizador_Items_fnc_getUIMovementSoundProfile;
private _p417=toLower (_prof417 getOrDefault ["path",""]);
private _gate417=(_p417 find ".wss" isEqualTo ((count _p417)-4)) && {_src417 find "CFGSOUNDS_CLASS" >= 0} && {_src417 find "DIRECT_FILE_FALLBACK" >= 0} && {_src417 find "playSoundUI" >= 0};
["ITEMS-0.11-417",_gate417,"Reprodução prioriza CfgSounds e mantém fallback .wss explícito, evitando o silêncio por path sem extensão."] call _assert;

// 418 — serviço registra exatamente um cue por gesto durante a suíte, sem áudio real.
call _resetUI;
private _m418=["REMOVE"] call ServoPeregrino_Organizador_Items_fnc_playUIMovementSound;
private _u418=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _gate418=(_m418 getOrDefault ["suppressedByTests",false]) && {!(_m418 getOrDefault ["attempted",true])} && {!(_m418 getOrDefault ["played",true])} && {(_m418 getOrDefault ["classAvailable",false])} && {(count (_u418 getOrDefault ["movementSoundHistory",[]])) isEqualTo 1} && {(count (_u418 getOrDefault ["soundHistory",[]])) isEqualTo 1};
["ITEMS-0.11-418",_gate418,"Um gesto produz um único registro/cue; suíte automática continua sem tocar áudio real."] call _assert;

// 419 — Delete no Draft e Delete no Equipment continuam ligados aos apresentadores audíveis centrais.
private _srcKey419=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUIKeyDown.sqf";
private _srcRefresh419=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshInterface.sqf";
private _srcQty419=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_commitDraftQuantityFromControl.sqf";
private _gate419=(_srcKey419 find "fnc_presentUIResult" >= 0) && {_srcKey419 find "fnc_presentLogicalMutationResult" >= 0} && {_srcRefresh419 find "fnc_presentLogicalMutationResult" >= 0} && {_srcQty419 find "fnc_presentLogicalMutationResult" >= 0};
["ITEMS-0.11-419",_gate419,"Delete Equipment, Delete Draft, +/- e quantidade 0 permanecem conectados à camada audível central."] call _assert;

// 420 — Delete lógico real registra movimento REMOVE sem tocar inventário físico.
call _resetUI;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMap];
["CP-B.2 Delete Test","ANY",["TEST","B2"],[]] call ServoPeregrino_Organizador_Items_fnc_createNewDraft;
private _e420=["ITEM","FirstAidKit",1,"NONE",[]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
if (_e420 getOrDefault ["success",false]) then {[((_e420 getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]])] call ServoPeregrino_Organizador_Items_fnc_addEntryToDraft;};
private _d420=["DELETE",["ITEM","FirstAidKit","NONE"]] call ServoPeregrino_Organizador_Items_fnc_handleDraftRowAction;
[_d420,"REMOVE",true] call ServoPeregrino_Organizador_Items_fnc_presentLogicalMutationResult;
private _u420=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _mh420=_u420 getOrDefault ["movementSoundHistory",[]];
private _gate420=(_d420 getOrDefault ["success",false]) && {(count _mh420) isEqualTo 1} && {((_mh420#0)#0) isEqualTo "REMOVE"} && {((_mh420#0)#4) isEqualTo "SP_ORG_Items_UI_VanillaMenuEscape"};
["ITEMS-0.11-420",_gate420,"Delete lógico registra exatamente um REMOVE usando o cue RscButtonMenu soundEscape e continua sem mutação física."] call _assert;

// 421 — sucesso usa movimento; PARTIAL/BLOCKED/FAILURE/ROLLBACK continuam excepcionais.
private _srcPresent421=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_presentUIResult.sqf";
private _gate421=(_srcPresent421 find "fnc_playUIMovementSound" >= 0) && {_srcPresent421 find "fnc_playUIFeedbackSound" >= 0};
["ITEMS-0.11-421",_gate421,"SUCCESS continua no cue de movimento; PARTIAL/BLOCKED/FAILURE/ROLLBACK permanecem nos cues excepcionais."] call _assert;

// 422 — seleção, troca de target/view e refresh não criam som de movimento.
call _resetUI;
private _before422=count ((missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]) getOrDefault ["movementSoundHistory",[]]);
["APP_TARGET","C"] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent;
["EQUIPMENT_VIEW","M"] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent;
["REFRESH"] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent;
private _after422=count ((missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]) getOrDefault ["movementSoundHistory",[]]);
private _gate422=_before422 isEqualTo 0 && {_after422 isEqualTo 0};
["ITEMS-0.11-422",_gate422,"Navegação, target/view e refresh continuam silenciosos; só movimentar/deletar dispara o cue vanilla."] call _assert;

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,_oldDraftState];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_oldUIState];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
private _durationMs=round ((diag_tickTime-_startedAt)*1000);
private _summary=createHashMapFromArray [["delivery","0.11 CP-B.2"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],["base",_base],["baseExpected",414],["checkpointFirstGate",415],["checkpointLastGate",422],["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],["cumulativeExpected",422],["cumulativePassed",414+_passed],["durationMs",_durationMs]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] 0.11 CP-B.2 — BASE=414/414  CP-B.2=%1/8  FAIL=%2  CUMULATIVO=%3/422  TEMPO=%4ms",_passed,_failed,414+_passed,_durationMs];
diag_log "[SP_ORG] [ITEMS] 0.11 CP-B.2 — Manual obrigatório: comparar 'Ouvir cue menu vanilla' com fechar o menu de ações via RMB; testar Delete Draft e Delete Equipment.";
diag_log "============================================================";
if (hasInterface) then {hint parseText format ["<t size='1.25'>SP_ORG_Items 0.11 CP-B.2</t><br/><br/>Baseline: <t color='#7CFC00'>414 / 414</t><br/>Menu Escape + Delete: <t color='%1'>%2 / 8</t><br/>Cumulativo: %3 / 422<br/><br/>%4",if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_passed,414+_passed,if (_failed isEqualTo 0) then {"422/422 concluído. Teste o cue manual e Delete nos dois painéis."} else {"Consulte o primeiro FAIL no RPT."}];};
_summary
