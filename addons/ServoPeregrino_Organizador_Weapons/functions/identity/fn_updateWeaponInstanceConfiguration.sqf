#include "..\..\script_version.hpp"
params [["_id","",[""]],["_configuration",false]];
private _lookup = [_id] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponInstance;
if !(_lookup get "success") exitWith {_lookup};
private _valid = [_configuration] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponConfigurationSemantic;
if !(_valid get "success") exitWith {_valid};
private _normal = [_configuration] call ServoPeregrino_Organizador_Weapons_fnc_normalizeWeaponConfiguration;
private _c = (_normal get "data") get "configuration";
private _instance = (_lookup get "data") get "instance";
if !((toLowerANSI (_instance get "weaponClass")) isEqualTo (toLowerANSI (_c get "weaponClass"))) exitWith {[false,"WEAPONS_CLASS_IMMUTABLE","Different weapon class requires separate identity."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
_instance set ["configuration",_c];
_instance set ["updatedAt",systemTimeUTC];
((missionNamespace getVariable SP_ORG_WEAPONS_AUTHORITY) get "instances") set [_id,_instance];
[true,"WEAPONS_INSTANCE_UPDATED","Logical configuration changed; identity preserved. No physical transfer claim.",createHashMapFromArray [["instance",[_instance] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
