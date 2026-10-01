params [
 ["_unit",objNull,[objNull]],
 ["_operation","",[""]],
 ["_slot","PRIMARY",[""]],
 ["_target",objNull,[objNull]],
 ["_eventItem","",[""]]
];

if (!isServer) exitWith {};
if (isMultiplayer && {!isRemoteExecuted}) exitWith {};
if (isNull _unit || {isPlayer _unit && {owner _unit != remoteExecutedOwner} && {isMultiplayer}}) exitWith {};

private _result = createHashMap;
switch (toUpperANSI _operation) do {
 case "CAPTURE": {_result = [_unit,_slot] call ServoPeregrino_Organizador_Weapons_fnc_captureWeaponConfiguration};
 case "INSPECT_TARGET": {_result = [_target] call ServoPeregrino_Organizador_Weapons_fnc_inspectWeaponCarrier};
 case "LIVE_BEFORE": {_result = [_unit,_target] call ServoPeregrino_Organizador_Weapons_fnc_captureLiveLifecycleBefore};
 case "LIVE_AFTER": {_result = [_unit,_eventItem] call ServoPeregrino_Organizador_Weapons_fnc_handleLiveLifecycleEvent};
 case "LIVE_RESET": {_result = [] call ServoPeregrino_Organizador_Weapons_fnc_resetLiveLifecycleTest};
 case "LIVE_STATUS": {_result = [] call ServoPeregrino_Organizador_Weapons_fnc_getLiveLifecycleStatus};
 default {_result = [false,"WEAPONS_LAB_OPERATION_UNKNOWN","Unknown lab operation."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
};

private _summary = format ["[SP_ORG] [WEAPONS] [LAB_RESULT] op=%1 success=%2 code=%3 message=%4",toUpperANSI _operation,_result getOrDefault ["success",false],_result getOrDefault ["code",""],_result getOrDefault ["message",""]];
diag_log _summary;
if (hasInterface && {!isMultiplayer}) then {hint _summary};
if (isMultiplayer && {isRemoteExecuted}) then {[_summary] remoteExecCall ["ServoPeregrino_Organizador_Weapons_fnc_clientReceiveLabResult",remoteExecutedOwner]};
_result
