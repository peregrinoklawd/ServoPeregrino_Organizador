#include "..\..\script_version.hpp"
disableSerialization;
params [
    ["_action","",[""]],
    ["_source",controlNull,[controlNull]],
    ["_explicitValue",-1,[0]]
];
private _display=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR,displayNull];
if (isNull _display) exitWith {false};
private _actionU=toUpper _action;
private _payload=[];
private _view="";
if (!isNull _source) then {
    _payload=+(_source getVariable ["SPORG_Items_equipmentPayload",[]]);
    _view=_source getVariable ["SPORG_Items_equipmentView",""];
};
if ((count _payload) isNotEqualTo 5) then {
    private _list=_display displayCtrl 4120;
    private _row=lbCurSel _list;
    if (_row>=0) then {
        private _raw=_list lbData _row;
        if (_raw isNotEqualTo "") then {_payload=parseSimpleArray _raw;};
    };
};
private _state=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
if (_view isEqualTo "") then {_view=_state getOrDefault ["equipmentView","U"];};
if ((count _payload) isNotEqualTo 5) exitWith {
    ["Selecione um item do equipamento antes de usar estes controles.","WARN"] call ServoPeregrino_Organizador_Items_fnc_pushUIFeedback;
    false
};
_payload params ["_type","_className","_quantity","_mode","_states"];
private _needsConfirm=(_actionU isEqualTo "QUANTITY") && {_explicitValue isEqualTo 0};
if (_needsConfirm) exitWith {
    private _frozenPayload=+_payload;
    private _frozenView=_view;
    private _frozenValue=_explicitValue;
    private _frozenAction=_actionU;
    [_frozenPayload,_frozenView,_frozenAction,_frozenValue] spawn {
        params ["_payloadArg","_viewArg","_actionArg","_valueArg"];
        _payloadArg params ["_typeArg","_classArg","_qtyArg","_modeArg","_statesArg"];
        private _question=format ["Definir a quantidade de %1 como 0 e remover este item de %2?",_classArg,_viewArg];
        private _yes=[_question,"SP_ORG_Items — REMOVER ITEM",true,true] call BIS_fnc_guiMessage;
        if (_yes) then {
            [_payloadArg,_actionArg,_valueArg,_viewArg,"EQUIPMENT_QUANTITY_ZERO_CONFIRMED"] call ServoPeregrino_Organizador_Items_fnc_executeEquipmentRowAction;
        } else {
            ["Remoção cancelada.","INFO"] call ServoPeregrino_Organizador_Items_fnc_pushUIFeedback;
            [] call ServoPeregrino_Organizador_Items_fnc_refreshEquipmentSelectionControls;
        };
    };
    true
};
[_payload,_actionU,_explicitValue,_view,if (_actionU isEqualTo "DELETE") then {"EQUIPMENT_DELETE_DIRECT"} else {format ["EQUIPMENT_%1",_actionU]}] call ServoPeregrino_Organizador_Items_fnc_executeEquipmentRowAction;
true
