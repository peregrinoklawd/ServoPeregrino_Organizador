#include "..\..\script_version.hpp"
if (isRemoteExecuted) exitWith {[false,"WEAPONS_REMOTE_EXEC_FORBIDDEN","Internal authority function is local-only; use a declared gateway."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
if (!isServer) exitWith {[false,"WEAPONS_SERVER_ONLY","Local server authority required."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _state = missionNamespace getVariable [SP_ORG_WEAPONS_AUTHORITY,createHashMap];
if (count _state > 0) exitWith {[true,"WEAPONS_AUTHORITY_READY","Existing session preserved."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _nonce = [];
for "_i" from 1 to 8 do {_nonce pushBack ((floor random 1000000) toFixed 0)};
private _session = ((systemTimeUTC apply {str _x}) joinString "-") + "-" + (_nonce joinString "-");
missionNamespace setVariable [SP_ORG_WEAPONS_AUTHORITY,createHashMapFromArray [
 ["session",_session],["counter",0],["instances",createHashMap],["references",createHashMap],["requests",createHashMap]
]];
[true,"WEAPONS_AUTHORITY_READY","SESSION authority initialized."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
