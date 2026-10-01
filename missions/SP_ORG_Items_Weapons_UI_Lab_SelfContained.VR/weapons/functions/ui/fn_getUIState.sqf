#include "..\..\script_version.hpp"
private _state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
if ((count _state) isEqualTo 0) then {
 _state = [] call ServoPeregrino_Organizador_Weapons_fnc_createUIState;
};
[_state] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy
