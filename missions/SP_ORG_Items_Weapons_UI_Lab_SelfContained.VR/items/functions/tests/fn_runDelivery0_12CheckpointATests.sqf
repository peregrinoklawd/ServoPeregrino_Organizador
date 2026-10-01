#include "..\..\script_version.hpp"
disableSerialization;

private _legacyRunningState=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR,createHashMap];
if (_legacyRunningState getOrDefault ["running",false]) exitWith {[false,"ITEMS_LEGACY_TEST_SUITE_ALREADY_RUNNING","A regressão legada já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _orchestrator=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
if (_orchestrator getOrDefault ["running",false]) exitWith {[false,"ITEMS_0_12_A_ALREADY_RUNNING","Outra suíte cumulativa já está em execução.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};

private _startedAt=diag_tickTime;
diag_log "============================================================";
diag_log "[SP_ORG] [ITEMS] 0.12-A — HEADER, SEARCH + LAYOUT SYMMETRY — 468 GATES";
diag_log "============================================================";

[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
uiSleep 0.02;
private _base=[] call ServoPeregrino_Organizador_Items_fnc_runDelivery0_11CheckpointDTests;
private _baseOk=(_base isEqualType createHashMap) && {_base getOrDefault ["success",false]} && {(_base getOrDefault ["checkpointPassed",0]) isEqualTo 10} && {(_base getOrDefault ["cumulativePassed",0]) isEqualTo 460};
if !(_baseOk) exitWith {
    [] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;
    private _summary=createHashMapFromArray [["delivery","0.12-A"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",false],["code","ITEMS_0_12_A_BASE_460_FAILED"],["base",_base],["checkpointSkipped",true],["checkpointFirstGate",461],["checkpointLastGate",468],["checkpointTotal",0],["checkpointPassed",0],["checkpointFailed",0],["cumulativeExpected",468]];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
    diag_log "[SP_ORG] [ITEMS] 0.12-A — FAIL-FAST: baseline CP-D 460/460 não fechou.";
    if (hasInterface) then {hint "SP_ORG_Items 0.12-A reprovado na baseline 460/460. Consulte o primeiro FAIL no RPT.";};
    _summary
};

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMapFromArray [["running",true],["startedAtTick",_startedAt],["delivery","0.12-A"]]];
private _passed=0;
private _failed=0;
private _results=[];
private _assert={
    params ["_id","_condition","_detail"];
    private _ok=(_condition isEqualType true) && {_condition};
    private _status=if (_ok) then {"PASS"} else {"FAIL"};
    if (_ok) then {_passed=_passed+1;} else {_failed=_failed+1;};
    _results pushBack [_id,_status,_detail];
    diag_log format ["[SP_ORG] [ITEMS] [TEST 0.12-A] [%1] %2 — %3",_status,_id,_detail];
};

private _productionBefore=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _loadoutBefore=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _srcDialog=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\ui\items_dialog.hpp";
private _srcRefresh=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshInterface.sqf";
private _srcVM=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_buildUIViewModel.sqf";
private _srcKitAwareness=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_getUIItemKitAwareness.sqf";
private _srcHeader=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshHeaderUI.sqf";
private _srcPhysical=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshPhysicalMutationUI.sqf";
private _srcEq=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshEquipmentViewUI.sqf";
private _srcTarget=preprocessFileLineNumbers "ServoPeregrino_Organizador_Items\functions\ui\fn_refreshPhysicalTargetUI.sqf";

// 461 — lupa consistente antes das quatro buscas.
private _gate461=true;
{_gate461=_gate461 && {(_srcDialog find format ["idc=%1",_x])>=0};} forEach [1090,2090,3090,4090];
_gate461=_gate461 && {(_srcDialog find "search_ca.paa")>=0};
["ITEMS-0.12-461",_gate461,"As quatro barras de pesquisa possuem lupa dedicada, alinhada antes do campo, usando ícone nativo do Arma."] call _assert;

// 462 — ações do Draft ficam logo abaixo da busca e antes da drop zone/lista.
private _gate462=(_srcDialog find "class DraftSave")>=0 && {(_srcDialog find "y=safeZoneY+0.139*safeZoneH")>=0}
    && {(_srcDialog find "y=safeZoneY+0.181*safeZoneH")>=0} && {(_srcDialog find "y=safeZoneY+0.224*safeZoneH")>=0};
["ITEMS-0.12-462",_gate462,"Salvar/Salvar como novo/Descartar/Limpar foram movidos para o topo do Draft, acima da área de arraste e da lista."] call _assert;

// 463 — rótulos humanos sem mudar os códigos internos U/C/M/ANY.
private _gate463=(_srcDialog find "text=""UNIFORME""")>=0 && {(_srcDialog find "text=""COLETE""")>=0} && {(_srcDialog find "text=""MOCHILA""")>=0}
    && {(_srcDialog find "class AppAny")>=0} && {(_srcDialog find "['APP_TARGET','ANY']")>=0} && {(_srcDialog find "class AppAny: SPORG_Items_Button {idc=2110; text=""""")>=0}
    && {(_srcDialog find "['APP_TARGET','U']")>=0} && {(_srcDialog find "['APP_TARGET','C']")>=0} && {(_srcDialog find "['APP_TARGET','M']")>=0}
    && {(_srcDialog find "['EQUIPMENT_VIEW','U']")>=0} && {(_srcDialog find "['EQUIPMENT_VIEW','C']")>=0} && {(_srcDialog find "['EQUIPMENT_VIEW','M']")>=0};
["ITEMS-0.12-463",_gate463,"Uniforme/Colete/Mochila permanecem player-facing; ANY continua disponível no contrato interno sem ocupar um botão visível."] call _assert;

// 464 — Meus Kits usa 'items' e awareness de massa do mesmo modelo da UI.
private _kitEntryR=["ITEM","FirstAidKit",2,"NONE",[]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
private _kitEntries=[];
if (_kitEntryR getOrDefault ["success",false]) then {_kitEntries pushBack (((_kitEntryR getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]]));};
private _kitR=["0.12-A Awareness",_kitEntries,"ANY",["TEST","UI_AWARENESS"]] call ServoPeregrino_Organizador_Items_fnc_createItemKit;
private _kitRuntime=((_kitR getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]]);
private _aware=[_kitRuntime] call ServoPeregrino_Organizador_Items_fnc_getUIItemKitAwareness;
private _gate464=(_kitR getOrDefault ["success",false]) && {(_aware getOrDefault ["entryCount",-1]) isEqualTo 1}
    && {(_srcVM find "fnc_getUIItemKitAwareness")>=0} && {(_srcVM find "totalMass")>=0} && {(_srcRefresh find "%2 items")>=0} && {(_srcRefresh find "entradas")<0};
["ITEMS-0.12-464",_gate464,"Meus Kits troca 'entradas' por 'items' e mostra massa total do kit sem alterar o schema persistido."] call _assert;

// 465 — cabeçalho possui identidade, carga, barra e slot futuro.
private _gate465=true;
{_gate465=_gate465 && {(_srcDialog find format ["idc=%1",_x])>=0};} forEach [103,104,105,106,107];
_gate465=_gate465 && {(_srcHeader find "name _unit")>=0} && {(_srcHeader find "groupId")>=0} && {(_srcHeader find "loadAbs")>=0} && {(_srcHeader find "load _unit")>=0} && {(_srcHeader find "ctrlSetPosition")>=0};
["ITEMS-0.12-465",_gate465,"Barra de título mostra operador, unidade, carga numérica, barra proporcional e mantém um slot reservado antes do Fechar."] call _assert;

// 466 — header awareness é refresh sob demanda, nunca por frame.
private _gate466=(_srcRefresh find "fnc_refreshHeaderUI")>=0 && {(_srcPhysical find "fnc_refreshHeaderUI")>=0} && {(_srcEq find "fnc_refreshHeaderUI")>=0} && {(_srcTarget find "fnc_refreshHeaderUI")>=0}
    && {(_srcHeader find "EachFrame")<0} && {(_srcHeader find "addMissionEventHandler")<0} && {(_srcHeader find "onEachFrame")<0};
["ITEMS-0.12-466",_gate466,"Carga do cabeçalho atualiza nos refreshes relevantes sem cálculo por frame ou event handler global."] call _assert;

// 467 — helpers visuais não escrevem storage nem mutam inventário.
private _gate467=(_srcKitAwareness find "saveStorage")<0 && {(_srcKitAwareness find "saveProfileNamespace")<0} && {(_srcKitAwareness find "mutateContainerEntry")<0}
    && {(_srcHeader find "saveStorage")<0} && {(_srcHeader find "saveProfileNamespace")<0} && {(_srcHeader find "mutateContainerEntry")<0};
["ITEMS-0.12-467",_gate467,"Awareness de kit e cabeçalho são estritamente de leitura: sem storage write e sem mutação física."] call _assert;

// 468 — fechamento: baseline física intacta e nenhum efeito real durante os gates A.
private _loadoutAfter=([player] call ServoPeregrino_Organizador_Items_fnc_getLoadoutFingerprint) getOrDefault ["data",createHashMap];
private _productionAfter=[] call ServoPeregrino_Organizador_Items_fnc_captureProductionRepositorySnapshot;
private _gate468=(_loadoutAfter getOrDefault ["serialized","B"]) isEqualTo (_loadoutBefore getOrDefault ["serialized","A"])
    && {_productionAfter isEqualTo _productionBefore}
    && {(SERVO_PEREGRINO_ORGANIZADOR_ITEMS_SEMANTIC_VERSION find "0.12.") isEqualTo 0}
    && {SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DELIVERY_0_12_A_CUMULATIVE_GATE_COUNT isEqualTo 468};
["ITEMS-0.12-468",_gate468,"0.12-A permanece integrada sobre a CP-D homologada sem tocar loadout/storage e conserva sua baseline cumulativa 468/468 em descendentes 0.12.x."] call _assert;

private _displayEnd=findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD;
if (!isNull _displayEnd) then {closeDialog 0; uiSleep 0.03;};
[_productionBefore] call ServoPeregrino_Organizador_Items_fnc_restoreProductionRepositorySnapshot;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
[] call ServoPeregrino_Organizador_Items_fnc_prepareCumulativeTestRun;

private _durationMs=round ((diag_tickTime-_startedAt)*1000);
private _summary=createHashMapFromArray [["delivery","0.12-A"],["build",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["success",_failed isEqualTo 0],["base",_base],["baseExpected",460],["checkpointFirstGate",461],["checkpointLastGate",468],["checkpointTotal",_passed+_failed],["checkpointPassed",_passed],["checkpointFailed",_failed],["checkpointResults",_results],["cumulativeExpected",468],["cumulativePassed",460+_passed],["durationMs",_durationMs],["headerSearchLayoutSymmetry",true]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR,_summary];
diag_log "============================================================";
diag_log format ["[SP_ORG] [ITEMS] 0.12-A — BASE=460/460  0.12-A=%1/8  FAIL=%2  CUMULATIVO=%3/468  TEMPO=%4ms",_passed,_failed,460+_passed,_durationMs];
diag_log "[SP_ORG] [ITEMS] 0.12-A — Manual: validar lupa nas quatro buscas, massa em Meus Kits, ações do Draft no topo, rótulos completos e cabeçalho operador/unidade/carga em ultrawide.";
diag_log "============================================================";
if (hasInterface) then {hint parseText format ["<t size='1.25'>SP_ORG_Items 0.12-A</t><br/><br/>Baseline CP-D: <t color='#7CFC00'>460 / 460</t><br/>0.12-A: <t color='%1'>%2 / 8</t><br/>Cumulativo: %3 / 468<br/><br/>%4",if (_failed isEqualTo 0) then {"#7CFC00"} else {"#FF6B6B"},_passed,460+_passed,if (_failed isEqualTo 0) then {"Valide o novo layout e o cabeçalho."} else {"Consulte o primeiro FAIL no RPT."}];};
_summary
