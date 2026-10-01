#include "..\..\script_version.hpp"
params [["_configuration",false]];
if (!isServer) exitWith {[false,"WEAPONS_SERVER_ONLY","Only local server may issue identities."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _valid = [_configuration] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponConfigurationSemantic;
if !(_valid get "success") exitWith {_valid};
private _init = [] call ServoPeregrino_Organizador_Weapons_fnc_initializeAuthority;
if !(_init get "success") exitWith {_init};
private _normal = [_configuration] call ServoPeregrino_Organizador_Weapons_fnc_normalizeWeaponConfiguration;
private _c = (_normal get "data") get "configuration";
private _output = createHashMap;
isNil {
 private _state = missionNamespace getVariable SP_ORG_WEAPONS_AUTHORITY;
 private _counter = (_state get "counter") + 1;
 if (_counter > 9999999) then {
  _output = [false,"WEAPONS_SESSION_EXHAUSTED","Refuse scalar precision/sequence reuse."] call ServoPeregrino_Organizador_Nexus_fnc_createResult;
 } else {
  _state set ["counter",_counter];
  private _suffix = format ["%1-%2",_state get "session",_counter toFixed 0];
  private _id = "WID-" + _suffix;
  private _instance = createHashMapFromArray [
   ["schemaVersion","0.1-A-candidate"],["instanceId",_id],["serial","SPW-" + _suffix],
   ["weaponClass",_c get "weaponClass"],["configuration",_c],
   ["metadata",createHashMapFromArray [["scope","SESSION"],["authority","SERVER"]]],
   ["createdAt",systemTimeUTC],["updatedAt",systemTimeUTC]
  ];
  private _instances = _state get "instances";
  if (_id in _instances) then {
   _output = [false,"WEAPONS_DUPLICATE_ID","Identity collision refused."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
  } else {
   _instances set [_id,_instance];
   _output = [true,"WEAPONS_INSTANCE_CREATED","Logical identity issued; no physical binding proven.",createHashMapFromArray [["instance",[_instance] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult;
  };
 };
};
_output
