#include "..\..\script_version.hpp"
disableSerialization;
params [
    ["_mode","MOVE",[""]],
    ["_drag",createHashMap,[createHashMap]],
    ["_display",displayNull,[displayNull]],
    ["_pointerX",-1000,[0]],
    ["_pointerY",-1000,[0]],
    ["_useCurrentMouse",true,[true]]
];
if (isNull _display) then {_display=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR,displayNull];};
private _modeU=toUpper _mode;
private _ghost=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAG_GHOST_CTRL_VAR,controlNull];

// C.8.1: o ghost é realmente transitório. Não existe controle estático escondido no diálogo.
// DROP/CANCEL/UNLOAD destroem o controle runtime para que nenhuma superfície invisível sobreviva ao gesto.
if (_modeU isEqualTo "HIDE") exitWith {
    if (!isNull _ghost) then {
        diag_log format ["[SP_ORG] [ITEMS] [DND_GHOST] HIDE idc=%1 moves=%2",ctrlIDC _ghost,uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAG_GHOST_MOVE_COUNT_VAR,0]];
        ctrlDelete _ghost;
    };
    uiNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAG_GHOST_CTRL_VAR,controlNull];
    uiNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAG_GHOST_MOVE_COUNT_VAR,0];
    uiNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAG_GHOST_MOVE_LOGGED_VAR,false];
    uiNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAG_GHOST_SOURCE_KEY_VAR,""];
    true
};
if (isNull _display) exitWith {false};
if !(_drag getOrDefault ["active",false]) exitWith {false};

if (_useCurrentMouse) then {
    getMousePosition params ["_mx","_my"];
    _pointerX=_mx;
    _pointerY=_my;
};

// Criação tardia é intencional: o controle nasce depois das CT_CONTROLS_TABLE e, portanto,
// ocupa a camada visual superior do display sem alterar o hit-test das linhas.
private _created=false;
if (isNull _ghost) then {
    _ghost=_display ctrlCreate ["RscStructuredText",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAG_GHOST_RUNTIME_IDC];
    if (isNull _ghost) exitWith {
        diag_log "[SP_ORG] [ITEMS] [DND_GHOST] CREATE_FAILED class=RscStructuredText";
        false
    };
    _created=true;
    _ghost ctrlEnable false;
    _ghost ctrlSetBackgroundColor [0.012,0.030,0.032,0.72];
    _ghost ctrlSetFade 0;
    _ghost ctrlShow true;
    uiNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAG_GHOST_CTRL_VAR,_ghost];
    uiNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAG_GHOST_MOVE_COUNT_VAR,0];
    uiNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAG_GHOST_MOVE_LOGGED_VAR,false];
    diag_log format ["[SP_ORG] [ITEMS] [DND_GHOST] CREATE source=%1 sourceId=%2 idc=%3 pointerAuthority=%4",_drag getOrDefault ["sourceType",""],_drag getOrDefault ["sourceId",""],ctrlIDC _ghost,_drag getOrDefault ["pointerAuthority","LEGACY"]];
};

private _ghostH=0.043*safeZoneH;
private _ghostW=0.300*safeZoneH*pixelW/pixelH;
private _offX=14*pixelW;
private _offY=12*pixelH;
private _x=_pointerX+_offX;
private _y=_pointerY+_offY;
private _maxX=safeZoneX+safeZoneW-_ghostW-(2*pixelW);
private _maxY=safeZoneY+safeZoneH-_ghostH-(2*pixelH);
_x=(_x max (safeZoneX+2*pixelW)) min _maxX;
_y=(_y max (safeZoneY+2*pixelH)) min _maxY;

private _picture=_drag getOrDefault ["sourcePicture",""];
private _label=_drag getOrDefault ["sourceText",_drag getOrDefault ["sourceId",""]];
if (_label isEqualTo "") then {_label=_drag getOrDefault ["sourceId","Item"]};
if ((count _label)>54) then {_label=(_label select [0,51])+"...";};
private _source=_drag getOrDefault ["sourceType",""];
private _sourceKey=format ["%1|%2|%3|%4",_source,_drag getOrDefault ["sourceId",""],_label,_picture];
private _lastSourceKey=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAG_GHOST_SOURCE_KEY_VAR,""];
if (_created || {_modeU isEqualTo "SHOW"} || {_sourceKey isNotEqualTo _lastSourceKey}) then {
    private _safeLabel=[_label] call ServoPeregrino_Organizador_Items_fnc_escapeStructuredText;
    private _imageMarkup=if (_picture isEqualTo "") then {""} else {format ["<img image='%1' size='1.35'/>  ",_picture]};
    private _markup=format ["<t size='0.94' color='#E1F0ED' valign='middle'>%1%2</t> ",_imageMarkup,_safeLabel];
    _ghost ctrlSetStructuredText parseText _markup;
    uiNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAG_GHOST_SOURCE_KEY_VAR,_sourceKey];
};
_ghost ctrlSetPosition [_x,_y,_ghostW,_ghostH];
_ghost ctrlSetFade 0;
_ghost ctrlEnable false;
_ghost ctrlShow true;
_ghost ctrlCommit 0;

private _moveCount=(uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAG_GHOST_MOVE_COUNT_VAR,0])+1;
uiNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAG_GHOST_MOVE_COUNT_VAR,_moveCount];
private _moveLogged=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAG_GHOST_MOVE_LOGGED_VAR,false];
if (!_moveLogged && {!_created}) then {
    uiNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAG_GHOST_MOVE_LOGGED_VAR,true];
    diag_log format ["[SP_ORG] [ITEMS] [DND_GHOST] MOVE_FIRST x=%1 y=%2 source=%3",_x,_y,_source];
};
true
