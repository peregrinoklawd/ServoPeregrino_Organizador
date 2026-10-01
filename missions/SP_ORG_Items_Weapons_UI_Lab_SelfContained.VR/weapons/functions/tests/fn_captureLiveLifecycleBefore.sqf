#include "..\..\script_version.hpp"
params [["_unit",objNull,[objNull]],["_container",objNull,[objNull]]];

if (!isServer) exitWith {
 [false,"WEAPONS_SERVER_ONLY","Before snapshot is server-only."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if (isNull _unit || {isNull _container}) exitWith {
 [false,"WEAPONS_LIVE_TEST_TARGET_INVALID","Unit/container missing."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _state = missionNamespace getVariable [SP_ORG_WEAPONS_LIVE_TEST,createHashMap];
if (count _state isEqualTo 0) exitWith {
 [false,"WEAPONS_LIVE_TEST_NOT_READY","Live lifecycle test has not been initialized."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _phase = _state getOrDefault ["phase",""];
private _transfer = missionNamespace getVariable ["SP_ORG_Weapons_Box_TRANSFER",objNull];
private _duplicates = missionNamespace getVariable ["SP_ORG_Weapons_Box_DUPLICATES",objNull];

private _expectedContainer = switch (_phase) do {
 case "BC_TAKE": {_transfer};
 case "BC_PUT": {_transfer};
 case "E_TAKE": {_duplicates};
 default {objNull};
};

if (isNull _expectedContainer || {!(_container isEqualTo _expectedContainer)}) exitWith {
 [true,"WEAPONS_LIVE_TEST_OTHER_CONTAINER","Container is not part of the current manual step."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _snapshot = [_container] call ServoPeregrino_Organizador_Weapons_fnc_inspectWeaponCarrier;
if !(_snapshot get "success") exitWith {_snapshot};

_state set ["beforeObservations",[_snapshot get "data" get "observations"] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy];
_state set ["beforeCaptured",true];
_state set ["activeContainer",netId _container];

diag_log format [
 "[SP_ORG] [WEAPONS] [LIVE_BEFORE] phase=%1 container=%2 observations=%3",
 _phase,netId _container,_state get "beforeObservations"
];

[true,"WEAPONS_LIVE_BEFORE_CAPTURED","Before snapshot captured.",createHashMapFromArray [["phase",_phase],["observationCount",count (_state get "beforeObservations")]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
