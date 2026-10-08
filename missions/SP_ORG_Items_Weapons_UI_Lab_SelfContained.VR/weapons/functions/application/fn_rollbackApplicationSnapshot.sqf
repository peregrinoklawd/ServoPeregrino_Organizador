params [["_unit",objNull,[objNull]],["_snapshot",false]];
if (isNull _unit || {!local _unit} || {!(_unit isKindOf "CAManBase")}) exitWith {
 [false,"WEAPONS_ROLLBACK_TARGET_INVALID","Rollback requires a local infantry unit."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _valid = [_snapshot] call ServoPeregrino_Organizador_Weapons_fnc_validateApplicationSnapshot;
if !(_valid getOrDefault ["success",false]) exitWith {_valid};
_unit setUnitLoadout [[_snapshot get "capturedLoadout"] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy,false];
_unit setAnimSpeedCoef (_snapshot get "animSpeedCoef");
[_unit,_snapshot] call ServoPeregrino_Organizador_Weapons_fnc_validateApplicationRollback
