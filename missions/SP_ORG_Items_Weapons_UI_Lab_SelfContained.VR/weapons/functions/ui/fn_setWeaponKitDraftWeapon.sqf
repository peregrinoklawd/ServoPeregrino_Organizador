#include "..\..\script_version.hpp"
params [
 ["_kitId","",[""]],
 ["_weaponClass","",[""]]
];

if (_kitId isEqualTo "" || {_weaponClass isEqualTo ""}) exitWith {
 [false,"WEAPONS_UI_DRAFT_WEAPON_INPUT_INVALID","WeaponKit id and weapon class are required."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _draftR = [_kitId] call ServoPeregrino_Organizador_Weapons_fnc_getOrCreateWeaponKitDraft;
if !(_draftR get "success") exitWith {_draftR};
private _draft = (_draftR get "data") get "draft";
private _targetSlot = toUpperANSI (_draft getOrDefault ["targetSlot",""]);

private _entryR = [_weaponClass,false] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponCatalogEntry;
if !(_entryR get "success") exitWith {_entryR};
private _entry = (_entryR get "data") get "entry";
private _weaponSlot = toUpperANSI (_entry getOrDefault ["category",""]);
if !(_weaponSlot isEqualTo _targetSlot) exitWith {
 [false,"WEAPONS_UI_DRAFT_WEAPON_SLOT_MISMATCH","The selected weapon belongs to another target slot. Create a new WeaponKit for another slot.",createHashMapFromArray [
  ["targetSlot",_targetSlot],
  ["weaponSlot",_weaponSlot],
  ["weaponClass",_weaponClass]
 ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _cfgR = [_entry getOrDefault ["weaponClass",_weaponClass]] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponConfiguration;
if !(_cfgR get "success") exitWith {_cfgR};
private _oldRecipe = _draft getOrDefault ["recipe",createHashMap];
private _oldMag = _oldRecipe getOrDefault ["magazineClass",""];
private _newWeaponClass = ((_cfgR get "data") get "configuration") getOrDefault ["weaponClass",_weaponClass];

// Weapon-base replacement intentionally starts from a clean configuration. Attachment selectors
// will be rebuilt from engine compatibility for the new class. Preserve the preferred magazine
// only when the engine reports that it is still compatible.
private _compatR = [_newWeaponClass] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponCompatibility;
if !(_compatR get "success") exitWith {_compatR};
private _allowedMags = ((_compatR get "data") getOrDefault ["magazines",[]]) apply {toLowerANSI _x};
private _newMag = if (_oldMag isNotEqualTo "" && {(toLowerANSI _oldMag) in _allowedMags}) then {_oldMag} else {""};

private _recipeR = [(_cfgR get "data") get "configuration",_newMag] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponRecipe;
if !(_recipeR get "success") exitWith {_recipeR};
private _newRecipe = (_recipeR get "data") get "recipe";
private _baseRecipe = _draft getOrDefault ["baseRecipe",createHashMap];
private _cmp = [_baseRecipe,_newRecipe] call ServoPeregrino_Organizador_Weapons_fnc_compareWeaponRecipes;
private _dirty = true;
if (_cmp get "success") then {_dirty = !((_cmp get "data") getOrDefault ["equal",false])};

_draft set ["recipe",[_newRecipe] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy];
_draft set ["dirty",_dirty];
_draft set ["revision",(_draft getOrDefault ["revision",0]) + 1];
_draft set ["updatedAtTick",diag_tickTime];

private _state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
private _drafts = _state getOrDefault ["draftsByKitId",createHashMap];
_drafts set [_kitId,_draft];
_state set ["draftsByKitId",_drafts];
_state set ["activeDraftKitId",_kitId];
missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];

[true,"WEAPONS_UI_DRAFT_WEAPON_CHANGED","Weapon base changed in the local draft for the same target slot. Attachments and magazine were reset/revalidated; repository and loadout remain unchanged.",createHashMapFromArray [
 ["draft",[_draft] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
 ["weaponClass",_newWeaponClass],
 ["targetSlot",_targetSlot],
 ["weaponKitMutation",false],
 ["loadoutMutation",false]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
