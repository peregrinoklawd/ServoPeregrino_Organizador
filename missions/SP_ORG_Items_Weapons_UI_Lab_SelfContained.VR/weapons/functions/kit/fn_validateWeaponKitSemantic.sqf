params [["_value",false]];
private _normal = [_value] call ServoPeregrino_Organizador_Weapons_fnc_normalizeWeaponKit;
if !(_normal get "success") exitWith {_normal};
private _kit = (_normal get "data") get "kit";

private _recipeSemantic = [_kit get "recipe"] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponRecipeSemantic;
if !(_recipeSemantic get "success") exitWith {
 [false,"WEAPONS_KIT_RECIPE_INCOMPATIBLE","Nested WeaponRecipe failed semantic validation.",createHashMapFromArray [
  ["nestedCode",_recipeSemantic get "code"]
 ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _weaponClass = (((_kit get "recipe") get "configuration") get "weaponClass");
private _cfg = configFile >> "CfgWeapons" >> _weaponClass;
private _type = getNumber (_cfg >> "type");
private _expectedSlot = switch (_type) do {
 case 1: {"PRIMARY"};
 case 2: {"HANDGUN"};
 case 4: {"SECONDARY"};
 default {""};
};

if (_expectedSlot isEqualTo "") exitWith {
 [false,"WEAPONS_KIT_WEAPON_TYPE_UNSUPPORTED","Recipe weapon is not a supported infantry weapon type."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

if !((_kit get "targetSlot") isEqualTo _expectedSlot) exitWith {
 [false,"WEAPONS_KIT_SLOT_RECIPE_MISMATCH","WeaponKit targetSlot must match the recipe weapon engine category.",createHashMapFromArray [
  ["targetSlot",_kit get "targetSlot"],
  ["expectedSlot",_expectedSlot],
  ["weaponClass",_weaponClass]
 ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

[true,"WEAPONS_KIT_SEMANTIC_VALID","WeaponKit name, slot and Recipe are valid.",createHashMapFromArray [
 ["weaponClass",_weaponClass],
 ["targetSlot",_expectedSlot]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
