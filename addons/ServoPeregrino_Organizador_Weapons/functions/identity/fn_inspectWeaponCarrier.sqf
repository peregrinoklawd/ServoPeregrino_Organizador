params [["_carrier",objNull,[objNull]]];
if (isRemoteExecuted) exitWith {[false,"WEAPONS_REMOTE_EXEC_FORBIDDEN","Carrier inspection is local-only; use a declared gateway."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
if (isNull _carrier) exitWith {[false,"WEAPONS_CARRIER_INVALID","No carrier."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _isUnit = _carrier isKindOf "CAManBase";
private _rows = if (_isUnit) then {(getUnitLoadout _carrier) select [0,3]} else {weaponsItemsCargo _carrier};
private _observations = [];
private _fingerprints = [];
{
 private _capture = [_x] call ServoPeregrino_Organizador_Weapons_fnc_configurationFromWeaponArray;
 if (_capture get "success") then {
  private _data = _capture get "data";
  private _c = _data get "configuration";
  private _loaded = _data get "loadedState";
  private _fp = (([_c] call ServoPeregrino_Organizador_Weapons_fnc_getConfigurationFingerprint) get "data") get "fingerprint";
  _fingerprints pushBack _fp;
  _observations pushBack createHashMapFromArray [
   ["observationIndex",_forEachIndex],["configuration",_c],["loadedState",_loaded],["configurationFingerprint",_fp]
  ];
 };
} forEach _rows;
private _duplicates = [];
{private _fp = _x; if ({_x isEqualTo _fp} count _fingerprints > 1) then {_duplicates pushBackUnique _fp}} forEach _fingerprints;
private _code = if (_duplicates isEqualTo []) then {"WEAPONS_IDENTITY_UNPROVEN"} else {"WEAPONS_IDENTITY_AMBIGUOUS"};
private _data = createHashMapFromArray [
 ["carrierNetId",netId _carrier],["carrierType",typeOf _carrier],["owner",owner _carrier],["local",local _carrier],
 ["observations",_observations],["duplicateConfigurationFingerprints",_duplicates],["resolvedInstanceId",""],
 ["physicalIdentityProven",false],["rawStandard",_rows],["observedAt",systemTimeUTC]
];
private _diagnostic = ["WARN",_code,"Snapshot cannot prove identity continuity.",_data] call ServoPeregrino_Organizador_Nexus_fnc_createDiagnostic;
[true,_code,"Observation only; index, carrier and configuration fingerprint are not identity.",_data,[_diagnostic]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
