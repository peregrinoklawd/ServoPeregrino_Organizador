#include "..\..\script_version.hpp"
private _runtime = [missionNamespace getVariable [SP_ORG_WEAPONS_RUNTIME,createHashMap]] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
[_runtime getOrDefault ["ready",false],"WEAPONS_RUNTIME_STATUS","Status local.",_runtime] call ServoPeregrino_Organizador_Nexus_fnc_createResult
