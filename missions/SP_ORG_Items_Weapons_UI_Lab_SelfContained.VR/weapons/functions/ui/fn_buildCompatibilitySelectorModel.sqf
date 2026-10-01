#include "..\..\script_version.hpp"
params [
 ["_weaponClass","",[""]],
 ["_recipe",createHashMap,[createHashMap]]
];

if (_weaponClass isEqualTo "") exitWith {
 [false,"WEAPONS_UI_COMPATIBILITY_WEAPON_EMPTY","Weapon class is required for compatibility selectors."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _weaponCfg = configFile >> "CfgWeapons" >> _weaponClass;
if (!isClass _weaponCfg) exitWith {
 [false,"WEAPONS_UI_COMPATIBILITY_WEAPON_UNKNOWN","Weapon class does not exist in CfgWeapons."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _canonicalWeaponClass = configName _weaponCfg;

private _configuration = _recipe getOrDefault ["configuration",createHashMap];
private _recipeWeaponClass = _configuration getOrDefault ["weaponClass",""];
if (
 _recipeWeaponClass isNotEqualTo ""
 && {(toLowerANSI _recipeWeaponClass) isNotEqualTo (toLowerANSI _canonicalWeaponClass)}
) exitWith {
 [false,"WEAPONS_UI_COMPATIBILITY_RECIPE_WEAPON_MISMATCH","Recipe weapon does not match the requested selector weapon.",createHashMapFromArray [
  ["requestedWeaponClass",_canonicalWeaponClass],
  ["recipeWeaponClass",_recipeWeaponClass]
 ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _cache = missionNamespace getVariable ["SP_ORG_Weapons_UI_CompatibilityCache",createHashMap];
private _cacheKey = toLowerANSI _canonicalWeaponClass;
private _compatibility = _cache getOrDefault [_cacheKey,createHashMap];
private _cacheHit = (count _compatibility) > 0;

if (!_cacheHit) then {
 private _compatibilityResult = [_canonicalWeaponClass] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponCompatibility;
 if !(_compatibilityResult get "success") exitWith {
  _compatibility = createHashMapFromArray [
   ["__errorResult",[_compatibilityResult] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy]
  ];
 };
 _compatibility = [(_compatibilityResult get "data")] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 _cache set [_cacheKey,[_compatibility] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy];
 missionNamespace setVariable ["SP_ORG_Weapons_UI_CompatibilityCache",_cache];
};

if (!isNil {_compatibility get "__errorResult"}) exitWith {
 _compatibility get "__errorResult"
};

private _buildSelector = {
 params [
  ["_field","",[""]],
  ["_label","",[""]],
  ["_classes",[],[[]]],
  ["_root",configNull,[configNull]],
  ["_currentClass","",[""]],
  ["_noneLabel","Nenhum",[""]]
 ];

 private _options = [];
 private _currentLower = toLowerANSI _currentClass;
 private _selectedIndex = if (_currentClass isEqualTo "") then {0} else {-1};

 _options pushBack (createHashMapFromArray [
  ["className",""],
  ["displayName",_noneLabel],
  ["selected",_currentClass isEqualTo ""]
 ]);

 {
  if (_x isEqualType "" && {_x isNotEqualTo ""}) then {
   private _cfg = _root >> _x;
   private _canonical = if (isClass _cfg) then {configName _cfg} else {_x};
   private _name = if (isClass _cfg) then {getText (_cfg >> "displayName")} else {""};
   if (_name isEqualTo "") then {_name = _canonical};
   private _selected = (toLowerANSI _canonical) isEqualTo _currentLower;
   private _index = count _options;
   if (_selected) then {_selectedIndex = _index};
   _options pushBack (createHashMapFromArray [
    ["className",_canonical],
    ["displayName",_name],
    ["selected",_selected]
   ]);
  };
 } forEach _classes;

 createHashMapFromArray [
  ["field",_field],
  ["label",_label],
  ["currentClass",_currentClass],
  ["selectedIndex",_selectedIndex],
  ["currentCompatible",_selectedIndex >= 0],
  ["optionCount",count _options],
  ["options",_options],
  ["readOnly",false]
 ]
};

private _slots = _compatibility getOrDefault ["slots",createHashMap];
private _selectors = createHashMap;
private _invalidCurrent = [];

{
 _x params ["_field","_label","_noneLabel"];
 private _current = _configuration getOrDefault [_field,""];
 private _selector = [
  _field,
  _label,
  _slots getOrDefault [_field,[]],
  configFile >> "CfgWeapons",
  _current,
  _noneLabel
 ] call _buildSelector;
 _selectors set [_field,_selector];
 if !(_selector getOrDefault ["currentCompatible",false]) then {
  _invalidCurrent pushBack [_field,_current];
 };
} forEach [
 ["optic","Mira","Nenhuma"],
 ["muzzle","Boca","Nenhuma"],
 ["pointer","Pointer","Nenhum"],
 ["bipod","Bipé","Nenhum"]
];

private _magCurrent = _recipe getOrDefault ["magazineClass",""];
private _magSelector = [
 "magazineClass",
 "Carregador",
 _compatibility getOrDefault ["magazines",[]],
 configFile >> "CfgMagazines",
 _magCurrent,
 "Nenhum"
] call _buildSelector;
_selectors set ["magazineClass",_magSelector];
if !(_magSelector getOrDefault ["currentCompatible",false]) then {
 _invalidCurrent pushBack ["magazineClass",_magCurrent];
};

if ((count _invalidCurrent) > 0) exitWith {
 [false,"WEAPONS_UI_COMPATIBILITY_CURRENT_VALUE_INVALID","Saved Recipe contains a value that is not present in engine-derived compatibility.",createHashMapFromArray [
  ["weaponClass",_canonicalWeaponClass],
  ["invalidCurrent",_invalidCurrent],
  ["compatibilitySource",_compatibility getOrDefault ["source",""]]
 ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

[true,"WEAPONS_UI_COMPATIBILITY_SELECTORS_BUILT","Draft-editable compatibility selector model built from the approved 0.3 engine query. Repository and loadout mutation remain disabled.",createHashMapFromArray [
 ["model",createHashMapFromArray [
  ["schemaVersion","0.6-D-compatibility-selector-candidate"],
  ["weaponClass",_canonicalWeaponClass],
  ["selectors",_selectors],
  ["readOnly",false],
  ["draftMutation",true],
  ["weaponKitMutation",false],
  ["loadoutMutation",false],
  ["compatibilitySource",_compatibility getOrDefault ["source",""]],
  ["magazineSource",_compatibility getOrDefault ["magazineSource",""]],
  ["cacheHit",_cacheHit]
 ]]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
