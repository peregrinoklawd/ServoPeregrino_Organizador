params [
 ["_unit",objNull,[objNull]],
 ["_plan",false],
 ["_snapshot",false]
];

if (isNull _unit || {!(_unit isKindOf "CAManBase")}) exitWith {
 [false,"WEAPONS_APPLICATION_TARGET_INVALID","Expected infantry unit."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _planValid = [_plan] call ServoPeregrino_Organizador_Weapons_fnc_validateApplicationPlan;
if !(_planValid getOrDefault ["success",false]) exitWith {_planValid};
private _snapshotValid = [_snapshot] call ServoPeregrino_Organizador_Weapons_fnc_validateApplicationSnapshot;
if !(_snapshotValid getOrDefault ["success",false]) exitWith {_snapshotValid};

if !((_plan get "targetSlot") isEqualTo (_snapshot get "targetSlot") && {(_plan get "targetSlotIndex") isEqualTo (_snapshot get "targetSlotIndex")}) exitWith {
 [false,"WEAPONS_APPLICATION_VALIDATE_CONTEXT_MISMATCH","Plan and Snapshot do not address the same target slot."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _built = [_plan,_snapshot] call ServoPeregrino_Organizador_Weapons_fnc_buildApplicationTargetLoadout;
if !(_built getOrDefault ["success",false]) exitWith {_built};
private _builtData = _built get "data";
private _expectedRow = _builtData get "targetRow";
private _ammoPolicy = _builtData get "ammoPolicy";

private _slot = _plan get "targetSlot";
private _slotIndex = _plan get "targetSlotIndex";
private _afterLoadout = getUnitLoadout _unit;
private _afterFingerprintResult = [_afterLoadout,_slot] call ServoPeregrino_Organizador_Weapons_fnc_getApplicationPreservationFingerprint;
if !(_afterFingerprintResult getOrDefault ["success",false]) exitWith {_afterFingerprintResult};

private _afterFingerprint = ((_afterFingerprintResult get "data") get "fingerprint");
private _preservationMatched = _afterFingerprint isEqualTo (_snapshot get "preservationFingerprint");

private _observedRow = _afterLoadout param [_slotIndex,[]];
private _observedOccupied = _observedRow isEqualType [] && {count _observedRow isEqualTo 7} && {(_observedRow param [0,""]) != ""};
private _configurationMatched = false;
private _classEquivalent = false;
private _captureError = createHashMap;
private _observedConfiguration = createHashMap;

if (_observedOccupied) then {
 private _capture = [_observedRow] call ServoPeregrino_Organizador_Weapons_fnc_configurationFromWeaponArray;
 if !(_capture getOrDefault ["success",false]) then {
  _captureError = _capture;
 } else {
  _observedConfiguration = ((_capture get "data") get "configuration");
  private _desiredConfiguration = _plan get "desiredConfiguration";
  private _equiv = [
   _observedConfiguration getOrDefault ["weaponClass",""],
   _desiredConfiguration getOrDefault ["weaponClass",""],
   _slot
  ] call ServoPeregrino_Organizador_Weapons_fnc_areWeaponClassesEquivalentForSlot;
  if !(_equiv getOrDefault ["success",false]) then {
   _captureError = _equiv;
  } else {
   _classEquivalent = ((_equiv get "data") getOrDefault ["equivalent",false]);
   private _diff = [_desiredConfiguration,_observedConfiguration] call ServoPeregrino_Organizador_Weapons_fnc_diffWeaponConfigurations;
   _configurationMatched = _diff getOrDefault ["success",false] && {
    ((_diff get "data") getOrDefault ["changedCount",-1]) isEqualTo 0
   } && {_classEquivalent};
  };
 };
};
if (count _captureError > 0) exitWith {_captureError};

private _magEqual = {
 params ["_expected","_observed"];
 if (_expected isEqualTo [] && {_observed isEqualTo []}) exitWith {true};
 if !(_expected isEqualType [] && {_observed isEqualType []} && {count _expected >= 2} && {count _observed >= 2}) exitWith {false};
 (toLowerANSI (_expected param [0,""])) isEqualTo (toLowerANSI (_observed param [0,""]))
 && {(_expected param [1,-1]) isEqualTo (_observed param [1,-2])}
};

private _expectedPrimary = _expectedRow param [4,[]];
private _observedPrimary = if (_observedOccupied) then {_observedRow param [4,[]]} else {[]};
private _primaryMagazineMatched = [_expectedPrimary,_observedPrimary] call _magEqual;

private _expectedSecondary = _expectedRow param [5,[]];
private _observedSecondary = if (_observedOccupied) then {_observedRow param [5,[]]} else {[]};
private _secondaryMagazineMatched = [_expectedSecondary,_observedSecondary] call _magEqual;

private _animMatched = (getAnimSpeedCoef _unit) isEqualTo (_snapshot get "animSpeedCoef");
private _success = _animMatched && {_preservationMatched} && {_configurationMatched} && {_primaryMagazineMatched} && {_secondaryMagazineMatched};

[
 _success,
 if (_success) then {"WEAPONS_APPLICATION_POST_VALIDATION_OK"} else {"WEAPONS_APPLICATION_POST_VALIDATION_FAILED"},
 if (_success) then {"Target slot matches the planned configuration and every non-target preservation domain remained equivalent."} else {"Post-validation detected target or non-target divergence."},
 createHashMapFromArray [
  ["targetSlot",_slot],
  ["targetSlotIndex",_slotIndex],
  ["preservationMatched",_preservationMatched],
  ["animSpeedMatched",_animMatched],
  ["expectedPreservationFingerprint",_snapshot get "preservationFingerprint"],
  ["observedPreservationFingerprint",_afterFingerprint],
  ["configurationMatched",_configurationMatched],
  ["classEquivalent",_classEquivalent],
  ["primaryMagazineMatched",_primaryMagazineMatched],
  ["secondaryMagazineMatched",_secondaryMagazineMatched],
  ["ammoPolicy",_ammoPolicy],
  ["expectedTargetRow",[_expectedRow] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
  ["observedTargetRow",[_observedRow] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
  ["observedConfiguration",[_observedConfiguration] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy]
 ]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
