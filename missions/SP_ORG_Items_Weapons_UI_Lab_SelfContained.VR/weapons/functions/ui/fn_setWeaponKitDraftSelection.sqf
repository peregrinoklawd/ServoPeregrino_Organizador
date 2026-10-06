#include "..\..\script_version.hpp"
params [
 ["_kitId","",[""]],
 ["_field","",[""]],
 ["_className","",[""]]
];

if (_kitId isEqualTo "") exitWith {
 [false,"WEAPONS_UI_DRAFT_KIT_ID_EMPTY","WeaponKit id is required to edit a draft."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _fieldName = if (_field isEqualTo "magazineClass") then {"magazineClass"} else {toLowerANSI _field};
if !(_fieldName in ["optic","muzzle","pointer","bipod","magazineClass"]) exitWith {
 [false,"WEAPONS_UI_DRAFT_FIELD_INVALID","Draft field is not editable in 0.6-D.",createHashMapFromArray [["field",_field]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _draftResult = [_kitId] call ServoPeregrino_Organizador_Weapons_fnc_getOrCreateWeaponKitDraft;
if !(_draftResult get "success") exitWith {_draftResult};
private _draft = ((_draftResult get "data") get "draft");
private _recipe = [_draft getOrDefault ["recipe",createHashMap]] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
private _configuration = [_recipe getOrDefault ["configuration",createHashMap]] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
private _weaponClass = _configuration getOrDefault ["weaponClass",""];

private _selectorResult = [_weaponClass,_recipe] call ServoPeregrino_Organizador_Weapons_fnc_buildCompatibilitySelectorModel;
if !(_selectorResult get "success") exitWith {_selectorResult};
private _model = ((_selectorResult get "data") get "model");
private _selector = (_model getOrDefault ["selectors",createHashMap]) getOrDefault [_fieldName,createHashMap];
if ((count _selector) isEqualTo 0) exitWith {
 [false,"WEAPONS_UI_DRAFT_SELECTOR_MISSING","Compatibility selector is unavailable for requested draft field.",createHashMapFromArray [["field",_fieldName]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _requestedLower = toLowerANSI _className;
private _options = _selector getOrDefault ["options",[]];
private _matchIndex = _options findIf {
 (toLowerANSI (_x getOrDefault ["className",""])) isEqualTo _requestedLower
};
if (_matchIndex < 0) exitWith {
 [false,"WEAPONS_UI_DRAFT_SELECTION_INCOMPATIBLE","Requested value is not present in the engine-derived compatibility selector.",createHashMapFromArray [
  ["field",_fieldName],["className",_className],["weaponClass",_weaponClass]
 ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _canonicalClass = (_options select _matchIndex) getOrDefault ["className",""];

if (_fieldName isEqualTo "magazineClass") then {
 _recipe set ["magazineClass",_canonicalClass];
} else {
 _configuration set [_fieldName,_canonicalClass];
 _recipe set ["configuration",_configuration];
};

private _semantic = [_recipe] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponRecipeSemantic;
if !(_semantic get "success") exitWith {_semantic};

private _baseRecipe = _draft getOrDefault ["baseRecipe",createHashMap];
private _comparison = [_baseRecipe,_recipe] call ServoPeregrino_Organizador_Weapons_fnc_compareWeaponRecipes;
if !(_comparison get "success") exitWith {_comparison};
private _dirty = !(((_comparison get "data") getOrDefault ["equal",false]));

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

[true,"WEAPONS_UI_DRAFT_SELECTION_UPDATED","Compatibility selection updated only the session-local WeaponKit draft.",createHashMapFromArray [
 ["field",_fieldName],
 ["className",_canonicalClass],
 ["dirty",_dirty],
 ["draft",[_draft] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
 ["weaponKitMutation",false],
 ["loadoutMutation",false]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
