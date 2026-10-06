#include "..\..\script_version.hpp"
params [["_kitId","",[""]]];

if (_kitId isEqualTo "") exitWith {
 [false,"WEAPONS_UI_DRAFT_KIT_ID_EMPTY","WeaponKit id is required to clear a draft."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _draftR = [_kitId] call ServoPeregrino_Organizador_Weapons_fnc_getOrCreateWeaponKitDraft;
if !(_draftR get "success") exitWith {_draftR};
private _draft = (_draftR get "data") get "draft";
private _recipe = _draft getOrDefault ["recipe",createHashMap];
private _cfg = _recipe getOrDefault ["configuration",createHashMap];
private _weaponClass = _cfg getOrDefault ["weaponClass",""];
if (_weaponClass isEqualTo "") exitWith {
 [false,"WEAPONS_UI_DRAFT_WEAPON_EMPTY","O rascunho não possui arma-base para preservar durante LIMPAR."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _cfgR = [_weaponClass] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponConfiguration;
if !(_cfgR get "success") exitWith {_cfgR};
private _recipeR = [(_cfgR get "data") get "configuration",""] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponRecipe;
if !(_recipeR get "success") exitWith {_recipeR};
private _cleanRecipe = (_recipeR get "data") get "recipe";
private _baseRecipe = _draft getOrDefault ["baseRecipe",createHashMap];
private _cmp = [_baseRecipe,_cleanRecipe] call ServoPeregrino_Organizador_Weapons_fnc_compareWeaponRecipes;
if !(_cmp get "success") exitWith {_cmp};
private _dirty = !(((_cmp get "data") getOrDefault ["equal",false]));

_draft set ["recipe",[_cleanRecipe] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy];
_draft set ["dirty",_dirty];
_draft set ["revision",(_draft getOrDefault ["revision",0])+1];
_draft set ["updatedAtTick",diag_tickTime];
private _state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
private _drafts = _state getOrDefault ["draftsByKitId",createHashMap];
_drafts set [_kitId,_draft];
_state set ["draftsByKitId",_drafts];
_state set ["activeDraftKitId",_kitId];
missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];

[true,"WEAPONS_UI_DRAFT_CLEARED","Acessórios e carregador foram removidos do rascunho; a arma-base foi preservada. Repository e equipamento físico não foram alterados.",createHashMapFromArray [
 ["draft",[_draft] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],["dirty",_dirty],["loadoutMutation",false]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
