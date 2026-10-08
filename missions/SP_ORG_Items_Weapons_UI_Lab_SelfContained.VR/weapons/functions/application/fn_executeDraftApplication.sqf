params [["_unit",objNull,[objNull]],["_draft",createHashMap,[createHashMap]],["_labFault","",[""]]];
private _preFailure = {
 params ["_result"];
 private _data = _result getOrDefault ["data",createHashMap];
 _data set ["failurePhase","PRE_MUTATION"];_data set ["mutationPerformed",false];_data set ["rollbackAttempted",false];
 _result set ["data",_data];_result
};
private _recipe = _draft getOrDefault ["recipe",false];
if !(_recipe isEqualType createHashMap) exitWith {
 [false,"WEAPONS_APPLICATION_DRAFT_INVALID","Draft has no valid Recipe.",createHashMapFromArray [["failurePhase","PRE_MUTATION"],["mutationPerformed",false],["rollbackAttempted",false]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
// Pure transient WeaponKit: never create/update/save/publish a repository entry.
private _kit = createHashMapFromArray [
 ["schemaVersion","0.5-kit-candidate"],["kitId","WKT-TRANSIENT-DRAFT"],
 ["name","Rascunho atual"],["targetSlot",_draft getOrDefault ["targetSlot",""]],
 ["recipe",[_recipe] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy]
];
private _planR = [_unit,_kit] call ServoPeregrino_Organizador_Weapons_fnc_createApplicationPlan;
if !(_planR getOrDefault ["success",false]) exitWith {[_planR] call _preFailure};
private _plan = (_planR get "data") get "plan";
private _snapshotR = [_unit,_plan] call ServoPeregrino_Organizador_Weapons_fnc_captureApplicationSnapshot;
if !(_snapshotR getOrDefault ["success",false]) exitWith {[_snapshotR] call _preFailure};
private _snapshot = (_snapshotR get "data") get "snapshot";
private _result = [_unit,_plan,_snapshot,_labFault] call ServoPeregrino_Organizador_Weapons_fnc_applyApplicationPlan;
private _data = _result getOrDefault ["data",createHashMap];
_data set ["sourceKind","CURRENT_UNSAVED_DRAFT"];
_data set ["repositoryMutation",false];
_data set ["draftMutation",false];
_data set ["plan",_plan];
_data set ["snapshot",_snapshot];
_data set ["undo","UNDO_DEFERRED"];
_result set ["data",_data];
_result
