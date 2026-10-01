#include "..\..\script_version.hpp"
params [
 ["_kitId","",[""]],
 ["_field","",[""]],
 ["_className","",[""]]
];

private _fieldL = toLowerANSI _field;
if !(_fieldL in ["optic","muzzle","pointer","bipod","magazine"]) exitWith {
 [false,"WEAPONS_UI_DRAFT_FIELD_INVALID","Draft field must be OPTIC/MUZZLE/POINTER/BIPOD/MAGAZINE."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _draftResult = [_kitId] call ServoPeregrino_Organizador_Weapons_fnc_getOrCreateWeaponKitDraft;
if !(_draftResult get "success") exitWith {_draftResult};
private _draft = (_draftResult get "data") get "draft";
private _recipe = [_draft getOrDefault ["recipe",createHashMap]] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
private _configuration = [_recipe getOrDefault ["configuration",createHashMap]] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
private _weaponClass = _configuration getOrDefault ["weaponClass",""];
if (_weaponClass isEqualTo "") exitWith {
 [false,"WEAPONS_UI_DRAFT_WEAPON_EMPTY","Draft does not contain a weapon class."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _compatResult = [_weaponClass] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponCompatibility;
if !(_compatResult get "success") exitWith {_compatResult};
private _compat = _compatResult get "data";
private _compatKey = switch (_fieldL) do {
 case "optic": {"optics"};
 case "muzzle": {"muzzles"};
 case "pointer": {"pointers"};
 case "bipod": {"bipods"};
 case "magazine": {"magazines"};
};
private _allowed = (_compat getOrDefault [_compatKey,[]]) apply {toLowerANSI _x};
if (_className isNotEqualTo "" && {!((toLowerANSI _className) in _allowed)}) exitWith {
 [false,"WEAPONS_UI_DRAFT_SELECTION_INCOMPATIBLE","Selected class is not engine-compatible with the draft weapon.",createHashMapFromArray [
  ["weaponClass",_weaponClass],
  ["field",toUpperANSI _fieldL],
  ["className",_className]
 ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

if (_fieldL isEqualTo "magazine") then {
 _recipe set ["magazineClass",_className];
} else {
 _configuration set [_fieldL,_className];
 _recipe set ["configuration",_configuration];
};

private _recipeSemantic = [_recipe] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponRecipeSemantic;
if !(_recipeSemantic get "success") exitWith {_recipeSemantic};
private _recipeNormal = [_recipe] call ServoPeregrino_Organizador_Weapons_fnc_normalizeWeaponRecipe;
if !(_recipeNormal get "success") exitWith {_recipeNormal};
_recipe = (_recipeNormal get "data") get "recipe";

private _baseRecipe = _draft getOrDefault ["baseRecipe",createHashMap];
private _compare = [_baseRecipe,_recipe] call ServoPeregrino_Organizador_Weapons_fnc_compareWeaponRecipes;
private _dirty = true;
if (_compare get "success") then {_dirty = !((_compare get "data") getOrDefault ["equal",false])};

_draft set ["recipe",[_recipe] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy];
_draft set ["dirty",_dirty];
_draft set ["revision",(_draft getOrDefault ["revision",0]) + 1];
_draft set ["updatedAtTick",diag_tickTime];

private _state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
private _drafts = _state getOrDefault ["draftsByKitId",createHashMap];
_drafts set [_kitId,_draft];
_state set ["draftsByKitId",_drafts];
_state set ["activeDraftKitId",_kitId];
missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];

[true,"WEAPONS_UI_DRAFT_SELECTION_UPDATED","Local WeaponKit draft updated. Repository and physical loadout were not changed.",createHashMapFromArray [
 ["draft",[_draft] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
 ["field",toUpperANSI _fieldL],
 ["className",_className],
 ["weaponKitMutation",false],
 ["loadoutMutation",false]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
