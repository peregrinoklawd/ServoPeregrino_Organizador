#include "..\..\script_version.hpp"
params [["_id","",[""]]];
if (isRemoteExecuted) exitWith {[false,"WEAPONS_REMOTE_EXEC_FORBIDDEN","Internal authority read is local-only; use a declared gateway."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
if (!isServer) exitWith {[false,"WEAPONS_SERVER_ONLY","Local server read only."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _init = [] call ServoPeregrino_Organizador_Weapons_fnc_initializeAuthority;
if !(_init get "success") exitWith {_init};
private _instances = (missionNamespace getVariable SP_ORG_WEAPONS_AUTHORITY) get "instances";
if !(_id in _instances) exitWith {[false,"WEAPONS_INSTANCE_NOT_FOUND","No automatic recovery/reissue."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
[true,"WEAPONS_INSTANCE_FOUND","Logical record only.",createHashMapFromArray [["instance",[_instances get _id] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
