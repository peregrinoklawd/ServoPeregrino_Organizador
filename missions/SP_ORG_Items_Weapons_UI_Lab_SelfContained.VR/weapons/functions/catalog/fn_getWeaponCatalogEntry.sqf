params [
 ["_weaponClass","",[""]],
 ["_includeCompatibility",false,[false]]
];

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

private _className = configName _cfg;
private _baseWeapon = getText (_cfg >> "baseWeapon");
private _hasLinkedItems = isClass (_cfg >> "LinkedItems");
private _isPreset = _hasLinkedItems && {_baseWeapon != ""} && {!((toLowerANSI _baseWeapon) isEqualTo (toLowerANSI _className))};
private _category = switch (_type) do {
 case 1: {"PRIMARY"};
 case 2: {"HANDGUN"};
 case 4: {"SECONDARY"};
 default {"UNKNOWN"};
};

private _entry = createHashMapFromArray [
 ["schemaVersion","0.3-catalog-entry-candidate"],
 ["weaponClass",_className],
 ["displayName",getText (_cfg >> "displayName")],
 ["descriptionShort",getText (_cfg >> "descriptionShort")],
 ["picture",getText (_cfg >> "picture")],
 ["scope",getNumber (_cfg >> "scope")],
 ["type",_type],
 ["category",_category],
 ["baseWeapon",_baseWeapon],
 ["isPresetVariant",_isPreset],
 ["hasLinkedItems",_hasLinkedItems],
 ["sourceAddons",configSourceAddonList _cfg],
 ["sourceMods",configSourceModList _cfg]
];

if (_includeCompatibility) then {
 private _compat = [_className] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponCompatibility;
 if !(_compat get "success") exitWith {_compat};
 _entry set ["compatibility",(_compat get "data")];
};

[true,"WEAPONS_CATALOG_ENTRY","Weapon catalog entry resolved.",createHashMapFromArray [["entry",_entry]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
