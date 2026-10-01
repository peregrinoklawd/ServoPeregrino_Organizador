#include "..\..\script_version.hpp"
params [
    ["_kit",[],[[]]],
    ["_sourceKitId","",[""]],
    ["_authorName","",[""]],
    ["_authorKey","",[""]],
    ["_sourceKind","PLAYER",[""]]
];

if (!isServer) exitWith {[false,"ITEMS_PUBLIC_SERVER_REQUIRED","Somente o servidor pode alterar a biblioteca pública.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
if (_sourceKitId isEqualTo "") exitWith {[false,"ITEMS_PUBLIC_SOURCE_ID_INVALID","Identificador do kit de origem está vazio.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
if (_authorKey isEqualTo "") exitWith {[false,"ITEMS_PUBLIC_AUTHOR_INVALID","Não foi possível identificar o autor da publicação.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};

private _valid=[_kit] call ServoPeregrino_Organizador_Items_fnc_validateItemKitSemantic;
if !(_valid getOrDefault ["success",false]) exitWith {[false,"ITEMS_PUBLIC_KIT_INVALID","O snapshot enviado ao servidor é inválido.",createHashMapFromArray [["validation",_valid]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
if !((_kit param [2,"",[""]]) isEqualTo _sourceKitId) exitWith {[false,"ITEMS_PUBLIC_SOURCE_MISMATCH","A identidade do snapshot não corresponde ao kit de origem informado.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};

[] call ServoPeregrino_Organizador_Items_fnc_initializePublicLibraryAuthority;
private _registry=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VAR,[SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_MAGIC,SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VERSION,0,[]]];
private _entries=+(_registry#3);
private _kind=toUpper _sourceKind; if !(_kind in ["PLAYER","SERVER"]) then {_kind="PLAYER";};
private _safeAuthorName=if (_authorName isEqualTo "") then {if (_kind isEqualTo "SERVER") then {"Servidor"} else {"Jogador"}} else {_authorName};
private _idx=_entries findIf {(_x isEqualType []) && {(count _x) isEqualTo 8} && {(_x#2) isEqualTo _sourceKitId} && {(_x#4) isEqualTo _authorKey}};
private _now=systemTimeUTC;
private _created=_idx<0;
private _publicId=if (_created) then {format ["sporg-public-%1-%2-%3",_authorKey,_sourceKitId,_registry#2]} else {(_entries#_idx)#0};
private _publishedAt=if (_created) then {+_now} else {+((_entries#_idx)#5)};
private _entry=[_publicId,_kind,_sourceKitId,_safeAuthorName,_authorKey,_publishedAt,+_now,[_kit] call ServoPeregrino_Organizador_Items_fnc_deepCopy];
if (_created) then {_entries pushBack _entry;} else {_entries set [_idx,_entry];};
_registry set [2,(_registry#2)+1];
_registry set [3,_entries];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VAR,_registry,true];

diag_log format ["[SP_ORG] [ITEMS] [PUBLIC_AUTHORITY] COMMIT publicId=%1 sourceKitId=%2 author=%3 authorKey=%4 kind=%5 created=%6 revision=%7 scope=SESSION",_publicId,_sourceKitId,_safeAuthorName,_authorKey,_kind,_created,_registry#2];
[true,if (_created) then {"ITEMS_PUBLIC_KIT_PUBLISHED"} else {"ITEMS_PUBLIC_KIT_UPDATED"},if (_created) then {"Kit publicado pelo servidor na biblioteca pública da sessão."} else {"Snapshot público atualizado pelo servidor."},createHashMapFromArray [["publicId",_publicId],["sourceKitId",_sourceKitId],["created",_created],["revision",_registry#2],["scope","SESSION"],["authority","SERVER"],["authoritative",true],["authorName",_safeAuthorName],["sourceKind",_kind]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
