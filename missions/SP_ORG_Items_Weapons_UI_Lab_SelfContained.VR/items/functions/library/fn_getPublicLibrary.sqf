#include "..\..\script_version.hpp"
private _registry=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VAR,[]];
private _valid=(_registry isEqualType []) && {(count _registry) isEqualTo 4} && {(_registry#0) isEqualType ""} && {(_registry#0) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_MAGIC} && {(_registry#1) isEqualType 0} && {(_registry#1) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VERSION} && {(_registry#2) isEqualType 0} && {(_registry#3) isEqualType []};
if (!_valid) then {
    if (isServer) then {
        [] call ServoPeregrino_Organizador_Items_fnc_initializePublicLibraryAuthority;
        _registry=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VAR,[SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_MAGIC,SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VERSION,0,[]]];
        _valid=true;
    } else {
        // Cliente não fabrica estado público local. Até chegar a réplica do servidor, expõe somente uma visão vazia transitória.
        _registry=[SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_MAGIC,SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_LIBRARY_VERSION,0,[]];
    };
};
private _authority=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_AUTHORITY_VAR,[]];
private _authorityReady=(_authority isEqualType []) && {(count _authority) isEqualTo 4} && {(_authority#0) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_AUTHORITY_MAGIC} && {(_authority#1) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PUBLIC_AUTHORITY_VERSION} && {(_authority#2) isEqualTo "SERVER"};
[true,"ITEMS_PUBLIC_LIBRARY_READY","Biblioteca pública da sessão disponível.",createHashMapFromArray [["library",[_registry] call ServoPeregrino_Organizador_Items_fnc_deepCopy],["scope","SESSION"],["authority","SERVER"],["authoritative",_authorityReady],["authorityPending",!_authorityReady]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
