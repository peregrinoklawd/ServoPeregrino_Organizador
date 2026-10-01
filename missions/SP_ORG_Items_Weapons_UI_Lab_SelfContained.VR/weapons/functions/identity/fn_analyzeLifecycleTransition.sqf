params [
 ["_transition","",[""]],
 ["_beforeObservations",[],[[]]],
 ["_afterObservations",[],[[]]],
 ["_fingerprint","",[""]],
 ["_instanceId","",[""]],
 ["_fromLocator",createHashMap,[createHashMap]],
 ["_toLocator",createHashMap,[createHashMap]]
];

private _direction = toUpperANSI _transition;
if !(_direction in ["PUT","TAKE"]) exitWith {
 [false,"WEAPONS_LIFECYCLE_TRANSITION_INVALID","Expected PUT or TAKE."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if (_fingerprint isEqualTo "") exitWith {
 [false,"WEAPONS_LIFECYCLE_FINGERPRINT_REQUIRED","Configuration fingerprint required."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _beforeCount = [_beforeObservations,_fingerprint] call ServoPeregrino_Organizador_Weapons_fnc_getFingerprintMultiplicity;
private _afterCount = [_afterObservations,_fingerprint] call ServoPeregrino_Organizador_Weapons_fnc_getFingerprintMultiplicity;

private _status = "UNPROVEN";
private _code = "WEAPONS_LIFECYCLE_DELTA_UNPROVEN";
private _candidates = 0;

if (_direction isEqualTo "PUT") then {
 if (_beforeCount isEqualTo 0 && {_afterCount isEqualTo 1}) then {
  _status = "CORRELATED";
  _code = "WEAPONS_LIFECYCLE_UNIQUE_EVENT_DELTA";
  _candidates = 1;
 } else {
  if (_afterCount isEqualTo (_beforeCount + 1) && {_afterCount > 1}) then {
   _status = "AMBIGUOUS";
   _code = "WEAPONS_LIFECYCLE_IDENTICAL_SET_AMBIGUOUS";
   _candidates = _afterCount;
  };
 };
};

if (_direction isEqualTo "TAKE") then {
 if (_beforeCount isEqualTo 1 && {_afterCount isEqualTo 0}) then {
  _status = "CORRELATED";
  _code = "WEAPONS_LIFECYCLE_UNIQUE_EVENT_DELTA";
  _candidates = 1;
 } else {
  if (_beforeCount isEqualTo (_afterCount + 1) && {_beforeCount > 1}) then {
   _status = "AMBIGUOUS";
   _code = "WEAPONS_LIFECYCLE_IDENTICAL_SET_AMBIGUOUS";
   _candidates = _beforeCount;
  };
 };
};

private _evidence = [
 _instanceId,_direction,_fromLocator,_toLocator,_fingerprint,_code,_status,_candidates
] call ServoPeregrino_Organizador_Weapons_fnc_createLifecycleEvidence;

private _diagnostic = [
 if (_status isEqualTo "CORRELATED") then {"INFO"} else {"WARN"},
 _code,
 if (_status isEqualTo "CORRELATED") then {
  "Unique transition evidence correlates continuity; it still does not prove intrinsic physical identity."
 } else {
  "Transition evidence is insufficient to correlate one physical weapon."
 },
 createHashMapFromArray [
  ["beforeCount",_beforeCount],["afterCount",_afterCount],["evidence",_evidence]
 ]
] call ServoPeregrino_Organizador_Nexus_fnc_createDiagnostic;

[true,_code,"Lifecycle evidence analyzed.",createHashMapFromArray [
 ["beforeCount",_beforeCount],
 ["afterCount",_afterCount],
 ["evidence",_evidence]
],[_diagnostic]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
