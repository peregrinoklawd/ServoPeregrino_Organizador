#include "..\..\script_version.hpp"
params [
 ["_includePresets",false,[false]],
 ["_forceRebuild",false,[false]]
];

private _cacheKey = if (_includePresets) then {SP_ORG_WEAPONS_CATALOG_ALL} else {SP_ORG_WEAPONS_CATALOG_BASE};
private _cached = missionNamespace getVariable [_cacheKey,createHashMap];
if (!_forceRebuild && {count _cached > 0}) exitWith {
 [true,"WEAPONS_CATALOG_CACHE_HIT","Cached weapon catalog returned.",createHashMapFromArray [["catalog",[_cached] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _started = diag_tickTime;
private _showPlayerProgress = hasInterface;
if (_showPlayerProgress) then {
 titleText ["Vasculhando inventário e catalogando armas...","PLAIN DOWN",0.15];
 if (canSuspend) then {uiSleep 0.01};
};
private _cfgs = "getNumber (_x >> 'scope') == 2" configClasses (configFile >> "CfgWeapons");
private _entries = [];
private _primary = 0;
private _handgun = 0;
private _secondary = 0;
private _presetSkipped = 0;
private _blankNameSkipped = 0;

{
 private _cfg = _x;
 private _type = getNumber (_cfg >> "type");
 if (_type in [1,2,4]) then {
  private _className = configName _cfg;
  private _baseWeapon = getText (_cfg >> "baseWeapon");
  private _hasLinkedItems = isClass (_cfg >> "LinkedItems");
  private _isPreset = _hasLinkedItems && {_baseWeapon != ""} && {!((toLowerANSI _baseWeapon) isEqualTo (toLowerANSI _className))};
  private _displayName = getText (_cfg >> "displayName");
  if (_displayName isEqualTo "") then {
   _blankNameSkipped = _blankNameSkipped + 1;
  } else {
   if (!_includePresets && {_isPreset}) then {
    _presetSkipped = _presetSkipped + 1;
   } else {
    private _entryResult = [_className,false] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponCatalogEntry;
    if (_entryResult get "success") then {
     private _entry = (_entryResult get "data") get "entry";
     _entries pushBack _entry;
     switch (_type) do {
      case 1: {_primary = _primary + 1};
      case 2: {_handgun = _handgun + 1};
      case 4: {_secondary = _secondary + 1};
     };
    };
   };
  };
 };
 if ((_forEachIndex mod 600) isEqualTo 0 && {_forEachIndex > 0} && {canSuspend}) then {uiSleep 0.001};
} forEach _cfgs;

_entries = [_entries,[],{toLowerANSI (_x get "weaponClass")},"ASCEND"] call BIS_fnc_sortBy;
private _elapsedMs = round ((diag_tickTime - _started) * 1000);
private _catalog = createHashMapFromArray [
 ["schemaVersion","0.3-catalog-candidate"],
 ["includePresets",_includePresets],
 ["entries",_entries],
 ["total",count _entries],
 ["primary",_primary],
 ["handgun",_handgun],
 ["secondary",_secondary],
 ["presetSkipped",_presetSkipped],
 ["blankNameSkipped",_blankNameSkipped],
 ["buildMs",_elapsedMs],
 ["compatibilityMode","ON_DEMAND_ENGINE_QUERY"]
];
missionNamespace setVariable [_cacheKey,[_catalog] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy];

diag_log format ["[SP_ORG] [WEAPONS] [CATALOG_BUILD] includePresets=%1 total=%2 primary=%3 handgun=%4 secondary=%5 presetSkipped=%6 blankNameSkipped=%7 buildMs=%8",_includePresets,count _entries,_primary,_handgun,_secondary,_presetSkipped,_blankNameSkipped,_elapsedMs];
if (_showPlayerProgress) then {
 titleText [format ["Catálogo de armas pronto: %1 opções encontradas.",count _entries],"PLAIN DOWN",0.10];
 if (canSuspend) then {uiSleep 0.12};
 titleText ["","PLAIN DOWN",0.10];
};

[true,"WEAPONS_CATALOG_BUILT","Weapon catalog built from CfgWeapons.",createHashMapFromArray [["catalog",[_catalog] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
