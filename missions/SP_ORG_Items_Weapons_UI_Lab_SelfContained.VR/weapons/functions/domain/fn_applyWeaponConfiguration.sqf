params [
 ["_unit",objNull,[objNull]],
 ["_slot","PRIMARY",[""]],
 ["_configuration",false]
];

if (isNull _unit || {!(_unit isKindOf "CAManBase")}) exitWith {
 [false,"WEAPONS_APPLY_TARGET_INVALID","Expected infantry unit."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if (!local _unit) exitWith {
 [false,"WEAPONS_APPLY_TARGET_NOT_LOCAL","WeaponConfiguration apply requires local unit."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _slotName = toUpperANSI _slot;
if !(_slotName in ["PRIMARY","SECONDARY","HANDGUN"]) exitWith {
 [false,"WEAPONS_APPLY_SLOT_INVALID","Expected PRIMARY, SECONDARY or HANDGUN."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _valid = [_configuration] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponConfigurationSemantic;
if !(_valid get "success") exitWith {_valid};

private _targetResult = [_configuration] call ServoPeregrino_Organizador_Weapons_fnc_normalizeWeaponConfiguration;
if !(_targetResult get "success") exitWith {_targetResult};
private _target = (_targetResult get "data") get "configuration";

private _currentClass = switch (_slotName) do {
 case "PRIMARY": {primaryWeapon _unit};
 case "SECONDARY": {secondaryWeapon _unit};
 case "HANDGUN": {handgunWeapon _unit};
 default {""};
};

if (_currentClass isEqualTo "") exitWith {
 [false,"WEAPONS_APPLY_SLOT_EMPTY","Selected weapon slot is empty."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _classEquivalentBeforeResult = [
 _currentClass,
 _target get "weaponClass",
 _slotName
] call ServoPeregrino_Organizador_Weapons_fnc_areWeaponClassesEquivalentForSlot;
if !(_classEquivalentBeforeResult get "success") exitWith {_classEquivalentBeforeResult};
private _classEquivalentBefore = ((_classEquivalentBeforeResult get "data") get "equivalent");

if (!_classEquivalentBefore) exitWith {
 [false,"WEAPONS_APPLY_CLASS_MISMATCH","Configuration weaponClass must match the equipped weapon or an allowed SECONDARY runtime/base variant family.",createHashMapFromArray [
  ["slot",_slotName],
  ["equivalence",(_classEquivalentBeforeResult get "data")]
 ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _beforeResult = [_unit,_slotName] call ServoPeregrino_Organizador_Weapons_fnc_captureWeaponConfiguration;
if !(_beforeResult get "success") exitWith {_beforeResult};
private _before = (_beforeResult get "data") get "configuration";
private _loadedBefore = (_beforeResult get "data") get "loadedState";
private _diff = [_before,_target] call ServoPeregrino_Organizador_Weapons_fnc_diffWeaponConfigurations;
if !(_diff get "success") exitWith {_diff};

// No-op must be observational only. Avoid touching engine inventory state.
if (((_diff get "data") get "changedCount") isEqualTo 0 && {_classEquivalentBefore}) exitWith {
 [true,"WEAPONS_CONFIGURATION_ALREADY_APPLIED","WeaponConfiguration already matches engine state; no mutation performed.",createHashMapFromArray [
  ["slot",_slotName],
  ["beforeConfiguration",_before],
  ["afterConfiguration",[_before] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
  ["loadedStateBefore",_loadedBefore],
  ["loadedStateAfter",[_loadedBefore] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
  ["diff",(_diff get "data")],
  ["classEquivalence",(_classEquivalentBeforeResult get "data")]
 ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _applyItems = {
 params ["_u","_slotLocal","_c"];
 switch (_slotLocal) do {
  case "PRIMARY": {
   removeAllPrimaryWeaponItems _u;
   {if (_x != "") then {_u addPrimaryWeaponItem _x}} forEach [
    _c get "muzzle",_c get "pointer",_c get "optic",_c get "bipod"
   ];
  };
  case "SECONDARY": {
   removeAllSecondaryWeaponItems _u;
   {if (_x != "") then {_u addSecondaryWeaponItem _x}} forEach [
    _c get "muzzle",_c get "pointer",_c get "optic",_c get "bipod"
   ];
  };
  case "HANDGUN": {
   removeAllHandgunItems _u;
   {if (_x != "") then {_u addHandgunItem _x}} forEach [
    _c get "muzzle",_c get "pointer",_c get "optic",_c get "bipod"
   ];
  };
 };
};

[_unit,_slotName,_target] call _applyItems;

private _afterResult = [_unit,_slotName] call ServoPeregrino_Organizador_Weapons_fnc_captureWeaponConfiguration;
if !(_afterResult get "success") exitWith {
 [_unit,_slotName,_before] call _applyItems;
 _afterResult
};

private _after = (_afterResult get "data") get "configuration";
private _loadedAfter = (_afterResult get "data") get "loadedState";
private _verifyDiff = [_target,_after] call ServoPeregrino_Organizador_Weapons_fnc_diffWeaponConfigurations;
private _classEquivalentAfterResult = [
 _after get "weaponClass",
 _target get "weaponClass",
 _slotName
] call ServoPeregrino_Organizador_Weapons_fnc_areWeaponClassesEquivalentForSlot;
private _classEquivalentAfter = _classEquivalentAfterResult get "success" && {
 ((_classEquivalentAfterResult get "data") get "equivalent")
};
private _equal = _verifyDiff get "success" && {
 ((_verifyDiff get "data") get "changedCount") isEqualTo 0
} && {_classEquivalentAfter};
private _loadedPreserved = _loadedBefore isEqualTo _loadedAfter;

if (!_equal || {!_loadedPreserved}) exitWith {
 [_unit,_slotName,_before] call _applyItems;
 [false,"WEAPONS_APPLY_VERIFY_FAILED","Engine round-trip verification failed; attachments rolled back.",createHashMapFromArray [
  ["configurationMatched",_equal],
  ["loadedStatePreserved",_loadedPreserved],
  ["beforeConfiguration",_before],
  ["attemptedConfiguration",_target],
  ["observedConfiguration",_after],
  ["loadedStateBefore",_loadedBefore],
  ["loadedStateAfter",_loadedAfter]
 ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

[true,
 if (((_diff get "data") get "changedCount") isEqualTo 0) then {"WEAPONS_CONFIGURATION_ALREADY_APPLIED"} else {"WEAPONS_CONFIGURATION_APPLIED"},
 "WeaponConfiguration applied and verified against engine state.",
 createHashMapFromArray [
  ["slot",_slotName],
  ["beforeConfiguration",_before],
  ["afterConfiguration",_after],
  ["loadedStateBefore",_loadedBefore],
  ["loadedStateAfter",_loadedAfter],
  ["diff",(_diff get "data")]
 ]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
