params [["_value",false]];
private _normal = [_value] call ServoPeregrino_Organizador_Weapons_fnc_normalizeWeaponRecipe;
if !(_normal get "success") exitWith {_normal};
private _recipe = (_normal get "data") get "recipe";
private _configuration = _recipe get "configuration";

private _cfgSemantic = [_configuration] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponConfigurationSemantic;
if !(_cfgSemantic get "success") exitWith {
 [false,"WEAPONS_RECIPE_CONFIGURATION_INCOMPATIBLE","Nested WeaponConfiguration failed semantic validation.",createHashMapFromArray [
  ["nestedCode",_cfgSemantic get "code"]
 ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _weaponClass = _configuration get "weaponClass";
private _magazineClass = _recipe get "magazineClass";
private _magazineError = createHashMap;
if !(_magazineClass isEqualTo "") then {
 private _compat = [_weaponClass] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponCompatibility;
 if !(_compat get "success") then {
  _magazineError = _compat;
 } else {
  private _allowed = ((_compat get "data") get "magazines") apply {toLowerANSI _x};
  if !((toLowerANSI _magazineClass) in _allowed) then {
   _magazineError = [false,"WEAPONS_RECIPE_MAGAZINE_INCOMPATIBLE","Requested magazineClass is not compatible with recipe weaponClass.",createHashMapFromArray [
    ["weaponClass",_weaponClass],
    ["magazineClass",_magazineClass]
   ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult;
  };
 };
};
if (count _magazineError > 0) exitWith {_magazineError};

[true,"WEAPONS_RECIPE_SEMANTIC_VALID","WeaponRecipe configuration and optional magazine are compatible with engine data.",createHashMapFromArray [
 ["weaponClass",_weaponClass],
 ["magazineClass",_magazineClass]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
