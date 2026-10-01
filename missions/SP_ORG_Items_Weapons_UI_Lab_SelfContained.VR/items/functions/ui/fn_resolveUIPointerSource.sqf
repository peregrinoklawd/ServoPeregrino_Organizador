#include "..\..\script_version.hpp"
disableSerialization;
params [
    ["_display",displayNull,[displayNull]],
    ["_pointerX",-1000,[0]],
    ["_pointerY",-1000,[0]],
    ["_useCurrentMouse",true,[true]]
];
if (isNull _display) then {_display=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR,displayNull];};
if (_useCurrentMouse) then {getMousePosition params ["_mx","_my"]; _pointerX=_mx; _pointerY=_my;};

private _none=createHashMapFromArray [
    ["found",false],["sourceType",""],["sourceIDC",-1],["sourceId",""],["sourcePayload",[]],["sourceText",""],["sourcePicture",""],
    ["rowIndex",-1],["hitControlIndex",-1],["pointerX",_pointerX],["pointerY",_pointerY]
];
if (isNull _display) exitWith {_none};

private _inside={
    params ["_x","_y","_p"];
    (count _p)>=4 && {_x>=(_p#0)} && {_x<=((_p#0)+(_p#2))} && {_y>=(_p#1)} && {_y<=((_p#1)+(_p#3))}
};
private _absoluteChildRect={
    params ["_table","_child"];
    if (isNull _table || {isNull _child}) exitWith {[]};
    private _tp=ctrlPosition _table;
    private _cp=ctrlPosition _child; // CT_CONTROLS_TABLE row controls are relative to the table.
    if ((count _tp)<4 || {(count _cp)<4}) exitWith {[]};
    [(_tp#0)+(_cp#0),(_tp#1)+(_cp#1),_cp#2,_cp#3]
};

private _probeTable={
    params ["_tableIDC","_sourceType","_pictureIndex","_nameIndex"];
    private _table=_display displayCtrl _tableIDC;
    if (isNull _table) exitWith {createHashMap};
    private _tp=ctrlPosition _table;
    if !([_pointerX,_pointerY,_tp] call _inside) exitWith {createHashMap};
    private _result=createHashMap;
    private _rowCount=ctRowCount _table;
    if (_rowCount <= 0) exitWith {_result};
    for "_ri" from 0 to (_rowCount-1) do {
        private _controls=_table ctRowControls _ri;
        if ((count _controls)>_nameIndex) then {
            private _hit=-1;
            {
                private _ctrl=_controls param [_x,controlNull,[controlNull]];
                private _rect=[_table,_ctrl] call _absoluteChildRect;
                if ([_pointerX,_pointerY,_rect] call _inside) exitWith {_hit=_x;};
            } forEach [_pictureIndex,_nameIndex];
            if (_hit>=0) exitWith {
                private _sourceCtrl=_controls#_hit;
                private _pictureCtrl=_controls param [_pictureIndex,controlNull,[controlNull]];
                private _sourcePicture=if (isNull _pictureCtrl) then {""} else {ctrlText _pictureCtrl};
                private _sourceId="";
                private _payload=[];
                private _text="";
                switch (_sourceType) do {
                    case "CATALOG": {
                        _sourceId=_sourceCtrl getVariable ["SPORG_Items_catalogClass",""];
                        _payload=_sourceId;
                        _text=_sourceCtrl getVariable ["SPORG_Items_catalogDisplayName",_sourceId];
                    };
                    case "EQUIPMENT": {
                        _payload=+(_sourceCtrl getVariable ["SPORG_Items_equipmentPayload",[]]);
                        _sourceId=str _payload;
                        _text=_sourceCtrl getVariable ["SPORG_Items_equipmentDisplayName",""];
                    };
                    case "ENTRY": {
                        _payload=+(_sourceCtrl getVariable ["SPORG_Items_draftEntry",[]]);
                        _sourceId=if ((count _payload)>=3) then {_payload#2} else {""};
                        _text=_sourceCtrl getVariable ["SPORG_Items_draftDisplayName",_sourceId];
                    };
                };
                private _valid=switch (_sourceType) do {
                    case "CATALOG": {_sourceId isNotEqualTo ""};
                    case "EQUIPMENT": {(count _payload) isEqualTo 5};
                    case "ENTRY": {(count _payload) isEqualTo 6};
                    default {false};
                };
                if (_valid) then {
                    _result=createHashMapFromArray [
                        ["found",true],["sourceType",_sourceType],["sourceIDC",_tableIDC],["sourceId",_sourceId],
                        ["sourcePayload",_payload],["sourceText",_text],["sourcePicture",_sourcePicture],["rowIndex",_ri],["hitControlIndex",_hit],
                        ["pointerX",_pointerX],["pointerY",_pointerY]
                    ];
                };
            };
        };
    };
    _result
};

// Only Picture/Name are drag handles. Buttons and edit fields are intentionally never probed.
private _result=[SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_TABLE_IDC,"CATALOG",2,3] call _probeTable;
if ((count _result)>0) exitWith {_result};
_result=[SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_EQUIPMENT_TABLE_IDC,"EQUIPMENT",2,3] call _probeTable;
if ((count _result)>0) exitWith {_result};
_result=[SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAFT_TABLE_IDC,"ENTRY",1,2] call _probeTable;
if ((count _result)>0) exitWith {_result};
_none
