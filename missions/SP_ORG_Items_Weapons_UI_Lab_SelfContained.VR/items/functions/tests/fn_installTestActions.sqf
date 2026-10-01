#include "..\..\script_version.hpp"
params [["_unit",objNull,[objNull]]];
if (isNull _unit) exitWith {[]};
private _old=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ACTIONS_VAR,[]];
{_unit removeAction _x;} forEach _old;
private _actions=[];

_actions pushBack (_unit addAction [
    "<t color='#7CFC00'>SP_ORG_Items 0.13-A — Server Authority Foundation</t>",
    {
        private _o=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
        private _s=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RUNNING_VAR,createHashMap];
        if ((_o getOrDefault ["running",false]) || {_s getOrDefault ["running",false]}) then {
            hint "Suíte de testes já está em execução.";
        } else {
            [] spawn ServoPeregrino_Organizador_Items_fnc_runDelivery0_13CheckpointATests;
        };
    },nil,11.8,false,true,"","true",5
]);
_actions pushBack (_unit addAction [
    "<t color='#7FD9D0'>SP_ORG_Items 0.13-A — Abrir interface</t>",
    {hintSilent ""; private _r=[] call ServoPeregrino_Organizador_Items_fnc_openInterface; if !(_r getOrDefault ["success",false]) then {hint format ["%1 — %2",_r getOrDefault ["code","UNKNOWN"],_r getOrDefault ["message",""]];};},nil,10.5,false,true,"","true",5
]);
_actions pushBack (_unit addAction [
    "<t color='#FFDF8A'>SP_ORG_Items 0.13-A — Diagnosticar kits de teste vazados</t>",
    {private _r=[] call ServoPeregrino_Organizador_Items_fnc_findLeakedTestKits; private _d=_r getOrDefault ["data",createHashMap]; hint format ["Kits de teste detectados: %1. Nenhum item foi removido. Veja TEST_STORAGE_GUARD no RPT.",_d getOrDefault ["count",0]];},nil,9.7,false,true,"","true",5
]);
_actions pushBack (_unit addAction [
    "<t color='#FF8A8A'>SP_ORG_Items 0.13-A — REMOVER kits de teste vazados</t>",
    {[] spawn {private _scan=[] call ServoPeregrino_Organizador_Items_fnc_findLeakedTestKits; private _sd=_scan getOrDefault ["data",createHashMap]; private _n=_sd getOrDefault ["count",0]; if (_n <= 0) exitWith {hint "Nenhum fixture histórico detectado.";}; private _ok=[format ["Foram detectados %1 kits com nome E metadata de fixtures conhecidos. Remover esses kits persistidos?",_n],"SP_ORG_Items — limpeza de fixtures",true,true] call BIS_fnc_guiMessage; if (_ok) then {private _r=["CONFIRM_TEST_FIXTURE_CLEANUP"] call ServoPeregrino_Organizador_Items_fnc_cleanupLeakedTestKits; private _d=_r getOrDefault ["data",createHashMap]; hint format ["Limpeza de fixtures: %1 removidos | %2 falhas.",count (_d getOrDefault ["removed",[]]),count (_d getOrDefault ["failed",[]])];} else {hint "Limpeza cancelada.";};};},nil,9.5,false,true,"","true",5
]);
_actions pushBack (_unit addAction [
    "SP_ORG_Items 0.13-A — Status / UI + Biblioteca",
    {
        private _a=[] call ServoPeregrino_Organizador_Items_fnc_getApplicationStatus;
        private _ad=_a getOrDefault ["data",createHashMap];
        private _u=[] call ServoPeregrino_Organizador_Items_fnc_getUIState;
        private _us=((_u getOrDefault ["data",createHashMap]) getOrDefault ["state",createHashMap]);
        private _rr=[player,_us getOrDefault ["applicationTarget","ANY"],""] call ServoPeregrino_Organizador_Items_fnc_getUIPhysicalReadiness;
        private _rd=_rr getOrDefault ["data",createHashMap];
        private _ds=([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap];
        private _dc=_ds getOrDefault ["current",createHashMap];
        private _pc=_rd getOrDefault ["capacity",createHashMap];
        private _ec=_us getOrDefault ["lastEquipmentCapacity",createHashMap];
        private _targetCurrent=[_pc getOrDefault ["currentLoad",0],false,2] call ServoPeregrino_Organizador_Items_fnc_formatUIMass;
        private _targetMax=[_pc getOrDefault ["maxLoad",0],false,2] call ServoPeregrino_Organizador_Items_fnc_formatUIMass;
        private _targetFree=[_pc getOrDefault ["availableLoad",0],false,2] call ServoPeregrino_Organizador_Items_fnc_formatUIMass;
        private _draftMass=[_us getOrDefault ["lastDraftTotalMass",0],false,2] call ServoPeregrino_Organizador_Items_fnc_formatUIMass;
        private _eqContent=[_us getOrDefault ["lastEquipmentContentMass",0],false,2] call ServoPeregrino_Organizador_Items_fnc_formatUIMass;
        private _eqCurrent=[_ec getOrDefault ["currentLoad",0],false,2] call ServoPeregrino_Organizador_Items_fnc_formatUIMass;
        private _eqMax=[_ec getOrDefault ["maxLoad",0],false,2] call ServoPeregrino_Organizador_Items_fnc_formatUIMass;
        hint parseText format ["<t size='1.2'>SP_ORG_Items 0.13-A</t><br/><br/>Application ready: %1<br/>Physical ready: %2<br/>Destino: %3 → %4<br/>Carga target: %5 / %6 · livre %7<br/>View: %8<br/>Draft entries: %9 · peso %10<br/>Equipment CONTENT: %11 · carga %12 / %13<br/>Outcome: %14<br/><br/>Último refresh: %15<br/>FULL: %16 ms (%17x)<br/>DRAFT_FOCUSED: %18 ms (%19x)<br/>PHYSICAL_FOCUSED: %20 ms · capture %21 ms<br/>CATALOG_FOCUSED: %22 ms · filtro %23 ms<br/>EQUIPMENT_FOCUSED: %24 ms · capture %25 ms<br/>KIT_SWITCH: %26 ms · focused %27 ms · fullDelta %28 · CatEq intactos %29/%30<br/><br/>Baseline 0.12 FINAL homologada · novos gates 0.13-A: 655..664 · dívida histórica 516/523 permanece aceita",_ad getOrDefault ["ready",false],_rd getOrDefault ["physicalMutationEnabled",false],_rd getOrDefault ["requestedTarget","ANY"],_rd getOrDefault ["resolvedTarget","-"],_targetCurrent,_targetMax,_targetFree,_us getOrDefault ["equipmentView","U"],count (_dc getOrDefault ["entries",[]]),_draftMass,_eqContent,_eqCurrent,_eqMax,_us getOrDefault ["lastOutcome","-"],_us getOrDefault ["lastRefreshMode","NONE"],_us getOrDefault ["lastFullRefreshDurationMs",-1],_us getOrDefault ["fullRefreshCount",0],_us getOrDefault ["lastDraftFocusedRefreshDurationMs",-1],_us getOrDefault ["draftFocusedRefreshCount",0],_us getOrDefault ["lastPhysicalFocusedRefreshDurationMs",-1],_us getOrDefault ["lastPhysicalFocusedCaptureDurationMs",-1],_us getOrDefault ["lastCatalogFocusedRefreshDurationMs",-1],_us getOrDefault ["lastCatalogFocusedFilterDurationMs",-1],_us getOrDefault ["lastEquipmentFocusedRefreshDurationMs",-1],_us getOrDefault ["lastEquipmentFocusedCaptureDurationMs",-1],_us getOrDefault ["lastKitSwitchTotalDurationMs",-1],_us getOrDefault ["lastKitSwitchFocusedRefreshDurationMs",-1],_us getOrDefault ["lastKitSwitchFullDelta",-1],_us getOrDefault ["lastKitSwitchCatalogUntouched",false],_us getOrDefault ["lastKitSwitchEquipmentUntouched",false]];
    },nil,9.1,false,true,"","true",5
]);
_actions pushBack (_unit addAction [
    "SP_ORG_Items 0.13-A — Criar Kit demo",
    {
        private _d=([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap];
        if (_d getOrDefault ["hasDraft",false]) then {private _cur=_d getOrDefault ["current",createHashMap]; if (_cur getOrDefault ["dirty",false]) then {hint "Há alterações não salvas. Salve ou descarte pela UI antes de substituir.";} else {[] call ServoPeregrino_Organizador_Items_fnc_discardDraft;};};
        private _d2=([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap];
        if !(_d2 getOrDefault ["hasDraft",false]) then {
            ["Kit UI Demo 0.13-A","ANY",["MANUAL","UI_DEMO"],[]] call ServoPeregrino_Organizador_Items_fnc_createNewDraft;
            ["FirstAidKit",2] call ServoPeregrino_Organizador_Items_fnc_addCatalogItemToDraft;
            private _e=["MAGAZINE","30Rnd_65x39_caseless_mag",3,"EXACT",[30,17,6]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
            if (_e getOrDefault ["success",false]) then {[((_e getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]])] call ServoPeregrino_Organizador_Items_fnc_addEntryToDraft;};
            hint "Kit demo criado. Valide: Onde aplicar o kit e Mostrar são independentes; drag Catálogo → Conteúdo do Equipamento deve obedecer Mostrar; arraste ou use ← para Kit Selecionado sem Rascunho e um novo Rascunho deve nascer; header ancorado no Fechar; Mostrar continua soberano no Equipment; pesos dos itens em kg/lb, carga do header em kg, DnD, tooltips, ←/→, X imediato e munição parcial permanecem.";
        };
    },nil,8.9,false,true,"","true",5
]);
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ACTIONS_VAR,_actions];
_actions
