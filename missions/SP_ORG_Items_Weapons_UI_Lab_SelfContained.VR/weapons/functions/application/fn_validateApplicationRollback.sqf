params [["_unit",objNull,[objNull]],["_snapshot",false]];
if (isNull _unit || {!local _unit}) exitWith {
 [false,"WEAPONS_ROLLBACK_TARGET_INVALID","Rollback verification requires the original local unit."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _valid = [_snapshot] call ServoPeregrino_Organizador_Weapons_fnc_validateApplicationSnapshot;
if !(_valid getOrDefault ["success",false]) exitWith {_valid};
private _observed = getUnitLoadout _unit;
private _captured = _snapshot get "capturedLoadout";
private _domains = [];
for "_i" from 0 to 9 do {_domains pushBack ((_observed param [_i,false]) isEqualTo (_captured param [_i,true]))};
private _fp = [_observed,_snapshot get "targetSlot"] call ServoPeregrino_Organizador_Weapons_fnc_getApplicationPreservationFingerprint;
private _fpMatched = _fp getOrDefault ["success",false] && {(((_fp get "data") get "fingerprint") isEqualTo (_snapshot get "preservationFingerprint"))};
private _exact = _observed isEqualTo _captured;
private _anim = (getAnimSpeedCoef _unit) isEqualTo (_snapshot get "animSpeedCoef");
private _ok = _exact && {_fpMatched} && {_anim};
[_ok,if (_ok) then {"WEAPONS_ROLLBACK_VERIFIED"} else {"WEAPONS_ROLLBACK_VERIFY_FAILED"},"Snapshot restoration verified against exact loadout, protected fingerprint and animation coefficient.",createHashMapFromArray [
 ["rollbackRestoredExactly",_exact],["preservationMatched",_fpMatched],["animSpeedRestored",_anim],
 ["domainsMatched",_domains],["observedLoadout",_observed],
 ["observedTargetRow",_observed param [_snapshot get "targetSlotIndex",[]]]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
