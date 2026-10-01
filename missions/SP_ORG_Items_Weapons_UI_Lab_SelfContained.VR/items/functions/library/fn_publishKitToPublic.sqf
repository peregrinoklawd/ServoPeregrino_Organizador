#include "..\..\script_version.hpp"
params [["_kitId","",[""]],["_unit",objNull,[objNull]],["_sourceKind","PLAYER",[""]],["_authorNameOverride","",[""]],["_authorKeyOverride","",[""]]];
private _get=[_kitId] call ServoPeregrino_Organizador_Items_fnc_getKit;
if !(_get getOrDefault ["success",false]) exitWith {_get};
private _kit=((_get getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]]);
private _kind=toUpper _sourceKind; if !(_kind in ["PLAYER","SERVER"]) then {_kind="PLAYER";};

// scope=SESSION permanece nesta etapa. 0.13-A altera autoridade, não persistência/JIP.
if (isMultiplayer && {!isServer}) exitWith {
    [_kit,_kitId] call ServoPeregrino_Organizador_Items_fnc_requestPublicKitPublish
};

// Servidor/SP preserva o entry point síncrono usado desde D.7.0. Overrides existem apenas para fixtures/server-local; clientes remotos nunca os controlam.
private _authorName=_authorNameOverride;
if (_authorName isEqualTo "") then {_authorName=if (!isNull _unit) then {name _unit} else {profileName};};
if (_authorName isEqualTo "") then {_authorName=if (_kind isEqualTo "SERVER") then {"Servidor"} else {"Jogador"};};
private _authorKey=_authorKeyOverride;
if (_authorKey isEqualTo "") then {
    _authorKey=if (!isNull _unit) then {getPlayerUID _unit} else {""};
    if (_authorKey isEqualTo "") then {_authorKey=if (_kind isEqualTo "SERVER") then {"SERVER"} else {format ["LOCAL-%1-%2",clientOwner,toLower _authorName]};};
};
[_kit,_kitId,_authorName,_authorKey,_kind] call ServoPeregrino_Organizador_Items_fnc_commitPublicKitSnapshotServer
