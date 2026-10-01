#include "..\..\script_version.hpp"

if (!isServer) exitWith {
    [true,"ITEMS_PUBLIC_AUTHORITY_OBSERVER","Cliente aguardando a autoridade de biblioteca pública do servidor.",createHashMapFromArray [["authority","SERVER"],["authoritative",false],["scope","SESSION"]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _registry=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VAR,[]];
private _valid=(_registry isEqualType []) && {(count _registry) isEqualTo 4} && {(_registry#0) isEqualType ""} && {(_registry#0) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_MAGIC} && {(_registry#1) isEqualType 0} && {(_registry#1) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VERSION} && {(_registry#2) isEqualType 0} && {(_registry#3) isEqualType []};
if (!_valid) then {
    _registry=[SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_MAGIC,SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VERSION,0,[]];
};

private _authority=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_AUTHORITY_VAR,[]];
private _authorityValid=(_authority isEqualType []) && {(count _authority) isEqualTo 4} && {(_authority#0) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_AUTHORITY_MAGIC} && {(_authority#1) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_AUTHORITY_VERSION} && {(_authority#2) isEqualTo "SERVER"};
if (!_authorityValid) then {
    _authority=[SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_AUTHORITY_MAGIC,SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_AUTHORITY_VERSION,"SERVER",+systemTimeUTC];
};

// O servidor publica o estado corrente para os clientes conectados. JIP/reconciliação persistente ficam para 0.13-B.
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VAR,_registry,true];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_AUTHORITY_VAR,_authority,true];
diag_log format ["[SP_ORG] [ITEMS] [PUBLIC_AUTHORITY] READY mode=SERVER revision=%1 entries=%2 scope=SESSION",_registry#2,count (_registry#3)];

[true,"ITEMS_PUBLIC_AUTHORITY_READY","Servidor assumiu a autoridade da biblioteca pública da sessão.",createHashMapFromArray [["authority","SERVER"],["authoritative",true],["scope","SESSION"],["revision",_registry#2],["count",count (_registry#3)]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
