params [["_value",false]];
if !(_value isEqualType createHashMap) exitWith {
 [false,"WEAPONS_KIT_PAYLOAD_INVALID","Expected WeaponKit HashMap."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _keys = ["schemaVersion","kitId","name","targetSlot","recipe"];
if !((count _value) isEqualTo count _keys && {{_x in _value} count _keys isEqualTo count _keys}) exitWith {
 [false,"WEAPONS_KIT_FIELDS_INVALID","Closed candidate schema. WeaponKit contains only schemaVersion, kitId, name, targetSlot and recipe."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

if !((_value get "schemaVersion") isEqualTo "0.5-kit-candidate") exitWith {
 [false,"WEAPONS_KIT_SCHEMA_INCOMPATIBLE","WeaponKit candidate schema mismatch."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

if !((_value get "kitId") isEqualType "" && {!((_value get "kitId") isEqualTo "")}) exitWith {
 [false,"WEAPONS_KIT_ID_INVALID","kitId must be a non-empty string."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if !(((_value get "kitId") select [0,4]) isEqualTo "WKT-") exitWith {
 [false,"WEAPONS_KIT_ID_INVALID","kitId must use WKT- prefix."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

if !((_value get "name") isEqualType "") exitWith {
 [false,"WEAPONS_KIT_NAME_TYPE_INVALID","name must be a string."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if !((_value get "targetSlot") isEqualType "") exitWith {
 [false,"WEAPONS_KIT_SLOT_TYPE_INVALID","targetSlot must be a string."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if !((_value get "recipe") isEqualType createHashMap) exitWith {
 [false,"WEAPONS_KIT_RECIPE_TYPE_INVALID","recipe must be a WeaponRecipe HashMap."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _recipeStructural = [_value get "recipe"] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponRecipeStructural;
if !(_recipeStructural get "success") exitWith {
 [false,"WEAPONS_KIT_RECIPE_INVALID","Nested WeaponRecipe failed structural validation.",createHashMapFromArray [
  ["nestedCode",_recipeStructural get "code"]
 ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

[true,"WEAPONS_KIT_STRUCTURAL_VALID","WeaponKit structural validation passed."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
