#include "..\..\script_version.hpp"
disableSerialization;
params [
    ["_mode","MOVE",[""]],
    ["_sourceCtrl",controlNull,[controlNull]],
    ["_display",displayNull,[displayNull]]
];
private _modeU=toUpper _mode;
if (isNull _display) then {_display=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR,displayNull];};
private _tip=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_ITEM_TOOLTIP_CTRL_VAR,controlNull];
private _activeIDC=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_ITEM_TOOLTIP_SOURCE_IDC_VAR,-1];
private _state=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _drag=_state getOrDefault ["dragState",createHashMap];
private _dragActive=_drag getOrDefault ["active",false];

if (_dragActive && {_modeU in ["SHOW","MOVE","SYNC"]}) exitWith {
    ["HIDE",controlNull,_display] call ServoPeregrino_Organizador_Items_fnc_updateUIItemTooltip;
    false
};

// D.3: o próprio hit-test autoritativo do DnD resolve o item sob o ponteiro.
// Assim o tooltip não depende do tooltip nativo nem de o engine entregar MouseEnter à CT_CONTROLS_TABLE.
if (_modeU isEqualTo "SYNC") exitWith {
    if (isNull _display) exitWith {false};
    private _source=[_display,-1000,-1000,true] call ServoPeregrino_Organizador_Items_fnc_resolveUIPointerSource;
    if !(_source getOrDefault ["found",false]) exitWith {
        ["HIDE",controlNull,_display] call ServoPeregrino_Organizador_Items_fnc_updateUIItemTooltip;
        false
    };
    private _table=_display displayCtrl (_source getOrDefault ["sourceIDC",-1]);
    private _rowIndex=_source getOrDefault ["rowIndex",-1];
    private _hitIndex=_source getOrDefault ["hitControlIndex",-1];
    if (isNull _table || {_rowIndex<0} || {_hitIndex<0}) exitWith {
        ["HIDE",controlNull,_display] call ServoPeregrino_Organizador_Items_fnc_updateUIItemTooltip;
        false
    };
    private _controls=_table ctRowControls _rowIndex;
    private _hoverCtrl=_controls param [_hitIndex,controlNull,[controlNull]];
    if (isNull _hoverCtrl) exitWith {
        ["HIDE",controlNull,_display] call ServoPeregrino_Organizador_Items_fnc_updateUIItemTooltip;
        false
    };
    ["SHOW",_hoverCtrl,_display] call ServoPeregrino_Organizador_Items_fnc_updateUIItemTooltip
};

// Força cleanup quando chamado sem controle (drag start/unload) ou quando o mesmo controle abandona o hover.
if (_modeU isEqualTo "HIDE") exitWith {
    private _requestedIDC=if (isNull _sourceCtrl) then {-1} else {ctrlIDC _sourceCtrl};
    if (_requestedIDC>=0 && {_activeIDC>=0} && {_requestedIDC isNotEqualTo _activeIDC}) exitWith {true};
    if (!isNull _tip) then {ctrlDelete _tip;};
    uiNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_ITEM_TOOLTIP_CTRL_VAR,controlNull];
    uiNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_ITEM_TOOLTIP_SOURCE_IDC_VAR,-1];
    true
};

if (isNull _display) exitWith {false};
if !(_modeU in ["SHOW","MOVE"]) exitWith {false};
if (_modeU isEqualTo "SHOW" && {isNull _sourceCtrl}) exitWith {false};

if (_modeU isEqualTo "SHOW") then {
    private _title=_sourceCtrl getVariable ["SPORG_Items_tooltipTitle",""];
    private _lines=+(_sourceCtrl getVariable ["SPORG_Items_tooltipLines",[]]);
    private _picture=_sourceCtrl getVariable ["SPORG_Items_tooltipPicture",""];
    if (_title isEqualTo "" && {(count _lines) isEqualTo 0}) exitWith {
        ["HIDE",controlNull,_display] call ServoPeregrino_Organizador_Items_fnc_updateUIItemTooltip;
    };

    if (isNull _tip) then {
        _tip=_display ctrlCreate ["RscStructuredText",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_ITEM_TOOLTIP_RUNTIME_IDC];
        if (!isNull _tip) then {
            _tip ctrlEnable false;
            _tip ctrlSetBackgroundColor [0.012,0.026,0.028,0.58];
            _tip ctrlSetFade 0;
            _tip ctrlShow true;
            uiNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_ITEM_TOOLTIP_CTRL_VAR,_tip];
        };
    };
    if (isNull _tip) exitWith {};

    private _sourceIDC=ctrlIDC _sourceCtrl;
    // Reescreve o conteúdo apenas quando a origem muda; o movimento do mouse só reposiciona.
    if (_sourceIDC isNotEqualTo _activeIDC) then {
        private _safeTitle=[_title] call ServoPeregrino_Organizador_Items_fnc_escapeStructuredText;
        private _safeLines=[];
        {_safeLines pushBack ([_x] call ServoPeregrino_Organizador_Items_fnc_escapeStructuredText);} forEach _lines;
        private _body=_safeLines joinString "<br/>";
        private _imageMarkup=if (_picture isEqualTo "") then {""} else {format ["<img image='%1' size='1.30'/>  ",_picture]};
        private _markup=format ["<t size='0.92' color='#E7F3F0'>%1%2</t>%3",_imageMarkup,_safeTitle,if (_body isEqualTo "") then {""} else {format ["<br/><t size='0.78' color='#B7C8C4'>%1</t>",_body]}];
        _tip ctrlSetStructuredText parseText _markup;
        uiNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_ITEM_TOOLTIP_SOURCE_IDC_VAR,_sourceIDC];
        _activeIDC=_sourceIDC;
    };
};

_tip=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_ITEM_TOOLTIP_CTRL_VAR,controlNull];
if (isNull _tip) exitWith {false};
getMousePosition params ["_mx","_my"];
private _w=0.205*safeZoneW;
private _probeH=0.16*safeZoneH;
_tip ctrlSetPosition [_mx,_my,_w,_probeH];
_tip ctrlCommit 0;
private _h=((ctrlTextHeight _tip)+0.010*safeZoneH) max (0.045*safeZoneH);
_h=_h min (0.16*safeZoneH);
private _x=_mx+(12*pixelW);
private _y=_my+(14*pixelH);
private _maxX=safeZoneX+safeZoneW-_w-(2*pixelW);
private _maxY=safeZoneY+safeZoneH-_h-(2*pixelH);
_x=(_x max (safeZoneX+2*pixelW)) min _maxX;
_y=(_y max (safeZoneY+2*pixelH)) min _maxY;
_tip ctrlSetPosition [_x,_y,_w,_h];
_tip ctrlEnable false;
_tip ctrlSetFade 0;
_tip ctrlShow true;
_tip ctrlCommit 0;
true
