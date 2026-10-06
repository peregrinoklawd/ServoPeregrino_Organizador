#include "..\..\script_version.hpp"
params [
 ["_kitId","",[""]],
 ["_targetSlot","",[""]],
 ["_recipe",false]
];

if (_kitId isEqualTo "") exitWith {
 [false,"WEAPONS_KIT_ID_EMPTY","WeaponKit id is required."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if !(_recipe isEqualType createHashMap) exitWith {
 [false,"WEAPONS_KIT_RECIPE_TYPE_INVALID","Expected WeaponRecipe HashMap."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _existingResult = [_kitId] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponKit;
if !(_existingResult get "success") exitWith {_existingResult};
private _kit = (_existingResult get "data") get "kit";
_kit set ["targetSlot",toUpperANSI _targetSlot];
_kit set ["recipe",[_recipe] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy];

private _semantic = [_kit] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponKitSemantic;
if !(_semantic get "success") exitWith {_semantic};
private _normal = [_kit] call ServoPeregrino_Organizador_Weapons_fnc_normalizeWeaponKit;
if !(_normal get "success") exitWith {_normal};
_kit = (_normal get "data") get "kit";

private _store = missionNamespace getVariable SP_ORG_WEAPONS_KIT_STORE;
(_store get "kits") set [_kitId,[_kit] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy];

[true,"WEAPONS_KIT_DEFINITION_UPDATED","WeaponKit atualizado na sessão; identidade e nome foram preservados.",createHashMapFromArray [
 ["kit",[_kit] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
