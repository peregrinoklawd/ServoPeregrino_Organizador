#include "..\..\script_version.hpp"
params [["_kitId","",[""]]];

if (_kitId isEqualTo "") exitWith {
 [false,"WEAPONS_UI_DRAFT_KIT_ID_EMPTY","WeaponKit id is required to create a local draft."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _kitResult = [_kitId] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponKit;
if !(_kitResult get "success") exitWith {_kitResult};
private _kit = ((_kitResult get "data") get "kit");

private _state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
if ((count _state) isEqualTo 0) then {
 [] call ServoPeregrino_Organizador_Weapons_fnc_createUIState;
 _state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
};

private _drafts = _state getOrDefault ["draftsByKitId",createHashMap];
private _draft = _drafts getOrDefault [_kitId,createHashMap];

if ((count _draft) > 0) exitWith {
 [true,"WEAPONS_UI_DRAFT_FOUND","Existing session-local WeaponKit draft returned.",createHashMapFromArray [
  ["draft",[_draft] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy]
 ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _baseRecipe = [_kit getOrDefault ["recipe",createHashMap]] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
private _recipe = [_baseRecipe] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;

_draft = createHashMapFromArray [
 ["schemaVersion","0.6-D-weaponkit-draft-candidate"],
 ["sourceKitId",_kitId],
 ["sourceName",_kit getOrDefault ["name",""]],
 ["targetSlot",_kit getOrDefault ["targetSlot",""]],
 ["baseRecipe",_baseRecipe],
 ["recipe",_recipe],
 ["dirty",false],
 ["revision",0],
 ["createdAtTick",diag_tickTime],
 ["updatedAtTick",diag_tickTime]
];

_drafts set [_kitId,_draft];
_state set ["draftsByKitId",_drafts];
_state set ["activeDraftKitId",_kitId];
missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];

[true,"WEAPONS_UI_DRAFT_CREATED","Session-local WeaponKit draft created from the saved repository snapshot. No repository or loadout mutation performed.",createHashMapFromArray [
 ["draft",[_draft] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
