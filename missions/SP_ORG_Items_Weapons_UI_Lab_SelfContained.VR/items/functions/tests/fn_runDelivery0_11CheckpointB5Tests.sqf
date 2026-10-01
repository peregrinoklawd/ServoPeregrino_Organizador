#include "..\..\script_version.hpp"
disableSerialization;

private _legacyRunningState=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR,createHashMap];
if (_legacyRunningState getOrDefault ["running",false]) exitWith {[false,"ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING","A regressão legada já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _orchestrator=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
if (_orchestrator getOrDefault ["running",false]) exitWith {[false,"ITEMS_0_11_CP_B5_ALREADY_RUNNING","Outra suíte cumulativa já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};

private _startedAt=diag_tickTime;
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.11 CP-B.5 — FOCUSED DRAFT REFRESH + PERF TRACE + SOUND RESTORE — 428 GATES";
diag_log "============================================================";

// A baseline histórica ainda contém testes que exercitam storage. Protegemos as chaves reais antes de executá-la.
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
    private _summary=createHashMapFromArray [["delivery","0.11 CP-B.5"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",false],["code","ITEMS_0_11_CP_B5_BASE_414_FAILED"],["base",_base],["checkpointSkipped",true],["checkpointFirstGate",415],["checkpointLastGate",428],["checkpointTotal",0],["checkpointPassed",0],["checkpointFailed",0],["cumulativeExpected",428],["productionRestored",_productionRestoreExact]];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    diag_log "[SP_ORG] [ITEMS] 0.11 CP-B.5 — FAIL-FAST: baseline aprovada 414/414 não fechou; produção foi restaurada antes de sair.";
    if (hasInterface) then {hint "SP_ORG_Items 0.11 CP-B.5 reprovado na baseline 414/414. Storage de produção restaurado; consulte o primeiro FAIL no RPT.";};
    _summary
};

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.11 CP-B.5"]]];
private _passed=0;
private _failed=0;
private _results=[];
private _assert={
    params ["_id","_condition","_detail"];
    private _ok=(_condition isEqualType true) && {_condition};
    private _status=if (_ok) then {"PASS"} else {"FAIL"};
    if (_ok) then {_passed=_passed+1;} else {_failed=_failed+1;};
    _results pushBack [_id,_status,_detail];
    diag_log format ["[SP_ORG] [ITEMS] [TEST 0.11 CP-B.5] [%1] %2 — %3",_status,_id,_detail];
};
private _oldUIState=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _oldDraftState=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _resetUI={missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]; [] call ServoPeregrino_Organizador_Items_fnc_createUIState;};

// 415 — som volta a nascer habilitado; performance hold não faz mais parte do runtime da candidata.
call _resetUI;
private _u415=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _gate415=(_u415 getOrDefault ["soundEnabled",false]) && {!(_u415 getOrDefault ["soundPerformanceHold",true])} && {(SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_AUDIO_PERFORMANCE_HOLD isEqualTo 0)};
["ITEMS-0.11-415",_gate415,"Áudio de movimento volta a nascer ATIVO e o performance hold fica desativado na CP-B.5."] call _assert;

// 416 — corrige o falso negativo da CP-B.4: valida comportamento/runtime, não o nome de macro já expandido pelo preprocessador.
private _p416=["ADD"] call ServoPeregrino_Organizador_Items_fnc_getUIMovementSoundProfile;
private _c416=_p416 getOrDefault ["soundClass",""];
private _scope416=_p416 getOrDefault ["classScope","MAIN"];
private _avail416=if (_scope416 isEqualTo "MAIN") then {isClass (configFile >> "CfgSounds" >> _c416)} else {isClass (missionConfigFile >> "CfgSounds" >> _c416)};
private _m416=["ADD"] call ServoPeregrino_Organizador_Items_fnc_playUIMovementSound;
private _gate416=_avail416 && {_p416 getOrDefault ["providerCached",false]} && {_m416 getOrDefault ["suppressedByTests",false]} && {!(_m416 getOrDefault ["attempted",true])} && {!(_m416 getOrDefault ["played",true])} && {!(_m416 getOrDefault ["suppressedByPerformanceHold",false])};
["ITEMS-0.11-416",_gate416,"Provider sonoro é resolvido/cacheado uma vez por missão; suíte suprime playback real sem depender de procurar nome de macro após preprocessFileLineNumbers."] call _assert;

// 417 — refresh do Draft é focal e não chama os serviços pesados que causavam o micro-engasgo.
private _srcFocused417=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshDraftMutationUI.sqf";
private _heavy417=["fnc_filterCatalog","fnc_getCatalog","fnc_capturePlayerContainer","fnc_listKits","fnc_getUIPhysicalReadiness","fnc_saveStorage","saveProfileNamespace","fnc_refreshInterface"];
private _gate417=(_srcFocused417 find "DRAFT_FOCUSED" >= 0) && {(_srcFocused417 find "fnc_getDraftState" >= 0)} && {(_srcFocused417 find "UI_PERF" >= 0)} && {({_srcFocused417 find _x >= 0} count _heavy417) isEqualTo 0};
["ITEMS-0.11-417",_gate417,"DRAFT_FOCUSED atualiza somente Draft/footer e não percorre Catálogo, Repository, readiness nem recaptura Equipment."] call _assert;

// 418 — setas Catalog/Equipment e buscas/edições do Draft deixam de pedir refresh global.
private _srcEvent418=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUIEvent.sqf";
private _gate418=(_srcEvent418 find "CATALOG_ARROW_TO_DRAFT" >= 0) && {(_srcEvent418 find "EQUIPMENT_ARROW_TO_DRAFT" >= 0)} && {(_srcEvent418 find "DRAFT_SEARCH" >= 0)} && {(_srcEvent418 find "fnc_refreshDraftMutationUI" >= 0)};
["ITEMS-0.11-418",_gate418,"Setas Catalog/Equipment → Draft e mutações locais do Draft convergem para refresh focal em vez de reconstruir os quatro painéis."] call _assert;

// 419 — DnD, +, -, Delete e edição de quantidade também usam o mesmo caminho focal.
private _srcDnD419=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUIDragEvent.sqf";
private _srcRefresh419=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshInterface.sqf";
private _srcQty419=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_commitDraftQuantityFromControl.sqf";
private _srcKey419=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUIKeyDown.sqf";
private _gate419=(_srcDnD419 find "DND_TO_DRAFT" >= 0) && {(_srcDnD419 find "fnc_refreshDraftMutationUI" >= 0)} && {(_srcRefresh419 find "ROW_MINUS" >= 0)} && {(_srcRefresh419 find "ROW_PLUS" >= 0)} && {(_srcRefresh419 find "ROW_DELETE" >= 0)} && {(_srcQty419 find "QUANTITY_COMMIT" >= 0)} && {(_srcKey419 find "KEY_DELETE_DRAFT" >= 0)};
["ITEMS-0.11-419",_gate419,"DnD → Draft, +/−/Delete e quantidade/0 usam DRAFT_FOCUSED; um gesto lógico não solicita full refresh."] call _assert;

// 420 — o caminho normal de transferência lógica não persiste ProfileNamespace/storage.
private _srcExec420=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_executeUITransferCommand.sqf";
private _srcDraft420=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUITransferToDraft.sqf";
private _forbidden420=["saveProfileNamespace","fnc_saveStorage","fnc_saveKit","fnc_saveDraft","fnc_saveDraftAsNew"];
private _combined420=_srcExec420+_srcDraft420;
private _gate420=({_combined420 find _x >= 0} count _forbidden420) isEqualTo 0;
["ITEMS-0.11-420",_gate420,"Catalog/Equipment/Kit → Draft permanece 100% em memória; save/load persistente só ocorre em comandos explícitos de persistência."] call _assert;

// 421 — prova runtime de que uma mutação lógica do Draft não altera as chaves reais de produção.
private _prod421a=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMap];
["CP-B.5 Perf Draft","ANY",["TEST","CPB5_PERF"],[]] call ServoPeregrino_Organizador_Items_fnc_createNewDraft;
private _add421=["FirstAidKit",1] call ServoPeregrino_Organizador_Items_fnc_addCatalogItemToDraft;
private _prod421b=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _gate421=(_add421 getOrDefault ["success",false]) && {_prod421a isEqualTo _prod421b};
["ITEMS-0.11-421",_gate421,"Adicionar item ao Draft em runtime não grava nem modifica o storage real do jogador."] call _assert;

// 422..424 — smoke real da UI: um refresh focal incrementa somente seu contador e não toca Catalog/Equipment.
private _existing422=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
if (!isNull _existing422) then {closeDialog 0; uiSleep 0.03;};
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_createUIState;
private _dialog422=createDialog "SP_ORG_Items_Dialog";
uiSleep 0.08;
private _display422=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
private _state422a=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _full422a=_state422a getOrDefault ["fullRefreshCount",0];
private _draft422a=_state422a getOrDefault ["draftFocusedRefreshCount",0];
private _cat422=if (isNull _display422) then {controlNull} else {_display422 displayCtrl 3120};
private _eq422=if (isNull _display422) then {controlNull} else {_display422 displayCtrl 4120};
private _catSize422=if (isNull _cat422) then {-1} else {lbSize _cat422};
private _catSel422=if (isNull _cat422) then {-1} else {lbCurSel _cat422};
private _catData422=if (!isNull _cat422 && {_catSel422>=0}) then {_cat422 lbData _catSel422} else {""};
private _catScroll422=if (isNull _cat422) then {[]} else {ctrlScrollValues _cat422};
private _eqSize422=if (isNull _eq422) then {-1} else {lbSize _eq422};
private _eqSel422=if (isNull _eq422) then {-1} else {lbCurSel _eq422};
private _eqData422=if (!isNull _eq422 && {_eqSel422>=0}) then {_eq422 lbData _eqSel422} else {""};
private _eqScroll422=if (isNull _eq422) then {[]} else {ctrlScrollValues _eq422};
private _focused422=if (_dialog422 && {!isNull _display422}) then {["AUTOMATIC_SMOKE"] call ServoPeregrino_Organizador_Items_fnc_refreshDraftMutationUI} else {false};
private _state422b=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _gate422=_focused422 && {(_state422b getOrDefault ["fullRefreshCount",-1]) isEqualTo _full422a} && {(_state422b getOrDefault ["draftFocusedRefreshCount",-1]) isEqualTo (_draft422a+1)} && {(_state422b getOrDefault ["lastRefreshMode",""]) isEqualTo "DRAFT_FOCUSED"};
["ITEMS-0.11-422",_gate422,"Smoke UI: DRAFT_FOCUSED incrementa somente o contador focal; não dispara um segundo refresh FULL."] call _assert;

private _catSize423=if (isNull _cat422) then {-2} else {lbSize _cat422};
private _catSel423=if (isNull _cat422) then {-2} else {lbCurSel _cat422};
private _catData423=if (!isNull _cat422 && {_catSel423>=0}) then {_cat422 lbData _catSel423} else {""};
private _catScroll423=if (isNull _cat422) then {[]} else {ctrlScrollValues _cat422};
private _gate423=(_catSize422>=0) && {_catSize423 isEqualTo _catSize422} && {_catSel423 isEqualTo _catSel422} && {_catData423 isEqualTo _catData422} && {_catScroll423 isEqualTo _catScroll422};
["ITEMS-0.11-423",_gate423,"Refresh focal preserva exatamente tamanho, seleção/dado e scroll do Catálogo; nenhuma lbClear/reconstrução ocorre."] call _assert;

private _eqSize424=if (isNull _eq422) then {-2} else {lbSize _eq422};
private _eqSel424=if (isNull _eq422) then {-2} else {lbCurSel _eq422};
private _eqData424=if (!isNull _eq422 && {_eqSel424>=0}) then {_eq422 lbData _eqSel424} else {""};
private _eqScroll424=if (isNull _eq422) then {[]} else {ctrlScrollValues _eq422};
private _gate424=(_eqSize422>=0) && {_eqSize424 isEqualTo _eqSize422} && {_eqSel424 isEqualTo _eqSel422} && {_eqData424 isEqualTo _eqData422} && {_eqScroll424 isEqualTo _eqScroll422};
["ITEMS-0.11-424",_gate424,"Refresh focal do Draft preserva exatamente a lista/seleção/scroll de Equipment e não recaptura o container."] call _assert;

// 425 — FULL continua instrumentado, mas a arquitetura moderna usa janela virtual do Catálogo.
// O ID histórico permanece o mesmo; o requisito agora valida a intenção original (telemetria + custo explícito)
// sem obrigar a implementação antiga que filtrava/copiava todo o CONFIG_ALL.
private _srcFull425=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshInterface.sqf";
private _srcVM425=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_buildUIViewModel.sqf";
private _srcWindow425=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_getUICatalogWindow.sqf";
private _gate425=(_srcFull425 find "mode=FULL" >= 0) && {(_srcFull425 find "vmMs=" >= 0)} && {(_srcFull425 find "renderMs=" >= 0)} && {(_srcVM425 find "fnc_getUICatalogWindow" >= 0)} && {(_srcVM425 find "fnc_filterCatalog" < 0)} && {(_srcVM425 find "fnc_capturePlayerContainer" >= 0)} && {(_srcWindow425 find "fnc_copyCatalogItem" >= 0)};
["ITEMS-0.11-425",_gate425,"FULL registra total/vm/render, recaptura Equipment quando necessário e usa somente a janela virtual do Catálogo; não regride para filterCatalog sobre o CONFIG_ALL inteiro."] call _assert;

// 426 — operações físicas também ganham medição separada de transaction trace e recaptura focal.
private _srcPhysical426=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshPhysicalMutationUI.sqf";
private _gate426=(_srcPhysical426 find "PHYSICAL_FOCUSED" >= 0) && {(_srcPhysical426 find "captureMs=" >= 0)} && {(_srcPhysical426 find "fnc_capturePlayerContainer" >= 0)};
["ITEMS-0.11-426",_gate426,"Refresh físico registra UI_PERF PHYSICAL_FOCUSED/captureMs para separar custo da recaptura do durationMs da transação PHYSICAL_FLOW."] call _assert;

// 427 — Storage Guard/classificador corrigido permanecem protegendo os dados reais e scanner é read-only.
private _fakeEntryR427=["ITEM","FirstAidKit",1,"NONE",[]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _fakeEntry427=(_fakeEntryR427 getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]];
private _fakeTestR427=["Kit CP-C",[_fakeEntry427],"ANY",["MANUAL","CPC_TEST"],""] call ServoPeregrino_Organizador_Items_fnc_createItemKit;
private _ct427=[((_fakeTestR427 getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]])] call ServoPeregrino_Organizador_Items_fnc_classifyLeakedTestKit;
private _prod427a=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _scan427=[] call ServoPeregrino_Organizador_Items_fnc_findLeakedTestKits;
private _prod427b=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _gate427=(_ct427 isEqualType createHashMap) && {_ct427 getOrDefault ["isTestKit",false]} && {(_ct427 getOrDefault ["confidence",""]) isEqualTo "HIGH"} && {_scan427 isEqualType createHashMap} && {_scan427 getOrDefault ["success",false]} && {_prod427a isEqualTo _prod427b} && {_productionRestoreExact};
["ITEMS-0.11-427",_gate427,"Storage Guard permanece íntegro: classificador HIGH funciona, scanner é read-only e produção foi restaurada exatamente após baseline."] call _assert;

// 428 — um gesto lógico continua gerando um único cue; refresh focal puro não adiciona som.
call _resetUI;
private _hist428a=count ((missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]) getOrDefault ["movementSoundHistory",[]]);
private _logical428=[true,"ITEMS_UI_TRANSFER_DRAFT_OK","Teste lógico CP-B.5",createHashMapFromArray [["quantity",1]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult;
[_logical428,"ADD",true] call ServoPeregrino_Organizador_Items_fnc_presentLogicalMutationResult;
private _hist428b=count ((missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]) getOrDefault ["movementSoundHistory",[]]);
if (_dialog422 && {!isNull (findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD)}) then {["SOUND_SILENCE_CHECK"] call ServoPeregrino_Organizador_Items_fnc_refreshDraftMutationUI;};
private _hist428c=count ((missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]) getOrDefault ["movementSoundHistory",[]]);
private _gate428=(_hist428b isEqualTo (_hist428a+1)) && {_hist428c isEqualTo _hist428b};
["ITEMS-0.11-428",_gate428,"Um gesto lógico gera exatamente um cue de movimento; refresh DRAFT_FOCUSED puro continua silencioso."] call _assert;

// Cleanup hermético.
private _displayEnd=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
if (!isNull _displayEnd) then {closeDialog 0; uiSleep 0.03;};
[_productionBefore] call ServoPeregrino_Organizador_Items_fnc_restoreProductionRepositorySnapshot;
private _productionFinal=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _productionFinalExact=_productionBefore isEqualTo _productionFinal;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,_oldDraftState];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_oldUIState];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;

private _durationMs=round ((diag_tickTime-_startedAt)*1000);
private _summary=createHashMapFromArray [["delivery","0.11 CP-B.5"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],["base",_base],["baseExpected",414],["checkpointFirstGate",415],["checkpointLastGate",428],["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],["cumulativeExpected",428],["cumulativePassed",414+_passed],["durationMs",_durationMs],["productionRestored",_productionRestoreExact && _productionFinalExact],["transientProductionChanged",_transientProductionChanged],["audioPerformanceHold",false],["focusedDraftRefresh",true]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] 0.11 CP-B.5 — BASE=414/414  CP-B.5=%1/14  FAIL=%2  CUMULATIVO=%3/428  TEMPO=%4ms",_passed,_failed,414+_passed,_durationMs];
diag_log format ["[SP_ORG] [ITEMS] 0.11 CP-B.5 — AUDIO=ON focusedDraft=true storageGuard restoredExact=%1 finalExact=%2 transientChanged=%3",_productionRestoreExact,_productionFinalExact,_transientProductionChanged];
diag_log "[SP_ORG] [ITEMS] 0.11 CP-B.5 — Teste manual: compare [UI_PERF] DRAFT_FOCUSED/FULL/PHYSICAL_FOCUSED e [PHYSICAL_FLOW] durationMs durante movimentações rápidas.";
diag_log "============================================================";
if (hasInterface) then {hint parseText format ["<t size='1.25'>SP_ORG_Items 0.11 CP-B.5</t><br/><br/>Baseline: <t color='#7CFC00'>414 / 414</t><br/>CP-B.5: <t color='%1'>%2 / 14</t><br/>Cumulativo: %3 / 428<br/>Áudio: ATIVO<br/>DRAFT_FOCUSED: ativo<br/>Storage restaurado: %4<br/><br/>%5",if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_passed,414+_passed,(_productionRestoreExact && _productionFinalExact),if (_failed isEqualTo 0) then {"428/428 concluído. Teste movimentos rápidos e envie o RPT com UI_PERF."} else {"Consulte o primeiro FAIL no RPT."}];};
_summary
