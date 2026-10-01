#include "..\..\script_version.hpp"
disableSerialization;
params [["_options",createHashMap,[createHashMap]]];

private _startedAt=diag_tickTime;
private _display=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR,displayNull];
if (isNull _display) exitWith {false};
private _state=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
if ((count _state) isEqualTo 0) then {_state=[] call ServoPeregrino_Organizador_Items_fnc_createUIState;};
private _reason=toUpper (_options getOrDefault ["reason","EQUIPMENT_VIEW"]);
private _sameView=_options getOrDefault ["sameView",false];
private _view=toUpper (_state getOrDefault ["equipmentView","U"]);
_state set ["refreshing",true]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state];

private _eqCtrl=_display displayCtrl SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_EQUIPMENT_TABLE_IDC;
private _captureMs=0;
private _renderMs=0;
private _captureOk=true;
private _rowCount=_state getOrDefault ["equipmentRenderedRowCount",0];
private _captured=false;
private _contentMass=_state getOrDefault ["lastEquipmentContentMass",0];
private _unknownMassCount=_state getOrDefault ["lastEquipmentUnknownMassCount",0];
private _capacity=_state getOrDefault ["lastEquipmentCapacity",createHashMapFromArray [["known",false],["maxLoad",0],["currentLoad",0],["availableLoad",-1]]];

if (!_sameView) then {
    private _captureStartedAt=diag_tickTime;
    private _cap=[player,_view] call ServoPeregrino_Organizador_Items_fnc_capturePlayerContainer;
    _captureMs=round ((diag_tickTime-_captureStartedAt)*1000);
    _captureOk=_cap getOrDefault ["success",false];
    private _rows=[];
    if (_captureOk) then {
        private _cd=_cap getOrDefault ["data",createHashMap];
        _capacity=_cd getOrDefault ["capacity",_capacity];
        _contentMass=0; _unknownMassCount=0;
        private _needle=toLower (_state getOrDefault ["equipmentQuery",""]);
        {
            private _entry=_x;
            private _meta=[_entry#2] call ServoPeregrino_Organizador_Items_fnc_resolveUIItemMetadata;
            private _displayName=_meta getOrDefault ["displayName",_entry#2];
            private _aware=[_entry,_meta] call ServoPeregrino_Organizador_Items_fnc_getUIEntryAwareness;
            if (_aware getOrDefault ["known",false]) then {_contentMass=_contentMass+(_aware getOrDefault ["totalMass",0]);} else {_unknownMassCount=_unknownMassCount+1;};
            if (_needle isEqualTo "" || {(toLower format ["%1 %2",_entry#2,_displayName]) find _needle >= 0}) then {
                _rows pushBack createHashMapFromArray [["type",_entry#1],["className",_entry#2],["quantity",_entry#3],["stateMode",_entry#4],["stateData",+(_entry#5)],["displayName",_displayName],["picture",_meta getOrDefault ["picture",""]],["massKnown",_aware getOrDefault ["known",false]],["unitMass",_aware getOrDefault ["unitMass",0]],["totalMass",_aware getOrDefault ["totalMass",0]]];
            };
        } forEach (_cd getOrDefault ["entries",[]]);
    };
    private _renderStartedAt=diag_tickTime;
    private _renderR=[_rows,_view,_capacity,_contentMass,_unknownMassCount,if (_captureOk) then {"OK"} else {"INDISPONÍVEL"},_reason] call ServoPeregrino_Organizador_Items_fnc_renderEquipmentRowsUI;
    _rowCount=_renderR getOrDefault ["rowCount",count _rows];
    _renderMs=round ((diag_tickTime-_renderStartedAt)*1000);
    _captured=true;
};

{private _ctrl=_display displayCtrl (_x#0); _ctrl ctrlSetBackgroundColor (if ((_x#1) isEqualTo _view) then {[0.08,0.38,0.30,0.76]} else {[0.08,0.11,0.12,0.58]});} forEach [[4110,"U"],[4111,"C"],[4112,"M"]];
(_display displayCtrl 4123) ctrlEnable _captureOk;
private _viewLabel=[_view] call ServoPeregrino_Organizador_Items_fnc_getUITargetLabel;
(_display displayCtrl 4124) ctrlSetTooltip format ["Remover os itens gerenciáveis de %1, que é o equipamento mostrado agora. Armas e conteúdos reservados serão preservados.",_viewLabel];
// D.6.2: recalculate readiness for the equipment being shown; this does not depend on Kit applicationTarget.
private _equipmentReadyR=[player,_view,""] call ServoPeregrino_Organizador_Items_fnc_getUIPhysicalReadiness;
private _equipmentReady=_equipmentReadyR getOrDefault ["data",createHashMap];
private _equipmentEnabled=_equipmentReady getOrDefault ["physicalMutationEnabled",false];
private _equipmentResolved=_equipmentReady getOrDefault ["resolvedTarget",_view];
private _equipmentResolvedLabel=[_equipmentResolved] call ServoPeregrino_Organizador_Items_fnc_getUITargetLabel;
private _drop=_display displayCtrl 4113;
_drop ctrlEnable _equipmentEnabled;
_drop ctrlSetText (if (_equipmentEnabled) then {format ["ARRASTE ITENS PARA ADICIONAR A %1",_equipmentResolvedLabel]} else {"NÃO É POSSÍVEL ADICIONAR ITENS AQUI"});
_drop ctrlSetTooltip format ["Itens soltos neste painel são adicionados a %1, que é o equipamento selecionado em Mostrar.",_equipmentResolvedLabel];
_drop ctrlSetBackgroundColor (if (_equipmentEnabled) then {[0.24,0.13,0.03,0.42]} else {[0.10,0.08,0.07,0.25]});
_drop ctrlSetTextColor (if (_equipmentEnabled) then {[1,0.84,0.55,1]} else {[0.58,0.58,0.56,0.85]});
private _eqSearch=_display displayCtrl 4100;
if ((ctrlText _eqSearch) isNotEqualTo (_state getOrDefault ["equipmentQuery",""])) then {_eqSearch ctrlSetText (_state getOrDefault ["equipmentQuery",""]);};
private _resolved=_state getOrDefault ["resolvedPhysicalTarget","-"];
private _enabled=_state getOrDefault ["physicalCommandEnabled",false];
[_display,_enabled,_resolved,_view,_state getOrDefault ["lastPhysicalCapacity",createHashMap]] call ServoPeregrino_Organizador_Items_fnc_refreshHeaderStatusUI;

private _context=format ["Mostrando: %1  •  Adicionar em: %2  •  Conteúdo %3",_viewLabel,[_resolved] call ServoPeregrino_Organizador_Items_fnc_getUITargetLabel,if (_captured) then {"atualizado"} else {"já estava atualizado"}];
private _contextSafe=[_context] call ServoPeregrino_Organizador_Items_fnc_escapeStructuredText;
private _messageSafe=[_state getOrDefault ["temporaryMessage",""]] call ServoPeregrino_Organizador_Items_fnc_escapeStructuredText;
private _feedbackPalette=[_state getOrDefault ["lastFeedbackKind","INFO"]] call ServoPeregrino_Organizador_Items_fnc_getUIFeedbackPalette;
(_display displayCtrl 5000) ctrlSetStructuredText parseText format ["<t color='#6FCBB8'>CONTEXTO</t><t color='#A8C9C2'>  •  %1</t>",_contextSafe];
(_display displayCtrl 5001) ctrlSetStructuredText parseText format ["<t color='%1'>RESULTADO</t><t color='%2'>  •  %3</t>",_feedbackPalette getOrDefault ["labelColor","#7EC8FF"],_feedbackPalette getOrDefault ["messageColor","#D7EEFF"],_messageSafe];
private _hist=_state getOrDefault ["history",[]]; private _histText="";
{private _entry=_x; _histText=_histText + (if (_histText isEqualTo "") then {""} else {"  |  "}) + format ["%1: %2",_entry#0,_entry#1];} forEach (_hist select [((count _hist)-3) max 0,(3 min (count _hist))]);
private _histSafe=[_histText] call ServoPeregrino_Organizador_Items_fnc_escapeStructuredText;
(_display displayCtrl 5002) ctrlSetStructuredText parseText format ["<t color='#81918E'>HISTÓRICO  •  %1</t>",_histSafe];

private _totalMs=round ((diag_tickTime-_startedAt)*1000);
_state=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
_state set ["lastRefreshTick",diag_tickTime];
_state set ["lastRefreshMode","EQUIPMENT_FOCUSED"];
_state set ["equipmentFocusedRefreshCount",(_state getOrDefault ["equipmentFocusedRefreshCount",0])+1];
if (_captured) then {_state set ["equipmentCaptureCount",(_state getOrDefault ["equipmentCaptureCount",0])+1];};
_state set ["lastEquipmentFocusedRefreshDurationMs",_totalMs];
_state set ["lastEquipmentFocusedCaptureDurationMs",_captureMs];
_state set ["lastEquipmentFocusedRenderDurationMs",_renderMs];
_state set ["lastEquipmentFocusedCaptured",_captured];
_state set ["lastEquipmentContentMass",_contentMass];
_state set ["lastEquipmentUnknownMassCount",_unknownMassCount];
_state set ["lastEquipmentCapacity",_capacity];
_state set ["equipmentViewCommandEnabled",_equipmentEnabled];
_state set ["resolvedEquipmentViewTarget",_equipmentResolved];
private _perf=+(_state getOrDefault ["uiPerfHistory",[]]);
_perf pushBack ["EQUIPMENT_FOCUSED",_reason,_totalMs,_captureMs,_renderMs,_captured,diag_tickTime];
while {(count _perf)>24} do {_perf deleteAt 0;};
_state set ["uiPerfHistory",_perf];
_state set ["refreshing",false];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state];
if (_state getOrDefault ["uiPerfTracing",true]) then {
    diag_log format ["[SP_ORG] [ITEMS] [UI_PERF] mode=EQUIPMENT_FOCUSED reason=%1 view=%2 totalMs=%3 captureMs=%4 renderMs=%5 captured=%6 sameView=%7 rows=%8 fullRefresh=false catalogTouched=false",_reason,_view,_totalMs,_captureMs,_renderMs,_captured,_sameView,_rowCount];
};
[player] call ServoPeregrino_Organizador_Items_fnc_refreshHeaderUI;
true
