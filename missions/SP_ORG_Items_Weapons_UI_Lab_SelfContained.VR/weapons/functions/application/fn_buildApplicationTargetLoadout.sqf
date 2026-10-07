params [
 ["_plan",false],
 ["_snapshot",false]
];

private _planValid = [_plan] call ServoPeregrino_Organizador_Weapons_fnc_validateApplicationPlan;
if !(_planValid getOrDefault ["success",false]) exitWith {_planValid};

private _snapshotValid = [_snapshot] call ServoPeregrino_Organizador_Weapons_fnc_validateApplicationSnapshot;
if !(_snapshotValid getOrDefault ["success",false]) exitWith {_snapshotValid};

private _slot = _plan get "targetSlot";
private _slotIndex = _plan get "targetSlotIndex";
if !(_slot isEqualTo (_snapshot get "targetSlot") && {_slotIndex isEqualTo (_snapshot get "targetSlotIndex")}) exitWith {
 [false,"WEAPONS_APPLICATION_BUILD_CONTEXT_MISMATCH","Plan and Snapshot do not address the same target slot."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _capturedLoadout = _snapshot get "capturedLoadout";
private _targetLoadout = [_capturedLoadout] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
private _beforeRow = [(_snapshot getOrDefault ["targetRow",[]])] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
private _desired = _plan get "desiredConfiguration";
private _desiredMagazineClass = _plan getOrDefault ["desiredMagazineClass",""];

private _beforeWeaponClass = if (_beforeRow isEqualType [] && {count _beforeRow >= 1}) then {_beforeRow param [0,""]} else {""};
private _classEquivalent = false;
if !(_beforeWeaponClass isEqualTo "") then {
 private _equiv = [
  _beforeWeaponClass,
  _desired getOrDefault ["weaponClass",""],
  _slot
 ] call ServoPeregrino_Organizador_Weapons_fnc_areWeaponClassesEquivalentForSlot;
 if !(_equiv getOrDefault ["success",false]) exitWith {_equiv};
 _classEquivalent = ((_equiv get "data") getOrDefault ["equivalent",false]);
};

private _beforePrimaryMagazine = if (_beforeRow isEqualType [] && {count _beforeRow >= 5}) then {
 [(_beforeRow param [4,[]])] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy
} else {[]};
private _beforeSecondaryMagazine = if (_beforeRow isEqualType [] && {count _beforeRow >= 6}) then {
 [(_beforeRow param [5,[]])] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy
} else {[]};

private _primaryMagazine = [];
private _secondaryMagazine = [];
private _ammoPolicy = "NO_RECIPE_MAGAZINE";
private _buildError = createHashMap;

if !(_desiredMagazineClass isEqualTo "") then {
 private _beforeMagClass = if (_beforePrimaryMagazine isEqualType [] && {count _beforePrimaryMagazine >= 1}) then {
  _beforePrimaryMagazine param [0,""]
 } else {""};

 if (
  _classEquivalent
  && {!(_beforeMagClass isEqualTo "")}
  && {(toLowerANSI _beforeMagClass) isEqualTo (toLowerANSI _desiredMagazineClass)}
 ) then {
  _primaryMagazine = [_beforePrimaryMagazine] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
  _ammoPolicy = "PRESERVE_OBSERVED_AMMO";
 } else {
  private _magCfg = configFile >> "CfgMagazines" >> _desiredMagazineClass;
  private _capacity = if (isClass _magCfg) then {getNumber (_magCfg >> "count")} else {0};
  if (_capacity <= 0) then {
   _buildError = [false,"WEAPONS_APPLICATION_MAGAZINE_CAPACITY_INVALID","Desired magazine has no usable engine capacity.",createHashMapFromArray [
    ["magazineClass",_desiredMagazineClass]
   ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult;
  } else {
   _primaryMagazine = [_desiredMagazineClass,_capacity];
   _ammoPolicy = "NEW_MAGAZINE_FULL_CAPACITY";
  };
 };
};
if (count _buildError > 0) exitWith {_buildError};

// Secondary-muzzle loaded state belongs to the target weapon row. Preserve it only
// when the physical weapon stays in the same class/family; never carry it across replacement.
if (_classEquivalent) then {
 _secondaryMagazine = [_beforeSecondaryMagazine] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
};

private _targetRow = [
 _desired getOrDefault ["weaponClass",""],
 _desired getOrDefault ["muzzle",""],
 _desired getOrDefault ["pointer",""],
 _desired getOrDefault ["optic",""],
 _primaryMagazine,
 _secondaryMagazine,
 _desired getOrDefault ["bipod",""]
];

_targetLoadout set [_slotIndex,_targetRow];

[true,"WEAPONS_APPLICATION_TARGET_LOADOUT_BUILT","0.7-B target loadout built from the frozen Plan/Snapshot contract; only the target weapon row differs by construction.",createHashMapFromArray [
 ["targetSlot",_slot],
 ["targetSlotIndex",_slotIndex],
 ["targetRow",_targetRow],
 ["targetLoadout",_targetLoadout],
 ["ammoPolicy",_ammoPolicy],
 ["classEquivalentBefore",_classEquivalent],
 ["fullMagazines",false]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
