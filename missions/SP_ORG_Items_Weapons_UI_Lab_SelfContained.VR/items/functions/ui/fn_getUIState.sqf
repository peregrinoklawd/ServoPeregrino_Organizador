#include "..\..\script_version.hpp"
private _state = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR, createHashMap];
if ((count _state) isEqualTo 0) then {_state = [] call ServoPeregrino_Organizador_Items_fnc_createUIState;};
[
    true, "ITEMS_UI_STATE_READY", "Estado de sessão da UI retornado por cópia defensiva.",
    createHashMapFromArray [["state", [_state] call ServoPeregrino_Organizador_Items_fnc_deepCopy]]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
