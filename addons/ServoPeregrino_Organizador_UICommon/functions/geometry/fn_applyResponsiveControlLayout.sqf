disableSerialization;
params [["_display",displayNull,[displayNull]],["_wideAspect",2.0,[0]],["_layouts",[],[[]]],["_tag","UI",[""]]];
if (isNull _display) exitWith {createHashMapFromArray [["profile","NONE"],["aspect",0],["resolution",getResolution]]};
private _res=getResolution; private _w=if ((count _res)>0) then {_res#0} else {0}; private _h=if ((count _res)>1) then {_res#1} else {1};
private _aspect=if (_h>0) then {_w/_h} else {1}; private _wide=_aspect>=_wideAspect; private _profile=if (_wide) then {"WIDE"} else {"STANDARD"};
{_x params [["_idc",-1,[0]],["_standard",[],[[]]],["_widePos",[],[[]]]]; private _ctrl=_display displayCtrl _idc; if (!isNull _ctrl) then {private _pos=if (_wide) then {_widePos} else {_standard}; if ((count _pos) isEqualTo 4) then {_ctrl ctrlSetPosition _pos; _ctrl ctrlCommit 0;};};} forEach _layouts;
diag_log format ["[SP_ORG] [UICOMMON] [RESPONSIVE] tag=%1 profile=%2 resolution=%3 aspect=%4 threshold=%5",_tag,_profile,_res,_aspect,_wideAspect];
createHashMapFromArray [["profile",_profile],["aspect",_aspect],["resolution",_res]]
