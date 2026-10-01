params [["_value",false]];
if !(_value isEqualType createHashMap) exitWith {
 [false,"WEAPONS_RECIPE_PAYLOAD_INVALID","Expected HashMap."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _keys = ["schemaVersion","configuration","magazineClass"];
if !((count _value) isEqualTo count _keys && {{_x in _value} count _keys isEqualTo count _keys}) exitWith {
 [false,"WEAPONS_RECIPE_FIELDS_INVALID","Closed candidate schema. WeaponRecipe contains only schemaVersion, configuration and optional magazineClass. Name, targetSlot, ammo count and persistence metadata belong to later layers."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

if !((_value get "schemaVersion") isEqualTo "0.4-recipe-candidate") exitWith {
 [false,"WEAPONS_RECIPE_SCHEMA_INCOMPATIBLE","WeaponRecipe candidate schema mismatch."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

if !((_value get "configuration") isEqualType createHashMap) exitWith {
 [false,"WEAPONS_RECIPE_CONFIGURATION_TYPE_INVALID","configuration must be a WeaponConfiguration HashMap."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

if !((_value get "magazineClass") isEqualType "") exitWith {
 [false,"WEAPONS_RECIPE_MAGAZINE_TYPE_INVALID","magazineClass must be a string."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _cfgValidation = [_value get "configuration"] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponConfigurationStructural;
if !(_cfgValidation get "success") exitWith {
 [false,"WEAPONS_RECIPE_CONFIGURATION_INVALID","Nested WeaponConfiguration failed structural validation.",createHashMapFromArray [
  ["nestedCode",_cfgValidation get "code"]
 ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

[true,"WEAPONS_RECIPE_STRUCTURAL_VALID","WeaponRecipe structural validation passed."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
