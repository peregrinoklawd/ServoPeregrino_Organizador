params [["_weaponClass","",[""]]];
if (_weaponClass isEqualTo "") exitWith {
 [true,"WEAPONS_UI_WEAPON_PRESENTATION_EMPTY","No weapon class selected.",createHashMapFromArray [["info",createHashMapFromArray [["present",false],["weaponClass",""],["displayName","Nenhuma arma selecionada"],["picture",""],["descriptionShort",""],["category",""],["type",0],["baseWeapon",""],["isPresetVariant",false],["sourceAddons",[]],["sourceMods",[]],["originLabel",""]]]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _entryR = [_weaponClass,false] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponCatalogEntry;
if !(_entryR get "success") exitWith {_entryR};
private _entry = (_entryR get "data") get "entry";
private _displayName = _entry getOrDefault ["displayName",""];
if (_displayName isEqualTo "") then {_displayName = _entry getOrDefault ["weaponClass",_weaponClass]};
private _sourceAddons = _entry getOrDefault ["sourceAddons",[]];
private _sourceMods = _entry getOrDefault ["sourceMods",[]];
private _originLabel = if (count _sourceMods > 0) then {_sourceMods joinString ", "} else {_sourceAddons joinString ", "};
[true,"WEAPONS_UI_WEAPON_PRESENTATION_INFO","Weapon presentation metadata resolved without mutation.",createHashMapFromArray [["info",createHashMapFromArray [["present",true],["weaponClass",_entry getOrDefault ["weaponClass",_weaponClass]],["displayName",_displayName],["picture",_entry getOrDefault ["picture",""]],["descriptionShort",_entry getOrDefault ["descriptionShort",""]],["category",_entry getOrDefault ["category",""]],["type",_entry getOrDefault ["type",0]],["baseWeapon",_entry getOrDefault ["baseWeapon",""]],["isPresetVariant",_entry getOrDefault ["isPresetVariant",false]],["sourceAddons",_sourceAddons],["sourceMods",_sourceMods],["originLabel",_originLabel]]]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
