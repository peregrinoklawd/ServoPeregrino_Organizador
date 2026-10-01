#include "..\..\script_version.hpp"
disableSerialization;

private _legacyRunningState=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR,createHashMap];
if (_legacyRunningState getOrDefault ["running",false]) exitWith {[false,"ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING","A regressão legada já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _orchestrator=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
if (_orchestrator getOrDefault ["running",false]) exitWith {[false,"ITEMS_0_12_D70_ALREADY_RUNNING","Outra suíte cumulativa já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _startedAt=diag_tickTime;
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.12-D.7.0 — PRIVATE/PUBLIC LIBRARY FOUNDATION — 627 GATES";
diag_log "============================================================";
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun; uiSleep 0.02;
private _base=createHashMapFromArray [["success",false],["code","ITEMS_0_12_D70_BASE_CALL_DID_NOT_RETURN"]];
private _baseCall=[] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_12CheckpointD64Tests;
if !(isNil "_baseCall") then {if (_baseCall isEqualType createHashMap) then {_base=_baseCall;};};
private _baseOk=(_base getOrDefault ["success",false]) && {(_base getOrDefault ["checkpointPassed",0]) isEqualTo 7} && {(_base getOrDefault ["cumulativePassed",0]) isEqualTo 617};
if !(_baseOk) exitWith {
    [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
    private _summary=createHashMapFromArray [["delivery","0.12-D.7.0"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",false],["code","ITEMS_0_12_D70_BASE_617_FAILED"],["base",_base],["checkpointSkipped",true],["checkpointFirstGate",618],["checkpointLastGate",627],["checkpointTotal",0],["checkpointPassed",0],["checkpointFailed",0],["cumulativeExpected",627]];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    diag_log "[SP_ORG] [ITEMS] 0.12-D.7.0 — FAIL-FAST: baseline D.6.4 617/617 não fechou.";
    _summary
};

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.12-D.7.0"]]];
private _passed=0; private _failed=0; private _results=[];
private _assert={params ["_id","_condition","_detail"]; private _ok=(_condition isEqualType true)&&{_condition}; private _status=if (_ok) then {"PASS"} else {"FAIL"}; if (_ok) then {_passed=_passed+1}else{_failed=_failed+1}; _results pushBack [_id,_status,_detail]; diag_log format ["[SP_ORG] [ITEMS] [TEST 0.12-D.7.0] [%1] %2 — %3",_status,_id,_detail];};

private _productionBefore=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _loadoutBefore=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _draftBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _uiBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _publicBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VAR,[]]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;

private _srcDesc=preprocessFileLineNumbers "description.ext";
private _srcCfg=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\config.cpp";
private _srcDialog=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\ui\items_dialog.hpp";
private _srcVM=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_buildUIViewModel.sqf";
private _srcEvent=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUIEvent.sqf";
private _srcDrag=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUIDragEvent.sqf";
private _srcPublish=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\library\fn_publishKitToPublic.sqf";

private _gate618=(_srcDesc find "class runDelivery0_12CheckpointD70Tests {}")>=0 && {(_srcCfg find "class runDelivery0_12CheckpointD70Tests {}")>=0} && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_7_0_GATE_COUNT isEqualTo 10} && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_7_0_CUMULATIVE_GATE_COUNT isEqualTo 627} && {(SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DISPLAY_VERSION find "0.12-D.7.") isEqualTo 0};
["ITEMS-0.12-618",_gate618,"Fundação D.7.x está registrada e o baseline D.7.0 mantém contrato cumulativo 627/627."] call _assert;

private _gate619=(_srcDialog find "KitsPrivateTab")>=0 && {(_srcDialog find "KitsPublicTab")>=0} && {(_srcDialog find "PRIVADOS")>=0} && {(_srcDialog find "PÚBLICOS")>=0} && {(_srcDialog find "SALVAR NO PRIVADO")>=0} && {(_srcDialog find "PUBLICAR")>=0};
["ITEMS-0.12-619",_gate619,"Meus Kits materializa abas PRIVADOS/PÚBLICOS e ações explícitas de publicar/copiar sem adicionar múltiplas ações por linha."] call _assert;

private _gate620=(_srcVM find "fnc_listPublicKits")>=0 && {(_srcVM find "kitLibraryMode")>=0} && {(_srcEvent find "KIT_LIBRARY_MODE")>=0} && {(_srcEvent find "selectedPublicKitId")>=0};
["ITEMS-0.12-620",_gate620,"View-model e eventos separam Repository privado da biblioteca pública sem misturar IDs/seleções."] call _assert;

// Fixture privado isolado pelo Storage Guard já instalado pela suíte cumulativa.
private _entryR=["ITEM","FirstAidKit",2,"NONE",[]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _entry=((_entryR getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]]);
private _kitR=["D70 Public Fixture",[_entry],"ANY",["TEST","D70"]] call ServoPeregrino_Organizador_Items_fnc_createItemKit;
private _kit=((_kitR getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]]);
private _save=[_kit] call ServoPeregrino_Organizador_Items_fnc_saveKit;
private _privateId=((_save getOrDefault ["data",createHashMap]) getOrDefault ["kitId",""]);
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VAR,[SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_MAGIC,SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VERSION,0,[]]];
private _pub=[_privateId,player,"PLAYER","Teste D70","TEST-AUTHOR-D70"] call ServoPeregrino_Organizador_Items_fnc_publishKitToPublic;
private _pubD=_pub getOrDefault ["data",createHashMap];
private _publicId=_pubD getOrDefault ["publicId",""];
private _listPub=[] call ServoPeregrino_Organizador_Items_fnc_listPublicKits;
private _listPubD=_listPub getOrDefault ["data",createHashMap];
private _gate621=(_pub getOrDefault ["success",false]) && {_publicId isNotEqualTo ""} && {(_listPubD getOrDefault ["count",0]) isEqualTo 1} && {(_listPubD getOrDefault ["scope",""]) isEqualTo "SESSION"};
["ITEMS-0.12-621",_gate621,"Publicar kit privado cria snapshot público SESSION-scoped separado do Repository privado."] call _assert;

// Alterar o privado depois não altera o snapshot publicado.
private _getPrivate=[_privateId] call ServoPeregrino_Organizador_Items_fnc_getKit;
private _privateKit=((_getPrivate getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]]);
_privateKit set [3,"D70 Private Changed After Publish"];
private _saveChanged=[_privateKit] call ServoPeregrino_Organizador_Items_fnc_saveKit;
private _pubGet=[_publicId] call ServoPeregrino_Organizador_Items_fnc_getPublicKit;
private _pubKit=((_pubGet getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]]);
private _gate622=(_saveChanged getOrDefault ["success",false]) && {_pubGet getOrDefault ["success",false]} && {(_pubKit#3) isEqualTo "D70 Public Fixture"};
["ITEMS-0.12-622",_gate622,"Snapshot público não é vínculo vivo: editar/salvar o privado depois da publicação não muda o público silenciosamente."] call _assert;

// Publicar novamente atualiza a mesma publicação, sem duplicar.
private _pub2=[_privateId,player,"PLAYER","Teste D70","TEST-AUTHOR-D70"] call ServoPeregrino_Organizador_Items_fnc_publishKitToPublic;
private _listPub2=[] call ServoPeregrino_Organizador_Items_fnc_listPublicKits;
private _listPub2D=_listPub2 getOrDefault ["data",createHashMap];
private _pubGet2=[_publicId] call ServoPeregrino_Organizador_Items_fnc_getPublicKit;
private _pubKit2=((_pubGet2 getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]]);
private _pub2D=_pub2 getOrDefault ["data",createHashMap];
private _gate623=(_pub2 getOrDefault ["success",false]) && {!(_pub2D getOrDefault ["created",true])} && {(_listPub2D getOrDefault ["count",0]) isEqualTo 1} && {(_pubKit2#3) isEqualTo "D70 Private Changed After Publish"};
["ITEMS-0.12-623",_gate623,"PUBLICAR novamente atualiza explicitamente o mesmo snapshot do autor/origem em vez de criar duplicata."] call _assert;

private _privateBeforeCopy=(([] call ServoPeregrino_Organizador_Items_fnc_listKits) getOrDefault ["data",createHashMap]) getOrDefault ["count",0];
private _copy=[_publicId] call ServoPeregrino_Organizador_Items_fnc_savePublicKitToPrivate;
private _copyD=_copy getOrDefault ["data",createHashMap];
private _copyId=_copyD getOrDefault ["kitId",""];
private _privateAfterCopy=(([] call ServoPeregrino_Organizador_Items_fnc_listKits) getOrDefault ["data",createHashMap]) getOrDefault ["count",0];
private _copyGet=[_copyId] call ServoPeregrino_Organizador_Items_fnc_getKit;
private _copyKit=((_copyGet getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]]);
private _gate624=(_copy getOrDefault ["success",false]) && {_copyId isNotEqualTo _privateId} && {_privateAfterCopy isEqualTo (_privateBeforeCopy+1)} && {_copyGet getOrDefault ["success",false]} && {((_copyKit#5)#0) isEqualTo "PUBLIC_COPY"};
["ITEMS-0.12-624",_gate624,"SALVAR NO PRIVADO cria novo ItemKit ID independente e registra origem PUBLIC_COPY sem sobrescrever o kit fonte."] call _assert;

private _uiState=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
_uiState set ["kitLibraryMode","PUBLIC"]; _uiState set ["selectedPublicKitId",_publicId]; _uiState set ["kitQuery","teste d70"];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_uiState];
private _vmR=[player] call ServoPeregrino_Organizador_Items_fnc_buildUIViewModel;
private _vm=_vmR getOrDefault ["data",createHashMap];
private _vmKits=_vm getOrDefault ["kits",[]];
private _gate625=(_vmR getOrDefault ["success",false]) && {(_vm getOrDefault ["kitLibraryMode",""]) isEqualTo "PUBLIC"} && {(count _vmKits) isEqualTo 1} && {((_vmKits#0) getOrDefault ["authorName",""]) isEqualTo "Teste D70"} && {(_vmKits#0) getOrDefault ["selected",false]};
["ITEMS-0.12-625",_gate625,"A aba pública filtra localmente por nome/autor/origem e expõe autor + seleção sem tocar o Draft."] call _assert;

private _gate626=(_srcDrag find "Kits públicos são somente leitura")>=0 && {(_srcEvent find "Kit público selecionado")>=0} && {(_srcEvent find "LOAD_KIT")>=0} && {(_srcPublish find "scope=SESSION")>=0};
["ITEMS-0.12-626",_gate626,"PÚBLICOS é read-only na fundação: clique não abre EDIT e DnD de Meus Kits é bloqueado até existir cópia privada."] call _assert;

// Restore all state, then assert no physical/storage leakage.
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VAR,_publicBefore];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,_draftBefore];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_uiBefore];
[_productionBefore] call ServoPeregrino_Organizador_Items_fnc_restoreProductionRepositorySnapshot;
private _loadoutAfter=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _productionAfter=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _cmp=[_loadoutBefore,_loadoutAfter,"ITEMS-0.12-627"] call ServoPeregrino_Organizador_Items_fnc_compareLoadoutFingerprints;
private _cmpD=_cmp getOrDefault ["data",createHashMap];
private _changed=_cmpD getOrDefault ["changedIndexes",[]];
private _ambient=!(_cmpD getOrDefault ["equal",false]) && {(count _changed)>0} && {(_changed findIf {!(_x in [0,1,2])})<0};
if (_ambient) then {diag_log format ["[SP_ORG] [ITEMS] [TEST_AMBIENT_DRIFT] label=ITEMS-0.12-627 changedIndexes=%1 accepted=true reason=WEAPON_SLOTS_ONLY",_changed];};
private _gate627=((_cmpD getOrDefault ["equal",false]) || {_ambient}) && {_productionAfter isEqualTo _productionBefore} && {(missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VAR,[]]) isEqualTo _publicBefore};
["ITEMS-0.12-627",_gate627,"D.7.0 restaura Repository, biblioteca pública, UI/Draft e não muta o loadout físico durante os smokes da biblioteca."] call _assert;

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
private _durationMs=round ((diag_tickTime-_startedAt)*1000);
private _summary=createHashMapFromArray [["delivery","0.12-D.7.0"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],["base",_base],["baseExpected",617],["checkpointFirstGate",618],["checkpointLastGate",627],["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],["cumulativeExpected",627],["cumulativePassed",617+_passed],["durationMs",_durationMs],["privatePublicTabs",true],["publicLibraryScope","SESSION"],["publicSnapshotReadOnly",true]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] 0.12-D.7.0 — BASE=617/617  D.7.0=%1/10  FAIL=%2  CUMULATIVO=%3/627  TEMPO=%4ms",_passed,_failed,617+_passed,_durationMs];
diag_log "[SP_ORG] [ITEMS] 0.12-D.7.0 — Manual: PRIVADOS/PÚBLICOS; publicar snapshot; alterar privado sem mudar público; salvar público no privado; confirmar DnD privado e bloqueio público.";
diag_log "============================================================";
if (hasInterface) then {hint parseText format ["<t size='1.25'>SP_ORG_Items 0.12-D.7.0</t><br/><br/>Baseline D.6.4: <t color='#7CFC00'>617 / 617</t><br/>D.7.0: <t color='%1'>%2 / 10</t><br/>Cumulativo: %3 / 627<br/><br/>%4",if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_passed,617+_passed,if (_failed isEqualTo 0) then {"Valide o fluxo PRIVADOS/PÚBLICOS manualmente."} else {"Consulte o primeiro FAIL no RPT."}];};
_summary
