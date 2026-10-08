params [
 ["_unit",objNull,[objNull]],
 ["_plan",false],
 ["_snapshot",false],
 ["_labFault","",[""]]
];

if (isNull _unit || {!(_unit isKindOf "CAManBase")}) exitWith {
 [false,"WEAPONS_APPLICATION_TARGET_INVALID","Expected infantry unit.",createHashMapFromArray [["failurePhase","PRE_MUTATION"],["mutationPerformed",false],["rollbackAttempted",false]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if (!local _unit) exitWith {
 [false,"WEAPONS_APPLICATION_TARGET_NOT_LOCAL","0.7-B slot-safe apply requires a local unit. Multiplayer authority remains deferred to 0.8.",createHashMapFromArray [["failurePhase","PRE_MUTATION"],["mutationPerformed",false],["rollbackAttempted",false]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _faultAuthorized = _labFault isEqualTo "" || {
 (missionNamespace getVariable ["SP_ORG_Weapons_LabEnabled",false]) && {isServer} && {!isRemoteExecuted} && {!isPlayer _unit} && {_unit getVariable ["SP_ORG_Weapons_IsolatedFaultTarget",false]} && {_labFault in ["TARGET_DIVERGENCE","PROTECTED_DIVERGENCE","AMMO_DIVERGENCE"]}
};
if (!_faultAuthorized) exitWith {
 [false,"WEAPONS_LAB_FAULT_REFUSED","Fault injection is isolated LAB only.",createHashMapFromArray [["failurePhase","PRE_MUTATION"],["mutationPerformed",false],["rollbackAttempted",false]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _preFailure = {
 params ["_result"];
 private _data = _result getOrDefault ["data",createHashMap];
 _data set ["failurePhase","PRE_MUTATION"];
 _data set ["mutationPerformed",false];
 _data set ["rollbackAttempted",false];
 _result set ["data",_data];
 _result
};
private _planValid = [_plan] call ServoPeregrino_Organizador_Weapons_fnc_validateApplicationPlan;
if !(_planValid getOrDefault ["success",false]) exitWith {[_planValid] call _preFailure};
private _snapshotValid = [_snapshot] call ServoPeregrino_Organizador_Weapons_fnc_validateApplicationSnapshot;
if !(_snapshotValid getOrDefault ["success",false]) exitWith {[_snapshotValid] call _preFailure};

if !((_plan get "targetSlot") isEqualTo (_snapshot get "targetSlot") && {(_plan get "targetSlotIndex") isEqualTo (_snapshot get "targetSlotIndex")}) exitWith {
 [false,"WEAPONS_APPLICATION_APPLY_CONTEXT_MISMATCH","Plan and Snapshot do not address the same target slot.",createHashMapFromArray [["failurePhase","PRE_MUTATION"],["mutationPerformed",false],["rollbackAttempted",false]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _currentLoadout = getUnitLoadout _unit;
if !(_currentLoadout isEqualTo (_snapshot get "capturedLoadout")) exitWith {
 [false,"WEAPONS_APPLICATION_APPLY_STALE_SNAPSHOT","Unit loadout changed after snapshot capture; physical mutation was refused.",createHashMapFromArray [
  ["mutationPerformed",false],
  ["failurePhase","PRE_MUTATION"],
  ["rollbackAttempted",false]
 ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _built = [_plan,_snapshot] call ServoPeregrino_Organizador_Weapons_fnc_buildApplicationTargetLoadout;
if !(_built getOrDefault ["success",false]) exitWith {[_built] call _preFailure};
private _builtData = _built get "data";
private _targetLoadout = _builtData get "targetLoadout";
private _operation = _plan get "operation";

if (_operation isEqualTo "NO_OP") exitWith {
 private _validation = [_unit,_plan,_snapshot] call ServoPeregrino_Organizador_Weapons_fnc_validateAppliedApplicationState;
 if !(_validation getOrDefault ["success",false]) exitWith {[_validation] call _preFailure};
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

private _mutatedBeforeFault = [getUnitLoadout _unit] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
if !(_labFault isEqualTo "") then {
 private _faultLoadout = [_mutatedBeforeFault] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 switch (_labFault) do {
  case "TARGET_DIVERGENCE": {_faultLoadout set [_plan get "targetSlotIndex",[]]};
  case "PROTECTED_DIVERGENCE": {_faultLoadout set [6,if ((_faultLoadout param [6,""]) isEqualTo "H_HelmetB") then {"H_HelmetB_light"} else {"H_HelmetB"}]};
  case "AMMO_DIVERGENCE": {
   private _row = _faultLoadout select (_plan get "targetSlotIndex");
   private _mag = _row param [4,[]];
   if (count _mag >= 2) then {_mag set [1,if ((_mag select 1) isEqualTo 1) then {2} else {1}]};
   _row set [4,_mag];
  };
 };
 _unit setUnitLoadout [_faultLoadout,false];
 _unit setAnimSpeedCoef 0.75;
 diag_log format ["[SP_ORG] [WEAPONS] [LAB_FAULT] mode=%1 mutationBeforeFault=%2",_labFault,!(_mutatedBeforeFault isEqualTo (_snapshot get "capturedLoadout"))];
};

private _validation = [_unit,_plan,_snapshot] call ServoPeregrino_Organizador_Weapons_fnc_validateAppliedApplicationState;
if !(_validation getOrDefault ["success",false]) exitWith {
 private _rollback = [_unit,_snapshot] call ServoPeregrino_Organizador_Weapons_fnc_rollbackApplicationSnapshot;
 private _rollbackData = _rollback getOrDefault ["data",createHashMap];
 private _rollbackRestored = _rollback getOrDefault ["success",false];

 [false,if (_rollbackRestored) then {"WEAPONS_APPLICATION_APPLY_VERIFY_FAILED"} else {"WEAPONS_APPLICATION_ROLLBACK_FAILED"},"Post-mutation verification failed; explicit snapshot rollback was attempted and verified.",createHashMapFromArray [
  ["targetSlot",_plan get "targetSlot"],
  ["operation",_operation],
  ["mutationPerformed",true],
  ["fullMagazines",false],
  ["ammoPolicy",_builtData get "ammoPolicy"],
  ["postValidationCode",_validation getOrDefault ["code",""]],
  ["postValidation",_validation getOrDefault ["data",createHashMap]],
  ["rollbackAttempted",true],
  ["rollbackRestoredExactly",_rollbackData getOrDefault ["rollbackRestoredExactly",false]],
  ["rollbackSucceeded",_rollbackRestored],
  ["failurePhase",if (_rollbackRestored) then {"POST_MUTATION_ROLLBACK_SUCCEEDED"} else {"POST_MUTATION_ROLLBACK_FAILED"}],
  ["rollback",_rollbackData],["rollbackCode",_rollback getOrDefault ["code",""]],
  ["labFault",_labFault],["mutatedBeforeFault",_mutatedBeforeFault]
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
