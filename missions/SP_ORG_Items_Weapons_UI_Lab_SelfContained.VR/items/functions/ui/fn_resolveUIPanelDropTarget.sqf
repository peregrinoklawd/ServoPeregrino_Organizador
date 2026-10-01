#include "..\..\script_version.hpp"
disableSerialization;
params [
    ["_pointerX",-1000,[0]],
    ["_pointerY",-1000,[0]],
    ["_sourceType","",[""]],
    ["_display",displayNull,[displayNull]],
    ["_useCurrentMouse",true,[true]]
];
if (isNull _display) then {_display=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR,displayNull];};
if (_useCurrentMouse) then {getMousePosition params ["_mx","_my"]; _pointerX=_mx; _pointerY=_my;};
private _source=toUpper _sourceType;
private _state=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _inside={params ["_p"]; _pointerX>=(_p#0) && {_pointerX<=((_p#0)+(_p#2))} && {_pointerY>=(_p#1)} && {_pointerY<=((_p#1)+(_p#3))}};

// C.7: these bounds are shared with items_dialog.hpp. Runtime uses getMousePosition, which is in UI coordinates.
private _draftBounds=[
    SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAFT_PANEL_X,
    SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAFT_PANEL_Y,
    SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAFT_PANEL_W,
    SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAFT_PANEL_H
];
private _equipmentBounds=[
    SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_EQUIPMENT_PANEL_X,
    SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_EQUIPMENT_PANEL_Y,
    SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_EQUIPMENT_PANEL_W,
    SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_EQUIPMENT_PANEL_H
];
private _insideDraft=[_draftBounds] call _inside;
private _insideEquipment=[_equipmentBounds] call _inside;
private _draftAllowed=_source in ["CATALOG","EQUIPMENT","KIT"];
private _physicalAllowed=_source in ["CATALOG","KIT","ENTRY"];
// D.6.2: this is the Equipment panel. Readiness follows its own selected view, not applicationTarget.
private _physicalReady=_state getOrDefault ["equipmentViewCommandEnabled",_state getOrDefault ["physicalCommandEnabled",false]];
private _area="OUTSIDE";
private _destination="";
private _reason="OUTSIDE";
if (_insideDraft) then {
    _area="DRAFT_PANEL";
    if (_draftAllowed) then {_destination="DRAFT"; _reason="ACCEPTED";} else {_reason="SOURCE_NOT_ALLOWED";};
} else {
    if (_insideEquipment) then {
        _area="EQUIPMENT_PANEL";
        if (!_physicalAllowed) then {_reason="SOURCE_NOT_ALLOWED";} else {
            if (_physicalReady) then {_destination="PHYSICAL"; _reason="ACCEPTED";} else {_reason="PHYSICAL_NOT_READY";};
        };
    };
};
createHashMapFromArray [
    ["area",_area],["destination",_destination],["reason",_reason],
    ["insideDraftPanel",_insideDraft],["insideEquipmentPanel",_insideEquipment],
    ["draftAllowed",_draftAllowed],["physicalAllowed",_physicalAllowed],["physicalReady",_physicalReady],
    ["pointerX",_pointerX],["pointerY",_pointerY],["coordinateSource",if (_useCurrentMouse) then {"GET_MOUSE_POSITION"} else {"EXPLICIT_UI"}],
    ["draftBounds",_draftBounds],["equipmentBounds",_equipmentBounds]
]
