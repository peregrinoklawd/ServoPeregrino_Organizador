params [
 ["_unit",objNull,[objNull]],
 ["_plan",false]
];

if (isNull _unit || {!(_unit isKindOf "CAManBase")}) exitWith {
 [false,"WEAPONS_APPLICATION_TARGET_INVALID","Expected infantry unit."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _planValid = [_plan] call ServoPeregrino_Organizador_Weapons_fnc_validateApplicationPlan;
if !(_planValid getOrDefault ["success",false]) exitWith {_planValid};

private _slot = _plan get "targetSlot";
private _slotIndex = _plan get "targetSlotIndex";
private _loadout = [getUnitLoadout _unit] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
private _fp = [_loadout,_slot] call ServoPeregrino_Organizador_Weapons_fnc_getApplicationPreservationFingerprint;
if !(_fp getOrDefault ["success",false]) exitWith {_fp};

private _targetRow = [(_loadout param [_slotIndex,[]])] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
private _occupied = _targetRow isEqualType [] && {count _targetRow >= 1} && {(_targetRow param [0,""]) != ""};
private _targetConfiguration = createHashMap;
private _targetLoadedState = createHashMap;
if (_occupied) then {
 private _capture = [_targetRow] call ServoPeregrino_Organizador_Weapons_fnc_configurationFromWeaponArray;
 if !(_capture getOrDefault ["success",false]) exitWith {_capture};
 _targetConfiguration = ((_capture get "data") get "configuration");
 _targetLoadedState = ((_capture get "data") get "loadedState");
};

private _snapshot = createHashMapFromArray [
 ["schemaVersion","0.7-A-application-snapshot-candidate"],
 ["targetSlot",_slot],
 ["targetSlotIndex",_slotIndex],
 ["capturedLoadout",_loadout],
 ["preservationFingerprint",((_fp get "data") get "fingerprint")],
 ["preservationDomains",[((_fp get "data") get "domains")] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
 ["targetOccupied",_occupied],
 ["targetRow",_targetRow],
 ["targetConfiguration",[_targetConfiguration] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
 ["targetLoadedState",[_targetLoadedState] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
 ["currentWeapon",currentWeapon _unit],
 ["currentMuzzle",currentMuzzle _unit],
 ["animSpeedCoef",getAnimSpeedCoef _unit]
];

private _valid = [_snapshot] call ServoPeregrino_Organizador_Weapons_fnc_validateApplicationSnapshot;
if !(_valid getOrDefault ["success",false]) exitWith {_valid};

[true,"WEAPONS_APPLICATION_SNAPSHOT_CAPTURED","Read-only application snapshot captured; no inventory mutation performed.",createHashMapFromArray [
 ["snapshot",_snapshot]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
