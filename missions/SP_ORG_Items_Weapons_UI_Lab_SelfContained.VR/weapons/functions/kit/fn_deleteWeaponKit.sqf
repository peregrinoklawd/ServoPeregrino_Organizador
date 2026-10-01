#include "..\..\script_version.hpp"
params [["_kitId","",[""]]];
private _init = [] call ServoPeregrino_Organizador_Weapons_fnc_initializeWeaponKitStore;
if !(_init get "success") exitWith {_init};
private _store = missionNamespace getVariable SP_ORG_WEAPONS_KIT_STORE;
private _kits = _store get "kits";
if !(_kitId in _kits) exitWith {
 [false,"WEAPONS_KIT_NOT_FOUND","WeaponKit not found in session repository."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _removed = _kits deleteAt _kitId;
[true,"WEAPONS_KIT_DELETED","WeaponKit removed from session-local repository.",createHashMapFromArray [
 ["kit",[_removed] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
