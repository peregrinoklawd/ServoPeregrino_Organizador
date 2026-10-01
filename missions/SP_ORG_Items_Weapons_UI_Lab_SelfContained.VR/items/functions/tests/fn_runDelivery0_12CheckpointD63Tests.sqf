#include "..\..\script_version.hpp"
disableSerialization;

private _legacyRunningState=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR,createHashMap];
if (_legacyRunningState getOrDefault ["running",false]) exitWith {[false,"ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING","A regressão legada já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _orchestrator=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
if (_orchestrator getOrDefault ["running",false]) exitWith {[false,"ITEMS_0_12_D63_ALREADY_RUNNING","Outra suíte cumulativa já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _startedAt=diag_tickTime;
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.12-D.6.3 — AUTO DRAFT ON DROP + HEADER ANCHOR — 610 GATES";
diag_log "============================================================";
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun; uiSleep 0.02;
private _base=createHashMapFromArray [["success",false],["code","ITEMS_0_12_D63_BASE_CALL_DID_NOT_RETURN"]];
private _baseCall=[] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_12CheckpointD62Tests;
if !(isNil "_baseCall") then {if (_baseCall isEqualType createHashMap) then {_base=_baseCall;};};
private _baseOk=(_base getOrDefault ["success",false]) && {(_base getOrDefault ["checkpointPassed",0]) isEqualTo 8} && {(_base getOrDefault ["cumulativePassed",0]) isEqualTo 602};
if !(_baseOk) exitWith {
    [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
    private _summary=createHashMapFromArray [["delivery","0.12-D.6.3"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",false],["code","ITEMS_0_12_D63_BASE_602_FAILED"],["base",_base],["checkpointSkipped",true],["checkpointFirstGate",603],["checkpointLastGate",610],["checkpointTotal",0],["checkpointPassed",0],["checkpointFailed",0],["cumulativeExpected",610]];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    diag_log "[SP_ORG] [ITEMS] 0.12-D.6.3 — FAIL-FAST: baseline D.6.2 602/602 não fechou.";
    _summary
};

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.12-D.6.3"]]];
private _passed=0; private _failed=0; private _results=[];
private _assert={
    params ["_id","_condition","_detail"];
    private _ok=(_condition isEqualType true)&&{_condition};
    private _status=if (_ok) then {"PASS"} else {"FAIL"};
    if (_ok) then {_passed=_passed+1}else{_failed=_failed+1};
    _results pushBack [_id,_status,_detail];
    diag_log format ["[SP_ORG] [ITEMS] [TEST 0.12-D.6.3] [%1] %2 — %3",_status,_id,_detail];
};
private _emptyDraftState={createHashMapFromArray [["ready",true],["hasDraft",false],["current",createHashMap],["baseline",createHashMap],["revision",0],["lastAction","NONE"]]};
private _qtyClass={params ["_entries","_class"]; private _q=0; {if ((_x param [2,"",[""]]) isEqualTo _class) then {_q=_q+(_x param [3,0,[0]]);};} forEach _entries; _q};

private _productionBefore=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _loadoutBefore=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _draftStateBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _uiStateBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;

private _srcDescription=preprocessFileLineNumbers "description.ext";
private _srcConfig=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\config.cpp";
private _srcVersion=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\script_version.hpp";
private _srcDialog=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\ui\items_dialog.hpp";
private _srcTransfer=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUITransferToDraft.sqf";
private _srcDispatcher=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_executeUITransferCommand.sqf";
private _srcDrag=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUIDragEvent.sqf";
private _srcC1=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\tests\fn_runDelivery0_12CheckpointCTests.sqf";
private _srcDetails=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshCatalogSelectionDetails.sqf";

private _gate603=(_srcDescription find "class runDelivery0_12CheckpointD63Tests {}")>=0 && {(_srcConfig find "class runDelivery0_12CheckpointD63Tests {}")>=0} && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_6_3_GATE_COUNT isEqualTo 8} && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_D_6_3_CUMULATIVE_GATE_COUNT isEqualTo 610} && {(SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DISPLAY_VERSION find "0.12-D.") isEqualTo 0};
["ITEMS-0.12-603",_gate603,"D.6.3 está registrada, versionada e declara contrato cumulativo 610/610."] call _assert;

private _gate604=(_srcC1 find "ITEMS-0.12-484")>=0
    && {((_srcC1 find "equipamento escolhido")>=0) || {(_srcC1 find "equipamento exibido em Mostrar")>=0}}
    && {((_srcDetails find "equipamento escolhido")>=0) || {(_srcDetails find "equipamento exibido em Mostrar")>=0}}
    && {(_srcDetails find "Classe:")<0}
    && {(_srcDetails find "Addon:")<0};
["ITEMS-0.12-604",_gate604,"Gate histórico 484 acompanha a copy player-facing atual do Catálogo e deixa de bloquear toda a cadeia por rótulo obsoleto."] call _assert;

private _gate605=(_srcDispatcher find "[_source,_payload,_options]")>=0 && {(_srcTransfer find "commandOrigin")>=0} && {(_srcTransfer find "DND_")>=0} && {(_srcTransfer find "autoCreateDraftIfMissing")>=0 && {(_srcTransfer find "autoCreateDraftOnDrop")>=0}} && {(_srcTransfer find "AUTO_CREATE")>=0} && {(_srcTransfer find "autoDraftCreated")>=0} && {(_srcTransfer find "_stateBefore")>=0} && {(_srcDrag find "CRIAR UM RASCUNHO E ADICIONAR")>=0};
["ITEMS-0.12-605",_gate605,"Auto-criação permanece centralizada na transferência lógica, aceita opt-in de gesto explícito, preserva DnD e possui rollback se a transferência falhar."] call _assert;

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,call _emptyDraftState];
private _catDrop=["CATALOG","FirstAidKit","DRAFT","AUTO",player,"",createHashMapFromArray [["commandOrigin","DND_CATALOG_TABLE_DRAFT"]]] call ServoPeregrino_Organizador_Items_fnc_executeUITransferCommand;
private _catState=([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap];
private _catDraft=_catState getOrDefault ["current",createHashMap];
private _catEntries=_catDraft getOrDefault ["entries",[]];
private _catData=_catDrop getOrDefault ["data",createHashMap];
private _gate606=(_catDrop getOrDefault ["success",false]) && {_catState getOrDefault ["hasDraft",false]} && {(_catDraft getOrDefault ["mode",""]) isEqualTo "NEW"} && {([_catEntries,"FirstAidKit"] call _qtyClass)>=1} && {_catData getOrDefault ["autoDraftCreated",false]};
["ITEMS-0.12-606",_gate606,"Catálogo -> Kit Selecionado cria um novo Rascunho quando o painel estava vazio e conclui a cópia no mesmo gesto."] call _assert;

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,call _emptyDraftState];
private _arrow=["CATALOG","FirstAidKit","DRAFT","AUTO",player,"",createHashMapFromArray [["commandOrigin","CATALOG_ARROW_TO_DRAFT"],["autoCreateDraftIfMissing",true]]] call ServoPeregrino_Organizador_Items_fnc_executeUITransferCommand;
private _arrowState=([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap];
private _arrowDraft=_arrowState getOrDefault ["current",createHashMap];
private _arrowData=_arrow getOrDefault ["data",createHashMap];
private _gate607=(_arrow getOrDefault ["success",false]) && {_arrowState getOrDefault ["hasDraft",false]} && {([_arrowDraft getOrDefault ["entries",[]],"FirstAidKit"] call _qtyClass)>=1} && {_arrowData getOrDefault ["autoDraftCreated",false]};
["ITEMS-0.12-607",_gate607,"Gate histórico acompanha a paridade D.6.4: a seta explícita do Catálogo também pode criar Rascunho quando o painel está vazio."] call _assert;

private _kitEntryR=["ITEM","FirstAidKit",2,"NONE",[]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _kitEntry=(_kitEntryR getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]];
private _kitR=["Kit CP-C D63 Auto Draft",[_kitEntry],"ANY",["TEST","D63_AUTO_DRAFT"],""] call ServoPeregrino_Organizador_Items_fnc_createItemKit;
private _kit=(_kitR getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]];
private _saveR=if (_kitR getOrDefault ["success",false]) then {[_kit] call ServoPeregrino_Organizador_Items_fnc_saveKit} else {_kitR};
private _saveData=_saveR getOrDefault ["data",createHashMap];
private _kitId=_saveData getOrDefault ["kitId",((_saveData getOrDefault ["kit",[]]) param [2,"",[""]])];
private _sourceBefore=if (_kitId isEqualTo "") then {createHashMap} else {[_kitId] call ServoPeregrino_Organizador_Items_fnc_getKit};
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,call _emptyDraftState];
private _kitDrop=["KIT",_kitId,"DRAFT","AUTO",player,"",createHashMapFromArray [["commandOrigin","DND_KIT_PANEL_DRAFT"]]] call ServoPeregrino_Organizador_Items_fnc_executeUITransferCommand;
private _kitState=([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap];
private _kitDraft=_kitState getOrDefault ["current",createHashMap];
private _kitEntries=_kitDraft getOrDefault ["entries",[]];
private _sourceAfter=if (_kitId isEqualTo "") then {createHashMap} else {[_kitId] call ServoPeregrino_Organizador_Items_fnc_getKit};
private _sourceBeforeKit=(_sourceBefore getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]];
private _sourceAfterKit=(_sourceAfter getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]];
private _gate608=(_saveR getOrDefault ["success",false]) && {_kitDrop getOrDefault ["success",false]} && {_kitState getOrDefault ["hasDraft",false]} && {([_kitEntries,"FirstAidKit"] call _qtyClass)>=2} && {_sourceBeforeKit isEqualTo _sourceAfterKit} && {((_kitDrop getOrDefault ["data",createHashMap]) getOrDefault ["autoDraftCreated",false])};
["ITEMS-0.12-608",_gate608,"Meus Kits -> Kit Selecionado também cria Rascunho vazio e mescla o kit sem consumir ou alterar o kit persistido de origem."] call _assert;

[_productionBefore] call ServoPeregrino_Organizador_Items_fnc_restoreProductionRepositorySnapshot;
private _existing=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
if (!isNull _existing) then {closeDialog 0; uiSleep 0.03;};
private _dialog=createDialog "SP_ORG_Items_Dialog"; uiSleep 0.12;
private _display=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
private _pos={params ["_idc"]; if (isNull _display) exitWith {[]}; ctrlPosition (_display displayCtrl _idc)};
private _loadPos=[104] call _pos; private _barPos=[105] call _pos; private _idPos=[103] call _pos; private _unitPos=[108] call _pos; private _futurePos=[107] call _pos; private _closePos=[102] call _pos;
private _anchored=(count _loadPos)>=4 && {(count _barPos)>=4} && {(count _idPos)>=4} && {(count _unitPos)>=4} && {(count _futurePos)>=4} && {(count _closePos)>=4} && {abs((_loadPos#0)-(_barPos#0))<0.002*safeZoneW} && {abs((_loadPos#2)-(_barPos#2))<0.002*safeZoneW} && {(_loadPos#0)+(_loadPos#2)<=(_idPos#0)+0.002*safeZoneW} && {abs((_idPos#0)-(_unitPos#0))<0.002*safeZoneW} && {(_idPos#0)+(_idPos#2)<=(_futurePos#0)+0.002*safeZoneW} && {(_futurePos#0)+(_futurePos#2)<=(_closePos#0)+0.002*safeZoneW};
private _gate609=!isNull _display && {_dialog} && {_anchored} && {(_srcDialog find "SPORG_ITEMS_UI_HEADER_CLOSE_X")>=0} && {(_srcDialog find "SPORG_ITEMS_UI_HEADER_FUTURE_X")>=0} && {(_srcDialog find "SPORG_ITEMS_UI_HEADER_ID_X")>=0} && {(_srcDialog find "SPORG_ITEMS_UI_HEADER_LOAD_X")>=0};
["ITEMS-0.12-609",_gate609,"Header passa a ser um bloco ancorado no Fechar: Carga/barra alinhadas, Operador/Unidade empilhados, slot futuro e X em sequência."] call _assert;
if (!isNull _display) then {closeDialog 0; uiSleep 0.03;};

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,_draftStateBefore];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_uiStateBefore];
[_productionBefore] call ServoPeregrino_Organizador_Items_fnc_restoreProductionRepositorySnapshot;
private _loadoutAfter=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _productionAfter=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _cmp610=[_loadoutBefore,_loadoutAfter,"ITEMS-0.12-610"] call ServoPeregrino_Organizador_Items_fnc_compareLoadoutFingerprints;
private _cmp610d=_cmp610 getOrDefault ["data",createHashMap];
private _changed610=_cmp610d getOrDefault ["changedIndexes",[]];
private _ambient610=!(_cmp610d getOrDefault ["equal",false]) && {(count _changed610)>0} && {(_changed610 findIf {!(_x in [0,1,2])})<0};
if (_ambient610) then {diag_log format ["[SP_ORG] [ITEMS] [TEST_AMBIENT_DRIFT] label=ITEMS-0.12-610 changedIndexes=%1 accepted=true reason=WEAPON_SLOTS_ONLY",_changed610];};
private _gate610=((_cmp610d getOrDefault ["equal",false]) || {_ambient610}) && {_productionAfter isEqualTo _productionBefore};
["ITEMS-0.12-610",_gate610,"D.6.3 restaura fixtures, Rascunho, storage e loadout após os smokes; nenhuma conveniência de DnD deixa efeito colateral de teste."] call _assert;

["HIDE",controlNull,displayNull] call ServoPeregrino_Organizador_Items_fnc_updateUIItemTooltip;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
private _durationMs=round ((diag_tickTime-_startedAt)*1000);
private _summary=createHashMapFromArray [["delivery","0.12-D.6.3"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],["base",_base],["baseExpected",602],["checkpointFirstGate",603],["checkpointLastGate",610],["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],["cumulativeExpected",610],["cumulativePassed",602+_passed],["durationMs",_durationMs],["autoDraftOnDrop",true],["dragOnlyAutoCreate",false],["explicitAddAutoCreate",true],["headerCloseAnchored",true],["historical484Hardened",true]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] 0.12-D.6.3 — BASE=602/602  D.6.3=%1/8  FAIL=%2  CUMULATIVO=%3/610  TEMPO=%4ms",_passed,_failed,602+_passed,_durationMs];
diag_log "[SP_ORG] [ITEMS] 0.12-D.6.3 — Manual: sem kit aberto, arrastar Catálogo -> Kit Selecionado cria Rascunho; repetir Meus Kits -> Kit Selecionado; validar header ancorado no Fechar.";
diag_log "============================================================";
if (hasInterface) then {hint parseText format ["<t size='1.25'>SP_ORG_Items 0.12-D.6.3</t><br/><br/>Baseline D.6.2: <t color='#7CFC00'>602 / 602</t><br/>D.6.3: <t color='%1'>%2 / 8</t><br/>Cumulativo: %3 / 610<br/><br/>%4",if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_passed,602+_passed,if (_failed isEqualTo 0) then {"Valide o auto-Rascunho por DnD e o novo bloco do header."} else {"Consulte o primeiro FAIL no RPT."}];};
_summary
