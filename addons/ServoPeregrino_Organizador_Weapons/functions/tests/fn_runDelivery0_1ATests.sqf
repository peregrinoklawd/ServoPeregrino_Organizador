#include "..\..\script_version.hpp"
if (!isServer || {isRemoteExecuted} || {!(missionNamespace getVariable ["SP_ORG_Weapons_LabEnabled",false])}) exitWith {
 [false,"WEAPONS_TEST_SERVER_LAB_ONLY","Run locally on lab server/host."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _checks = [];
private _issued = [];
private _assert = {
 params ["_name","_ok"];
 _checks pushBack [_name,_ok];
 diag_log format ["[SP_ORG] [WEAPONS] [AUTO_TEST] %1 | %2",if (_ok) then {"PASS"} else {"FAIL"},_name];
};
private _init = [] call ServoPeregrino_Organizador_Weapons_fnc_initialize;
["lifecycle",_init get "success"] call _assert;
["idempotent lifecycle",([] call ServoPeregrino_Organizador_Weapons_fnc_initialize) get "success"] call _assert;
["Nexus compatible",([] call ServoPeregrino_Organizador_Weapons_fnc_validateNexus) get "success"] call _assert;
["weapons.runtime",["weapons.runtime",1] call ServoPeregrino_Organizador_Nexus_fnc_hasCapability] call _assert;
private _cap = ((["weapons.runtime"] call ServoPeregrino_Organizador_Nexus_fnc_getCapability) get "data") get "capability";
["capability provider",(_cap get "provider") isEqualTo "ServoPeregrino_Organizador_Weapons"] call _assert;
["physical identity NOT claimed",!(([] call ServoPeregrino_Organizador_Weapons_fnc_getRuntimeStatus) get "data" get "physicalIdentityProven")] call _assert;

private _created = ["arifle_MX_F"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponConfiguration;
["create configuration",_created get "success"] call _assert;
private _c = (_created get "data") get "configuration";
["preserve classname spelling",(_c get "weaponClass") isEqualTo "arifle_MX_F"] call _assert;
["structural validation",([_c] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponConfigurationStructural) get "success"] call _assert;
["semantic validation",([_c] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponConfigurationSemantic) get "success"] call _assert;

private _copy = [_c] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
_copy set ["optic","optic_Aco"];
["deep copy map",(_c get "optic") isEqualTo ""] call _assert;
private _nested = createHashMapFromArray [["list",[[1,2],createHashMapFromArray [["value",3]]]]];
private _nestedCopy = [_nested] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
((_nestedCopy get "list") select 0) set [0,999];
((_nestedCopy get "list") select 1) set ["value",999];
["deep copy nested aggregates",((_nested get "list") select 0 select 0) isEqualTo 1 && {(((_nested get "list") select 1) get "value") isEqualTo 3}] call _assert;

private _fp1 = (([_c] call ServoPeregrino_Organizador_Weapons_fnc_getConfigurationFingerprint) get "data") get "fingerprint";
private _fp2 = (([[_c] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy] call ServoPeregrino_Organizador_Weapons_fnc_getConfigurationFingerprint) get "data") get "fingerprint";
["deterministic fingerprint",_fp1 isEqualTo _fp2] call _assert;
private _caseVariant = [_c] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
_caseVariant set ["weaponClass","ARIFLE_mx_F"];
private _fpCase = (([_caseVariant] call ServoPeregrino_Organizador_Weapons_fnc_getConfigurationFingerprint) get "data") get "fingerprint";
["case-insensitive fingerprint without stored mutation",_fp1 isEqualTo _fpCase && {(_caseVariant get "weaponClass") isEqualTo "ARIFLE_mx_F"}] call _assert;
["equal configurations",(([_c,[_c] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy] call ServoPeregrino_Organizador_Weapons_fnc_compareWeaponConfigurations) get "data") get "equal"] call _assert;
["different attachment configuration",!((([_c,_copy] call ServoPeregrino_Organizador_Weapons_fnc_compareWeaponConfigurations) get "data") get "equal")] call _assert;

private _row30 = ["arifle_MX_F","","","",["30Rnd_65x39_caseless_mag",30],[],""];
private _row29 = ["arifle_MX_F","","","",["30Rnd_65x39_caseless_mag",29],[],""];
private _capture30 = [_row30] call ServoPeregrino_Organizador_Weapons_fnc_configurationFromWeaponArray;
private _capture29 = [_row29] call ServoPeregrino_Organizador_Weapons_fnc_configurationFromWeaponArray;
["weapon array capture separates loaded state",_capture30 get "success" && {_capture29 get "success"}] call _assert;
if (_capture30 get "success" && {_capture29 get "success"}) then {
 private _capCfg30 = (_capture30 get "data") get "configuration";
 private _capCfg29 = (_capture29 get "data") get "configuration";
 private _load30 = (_capture30 get "data") get "loadedState";
 private _load29 = (_capture29 get "data") get "loadedState";
 private _f30 = (([_capCfg30] call ServoPeregrino_Organizador_Weapons_fnc_getConfigurationFingerprint) get "data") get "fingerprint";
 private _f29 = (([_capCfg29] call ServoPeregrino_Organizador_Weapons_fnc_getConfigurationFingerprint) get "data") get "fingerprint";
 ["ammo count does not change WeaponConfiguration fingerprint",_f30 isEqualTo _f29] call _assert;
 ["loaded state preserves observed ammo",((_load30 get "primaryMagazine") select 1) isEqualTo 30 && {((_load29 get "primaryMagazine") select 1) isEqualTo 29}] call _assert;
};

["invalid payload",!(([42] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponConfigurationStructural) get "success")] call _assert;
["empty class",!(([""] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponConfiguration) get "success")] call _assert;
["capture invalid target",!(([objNull,"PRIMARY"] call ServoPeregrino_Organizador_Weapons_fnc_captureWeaponConfiguration) get "success")] call _assert;
["capture invalid shape",!(([[]] call ServoPeregrino_Organizador_Weapons_fnc_configurationFromWeaponArray) get "success")] call _assert;
{
 _x params ["_field","_value","_name"];
 private _bad = [_c] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 _bad set [_field,_value];
 [_name,!(([_bad] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponConfigurationStructural) get "success")] call _assert;
} forEach [
 ["schemaVersion",1,"configuration incompatible schema"],
 ["optic",42,"configuration field wrong type"],
 ["primaryMagazine",["30Rnd_65x39_caseless_mag",30],"loaded state rejected from configuration"],
 ["condition",0.5,"reject extra domain state"]
];
{
 _x params ["_field","_value","_name"];
 private _bad = [_c] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 _bad set [_field,_value];
 [_name,!(([_bad] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponConfigurationSemantic) get "success")] call _assert;
} forEach [
 ["weaponClass","SP_ORG_NO_SUCH_WEAPON","missing weapon class"],
 ["weaponClass","FirstAidKit","item is not weapon"],
 ["optic","SP_ORG_NO_SUCH_OPTIC","incompatible accessory"]
];

private _r1 = [_c] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponInstance;
private _r2 = [_c] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponInstance;
["create instance",_r1 get "success" && {_r2 get "success"}] call _assert;
if (_r1 get "success" && {_r2 get "success"}) then {
 private _i1 = (_r1 get "data") get "instance";
 private _i2 = (_r2 get "data") get "instance";
 _issued append [_i1 get "instanceId",_i2 get "instanceId"];
 ["same configuration distinct logical IDs",(_i1 get "instanceId") != (_i2 get "instanceId")] call _assert;
 ["distinct serials",(_i1 get "serial") != (_i2 get "serial")] call _assert;
 ["instance validation",([_i1] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponInstance) get "success"] call _assert;
 private _changed = [_c] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 _changed set ["optic","optic_Aco"];
 private _update = [_i1 get "instanceId",_changed] call ServoPeregrino_Organizador_Weapons_fnc_updateWeaponInstanceConfiguration;
 ["configuration update",_update get "success"] call _assert;
 if (_update get "success") then {
  private _after = (_update get "data") get "instance";
  ["update preserves instanceId",(_after get "instanceId") isEqualTo (_i1 get "instanceId")] call _assert;
  ["update preserves serial",(_after get "serial") isEqualTo (_i1 get "serial")] call _assert;
  ["update preserves createdAt",(_after get "createdAt") isEqualTo (_i1 get "createdAt")] call _assert;
 };
 _i1 set ["serial","BAD"];
 private _fresh = (([_issued select 0] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponInstance) get "data") get "instance";
 ["registry defensive copy",(_fresh get "serial") != "BAD"] call _assert;
 {
  _x params ["_field","_value","_name"];
  private _bad = [_fresh] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
  _bad set [_field,_value];
  [_name,!(([_bad] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponInstance) get "success")] call _assert;
 } forEach [
  ["schemaVersion","weapons.instance.v1","instance incompatible schema"],
  ["instanceId","","invalid instanceId"],["serial","BAD","invalid serial"],
  ["weaponClass","hgun_P07_F","instance class mismatch"],
  ["metadata",createHashMapFromArray [["scope","SESSION"],["authority","CLIENT"]],"client cannot declare authority"],
  ["metadata",createHashMapFromArray [["scope","SESSION"],["authority","SERVER"],["wear",1]],"no condition metadata"],
  ["createdAt",[],"invalid timestamp"],["wear",0.2,"no wear state"]
 ];
 private _other = ((["hgun_P07_F"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponConfiguration) get "data") get "configuration";
 ["reject class replacement",!(([_fresh get "instanceId",_other] call ServoPeregrino_Organizador_Weapons_fnc_updateWeaponInstanceConfiguration) get "success")] call _assert;
 [] call ServoPeregrino_Organizador_Weapons_fnc_initialize;
 ["lifecycle preserves issued identity",([_fresh get "instanceId"] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponInstance) get "success"] call _assert;
};

["invalid instance payload",!(([[]] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponInstance) get "success")] call _assert;
["missing registry identity",!((["WID-99999999999"] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponInstance) get "success")] call _assert;
["identity token invalid chars",!(["WID-12345678+","WID-"] call ServoPeregrino_Organizador_Weapons_fnc_isValidIdentityToken)] call _assert;
private _required = getArray (configFile >> "CfgPatches" >> "ServoPeregrino_Organizador_Weapons" >> "requiredAddons");
["dependencies Nexus and A3 only",_required isEqualTo ["A3_Functions_F","ServoPeregrino_Organizador_Nexus"]] call _assert;

// Cleanup only records created by this test; NEVER roll back sequence or reset live state.
private _registry = (missionNamespace getVariable SP_ORG_WEAPONS_AUTHORITY) get "instances";
{_registry deleteAt _x} forEach _issued;
private _passed = {_x select 1} count _checks;
private _failed = count _checks - _passed;
diag_log format ["[SP_ORG] [WEAPONS] [AUTO_TEST_SUMMARY] passed=%1 failed=%2 total=%3 | RUNTIME_MANUAL_GATE=OPEN",_passed,_failed,count _checks];
hint format ["Weapons AUTO TEST: %1/%2; falhas=%3. Identidade fisica: gate ABERTO.",_passed,count _checks,_failed];
[_failed isEqualTo 0,"WEAPONS_AUTO_TEST_COMPLETE","Logical/runtime tests do not prove physical identity.",createHashMapFromArray [["passed",_passed],["failed",_failed],["checks",_checks],["manualGate","OPEN"]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
