private _required = ["initialize","createResult","createDiagnostic","registerCapability","getCapability","hasCapability","log"];
private _missing = _required select {isNil ("ServoPeregrino_Organizador_Nexus_fnc_" + _x)};
if !(_missing isEqualTo []) exitWith {
 diag_log format ["[SP_ORG] [WEAPONS] [NEXUS_REQUIRED] %1",_missing];
 createHashMapFromArray [["success",false],["code","WEAPONS_NEXUS_REQUIRED"],["data",createHashMap]]
};
private _init = [] call ServoPeregrino_Organizador_Nexus_fnc_initialize;
if !(_init get "success") exitWith {_init};
private _result = ["nexus.runtime"] call ServoPeregrino_Organizador_Nexus_fnc_getCapability;
if !(_result get "success") exitWith {_result};
private _cap = (_result get "data") get "capability";
private _ok = (_cap get "provider") isEqualTo "ServoPeregrino_Organizador_Nexus" && {[_cap get "id",1] call ServoPeregrino_Organizador_Nexus_fnc_hasCapability};
[_ok,"WEAPONS_NEXUS_CHECK","Nexus capability/provider validation."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
