params [["_value",false]];
private _normal = [_value] call ServoPeregrino_Organizador_Weapons_fnc_normalizeWeaponConfiguration;
if !(_normal get "success") exitWith {_normal};
private _c = (_normal get "data") get "configuration";
// Lossless ordered canonical serialization, not a lossy hash and NEVER an identity.
private _fingerprint = str (["schemaVersion","weaponClass","muzzle","pointer","optic","bipod","primaryMagazine","secondaryMagazine"] apply {_c get _x});
[true,"WEAPONS_FINGERPRINT","Configuration fingerprint only.",createHashMapFromArray [["fingerprint",_fingerprint]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
