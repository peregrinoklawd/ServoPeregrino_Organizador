#include "..\..\script_version.hpp"
disableSerialization;
private _perfStartedAt=diag_tickTime;
params [
    ["_result", createHashMap, [createHashMap]],
    ["_options", createHashMap, [createHashMap]]
];
private _display = uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR, displayNull];
if (isNull _display) exitWith {false};
private _state = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR, createHashMap];
if ((count _state) isEqualTo 0) then {_state = [] call ServoPeregrino_Organizador_Items_fnc_createUIState;};
_state set ["refreshing", true];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR, _state];

private _resultData = _result getOrDefault ["data", createHashMap];
private _uiCommand = _resultData getOrDefault ["uiCommand", createHashMap];
private _changedTarget = toUpper (_uiCommand getOrDefault ["target", _options getOrDefault ["target", ""]]);
if (_changedTarget isEqualTo "UNIFORM") then {_changedTarget = "U";};
if (_changedTarget isEqualTo "VEST") then {_changedTarget = "C";};
if (_changedTarget isEqualTo "BACKPACK") then {_changedTarget = "M";};
private _view = toUpper (_state getOrDefault ["equipmentView", "U"]);
private _refreshEquipment = (_changedTarget isEqualTo _view) || {_options getOrDefault ["forceEquipmentRefresh", false]};
private _captureDurationMs=0;
private _equipmentContentMass=_state getOrDefault ["lastEquipmentContentMass",0];
private _equipmentUnknownMassCount=_state getOrDefault ["lastEquipmentUnknownMassCount",0];
private _equipmentCapacity=_state getOrDefault ["lastEquipmentCapacity",createHashMapFromArray [["known",false],["maxLoad",0],["currentLoad",0],["availableLoad",-1]]];

if (_refreshEquipment) then {
    private _captureStartedAt=diag_tickTime;
    private _captureData = _options getOrDefault ["captureOverride", createHashMap];
    private _captureOk = (count _captureData) > 0;
    if (!_captureOk) then {
        private _cap = [player, _view] call ServoPeregrino_Organizador_Items_fnc_capturePlayerContainer;
        if (_cap getOrDefault ["success", false]) then {_captureData = _cap getOrDefault ["data", createHashMap]; _captureOk = true;};
    };
    private _rows = [];
    if (_captureOk) then {
        _equipmentCapacity=_captureData getOrDefault ["capacity",_equipmentCapacity];
        _equipmentContentMass=0; _equipmentUnknownMassCount=0;
        private _needle = toLower (_state getOrDefault ["equipmentQuery", ""]);
        {
            private _entry = _x;
            if (_entry isEqualType [] && {(count _entry) isEqualTo 6}) then {
                private _meta = [_entry#2] call ServoPeregrino_Organizador_Items_fnc_resolveUIItemMetadata;
                private _displayName = _meta getOrDefault ["displayName", _entry#2];
                private _aware=[_entry,_meta] call ServoPeregrino_Organizador_Items_fnc_getUIEntryAwareness;
                if (_aware getOrDefault ["known",false]) then {_equipmentContentMass=_equipmentContentMass+(_aware getOrDefault ["totalMass",0]);} else {_equipmentUnknownMassCount=_equipmentUnknownMassCount+1;};
                private _searchText = toLower (format ["%1 %2",_entry#2,_displayName]);
                if (_needle isEqualTo "" || {_searchText find _needle >= 0}) then {
                    _rows pushBack createHashMapFromArray [["type",_entry#1],["className",_entry#2],["quantity",_entry#3],["stateMode",_entry#4],["stateData",+(_entry#5)],["displayName",_displayName],["picture",_meta getOrDefault ["picture",""]],["massKnown",_aware getOrDefault ["known",false]],["unitMass",_aware getOrDefault ["unitMass",0]],["totalMass",_aware getOrDefault ["totalMass",0]]];
                };
            };
        } forEach (_captureData getOrDefault ["entries", []]);
    };
    [_rows,_view,_equipmentCapacity,_equipmentContentMass,_equipmentUnknownMassCount,if (_captureOk) then {"OK"} else {"INDISPONÍVEL"},"PHYSICAL_FOCUSED"] call ServoPeregrino_Organizador_Items_fnc_renderEquipmentRowsUI;
    (_display displayCtrl 4123) ctrlEnable _captureOk;
    _captureDurationMs=round ((diag_tickTime-_captureStartedAt)*1000);
};

private _readiness = _options getOrDefault ["readinessOverride", createHashMap];
if ((count _readiness) isEqualTo 0) then {
    private _rr = [player,_state getOrDefault ["applicationTarget","ANY"],""] call ServoPeregrino_Organizador_Items_fnc_getUIPhysicalReadiness;
    _readiness = _rr getOrDefault ["data",createHashMap];
};
private _physicalEnabled = _readiness getOrDefault ["physicalMutationEnabled",false];
private _physicalTarget = _readiness getOrDefault ["resolvedTarget","-"];
private _physicalCapacity=_readiness getOrDefault ["capacity",createHashMapFromArray [["known",false],["maxLoad",0],["currentLoad",0],["availableLoad",-1]]];
private _draftData = ([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap];
private _hasDraft = _draftData getOrDefault ["hasDraft",false];
private _physicalTargetLabel=[_physicalTarget] call ServoPeregrino_Organizador_Items_fnc_getUITargetLabel;
// D.6.2: refresh the Equipment drop zone from the visible Equipment View, independently from Kit applicationTarget.
private _equipmentReadyR=[player,_view,""] call ServoPeregrino_Organizador_Items_fnc_getUIPhysicalReadiness;
private _equipmentReady=_equipmentReadyR getOrDefault ["data",createHashMap];
private _equipmentEnabled=_equipmentReady getOrDefault ["physicalMutationEnabled",false];
private _equipmentResolved=_equipmentReady getOrDefault ["resolvedTarget",_view];
private _equipmentResolvedLabel=[_equipmentResolved] call ServoPeregrino_Organizador_Items_fnc_getUITargetLabel;
private _physicalDrop = _display displayCtrl 4113;
_physicalDrop ctrlEnable _equipmentEnabled;
_physicalDrop ctrlSetText (if (_equipmentEnabled) then {format ["ARRASTE ITENS PARA ADICIONAR A %1",_equipmentResolvedLabel]} else {"NÃO É POSSÍVEL ADICIONAR ITENS AQUI"});
_physicalDrop ctrlSetTooltip format ["Itens soltos neste painel são adicionados a %1, que é o equipamento selecionado em Mostrar.",_equipmentResolvedLabel];
_physicalDrop ctrlSetBackgroundColor (if (_equipmentEnabled) then {[0.24,0.13,0.03,0.42]} else {[0.10,0.08,0.07,0.25]});
_physicalDrop ctrlSetTextColor (if (_equipmentEnabled) then {[1,0.84,0.55,1]} else {[0.58,0.58,0.56,0.85]});
{(_display displayCtrl _x) ctrlEnable true;} forEach [2150,2151,2152,2153,4124];
(_display displayCtrl 2153) ctrlSetTooltip "Limpar somente o Kit Selecionado/Rascunho. Não altera o equipamento físico.";
(_display displayCtrl 4124) ctrlSetTooltip format ["Remover os itens gerenciáveis de %1, que é o equipamento mostrado agora. Armas e conteúdos reservados serão preservados.",[_view] call ServoPeregrino_Organizador_Items_fnc_getUITargetLabel];
[_display,_physicalEnabled,_physicalTarget,_view,_physicalCapacity] call ServoPeregrino_Organizador_Items_fnc_refreshHeaderStatusUI;

private _context = format ["Adicionar em: %1  •  Mostrando: %2  •  %3",_physicalTargetLabel,[_view] call ServoPeregrino_Organizador_Items_fnc_getUITargetLabel,if (_physicalCapacity getOrDefault ["known",false]) then {format ["Carga %1 / %2",[_physicalCapacity getOrDefault ["currentLoad",0],false,2] call ServoPeregrino_Organizador_Items_fnc_formatUIMass,[_physicalCapacity getOrDefault ["maxLoad",0],false,2] call ServoPeregrino_Organizador_Items_fnc_formatUIMass]} else {"Carga não disponível"}];
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
_state set ["physicalCommandEnabled",_physicalEnabled];
_state set ["resolvedPhysicalTarget",_physicalTarget];
_state set ["lastPhysicalCapacity",_physicalCapacity];
_state set ["equipmentViewCommandEnabled",_equipmentEnabled];
_state set ["resolvedEquipmentViewTarget",_equipmentResolved];
_state set ["lastEquipmentContentMass",_equipmentContentMass];
_state set ["lastEquipmentUnknownMassCount",_equipmentUnknownMassCount];
_state set ["lastEquipmentCapacity",_equipmentCapacity];
_state set ["lastRefreshTick",diag_tickTime];
_state set ["lastRefreshMode","PHYSICAL_FOCUSED"];
_state set ["focusedRefreshCount",(_state getOrDefault ["focusedRefreshCount",0])+1];
_state set ["lastFocusedRefreshTarget",_changedTarget];
private _perfDurationMs=round ((diag_tickTime-_perfStartedAt)*1000);
_state set ["lastPhysicalFocusedRefreshDurationMs",_perfDurationMs];
_state set ["lastPhysicalFocusedCaptureDurationMs",_captureDurationMs];
private _perf=+(_state getOrDefault ["uiPerfHistory",[]]);
_perf pushBack ["PHYSICAL_FOCUSED",_changedTarget,_perfDurationMs,_captureDurationMs,diag_tickTime];
while {(count _perf)>24} do {_perf deleteAt 0;};
_state set ["uiPerfHistory",_perf];
_state set ["refreshing",false];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state];
if (_state getOrDefault ["uiPerfTracing",true]) then {
    diag_log format ["[SP_ORG] [ITEMS] [UI_PERF] mode=PHYSICAL_FOCUSED target=%1 totalMs=%2 captureMs=%3 equipmentRefreshed=%4",_changedTarget,_perfDurationMs,_captureDurationMs,_refreshEquipment];
};
[player] call ServoPeregrino_Organizador_Items_fnc_refreshHeaderUI;
true
