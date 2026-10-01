#include "..\..\script_version.hpp"
params [["_kit",[],[[]]],["_sourceKitId","",[""]]];
if (isServer) exitWith {[false,"ITEMS_PUBLIC_REQUEST_NOT_REQUIRED","O servidor não precisa usar a fila remota de publicação.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
if (!isMultiplayer) exitWith {[false,"ITEMS_PUBLIC_REQUEST_MP_ONLY","Request remoto de publicação é exclusivo do multiplayer cliente.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _valid=[_kit] call ServoPeregrino_Organizador_Items_fnc_validateItemKitSemantic;
if !(_valid getOrDefault ["success",false]) exitWith {_valid};
if (_sourceKitId isEqualTo "" || {!((_kit param [2,"",[""]]) isEqualTo _sourceKitId)}) exitWith {[false,"ITEMS_PUBLIC_SOURCE_MISMATCH","A identidade do snapshot não corresponde à origem local.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};

private _seq=(missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_REQUEST_COUNTER_VAR,0])+1;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_REQUEST_COUNTER_VAR,_seq];
private _requestId=format ["sporg-pubreq-%1-%2",clientOwner,_seq];
private _pending=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_PENDING_VAR,createHashMap];
_pending set [_requestId,createHashMapFromArray [["sourceKitId",_sourceKitId],["createdAtTick",diag_tickTime],["status","SENT"]]];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_PENDING_VAR,_pending];

["PUBLISH",_requestId,[_kit] call ServoPeregrino_Organizador_Items_fnc_deepCopy,_sourceKitId] remoteExecCall ["ServoPeregrino_Organizador_Items_fnc_serverHandlePublicLibraryRequest",2];
diag_log format ["[SP_ORG] [ITEMS] [PUBLIC_AUTHORITY] REQUEST_SEND requestId=%1 sourceKitId=%2 owner=%3",_requestId,_sourceKitId,clientOwner];
[true,"ITEMS_PUBLIC_PUBLISH_REQUESTED","Solicitação de publicação enviada ao servidor.",createHashMapFromArray [["pending",true],["requestId",_requestId],["sourceKitId",_sourceKitId],["authority","SERVER"],["scope","SESSION"]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
