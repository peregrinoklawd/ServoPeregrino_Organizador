#include "..\..\script_version.hpp"
params [["_requestId","",[""]],["_success",false,[true]],["_code","UNKNOWN",[""]],["_message","",[""]],["_publicId","",[""]],["_revision",-1,[0]],["_created",false,[true]]];
if (!hasInterface) exitWith {};
if (isMultiplayer && {(!isRemoteExecuted) || {remoteExecutedOwner isNotEqualTo 2}}) exitWith {
    diag_log format ["[SP_ORG] [ITEMS] [PUBLIC_AUTHORITY] CLIENT_RESULT_REJECT requestId=%1 remoteOwner=%2",_requestId,remoteExecutedOwner];
};

private _pending=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_PENDING_VAR,createHashMap];
private _known=_pending getOrDefault [_requestId,createHashMap];
if ((count _known)>0) then {_pending deleteAt _requestId; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_PENDING_VAR,_pending];};

private _result=[_success,_code,_message,createHashMapFromArray [["requestId",_requestId],["publicId",_publicId],["revision",_revision],["created",_created],["authority","SERVER"],["scope","SESSION"]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult;
private _state=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
if ((count _state) isEqualTo 0) then {_state=[] call ServoPeregrino_Organizador_Items_fnc_createUIState;};
_state set ["kitLibraryActionStatus",if (_success) then {"PUBLICADO"} else {"FALHA"}];
_state set ["lastPublicRequestId",_requestId];
_state set ["lastPublicRequestRevision",_revision];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state];
[_result,true] call ServoPeregrino_Organizador_Items_fnc_presentUIResult;
if (!isNull (findDisplay SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD)) then {[] call ServoPeregrino_Organizador_Items_fnc_refreshInterface;};
diag_log format ["[SP_ORG] [ITEMS] [PUBLIC_AUTHORITY] CLIENT_RESULT requestId=%1 success=%2 code=%3 publicId=%4 revision=%5",_requestId,_success,_code,_publicId,_revision];
