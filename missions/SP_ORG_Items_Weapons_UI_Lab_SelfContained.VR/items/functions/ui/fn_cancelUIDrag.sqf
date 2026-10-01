#include "..\..\script_version.hpp"
disableSerialization;
params [["_reason","CANCEL",[""]],["_expectedStartedAt",-1,[0]]];
private _state = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _drag = _state getOrDefault ["dragState",createHashMap];
private _wasActive = _drag getOrDefault ["active",false];
private _sameGesture = _expectedStartedAt < 0 || {(_drag getOrDefault ["startedAtTick",-2]) isEqualTo _expectedStartedAt};
if (_wasActive && {!_sameGesture}) exitWith {false};
if (_wasActive) then {
    _state set ["dragState",createHashMapFromArray [["active",false],["sourceType",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAG_NONE],["sourceIDC",-1],["sourceId",""],["sourcePayload",[]],["hasSourcePayload",false],["startedAtTick",-1],["cancelReason",_reason]]];
};
// C.7: pending display-pointer state must be cleared even when no drag reached ACTIVE.
_state set ["pointerDragCandidate",createHashMap];
_state set ["pointerDragTravel",0];
_state set ["pointerButtonDown",false];
_state set ["pointerCandidateTick",-1];
_state set ["dragHoverArea","OUTSIDE"];
_state set ["dragHoverDestination",""];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state];
private _display = uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR,displayNull];
if (!isNull _display) then {
    ["HIDE",createHashMap,_display,-1000,-1000,false] call ServoPeregrino_Organizador_Items_fnc_updateUIDragVisualProxy;

    private _draftPanel=_display displayCtrl SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAFT_PANEL_IDC;
    if (!isNull _draftPanel) then {_draftPanel ctrlSetBackgroundColor [0.015,0.02,0.022,0.44];};
    private _equipmentPanel=_display displayCtrl SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_EQUIPMENT_PANEL_IDC;
    if (!isNull _equipmentPanel) then {_equipmentPanel ctrlSetBackgroundColor [0.015,0.02,0.022,0.44];};
    private _draftDrop = _display displayCtrl 2103;
    if (!isNull _draftDrop) then {
        _draftDrop ctrlSetText "ARRASTE ITENS PARA ADICIONAR AO KIT";
        _draftDrop ctrlSetBackgroundColor [0.03,0.18,0.16,0.14];
        _draftDrop ctrlSetTextColor [0.48,0.69,0.64,0.72];
    };
    private _physicalDrop = _display displayCtrl 4113;
    if (!isNull _physicalDrop) then {
        private _view=_state getOrDefault ["equipmentView","U"];
        private _readyR = [player,_view,""] call ServoPeregrino_Organizador_Items_fnc_getUIPhysicalReadiness;
        private _rd = _readyR getOrDefault ["data",createHashMap];
        private _enabled = _rd getOrDefault ["physicalMutationEnabled",false];
        private _targetLabel=[_rd getOrDefault ["resolvedTarget",_view]] call ServoPeregrino_Organizador_Items_fnc_getUITargetLabel;
        _physicalDrop ctrlSetText (if (_enabled) then {format ["ARRASTE ITENS PARA ADICIONAR A %1",_targetLabel]} else {"NÃO É POSSÍVEL ADICIONAR ITENS AQUI"});
        _physicalDrop ctrlSetTooltip format ["Itens soltos neste painel são adicionados a %1, que é o equipamento selecionado em Mostrar.",_targetLabel];
        _physicalDrop ctrlSetBackgroundColor (if (_enabled) then {[0.24,0.13,0.03,0.42]} else {[0.10,0.08,0.07,0.25]});
        _physicalDrop ctrlSetTextColor (if (_enabled) then {[1,0.84,0.55,1]} else {[0.58,0.58,0.56,0.85]});
    };
};
_wasActive
