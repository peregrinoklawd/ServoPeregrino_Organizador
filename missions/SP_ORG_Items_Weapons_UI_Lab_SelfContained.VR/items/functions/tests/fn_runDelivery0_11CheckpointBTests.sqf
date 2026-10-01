#include "..\..\script_version.hpp"
disableSerialization;

private _legacyRunningState=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR,createHashMap];
if (_legacyRunningState getOrDefault ["running",false]) exitWith {[false,"ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING","A regressão legada já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _orchestrator=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
if (_orchestrator getOrDefault ["running",false]) exitWith {[false,"ITEMS_0_11_CP_B_ALREADY_RUNNING","Outra suíte cumulativa já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};

private _startedAt=diag_tickTime;
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.11 CP-B — SOUND & OUTCOME FEEDBACK — 414 GATES";
diag_log "============================================================";

[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
uiSleep 0.02;
private _base=[] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_11CheckpointATests;
private _baseOk=(_base isEqualType createHashMap)
    && {_base getOrDefault ["success",false]}
    && {(_base getOrDefault ["checkpointPassed",0]) isEqualTo 8}
    && {(_base getOrDefault ["cumulativePassed",0]) isEqualTo 406};
if !(_baseOk) exitWith {
    [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
    private _summary=createHashMapFromArray [
        ["delivery","0.11 CP-B"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",false],
        ["code","ITEMS_0_11_CP_B_BASE_406_FAILED"],["base",_base],["checkpointSkipped",true],
        ["checkpointFirstGate",407],["checkpointLastGate",414],["checkpointTotal",0],["checkpointPassed",0],["checkpointFailed",0],
        ["cumulativeExpected",414]
    ];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    diag_log "[SP_ORG] [ITEMS] 0.11 CP-B — FAIL-FAST: baseline 406/406 não fechou; gates 407..414 NÃO executados.";
    if (hasInterface) then {hint "SP_ORG_Items 0.11 CP-B reprovado na baseline 406/406. Consulte o primeiro FAIL no RPT.";};
    _summary
};

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.11 CP-B"]]];
private _passed=0; private _failed=0; private _results=[];
private _assert={
    params ["_id","_condition","_detail"];
    private _status=if (_condition) then {"PASS"} else {"FAIL"};
    if (_condition) then {_passed=_passed+1;} else {_failed=_failed+1;};
    _results pushBack [_id,_status,_detail];
    diag_log format ["[SP_ORG] [ITEMS] [TEST 0.11 CP-B] [%1] %2 — %3",_status,_id,_detail];
};

private _oldUIState=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _oldAppState=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _resetUI={missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]; [] call ServoPeregrino_Organizador_Items_fnc_createUIState;};
private _mkPhysicalResult={
    params ["_ok","_code","_message","_operation","_target","_commandId","_status","_appliedQty","_rejectedCount"];
    private _applied=[]; if (_appliedQty>0) then {_applied pushBack [1,"ITEM","FirstAidKit",_appliedQty,"NONE",[]];};
    private _rejected=[]; for "_i" from 1 to _rejectedCount do {_rejected pushBack [1,"ITEM","ToolKit",1,"NONE",[]];};
    private _actions=[]; private _actionCount=(_appliedQty max 1); for "_i" from 1 to _actionCount do {_actions pushBack createHashMapFromArray [["action",_i],["success",_ok]];};
    [_ok,_code,_message,createHashMapFromArray [
        ["uiCommand",createHashMapFromArray [["operation",_operation],["target",_target],["commandId",_commandId],["singleDispatch",true]]],
        ["applyResult",createHashMapFromArray [["status",_status],["appliedEntries",_applied],["rejectedEntries",_rejected],["actionResults",_actions]]]
    ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

// 407 — os cinco sons são locais da missão e resolvem em CfgSounds.
private _soundClasses407=["SP_ORG_Items_UI_Success","SP_ORG_Items_UI_Partial","SP_ORG_Items_UI_Failure","SP_ORG_Items_UI_Rollback","SP_ORG_Items_UI_Blocked"];
private _gate407=({_x isEqualType "" && {isClass (missionConfigFile >> "CfgSounds" >> _x)}} count _soundClasses407) isEqualTo 5;
["ITEMS-0.11-407",_gate407,"CP-B registra cinco CfgSounds locais e autocontidos: success/partial/failure/rollback/blocked."] call _assert;

// 408 — SUCCESS preserva semântica operacional e metadata técnica sem acoplar o gate à copy player-facing.
private _r408=[true,"ITEMS_APPLICATION_COMPLETE","Transação física concluída.","ADD","U","TEST-408","COMPLETE",3,0] call _mkPhysicalResult;
private _o408=[_r408] call ServoPeregrino_Organizador_Items_fnc_classifyUIOutcome;
private _m408=_o408 getOrDefault ["message",""];
private _gate408=(_o408 getOrDefault ["outcome",""]) isEqualTo "SUCCESS"
    && {(_o408 getOrDefault ["severity",""]) isEqualTo "SUCCESS"}
    && {(_o408 getOrDefault ["soundKey",""]) isEqualTo "SUCCESS"}
    && {(_o408 getOrDefault ["appliedQty",-1]) isEqualTo 3}
    && {(_o408 getOrDefault ["actionCount",-1]) isEqualTo 3}
    && {(_o408 getOrDefault ["operation",""]) isEqualTo "ADD"}
    && {(_o408 getOrDefault ["target",""]) isEqualTo "U"}
    && {(_o408 getOrDefault ["commandId",""]) isEqualTo "TEST-408"}
    && {_m408 find "3 itens" >= 0};
["ITEMS-0.11-408",_gate408,"SUCCESS preserva outcome, quantidade, ações, operação, target e commandId; mensagem ao jogador permanece amigável."] call _assert;

// 409 — PARTIAL é sucesso transacional parcial, mas recebe WARN e som próprio.
private _r409=[true,"ITEMS_APPLICATION_PARTIAL","Transação concluída parcialmente.","ADD","C","TEST-409","PARTIAL",2,1] call _mkPhysicalResult;
private _o409=[_r409] call ServoPeregrino_Organizador_Items_fnc_classifyUIOutcome;
private _gate409=(_o409 getOrDefault ["outcome",""]) isEqualTo "PARTIAL"
    && {(_o409 getOrDefault ["severity",""]) isEqualTo "WARN"}
    && {(_o409 getOrDefault ["soundKey",""]) isEqualTo "PARTIAL"}
    && {(_o409 getOrDefault ["appliedQty",-1]) isEqualTo 2}
    && {(_o409 getOrDefault ["rejectedCount",-1]) isEqualTo 1}
    && {(_o409 getOrDefault ["message",""]) find "parcial" >= 0};
["ITEMS-0.11-409",_gate409,"PARTIAL é destacado como WARN, informa rejeições e usa feedback sonoro diferente de SUCCESS."] call _assert;

// 410 — BLOCKED e FAILURE são distinguíveis.
private _r410a=[false,"ITEMS_UI_PHYSICAL_NOT_READY","Application Engine ocupado.","ADD","M","TEST-410A","FAILED",0,0] call _mkPhysicalResult;
private _r410b=[false,"ITEMS_MUTATION_FAILED","Mutação física falhou.","REMOVE","U","TEST-410B","FAILED",0,0] call _mkPhysicalResult;
private _o410a=[_r410a] call ServoPeregrino_Organizador_Items_fnc_classifyUIOutcome;
private _o410b=[_r410b] call ServoPeregrino_Organizador_Items_fnc_classifyUIOutcome;
private _gate410=(_o410a getOrDefault ["outcome",""]) isEqualTo "BLOCKED"
    && {(_o410a getOrDefault ["soundKey",""]) isEqualTo "BLOCKED"}
    && {(_o410b getOrDefault ["outcome",""]) isEqualTo "FAILURE"}
    && {(_o410b getOrDefault ["severity",""]) isEqualTo "ERROR"}
    && {(_o410b getOrDefault ["soundKey",""]) isEqualTo "FAILURE"};
["ITEMS-0.11-410",_gate410,"Tentativa bloqueada e falha real não são tratadas como o mesmo outcome visual/sonoro."] call _assert;

// 411 — rollback recuperado e rollback crítico são explicitamente diferenciados.
private _rbData411=createHashMapFromArray [["uiCommand",createHashMapFromArray [["operation","REPLACE"],["target","U"],["commandId","TEST-411A"]]],["status","ROLLED_BACK"],["rolledBack",true],["rollbackSucceeded",true]];
private _rbFailData411=createHashMapFromArray [["uiCommand",createHashMapFromArray [["operation","REPLACE"],["target","U"],["commandId","TEST-411B"]]],["status","ROLLBACK_FAILED"],["rolledBack",true],["rollbackSucceeded",false]];
private _o411a=[[false,"ITEMS_ROLLED_BACK","Commit interrompido e rollback comprovado.",_rbData411] call ServoPeregrino_Organizador_Nexus_fnc_createResult] call ServoPeregrino_Organizador_Items_fnc_classifyUIOutcome;
private _o411b=[[false,"ITEMS_ROLLBACK_FAILED","Rollback não pôde ser comprovado.",_rbFailData411] call ServoPeregrino_Organizador_Nexus_fnc_createResult] call ServoPeregrino_Organizador_Items_fnc_classifyUIOutcome;
private _gate411=(_o411a getOrDefault ["outcome",""]) isEqualTo "ROLLBACK"
    && {(_o411a getOrDefault ["soundKey",""]) isEqualTo "ROLLBACK"}
    && {_o411a getOrDefault ["rolledBack",false]}
    && {_o411a getOrDefault ["rollbackSucceeded",false]}
    && {(_o411a getOrDefault ["commandId",""]) isEqualTo "TEST-411A"}
    && {(_o411b getOrDefault ["outcome",""]) isEqualTo "ROLLBACK_FAILED"}
    && {(_o411b getOrDefault ["severity",""]) isEqualTo "ERROR"}
    && {_o411b getOrDefault ["rolledBack",false]}
    && {!(_o411b getOrDefault ["rollbackSucceeded",true])}
    && {(_o411b getOrDefault ["commandId",""]) isEqualTo "TEST-411B"};
["ITEMS-0.11-411",_gate411,"Rollback comprovado e rollback crítico são diferenciados por estado, cue, severidade e metadata técnica, sem acoplamento à copy visual."] call _assert;

// 412 — serviço de som mapeia outcomes, registra histórico e silencia reprodução real durante suíte.
call _resetUI;
private _classes412=[]; private _suppressed412=true;
{
    private _sr=[_x] call ServoPeregrino_Organizador_Items_fnc_playUIFeedbackSound;
    _classes412 pushBack (_sr getOrDefault ["soundClass",""]);
    _suppressed412=_suppressed412 && {_sr getOrDefault ["suppressedByTests",false]} && {!(_sr getOrDefault ["played",true])};
} forEach ["SUCCESS","PARTIAL","FAILURE","ROLLBACK","BLOCKED"];
private _ui412=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _hist412=_ui412 getOrDefault ["soundHistory",[]];
private _gate412=(count _hist412) isEqualTo 5 && {_suppressed412} && {(count (_classes412 arrayIntersect _classes412)) isEqualTo 5} && {(_ui412 getOrDefault ["lastSoundOutcome",""]) isEqualTo "BLOCKED"};
["ITEMS-0.11-412",_gate412,"Serviço sonoro registra exatamente um cue por chamada e suprime áudio real durante testes automáticos."] call _assert;

// 413 — apresentação integrada de Result atualiza feedback, outcome, métricas e exatamente um cue.
call _resetUI;
private _r413=[true,"ITEMS_APPLICATION_PARTIAL","Aplicação parcial.","ADD","M","TEST-413","PARTIAL",4,2] call _mkPhysicalResult;
private _p413=[_r413,true] call ServoPeregrino_Organizador_Items_fnc_presentUIResult;
private _ui413=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _metrics413=_ui413 getOrDefault ["lastOutcomeMetrics",createHashMap];
private _gate413=(_p413 getOrDefault ["outcome",""]) isEqualTo "PARTIAL"
    && {(_ui413 getOrDefault ["lastFeedbackKind",""]) isEqualTo "WARN"}
    && {(_ui413 getOrDefault ["lastOutcome",""]) isEqualTo "PARTIAL"}
    && {(_metrics413 getOrDefault ["appliedQty",-1]) isEqualTo 4}
    && {(_metrics413 getOrDefault ["rejectedCount",-1]) isEqualTo 2}
    && {(count (_ui413 getOrDefault ["soundHistory",[]])) isEqualTo 1};
["ITEMS-0.11-413",_gate413,"presentUIResult integra mensagem, severidade, métricas e um único feedback sonoro por operação."] call _assert;

// 414 — seleção/target/refresh puro são silenciosos; uma operação explícita continua gerando um cue.
call _resetUI;
private _before414=count ((missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]) getOrDefault ["soundHistory",[]]);
["APP_TARGET","U"] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent;
["EQUIPMENT_VIEW","C"] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent;
["REFRESH"] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent;
private _afterPure414=count ((missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]) getOrDefault ["soundHistory",[]]);
private _r414=[true,"ITEMS_APPLICATION_COMPLETE","Operação concluída.","REMOVE","U","TEST-414","COMPLETE",1,0] call _mkPhysicalResult;
[_r414,true] call ServoPeregrino_Organizador_Items_fnc_presentUIResult;
private _afterOp414=count ((missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]) getOrDefault ["soundHistory",[]]);
["APP_TARGET","C"] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent;
private _afterSelection414=count ((missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]) getOrDefault ["soundHistory",[]]);
private _gate414=_before414 isEqualTo 0 && {_afterPure414 isEqualTo 0} && {_afterOp414 isEqualTo 1} && {_afterSelection414 isEqualTo 1};
["ITEMS-0.11-414",_gate414,"Seleção, troca de target e refresh puro não emitem som; uma operação explícita gera exatamente um cue."] call _assert;

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_STATE_VAR,_oldAppState];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_oldUIState];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;

private _durationMs=round ((diag_tickTime-_startedAt)*1000);
private _summary=createHashMapFromArray [
    ["delivery","0.11 CP-B"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],
    ["base",_base],["baseExpected",406],["checkpointFirstGate",407],["checkpointLastGate",414],
    ["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],
    ["cumulativeExpected",414],["cumulativePassed",406+_passed],["durationMs",_durationMs]
];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] 0.11 CP-B — BASE=406/406  CP-B=%1/8  FAIL=%2  CUMULATIVO=%3/414  TEMPO=%4ms",_passed,_failed,406+_passed,_durationMs];
diag_log "[SP_ORG] [ITEMS] 0.11 CP-B — Teste manual: ouvir cues e validar SUCCESS/PARTIAL/FAILURE/ROLLBACK/BLOCKED sem som em seleção/refresh.";
diag_log "============================================================";
if (hasInterface) then {
    hint parseText format ["<t size='1.25'>SP_ORG_Items 0.11 CP-B</t><br/><br/>Baseline: <t color='#7CFC00'>406 / 406</t><br/>Sound + Outcome: <t color='%1'>%2 / 8</t><br/>Cumulativo: %3 / 414<br/><br/>%4",if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_passed,406+_passed,if (_failed isEqualTo 0) then {"414/414 concluído. Faça o teste manual dos sons."} else {"Consulte o primeiro FAIL no RPT."}];
};
_summary
