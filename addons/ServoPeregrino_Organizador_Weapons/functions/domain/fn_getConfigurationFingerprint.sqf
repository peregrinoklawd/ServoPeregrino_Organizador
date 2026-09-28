params [["_value",false]];
private _normal = [_value] call ServoPeregrino_Organizador_Weapons_fnc_normalizeWeaponConfiguration;
if !(_normal get "success") exitWith {_normal};
private _c = (_normal get "data") get "configuration";
// Canonical comparison key only. Stored class spelling is preserved; ammo/magazines are transient loaded state.
private _fingerprint = str (["schemaVersion","weaponClass","muzzle","pointer","optic","bipod"] apply {
 private _v = _c get _x;
 if (_v isEqualType "") then {toLowerANSI _v} else {_v}
});
[true,"WEAPONS_FINGERPRINT","Configuration fingerprint only; loaded ammo is excluded and fingerprint is NEVER identity.",createHashMapFromArray [["fingerprint",_fingerprint]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
