disableSerialization;
params [["_display",displayNull,[displayNull]]];
if (isNull _display) exitWith {createHashMapFromArray [["profile","NONE"]]};

private _barH=0.027*safeZoneH;
private _iconH=0.014*safeZoneH;
private _iconW=_iconH*pixelW/pixelH;
private _clearH=0.020*safeZoneH;
private _clearW=_clearH*pixelW/pixelH;
private _pad=0.0035*safeZoneH*pixelW/pixelH;
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
 safeZoneX+0.117*safeZoneW,safeZoneY+0.0615*safeZoneH,0.061*safeZoneW] call _addSearch;

[2053,2050,2051,2052,
 safeZoneX+0.206*safeZoneW,safeZoneY+0.099*safeZoneH,0.228*safeZoneW,
 safeZoneX+0.362*safeZoneW,safeZoneY+0.0615*safeZoneH,0.072*safeZoneW] call _addSearch;

[3091,3090,3100,3101,
 safeZoneX+0.466*safeZoneW,safeZoneY+0.099*safeZoneH,0.310*safeZoneW,
 safeZoneX+0.573*safeZoneW,safeZoneY+0.0615*safeZoneH,0.203*safeZoneW] call _addSearch;

[4091,4090,4100,4101,
 safeZoneX+0.804*safeZoneW,safeZoneY+0.099*safeZoneH,0.174*safeZoneW,
 safeZoneX+0.905*safeZoneW,safeZoneY+0.0615*safeZoneH,0.073*safeZoneW] call _addSearch;

_layouts append [
 [1000,[safeZoneX+0.022*safeZoneW,safeZoneY+0.064*safeZoneH,0.118*safeZoneW,0.026*safeZoneH],[safeZoneX+0.022*safeZoneW,safeZoneY+0.064*safeZoneH,0.060*safeZoneW,0.026*safeZoneH]],
 [1107,[safeZoneX+0.142*safeZoneW,safeZoneY+0.061*safeZoneH,0.036*safeZoneW,0.030*safeZoneH],[safeZoneX+0.084*safeZoneW,safeZoneY+0.061*safeZoneH,0.030*safeZoneW,0.030*safeZoneH]],
 [2000,[safeZoneX+0.206*safeZoneW,safeZoneY+0.064*safeZoneH,0.073*safeZoneW,0.026*safeZoneH],[safeZoneX+0.206*safeZoneW,safeZoneY+0.064*safeZoneH,0.045*safeZoneW,0.026*safeZoneH]],
 [2001,[safeZoneX+0.281*safeZoneW,safeZoneY+0.061*safeZoneH,0.098*safeZoneW,0.030*safeZoneH],[safeZoneX+0.253*safeZoneW,safeZoneY+0.061*safeZoneH,0.066*safeZoneW,0.030*safeZoneH]],
 [2002,[safeZoneX+0.382*safeZoneW,safeZoneY+0.064*safeZoneH,0.056*safeZoneW,0.026*safeZoneH],[safeZoneX+0.321*safeZoneW,safeZoneY+0.064*safeZoneH,0.038*safeZoneW,0.026*safeZoneH]],
 [3000,[safeZoneX+0.466*safeZoneW,safeZoneY+0.064*safeZoneH,0.200*safeZoneW,0.026*safeZoneH],[safeZoneX+0.466*safeZoneW,safeZoneY+0.064*safeZoneH,0.100*safeZoneW,0.026*safeZoneH]],
 [4000,[safeZoneX+0.804*safeZoneW,safeZoneY+0.064*safeZoneH,0.174*safeZoneW,0.026*safeZoneH],[safeZoneX+0.804*safeZoneW,safeZoneY+0.064*safeZoneH,0.095*safeZoneW,0.026*safeZoneH]]
];

private _result=[_display,2.0,_layouts,"WEAPONS"] call ServoPeregrino_Organizador_UICommon_fnc_applyResponsiveControlLayout;
private _state=missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
_state set ["responsiveProfile",_result getOrDefault ["profile","NONE"]];
_state set ["responsiveResolution",_result getOrDefault ["resolution",[]]];
missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
_result
