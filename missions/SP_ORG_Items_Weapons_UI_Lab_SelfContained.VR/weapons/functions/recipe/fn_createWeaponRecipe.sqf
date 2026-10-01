params [
 ["_configuration",false],
 ["_magazineClass","",[""]]
];

if !(_configuration isEqualType createHashMap) exitWith {
 [false,"WEAPONS_RECIPE_CONFIGURATION_TYPE_INVALID","createWeaponRecipe expects a WeaponConfiguration HashMap."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _candidate = createHashMapFromArray [
 ["schemaVersion","0.4-recipe-candidate"],
 ["configuration",[_configuration] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
 ["magazineClass",_magazineClass]
];

private _semantic = [_candidate] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponRecipeSemantic;
if !(_semantic get "success") exitWith {_semantic};

private _normal = [_candidate] call ServoPeregrino_Organizador_Weapons_fnc_normalizeWeaponRecipe;
if !(_normal get "success") exitWith {_normal};

[true,"WEAPONS_RECIPE_CREATED","WeaponRecipe candidate created. No inventory mutation performed.",createHashMapFromArray [
 ["recipe",(_normal get "data") get "recipe"]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
