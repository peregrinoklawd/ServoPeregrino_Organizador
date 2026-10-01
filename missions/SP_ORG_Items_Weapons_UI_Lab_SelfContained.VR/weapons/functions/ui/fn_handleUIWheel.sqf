#include "..\..\script_version.hpp"
disableSerialization;
params ["_displayOrControl",["_scroll",0,[0]]];

private _display = findDisplay SP_ORG_WEAPONS_UI_DISPLAY_IDD;
if (isNull _display) exitWith {false};

private _state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
_state set ["wheelConsumeCount",(_state getOrDefault ["wheelConsumeCount",0]) + 1];

getMousePosition params ["_mx","_my"];
private _catalogCtrl = _display displayCtrl 3120;
private _sliderCtrl = _display displayCtrl 3124;
private _overCatalog = false;
{
 if (!isNull _x) then {
  private _p = ctrlPosition _x;
  if (_mx >= (_p#0) && {_mx <= ((_p#0)+(_p#2))} && {_my >= (_p#1)} && {_my <= ((_p#1)+(_p#3))}) exitWith {
   _overCatalog = true;
  };
 };
} forEach [_catalogCtrl,_sliderCtrl];

if (_overCatalog && {_scroll isNotEqualTo 0}) then {
 private _delta = if (_scroll > 0) then {-6} else {6};
 ["CATALOG_SCROLL",_delta] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
 _state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
 _state set ["wheelCatalogScrollCount",(_state getOrDefault ["wheelCatalogScrollCount",0]) + 1];
};

missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
// Consume the wheel while the organizer is open, matching Items and preventing
// the vanilla action menu from reacting underneath the dialog.
true
