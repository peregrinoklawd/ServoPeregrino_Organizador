#include "..\..\script_version.hpp"
disableSerialization;
params [["_display",displayNull,[displayNull]]];
if (isNull _display) exitWith {createHashMapFromArray [["profile","NONE"]]};

private _barH=SPORG_UICOMMON_UI_SEARCH_BAR_H;
private _iconH=SPORG_UICOMMON_UI_SEARCH_ICON_H;
private _iconW=SPORG_UICOMMON_UI_SEARCH_ICON_W;
private _clearH=SPORG_UICOMMON_UI_SEARCH_CLEAR_H;
private _clearW=SPORG_UICOMMON_UI_SEARCH_CLEAR_W;
private _pad=SPORG_UICOMMON_UI_SEARCH_PAD_W;
private _layouts=[];

private _addSearch={
 params ["_bg","_icon","_edit","_clear","_sx","_sy","_sw","_wx","_wy","_ww"];
 _layouts append [
  [_bg,[_sx,_sy,_sw,_barH],[_wx,_wy,_ww,_barH]],
  [_icon,[_sx+_pad,_sy+0.0065*safeZoneH,_iconW,_iconH],[_wx+_pad,_wy+0.0065*safeZoneH,_iconW,_iconH]],
  [_edit,[_sx+_pad+_iconW+_pad,_sy,_sw-_iconW-_clearW-(4*_pad),_barH],[_wx+_pad+_iconW+_pad,_wy,_ww-_iconW-_clearW-(4*_pad),_barH]],
  [_clear,[_sx+_sw-_clearW-_pad,_sy+0.0035*safeZoneH,_clearW,_clearH],[_wx+_ww-_clearW-_pad,_wy+0.0035*safeZoneH,_clearW,_clearH]]
 ];
};

[1091,1090,1100,1101,
 safeZoneX+0.022*safeZoneW,safeZoneY+0.099*safeZoneH,0.156*safeZoneW,
 safeZoneX+0.116*safeZoneW,safeZoneY+0.0615*safeZoneH,0.062*safeZoneW] call _addSearch;

[2091,2090,2101,2102,
 safeZoneX+0.206*safeZoneW,safeZoneY+0.099*safeZoneH,0.228*safeZoneW,
 safeZoneX+0.362*safeZoneW,safeZoneY+0.0615*safeZoneH,0.072*safeZoneW] call _addSearch;

[3091,3090,3100,3101,
 safeZoneX+0.466*safeZoneW,safeZoneY+0.099*safeZoneH,0.310*safeZoneW,
 safeZoneX+0.573*safeZoneW,safeZoneY+0.0615*safeZoneH,0.203*safeZoneW] call _addSearch;

[4091,4090,4100,4101,
 safeZoneX+0.804*safeZoneW,safeZoneY+0.099*safeZoneH,0.164*safeZoneW,
 safeZoneX+0.905*safeZoneW,safeZoneY+0.0615*safeZoneH,0.063*safeZoneW] call _addSearch;

_layouts append [
 [1000,[safeZoneX+0.022*safeZoneW,safeZoneY+0.064*safeZoneH,0.100*safeZoneW,0.026*safeZoneH],[safeZoneX+0.022*safeZoneW,safeZoneY+0.064*safeZoneH,0.065*safeZoneW,0.026*safeZoneH]],
 [1001,[safeZoneX+0.126*safeZoneW,safeZoneY+0.064*safeZoneH,0.052*safeZoneW,0.026*safeZoneH],[safeZoneX+0.090*safeZoneW,safeZoneY+0.064*safeZoneH,0.023*safeZoneW,0.026*safeZoneH]],
 [2000,[safeZoneX+0.206*safeZoneW,safeZoneY+0.064*safeZoneH,0.074*safeZoneW,0.026*safeZoneH],[safeZoneX+0.206*safeZoneW,safeZoneY+0.064*safeZoneH,0.045*safeZoneW,0.026*safeZoneH]],
 [2100,[safeZoneX+0.283*safeZoneW,safeZoneY+0.062*safeZoneH,0.096*safeZoneW,0.030*safeZoneH],[safeZoneX+0.253*safeZoneW,safeZoneY+0.061*safeZoneH,0.066*safeZoneW,0.030*safeZoneH]],
 [2001,[safeZoneX+0.382*safeZoneW,safeZoneY+0.064*safeZoneH,0.052*safeZoneW,0.026*safeZoneH],[safeZoneX+0.321*safeZoneW,safeZoneY+0.064*safeZoneH,0.038*safeZoneW,0.026*safeZoneH]],
 [3000,[safeZoneX+0.466*safeZoneW,safeZoneY+0.064*safeZoneH,0.200*safeZoneW,0.026*safeZoneH],[safeZoneX+0.466*safeZoneW,safeZoneY+0.064*safeZoneH,0.100*safeZoneW,0.026*safeZoneH]],
 [4000,[safeZoneX+0.804*safeZoneW,safeZoneY+0.064*safeZoneH,0.170*safeZoneW,0.026*safeZoneH],[safeZoneX+0.804*safeZoneW,safeZoneY+0.064*safeZoneH,0.095*safeZoneW,0.026*safeZoneH]]
];

private _result=[_display,2.0,_layouts,"ITEMS"] call ServoPeregrino_Organizador_UICommon_fnc_applyResponsiveControlLayout;
private _state=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
_state set ["responsiveProfile",_result getOrDefault ["profile","NONE"]];
_state set ["responsiveResolution",_result getOrDefault ["resolution",[]]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state];
_result
