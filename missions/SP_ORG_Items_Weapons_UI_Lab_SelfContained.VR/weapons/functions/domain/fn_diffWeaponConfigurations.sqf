params [["_left",false],["_right",false]];

private _aResult = [_left] call ServoPeregrino_Organizador_Weapons_fnc_normalizeWeaponConfiguration;
if !(_aResult get "success") exitWith {_aResult};
private _bResult = [_right] call ServoPeregrino_Organizador_Weapons_fnc_normalizeWeaponConfiguration;
if !(_bResult get "success") exitWith {_bResult};

private _a = (_aResult get "data") get "configuration";
private _b = (_bResult get "data") get "configuration";

private _sameClass = (toLowerANSI (_a get "weaponClass")) isEqualTo (toLowerANSI (_b get "weaponClass"));
private _changes = [];

{
 private _field = _x;
 private _from = _a get _field;
 private _to = _b get _field;
 if !((toLowerANSI _from) isEqualTo (toLowerANSI _to)) then {
  _changes pushBack createHashMapFromArray [
   ["field",_field],
   ["from",_from],
   ["to",_to]
  ];
 };
} forEach ["muzzle","pointer","optic","bipod"];

[true,"WEAPONS_CONFIGURATION_DIFF","WeaponConfiguration diff computed.",createHashMapFromArray [
 ["sameWeaponClass",_sameClass],
 ["equal",_sameClass && {count _changes isEqualTo 0}],
 ["changedCount",count _changes],
 ["changes",_changes]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
