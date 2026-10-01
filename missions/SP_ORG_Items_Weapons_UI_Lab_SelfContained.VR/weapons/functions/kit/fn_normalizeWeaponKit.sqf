params [["_value",false]];
private _valid = [_value] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponKitStructural;
if !(_valid get "success") exitWith {_valid};

private _nameResult = [_value get "name"] call ServoPeregrino_Organizador_Weapons_fnc_normalizeWeaponKitName;
if !(_nameResult get "success") exitWith {_nameResult};

private _slot = toUpperANSI (_value get "targetSlot");
if !(_slot in ["PRIMARY","HANDGUN","SECONDARY"]) exitWith {
 [false,"WEAPONS_KIT_SLOT_INVALID","targetSlot must be PRIMARY, HANDGUN or SECONDARY."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _recipeResult = [_value get "recipe"] call ServoPeregrino_Organizador_Weapons_fnc_normalizeWeaponRecipe;
if !(_recipeResult get "success") exitWith {_recipeResult};

private _copy = [_value] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
_copy set ["name",(_nameResult get "data") get "name"];
_copy set ["targetSlot",_slot];
_copy set ["recipe",(_recipeResult get "data") get "recipe"];

[true,"WEAPONS_KIT_NORMALIZED","WeaponKit normalized without inventory mutation.",createHashMapFromArray [
 ["kit",_copy]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
