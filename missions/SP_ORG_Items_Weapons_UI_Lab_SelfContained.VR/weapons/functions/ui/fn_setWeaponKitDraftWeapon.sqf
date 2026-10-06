#include "..\..\script_version.hpp"
params [
 ["_kitId","",[""]],
 ["_weaponClass","",[""]]
];

if (_kitId isEqualTo "") exitWith {
 [false,"WEAPONS_UI_DRAFT_KIT_ID_EMPTY","Nenhum kit está aberto para receber a arma."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _kitR = [_kitId] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponKit;
if !(_kitR get "success") exitWith {_kitR};
private _kit = (_kitR get "data") get "kit";

private _entryR = [_weaponClass,false] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponCatalogEntry;
if !(_entryR get "success") exitWith {_entryR};
private _entry = (_entryR get "data") get "entry";
private _selectedSlot = toUpperANSI (_entry getOrDefault ["category",""]);
if !(_selectedSlot in ["PRIMARY","HANDGUN","SECONDARY"]) exitWith {
 [false,"WEAPONS_UI_DRAFT_WEAPON_TYPE_UNSUPPORTED","Esta arma não pode ser usada em um kit de armas do jogador."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _draftR = [_kitId] call ServoPeregrino_Organizador_Weapons_fnc_getOrCreateWeaponKitDraft;
if !(_draftR get "success") exitWith {_draftR};
private _draft = (_draftR get "data") get "draft";
private _currentRecipe = _draft getOrDefault ["recipe",createHashMap];
private _currentCfg = _currentRecipe getOrDefault ["configuration",createHashMap];
private _currentWeapon = _currentCfg getOrDefault ["weaponClass",""];
private _currentSlot = toUpperANSI (_draft getOrDefault ["targetSlot",_kit getOrDefault ["targetSlot",""]]);
private _canonicalWeapon = _entry getOrDefault ["weaponClass",_weaponClass];

if ((toLowerANSI _currentWeapon) isEqualTo (toLowerANSI _canonicalWeapon) && {_currentSlot isEqualTo _selectedSlot}) exitWith {
 [true,"WEAPONS_UI_DRAFT_WEAPON_UNCHANGED","A arma selecionada já está no rascunho.",createHashMapFromArray [
  ["draft",[_draft] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],["changed",false],["loadoutMutation",false]
 ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _cfgR = [_canonicalWeapon] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponConfiguration;
if !(_cfgR get "success") exitWith {_cfgR};
private _recipeR = [(_cfgR get "data") get "configuration",""] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponRecipe;
if !(_recipeR get "success") exitWith {_recipeR};
private _recipe = (_recipeR get "data") get "recipe";

private _baseRecipe = _draft getOrDefault ["baseRecipe",createHashMap];
private _baseSlot = toUpperANSI (_draft getOrDefault ["baseTargetSlot",_kit getOrDefault ["targetSlot",""]]);
private _cmp = [_baseRecipe,_recipe] call ServoPeregrino_Organizador_Weapons_fnc_compareWeaponRecipes;
if !(_cmp get "success") exitWith {_cmp};
private _dirty = !(((_cmp get "data") getOrDefault ["equal",false])) || {!(_selectedSlot isEqualTo _baseSlot)};

_draft set ["recipe",[_recipe] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy];
_draft set ["targetSlot",_selectedSlot];
_draft set ["dirty",_dirty];
_draft set ["revision",(_draft getOrDefault ["revision",0]) + 1];
_draft set ["updatedAtTick",diag_tickTime];

private _state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
private _drafts = _state getOrDefault ["draftsByKitId",createHashMap];
_drafts set [_kitId,_draft];
_state set ["draftsByKitId",_drafts];
_state set ["activeDraftKitId",_kitId];
_state set ["catalogOffset",0];
missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
missionNamespace setVariable [SP_ORG_WEAPONS_UI_CATALOG_PROJECTION_VAR,createHashMap];

[true,"WEAPONS_UI_DRAFT_WEAPON_UPDATED","Arma do rascunho substituída. Os acessórios e o carregador foram limpos para recalcular a compatibilidade. Nenhum equipamento físico foi alterado.",createHashMapFromArray [
 ["draft",[_draft] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
 ["weaponClass",_canonicalWeapon],
 ["targetSlot",_selectedSlot],
 ["previousTargetSlot",_currentSlot],
 ["dirty",_dirty],
 ["changed",true],
 ["weaponKitMutation",false],
 ["loadoutMutation",false]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
