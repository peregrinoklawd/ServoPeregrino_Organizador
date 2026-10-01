params [
 ["_transition","",[""]],
 ["_beforeObservations",[],[[]]],
 ["_afterObservations",[],[[]]]
];

private _direction = toUpperANSI _transition;
if !(_direction in ["PUT","TAKE"]) exitWith {
 [false,"WEAPONS_LIFECYCLE_TRANSITION_INVALID","Expected PUT or TAKE."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _fingerprints = [];
{
 if (_x isEqualType createHashMap) then {
  private _fp = _x getOrDefault ["configurationFingerprint",""];
  if (_fp != "") then {_fingerprints pushBackUnique _fp};
 };
} forEach (_beforeObservations + _afterObservations);

private _changed = [];
{
 private _fp = _x;
 private _before = [_beforeObservations,_fp] call ServoPeregrino_Organizador_Weapons_fnc_getFingerprintMultiplicity;
 private _after = [_afterObservations,_fp] call ServoPeregrino_Organizador_Weapons_fnc_getFingerprintMultiplicity;
 private _delta = if (_direction isEqualTo "PUT") then {_after - _before} else {_before - _after};
 if (_delta isEqualTo 1) then {
  _changed pushBack createHashMapFromArray [
   ["fingerprint",_fp],["beforeCount",_before],["afterCount",_after]
  ];
 };
} forEach _fingerprints;

if (count _changed isEqualTo 0) exitWith {
 [false,"WEAPONS_LIFECYCLE_DELTA_NOT_FOUND","No single-weapon lifecycle delta detected.",createHashMapFromArray [["changed",[]]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if (count _changed > 1) exitWith {
 [false,"WEAPONS_LIFECYCLE_DELTA_MULTI","More than one fingerprint changed; event evidence is insufficient.",createHashMapFromArray [["changed",_changed]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

[true,"WEAPONS_LIFECYCLE_DELTA_DETECTED","Exactly one fingerprint multiplicity changed by one.",createHashMapFromArray [["changed",_changed]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
