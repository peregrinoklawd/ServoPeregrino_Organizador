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

// UC-001-B: a single slot-aware logical source for catalog, selectors and domain.
private _attachmentR=[_weaponClass] call ServoPeregrino_Organizador_Weapons_fnc_resolveAttachmentCompatibility;
if !(_attachmentR getOrDefault ["success",false]) exitWith {_attachmentR};
private _attachmentD=_attachmentR getOrDefault ["data",createHashMap];
private _slotItems=_attachmentD getOrDefault ["slots",createHashMap];
private _attachmentSources=_attachmentD getOrDefault ["sourcesBySlot",createHashMap];
private _underbarrelData=_attachmentSources getOrDefault ["bipod",createHashMap];
// UC-001-C: magazines/muzzles/magwells/launcher-variants have one
// read-only source; existing selectors and recipe validation consume this map.
private _magazineR=[_weaponClass] call ServoPeregrino_Organizador_Weapons_fnc_resolveMagazineCompatibility;
if !(_magazineR getOrDefault ["success",false]) exitWith {_magazineR};
private _magazineD=_magazineR getOrDefault ["data",createHashMap];
private _allMagazines=_magazineD getOrDefault ["magazines",[]];
private _muzzles=_magazineD getOrDefault ["muzzles",[]];
private _magazinesByMuzzle=_magazineD getOrDefault ["magazinesByMuzzle",createHashMap];
private _magazineSource=_magazineD getOrDefault ["magazineSource","ENGINE_COMPATIBLE_COMMANDS"];
private _secondaryVariantClasses=_magazineD getOrDefault ["secondaryVariantClasses",[]];
private _secondaryVariantMagazines=_magazineD getOrDefault ["secondaryVariantMagazines",[]];

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
 ["magazineWellsByMuzzle",_magazineD getOrDefault ["magazineWellsByMuzzle",createHashMap]],
 ["magazineSourcesByMuzzle",_magazineD getOrDefault ["sourcesByMuzzle",createHashMap]],
 ["magazineResolutionMode",_magazineD getOrDefault ["resolutionMode","ENGINE"]],
 ["secondaryVariantClasses",_secondaryVariantClasses],
 ["secondaryVariantCount",count _secondaryVariantClasses],
 ["secondaryVariantMagazineCount",count _secondaryVariantMagazines],
 ["underbarrelSource",if ((_underbarrelData getOrDefault ["source","ENGINE"]) isEqualTo "ENGINE_PLUS_CBA") then {"ENGINE_PLUS_CBA_UNDERBARREL"} else {"ENGINE_UNDERBARREL"}],
 ["underbarrelCBAAdded",_underbarrelData getOrDefault ["cbaAddedCount",0]],
 ["attachmentSources",_attachmentSources],
 ["attachmentResolutionMode",_attachmentD getOrDefault ["resolutionMode","ENGINE"]],
 // The legacy "source" field is a stable compatibility marker introduced in
 // catalog 0.3. The actual slot source/provenance is expressed separately above.
 // Preserve this value for existing consumers and the R5 frozen test contract.
 ["source","ENGINE_COMPATIBLE_COMMANDS"]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
