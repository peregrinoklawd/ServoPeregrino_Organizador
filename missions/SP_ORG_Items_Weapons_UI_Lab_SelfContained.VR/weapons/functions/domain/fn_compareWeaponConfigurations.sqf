params [["_left",false],["_right",false]];
private _a = [_left] call ServoPeregrino_Organizador_Weapons_fnc_getConfigurationFingerprint;
if !(_a get "success") exitWith {_a};
private _b = [_right] call ServoPeregrino_Organizador_Weapons_fnc_getConfigurationFingerprint;
if !(_b get "success") exitWith {_b};
[true,"WEAPONS_CONFIGURATION_COMPARISON","Configuration equality is not identity equality.",createHashMapFromArray [["equal",((_a get "data") get "fingerprint") isEqualTo ((_b get "data") get "fingerprint")]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
