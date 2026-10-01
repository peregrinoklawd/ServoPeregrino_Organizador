params [
 ["_observations",[],[[]]],
 ["_fingerprint","",[""]]
];

private _count = 0;
{
 if (_x isEqualType createHashMap && {
  (_x getOrDefault ["configurationFingerprint",""]) isEqualTo _fingerprint
 }) then {
  _count = _count + 1;
 };
} forEach _observations;

_count
