#include "..\..\script_version.hpp"
params [["_operation","",[""]],["_requestId","",[""]],["_kit",[],[[]]],["_sourceKitId","",[""]]];

if (!isServer) exitWith {};
if (!isRemoteExecuted) exitWith {diag_log "[SP_ORG] [ITEMS] [PUBLIC_AUTHORITY] REJECT reason=NOT_REMOTE_EXECUTED";};
private _callerOwner=remoteExecutedOwner;
if (_callerOwner <= 2) exitWith {diag_log format ["[SP_ORG] [ITEMS] [PUBLIC_AUTHORITY] REJECT requestId=%1 reason=INVALID_REMOTE_OWNER owner=%2",_requestId,_callerOwner];};
private _callerIndex=allPlayers findIf {(owner _x) isEqualTo _callerOwner};
if (_callerIndex<0) exitWith {
    [_requestId,false,"ITEMS_PUBLIC_CALLER_NOT_PLAYER","O servidor não conseguiu associar a solicitação a um jogador.","",-1,false] remoteExecCall ["ServoPeregrino_Organizador_Items_fnc_clientReceivePublicLibraryResult",_callerOwner];
};
private _caller=allPlayers#_callerIndex;
private _authorName=name _caller; if (_authorName isEqualTo "") then {_authorName="Jogador";};
private _authorKey=getPlayerUID _caller; if (_authorKey isEqualTo "") then {_authorKey=format ["OWNER-%1",_callerOwner];};
private _op=toUpper _operation;
private _result=createHashMap;
if (_op isEqualTo "PUBLISH") then {
    _result=[_kit,_sourceKitId,_authorName,_authorKey,"PLAYER"] call ServoPeregrino_Organizador_Items_fnc_commitPublicKitSnapshotServer;
} else {
    _result=[false,"ITEMS_PUBLIC_OPERATION_UNSUPPORTED","Operação pública não suportada pelo servidor.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult;
};
private _data=_result getOrDefault ["data",createHashMap];
[_requestId,_result getOrDefault ["success",false],_result getOrDefault ["code","UNKNOWN"],_result getOrDefault ["message",""],_data getOrDefault ["publicId",""],_data getOrDefault ["revision",-1],_data getOrDefault ["created",false]] remoteExecCall ["ServoPeregrino_Organizador_Items_fnc_clientReceivePublicLibraryResult",_callerOwner];
diag_log format ["[SP_ORG] [ITEMS] [PUBLIC_AUTHORITY] REQUEST_DONE requestId=%1 owner=%2 player=%3 success=%4 code=%5",_requestId,_callerOwner,_authorName,_result getOrDefault ["success",false],_result getOrDefault ["code","UNKNOWN"]];
