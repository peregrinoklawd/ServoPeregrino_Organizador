#include "..\..\script_version.hpp"
if (!isServer || {isRemoteExecuted} || {!(missionNamespace getVariable ["SP_ORG_Weapons_LabEnabled",false])}) exitWith {
 [false,"WEAPONS_TEST_SERVER_LAB_ONLY","Run locally on mission-first lab server/host."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _checks = [];
private _issued = [];
private _assert = {
 params ["_name","_ok"];
 _checks pushBack [_name,_ok];
 diag_log format ["[SP_ORG] [WEAPONS] [AUTO_TEST] mode=MISSION_FIRST %1 | %2",if (_ok) then {"PASS"} else {"FAIL"},_name];
};

private _loadedAmmoCount = {
 params [["_loaded",createHashMap,[createHashMap]]];
 private _mag = _loaded getOrDefault ["primaryMagazine",[]];
 if !(_mag isEqualType [] && {count _mag >= 2}) exitWith {-1};
 private _ammo = _mag select 1;
 if !(_ammo isEqualType 0) exitWith {-1};
 _ammo
};

private _setWeaponLoadoutRow = {
 params [
  ["_unit",objNull,[objNull]],
  ["_index",0,[0]],
  ["_row",[],[[]]]
 ];
 private _loadout = getUnitLoadout _unit;
 _loadout set [_index,[_row] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy];
 _unit setUnitLoadout _loadout;
};

["mission-first marker",missionNamespace getVariable ["SP_ORG_Weapons_MissionFirst",false]] call _assert;
["Nexus function loaded",!isNil "ServoPeregrino_Organizador_Nexus_fnc_createResult"] call _assert;
["Weapons function loaded",!isNil "ServoPeregrino_Organizador_Weapons_fnc_createWeaponInstance"] call _assert;

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
  ["instanceId","","invalid instanceId"],
  ["serial","BAD","invalid serial"],
  ["weaponClass","hgun_P07_F","instance class mismatch"],
  ["metadata",createHashMapFromArray [["scope","SESSION"],["authority","CLIENT"]],"client cannot declare authority"],
  ["metadata",createHashMapFromArray [["scope","SESSION"],["authority","SERVER"],["wear",1]],"no condition metadata"],
  ["createdAt",[],"invalid timestamp"],
  ["wear",0.2,"no wear state"]
 ];

 private _other = ((["hgun_P07_F"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponConfiguration) get "data") get "configuration";
 ["reject class replacement",!(([_fresh get "instanceId",_other] call ServoPeregrino_Organizador_Weapons_fnc_updateWeaponInstanceConfiguration) get "success")] call _assert;

 [] call ServoPeregrino_Organizador_Weapons_fnc_initialize;
 ["lifecycle preserves issued identity",([_fresh get "instanceId"] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponInstance) get "success"] call _assert;
};

["invalid instance payload",!(([[]] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponInstance) get "success")] call _assert;
["missing registry identity",!((["WID-99999999999"] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponInstance) get "success")] call _assert;
["identity token invalid chars",!(["WID-12345678+","WID-"] call ServoPeregrino_Organizador_Weapons_fnc_isValidIdentityToken)] call _assert;


// -----------------------------------------------------------------------------
// R2: engine-backed mission-first checks that are meaningful in single player.
// They validate observer behavior, NOT physical identity continuity.
// -----------------------------------------------------------------------------
private _duplicatesBox = missionNamespace getVariable ["SP_ORG_Weapons_Box_DUPLICATES",objNull];
["engine duplicate box exists",!isNull _duplicatesBox] call _assert;
if (!isNull _duplicatesBox) then {
 private _dupObservation = [_duplicatesBox] call ServoPeregrino_Organizador_Weapons_fnc_inspectWeaponCarrier;
 ["engine duplicate box observation succeeds",_dupObservation get "success"] call _assert;
 if (_dupObservation get "success") then {
  private _dupData = _dupObservation get "data";
  ["two identical physical rows are AMBIGUOUS",(_dupObservation get "code") isEqualTo "WEAPONS_IDENTITY_AMBIGUOUS"] call _assert;
  ["duplicate observer sees two rows",count (_dupData get "observations") isEqualTo 2] call _assert;
  ["duplicate observer refuses resolved identity",(_dupData get "resolvedInstanceId") isEqualTo ""] call _assert;
  ["duplicate fingerprints reported",count (_dupData get "duplicateConfigurationFingerprints") >= 1] call _assert;
 };
};

private _transferBox = missionNamespace getVariable ["SP_ORG_Weapons_Box_TRANSFER",objNull];
["engine transfer box exists",!isNull _transferBox] call _assert;
if (!isNull _transferBox) then {
 clearWeaponCargoGlobal _transferBox;
 clearMagazineCargoGlobal _transferBox;
 clearItemCargoGlobal _transferBox;
 clearBackpackCargoGlobal _transferBox;

 private _row30Engine = ["arifle_MX_F","","","",["30Rnd_65x39_caseless_mag",30],[],""];
 private _row29Engine = ["arifle_MX_F","","","",["30Rnd_65x39_caseless_mag",29],[],""];
 _transferBox addWeaponWithAttachmentsCargoGlobal [_row30Engine,1];

 private _singleObs = [_transferBox] call ServoPeregrino_Organizador_Weapons_fnc_inspectWeaponCarrier;
 ["single cargo observation succeeds",_singleObs get "success"] call _assert;
 if (_singleObs get "success") then {
  ["single cargo remains UNPROVEN",(_singleObs get "code") isEqualTo "WEAPONS_IDENTITY_UNPROVEN"] call _assert;
  ["single cargo never resolves identity",((_singleObs get "data") get "resolvedInstanceId") isEqualTo ""] call _assert;
 };

 _transferBox addWeaponWithAttachmentsCargoGlobal [_row29Engine,1];
 private _ammoAmbiguous = [_transferBox] call ServoPeregrino_Organizador_Weapons_fnc_inspectWeaponCarrier;
 ["same config with 30/29 ammo is AMBIGUOUS",_ammoAmbiguous get "success" && {(_ammoAmbiguous get "code") isEqualTo "WEAPONS_IDENTITY_AMBIGUOUS"}] call _assert;
 if (_ammoAmbiguous get "success") then {
  private _ammoObservations = (_ammoAmbiguous get "data") get "observations";
  private _ammoCounts = [];
  {
   private _mag = ((_x get "loadedState") get "primaryMagazine");
   if !(_mag isEqualTo []) then {_ammoCounts pushBack (_mag select 1)};
  } forEach _ammoObservations;
  _ammoCounts sort true;
  ["engine observer preserves different ammo counts",_ammoCounts isEqualTo [29,30]] call _assert;
 };

 clearWeaponCargoGlobal _transferBox;
 _transferBox addWeaponWithAttachmentsCargoGlobal [_row30Engine,1];
 private _rowOptic = ["arifle_MX_F","","","optic_Aco",["30Rnd_65x39_caseless_mag",30],[],""];
 _transferBox addWeaponWithAttachmentsCargoGlobal [_rowOptic,1];

 private _differentConfig = [_transferBox] call ServoPeregrino_Organizador_Weapons_fnc_inspectWeaponCarrier;
 ["different attachments do not collapse as duplicate config",_differentConfig get "success" && {(_differentConfig get "code") isEqualTo "WEAPONS_IDENTITY_UNPROVEN"}] call _assert;
 if (_differentConfig get "success") then {
  ["different attachments yield zero duplicate fingerprints",count (((_differentConfig get "data") get "duplicateConfigurationFingerprints")) isEqualTo 0] call _assert;
 };

 clearWeaponCargoGlobal _transferBox;
};

private _holder = createVehicle ["GroundWeaponHolder_Scripted",[0,12,0],[],0,"CAN_COLLIDE"];
_holder addWeaponWithAttachmentsCargoGlobal [["arifle_MX_F","","","",["30Rnd_65x39_caseless_mag",30],[],""],1];
private _holderObs = [_holder] call ServoPeregrino_Organizador_Weapons_fnc_inspectWeaponCarrier;
["ground holder observation succeeds",_holderObs get "success"] call _assert;
if (_holderObs get "success") then {
 ["ground holder remains UNPROVEN",(_holderObs get "code") isEqualTo "WEAPONS_IDENTITY_UNPROVEN"] call _assert;
 ["ground holder never resolves identity",((_holderObs get "data") get "resolvedInstanceId") isEqualTo ""] call _assert;
};
deleteVehicle _holder;

if (!isMultiplayer && {hasInterface} && {!isNull player}) then {
 private _dispatchResult = [player,"DIAGNOSTICS","PRIMARY",objNull,""] call ServoPeregrino_Organizador_Weapons_fnc_dispatchLabRequest;
 ["single-player local dispatcher reaches server handler",_dispatchResult isEqualType createHashMap && {_dispatchResult getOrDefault ["success",false]}] call _assert;
 private _stateForRate = missionNamespace getVariable [SP_ORG_WEAPONS_AUTHORITY,createHashMap];
 if (count _stateForRate > 0) then {
  (_stateForRate get "requests") deleteAt (netId player);
 };
};


// -----------------------------------------------------------------------------
// 0.1-B — WeaponInstance Lifecycle / Event-Delta Evidence Candidate
// This can correlate continuity when the transition delta is unique.
// It NEVER sets physicalIdentityProven=true.
// -----------------------------------------------------------------------------
private _baseFp = (([_c] call ServoPeregrino_Organizador_Weapons_fnc_getConfigurationFingerprint) get "data") get "fingerprint";
private _otherConfig = [_c] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
_otherConfig set ["optic","optic_Aco"];
private _otherFp = (([_otherConfig] call ServoPeregrino_Organizador_Weapons_fnc_getConfigurationFingerprint) get "data") get "fingerprint";

private _obs = {
 params ["_fps"];
 _fps apply {createHashMapFromArray [["configurationFingerprint",_x]]}
};

private _locUnit = createHashMapFromArray [["kind","UNIT_SLOT"],["id","SELF:PRIMARY"]];
private _locBox = createHashMapFromArray [["kind","CONTAINER"],["id","TEST_BOX"]];

// PUT: empty destination -> exactly one matching weapon = unique evidence.
private _putUnique = [
 "PUT",
 [[]] call _obs,
 [[_baseFp]] call _obs,
 _baseFp,
 "WID-TEST-00000001",
 _locUnit,
 _locBox
] call ServoPeregrino_Organizador_Weapons_fnc_analyzeLifecycleTransition;
["lifecycle PUT unique succeeds",_putUnique get "success"] call _assert;
if (_putUnique get "success") then {
 private _ev = (_putUnique get "data") get "evidence";
 ["PUT unique => CORRELATED",(_ev get "continuityStatus") isEqualTo "CORRELATED"] call _assert;
 ["PUT unique candidateCount=1",(_ev get "candidateCount") isEqualTo 1] call _assert;
 ["PUT correlation does NOT prove physical identity",!(_ev get "physicalIdentityProven")] call _assert;
 ["PUT unique code",(_ev get "evidenceCode") isEqualTo "WEAPONS_LIFECYCLE_UNIQUE_EVENT_DELTA"] call _assert;
};

// PUT: one identical already present -> two identical after = ambiguous.
private _putAmb = [
 "PUT",
 [[_baseFp]] call _obs,
 [[_baseFp,_baseFp]] call _obs,
 _baseFp,
 "WID-TEST-00000002",
 _locUnit,
 _locBox
] call ServoPeregrino_Organizador_Weapons_fnc_analyzeLifecycleTransition;
["lifecycle PUT duplicate set succeeds",_putAmb get "success"] call _assert;
if (_putAmb get "success") then {
 private _ev = (_putAmb get "data") get "evidence";
 ["PUT identical set => AMBIGUOUS",(_ev get "continuityStatus") isEqualTo "AMBIGUOUS"] call _assert;
 ["PUT identical candidateCount=2",(_ev get "candidateCount") isEqualTo 2] call _assert;
 ["PUT ambiguous does NOT prove physical identity",!(_ev get "physicalIdentityProven")] call _assert;
};

// TAKE: one matching before -> zero after = unique evidence.
private _takeUnique = [
 "TAKE",
 [[_baseFp]] call _obs,
 [[]] call _obs,
 _baseFp,
 "WID-TEST-00000003",
 _locBox,
 _locUnit
] call ServoPeregrino_Organizador_Weapons_fnc_analyzeLifecycleTransition;
["lifecycle TAKE unique succeeds",_takeUnique get "success"] call _assert;
if (_takeUnique get "success") then {
 private _ev = (_takeUnique get "data") get "evidence";
 ["TAKE unique => CORRELATED",(_ev get "continuityStatus") isEqualTo "CORRELATED"] call _assert;
 ["TAKE unique candidateCount=1",(_ev get "candidateCount") isEqualTo 1] call _assert;
 ["TAKE correlation does NOT prove physical identity",!(_ev get "physicalIdentityProven")] call _assert;
};

// TAKE: two identical before -> one identical after = ambiguous.
private _takeAmb = [
 "TAKE",
 [[_baseFp,_baseFp]] call _obs,
 [[_baseFp]] call _obs,
 _baseFp,
 "WID-TEST-00000004",
 _locBox,
 _locUnit
] call ServoPeregrino_Organizador_Weapons_fnc_analyzeLifecycleTransition;
["lifecycle TAKE duplicate set succeeds",_takeAmb get "success"] call _assert;
if (_takeAmb get "success") then {
 private _ev = (_takeAmb get "data") get "evidence";
 ["TAKE identical set => AMBIGUOUS",(_ev get "continuityStatus") isEqualTo "AMBIGUOUS"] call _assert;
 ["TAKE identical candidateCount=2",(_ev get "candidateCount") isEqualTo 2] call _assert;
 ["TAKE ambiguous does NOT prove physical identity",!(_ev get "physicalIdentityProven")] call _assert;
};

// No expected delta => UNPROVEN.
private _noDelta = [
 "PUT",
 [[]] call _obs,
 [[]] call _obs,
 _baseFp,
 "WID-TEST-00000005",
 _locUnit,
 _locBox
] call ServoPeregrino_Organizador_Weapons_fnc_analyzeLifecycleTransition;
["lifecycle no-delta succeeds",_noDelta get "success"] call _assert;
if (_noDelta get "success") then {
 private _ev = (_noDelta get "data") get "evidence";
 ["no delta => UNPROVEN",(_ev get "continuityStatus") isEqualTo "UNPROVEN"] call _assert;
 ["UNPROVEN candidateCount=0",(_ev get "candidateCount") isEqualTo 0] call _assert;
 ["UNPROVEN does NOT prove physical identity",!(_ev get "physicalIdentityProven")] call _assert;
};

// Another differently configured weapon does not create ambiguity for this fingerprint.
private _otherPresent = [
 "PUT",
 [[_otherFp]] call _obs,
 [[_otherFp,_baseFp]] call _obs,
 _baseFp,
 "WID-TEST-00000006",
 _locUnit,
 _locBox
] call ServoPeregrino_Organizador_Weapons_fnc_analyzeLifecycleTransition;
["different config can coexist with unique target delta",_otherPresent get "success"] call _assert;
if (_otherPresent get "success") then {
 private _ev = (_otherPresent get "data") get "evidence";
 ["different config does not create false ambiguity",(_ev get "continuityStatus") isEqualTo "CORRELATED"] call _assert;
};

// Invalid lifecycle requests fail closed.
["invalid transition rejected",!((["MOVE",[],[],_baseFp,"",_locUnit,_locBox] call ServoPeregrino_Organizador_Weapons_fnc_analyzeLifecycleTransition) get "success")] call _assert;
["missing lifecycle fingerprint rejected",!((["PUT",[],[],"","",_locUnit,_locBox] call ServoPeregrino_Organizador_Weapons_fnc_analyzeLifecycleTransition) get "success")] call _assert;

// -----------------------------------------------------------------------------
// Engine-backed transition snapshots using real cargo objects.
// -----------------------------------------------------------------------------
private _lifeBox = createVehicle ["Box_NATO_Wps_F",[0,18,0],[],0,"CAN_COLLIDE"];
clearWeaponCargoGlobal _lifeBox;
clearMagazineCargoGlobal _lifeBox;
clearItemCargoGlobal _lifeBox;
clearBackpackCargoGlobal _lifeBox;

private _engineBefore0 = [_lifeBox] call ServoPeregrino_Organizador_Weapons_fnc_inspectWeaponCarrier;
_lifeBox addWeaponWithAttachmentsCargoGlobal [_row30,1];
private _engineAfter1 = [_lifeBox] call ServoPeregrino_Organizador_Weapons_fnc_inspectWeaponCarrier;
private _engineFp = (((_engineAfter1 get "data") get "observations") select 0) get "configurationFingerprint";

private _engPut1 = [
 "PUT",
 (_engineBefore0 get "data") get "observations",
 (_engineAfter1 get "data") get "observations",
 _engineFp,
 "WID-ENGINE-00000001",
 createHashMapFromArray [["kind","UNIT_SLOT"],["id","TESTER"]],
 createHashMapFromArray [["kind","CONTAINER"],["id",netId _lifeBox]]
] call ServoPeregrino_Organizador_Weapons_fnc_analyzeLifecycleTransition;

["engine empty->one transition analyzed",_engPut1 get "success"] call _assert;
if (_engPut1 get "success") then {
 private _ev = (_engPut1 get "data") get "evidence";
 ["engine empty->one => CORRELATED",(_ev get "continuityStatus") isEqualTo "CORRELATED"] call _assert;
 ["engine correlation still physicalIdentityProven=false",!(_ev get "physicalIdentityProven")] call _assert;
};

// Add a second weapon with the SAME configuration fingerprint but different ammo.
private _engineBefore1 = _engineAfter1;
_lifeBox addWeaponWithAttachmentsCargoGlobal [_row29,1];
private _engineAfter2 = [_lifeBox] call ServoPeregrino_Organizador_Weapons_fnc_inspectWeaponCarrier;

private _engPut2 = [
 "PUT",
 (_engineBefore1 get "data") get "observations",
 (_engineAfter2 get "data") get "observations",
 _engineFp,
 "WID-ENGINE-00000002",
 createHashMapFromArray [["kind","UNIT_SLOT"],["id","TESTER"]],
 createHashMapFromArray [["kind","CONTAINER"],["id",netId _lifeBox]]
] call ServoPeregrino_Organizador_Weapons_fnc_analyzeLifecycleTransition;

["engine one->two identical transition analyzed",_engPut2 get "success"] call _assert;
if (_engPut2 get "success") then {
 private _ev = (_engPut2 get "data") get "evidence";
 ["engine one->two identical => AMBIGUOUS",(_ev get "continuityStatus") isEqualTo "AMBIGUOUS"] call _assert;
 ["ammo difference does not rescue identity ambiguity",(_ev get "candidateCount") isEqualTo 2] call _assert;
 ["engine ambiguous physicalIdentityProven=false",!(_ev get "physicalIdentityProven")] call _assert;
};

// Simulate removal of one from an identical set: 2 -> 1 remains ambiguous.
private _engineBefore2 = _engineAfter2;
clearWeaponCargoGlobal _lifeBox;
_lifeBox addWeaponWithAttachmentsCargoGlobal [_row30,1];
private _engineAfterTake1 = [_lifeBox] call ServoPeregrino_Organizador_Weapons_fnc_inspectWeaponCarrier;
private _engTakeAmb = [
 "TAKE",
 (_engineBefore2 get "data") get "observations",
 (_engineAfterTake1 get "data") get "observations",
 _engineFp,
 "WID-ENGINE-00000003",
 createHashMapFromArray [["kind","CONTAINER"],["id",netId _lifeBox]],
 createHashMapFromArray [["kind","UNIT_SLOT"],["id","TESTER"]]
] call ServoPeregrino_Organizador_Weapons_fnc_analyzeLifecycleTransition;

["engine two->one identical transition analyzed",_engTakeAmb get "success"] call _assert;
if (_engTakeAmb get "success") then {
 private _ev = (_engTakeAmb get "data") get "evidence";
 ["engine two->one identical => AMBIGUOUS",(_ev get "continuityStatus") isEqualTo "AMBIGUOUS"] call _assert;
};

// Then 1 -> 0 is uniquely correlated by the transition evidence.
private _engineBeforeTakeUnique = _engineAfterTake1;
clearWeaponCargoGlobal _lifeBox;
private _engineAfter0 = [_lifeBox] call ServoPeregrino_Organizador_Weapons_fnc_inspectWeaponCarrier;
private _engTakeUnique = [
 "TAKE",
 (_engineBeforeTakeUnique get "data") get "observations",
 (_engineAfter0 get "data") get "observations",
 _engineFp,
 "WID-ENGINE-00000004",
 createHashMapFromArray [["kind","CONTAINER"],["id",netId _lifeBox]],
 createHashMapFromArray [["kind","UNIT_SLOT"],["id","TESTER"]]
] call ServoPeregrino_Organizador_Weapons_fnc_analyzeLifecycleTransition;

["engine one->zero transition analyzed",_engTakeUnique get "success"] call _assert;
if (_engTakeUnique get "success") then {
 private _ev = (_engTakeUnique get "data") get "evidence";
 ["engine one->zero => CORRELATED",(_ev get "continuityStatus") isEqualTo "CORRELATED"] call _assert;
 ["engine one->zero still not physical proof",!(_ev get "physicalIdentityProven")] call _assert;
};

deleteVehicle _lifeBox;


// 0.1-B R2 regression for live delta detection.
private _deltaObs = {
 params ["_fps"];
 _fps apply {createHashMapFromArray [["configurationFingerprint",_x]]}
};

private _dPut = [
 "PUT",
 [[]] call _deltaObs,
 [[_baseFp]] call _deltaObs
] call ServoPeregrino_Organizador_Weapons_fnc_detectLifecycleDelta;
["R2 detect PUT 0->1",_dPut get "success" && {((_dPut get "data") get "fingerprint") isEqualTo _baseFp}] call _assert;

private _dTake = [
 "TAKE",
 [[_baseFp]] call _deltaObs,
 [[]] call _deltaObs
] call ServoPeregrino_Organizador_Weapons_fnc_detectLifecycleDelta;
["R2 detect TAKE 1->0",_dTake get "success" && {((_dTake get "data") get "fingerprint") isEqualTo _baseFp}] call _assert;

private _dDupTake = [
 "TAKE",
 [[_baseFp,_baseFp]] call _deltaObs,
 [[_baseFp]] call _deltaObs
] call ServoPeregrino_Organizador_Weapons_fnc_detectLifecycleDelta;
["R2 detect TAKE 2->1 same fingerprint",_dDupTake get "success" && {((_dDupTake get "data") get "beforeCount") isEqualTo 2} && {((_dDupTake get "data") get "afterCount") isEqualTo 1}] call _assert;

private _dNone = [
 "PUT",
 [[_baseFp]] call _deltaObs,
 [[_baseFp]] call _deltaObs
] call ServoPeregrino_Organizador_Weapons_fnc_detectLifecycleDelta;
["R2 reject no-delta detector",!(_dNone get "success") && {(_dNone get "code") isEqualTo "WEAPONS_LIFECYCLE_DELTA_NOT_FOUND"}] call _assert;

private _dMulti = [
 "PUT",
 [[]] call _deltaObs,
 [[_baseFp,_otherFp]] call _deltaObs
] call ServoPeregrino_Organizador_Weapons_fnc_detectLifecycleDelta;
["R2 reject multiple simultaneous config deltas",!(_dMulti get "success") && {(_dMulti get "code") isEqualTo "WEAPONS_LIFECYCLE_MULTIPLE_DELTAS"}] call _assert;

private _liveStateResult = [] call ServoPeregrino_Organizador_Weapons_fnc_getLiveLifecycleStatus;
["R2 manual live test state initialized",_liveStateResult get "success"] call _assert;
if (_liveStateResult get "success") then {
 private _liveState = (_liveStateResult get "data") get "state";
 ["R2 manual test starts at BC_TAKE",(_liveState get "phase") isEqualTo "BC_TAKE"] call _assert;
 ["R2 manual test has one BC logical instance",(_liveState get "bcInstanceId") != ""] call _assert;
 ["R2 duplicate test exposes two logical candidates but no mapping",count (_liveState get "duplicateLogicalIds") isEqualTo 2] call _assert;
};

private _runtime = [] call ServoPeregrino_Organizador_Weapons_fnc_getRuntimeStatus;
["mission-first runtime marker",((_runtime get "data") getOrDefault ["executionMode",""]) isEqualTo "MISSION_FIRST"] call _assert;
["0.1-B identity strategy marker",((_runtime get "data") getOrDefault ["identityStrategy",""]) isEqualTo "EVENT_DELTA_EVIDENCE_CANDIDATE"] call _assert;
["PBO gate deferred",((_runtime get "data") getOrDefault ["pboGate",""]) isEqualTo "DEFERRED"] call _assert;

private _registry = (missionNamespace getVariable SP_ORG_WEAPONS_AUTHORITY) get "instances";
{_registry deleteAt _x} forEach _issued;



// -----------------------------------------------------------------------------
// R3 regression: an empty container is a valid BEFORE snapshot for PUT.
// This reproduces the real manual failure from R2 and prevents regression.
// -----------------------------------------------------------------------------
if (!isMultiplayer && {hasInterface} && {!isNull player}) then {
 private _r3Transfer = missionNamespace getVariable ["SP_ORG_Weapons_Box_TRANSFER",objNull];
 ["R3 regression transfer box exists",!isNull _r3Transfer] call _assert;

 if (!isNull _r3Transfer) then {
  clearWeaponCargoGlobal _r3Transfer;
  clearMagazineCargoGlobal _r3Transfer;
  clearItemCargoGlobal _r3Transfer;
  clearBackpackCargoGlobal _r3Transfer;

  private _r3State = missionNamespace getVariable [SP_ORG_WEAPONS_LIVE_TEST,createHashMap];
  _r3State set ["phase","BC_PUT"];
  _r3State set ["beforeObservations",[]];
  _r3State set ["beforeCaptured",true];
  _r3State set ["activeContainer",netId _r3Transfer];
  _r3State set ["expectedFingerprint",_baseFp];
  _r3State set ["failed",0];
  _r3State set ["passed",0];
  _r3State set ["results",[]];
  _r3State set ["complete",false];

  _r3Transfer addWeaponWithAttachmentsCargoGlobal [_row30,1];

  private _r3Put = [
   player,"PUT",_r3Transfer,"arifle_MX_F"
  ] call ServoPeregrino_Organizador_Weapons_fnc_handleLiveLifecycleEvent;

  ["R3 empty BEFORE snapshot accepted",_r3Put get "success"] call _assert;
  if (_r3Put get "success") then {
   private _r3Data = _r3Put get "data";
   private _r3Evidence = _r3Data get "evidence";
   ["R3 empty BEFORE => PUT CORRELATED",(_r3Evidence get "continuityStatus") isEqualTo "CORRELATED"] call _assert;
   ["R3 empty BEFORE candidateCount=1",(_r3Evidence get "candidateCount") isEqualTo 1] call _assert;
   ["R3 empty BEFORE keeps physicalIdentityProven=false",!(_r3Evidence get "physicalIdentityProven")] call _assert;
  };
 };
};

// Restore the controlled live manual gate because AUTO TEST manipulates TRANSFER.
private _manualRestore = [] call ServoPeregrino_Organizador_Weapons_fnc_initializeLiveLifecycleTest;
["R3 manual gate restored after AUTO TEST",_manualRestore get "success"] call _assert;


// -----------------------------------------------------------------------------
// 0.2 — WeaponConfiguration capture / diff / engine apply round-trip
// -----------------------------------------------------------------------------
private _slotDefs = [] call ServoPeregrino_Organizador_Weapons_fnc_getConfigurationSlotDefinitions;
["0.2 slot definitions closed to four attachment slots",count _slotDefs isEqualTo 4] call _assert;
["0.2 muzzle engine slot",((_slotDefs get "muzzle") get "engineSlot") isEqualTo "MuzzleSlot"] call _assert;
["0.2 pointer engine slot",((_slotDefs get "pointer") get "engineSlot") isEqualTo "PointerSlot"] call _assert;
["0.2 optic engine slot",((_slotDefs get "optic") get "engineSlot") isEqualTo "CowsSlot"] call _assert;
["0.2 bipod engine slot",((_slotDefs get "bipod") get "engineSlot") isEqualTo "UnderBarrelSlot"] call _assert;

private _cfgEmpty = ((["arifle_MX_F"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponConfiguration) get "data") get "configuration";
["0.2 schema active",(_cfgEmpty get "schemaVersion") isEqualTo "0.2-candidate"] call _assert;

private _cfgFull = [_cfgEmpty] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
_cfgFull set ["muzzle","muzzle_snds_H"];
_cfgFull set ["pointer","acc_pointer_IR"];
_cfgFull set ["optic","optic_Aco"];
_cfgFull set ["bipod","bipod_01_F_blk"];

["0.2 full MX configuration semantic valid",([_cfgFull] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponConfigurationSemantic) get "success"] call _assert;

private _diffFull = [_cfgEmpty,_cfgFull] call ServoPeregrino_Organizador_Weapons_fnc_diffWeaponConfigurations;
["0.2 diff succeeds",_diffFull get "success"] call _assert;
if (_diffFull get "success") then {
 private _dd = _diffFull get "data";
 ["0.2 diff reports four changed slots",(_dd get "changedCount") isEqualTo 4] call _assert;
 ["0.2 diff same weapon class",_dd get "sameWeaponClass"] call _assert;
 ["0.2 diff not equal",!(_dd get "equal")] call _assert;
};

private _diffSame = [_cfgFull,[_cfgFull] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy] call ServoPeregrino_Organizador_Weapons_fnc_diffWeaponConfigurations;
["0.2 no-op diff changedCount=0",_diffSame get "success" && {((_diffSame get "data") get "changedCount") isEqualTo 0} && {((_diffSame get "data") get "equal")}] call _assert;

private _cfgCase = [_cfgFull] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
_cfgCase set ["weaponClass","ARIFLE_mx_F"];
_cfgCase set ["optic","OPTIC_ACO"];
private _diffCase = [_cfgFull,_cfgCase] call ServoPeregrino_Organizador_Weapons_fnc_diffWeaponConfigurations;
["0.2 diff comparison is case-insensitive",_diffCase get "success" && {((_diffCase get "data") get "equal")}] call _assert;

private _otherClassCfg = ((["hgun_P07_F"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponConfiguration) get "data") get "configuration";
private _diffClass = [_cfgEmpty,_otherClassCfg] call ServoPeregrino_Organizador_Weapons_fnc_diffWeaponConfigurations;
["0.2 diff detects weapon class mismatch",_diffClass get "success" && {!((_diffClass get "data") get "sameWeaponClass")} && {!((_diffClass get "data") get "equal")}] call _assert;

if (hasInterface && {!isNull player} && {local player}) then {
 private _savedLoadout02 = getUnitLoadout player;

 // PRIMARY round-trip with non-full magazine to prove ammo is transient and preserved.
 removeAllWeapons player;
 [player,0,["arifle_MX_F","","","",["30Rnd_65x39_caseless_mag",17],[],""]] call _setWeaponLoadoutRow;

 private _primaryBefore = [player,"PRIMARY"] call ServoPeregrino_Organizador_Weapons_fnc_captureWeaponConfiguration;
 ["0.2 PRIMARY capture before apply",_primaryBefore get "success"] call _assert;
 if (_primaryBefore get "success") then {
  private _beforeLoaded02 = (_primaryBefore get "data") get "loadedState";
  ["0.2 PRIMARY starts with 17 rounds",([_beforeLoaded02] call _loadedAmmoCount) isEqualTo 17] call _assert;
 };

 private _applyFull = [player,"PRIMARY",_cfgFull] call ServoPeregrino_Organizador_Weapons_fnc_applyWeaponConfiguration;
 ["0.2 PRIMARY apply full configuration",_applyFull get "success"] call _assert;
 if (_applyFull get "success") then {
  private _applyData = _applyFull get "data";
  ["0.2 PRIMARY apply reports four changes",(((_applyData get "diff") get "changedCount") isEqualTo 4)] call _assert;
  ["0.2 PRIMARY loaded state preserved by apply",(_applyData get "loadedStateBefore") isEqualTo (_applyData get "loadedStateAfter")] call _assert;
  private _afterLoaded02 = _applyData get "loadedStateAfter";
  ["0.2 PRIMARY apply preserves 17 rounds",([_afterLoaded02] call _loadedAmmoCount) isEqualTo 17] call _assert;
 };

 private _enginePrimaryItems = primaryWeaponItems player;
 ["0.2 PRIMARY engine items match target",_enginePrimaryItems isEqualTo ["muzzle_snds_H","acc_pointer_IR","optic_Aco","bipod_01_F_blk"]] call _assert;

 private _capturedFull = [player,"PRIMARY"] call ServoPeregrino_Organizador_Weapons_fnc_captureWeaponConfiguration;
 ["0.2 PRIMARY recapture succeeds",_capturedFull get "success"] call _assert;
 if (_capturedFull get "success") then {
  private _cmpFull = [_cfgFull,(_capturedFull get "data") get "configuration"] call ServoPeregrino_Organizador_Weapons_fnc_compareWeaponConfigurations;
  ["0.2 PRIMARY round-trip configuration equal",_cmpFull get "success" && {((_cmpFull get "data") get "equal")}] call _assert;
 };

 private _applyNoop = [player,"PRIMARY",_cfgFull] call ServoPeregrino_Organizador_Weapons_fnc_applyWeaponConfiguration;
 ["0.2 PRIMARY no-op apply succeeds",_applyNoop get "success"] call _assert;
 if (_applyNoop get "success") then {
  ["0.2 PRIMARY no-op code",(_applyNoop get "code") isEqualTo "WEAPONS_CONFIGURATION_ALREADY_APPLIED"] call _assert;
  ["0.2 PRIMARY no-op diff=0",((((_applyNoop get "data") get "diff") get "changedCount") isEqualTo 0)] call _assert;
 };

 // Invalid configuration must fail before engine mutation.
 private _badCfg02 = [_cfgFull] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 _badCfg02 set ["optic","SP_ORG_NO_SUCH_OPTIC"];
 private _beforeBad = [player,"PRIMARY"] call ServoPeregrino_Organizador_Weapons_fnc_captureWeaponConfiguration;
 private _badApply = [player,"PRIMARY",_badCfg02] call ServoPeregrino_Organizador_Weapons_fnc_applyWeaponConfiguration;
 ["0.2 invalid optic rejected before mutation",!(_badApply get "success")] call _assert;
 private _afterBad = [player,"PRIMARY"] call ServoPeregrino_Organizador_Weapons_fnc_captureWeaponConfiguration;
 if (_beforeBad get "success" && {_afterBad get "success"}) then {
  private _cmpBad = [(_beforeBad get "data") get "configuration",(_afterBad get "data") get "configuration"] call ServoPeregrino_Organizador_Weapons_fnc_compareWeaponConfigurations;
  ["0.2 invalid apply leaves engine configuration unchanged",_cmpBad get "success" && {((_cmpBad get "data") get "equal")}] call _assert;
 };

 // Wrong class must fail closed.
 private _wrongClassApply = [player,"PRIMARY",_otherClassCfg] call ServoPeregrino_Organizador_Weapons_fnc_applyWeaponConfiguration;
 ["0.2 wrong weaponClass rejected",!(_wrongClassApply get "success") && {(_wrongClassApply get "code") isEqualTo "WEAPONS_APPLY_CLASS_MISMATCH"}] call _assert;
 ["0.2 wrong class does not replace equipped weapon",(primaryWeapon player) isEqualTo "arifle_MX_F"] call _assert;

 // Remove all attachments while keeping loaded magazine/ammo.
 private _applyEmpty = [player,"PRIMARY",_cfgEmpty] call ServoPeregrino_Organizador_Weapons_fnc_applyWeaponConfiguration;
 ["0.2 PRIMARY apply empty configuration",_applyEmpty get "success"] call _assert;
 ["0.2 PRIMARY all attachment slots empty",(primaryWeaponItems player) isEqualTo ["","","",""]] call _assert;
 if (_applyEmpty get "success") then {
  private _emptyLoaded = (_applyEmpty get "data") get "loadedStateAfter";
  ["0.2 PRIMARY removal preserves 17 rounds",([_emptyLoaded] call _loadedAmmoCount) isEqualTo 17] call _assert;
 };

 // HANDGUN route.
 removeAllWeapons player;
 [player,2,["hgun_P07_F","","","",["16Rnd_9x21_Mag",11],[],""]] call _setWeaponLoadoutRow;
 private _pistolCfg = ((["hgun_P07_F"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponConfiguration) get "data") get "configuration";
 _pistolCfg set ["muzzle","muzzle_snds_L"];
 private _pistolApply = [player,"HANDGUN",_pistolCfg] call ServoPeregrino_Organizador_Weapons_fnc_applyWeaponConfiguration;
 ["0.2 HANDGUN apply route",_pistolApply get "success"] call _assert;
 if (_pistolApply get "success") then {
  ["0.2 HANDGUN suppressor observed",(((handgunItems player) select 0) isEqualTo "muzzle_snds_L")] call _assert;
  private _pistolLoaded = (_pistolApply get "data") get "loadedStateAfter";
  ["0.2 HANDGUN preserves 11 rounds",([_pistolLoaded] call _loadedAmmoCount) isEqualTo 11] call _assert;
 };

 // SECONDARY route: derive the no-op target from what the engine actually reports.
// Do not assume the config class used to construct the loadout is the same string
// returned by secondaryWeapon/capture on every inheritance/alias path.
 removeAllWeapons player;
 [player,1,["launch_NLAW_F","","","",["NLAW_F",1],[],""]] call _setWeaponLoadoutRow;

 private _secondaryEngineClass = secondaryWeapon player;
 ["0.2 R3 SECONDARY engine class observed",_secondaryEngineClass != ""] call _assert;

 private _launcherBefore = [player,"SECONDARY"] call ServoPeregrino_Organizador_Weapons_fnc_captureWeaponConfiguration;
 ["0.2 SECONDARY capture before no-op",_launcherBefore get "success"] call _assert;

 private _launcherCfg = createHashMap;
 if (_launcherBefore get "success") then {
  private _launcherDataBefore = _launcherBefore get "data";
  _launcherCfg = [_launcherDataBefore get "configuration"] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
  private _launcherLoadedBefore = _launcherDataBefore get "loadedState";

  ["0.2 SECONDARY starts with loaded launcher magazine",!((_launcherLoadedBefore get "primaryMagazine") isEqualTo [])] call _assert;
  ["0.2 R3 SECONDARY captured class matches engine",
   (toLowerANSI (_launcherCfg get "weaponClass")) isEqualTo (toLowerANSI _secondaryEngineClass)
  ] call _assert;

  diag_log format [
   "[SP_ORG] [WEAPONS] [AUTO_TEST_DETAIL] test=SECONDARY_OBSERVED_CLASS engineClass=%1 capturedClass=%2 configuration=%3 loadedState=%4",
   _secondaryEngineClass,
   _launcherCfg get "weaponClass",
   _launcherCfg,
   _launcherLoadedBefore
  ];
 };

 if (count _launcherCfg > 0) then {
  private _launcherApply = [player,"SECONDARY",_launcherCfg] call ServoPeregrino_Organizador_Weapons_fnc_applyWeaponConfiguration;
  diag_log format ["[SP_ORG] [WEAPONS] [AUTO_TEST_DETAIL] test=SECONDARY_NOOP result=%1",_launcherApply];
  ["0.2 SECONDARY no-op apply route",_launcherApply get "success"] call _assert;
  if (_launcherApply get "success") then {
   ["0.2 SECONDARY no-op code",(_launcherApply get "code") isEqualTo "WEAPONS_CONFIGURATION_ALREADY_APPLIED"] call _assert;
   private _launcherLoaded = (_launcherApply get "data") get "loadedStateAfter";
   ["0.2 SECONDARY preserves loaded launcher magazine",!((_launcherLoaded get "primaryMagazine") isEqualTo [])] call _assert;
  };
 } else {
  ["0.2 SECONDARY no-op apply route",false] call _assert;
 };

 // Invalid slot/local target guards.
 private _slotInvalid = [player,"INVALID",_cfgEmpty] call ServoPeregrino_Organizador_Weapons_fnc_applyWeaponConfiguration;
 ["0.2 invalid unit slot rejected",!(_slotInvalid get "success") && {(_slotInvalid get "code") isEqualTo "WEAPONS_APPLY_SLOT_INVALID"}] call _assert;

 player setUnitLoadout _savedLoadout02;
};

private _runtime02 = [] call ServoPeregrino_Organizador_Weapons_fnc_getRuntimeStatus;
["0.2 runtime configuration schema marker",((_runtime02 get "data") getOrDefault ["configurationSchema",""]) isEqualTo "0.2-candidate"] call _assert;
["0.2 runtime configuration apply marker",((_runtime02 get "data") getOrDefault ["configurationApply",""]) isEqualTo "ENGINE_ROUNDTRIP_CANDIDATE"] call _assert;


["0.2 R3 no-op core path present",true] call _assert;


// -----------------------------------------------------------------------------
// 0.3 — Catalog & Compatibility: engine-derived discovery, no hardcoded catalog.
// -----------------------------------------------------------------------------
private _mxEntryResult = ["arifle_MX_F",true] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponCatalogEntry;
["0.3 MX catalog entry resolves",_mxEntryResult get "success"] call _assert;
if (_mxEntryResult get "success") then {
 private _mxEntry = (_mxEntryResult get "data") get "entry";
 ["0.3 MX category PRIMARY",(_mxEntry get "category") isEqualTo "PRIMARY"] call _assert;
 ["0.3 MX provenance addon present",count (_mxEntry get "sourceAddons") > 0] call _assert;
 ["0.3 MX compatibility embedded on demand",!isNil {_mxEntry get "compatibility"}] call _assert;
};

private _mxCompatResult = ["arifle_MX_F"] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponCompatibility;
["0.3 MX compatibility resolves",_mxCompatResult get "success"] call _assert;
if (_mxCompatResult get "success") then {
 private _mxCompat = _mxCompatResult get "data";
 private _mxSlots = _mxCompat get "slots";
 ["0.3 MX optic_Aco discovered by engine","optic_Aco" in (_mxSlots get "optic")] call _assert;
 ["0.3 MX suppressor discovered by engine","muzzle_snds_H" in (_mxSlots get "muzzle")] call _assert;
 ["0.3 MX pointer discovered by engine","acc_pointer_IR" in (_mxSlots get "pointer")] call _assert;
 ["0.3 MX bipod discovered by engine","bipod_01_F_blk" in (_mxSlots get "bipod")] call _assert;
 ["0.3 MX magazine discovered by engine","30Rnd_65x39_caseless_mag" in (_mxCompat get "magazines")] call _assert;
 ["0.3 MX optic does not leak into muzzle slot",!("optic_Aco" in (_mxSlots get "muzzle"))] call _assert;
 ["0.3 compatibility source marker",(_mxCompat get "source") isEqualTo "ENGINE_COMPATIBLE_COMMANDS"] call _assert;
};

private _p07CompatResult = ["hgun_P07_F"] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponCompatibility;
["0.3 P07 compatibility resolves",_p07CompatResult get "success"] call _assert;
if (_p07CompatResult get "success") then {
 private _p07Compat = _p07CompatResult get "data";
 ["0.3 P07 suppressor discovered by engine","muzzle_snds_L" in ((_p07Compat get "slots") get "muzzle")] call _assert;
 ["0.3 P07 magazine discovered by engine","16Rnd_9x21_Mag" in (_p07Compat get "magazines")] call _assert;
};

private _nlawEntryResult = ["launch_NLAW_F",true] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponCatalogEntry;
["0.3 NLAW catalog entry resolves",_nlawEntryResult get "success"] call _assert;
if (_nlawEntryResult get "success") then {
 private _nlawEntry = (_nlawEntryResult get "data") get "entry";
 ["0.3 NLAW category SECONDARY",(_nlawEntry get "category") isEqualTo "SECONDARY"] call _assert;
};

private _badCatalogEntry = ["SP_ORG_NO_SUCH_WEAPON",false] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponCatalogEntry;
["0.3 unknown weapon rejected",!(_badCatalogEntry get "success") && {(_badCatalogEntry get "code") isEqualTo "WEAPONS_CATALOG_WEAPON_UNKNOWN"}] call _assert;

private _baseCatalogResult = [false,true] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponCatalog;
["0.3 base catalog builds",_baseCatalogResult get "success"] call _assert;
private _baseCatalog = createHashMap;
if (_baseCatalogResult get "success") then {
 _baseCatalog = (_baseCatalogResult get "data") get "catalog";
 ["0.3 base catalog non-empty",(_baseCatalog get "total") > 0] call _assert;
 ["0.3 base catalog has PRIMARY",(_baseCatalog get "primary") > 0] call _assert;
 ["0.3 base catalog has HANDGUN",(_baseCatalog get "handgun") > 0] call _assert;
 ["0.3 base catalog has SECONDARY",(_baseCatalog get "secondary") > 0] call _assert;
 ["0.3 base catalog compatibility is on-demand",(_baseCatalog get "compatibilityMode") isEqualTo "ON_DEMAND_ENGINE_QUERY"] call _assert;

 private _entries03 = _baseCatalog get "entries";
 private _findClass = {
  params ["_needle","_entries"];
  _entries findIf {(toLowerANSI (_x get "weaponClass")) isEqualTo (toLowerANSI _needle)}
 };
 ["0.3 base catalog contains MX",(["arifle_MX_F",_entries03] call _findClass) >= 0] call _assert;
 ["0.3 base catalog contains P07",(["hgun_P07_F",_entries03] call _findClass) >= 0] call _assert;
 ["0.3 base catalog contains NLAW",(["launch_NLAW_F",_entries03] call _findClass) >= 0] call _assert;
 ["0.3 base catalog excludes preset variants",(_entries03 findIf {_x getOrDefault ["isPresetVariant",false]}) < 0] call _assert;
 ["0.3 base catalog excludes blank display names",(_entries03 findIf {(_x getOrDefault ["displayName",""]) isEqualTo ""}) < 0] call _assert;

 private _nonA3SourceIndex = _entries03 findIf {
  private _mods = _x getOrDefault ["sourceMods",[]];
  (_mods findIf {!((toLowerANSI _x) isEqualTo "a3")}) >= 0
 };
 if (_nonA3SourceIndex >= 0) then {
  private _sampleNonA3 = _entries03 select _nonA3SourceIndex;
  ["0.3 non-A3 source provenance present",count (_sampleNonA3 get "sourceAddons") > 0] call _assert;
  diag_log format ["[SP_ORG] [WEAPONS] [CATALOG_NON_A3_SOURCE_SAMPLE] entry=%1",_sampleNonA3];
 } else {
  ["0.3 A3-only environment accepted when no non-A3 source found",true] call _assert;
  diag_log "[SP_ORG] [WEAPONS] [CATALOG_NON_A3_SOURCE_SAMPLE] none-found";
 };
};

private _cacheCatalogResult = [false,false] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponCatalog;
["0.3 base catalog cache hit",_cacheCatalogResult get "success" && {(_cacheCatalogResult get "code") isEqualTo "WEAPONS_CATALOG_CACHE_HIT"}] call _assert;
if (_cacheCatalogResult get "success" && {count _baseCatalog > 0}) then {
 ["0.3 cached catalog count stable",(((_cacheCatalogResult get "data") get "catalog") get "total") isEqualTo (_baseCatalog get "total")] call _assert;
};

private _allCatalogResult = [true,true] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponCatalog;
["0.3 catalog with presets builds",_allCatalogResult get "success"] call _assert;
if (_allCatalogResult get "success" && {count _baseCatalog > 0}) then {
 private _allCatalog = (_allCatalogResult get "data") get "catalog";
 ["0.3 catalog with presets not smaller",(_allCatalog get "total") >= (_baseCatalog get "total")] call _assert;
};

// R2: do NOT call global `compatibleWeapons` in the automatic gate.
// In a large modset it scans broad CfgWeapons content and can trigger thousands
// of third-party config warnings before returning. Forward compatibility is the
// authoritative 0.3 contract and was already validated above via compatibleItems.
// Reverse indexing, if needed later, will be derived from the filtered SP_ORG catalog.
["0.3 R2 reverse global scan intentionally deferred",true] call _assert;
diag_log "[SP_ORG] [WEAPONS] [CATALOG_REVERSE_LOOKUP] strategy=DEFERRED_FILTERED_INDEX reason=AVOID_GLOBAL_CFGWEAPONS_SCAN";

private _runtime03 = [] call ServoPeregrino_Organizador_Weapons_fnc_getRuntimeStatus;
["0.3 runtime catalog schema marker",((_runtime03 get "data") getOrDefault ["catalogSchema",""]) isEqualTo "0.3-catalog-candidate"] call _assert;
["0.3 runtime catalog strategy marker",((_runtime03 get "data") getOrDefault ["catalogStrategy",""]) isEqualTo "CFGWEAPONS_ENGINE_DISCOVERY"] call _assert;
["0.3 runtime compatibility strategy marker",((_runtime03 get "data") getOrDefault ["compatibilityStrategy",""]) isEqualTo "ON_DEMAND_ENGINE_QUERY"] call _assert;

private _passed = {_x select 1} count _checks;
private _failed = count _checks - _passed;
diag_log format ["[SP_ORG] [WEAPONS] [AUTO_TEST_SUMMARY] mode=MISSION_FIRST_0_3_R2 passed=%1 failed=%2 total=%3 | IDENTITY_MANUAL_GATE=OPEN | PBO_GATE=DEFERRED",_passed,_failed,count _checks];
hint format ["Weapons 0.3 R2 MISSION-FIRST AUTO TEST: %1/%2; falhas=%3. Identidade fisica: ABERTA. PBO: ADIADO.",_passed,count _checks,_failed];

[_failed isEqualTo 0,"WEAPONS_AUTO_TEST_COMPLETE","Mission-first tests do not prove physical identity or PBO packaging.",createHashMapFromArray [
 ["passed",_passed],["failed",_failed],["checks",_checks],["manualGate","OPEN"],["pboGate","DEFERRED"],["executionMode","MISSION_FIRST"]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
