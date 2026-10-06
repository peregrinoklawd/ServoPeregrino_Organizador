params [["_weaponClass","",[""]]];

if (_weaponClass isEqualTo "") exitWith {
 [false,"WEAPONS_UI_WEAPON_EMPTY","Weapon class is required for presentation."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _entryResult = [_weaponClass,false] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponCatalogEntry;
if !(_entryResult get "success") exitWith {_entryResult};

private _entry = (_entryResult get "data") get "entry";
private _class = _entry getOrDefault ["weaponClass",_weaponClass];
private _displayName = _entry getOrDefault ["displayName",_class];
private _category = _entry getOrDefault ["category","UNKNOWN"];
private _categoryLabel = [_category] call ServoPeregrino_Organizador_Weapons_fnc_getUISlotLabel;
private _description = _entry getOrDefault ["descriptionShort",""];
private _picture = _entry getOrDefault ["picture",""];
private _baseWeapon = _entry getOrDefault ["baseWeapon",""];

private _baseDisplayName = "";
if (_baseWeapon isNotEqualTo "") then {
 private _baseCfg = configFile >> "CfgWeapons" >> _baseWeapon;
 _baseDisplayName = if (isClass _baseCfg) then {getText (_baseCfg >> "displayName")} else {_baseWeapon};
 if (_baseDisplayName isEqualTo "") then {_baseDisplayName = _baseWeapon};
};

private _sourceMods = +(_entry getOrDefault ["sourceMods",[]]);
private _sourceAddons = +(_entry getOrDefault ["sourceAddons",[]]);

private _originLabel = "Origem não informada";
if ((count _sourceMods) > 0) then {
 _originLabel = _sourceMods joinString ", ";
} else {
 if ((count _sourceAddons) > 0) then {
  _originLabel = _sourceAddons joinString ", ";
 };
};

private _info = createHashMapFromArray [
 ["schemaVersion","0.6-B-presentation-candidate"],
 ["weaponClass",_class],
 ["displayName",_displayName],
 ["descriptionShort",_description],
 ["picture",_picture],
 ["type",_entry getOrDefault ["type",-1]],
 ["category",_category],
 ["categoryLabel",_categoryLabel],
 ["baseWeapon",_baseWeapon],
 ["baseWeaponDisplayName",_baseDisplayName],
 ["isPresetVariant",_entry getOrDefault ["isPresetVariant",false]],
 ["hasLinkedItems",_entry getOrDefault ["hasLinkedItems",false]],
 ["sourceAddons",_sourceAddons],
 ["sourceMods",_sourceMods],
 ["originLabel",_originLabel]
];

[true,"WEAPONS_UI_WEAPON_PRESENTATION","Basic weapon presentation resolved without compatibility scan or inventory mutation.",createHashMapFromArray [
 ["info",_info]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
