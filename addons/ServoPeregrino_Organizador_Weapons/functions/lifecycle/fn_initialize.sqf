#include "..\..\script_version.hpp"
private _check = [] call ServoPeregrino_Organizador_Weapons_fnc_validateNexus;
if !(_check get "success") exitWith {_check};
private _old = missionNamespace getVariable [SP_ORG_WEAPONS_RUNTIME,createHashMap];
if (_old getOrDefault ["ready",false]) exitWith {[true,"WEAPONS_ALREADY_INITIALIZED","Runtime preservado."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _cap = ["weapons.runtime",1,"ServoPeregrino_Organizador_Weapons",createHashMapFromArray [
 ["ready",true],["entryPoint","ServoPeregrino_Organizador_Weapons_fnc_getRuntimeStatus"],
 ["build",SERVO_PEREGRINO_ORGANIZADOR_WEAPONS_BUILD],["identityGate","OPEN"],
 ["physicalIdentityProven",false],["models","INTERNAL_CANDIDATES"]
]] call ServoPeregrino_Organizador_Nexus_fnc_registerCapability;
if !(_cap get "success") exitWith {_cap};
missionNamespace setVariable [SP_ORG_WEAPONS_RUNTIME,createHashMapFromArray [
 ["ready",true],["status","FOUNDATION_IDENTITY_SPIKE_PENDING_RUNTIME_VALIDATION"],
 ["build",[] call ServoPeregrino_Organizador_Weapons_fnc_getBuildInfo],["physicalIdentityProven",false]
]];
// Authority is initialized lazily on the server, never reset by lifecycle retry.
["WEAPONS","INFO","WEAPONS_INITIALIZED - identity gate OPEN; SESSION candidate."] call ServoPeregrino_Organizador_Nexus_fnc_log;
[true,"WEAPONS_INITIALIZED","Foundation pronta; identidade fisica nao comprovada."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
