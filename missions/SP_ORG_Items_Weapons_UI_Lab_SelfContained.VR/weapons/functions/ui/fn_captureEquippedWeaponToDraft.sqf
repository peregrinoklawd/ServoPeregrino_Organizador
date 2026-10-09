#include "..\..\script_version.hpp"
// Equipment P4 -> logical WeaponKit draft. Never apply/salvage physical inventory,
// update saved WeaponKits, publish, or copy the transient ammo count to a Recipe.
params [["_unit",objNull,[objNull]],["_slot","PRIMARY",[""]]];
private _slotU=toUpperANSI _slot;
if (isNull _unit || {!(_unit isKindOf "CAManBase")} || {!local _unit} || {!(_slotU in ["PRIMARY","SECONDARY","HANDGUN"])}) exitWith {
 [false,"WEAPONS_UI_CAPTURE_TARGET_INVALID","A captura exige uma unidade local e destino de arma válido."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _snapshotR=[_unit,_slotU] call ServoPeregrino_Organizador_Weapons_fnc_getEquipmentSlotSnapshot;
if !(_snapshotR getOrDefault ["success",false]) exitWith {_snapshotR};
private _snapshot=(_snapshotR get "data") get "snapshot";
if !(_snapshot getOrDefault ["equipped",false]) exitWith {
 [false,"WEAPONS_UI_CAPTURE_SLOT_EMPTY","Não há arma equipada neste destino. Selecione outro destino em VISUALIZAR."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _cfg=_snapshot getOrDefault ["configuration",createHashMap];
private _magClass=_snapshot getOrDefault ["magazineClass",""];
private _recipeR=[_cfg,_magClass] call ServoPeregrino_Organizador_Weapons_fnc_prepareObservedCaptureRecipe;
if !(_recipeR getOrDefault ["success",false]) exitWith {_recipeR};
private _recipe=(_recipeR get "data") get "recipe";
private _omissions=(_recipeR get "data") getOrDefault ["omissions",[]];
diag_log format ["[SP_ORG] [WEAPONS] [EQUIPMENT_CAPTURE_PREPARED] slot=%1 weapon=%2 magazine=%3 partial=%4 omissions=%5",_slotU,_cfg getOrDefault ["weaponClass",""],_magClass,count _omissions>0,_omissions];
private _state=missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
if ((count _state) isEqualTo 0) then {
 [] call ServoPeregrino_Organizador_Weapons_fnc_createUIState;
 _state=missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
};
private _kitId=if (_state getOrDefault ["pendingNewKit",false]) then {""} else {_state getOrDefault ["selectedKitId",""]};
private _createdNew=_kitId isEqualTo "";
private _changed=true;
private _draft=createHashMap;
private _captureError=createHashMap;
if (!_createdNew) then {
 private _kitR=[_kitId] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponKit;
 if !(_kitR getOrDefault ["success",false]) exitWith {_captureError=_kitR};
 private _kit=(_kitR get "data") get "kit";
 private _draftR=[_kitId] call ServoPeregrino_Organizador_Weapons_fnc_getOrCreateWeaponKitDraft;
 if !(_draftR getOrDefault ["success",false]) exitWith {_captureError=_draftR};
 _draft=(_draftR get "data") get "draft";
 private _baseRecipe=_draft getOrDefault ["baseRecipe",_kit getOrDefault ["recipe",createHashMap]];
 private _comparison=[_baseRecipe,_recipe] call ServoPeregrino_Organizador_Weapons_fnc_compareWeaponRecipes;
 if !(_comparison getOrDefault ["success",false]) exitWith {_captureError=_comparison};
 private _baseSlot=toUpperANSI (_draft getOrDefault ["baseTargetSlot",_kit getOrDefault ["targetSlot",""]]);
 private _dirty= !(((_comparison get "data") getOrDefault ["equal",false])) || {_slotU isNotEqualTo _baseSlot};
 _changed= !((_draft getOrDefault ["recipe",createHashMap]) isEqualTo _recipe)
    || {(_draft getOrDefault ["targetSlot",""]) isNotEqualTo _slotU}
    || {(_draft getOrDefault ["dirty",false]) isNotEqualTo _dirty};
 // Copy, do not mutate a HashMap owned by the caller while comparing the draft.
 _draft=[_draft] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 _draft set ["recipe",[_recipe] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy];
 _draft set ["captureOmissions",[_omissions] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy];
 _draft set ["targetSlot",_slotU];
 _draft set ["dirty",_dirty];
 if (_changed) then {
  _draft set ["revision",(_draft getOrDefault ["revision",0])+1];
  _draft set ["updatedAtTick",diag_tickTime];
 };
 private _drafts=_state getOrDefault ["draftsByKitId",createHashMap];
 _drafts set [_kitId,_draft];
 _state set ["draftsByKitId",_drafts];
 _state set ["activeDraftKitId",_kitId];
 _state set ["selectedKitDraftDirty",_dirty];
} else {
 // Preserve a name typed before capture, but do not add a WeaponKit to the store
 // until the player explicitly presses SALVAR.
 private _pendingName=_state getOrDefault ["pendingNewName",""];
 if (_pendingName isEqualTo "") then {
  private _nameBase=(_snapshot getOrDefault ["weaponInfo",createHashMap]) getOrDefault ["displayName","Arma equipada"];
  private _uniqueR=[_nameBase] call ServoPeregrino_Organizador_Weapons_fnc_getUniqueWeaponKitName;
  if !(_uniqueR getOrDefault ["success",false]) exitWith {_captureError=_uniqueR};
  _pendingName=(_uniqueR get "data") get "name";
 };
 private _previous=_state getOrDefault ["pendingCapturedDraft",createHashMap];
 _draft=createHashMapFromArray [
  ["schemaVersion","0.7-E-pending-captured-draft"],
  ["sourceKitId",""],
  ["sourceName",_pendingName],
  ["targetSlot",_slotU],
  ["baseTargetSlot",_slotU],
  ["baseRecipe",createHashMap],
  ["recipe",[_recipe] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
  ["captureOmissions",[_omissions] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
  ["dirty",true],
  ["revision",(_previous getOrDefault ["revision",0])+1],
  ["updatedAtTick",diag_tickTime]
 ];
 if ((count _captureError)>0) exitWith {};
 _state set ["pendingNewKit",true];
 _state set ["pendingNewName",_pendingName];
 _state set ["pendingCapturedDraft",_draft];
 _state set ["selectedKitId",""];
 _state set ["selectedKitIsNew",false];
 _state set ["activeDraftKitId",""];
 _state set ["selectedKitDraftDirty",true];
 _state set ["kitTypeFilter","ALL"];
 _state set ["kitQuery",""];
};
if ((count _captureError)>0) exitWith {_captureError};
_state set ["lastFocus","DRAFT"];
_state set ["equipmentSlotView",_slotU];
missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
// Capturing a different base weapon in the SAME selected kit must invalidate
// the accessory projection; kitId alone is not a compatibility cache key.
if (_changed || {_createdNew}) then {
 missionNamespace setVariable [SP_ORG_WEAPONS_UI_CATALOG_PROJECTION_VAR,createHashMap];
};
[true,if (_createdNew) then {"WEAPONS_UI_EQUIPMENT_CAPTURED_TO_NEW_DRAFT"} else {"WEAPONS_UI_EQUIPMENT_CAPTURED_TO_DRAFT"},"Arma equipada capturada para ARMAS DO KIT. O equipamento e os kits salvos não foram alterados.",createHashMapFromArray [
 ["slot",_slotU],["kitId",_kitId],["createdNew",_createdNew],["changed",_changed],
 ["draft",[_draft] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
 ["captureOmissions",[_omissions] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
 ["capturePartial",count _omissions>0],
 ["observedWeaponClass",_cfg getOrDefault ["weaponClass",""]],
 ["observedLoadedState",[_snapshot getOrDefault ["loadedState",createHashMap]] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
 ["savedKitMutation",false],["loadoutMutation",false],["ammoCountPersisted",false]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
