#include "..\..\script_version.hpp"
params [
 ["_includePresets",false,[false]],
 ["_forceRebuild",false,[false]]
];

private _cacheKey = if (_includePresets) then {SP_ORG_WEAPONS_CATALOG_ALL} else {SP_ORG_WEAPONS_CATALOG_BASE};
private _cached = missionNamespace getVariable [_cacheKey,createHashMap];
if (!_forceRebuild && {(count _cached) > 0}) exitWith {
 [true,"WEAPONS_CATALOG_CACHE_HIT","Weapon catalog returned from mission-local cache.",createHashMapFromArray [
  ["catalog",[_cached] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy]
 ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _start = diag_tickTime;
private _rows = [];
private _primary = 0;
private _handgun = 0;
private _secondary = 0;
private _presetSkipped = 0;
private _blankNameSkipped = 0;
private _scopeSkipped = 0;

{
 if (isClass _x) then {
  private _scope = getNumber (_x >> "scope");
  private _type = getNumber (_x >> "type");
  if (_scope >= 2 && {_type in [1,2,4]}) then {
   private _className = configName _x;
   private _displayName = getText (_x >> "displayName");
   if (_displayName isEqualTo "") then {
    _blankNameSkipped = _blankNameSkipped + 1;
   } else {
    private _baseWeapon = getText (_x >> "baseWeapon");
    private _hasLinkedItems = isClass (_x >> "LinkedItems");
    private _isPreset = _hasLinkedItems && {_baseWeapon != ""} && {!((toLowerANSI _baseWeapon) isEqualTo (toLowerANSI _className))};
    if (_isPreset && {!_includePresets}) then {
     _presetSkipped = _presetSkipped + 1;
    } else {
     private _category = switch (_type) do {
      case 1: {_primary=_primary+1;"PRIMARY"};
      case 2: {_handgun=_handgun+1;"HANDGUN"};
      case 4: {_secondary=_secondary+1;"SECONDARY"};
      default {"UNKNOWN"};
     };
     _rows pushBack createHashMapFromArray [
      ["schemaVersion","0.3-catalog-entry-candidate"],
      ["weaponClass",_className],
      ["displayName",_displayName],
      ["descriptionShort",getText (_x >> "descriptionShort")],
      ["picture",getText (_x >> "picture")],
      ["scope",_scope],
      ["type",_type],
      ["category",_category],
      ["baseWeapon",_baseWeapon],
      ["isPresetVariant",_isPreset],
      ["hasLinkedItems",_hasLinkedItems],
      ["sourceAddons",configSourceAddonList _x],
      ["sourceMods",configSourceModList _x]
     ];
    };
   };
  } else {
   _scopeSkipped = _scopeSkipped + 1;
  };
 };
} forEach ("true" configClasses (configFile >> "CfgWeapons"));

private _catalog = createHashMapFromArray [
 ["schemaVersion","0.3-catalog-candidate"],
 ["includePresetVariants",_includePresets],
 ["compatibilityIncluded",false],
 ["entries",_rows],
 ["total",count _rows],
 ["primary",_primary],
 ["handgun",_handgun],
 ["secondary",_secondary],
 ["presetSkipped",_presetSkipped],
 ["blankNameSkipped",_blankNameSkipped],
 ["scopeOrTypeSkipped",_scopeSkipped],
 ["buildMs",round ((diag_tickTime - _start) * 1000)]
];
missionNamespace setVariable [_cacheKey,_catalog];

[true,"WEAPONS_CATALOG_BUILT","Weapon catalog built from runtime CfgWeapons. Compatibility remains on-demand.",createHashMapFromArray [
 ["catalog",[_catalog] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
