#include "..\..\script_version.hpp"
params [["_kitId","",[""]]];

if (_kitId isEqualTo "") exitWith {
 [false,"WEAPONS_UI_DRAFT_KIT_ID_EMPTY","WeaponKit id is required to discard a draft."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _kitResult = [_kitId] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponKit;
if !(_kitResult get "success") exitWith {_kitResult};

private _state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
if ((count _state) isEqualTo 0) then {
 [] call ServoPeregrino_Organizador_Weapons_fnc_createUIState;
 _state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
};
private _drafts = _state getOrDefault ["draftsByKitId",createHashMap];
private _hadDraft = _kitId in _drafts;
if (_hadDraft) then {_drafts deleteAt _kitId};
_state set ["draftsByKitId",_drafts];
_state set ["activeDraftKitId",_kitId];
missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];

private _freshResult = [_kitId] call ServoPeregrino_Organizador_Weapons_fnc_getOrCreateWeaponKitDraft;
if !(_freshResult get "success") exitWith {_freshResult};
private _freshDraft = ((_freshResult get "data") get "draft");

[true,"WEAPONS_UI_DRAFT_DISCARDED","Local changes discarded and draft restored from the saved WeaponKit. Repository and loadout were not modified.",createHashMapFromArray [
 ["hadDraft",_hadDraft],
 ["draft",[_freshDraft] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
 ["weaponKitMutation",false],
 ["loadoutMutation",false]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
