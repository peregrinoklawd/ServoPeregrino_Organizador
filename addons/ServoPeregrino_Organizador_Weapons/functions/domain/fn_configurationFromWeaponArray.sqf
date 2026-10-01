params [["_row",false]];
if !(_row isEqualType [] && {count _row isEqualTo 7}) exitWith {[false,"WEAPONS_CAPTURE_SHAPE_INVALID","Expected standard seven-field weapon array."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _c = createHashMapFromArray [
 ["schemaVersion","0.1-A-candidate"],["weaponClass",_row select 0],
 ["muzzle",_row select 1],["pointer",_row select 2],["optic",_row select 3],["bipod",_row select 6]
];
private _normal = [_c] call ServoPeregrino_Organizador_Weapons_fnc_normalizeWeaponConfiguration;
if !(_normal get "success") exitWith {_normal};
private _loaded = createHashMapFromArray [
 ["schemaVersion","0.1-A-loaded-state-candidate"],
 ["primaryMagazine",[_row select 4] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
 ["secondaryMagazine",[_row select 5] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy]
];
private _bad = ["primaryMagazine","secondaryMagazine"] findIf {
 private _mag = _loaded get _x;
 !(_mag isEqualType []) || {!(_mag isEqualTo []) && {
  !(count _mag >= 2 && {(_mag select 0) isEqualType ""} && {(_mag select 0) != ""} && {(_mag select 1) isEqualType 0} && {finite (_mag select 1)} && {(_mag select 1) >= 0})
 }}
};
if (_bad >= 0) exitWith {[false,"WEAPONS_LOADED_STATE_INVALID","Magazine/ammo snapshot is malformed."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
[true,"WEAPONS_WEAPON_ARRAY_CAPTURED","Configuration separated from transient loaded state.",createHashMapFromArray [
 ["configuration",(_normal get "data") get "configuration"],["loadedState",_loaded]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
