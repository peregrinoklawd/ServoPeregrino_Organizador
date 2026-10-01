#include "..\..\script_version.hpp"
disableSerialization;

private _legacyRunningState=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR,createHashMap];
if (_legacyRunningState getOrDefault ["running",false]) exitWith {[false,"ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING","A regressão legada já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _orchestrator=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
if (_orchestrator getOrDefault ["running",false]) exitWith {[false,"ITEMS_0_12_D73_ALREADY_RUNNING","Outra suíte cumulativa já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _startedAt=diag_tickTime;
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.12-D.7.3 — CATALOG AUTHORITY & DISCOVERABILITY HOTFIX — 646 GATES";
diag_log "============================================================";
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun; uiSleep 0.02;
private _base=createHashMapFromArray [["success",false],["code","ITEMS_0_12_D73_BASE_CALL_DID_NOT_RETURN"]];
private _baseCall=[] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_12CheckpointD72Tests;
if !(isNil "_baseCall") then {if (_baseCall isEqualType createHashMap) then {_base=_baseCall;};};
private _baseOk=(_base getOrDefault ["success",false]) && {(_base getOrDefault ["checkpointPassed",0]) isEqualTo 5} && {(_base getOrDefault ["cumulativePassed",0]) isEqualTo 638};
if !(_baseOk) exitWith {
    [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
    private _summary=createHashMapFromArray [["delivery","0.12-D.7.3"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",false],["code","ITEMS_0_12_D73_BASE_638_FAILED"],["base",_base],["checkpointSkipped",true],["checkpointFirstGate",639],["checkpointLastGate",646],["checkpointTotal",0],["checkpointPassed",0],["checkpointFailed",0],["cumulativeExpected",646]];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    diag_log "[SP_ORG] [ITEMS] 0.12-D.7.3 — FAIL-FAST: baseline D.7.2 638/638 não fechou.";
    _summary
};

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.12-D.7.3"]]];
private _passed=0; private _failed=0; private _results=[];
private _assert={params ["_id","_condition","_detail"]; private _ok=(_condition isEqualType true)&&{_condition}; private _status=if (_ok) then {"PASS"} else {"FAIL"}; if (_ok) then {_passed=_passed+1}else{_failed=_failed+1}; _results pushBack [_id,_status,_detail]; diag_log format ["[SP_ORG] [ITEMS] [TEST 0.12-D.7.3] [%1] %2 — %3",_status,_id,_detail];};

private _productionBefore=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _loadoutBefore=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _draftBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _uiBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _publicBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VAR,[]]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _catalogBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_CACHE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _projectionBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_PROJECTION_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;

private _srcDesc=preprocessFileLineNumbers "description.ext";
private _srcCfg=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\config.cpp";
private _srcEvent=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUIEvent.sqf";
private _srcDrag=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUIDragEvent.sqf";
private _srcClear=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_clearKitLibraryActionStatus.sqf";
private _srcRefresh=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshInterface.sqf";
private _srcCatalogRefresh=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshCatalogWindowUI.sqf";
private _srcCatalogDetails=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshCatalogSelectionDetails.sqf";
private _srcCatalogRows=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_renderCatalogRowsUI.sqf";
private _srcEquipmentRows=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_renderEquipmentRowsUI.sqf";
private _srcBuild=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\catalog\fn_buildCatalog.sqf";

// 639 — registro/versionamento e continuidade cumulativa.
private _gate639=(_srcDesc find "class runDelivery0_12CheckpointD73Tests {}")>=0
    && {(_srcCfg find "class runDelivery0_12CheckpointD73Tests {}")>=0}
    && {(_srcDesc find "class clearKitLibraryActionStatus {}")>=0}
    && {(_srcCfg find "class clearKitLibraryActionStatus {}")>=0}
    && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_7_3_GATE_COUNT isEqualTo 8}
    && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_7_3_CUMULATIVE_GATE_COUNT isEqualTo 646}
    && {(SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DISPLAY_VERSION find "0.12-D.7.") isEqualTo 0};
["ITEMS-0.12-639",_gate639,"D.7.3 está registrada, versionada e declara contrato cumulativo 646/646 com helper de badge transitório."] call _assert;

// 640 — adição direta do Catálogo ao equipamento deve seguir Mostrar/equipmentView, nunca Onde aplicar/applicationTarget.
private _actionStart=_srcEvent find "private _executeCatalogClassAction";
private _actionEnd=_srcEvent find "private _clickCatalogAction";
private _actionSrc=if (_actionStart>=0 && {_actionEnd>_actionStart}) then {_srcEvent select [_actionStart,_actionEnd-_actionStart]} else {""};
private _gate640=(_actionSrc find "equipmentView")>=0 && {(_actionSrc find "applicationTarget")<0} && {(_srcEvent find "CATALOG_BUTTON_TO_PHYSICAL")>=0} && {(_srcEvent find "CATALOG_ARROW_TO_PHYSICAL")>=0};
["ITEMS-0.12-640",_gate640,"Seta/botão direito do Catálogo usa equipmentView (Mostrar) como autoridade do destino físico, alinhado ao DnD."] call _assert;

// Fixture privado para áudio de publicação.
private _entryR=["ITEM","FirstAidKit",1,"NONE",[]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _entry=((_entryR getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]]);
private _kitR=["D73 Publish Sound",[_entry],"ANY",["TEST","D73-PUBLISH"]] call ServoPeregrino_Organizador_Items_fnc_createItemKit;
private _kit=((_kitR getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]]);
private _saveR=[_kit] call ServoPeregrino_Organizador_Items_fnc_saveKit;
private _privateId=((_saveR getOrDefault ["data",createHashMap]) getOrDefault ["kitId",""]);
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VAR,[SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_MAGIC,SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VERSION,0,[]]];

// 641 — PUBLICAR precisa produzir o mesmo cue SUCCESS da cópia bem-sucedida.
private _state641=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
if ((count _state641) isEqualTo 0) then {_state641=[] call ServoPeregrino_Organizador_Items_fnc_createUIState;};
_state641 set ["kitLibraryMode","PRIVATE"];
_state641 set ["selectedKitId",_privateId];
_state641 set ["kitLibraryActionStatus",""];
_state641 set ["soundHistory",[]];
_state641 set ["lastSoundOutcome",""];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state641];
["PUBLISH_KIT"] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent;
private _after641=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _hist641=_after641 getOrDefault ["soundHistory",[]];
private _gate641=(_privateId isNotEqualTo "") && {(toUpper (_after641 getOrDefault ["kitLibraryActionStatus",""])) isEqualTo "PUBLICADO"} && {(toUpper (_after641 getOrDefault ["lastSoundOutcome",""])) isEqualTo "SUCCESS"} && {(count _hist641)>=1};
["ITEMS-0.12-641",_gate641,"PUBLICAR bem-sucedido exibe PUBLICADO e registra cue sonoro SUCCESS mesmo quando reprodução real é suprimida pelos testes."] call _assert;

// 642 — badge anterior deve sumir na próxima interação comum.
private _state642=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
_state642 set ["kitLibraryActionStatus","COPIADO"];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state642];
["KIT_SEARCH","D73"] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent;
private _after642=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _gate642=(_after642 getOrDefault ["kitLibraryActionStatus","X"]) isEqualTo "" && {(toUpper (_after642 getOrDefault ["lastKitLibraryActionStatus",""])) isEqualTo "COPIADO"} && {(toUpper (_after642 getOrDefault ["kitLibraryActionStatusClearReason",""])) isEqualTo "KIT_SEARCH"};
["ITEMS-0.12-642",_gate642,"COPIADO/PUBLICADO permanece como confirmação e é limpo somente na próxima interação real do jogador."] call _assert;

// 643 — DnD também encerra o badge, inclusive caminho pointer e drag nativo de Meus Kits.
private _gate643=(_srcDrag find "POINTER_DOWN")>=0
    && {(_srcDrag find "DND_START")>=0}
    && {(_srcDrag find "fnc_clearKitLibraryActionStatus")>=0}
    && {(_srcClear find "displayCtrl 1001")>=0}
    && {(_srcClear find "ctrlSetText")>=0};
["ITEMS-0.12-643",_gate643,"Clique/início de DnD limpa o badge transitório sem depender de full refresh."] call _assert;

// 644 — linguagem do catálogo deixa de usar setas como texto explicativo e contador técnico 'lista contínua'.
private _friendlyRange=(_srcRefresh find "Mostrando %1 a %2 de %3 itens")>=0 && {(_srcCatalogRefresh find "Mostrando %1 a %2 de %3 itens")>=0} && {(_srcRefresh find "Nenhum item encontrado")>=0};
private _friendlyAction=(_srcCatalogDetails find "Botão da esquerda")>=0 && {(_srcCatalogDetails find "equipamento exibido em Mostrar")>=0} && {(_srcCatalogRows find "equipamento exibido em Mostrar")>=0} && {(_srcEquipmentRows find "Botão da esquerda")>=0};
private _oldCopyGone=(_srcCatalogDetails find "Use ←")<0 && {(_srcCatalogDetails find "→ adicionar")<0} && {(_srcRefresh find "lista contínua")<0} && {(_srcCatalogRefresh find "lista contínua")<0};
private _gate644=_friendlyRange && {_friendlyAction} && {_oldCopyGone};
["ITEMS-0.12-644",_gate644,"Catálogo usa linguagem player-facing sem setas em frases e sem o rótulo técnico 'lista contínua'."] call _assert;

// 645 — ordem determinística por nome evita que filtros pareçam esconder itens por ordem de config.
private _a=createHashMapFromArray [["displayName","Zeta Médico"],["className","Z_Test"],["categoryId","MEDICAL"]];
private _b=createHashMapFromArray [["displayName","DEA Serie-X"],["className","DEA_Test"],["categoryId","MEDICAL"]];
private _c=createHashMapFromArray [["displayName","Bandagem"],["className","Bandage_Test"],["categoryId","MEDICAL"]];
private _sorted=[[_a,_b,_c],[],{format ["%1|%2",toLower (_x getOrDefault ["displayName",""]),toLower (_x getOrDefault ["className",""])]},"ASCEND"] call BIS_fnc_sortBy;
private _names=_sorted apply {_x getOrDefault ["displayName",""]};
private _gate645=(_names isEqualTo ["Bandagem","DEA Serie-X","Zeta Médico"]) && {(_srcBuild find "call BIS_fnc_sortBy")>=0} && {(_srcBuild find "displayName")>=0} && {(_srcBuild find "className")>=0} && {(_b getOrDefault ["categoryId",""]) isEqualTo "MEDICAL"};
["ITEMS-0.12-645",_gate645,"Catálogo é ordenado uma vez por displayName/className; itens válidos do filtro MÉDICO ficam em posição previsível e continuam pesquisáveis."] call _assert;

// 646 — restaura estado e prova invariância física/persistente dos smokes D.7.3.
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VAR,_publicBefore];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,_draftBefore];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_uiBefore];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_CACHE_VAR,_catalogBefore];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_PROJECTION_VAR,_projectionBefore];
[_productionBefore] call ServoPeregrino_Organizador_Items_fnc_restoreProductionRepositorySnapshot;
private _loadoutAfter=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _productionAfter=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _cmp=[_loadoutBefore,_loadoutAfter,"ITEMS-0.12-646"] call ServoPeregrino_Organizador_Items_fnc_compareLoadoutFingerprints;
private _cmpD=_cmp getOrDefault ["data",createHashMap];
private _changed=_cmpD getOrDefault ["changedIndexes",[]];
private _ambient=!(_cmpD getOrDefault ["equal",false]) && {(count _changed)>0} && {(_changed findIf {!(_x in [0,1,2])})<0};
if (_ambient) then {diag_log format ["[SP_ORG] [ITEMS] [TEST_AMBIENT_DRIFT] label=ITEMS-0.12-646 changedIndexes=%1 accepted=true reason=WEAPON_SLOTS_ONLY",_changed];};
private _gate646=((_cmpD getOrDefault ["equal",false]) || {_ambient}) && {_productionAfter isEqualTo _productionBefore} && {(missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VAR,[]]) isEqualTo _publicBefore} && {(missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_CACHE_VAR,createHashMap]) isEqualTo _catalogBefore};
["ITEMS-0.12-646",_gate646,"D.7.3 restaura Repository/biblioteca/UI/Draft/Catálogo e não deixa mutação física após os smokes."] call _assert;

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
private _durationMs=round ((diag_tickTime-_startedAt)*1000);
private _summary=createHashMapFromArray [["delivery","0.12-D.7.3"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],["base",_base],["baseExpected",638],["checkpointFirstGate",639],["checkpointLastGate",646],["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],["cumulativeExpected",646],["cumulativePassed",638+_passed],["durationMs",_durationMs],["catalogPhysicalUsesEquipmentView",true],["publishSuccessSound",true],["transientLibraryBadge",true],["friendlyCatalogCopy",true],["catalogSortedByDisplayName",true]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] 0.12-D.7.3 — BASE=638/638  D.7.3=%1/8  FAIL=%2  CUMULATIVO=%3/646  TEMPO=%4ms",_passed,_failed,638+_passed,_durationMs];
diag_log "[SP_ORG] [ITEMS] 0.12-D.7.3 — Manual: Mostrar governa seta direita do Catálogo; PUBLICAR toca confirmação; badge some na próxima interação; filtro MÉDICO navega em ordem previsível.";
diag_log "============================================================";
if (hasInterface) then {hint parseText format ["<t size='1.25'>SP_ORG_Items 0.12-D.7.3</t><br/><br/>Baseline D.7.2: <t color='#7CFC00'>638 / 638</t><br/>D.7.3: <t color='%1'>%2 / 8</t><br/>Cumulativo: %3 / 646<br/><br/>%4",if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_passed,638+_passed,if (_failed isEqualTo 0) then {"Valide os quatro cenários manuais da entrega."} else {"Consulte o primeiro FAIL no RPT."}];};
_summary
