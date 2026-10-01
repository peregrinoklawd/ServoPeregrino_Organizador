#include "..\..\script_version.hpp"
["UNLOAD"] call ServoPeregrino_Organizador_Items_fnc_cancelUIDrag;
["HIDE",controlNull] call ServoPeregrino_Organizador_Items_fnc_updateUIItemTooltip;
uiNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR,displayNull];
private _state=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]; if ((count _state)>0) then {_state set ["open",false]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state];};
true
