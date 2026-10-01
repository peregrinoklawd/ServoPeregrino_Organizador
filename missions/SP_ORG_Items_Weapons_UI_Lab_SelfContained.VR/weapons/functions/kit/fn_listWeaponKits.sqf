#include "..\..\script_version.hpp"
private _init = [] call ServoPeregrino_Organizador_Weapons_fnc_initializeWeaponKitStore;
if !(_init get "success") exitWith {_init};
private _store = missionNamespace getVariable SP_ORG_WEAPONS_KIT_STORE;
private _kits = _store get "kits";
private _ids = keys _kits;
_ids sort true;
private _list = [];
{
 _list pushBack ([(_kits get _x)] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy);
} forEach _ids;

[true,"WEAPONS_KIT_LIST","Session-local WeaponKits listed.",createHashMapFromArray [
 ["kits",_list],
 ["count",count _list],
 ["repositoryMode","SESSION_LOCAL_CANDIDATE"]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
