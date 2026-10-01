params [["_weaponClass","",[""]]];

if (_weaponClass isEqualTo "") exitWith {
 [false,"WEAPONS_CATALOG_WEAPON_EMPTY","Weapon class is required."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _cfg = configFile >> "CfgWeapons" >> _weaponClass;
if (!isClass _cfg) exitWith {
 [false,"WEAPONS_CATALOG_WEAPON_UNKNOWN","Weapon class does not exist in CfgWeapons."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _type = getNumber (_cfg >> "type");
if !(_type in [1,2,4]) exitWith {
 [false,"WEAPONS_CATALOG_NOT_INFANTRY_WEAPON","Expected primary, handgun or secondary infantry weapon."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

// Canonicalize + deduplicate config class names case-insensitively.
// Config lookup is case-insensitive; configName restores the declared engine spelling.
private _dedupeConfigClassnamesCI = {
 params ["_values","_root"];
 private _seen = createHashMap;
 private _out = [];

 {
  if (_x isEqualType "" && {!(_x isEqualTo "")}) then {
   private _itemCfg = _root >> _x;
   private _canonical = if (isClass _itemCfg) then {configName _itemCfg} else {_x};
   private _key = toLowerANSI _canonical;

   if !(_seen getOrDefault [_key,false]) then {
    _seen set [_key,true];
    _out pushBack _canonical;
   };
  };
 } forEach _values;

 _out sort true;
 _out
};

private _defs = [] call ServoPeregrino_Organizador_Weapons_fnc_getConfigurationSlotDefinitions;
private _slotItems = createHashMap;
{
 private _field = _x;
 private _engineSlot = (_defs get _field) get "engineSlot";
 private _items = compatibleItems [_weaponClass,_engineSlot];
 _items = [_items,configFile >> "CfgWeapons"] call _dedupeConfigClassnamesCI;
 _slotItems set [_field,_items];
} forEach ["muzzle","pointer","optic","bipod"];

private _allMagazines = compatibleMagazines _weaponClass;
_allMagazines = _allMagazines arrayIntersect _allMagazines;

private _magazineSource = "ENGINE_COMPATIBLE_COMMANDS";
private _secondaryVariantClasses = [];
private _secondaryVariantMagazines = [];

// SECONDARY launchers may be represented by hidden/runtime variants.
// Example pattern used by third-party mods:
//   public/base launcher -> hidden READY/USED runtime classes
// where the runtime READY class restores the real magazine/magazineWell.
//
// Resolve these generically through baseWeapon; never hardcode addon,
// launcher or magazine class names.
if (_type isEqualTo 4) then {
 private _requestedClass = configName _cfg;
 private _canonicalBase = getText (_cfg >> "baseWeapon");
 if (_canonicalBase isEqualTo "") then {_canonicalBase = _requestedClass};
 private _canonicalBaseLower = toLowerANSI _canonicalBase;

 private _secondaryCfgs = "getNumber (_x >> 'type') == 4" configClasses (configFile >> "CfgWeapons");
 {
  private _candidateCfg = _x;
  private _candidateClass = configName _candidateCfg;
  private _candidateBase = getText (_candidateCfg >> "baseWeapon");
  if (_candidateBase isEqualTo "") then {_candidateBase = _candidateClass};

  if ((toLowerANSI _candidateBase) isEqualTo _canonicalBaseLower) then {
   _secondaryVariantClasses pushBackUnique _candidateClass;

   private _variantMags = compatibleMagazines _candidateClass;
   private _variantConfigMags = [_candidateClass,false] call BIS_fnc_compatibleMagazines;

   _secondaryVariantMagazines append _variantMags;
   _secondaryVariantMagazines append _variantConfigMags;
  };
 } forEach _secondaryCfgs;

 _secondaryVariantClasses = [_secondaryVariantClasses,configFile >> "CfgWeapons"] call _dedupeConfigClassnamesCI;
 _secondaryVariantMagazines = [_secondaryVariantMagazines,configFile >> "CfgMagazines"] call _dedupeConfigClassnamesCI;

 private _beforeVariantCount = count _allMagazines;
 _allMagazines append _secondaryVariantMagazines;
 _allMagazines = [_allMagazines,configFile >> "CfgMagazines"] call _dedupeConfigClassnamesCI;

 if ((count _allMagazines) > _beforeVariantCount) then {
  _magazineSource = "ENGINE_COMMANDS_PLUS_BASEWEAPON_RUNTIME_VARIANTS";
 };
};

// Player-facing compatibility must not expose hidden/internal magazines.
// This removes technical placeholders (scope < 2) while preserving public
// magazines that a Recipe may legitimately request.
_allMagazines = _allMagazines select {
 private _magCfg = configFile >> "CfgMagazines" >> _x;
 isClass _magCfg && {getNumber (_magCfg >> "scope") >= 2}
};
_allMagazines = [_allMagazines,configFile >> "CfgMagazines"] call _dedupeConfigClassnamesCI;

private _muzzles = getArray (_cfg >> "muzzles");
if (_muzzles isEqualTo []) then {_muzzles = ["this"]};
private _magazinesByMuzzle = createHashMap;
{
 private _muzzle = _x;
 private _mags = compatibleMagazines [_weaponClass,_muzzle];

 // For a single primary muzzle on SECONDARY, expose the same public
 // compatibility union resolved from base/runtime variants.
 if (
  _type isEqualTo 4
  && {count _muzzles isEqualTo 1}
  && {_muzzle isEqualTo "this"}
 ) then {
  _mags append _allMagazines;
 };

 _mags = _mags select {
  private _magCfg = configFile >> "CfgMagazines" >> _x;
  isClass _magCfg && {getNumber (_magCfg >> "scope") >= 2}
 };
 _mags = [_mags,configFile >> "CfgMagazines"] call _dedupeConfigClassnamesCI;
 _magazinesByMuzzle set [_muzzle,_mags];
} forEach _muzzles;

private _attachmentCount = 0;
{_attachmentCount = _attachmentCount + count (_slotItems get _x)} forEach ["muzzle","pointer","optic","bipod"];

[true,"WEAPONS_COMPATIBILITY_DISCOVERED","Compatibility resolved from engine commands.",createHashMapFromArray [
 ["weaponClass",configName _cfg],
 ["type",_type],
 ["slots",_slotItems],
 ["muzzles",_muzzles],
 ["magazines",_allMagazines],
 ["magazinesByMuzzle",_magazinesByMuzzle],
 ["attachmentCount",_attachmentCount],
 ["magazineCount",count _allMagazines],
 ["magazineSource",_magazineSource],
 ["secondaryVariantClasses",_secondaryVariantClasses],
 ["secondaryVariantCount",count _secondaryVariantClasses],
 ["secondaryVariantMagazineCount",count _secondaryVariantMagazines],
 ["source","ENGINE_COMPATIBLE_COMMANDS"]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
