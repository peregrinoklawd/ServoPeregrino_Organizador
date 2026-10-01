#include "..\..\script_version.hpp"
disableSerialization;

private _legacyRunningState=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR,createHashMap];
if (_legacyRunningState getOrDefault ["running",false]) exitWith {[false,"ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING","A regressão legada já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _orchestrator=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
if (_orchestrator getOrDefault ["running",false]) exitWith {[false,"ITEMS_0_11_CP_D_ALREADY_RUNNING","Outra suíte cumulativa já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};

private _startedAt=diag_tickTime;
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.11 CP-D — MOVEMENT CONTROLS + INTERACTION POLISH — 460 GATES";
diag_log "============================================================";

[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
uiSleep 0.02;
private _base=[] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_11CheckpointCTests;
private _baseOk=(_base isEqualType createHashMap) && {_base getOrDefault ["success",false]} && {(_base getOrDefault ["checkpointPassed",0]) isEqualTo 8} && {(_base getOrDefault ["cumulativePassed",0]) isEqualTo 450};
if !(_baseOk) exitWith {
    [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
    private _summary=createHashMapFromArray [["delivery","0.11 CP-D"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",false],["code","ITEMS_0_11_CP_D_BASE_450_FAILED"],["base",_base],["checkpointSkipped",true],["checkpointFirstGate",451],["checkpointLastGate",460],["checkpointTotal",0],["checkpointPassed",0],["checkpointFailed",0],["cumulativeExpected",460]];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    diag_log "[SP_ORG] [ITEMS] 0.11 CP-D — FAIL-FAST: baseline CP-C 450/450 não fechou.";
    if (hasInterface) then {hint "SP_ORG_Items 0.11 CP-D reprovado na baseline 450/450. Consulte o primeiro FAIL no RPT.";};
    _summary
};

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.11 CP-D"]]];
private _passed=0;
private _failed=0;
private _results=[];
private _assert={
    params ["_id","_condition","_detail"];
    private _ok=(_condition isEqualType true) && {_condition};
    private _status=if (_ok) then {"PASS"} else {"FAIL"};
    if (_ok) then {_passed=_passed+1;} else {_failed=_failed+1;};
    _results pushBack [_id,_status,_detail];
    diag_log format ["[SP_ORG] [ITEMS] [TEST 0.11 CP-D] [%1] %2 — %3",_status,_id,_detail];
};

private _productionBefore=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _loadoutBefore=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];

// 451 — o flood conhecido de Structured Text não pode reaparecer.
private _srcActions=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\tests\fn_installTestActions.sqf";
private _srcInit=preprocessFileLineNumbers "initPlayerLocal.sqf";
private _srcDesc=preprocessFileLineNumbers "description.ext";
private _srcEscape=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_escapeStructuredText.sqf";
private _gate451=(_srcActions find "Capacity & Item Awareness" < 0)
    && {(_srcInit find "Capacity & Item Awareness" < 0)}
    && {(_srcDesc find "Capacity & Item Awareness" < 0)}
    && {(_srcActions find " & " < 0)} && {(_srcInit find " & " < 0)} && {(_srcDesc find " & " < 0)}
    && {(_srcEscape find "&amp;" >= 0)} && {(_srcEscape find "&lt;" >= 0)} && {(_srcEscape find "&gt;" >= 0)};
["ITEMS-0.11-451",_gate451,"Structured Text hardening remove o '&' cru da identidade CP-C/CP-D nos contextos runtime e mantém escape &amp;/&lt;/&gt; central."] call _assert;

// 452 — wheel fica local ao display e não sobrescreve handlers globais de mods.
private _srcDialog=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\ui\items_dialog.hpp";
private _srcWheel=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUIWheel.sqf";
private _gate452=(_srcDialog find "onMouseZChanged" >= 0)
    && {(_srcDialog find "fnc_handleUIWheel" >= 0)}
    && {(_srcWheel find "ctrlSetScrollValues" >= 0)}
    && {(_srcWheel find "getMousePosition" >= 0)}
    && {(_srcWheel find "inGameUISetEventHandler" < 0)};
["ITEMS-0.11-452",_gate452,"Wheel Guard é scoped ao display SP_ORG: consome o gesto e faz scroll local sem instalar inGameUISetEventHandler global que pisaria em mods."] call _assert;

// 453 — Equipment expõe controles físicos de linha e seleção dedicada.
private _gate453=(_srcDialog find "idc=4130" >= 0) && {(_srcDialog find "idc=4131" >= 0)} && {(_srcDialog find "idc=4132" >= 0)} && {(_srcDialog find "idc=4133" >= 0)}
    && {(_srcDialog find "EQUIPMENT_SELECT" >= 0)} && {(_srcDialog find "fnc_handleEquipmentQuantityKeyDown" >= 0)};
["ITEMS-0.11-453",_gate453,"Equipment possui - / quantidade / + / X reais e seleção dedicada sem transformar o painel físico em Draft."] call _assert;

// 454 — normalizador físico de linha cobre +, -, Delete e quantidade 0 determinísticamente.
private _entryR=["ITEM","FirstAidKit",3,"NONE",[]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _entry=(_entryR getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]];
private _plus=["PLUS",_entry,-1] call ServoPeregrino_Organizador_Items_fnc_createUIPhysicalRowCommand;
private _minus=["MINUS",_entry,-1] call ServoPeregrino_Organizador_Items_fnc_createUIPhysicalRowCommand;
private _delete=["DELETE",_entry,-1] call ServoPeregrino_Organizador_Items_fnc_createUIPhysicalRowCommand;
private _zero=["QUANTITY",_entry,0] call ServoPeregrino_Organizador_Items_fnc_createUIPhysicalRowCommand;
private _gate454=(_entryR getOrDefault ["success",false])
    && {(_plus getOrDefault ["success",false])} && {(((_plus getOrDefault ["data",createHashMap]) getOrDefault ["operation",""]) isEqualTo "ADD")} && {((((_plus getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]]) param [3,0]) isEqualTo 1)}
    && {(_minus getOrDefault ["success",false])} && {(((_minus getOrDefault ["data",createHashMap]) getOrDefault ["operation",""]) isEqualTo "REMOVE")} && {((((_minus getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]]) param [3,0]) isEqualTo 1)}
    && {(_delete getOrDefault ["success",false])} && {((((_delete getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]]) param [3,0]) isEqualTo 3)}
    && {(_zero getOrDefault ["success",false])} && {((((_zero getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]]) param [3,0]) isEqualTo 3)};
["ITEMS-0.11-454",_gate454,"Normalizador de linha física converte +/−/Delete/quantidade 0 em um único delta ADD/REMOVE sem duplicar dispatch."] call _assert;

// 455 — EXACT não pode crescer por quantidade inferida; + usa DEFAULT_FULL separado no executor.
private _exactR=["MAGAZINE","30Rnd_65x39_caseless_mag",3,"EXACT",[30,17,6]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _exact=(_exactR getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]];
private _exactGrow=["QUANTITY",_exact,4] call ServoPeregrino_Organizador_Items_fnc_createUIPhysicalRowCommand;
private _srcExec=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_executeEquipmentRowAction.sqf";
private _gate455=(_exactR getOrDefault ["success",false]) && {!(_exactGrow getOrDefault ["success",true])}
    && {(_exactGrow getOrDefault ["code",""]) isEqualTo "ITEMS_UI_PHYSICAL_EXACT_ADD_REQUIRES_STATE"}
    && {(_srcExec find "DEFAULT_FULL" >= 0)} && {(_srcExec find "fnc_createItemEntry" >= 0)} && {(_srcExec find "fnc_executeUITransferCommand" >= 0)};
["ITEMS-0.11-455",_gate455,"Equipment preserva EXACT: digitação não fabrica stateData; + materializa um magazine DEFAULT_FULL separado em vez de falsificar munição parcial."] call _assert;

// 456 — Enter/Numpad Enter e quantidade 0 convergem ao request com confirmação destrutiva.
private _srcQtyKey=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleEquipmentQuantityKeyDown.sqf";
private _srcQtyCommit=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_commitEquipmentQuantityFromControl.sqf";
private _srcRequest=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_requestEquipmentRowAction.sqf";
private _gate456=(_srcQtyKey find "[28,156]" >= 0) && {(_srcQtyCommit find "fnc_requestEquipmentRowAction" >= 0)}
    && {(_srcRequest find "_explicitValue isEqualTo 0" >= 0)} && {(_srcRequest find "BIS_fnc_guiMessage" >= 0)} && {(_srcRequest find "EQUIPMENT_QUANTITY_ZERO_CONFIRMED" >= 0)};
["ITEMS-0.11-456",_gate456,"Quantidade física confirma com Return/Numpad Enter; valor 0 remove somente após confirmação explícita e usa o mesmo executor central."] call _assert;

// 457 — Meus Kits mantém duas ações inequívocas: clique abre/seleciona; drag combina.
// A antiga rail → foi removida na 0.12-C.5 porque o glyph/hit-zone era ambíguo; Catálogo/Equipment mantêm botões dedicados.
private _srcEvent=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUIEvent.sqf";
private _srcDrag=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUIDragEvent.sqf";
private _gate457=(_srcDialog find "idc=1102") >= 0 && {(_srcDialog find "canDrag=1") >= 0}
    && {(_srcDialog find "KIT_ARROW_DOWN") < 0} && {(_srcDialog find "KIT_ARROW_CLICK") < 0}
    && {(_srcEvent find "case ""KIT_SELECT""") >= 0} && {(_srcEvent find "LOAD_KIT") >= 0}
    && {(_srcDrag find "case 1102:{""KIT""}") >= 0} && {(_srcDrag find "fnc_executeUITransferCommand") >= 0}
    && {(_srcEvent find "CATALOG_BUTTON_TO_DRAFT") >= 0} && {(_srcEvent find "EQUIPMENT_ARROW_TO_DRAFT") >= 0};
["ITEMS-0.11-457",_gate457,"Meus Kits usa clique apenas para abrir/selecionar e drag para combinar no Draft; affordance lateral ambígua foi removida, enquanto Catálogo/Equipment mantêm ações dedicadas."] call _assert;

// 458 — controles físicos usam VIEW congelado, não applicationTarget, e um único executeUITransferCommand.
private _gate458=(_srcExec find "applicationTarget" < 0) && {(_srcExec find "_target=toUpper _view" >= 0)}
    && {(_srcExec find "fnc_executeUITransferCommand" >= 0)} && {(_srcRequest find "SPORG_Items_equipmentView" >= 0)};
["ITEMS-0.11-458",_gate458,"Controles de linha física usam o Equipment VIEW congelado como target; applicationTarget continua independente e o executor central faz um dispatch por gesto."] call _assert;

// 459 — botão ATUALIZAR deixa de fazer FULL e executa EQUIPMENT_FOCUSED em runtime.
private _existing=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
if (!isNull _existing) then {closeDialog 0; uiSleep 0.03;};
private _dialog=createDialog "SP_ORG_Items_Dialog";
uiSleep 0.10;
private _stateBefore=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _fullBefore=_stateBefore getOrDefault ["fullRefreshCount",0];
["REFRESH"] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent;
uiSleep 0.03;
private _stateAfter=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _gate459=_dialog && {(_stateAfter getOrDefault ["fullRefreshCount",-1]) isEqualTo _fullBefore} && {(_stateAfter getOrDefault ["lastRefreshMode",""]) isEqualTo "EQUIPMENT_FOCUSED"};
["ITEMS-0.11-459",_gate459,"ATUALIZAR Equipment recaptura apenas EQUIPMENT_FOCUSED e não volta ao FULL dos quatro painéis."] call _assert;

// 460 — fechamento: sem mutação real/storage e UI continua com drag/drop visual explícito.
private _srcDrag=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_handleUIDragEvent.sqf";
private _loadoutAfter=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _productionAfter=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _cmp460=[_loadoutBefore,_loadoutAfter,"ITEMS-0.11-460"] call ServoPeregrino_Organizador_Items_fnc_compareLoadoutFingerprints;
private _cmp460d=_cmp460 getOrDefault ["data",createHashMap];
private _changed460=_cmp460d getOrDefault ["changedIndexes",[]];
private _ambient460=!(_cmp460d getOrDefault ["equal",false]) && {(count _changed460)>0} && {(_changed460 findIf {!(_x in [0,1,2])})<0};
if (_ambient460) then {diag_log format ["[SP_ORG] [ITEMS] [TEST_AMBIENT_DRIFT] label=ITEMS-0.11-460 changedIndexes=%1 accepted=true reason=WEAPON_SLOTS_ONLY",_changed460];};
private _gate460=((_cmp460d getOrDefault ["equal",false]) || {_ambient460})
    && {_productionAfter isEqualTo _productionBefore}
    && {(_srcDrag find "SOLTE EM QUALQUER LUGAR DESTE PAINEL PARA ADICIONAR AO KIT" >= 0)}
    && {(_srcDrag find "NÃO É POSSÍVEL ADICIONAR ITENS NESTE EQUIPAMENTO AGORA" >= 0)}
    && {(_srcDrag find "ESTE ITEM NÃO PODE SER ADICIONADO AQUI" >= 0)};
["ITEMS-0.11-460",_gate460,"CP-D preserva loadout/storage durante a suíte e mantém feedback visual permitido/bloqueado do DnD sem regressão dos contratos anteriores."] call _assert;

private _displayEnd=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
if (!isNull _displayEnd) then {closeDialog 0; uiSleep 0.03;};
[_productionBefore] call ServoPeregrino_Organizador_Items_fnc_restoreProductionRepositorySnapshot;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;

private _durationMs=round ((diag_tickTime-_startedAt)*1000);
private _summary=createHashMapFromArray [["delivery","0.11 CP-D"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],["base",_base],["baseExpected",450],["checkpointFirstGate",451],["checkpointLastGate",460],["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],["cumulativeExpected",460],["cumulativePassed",450+_passed],["durationMs",_durationMs],["movementInteractionPolish",true]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] 0.11 CP-D — BASE=450/450  CP-D=%1/10  FAIL=%2  CUMULATIVO=%3/460  TEMPO=%4ms",_passed,_failed,450+_passed,_durationMs];
diag_log "[SP_ORG] [ITEMS] 0.11 CP-D — Manual: wheel não abre action menu; Kits combinam por drag sem trocar Draft; Equipment -/qtd/+/X opera no VIEW; 0/Delete seguem contrato; ultrawide permanece legível.";
diag_log "============================================================";
if (hasInterface) then {hint parseText format ["<t size='1.25'>SP_ORG_Items 0.11 CP-D</t><br/><br/>Baseline CP-C: <t color='#7CFC00'>450 / 450</t><br/>CP-D: <t color='%1'>%2 / 10</t><br/>Cumulativo: %3 / 460<br/><br/>%4",if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_passed,450+_passed,if (_failed isEqualTo 0) then {"Valide wheel, setas e controles físicos do Equipment."} else {"Consulte o primeiro FAIL no RPT."}];};
_summary
