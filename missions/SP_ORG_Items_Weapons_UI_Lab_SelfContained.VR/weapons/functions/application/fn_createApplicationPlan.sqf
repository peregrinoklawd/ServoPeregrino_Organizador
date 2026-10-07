params [
 ["_unit",objNull,[objNull]],
 ["_kit",false]
];

if (isNull _unit || {!(_unit isKindOf "CAManBase")}) exitWith {
 [false,"WEAPONS_APPLICATION_TARGET_INVALID","Expected infantry unit."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _semantic = [_kit] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponKitSemantic;
if !(_semantic getOrDefault ["success",false]) exitWith {_semantic};

private _normal = [_kit] call ServoPeregrino_Organizador_Weapons_fnc_normalizeWeaponKit;
if !(_normal getOrDefault ["success",false]) exitWith {_normal};
private _normalizedKit = (_normal get "data") get "kit";
private _slot = _normalizedKit get "targetSlot";
private _slotIndex = ["PRIMARY","SECONDARY","HANDGUN"] find _slot;
if (_slotIndex < 0) exitWith {
 [false,"WEAPONS_APPLICATION_SLOT_INVALID","WeaponKit target slot is not supported."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _recipe = _normalizedKit get "recipe";
private _desiredConfiguration = _recipe get "configuration";
private _desiredMagazineClass = _recipe getOrDefault ["magazineClass",""];
private _loadout = getUnitLoadout _unit;
if !(count _loadout >= 10) exitWith {
 [false,"WEAPONS_APPLICATION_LOADOUT_SHAPE_INVALID","Engine returned an unexpected loadout shape."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _row = _loadout param [_slotIndex,[]];
private _occupied = _row isEqualType [] && {count _row >= 1} && {(_row param [0,""]) != ""};
private _currentConfiguration = createHashMap;
private _currentLoadedState = createHashMap;
private _currentMagazineClass = "";
private _classEquivalent = false;
private _changedFields = [];
private _operation = "INSERT";
private _nestedError = createHashMap;

if (_occupied) then {
 private _capture = [_row] call ServoPeregrino_Organizador_Weapons_fnc_configurationFromWeaponArray;
 if !(_capture getOrDefault ["success",false]) then {
  _nestedError = _capture;
 } else {
  _currentConfiguration = ((_capture get "data") get "configuration");
  _currentLoadedState = ((_capture get "data") get "loadedState");
  private _mag = _currentLoadedState getOrDefault ["primaryMagazine",[]];
  if (_mag isEqualType [] && {count _mag >= 1}) then {_currentMagazineClass = _mag param [0,""]};

  private _equiv = [
   _currentConfiguration getOrDefault ["weaponClass",""],
   _desiredConfiguration getOrDefault ["weaponClass",""],
   _slot
  ] call ServoPeregrino_Organizador_Weapons_fnc_areWeaponClassesEquivalentForSlot;
  if !(_equiv getOrDefault ["success",false]) then {
   _nestedError = _equiv;
  } else {
   _classEquivalent = ((_equiv get "data") getOrDefault ["equivalent",false]);
   if (_classEquivalent) then {
    private _diff = [_currentConfiguration,_desiredConfiguration] call ServoPeregrino_Organizador_Weapons_fnc_diffWeaponConfigurations;
    if !(_diff getOrDefault ["success",false]) then {
     _nestedError = _diff;
    } else {
     _changedFields = +(((_diff get "data") getOrDefault ["changedFields",[]]));
     private _magDiff = _desiredMagazineClass != "" && {!((toLowerANSI _desiredMagazineClass) isEqualTo (toLowerANSI _currentMagazineClass))};
     if ((count _changedFields) isEqualTo 0 && {!_magDiff}) then {_operation = "NO_OP"} else {_operation = "RECONFIGURE"};
    };
   } else {
    _operation = "REPLACE";
    _changedFields = ["weaponClass","muzzle","pointer","optic","bipod"];
   };
  };
 };
};
if (count _nestedError > 0) exitWith {_nestedError};

private _plan = createHashMapFromArray [
 ["schemaVersion","0.7-A-application-plan-candidate"],
 ["sourceKind","WEAPON_KIT"],
 ["sourceKitId",_normalizedKit getOrDefault ["kitId",""]],
 ["sourceKitName",_normalizedKit getOrDefault ["name",""]],
 ["targetSlot",_slot],
 ["targetSlotIndex",_slotIndex],
 ["operation",_operation],
 ["strategy","FULL_LOADOUT_CLONE_SETUNITLOADOUT_FALSE_CANDIDATE"],
 ["fullMagazines",false],
 ["dryRunOnly",true],
 ["mutationAuthorized",false],
 ["desiredRecipe",[_recipe] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
 ["desiredConfiguration",[_desiredConfiguration] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
 ["desiredMagazineClass",_desiredMagazineClass],
 ["currentOccupied",_occupied],
 ["currentConfiguration",[_currentConfiguration] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
 ["currentLoadedState",[_currentLoadedState] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
 ["currentMagazineClass",_currentMagazineClass],
 ["currentClassEquivalent",_classEquivalent],
 ["changedFields",_changedFields]
];

private _valid = [_plan] call ServoPeregrino_Organizador_Weapons_fnc_validateApplicationPlan;
if !(_valid getOrDefault ["success",false]) exitWith {_valid};

[true,"WEAPONS_APPLICATION_PLAN_CREATED","Slot-safe application plan created in dry-run mode; no inventory mutation performed.",createHashMapFromArray [
 ["plan",_plan]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
