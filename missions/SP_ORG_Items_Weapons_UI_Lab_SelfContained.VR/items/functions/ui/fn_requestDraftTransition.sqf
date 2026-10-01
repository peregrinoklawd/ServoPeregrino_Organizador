#include "..\..\script_version.hpp"
params [
    ["_action","",[""]],
    ["_payload","",[""]],
    ["_confirmed",false,[false]]
];
private _transitionPerfStartedAt=diag_tickTime;
private _actionU = toUpper _action;
private _uiPerfBefore=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _fullPerfBefore=_uiPerfBefore getOrDefault ["fullRefreshCount",0];
private _fromKitPerf=_uiPerfBefore getOrDefault ["selectedKitId",""];
private _catalogReadyPerf=false;
private _catalogCountPerf=0;
if (_actionU isEqualTo "LOAD_KIT") then {
    private _catalogPerfCache=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_CACHE_VAR,createHashMap];
    _catalogReadyPerf=(_catalogPerfCache getOrDefault ["provider",""]) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_PROVIDER
        && {(_catalogPerfCache getOrDefault ["buildKey",""]) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD};
    if (_catalogReadyPerf) then {_catalogCountPerf=count (_catalogPerfCache getOrDefault ["items",[]]);};
};
private _draftR = [] call ServoPeregrino_Organizador_Items_fnc_getDraftState;
private _dd = _draftR getOrDefault ["data",createHashMap];
private _has = _dd getOrDefault ["hasDraft",false];
private _current = _dd getOrDefault ["current",createHashMap];
private _dirty = _has && {_current getOrDefault ["dirty",false]};

// Toda confirmação agendada recebe action + payload explicitamente tipados como Strings.
// Isso elimina o caso 0.8 em que payload=nil fazia o segundo argumento desaparecer e _p ficava indefinido.
private _queueConfirmation = {
    params [
        ["_a","",[""]],
        ["_p","",[""]],
        ["_question","",[""]],
        ["_pendingCode","ITEMS_UI_CONFIRMATION_PENDING",[""]],
        ["_pendingMessage","Confirmação pendente.",[""]]
    ];
    [_a,_p,_question] spawn {
        params [["_a2","",[""]],["_p2","",[""]],["_q2","",[""]]];
        private _yes = [_q2,"SP_ORG_Items",true,true] call BIS_fnc_guiMessage;
        if (_yes) then {[_a2,_p2,true] call ServoPeregrino_Organizador_Items_fnc_requestDraftTransition;};
    };
    [true,_pendingCode,_pendingMessage,createHashMapFromArray [["action",_a],["payload",_p]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

// Fechar nunca descarta o estado de edição: se alterado, apenas confirma que ele permanecerá em memória.
if (_actionU isEqualTo "CLOSE_UI" && {_dirty} && {!_confirmed}) exitWith {
    [_actionU,_payload,"O kit possui alterações não salvas.<br/><br/>Fechar a interface mantendo o rascunho em memória?","ITEMS_UI_CONFIRMATION_PENDING","Confirmação de fechamento pendente."] call _queueConfirmation
};
if (_actionU isEqualTo "CLOSE_UI") exitWith {closeDialog 0; [true,"ITEMS_UI_CLOSED","Interface fechada. As alterações não salvas foram mantidas para esta sessão.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};

// Troca de kit / Novo / Descartar exige decisão explícita se há dirty.
if (_dirty && {!_confirmed} && {_actionU in ["LOAD_KIT","NEW_DRAFT","DISCARD_DRAFT"]}) exitWith {
    [_actionU,_payload,"O kit possui alterações não salvas.<br/><br/>Descartar essas alterações e continuar?","ITEMS_UI_CONFIRMATION_PENDING","Confirmação de descarte pendente."] call _queueConfirmation
};
if (_confirmed && {_dirty} && {_actionU in ["LOAD_KIT","NEW_DRAFT"]}) then {
    private _discard = [] call ServoPeregrino_Organizador_Items_fnc_discardDraft;
    if !(_discard getOrDefault ["success",false]) exitWith {_discard};
};
private _result = switch _actionU do {
    case "LOAD_KIT": {[_payload] call ServoPeregrino_Organizador_Items_fnc_loadDraftFromKit};
    case "NEW_DRAFT": {["Novo Kit","ANY",["UI","LOCAL"],[]] call ServoPeregrino_Organizador_Items_fnc_createNewDraft};
    case "DISCARD_DRAFT": {[] call ServoPeregrino_Organizador_Items_fnc_discardDraft};
    default {[false,"ITEMS_UI_TRANSITION_UNKNOWN","Não foi possível concluir esta ação do kit.",createHashMapFromArray [["action",_action]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
};
if (_result getOrDefault ["success",false]) then {
    private _ui = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
    private _newDraft = ([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap];
    private _newCurrent = _newDraft getOrDefault ["current",createHashMap];
    _ui set ["selectedKitId",if ((_newCurrent getOrDefault ["mode",""]) isEqualTo "EDIT") then {_newCurrent getOrDefault ["kitId",""]} else {""}];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_ui];
};
[_result getOrDefault ["message",_result getOrDefault ["code","UNKNOWN"]],if (_result getOrDefault ["success",false]) then {"INFO"} else {"WARN"}] call ServoPeregrino_Organizador_Items_fnc_pushUIFeedback;
private _logicalPerfMs=round ((diag_tickTime-_transitionPerfStartedAt)*1000);
private _refreshPerfStartedAt=diag_tickTime;
if (_actionU isEqualTo "LOAD_KIT") then {
    ["LOAD_KIT"] call ServoPeregrino_Organizador_Items_fnc_refreshKitSwitchUI;
} else {
    [] call ServoPeregrino_Organizador_Items_fnc_refreshInterface;
};
private _refreshPerfMs=round ((diag_tickTime-_refreshPerfStartedAt)*1000);
if (_actionU isEqualTo "LOAD_KIT") then {
    private _uiPerfAfter=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
    private _fullPerfAfter=_uiPerfAfter getOrDefault ["fullRefreshCount",0];
    private _toKitPerf=_uiPerfAfter getOrDefault ["selectedKitId",""];
    private _totalPerfMs=round ((diag_tickTime-_transitionPerfStartedAt)*1000);
    _uiPerfAfter set ["lastKitSwitchTotalDurationMs",_totalPerfMs];
    _uiPerfAfter set ["lastKitSwitchLogicalDurationMs",_logicalPerfMs];
    _uiPerfAfter set ["lastKitSwitchRefreshDurationMs",_refreshPerfMs];
    _uiPerfAfter set ["lastKitSwitchCatalogReady",_catalogReadyPerf];
    _uiPerfAfter set ["lastKitSwitchCatalogBase",_catalogCountPerf];
    _uiPerfAfter set ["lastKitSwitchFullDelta",_fullPerfAfter-_fullPerfBefore];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_uiPerfAfter];
    diag_log format ["[SP_ORG] [ITEMS] [UI_PERF_KIT_SWITCH] success=%1 confirmed=%2 catalogReady=%3 catalogBase=%4 from=%5 to=%6 logicalMs=%7 refreshMs=%8 totalMs=%9 fullDelta=%10 focusedMs=%11 catalogUntouched=%12 equipmentUntouched=%13 equipmentRecaptureDelta=%14 targetRefreshDelta=%15",_result getOrDefault ["success",false],_confirmed,_catalogReadyPerf,_catalogCountPerf,_fromKitPerf,_toKitPerf,_logicalPerfMs,_refreshPerfMs,_totalPerfMs,_fullPerfAfter-_fullPerfBefore,_uiPerfAfter getOrDefault ["lastKitSwitchFocusedRefreshDurationMs",-1],_uiPerfAfter getOrDefault ["lastKitSwitchCatalogUntouched",false],_uiPerfAfter getOrDefault ["lastKitSwitchEquipmentUntouched",false],_uiPerfAfter getOrDefault ["lastKitSwitchEquipmentCaptureDelta",-1],_uiPerfAfter getOrDefault ["lastKitSwitchTargetRefreshDelta",-1]];
};
_result
