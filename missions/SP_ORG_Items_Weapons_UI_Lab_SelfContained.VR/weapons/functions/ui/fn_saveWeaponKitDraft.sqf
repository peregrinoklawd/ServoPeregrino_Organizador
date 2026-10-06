#include "..\..\script_version.hpp"
params [["_kitId","",[""]]];

if (_kitId isEqualTo "") exitWith {
 [false,"WEAPONS_UI_DRAFT_KIT_ID_EMPTY","WeaponKit id is required to save a draft."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _draftR = [_kitId] call ServoPeregrino_Organizador_Weapons_fnc_getOrCreateWeaponKitDraft;
if !(_draftR get "success") exitWith {_draftR};
private _draft = (_draftR get "data") get "draft";
if !(_draft getOrDefault ["dirty",false]) exitWith {
 private _kitR = [_kitId] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponKit;
 [true,"WEAPONS_UI_DRAFT_ALREADY_SAVED","Draft already matches the saved WeaponKit.",createHashMapFromArray [
  ["changed",false],
  ["kit",if (_kitR get "success") then {[((_kitR get "data") get "kit")] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy} else {createHashMap}],
  ["loadoutMutation",false]
 ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _recipe = [_draft getOrDefault ["recipe",createHashMap]] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
private _targetSlot = _draft getOrDefault ["targetSlot",""];
private _saveR = [_kitId,_targetSlot,_recipe] call ServoPeregrino_Organizador_Weapons_fnc_updateWeaponKitDefinition;
if !(_saveR get "success") exitWith {_saveR};
private _kit = (_saveR get "data") get "kit";
private _savedRecipe = [_kit getOrDefault ["recipe",createHashMap]] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;

_draft set ["sourceName",_kit getOrDefault ["name",""]];
_draft set ["targetSlot",_kit getOrDefault ["targetSlot",""]];
_draft set ["baseTargetSlot",_kit getOrDefault ["targetSlot",""]];
_draft set ["baseRecipe",[_savedRecipe] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy];
_draft set ["recipe",[_savedRecipe] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy];
_draft set ["dirty",false];
_draft set ["revision",(_draft getOrDefault ["revision",0]) + 1];
_draft set ["updatedAtTick",diag_tickTime];

private _state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
private _drafts = _state getOrDefault ["draftsByKitId",createHashMap];
_drafts set [_kitId,_draft];
_state set ["draftsByKitId",_drafts];
_state set ["activeDraftKitId",_kitId];
missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];

[true,"WEAPONS_UI_DRAFT_SAVED","Alterações do kit salvas nesta sessão. O equipamento real do jogador não foi alterado.",createHashMapFromArray [
 ["changed",true],
 ["kit",[_kit] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
 ["draft",[_draft] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
 ["loadoutMutation",false]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
