params [["_snapshot",false]];

if !(_snapshot isEqualType createHashMap) exitWith {
 [false,"WEAPONS_APPLICATION_SNAPSHOT_TYPE_INVALID","ApplicationSnapshot must be a HashMap."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if !((_snapshot getOrDefault ["schemaVersion",""]) isEqualTo "0.7-A-application-snapshot-candidate") exitWith {
 [false,"WEAPONS_APPLICATION_SNAPSHOT_SCHEMA_INVALID","Unsupported ApplicationSnapshot schema."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _slot = _snapshot getOrDefault ["targetSlot",""];
private _slotIndex = ["PRIMARY","SECONDARY","HANDGUN"] find _slot;
if (_slotIndex < 0 || {!((_snapshot getOrDefault ["targetSlotIndex",-1]) isEqualTo _slotIndex)}) exitWith {
 [false,"WEAPONS_APPLICATION_SNAPSHOT_SLOT_INVALID","ApplicationSnapshot target slot/index pair is invalid."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _loadout = _snapshot getOrDefault ["capturedLoadout",false];
private _fp = [_loadout,_slot] call ServoPeregrino_Organizador_Weapons_fnc_getApplicationPreservationFingerprint;
if !(_fp getOrDefault ["success",false]) exitWith {_fp};
if !(((_fp get "data") get "fingerprint") isEqualTo (_snapshot getOrDefault ["preservationFingerprint",""])) exitWith {
 [false,"WEAPONS_APPLICATION_SNAPSHOT_FINGERPRINT_INVALID","Snapshot preservation fingerprint does not match captured loadout."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _speed = _snapshot getOrDefault ["animSpeedCoef",-1];
if !(_speed isEqualType 0 && {finite _speed} && {_speed >= 0}) exitWith {
 [false,"WEAPONS_APPLICATION_SNAPSHOT_ANIM_INVALID","Snapshot animation speed coefficient is invalid."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if !((_snapshot getOrDefault ["currentWeapon",""]) isEqualType "" && {(_snapshot getOrDefault ["currentMuzzle",""]) isEqualType ""}) exitWith {
 [false,"WEAPONS_APPLICATION_SNAPSHOT_SELECTION_INVALID","Snapshot weapon selection metadata is malformed."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

[true,"WEAPONS_APPLICATION_SNAPSHOT_VALID","ApplicationSnapshot passed structural integrity checks.",createHashMapFromArray [
 ["targetSlot",_slot],
 ["targetSlotIndex",_slotIndex],
 ["preservationFingerprint",(_snapshot get "preservationFingerprint")]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
