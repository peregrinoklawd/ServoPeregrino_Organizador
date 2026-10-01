params [
 ["_unit",objNull,[objNull]],
 ["_operation","",[""]],
 ["_slot","PRIMARY",[""]],
 ["_target",objNull,[objNull]],
 ["_eventItem","",[""]]
];

if (!isMultiplayer && {isServer}) exitWith {
 [_unit,_operation,_slot,_target,_eventItem] call ServoPeregrino_Organizador_Weapons_fnc_serverHandleLabRequest
};

[_unit,_operation,_slot,_target,_eventItem] remoteExecCall [
 "ServoPeregrino_Organizador_Weapons_fnc_serverHandleLabRequest",
 2
];

[true,"WEAPONS_LAB_REQUEST_SENT","Multiplayer request sent to server."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
