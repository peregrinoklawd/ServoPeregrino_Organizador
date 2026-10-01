#include "..\..\script_version.hpp"
params [
 ["_weaponClass","",[""]],
 ["_name","",[""]]
];

private _entryR = [_weaponClass,false] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponCatalogEntry;
if !(_entryR get "success") exitWith {_entryR};
private _entry = (_entryR get "data") get "entry";
private _slot = _entry getOrDefault ["category",""];
if !(_slot in ["PRIMARY","HANDGUN","SECONDARY"]) exitWith {
 [false,"WEAPONS_UI_NEW_KIT_SLOT_INVALID","Selected catalog weapon does not map to a supported WeaponKit target slot."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _cfgR = [_entry getOrDefault ["weaponClass",_weaponClass]] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponConfiguration;
if !(_cfgR get "success") exitWith {_cfgR};
private _recipeR = [(_cfgR get "data") get "configuration",""] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponRecipe;
if !(_recipeR get "success") exitWith {_recipeR};

private _desiredName = _name;
private _nameError = createHashMap;
if (_desiredName isEqualTo "") then {
 private _baseName = _entry getOrDefault ["displayName",_weaponClass];
 if (_baseName isEqualTo "") then {_baseName = _weaponClass};
 private _uniqueR = [_baseName] call ServoPeregrino_Organizador_Weapons_fnc_getUniqueWeaponKitName;
 if (_uniqueR get "success") then {
  _desiredName = (_uniqueR get "data") get "name";
 } else {
  _nameError = _uniqueR;
 };
};
if ((count _nameError) > 0) exitWith {_nameError};

private _createR = [_desiredName,_slot,(_recipeR get "data") get "recipe"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponKit;
if !(_createR get "success") exitWith {_createR};

[true,"WEAPONS_UI_KIT_CREATED_FROM_CATALOG","WeaponKit created from the selected catalog weapon. No physical loadout mutation performed.",createHashMapFromArray [
 ["kit",[((_createR get "data") get "kit")] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
 ["weaponClass",_entry getOrDefault ["weaponClass",_weaponClass]],
 ["targetSlot",_slot],
 ["loadoutMutation",false]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
