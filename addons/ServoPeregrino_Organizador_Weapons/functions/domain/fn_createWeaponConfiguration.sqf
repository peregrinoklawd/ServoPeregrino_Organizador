params [["_weaponClass","",[""]]];
private _candidate = createHashMapFromArray [
 ["schemaVersion","0.1-A-candidate"],["weaponClass",_weaponClass],
 ["muzzle",""],["pointer",""],["optic",""],["bipod",""]
];
[_candidate] call ServoPeregrino_Organizador_Weapons_fnc_normalizeWeaponConfiguration
