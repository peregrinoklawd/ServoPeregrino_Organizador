#include "..\..\script_version.hpp"
if (!isServer) exitWith {
 [false,"WEAPONS_SERVER_ONLY","Live lifecycle test initialization is server-only."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _transfer = missionNamespace getVariable ["SP_ORG_Weapons_Box_TRANSFER",objNull];
private _duplicates = missionNamespace getVariable ["SP_ORG_Weapons_Box_DUPLICATES",objNull];
if (isNull _transfer || {isNull _duplicates}) exitWith {
 [false,"WEAPONS_LIVE_TEST_BOX_MISSING","Expected TRANSFER and DUPLICATES boxes."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

clearWeaponCargoGlobal _transfer;
clearMagazineCargoGlobal _transfer;
clearItemCargoGlobal _transfer;
clearBackpackCargoGlobal _transfer;

clearWeaponCargoGlobal _duplicates;
clearMagazineCargoGlobal _duplicates;
clearItemCargoGlobal _duplicates;
clearBackpackCargoGlobal _duplicates;

private _row = ["arifle_MX_F","","","",["30Rnd_65x39_caseless_mag",30],[],""];
_transfer addWeaponWithAttachmentsCargoGlobal [_row,1];
_duplicates addWeaponWithAttachmentsCargoGlobal [_row,2];

private _capture = [_row] call ServoPeregrino_Organizador_Weapons_fnc_configurationFromWeaponArray;
if !(_capture get "success") exitWith {_capture};
private _configuration = (_capture get "data") get "configuration";
private _fingerprint = (([_configuration] call ServoPeregrino_Organizador_Weapons_fnc_getConfigurationFingerprint) get "data") get "fingerprint";

private _bcInstanceId = missionNamespace getVariable ["SP_ORG_Weapons_Live_BC_InstanceId",""];
if (_bcInstanceId isEqualTo "") then {
 private _created = [_configuration] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponInstance;
 if !(_created get "success") exitWith {_created};
 _bcInstanceId = (((_created get "data") get "instance") get "instanceId");
 missionNamespace setVariable ["SP_ORG_Weapons_Live_BC_InstanceId",_bcInstanceId];
};

private _eIds = missionNamespace getVariable ["SP_ORG_Weapons_Live_E_InstanceIds",[]];
if (count _eIds != 2) then {
 _eIds = [];
 for "_i" from 1 to 2 do {
  private _created = [_configuration] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponInstance;
  if (_created get "success") then {
   _eIds pushBack (((_created get "data") get "instance") get "instanceId");
  };
 };
 missionNamespace setVariable ["SP_ORG_Weapons_Live_E_InstanceIds",_eIds];
};

private _state = createHashMapFromArray [
 ["schemaVersion","0.1-B-r2-live-test"],
 ["phase","BC_TAKE"],
 ["beforeObservations",[]],
 ["beforeCaptured",false],
 ["activeContainer",""],
 ["expectedFingerprint",_fingerprint],
 ["bcInstanceId",_bcInstanceId],
 ["duplicateLogicalIds",_eIds],
 ["passed",0],
 ["failed",0],
 ["results",[]],
 ["complete",false]
];

missionNamespace setVariable [SP_ORG_WEAPONS_LIVE_TEST,_state,true];

diag_log format [
 "[SP_ORG] [WEAPONS] [LIVE_TEST_READY] phase=BC_TAKE bcInstanceId=%1 duplicateLogicalIds=%2 expectedFingerprint=%3",
 _bcInstanceId,_eIds,_fingerprint
];

[true,"WEAPONS_LIVE_TEST_READY","Manual live lifecycle test reset and ready.",createHashMapFromArray [["state",[_state] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
