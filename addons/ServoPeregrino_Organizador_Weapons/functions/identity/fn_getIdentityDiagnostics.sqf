#include "..\..\script_version.hpp"
if (isRemoteExecuted) exitWith {[false,"WEAPONS_REMOTE_EXEC_FORBIDDEN","Registry diagnostics are local-server only; use a declared gateway."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _init = [] call ServoPeregrino_Organizador_Weapons_fnc_initializeAuthority;
if !(_init get "success") exitWith {_init};
private _state = missionNamespace getVariable SP_ORG_WEAPONS_AUTHORITY;
private _data = createHashMapFromArray [
 ["scope","SESSION"],["authority","SERVER"],["identityGate","OPEN"],["physicalIdentityProven",false],
 ["instanceCount",count (_state get "instances")],["instances",[_state get "instances"] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
 ["references",[_state get "references"] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy]
];
[true,"WEAPONS_IDENTITY_DIAGNOSTICS","Registry records do not establish physical bindings.",_data] call ServoPeregrino_Organizador_Nexus_fnc_createResult
