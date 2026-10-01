#include "..\..\script_version.hpp"
disableSerialization;
params [["_options", createHashMap, [createHashMap]]];

private _display = uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR, displayNull];
if (isNull _display) exitWith {false};
private _state = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR, createHashMap];
if ((count _state) isEqualTo 0) then {_state = [] call ServoPeregrino_Organizador_Items_fnc_createUIState;};

private _readinessR = createHashMap;
private _readiness = _options getOrDefault ["readinessOverride", createHashMap];
if ((count _readiness) isEqualTo 0) then {
    _readinessR = [player, _state getOrDefault ["applicationTarget","ANY"], ""] call ServoPeregrino_Organizador_Items_fnc_getUIPhysicalReadiness;
    _readiness = _readinessR getOrDefault ["data", createHashMap];
};
private _enabled = _readiness getOrDefault ["physicalMutationEnabled", false];
private _resolved = _readiness getOrDefault ["resolvedTarget", "-"];
private _requested = _state getOrDefault ["applicationTarget", "ANY"];
private _view = _state getOrDefault ["equipmentView", "U"];
private _reason = if ((count _readinessR) > 0) then {_readinessR getOrDefault ["message",""]} else {_options getOrDefault ["readinessMessage",""]};
private _capacity=_readiness getOrDefault ["capacity",createHashMapFromArray [["known",false],["maxLoad",0],["currentLoad",0],["availableLoad",-1]]];
private _refreshReason = _options getOrDefault ["reason","TARGET_ONLY"];

// Application target highlight only. This refresh never recaptures Equipment and never mutates cargo.
{
    private _ctrl = _display displayCtrl (_x # 0);
    _ctrl ctrlSetBackgroundColor (if ((_x # 1) isEqualTo _requested) then {[0.08,0.38,0.30,0.76]} else {[0.08,0.11,0.12,0.58]});
} forEach [[2110,"ANY"],[2111,"U"],[2112,"C"],[2113,"M"]];

private _resolvedLabel=[_resolved] call ServoPeregrino_Organizador_Items_fnc_getUITargetLabel;
// Equipment drop zone has independent readiness derived from Mostrar (equipmentView).
private _equipmentReadinessR=[player,_view,""] call ServoPeregrino_Organizador_Items_fnc_getUIPhysicalReadiness;
private _equipmentReadiness=_equipmentReadinessR getOrDefault ["data",createHashMap];
private _equipmentEnabled=_equipmentReadiness getOrDefault ["physicalMutationEnabled",false];
private _equipmentResolved=_equipmentReadiness getOrDefault ["resolvedTarget",_view];
private _equipmentResolvedLabel=[_equipmentResolved] call ServoPeregrino_Organizador_Items_fnc_getUITargetLabel;
private _drop = _display displayCtrl 4113;
_drop ctrlEnable _equipmentEnabled;
_drop ctrlSetText (if (_equipmentEnabled) then {format ["ARRASTE ITENS PARA ADICIONAR A %1",_equipmentResolvedLabel]} else {"NÃO É POSSÍVEL ADICIONAR ITENS AQUI"});
_drop ctrlSetTooltip format ["Itens soltos neste painel são adicionados a %1, que é o equipamento selecionado em Mostrar.",_equipmentResolvedLabel];
_drop ctrlSetBackgroundColor (if (_equipmentEnabled) then {[0.24,0.13,0.03,0.42]} else {[0.10,0.08,0.07,0.25]});
_drop ctrlSetTextColor (if (_equipmentEnabled) then {[1,0.84,0.55,1]} else {[0.58,0.58,0.56,0.85]});

// APLICAR/REMOVER/SUBSTITUIR continuam clicáveis para explicar bloqueios físicos.
{
    private _ctrl = _display displayCtrl _x;
    _ctrl ctrlEnable true;
    _ctrl ctrlSetTooltip (switch _x do {
        case 2150: {if (_enabled) then {format ["Adicionar o Kit Selecionado a %1",_resolvedLabel]} else {"Não é possível adicionar o kit nesse destino agora. Clique para ver o motivo."}};
        case 2151: {if (_enabled) then {format ["Remover de %1 os itens presentes no Kit Selecionado",_resolvedLabel]} else {"Não é possível remover os itens desse destino agora. Clique para ver o motivo."}};
        default {if (_enabled) then {format ["Substituir os itens gerenciáveis de %1 pelo Kit Selecionado",_resolvedLabel]} else {"Não é possível substituir o conteúdo desse destino agora. Clique para ver o motivo."}};
    });
} forEach [2150,2151,2152];
private _draftClear=_display displayCtrl 2153; _draftClear ctrlEnable true; _draftClear ctrlSetTooltip "Remover todos os itens do Kit Selecionado. O equipamento do jogador não será alterado.";
private _viewLabel=[_view] call ServoPeregrino_Organizador_Items_fnc_getUITargetLabel;
private _equipmentClear=_display displayCtrl 4124; _equipmentClear ctrlEnable true; _equipmentClear ctrlSetTooltip format ["Remover os itens gerenciáveis de %1, que é o equipamento mostrado agora. Armas e conteúdos reservados serão preservados.",_viewLabel];

[_display,_enabled,_resolved,_view,_capacity] call ServoPeregrino_Organizador_Items_fnc_refreshHeaderStatusUI;
private _eqCtrl = _display displayCtrl 4120;
(_display displayCtrl 4122) ctrlSetStructuredText parseText format ["<t color='#B9DDD5'>Mostrando: %1 · %2 linha(s)</t>  <t color='#D0D7D5'>Arrastes neste painel serão adicionados ao equipamento mostrado.</t>",_viewLabel,lbSize _eqCtrl];

private _context = format ["Adicionar em: %1  •  Mostrando: %2  •  %3",_resolvedLabel,_viewLabel,if (_capacity getOrDefault ["known",false]) then {format ["Carga %1 / %2",[_capacity getOrDefault ["currentLoad",0],false,2] call ServoPeregrino_Organizador_Items_fnc_formatUIMass,[_capacity getOrDefault ["maxLoad",0],false,2] call ServoPeregrino_Organizador_Items_fnc_formatUIMass]} else {"Carga não disponível"}];
private _contextSafe = [_context] call ServoPeregrino_Organizador_Items_fnc_escapeStructuredText;
private _messageSafe = [_state getOrDefault ["temporaryMessage",""]] call ServoPeregrino_Organizador_Items_fnc_escapeStructuredText;
private _feedbackPalette=[_state getOrDefault ["lastFeedbackKind","INFO"]] call ServoPeregrino_Organizador_Items_fnc_getUIFeedbackPalette;
(_display displayCtrl 5000) ctrlSetStructuredText parseText format ["<t color='#6FCBB8'>CONTEXTO</t><t color='#A8C9C2'>  •  %1</t>",_contextSafe];
(_display displayCtrl 5001) ctrlSetStructuredText parseText format ["<t color='%1'>RESULTADO</t><t color='%2'>  •  %3</t>",_feedbackPalette getOrDefault ["labelColor","#7EC8FF"],_feedbackPalette getOrDefault ["messageColor","#D7EEFF"],_messageSafe];
private _hist = _state getOrDefault ["history",[]];
private _histText = "";
{private _entry=_x; _histText=_histText + (if (_histText isEqualTo "") then {""} else {"  |  "}) + format ["%1: %2",_entry#0,_entry#1];} forEach (_hist select [((count _hist)-3) max 0,(3 min (count _hist))]);
private _histSafe = [_histText] call ServoPeregrino_Organizador_Items_fnc_escapeStructuredText;
(_display displayCtrl 5002) ctrlSetStructuredText parseText format ["<t color='#81918E'>HISTÓRICO  •  %1</t>",_histSafe];

_state = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
_state set ["physicalMutationEnabled",false];
_state set ["physicalCommandEnabled",_enabled];
_state set ["resolvedPhysicalTarget",_resolved];
_state set ["lastPhysicalCapacity",_capacity];
_state set ["equipmentViewCommandEnabled",_equipmentEnabled];
_state set ["resolvedEquipmentViewTarget",_equipmentResolved];
_state set ["lastRefreshTick",diag_tickTime];
_state set ["lastRefreshMode","TARGET_ONLY"];
_state set ["targetRefreshCount",(_state getOrDefault ["targetRefreshCount",0])+1];
_state set ["refreshing",false];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state];

diag_log format ["[SP_ORG] [ITEMS] [PHYSICAL_FLOW] TARGET_REFRESH reason=%1 requested=%2 resolved=%3 view=%4 enabled=%5 noMutation=true",_refreshReason,_requested,_resolved,_view,_enabled];
[player] call ServoPeregrino_Organizador_Items_fnc_refreshHeaderUI;
true
