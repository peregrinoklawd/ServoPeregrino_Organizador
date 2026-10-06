#include "..\..\script_version.hpp"
params [
 ["_name","",[""]],
 ["_targetSlot","",[""]],
 ["_recipe",false]
];

if !(_recipe isEqualType createHashMap) exitWith {
 [false,"WEAPONS_KIT_RECIPE_TYPE_INVALID","createWeaponKit expects a WeaponRecipe HashMap."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _init = [] call ServoPeregrino_Organizador_Weapons_fnc_initializeWeaponKitStore;
if !(_init get "success") exitWith {_init};

private _nameResult = [_name] call ServoPeregrino_Organizador_Weapons_fnc_normalizeWeaponKitName;
if !(_nameResult get "success") exitWith {_nameResult};
private _normalizedName = (_nameResult get "data") get "name";

private _store = missionNamespace getVariable SP_ORG_WEAPONS_KIT_STORE;
private _kits = _store get "kits";
private _nameKey = toLowerANSI _normalizedName;
private _collision = false;
{
 private _existing = _kits get _x;
 if ((toLowerANSI (_existing get "name")) isEqualTo _nameKey) exitWith {_collision = true};
} forEach (keys _kits);
if (_collision) exitWith {
 [false,"WEAPONS_KIT_NAME_EXISTS","WeaponKit names are unique case-insensitively within the session repository."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _counter = (_store get "counter") + 1;
if (_counter > 9999999) exitWith {
 [false,"WEAPONS_KIT_STORE_EXHAUSTED","Session WeaponKit sequence exhausted."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
_store set ["counter",_counter];

private _kitId = format ["WKT-%1-%2",_store get "session",_counter toFixed 0];
private _candidate = createHashMapFromArray [
 ["schemaVersion","0.5-kit-candidate"],
 ["kitId",_kitId],
 ["name",_normalizedName],
 ["targetSlot",toUpperANSI _targetSlot],
 ["recipe",[_recipe] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy]
];

private _semantic = [_candidate] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponKitSemantic;
if !(_semantic get "success") exitWith {_semantic};

private _normal = [_candidate] call ServoPeregrino_Organizador_Weapons_fnc_normalizeWeaponKit;
if !(_normal get "success") exitWith {_normal};
private _kit = (_normal get "data") get "kit";

_kits set [_kitId,[_kit] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy];

[true,"WEAPONS_KIT_CREATED","WeaponKit created in session-local repository. No inventory mutation performed.",createHashMapFromArray [
 ["kit",[_kit] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
 ["repositoryMode","SESSION_LOCAL_CANDIDATE"]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
