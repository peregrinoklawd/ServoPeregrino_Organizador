params [["_value",false]];
private _normal = [_value] call ServoPeregrino_Organizador_Weapons_fnc_normalizeWeaponRecipe;
if !(_normal get "success") exitWith {_normal};
private _recipe = (_normal get "data") get "recipe";

private _cfgFpResult = [_recipe get "configuration"] call ServoPeregrino_Organizador_Weapons_fnc_getConfigurationFingerprint;
if !(_cfgFpResult get "success") exitWith {_cfgFpResult};
private _cfgFingerprint = (_cfgFpResult get "data") get "fingerprint";

private _fingerprint = str [
 "0.4-recipe-candidate",
 _cfgFingerprint,
 toLowerANSI (_recipe get "magazineClass")
];

[true,"WEAPONS_RECIPE_FINGERPRINT","Recipe comparison fingerprint only; it is not WeaponInstance identity.",createHashMapFromArray [
 ["fingerprint",_fingerprint]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
