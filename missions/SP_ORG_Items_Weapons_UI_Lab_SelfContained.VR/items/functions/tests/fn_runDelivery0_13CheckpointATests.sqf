#include "..\..\script_version.hpp"
disableSerialization;

private _legacyRunningState=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR,createHashMap];
if (_legacyRunningState getOrDefault ["running",false]) exitWith {[false,"ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING","A regressão legada já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _orchestrator=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
if (_orchestrator getOrDefault ["running",false]) exitWith {[false,"ITEMS_0_13_A_ALREADY_RUNNING","Outra suíte já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _startedAt=diag_tickTime;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.13-A"]]];
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.13-A — SERVER AUTHORITY FOUNDATION — GATES 655..664";
diag_log "[SP_ORG] [ITEMS] BASELINE: 0.12 FINAL homologada manualmente; gates históricos 516/523 permanecem dívida aceita e não bloqueiam este checkpoint.";
diag_log "============================================================";

private _passed=0; private _failed=0; private _results=[];
private _assert={params ["_id","_condition","_detail"]; private _ok=(_condition isEqualType true)&&{_condition}; private _status=if (_ok) then {"PASS"} else {"FAIL"}; if (_ok) then {_passed=_passed+1}else{_failed=_failed+1}; _results pushBack [_id,_status,_detail]; diag_log format ["[SP_ORG] [ITEMS] [TEST 0.13-A] [%1] %2 — %3",_status,_id,_detail];};

private _publicBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VAR,[]]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _authorityBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_AUTHORITY_VAR,[]]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _uiBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _loadoutBefore=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];

private _srcDesc=preprocessFileLineNumbers "description.ext";
private _srcCfg=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\config.cpp";
private _srcPublish=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\library\fn_publishKitToPublic.sqf";
private _srcRequest=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\library\fn_requestPublicKitPublish.sqf";
private _srcServer=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\library\fn_serverHandlePublicLibraryRequest.sqf";
private _srcCommit=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\library\fn_commitPublicKitSnapshotServer.sqf";
private _srcCallback=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\library\fn_clientReceivePublicLibraryResult.sqf";

private _gate655=(SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DISPLAY_VERSION isEqualTo "0.13-A") && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_SEMANTIC_VERSION isEqualTo "0.13.0.1"} && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_13_A_GATE_COUNT isEqualTo 10} && {(_srcDesc find "class runDelivery0_13CheckpointATests {}")>=0} && {(_srcCfg find "class runDelivery0_13CheckpointATests {}")>=0};
["ITEMS-0.13-655",_gate655,"0.13-A está versionada sobre a 0.12 FINAL e registra um checkpoint aditivo próprio sem renumerar gates históricos."] call _assert;

private _gate656=(_srcDesc find "fnc_serverHandlePublicLibraryRequest {allowedTargets = 2")>=0 && {(_srcDesc find "fnc_clientReceivePublicLibraryResult {allowedTargets = 1")>=0} && {(_srcCfg find "fnc_serverHandlePublicLibraryRequest {allowedTargets = 2")>=0} && {(_srcCfg find "fnc_clientReceivePublicLibraryResult {allowedTargets = 1")>=0};
["ITEMS-0.13-656",_gate656,"CfgRemoteExec libera apenas o endpoint server-only e o callback client-only do contrato público; nenhuma execução genérica call/spawn é adicionada."] call _assert;

private _auth1=[] call ServoPeregrino_Organizador_Items_fnc_initializePublicLibraryAuthority;
private _auth2=[] call ServoPeregrino_Organizador_Items_fnc_initializePublicLibraryAuthority;
private _authority=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_AUTHORITY_VAR,[]];
private _gate657=isServer && {(_auth1 getOrDefault ["success",false])} && {(_auth2 getOrDefault ["success",false])} && {(_authority isEqualType [])} && {(count _authority) isEqualTo 4} && {(_authority#2) isEqualTo "SERVER"};
["ITEMS-0.13-657",_gate657,"Inicialização da autoridade é server-owned e idempotente; o servidor publica metadata SERVER sem depender do Repository privado."] call _assert;

private _libR=[] call ServoPeregrino_Organizador_Items_fnc_getPublicLibrary;
private _libD=_libR getOrDefault ["data",createHashMap];
private _gate658=(_libR getOrDefault ["success",false]) && {(_libD getOrDefault ["scope",""]) isEqualTo "SESSION"} && {(_libD getOrDefault ["authority",""]) isEqualTo "SERVER"} && {_libD getOrDefault ["authoritative",false]};
["ITEMS-0.13-658",_gate658,"Biblioteca continua SESSION-scoped, mas passa a declarar SERVER como autoridade de mutação nesta etapa."] call _assert;

// Isola completamente o estado público para os testes do checkpoint.
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VAR,[SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_MAGIC,SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VERSION,0,[]]];
private _entryR=["ITEM","FirstAidKit",2,"NONE",[]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _entry=((_entryR getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]]);
private _kitR=["013A Authority Fixture",[_entry],"ANY",["TEST","013A"]] call ServoPeregrino_Organizador_Items_fnc_createItemKit;
private _kit=((_kitR getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]]);
private _kitId=_kit param [2,"",[""]];
private _commit1=[_kit,_kitId,"Autor A","AUTH-A","PLAYER"] call ServoPeregrino_Organizador_Items_fnc_commitPublicKitSnapshotServer;
private _commit1D=_commit1 getOrDefault ["data",createHashMap];
private _publicIdA=_commit1D getOrDefault ["publicId",""];
private _after1=[] call ServoPeregrino_Organizador_Items_fnc_listPublicKits;
private _after1D=_after1 getOrDefault ["data",createHashMap];
private _gate659=(_commit1 getOrDefault ["success",false]) && {_publicIdA isNotEqualTo ""} && {_commit1D getOrDefault ["created",false]} && {(_after1D getOrDefault ["count",0]) isEqualTo 1} && {(_after1D getOrDefault ["revision",0]) isEqualTo 1};
["ITEMS-0.13-659",_gate659,"Commit server-only valida snapshot e cria a primeira publicação autoritativa, incrementando a revisão exatamente uma vez."] call _assert;

private _kitChanged=[_kit] call ServoPeregrino_Organizador_Items_fnc_deepCopy; _kitChanged set [3,"013A Authority Fixture Updated"];
private _commit2=[_kitChanged,_kitId,"Autor A","AUTH-A","PLAYER"] call ServoPeregrino_Organizador_Items_fnc_commitPublicKitSnapshotServer;
private _commit2D=_commit2 getOrDefault ["data",createHashMap];
private _after2=[] call ServoPeregrino_Organizador_Items_fnc_listPublicKits;
private _after2D=_after2 getOrDefault ["data",createHashMap];
private _get2=[_publicIdA] call ServoPeregrino_Organizador_Items_fnc_getPublicKit;
private _kit2=((_get2 getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]]);
private _gate660=(_commit2 getOrDefault ["success",false]) && {!(_commit2D getOrDefault ["created",true])} && {(_commit2D getOrDefault ["publicId",""]) isEqualTo _publicIdA} && {(_after2D getOrDefault ["count",0]) isEqualTo 1} && {(_after2D getOrDefault ["revision",0]) isEqualTo 2} && {(_kit2 param [3,"",[""]]) isEqualTo "013A Authority Fixture Updated"};
["ITEMS-0.13-660",_gate660,"Mesmo autor + mesma origem atualiza o mesmo publicId no servidor; não cria duplicata e avança uma única revisão."] call _assert;

private _commitB=[_kit,_kitId,"Autor B","AUTH-B","PLAYER"] call ServoPeregrino_Organizador_Items_fnc_commitPublicKitSnapshotServer;
private _commitBD=_commitB getOrDefault ["data",createHashMap];
private _afterB=[] call ServoPeregrino_Organizador_Items_fnc_listPublicKits;
private _afterBD=_afterB getOrDefault ["data",createHashMap];
private _gate661=(_commitB getOrDefault ["success",false]) && {(_commitBD getOrDefault ["publicId",""]) isNotEqualTo _publicIdA} && {(_afterBD getOrDefault ["count",0]) isEqualTo 2} && {(_afterBD getOrDefault ["revision",0]) isEqualTo 3};
["ITEMS-0.13-661",_gate661,"Autores diferentes podem publicar a mesma origem como snapshots independentes; autoridade do servidor preserva a identidade por autor+origem."] call _assert;

private _publicCopy=[_publicIdA] call ServoPeregrino_Organizador_Items_fnc_getPublicKit;
private _publicCopyKit=((_publicCopy getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]]);
_publicCopyKit set [3,"MUTATED CALLER COPY"];
private _publicAgain=[_publicIdA] call ServoPeregrino_Organizador_Items_fnc_getPublicKit;
private _publicAgainKit=((_publicAgain getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]]);
private _gate662=(_publicCopy getOrDefault ["success",false]) && {(_publicAgain getOrDefault ["success",false])} && {!((_publicAgainKit param [3,"",[""]]) isEqualTo "MUTATED CALLER COPY")} && {(_srcCommit find "deepCopy")>=0};
["ITEMS-0.13-662",_gate662,"Snapshot público continua defensivo: mutar a cópia retornada ao caller não contamina a autoridade no servidor."] call _assert;

private _gate663=(_srcPublish find "requestPublicKitPublish")>=0 && {(_srcPublish find "commitPublicKitSnapshotServer")>=0} && {(_srcRequest find "remoteExecCall")>=0} && {(_srcServer find "remoteExecutedOwner")>=0} && {(_srcServer find "allPlayers")>=0} && {(_srcServer find "getPlayerUID")>=0} && {(_srcCallback find "PUBLICADO")>=0} && {(_srcCallback find "remoteExecutedOwner isNotEqualTo 2")>=0};
["ITEMS-0.13-663",_gate663,"Fluxo multiplayer separa request cliente, validação/identidade no servidor e callback ao cliente; identidade do autor não é aceita como override remoto."] call _assert;

// Restore exato do estado público/UI e prova de invariância física.
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VAR,_publicBefore,true];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_AUTHORITY_VAR,_authorityBefore,true];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_uiBefore];
private _loadoutAfter=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _cmp=[_loadoutBefore,_loadoutAfter,"ITEMS-0.13-664"] call ServoPeregrino_Organizador_Items_fnc_compareLoadoutFingerprints;
private _cmpD=_cmp getOrDefault ["data",createHashMap];
private _changed=_cmpD getOrDefault ["changedIndexes",[]];
private _ambient=!(_cmpD getOrDefault ["equal",false]) && {(count _changed)>0} && {(_changed findIf {!(_x in [0,1,2])})<0};
private _gate664=((_cmpD getOrDefault ["equal",false]) || {_ambient}) && {(missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VAR,[]]) isEqualTo _publicBefore} && {(missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_AUTHORITY_VAR,[]]) isEqualTo _authorityBefore};
["ITEMS-0.13-664",_gate664,"Checkpoint restaura biblioteca/authority/UI e não toca o loadout: Server Authority Foundation permanece isolada do motor físico."] call _assert;

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
private _durationMs=round ((diag_tickTime-_startedAt)*1000);
private _summary=createHashMapFromArray [["delivery","0.13-A"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],["checkpointFirstGate",655],["checkpointLastGate",664],["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],["baseline","0.12 FINAL"],["baselineManualApproved",true],["knownHistoricalDebt",[516,523]],["durationMs",_durationMs]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] 0.13-A — NOVOS=%1/10 FAIL=%2 GATES=655..664 TEMPO=%3ms BASELINE=0.12_FINAL_MANUAL_APPROVED",_passed,_failed,_durationMs];
diag_log "[SP_ORG] [ITEMS] 0.13-A — Manual MP recomendado: host+cliente; cliente publica; ENVIADO→PUBLICADO; host/cliente veem mesma revisão; republicar atualiza sem duplicar.";
diag_log "============================================================";
if (hasInterface) then {hint parseText format ["<t size='1.25'>SP_ORG_Items 0.13-A</t><br/><br/>Novos gates: <t color='%1'>%2 / 10</t><br/>Faixa: 655..664<br/>Baseline: 0.12 FINAL homologada manualmente<br/><br/>%3",if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_passed,if (_failed isEqualTo 0) then {"Agora valide o fluxo multiplayer host+cliente."} else {"Consulte o primeiro FAIL no RPT."}];};
_summary
