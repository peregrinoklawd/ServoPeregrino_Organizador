params [
 ["_unit",objNull,[objNull]],
 ["_plan",false],
 ["_snapshot",false]
];

if (isNull _unit || {!(_unit isKindOf "CAManBase")}) exitWith {
 [false,"WEAPONS_APPLICATION_TARGET_INVALID","Expected infantry unit."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if (!local _unit) exitWith {
 [false,"WEAPONS_APPLICATION_TARGET_NOT_LOCAL","0.7-B slot-safe apply requires a local unit. Multiplayer authority remains deferred to 0.8."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _planValid = [_plan] call ServoPeregrino_Organizador_Weapons_fnc_validateApplicationPlan;
if !(_planValid getOrDefault ["success",false]) exitWith {_planValid};
private _snapshotValid = [_snapshot] call ServoPeregrino_Organizador_Weapons_fnc_validateApplicationSnapshot;
if !(_snapshotValid getOrDefault ["success",false]) exitWith {_snapshotValid};

if !((_plan get "targetSlot") isEqualTo (_snapshot get "targetSlot") && {(_plan get "targetSlotIndex") isEqualTo (_snapshot get "targetSlotIndex")}) exitWith {
 [false,"WEAPONS_APPLICATION_APPLY_CONTEXT_MISMATCH","Plan and Snapshot do not address the same target slot."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _currentLoadout = getUnitLoadout _unit;
if !(_currentLoadout isEqualTo (_snapshot get "capturedLoadout")) exitWith {
 [false,"WEAPONS_APPLICATION_APPLY_STALE_SNAPSHOT","Unit loadout changed after snapshot capture; physical mutation was refused.",createHashMapFromArray [
  ["mutationPerformed",false],
  ["rollbackAttempted",false]
 ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _built = [_plan,_snapshot] call ServoPeregrino_Organizador_Weapons_fnc_buildApplicationTargetLoadout;
if !(_built getOrDefault ["success",false]) exitWith {_built};
private _builtData = _built get "data";
private _targetLoadout = _builtData get "targetLoadout";
private _operation = _plan get "operation";

if (_operation isEqualTo "NO_OP") exitWith {
 private _validation = [_unit,_plan,_snapshot] call ServoPeregrino_Organizador_Weapons_fnc_validateAppliedApplicationState;
 if !(_validation getOrDefault ["success",false]) exitWith {_validation};
 [true,"WEAPONS_APPLICATION_ALREADY_APPLIED","0.7-B detected NO_OP; no physical mutation was performed.",createHashMapFromArray [
  ["targetSlot",_plan get "targetSlot"],
  ["operation",_operation],
  ["mutationPerformed",false],
  ["fullMagazines",false],
  ["ammoPolicy",_builtData get "ammoPolicy"],
  ["postValidation",_validation get "data"],
  ["rollbackAttempted",false]
 ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

_unit setUnitLoadout [_targetLoadout,false];
_unit setAnimSpeedCoef (_snapshot getOrDefault ["animSpeedCoef",1]);

private _validation = [_unit,_plan,_snapshot] call ServoPeregrino_Organizador_Weapons_fnc_validateAppliedApplicationState;
if !(_validation getOrDefault ["success",false]) exitWith {
 private _rollbackLoadout = [(_snapshot get "capturedLoadout")] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 _unit setUnitLoadout [_rollbackLoadout,false];
 _unit setAnimSpeedCoef (_snapshot getOrDefault ["animSpeedCoef",1]);
 private _rollbackRestored = (getUnitLoadout _unit) isEqualTo (_snapshot get "capturedLoadout");

 [false,"WEAPONS_APPLICATION_APPLY_VERIFY_FAILED","0.7-B post-validation failed. Snapshot restoration was attempted immediately; forced-failure rollback hardening remains the 0.7-C gate.",createHashMapFromArray [
  ["targetSlot",_plan get "targetSlot"],
  ["operation",_operation],
  ["mutationPerformed",true],
  ["fullMagazines",false],
  ["ammoPolicy",_builtData get "ammoPolicy"],
  ["postValidationCode",_validation getOrDefault ["code",""]],
  ["postValidation",_validation getOrDefault ["data",createHashMap]],
  ["rollbackAttempted",true],
  ["rollbackRestoredExactly",_rollbackRestored]
 ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

[true,"WEAPONS_APPLICATION_APPLIED","0.7-B applied the planned WeaponKit to the target slot and verified target state plus all non-target preservation domains.",createHashMapFromArray [
 ["targetSlot",_plan get "targetSlot"],
 ["targetSlotIndex",_plan get "targetSlotIndex"],
 ["operation",_operation],
 ["mutationPerformed",true],
 ["fullMagazines",false],
 ["ammoPolicy",_builtData get "ammoPolicy"],
 ["postValidation",_validation get "data"],
 ["rollbackAttempted",false],
 ["strategy","FULL_LOADOUT_CLONE_SETUNITLOADOUT_FALSE"]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
