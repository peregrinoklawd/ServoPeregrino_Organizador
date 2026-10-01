#include "..\..\script_version.hpp"
params [["_kitId","",[""]],["_newName","",[""]]];
private _existingResult = [_kitId] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponKit;
if !(_existingResult get "success") exitWith {_existingResult};
private _nameResult = [_newName] call ServoPeregrino_Organizador_Weapons_fnc_normalizeWeaponKitName;
if !(_nameResult get "success") exitWith {_nameResult};
private _normalizedName = (_nameResult get "data") get "name";

private _store = missionNamespace getVariable SP_ORG_WEAPONS_KIT_STORE;
private _kits = _store get "kits";
private _nameKey = toLowerANSI _normalizedName;
private _collision = false;
{
 if !(_x isEqualTo _kitId) then {
  private _candidate = _kits get _x;
  if ((toLowerANSI (_candidate get "name")) isEqualTo _nameKey) exitWith {_collision = true};
 };
} forEach (keys _kits);
if (_collision) exitWith {
 [false,"WEAPONS_KIT_NAME_EXISTS","Another WeaponKit already uses that name case-insensitively."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _kit = (_existingResult get "data") get "kit";
_kit set ["name",_normalizedName];
_kits set [_kitId,[_kit] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy];

[true,"WEAPONS_KIT_RENAMED","WeaponKit renamed; identity and content preserved.",createHashMapFromArray [
 ["kit",[_kit] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
