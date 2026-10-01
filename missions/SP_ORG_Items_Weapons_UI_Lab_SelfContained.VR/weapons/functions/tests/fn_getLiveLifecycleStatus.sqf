#include "..\..\script_version.hpp"
private _state = missionNamespace getVariable [SP_ORG_WEAPONS_LIVE_TEST,createHashMap];
if (count _state isEqualTo 0) exitWith {
 [false,"WEAPONS_LIVE_TEST_NOT_READY","Live lifecycle test has not been initialized."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
[true,"WEAPONS_LIVE_TEST_STATUS","Current manual gate status.",createHashMapFromArray [["state",[_state] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
