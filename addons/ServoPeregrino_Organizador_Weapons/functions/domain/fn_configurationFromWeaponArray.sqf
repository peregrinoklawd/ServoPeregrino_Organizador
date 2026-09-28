params [["_row",false]];
if !(_row isEqualType [] && {count _row isEqualTo 7}) exitWith {[false,"WEAPONS_CAPTURE_SHAPE_INVALID","Expected standard seven-field weapon array."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _c = createHashMapFromArray [
 ["schemaVersion","0.1-A-candidate"],["weaponClass",_row select 0],
 ["muzzle",_row select 1],["pointer",_row select 2],["optic",_row select 3],
 ["primaryMagazine",_row select 4],["secondaryMagazine",_row select 5],["bipod",_row select 6]
];
[_c] call ServoPeregrino_Organizador_Weapons_fnc_normalizeWeaponConfiguration
