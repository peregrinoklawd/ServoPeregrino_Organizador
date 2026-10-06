#include "..\..\script_version.hpp"
if (!isServer || {!(missionNamespace getVariable ["SP_ORG_Weapons_LabEnabled",false])}) exitWith {};
params [["_unit",objNull,[objNull]],["_operation","",[""]],["_slot","PRIMARY",[""]],["_target",objNull,[objNull]],["_eventItem","",[""]]];
private _sender = if (isRemoteExecuted) then {remoteExecutedOwner} else {owner _unit};
if (isNull _unit || {!isPlayer _unit} || {owner _unit != _sender}) exitWith {};
if !(_operation in ["REGISTER","QUERY","UPDATE","OBSERVE","EVENT","DIAGNOSTICS"]) exitWith {};
if !(_slot in ["PRIMARY","SECONDARY","HANDGUN"]) exitWith {};

[] call ServoPeregrino_Organizador_Weapons_fnc_initializeAuthority;
private _state = missionNamespace getVariable SP_ORG_WEAPONS_AUTHORITY;
private _key = netId _unit;
private _requests = _state get "requests";
private _last = _requests getOrDefault [_key,-10];
if (_operation != "EVENT" && {diag_tickTime - _last < 0.3}) exitWith {};
_requests set [_key,diag_tickTime];

private _references = _state get "references";
private _refKey = _key + ":" + _slot;
private _reference = _references getOrDefault [_refKey,createHashMap];
private _result = createHashMap;

if (_operation isEqualTo "EVENT") then {
 {
  private _r = _references get _x;
  if ((_r get "unit") isEqualTo _unit && {getNumber (configFile >> "CfgWeapons" >> _eventItem >> "type") in [1,2,4]}) then {
   _r set ["status","UNRESOLVED_AFTER_EXTERNAL_EVENT"]
  };
 } forEach keys _references;
 _result = [_unit] call ServoPeregrino_Organizador_Weapons_fnc_inspectWeaponCarrier;
} else {
 switch (_operation) do {
  case "REGISTER": {
   if (count _reference > 0) then {
    _result = [false,"WEAPONS_REFERENCE_EXISTS","A referencia ja existe. Consulte-a; nao emitir outro serial para mascarar perda de identidade."] call ServoPeregrino_Organizador_Nexus_fnc_createResult;
   } else {
    private _capture = [_unit,_slot] call ServoPeregrino_Organizador_Weapons_fnc_captureWeaponConfiguration;
    _result = _capture;
    if (_capture get "success") then {
     _result = [(_capture get "data") get "configuration"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponInstance;
     if (_result get "success") then {
      private _instance = (_result get "data") get "instance";
      _references set [_refKey,createHashMapFromArray [
       ["unit",_unit],["slot",_slot],["instanceId",_instance get "instanceId"],["status","REFERENCE_ONLY_UNPROVEN"]
      ]];
     };
    };
   };
  };
  case "QUERY": {
   _result = [_unit] call ServoPeregrino_Organizador_Weapons_fnc_inspectWeaponCarrier;
   (_result get "data") set ["logicalReference",[_reference] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy];
   if (count _reference > 0) then {
    (_result get "data") set ["logicalRecord",[_reference get "instanceId"] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponInstance]
   };
  };
  case "UPDATE": {
   if (count _reference isEqualTo 0 || {(_reference getOrDefault ["status",""]) != "REFERENCE_ONLY_UNPROVEN"}) then {
    _result = [false,"WEAPONS_IDENTITY_UNRESOLVED","Sem referencia continua; nao reconciliar por classname/fingerprint."] call ServoPeregrino_Organizador_Nexus_fnc_createResult;
   } else {
    private _capture = [_unit,_slot] call ServoPeregrino_Organizador_Weapons_fnc_captureWeaponConfiguration;
    _result = _capture;
    if (_capture get "success") then {
     _result = [_reference get "instanceId",(_capture get "data") get "configuration"] call ServoPeregrino_Organizador_Weapons_fnc_updateWeaponInstanceConfiguration
    };
   };
  };
  case "OBSERVE": {
   if (isNull _target || {_unit distance _target > 10}) then {
    _result = [false,"WEAPONS_TARGET_OUT_OF_RANGE","Olhe para uma caixa/holder a menos de 10 m."] call ServoPeregrino_Organizador_Nexus_fnc_createResult;
   } else {
    _result = [_target] call ServoPeregrino_Organizador_Weapons_fnc_inspectWeaponCarrier
   };
  };
  case "DIAGNOSTICS": {
   _result = [] call ServoPeregrino_Organizador_Weapons_fnc_getIdentityDiagnostics
  };
 };
};

private _text = format ["[SP_ORG] [WEAPONS] [LAB] mode=MISSION_FIRST op=%1 slot=%2 sender=%3 result=%4",_operation,_slot,_sender,_result];
diag_log _text;
if (!isMultiplayer && {hasInterface}) then {
 hint _text;
} else {
 [_text] remoteExecCall ["ServoPeregrino_Organizador_Weapons_fnc_clientReceiveLabResult",_sender];
};
_result
