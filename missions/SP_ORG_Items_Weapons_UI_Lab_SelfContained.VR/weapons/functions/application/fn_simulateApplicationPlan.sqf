params [
 ["_unit",objNull,[objNull]],
 ["_plan",false],
 ["_snapshot",false]
];

if (isNull _unit || {!(_unit isKindOf "CAManBase")}) exitWith {
 [false,"WEAPONS_APPLICATION_TARGET_INVALID","Expected infantry unit."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _planValid = [_plan] call ServoPeregrino_Organizador_Weapons_fnc_validateApplicationPlan;
if !(_planValid getOrDefault ["success",false]) exitWith {_planValid};
private _snapshotValid = [_snapshot] call ServoPeregrino_Organizador_Weapons_fnc_validateApplicationSnapshot;
if !(_snapshotValid getOrDefault ["success",false]) exitWith {_snapshotValid};

if !((_plan get "targetSlot") isEqualTo (_snapshot get "targetSlot") && {(_plan get "targetSlotIndex") isEqualTo (_snapshot get "targetSlotIndex")}) exitWith {
 [false,"WEAPONS_APPLICATION_DRY_RUN_CONTEXT_MISMATCH","Plan and Snapshot do not address the same slot."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _currentLoadout = getUnitLoadout _unit;
if !(_currentLoadout isEqualTo (_snapshot get "capturedLoadout")) exitWith {
 [false,"WEAPONS_APPLICATION_DRY_RUN_STALE_SNAPSHOT","Unit loadout changed after snapshot capture; rebuild plan/snapshot before applying."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _desiredCfg = _plan get "desiredConfiguration";
private _desiredMag = _plan getOrDefault ["desiredMagazineClass",""];
private _targetOccupied = _snapshot getOrDefault ["targetOccupied",false];
private _loadedBefore = _snapshot getOrDefault ["targetLoadedState",createHashMap];
private _magBefore = _loadedBefore getOrDefault ["primaryMagazine",[]];
private _magBeforeClass = if (_magBefore isEqualType [] && {count _magBefore >= 1}) then {_magBefore param [0,""]} else {""};
private _sameDesiredMag = _desiredMag != "" && {(toLowerANSI _desiredMag) isEqualTo (toLowerANSI _magBeforeClass)};

private _ammoPolicy = if (_desiredMag isEqualTo "") then {
 "NO_RECIPE_MAGAZINE"
} else {
 if (_targetOccupied && {_sameDesiredMag}) then {"PRESERVE_OBSERVED_AMMO"} else {"ENGINE_RESOLUTION_PENDING_0_7_B"}
};

private _expected = createHashMapFromArray [
 ["targetSlot",_plan get "targetSlot"],
 ["operation",_plan get "operation"],
 ["configuration",[_desiredCfg] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
 ["magazineClass",_desiredMag],
 ["ammoPolicy",_ammoPolicy],
 ["preservationFingerprint",_snapshot get "preservationFingerprint"],
 ["fullMagazines",false]
];

[true,"WEAPONS_APPLICATION_DRY_RUN_COMPLETE","Application simulated from Plan + Snapshot. Physical mutation was not authorized or performed.",createHashMapFromArray [
 ["mutationPerformed",false],
 ["mutationAuthorized",false],
 ["loadoutUnchanged",(getUnitLoadout _unit) isEqualTo (_snapshot get "capturedLoadout")],
 ["requiresMutation",!((_plan get "operation") isEqualTo "NO_OP")],
 ["expected",_expected],
 ["strategy",_plan get "strategy"],
 ["targetSlot",_plan get "targetSlot"]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
