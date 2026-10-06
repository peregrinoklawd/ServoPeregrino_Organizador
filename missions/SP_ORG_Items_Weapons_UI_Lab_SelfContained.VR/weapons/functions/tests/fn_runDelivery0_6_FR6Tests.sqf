#include "..\..\script_version.hpp"
if (!isServer || {isRemoteExecuted} || {!(missionNamespace getVariable ["SP_ORG_Weapons_LabEnabled",false])}) exitWith {
 [false,"WEAPONS_TEST_SERVER_LAB_ONLY","Run locally on mission-first lab server/host."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _checks = [];
private _observations = [];
private _issued = [];
private _assert = {
 params [
  ["_name","UNNAMED_CHECK",[""]],
  ["_ok",false,[false]]
 ];
 _checks pushBack [_name,_ok];
 diag_log format ["[SP_ORG] [WEAPONS] [AUTO_TEST] mode=MISSION_FIRST %1 | %2",if (_ok) then {"PASS"} else {"FAIL"},_name];
};

// Release labels, revision text and presentation identifiers are diagnostic only.
// They must never turn an otherwise healthy future delivery red.
private _observe = {
 params [
  ["_name","UNNAMED_OBSERVATION",[""]],
  ["_value",nil]
 ];
 _observations pushBack [_name,_value];
 diag_log format ["[SP_ORG] [WEAPONS] [AUTO_TEST_INFO] mode=MISSION_FIRST %1 | value=%2",_name,_value];
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
  private _secondaryClassImmediatelyBeforeApplyR5 = secondaryWeapon player;
  private _launcherApply = [player,"SECONDARY",_launcherCfg] call ServoPeregrino_Organizador_Weapons_fnc_applyWeaponConfiguration;
  private _secondaryClassImmediatelyAfterApplyR5 = secondaryWeapon player;
  diag_log format [
   "[SP_ORG] [WEAPONS] [AUTO_TEST_DETAIL] test=SECONDARY_NOOP_R5 beforeApplyClass=%1 capturedClass=%2 afterApplyClass=%3 result=%4",
   _secondaryClassImmediatelyBeforeApplyR5,
   _launcherCfg get "weaponClass",
   _secondaryClassImmediatelyAfterApplyR5,
   _launcherApply
  ];
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

// R5: slot-aware class equivalence. PRIMARY/HANDGUN stay strict.
// SECONDARY may accept runtime/base variants only inside the same baseWeapon family.
private _eqPrimaryExact = ["arifle_MX_F","arifle_MX_F","PRIMARY"] call ServoPeregrino_Organizador_Weapons_fnc_areWeaponClassesEquivalentForSlot;
["0.4 R5 PRIMARY exact class equivalent",_eqPrimaryExact get "success" && {((_eqPrimaryExact get "data") get "equivalent")}] call _assert;

private _eqPrimaryDifferent = ["arifle_MX_F","arifle_MX_SW_F","PRIMARY"] call ServoPeregrino_Organizador_Weapons_fnc_areWeaponClassesEquivalentForSlot;
["0.4 R5 PRIMARY different class remains strict",_eqPrimaryDifferent get "success" && {!((_eqPrimaryDifferent get "data") get "equivalent")}] call _assert;

private _secondaryVariantsForEq = [];
{
 private _candidateClassR5 = configName _x;
 private _candidateBaseR5 = getText (_x >> "baseWeapon");
 if (_candidateBaseR5 isEqualTo "") then {_candidateBaseR5 = _candidateClassR5};
 if (
  getNumber (_x >> "type") isEqualTo 4
  && {(toLowerANSI _candidateBaseR5) isEqualTo "launch_nlaw_f"}
 ) then {
  _secondaryVariantsForEq pushBackUnique _candidateClassR5;
 };
} forEach ("getNumber (_x >> 'type') == 4" configClasses (configFile >> "CfgWeapons"));

private _secondaryOtherVariantR5 = "";
{
 if !((toLowerANSI _x) isEqualTo "launch_nlaw_f") exitWith {
  _secondaryOtherVariantR5 = _x;
 };
} forEach _secondaryVariantsForEq;

if !(_secondaryOtherVariantR5 isEqualTo "") then {
 private _eqSecondaryFamily = ["launch_NLAW_F",_secondaryOtherVariantR5,"SECONDARY"] call ServoPeregrino_Organizador_Weapons_fnc_areWeaponClassesEquivalentForSlot;
 ["0.4 R5 SECONDARY runtime variant family equivalent",_eqSecondaryFamily get "success" && {((_eqSecondaryFamily get "data") get "equivalent")}] call _assert;
} else {
 private _eqSecondaryExact = ["launch_NLAW_F","launch_NLAW_F","SECONDARY"] call ServoPeregrino_Organizador_Weapons_fnc_areWeaponClassesEquivalentForSlot;
 ["0.4 R5 SECONDARY runtime variant family equivalent",_eqSecondaryExact get "success" && {((_eqSecondaryExact get "data") get "equivalent")}] call _assert;
};



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



// -----------------------------------------------------------------------------
// 0.4 — WeaponRecipe: desired build model, no kit identity/slot/UI/application.
// -----------------------------------------------------------------------------
private _recipeBaseCfgResult = ["arifle_MX_F"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponConfiguration;
["0.4 recipe base configuration creates",_recipeBaseCfgResult get "success"] call _assert;

private _recipeBaseCfg = createHashMap;
if (_recipeBaseCfgResult get "success") then {
 _recipeBaseCfg = (_recipeBaseCfgResult get "data") get "configuration";
};

if (count _recipeBaseCfg > 0) then {
 private _recipeEmptyMagResult = [_recipeBaseCfg,""] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponRecipe;
 ["0.4 recipe with optional empty magazine creates",_recipeEmptyMagResult get "success"] call _assert;

 private _recipeMagResult = [_recipeBaseCfg,"30Rnd_65x39_caseless_mag"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponRecipe;
 ["0.4 MX recipe with compatible magazine creates",_recipeMagResult get "success"] call _assert;

 if (_recipeMagResult get "success") then {
  private _recipe = (_recipeMagResult get "data") get "recipe";
  ["0.4 recipe schema marker",(_recipe get "schemaVersion") isEqualTo "0.4-recipe-candidate"] call _assert;
  ["0.4 recipe stores nested WeaponConfiguration",(_recipe get "configuration") isEqualType createHashMap] call _assert;
  ["0.4 recipe preserves weapon class",((_recipe get "configuration") get "weaponClass") isEqualTo "arifle_MX_F"] call _assert;
  ["0.4 recipe preserves magazine spelling",(_recipe get "magazineClass") isEqualTo "30Rnd_65x39_caseless_mag"] call _assert;
  ["0.4 structural validation",([_recipe] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponRecipeStructural) get "success"] call _assert;
  ["0.4 semantic validation",([_recipe] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponRecipeSemantic) get "success"] call _assert;

  private _recipeFp1 = (([_recipe] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponRecipeFingerprint) get "data") get "fingerprint";
  private _recipeCopy = [_recipe] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
  private _recipeFp2 = (([_recipeCopy] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponRecipeFingerprint) get "data") get "fingerprint";
  ["0.4 deterministic recipe fingerprint",_recipeFp1 isEqualTo _recipeFp2] call _assert;
  ["0.4 equal recipe comparison",(([_recipe,_recipeCopy] call ServoPeregrino_Organizador_Weapons_fnc_compareWeaponRecipes) get "data") get "equal"] call _assert;

  private _caseRecipe = [_recipe] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
  (_caseRecipe get "configuration") set ["weaponClass","ARIFLE_mx_F"];
  _caseRecipe set ["magazineClass","30RND_65X39_CASELESS_MAG"];
  private _caseFp = (([_caseRecipe] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponRecipeFingerprint) get "data") get "fingerprint";
  ["0.4 recipe fingerprint case-insensitive",_recipeFp1 isEqualTo _caseFp] call _assert;
  ["0.4 case comparison preserves stored spelling",(_caseRecipe get "magazineClass") isEqualTo "30RND_65X39_CASELESS_MAG"] call _assert;

  private _differentMagRecipe = [_recipe] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
  _differentMagRecipe set ["magazineClass","30Rnd_65x39_caseless_mag_Tracer"];
  private _differentCompare = [_recipe,_differentMagRecipe] call ServoPeregrino_Organizador_Weapons_fnc_compareWeaponRecipes;
  ["0.4 different magazine changes recipe equality",_differentCompare get "success" && {!((_differentCompare get "data") get "equal")}] call _assert;

  private _differentOpticRecipe = [_recipe] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
  (_differentOpticRecipe get "configuration") set ["optic","optic_Aco"];
  private _differentOpticCompare = [_recipe,_differentOpticRecipe] call ServoPeregrino_Organizador_Weapons_fnc_compareWeaponRecipes;
  ["0.4 different configuration changes recipe equality",_differentOpticCompare get "success" && {!((_differentOpticCompare get "data") get "equal")}] call _assert;

  {
   _x params ["_field","_value","_name"];
   private _badRecipe = [_recipe] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
   _badRecipe set [_field,_value];
   [_name,!(([_badRecipe] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponRecipeStructural) get "success")] call _assert;
  } forEach [
   ["targetSlot","PRIMARY","0.4 targetSlot rejected from Recipe; belongs to WeaponKit"],
   ["name","My Rifle","0.4 kit name rejected from Recipe"],
   ["ammoCount",30,"0.4 ammo count rejected from Recipe"],
   ["instanceId","WID-NOT-A-RECIPE","0.4 physical/logical identity rejected from Recipe"]
  ];

  private _badMagazineCreate = [_recipeBaseCfg,"SP_ORG_NO_SUCH_MAGAZINE"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponRecipe;
  ["0.4 incompatible magazine rejected",!(_badMagazineCreate get "success") && {(_badMagazineCreate get "code") isEqualTo "WEAPONS_RECIPE_MAGAZINE_INCOMPATIBLE"}] call _assert;

  private _badCfgRecipe = [_recipe] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
  (_badCfgRecipe get "configuration") set ["optic","SP_ORG_NO_SUCH_OPTIC"];
  private _badCfgSemantic = [_badCfgRecipe] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponRecipeSemantic;
  ["0.4 incompatible nested configuration rejected",!(_badCfgSemantic get "success") && {(_badCfgSemantic get "code") isEqualTo "WEAPONS_RECIPE_CONFIGURATION_INCOMPATIBLE"}] call _assert;

  // Constructor must own a deep copy; caller mutation cannot rewrite an existing recipe.
  private _constructorCfg = [_recipeBaseCfg] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
  private _deepRecipeResult = [_constructorCfg,"30Rnd_65x39_caseless_mag"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponRecipe;
  _constructorCfg set ["optic","optic_Aco"];
  ["0.4 create recipe deep-copies configuration",_deepRecipeResult get "success" && {((((_deepRecipeResult get "data") get "recipe") get "configuration") get "optic") isEqualTo ""}] call _assert;
 };
};

// Fully configured MX recipe remains semantic-valid.
private _recipeFullCfgResult = ["arifle_MX_F"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponConfiguration;
if (_recipeFullCfgResult get "success") then {
 private _recipeFullCfg = (_recipeFullCfgResult get "data") get "configuration";
 _recipeFullCfg set ["muzzle","muzzle_snds_H"];
 _recipeFullCfg set ["pointer","acc_pointer_IR"];
 _recipeFullCfg set ["optic","optic_Aco"];
 _recipeFullCfg set ["bipod","bipod_01_F_blk"];
 private _fullRecipe = [_recipeFullCfg,"30Rnd_65x39_caseless_mag"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponRecipe;
 ["0.4 full MX recipe creates",_fullRecipe get "success"] call _assert;
};

// Other weapon categories use the same recipe model.
private _p07RecipeCfgResult = ["hgun_P07_F"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponConfiguration;
if (_p07RecipeCfgResult get "success") then {
 private _p07Recipe = [(_p07RecipeCfgResult get "data") get "configuration","16Rnd_9x21_Mag"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponRecipe;
 ["0.4 HANDGUN recipe creates",_p07Recipe get "success"] call _assert;
};

// R3 regression: resolve hidden/runtime SECONDARY variants through baseWeapon.
// This is generic and contains no addon/launcher-specific rules in the resolver.
private _nlawCompatR3 = ["launch_NLAW_F"] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponCompatibility;
["0.4 R3 SECONDARY compatibility resolves",_nlawCompatR3 get "success"] call _assert;
if (_nlawCompatR3 get "success") then {
 private _nlawCompatDataR3 = _nlawCompatR3 get "data";
 private _nlawMagsR3 = _nlawCompatDataR3 get "magazines";
 private _variantClassesR3 = _nlawCompatDataR3 getOrDefault ["secondaryVariantClasses",[]];

 ["0.4 R3 SECONDARY runtime variants discovered",(count _variantClassesR3) >= 1] call _assert;
 ["0.4 R3 SECONDARY missile magazine discovered",(_nlawMagsR3 findIf {(toLowerANSI _x) isEqualTo "nlaw_f"}) >= 0] call _assert;
 ["0.4 R3 SECONDARY returned magazines are public",(_nlawMagsR3 findIf {
  private _magCfg = configFile >> "CfgMagazines" >> _x;
  !isClass _magCfg || {getNumber (_magCfg >> "scope") < 2}
 }) < 0] call _assert;

 // R4 hygiene: compatibility results must be unique case-insensitively.
 private _nlawLowerR4 = _nlawMagsR3 apply {toLowerANSI _x};
 private _nlawUniqueLowerR4 = _nlawLowerR4 arrayIntersect _nlawLowerR4;
 ["0.4 R4 SECONDARY magazines case-insensitive unique",(count _nlawLowerR4) isEqualTo (count _nlawUniqueLowerR4)] call _assert;
 ["0.4 R4 NLAW magazine appears once",({_x isEqualTo "nlaw_f"} count _nlawLowerR4) isEqualTo 1] call _assert;

 private _allSlotItemsUniqueR4 = true;
 {
  private _slotListR4 = ((_nlawCompatDataR3 get "slots") get _x);
  private _slotLowerR4 = _slotListR4 apply {toLowerANSI _x};
  private _slotUniqueR4 = _slotLowerR4 arrayIntersect _slotLowerR4;
  if !((count _slotLowerR4) isEqualTo (count _slotUniqueR4)) then {
   _allSlotItemsUniqueR4 = false;
  };
 } forEach ["muzzle","pointer","optic","bipod"];
 ["0.4 R4 SECONDARY attachment lists case-insensitive unique",_allSlotItemsUniqueR4] call _assert;

 diag_log format [
  "[SP_ORG] [WEAPONS] [AUTO_TEST_DETAIL] test=SECONDARY_RECIPE_COMPAT_R5 magazines=%1 magazineSource=%2 variantClasses=%3 variantMagazineCount=%4 magazinesByMuzzle=%5",
  _nlawMagsR3,
  _nlawCompatDataR3 getOrDefault ["magazineSource",""],
  _variantClassesR3,
  _nlawCompatDataR3 getOrDefault ["secondaryVariantMagazineCount",0],
  _nlawCompatDataR3 get "magazinesByMuzzle"
 ];
};

private _nlawRecipeCfgResult = ["launch_NLAW_F"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponConfiguration;
if (_nlawRecipeCfgResult get "success") then {
 private _nlawRecipe = [(_nlawRecipeCfgResult get "data") get "configuration","NLAW_F"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponRecipe;
 diag_log format ["[SP_ORG] [WEAPONS] [AUTO_TEST_DETAIL] test=SECONDARY_RECIPE_R5 result=%1",_nlawRecipe];
 ["0.4 SECONDARY recipe creates",_nlawRecipe get "success"] call _assert;
};

// Recipe functions are descriptive only: creating/validating recipes must not mutate player loadout.
private _recipeLoadoutBefore = getUnitLoadout player;
if (count _recipeBaseCfg > 0) then {
 [_recipeBaseCfg,"30Rnd_65x39_caseless_mag"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponRecipe;
};
private _recipeLoadoutAfter = getUnitLoadout player;
["0.4 recipe operations do not mutate engine loadout",_recipeLoadoutBefore isEqualTo _recipeLoadoutAfter] call _assert;

private _runtime04 = [] call ServoPeregrino_Organizador_Weapons_fnc_getRuntimeStatus;
["0.4 runtime recipe schema marker",((_runtime04 get "data") getOrDefault ["recipeSchema",""]) isEqualTo "0.4-recipe-candidate"] call _assert;
["0.4 runtime recipe strategy marker",((_runtime04 get "data") getOrDefault ["recipeStrategy",""]) isEqualTo "DESIRED_BUILD_MODEL"] call _assert;


// -----------------------------------------------------------------------------
// 0.5 WeaponKit — player-facing saved unit model, session-local repository.
// -----------------------------------------------------------------------------
missionNamespace setVariable [SP_ORG_WEAPONS_KIT_STORE,nil];
private _kitStoreInit05 = [] call ServoPeregrino_Organizador_Weapons_fnc_initializeWeaponKitStore;
["0.5 kit store initializes",_kitStoreInit05 get "success"] call _assert;
["0.5 kit store mode session-local",((_kitStoreInit05 get "data") getOrDefault ["mode",""]) isEqualTo "SESSION_LOCAL_CANDIDATE"] call _assert;

// Build fresh recipes to avoid coupling to earlier mutable test variables.
private _kitMxCfgResult = ["arifle_MX_F"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponConfiguration;
private _kitMxRecipeResult = createHashMap;
if (_kitMxCfgResult get "success") then {
 _kitMxRecipeResult = [(_kitMxCfgResult get "data") get "configuration","30Rnd_65x39_caseless_mag"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponRecipe;
};
["0.5 PRIMARY recipe prerequisite",_kitMxRecipeResult getOrDefault ["success",false]] call _assert;

private _kitCreate = ["  Patrol MX  ","primary",(_kitMxRecipeResult get "data") get "recipe"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponKit;
["0.5 create PRIMARY kit",_kitCreate get "success"] call _assert;
private _kitA = createHashMap;
private _kitAId = "";
if (_kitCreate get "success") then {
 _kitA = (_kitCreate get "data") get "kit";
 _kitAId = _kitA get "kitId";
 ["0.5 kit schema marker",(_kitA get "schemaVersion") isEqualTo "0.5-kit-candidate"] call _assert;
 ["0.5 kit ID issued",((_kitAId select [0,4]) isEqualTo "WKT-")] call _assert;
 ["0.5 name trimmed",(_kitA get "name") isEqualTo "Patrol MX"] call _assert;
 ["0.5 target slot normalized",(_kitA get "targetSlot") isEqualTo "PRIMARY"] call _assert;
 ["0.5 nested recipe preserved",((_kitA get "recipe") get "schemaVersion") isEqualTo "0.4-recipe-candidate"] call _assert;
 ["0.5 structural validation",([_kitA] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponKitStructural) get "success"] call _assert;
 ["0.5 semantic validation",([_kitA] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponKitSemantic) get "success"] call _assert;
};

// Closed schema and invalid naming.
if (count _kitA > 0) then {
 private _extraKit = [_kitA] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 _extraKit set ["ammoCount",30];
 ["0.5 closed schema rejects ammoCount",!(([_extraKit] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponKitStructural) get "success")] call _assert;
};
["0.5 blank name rejected",!((["   ","PRIMARY",(_kitMxRecipeResult get "data") get "recipe"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponKit) get "success")] call _assert;
private _longName05 = "";
for "_i" from 1 to 65 do {_longName05 = _longName05 + "A"};
["0.5 long name rejected",!(([_longName05,"PRIMARY",(_kitMxRecipeResult get "data") get "recipe"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponKit) get "success")] call _assert;
["0.5 invalid slot rejected",!((["Invalid Slot","BACKPACK",(_kitMxRecipeResult get "data") get "recipe"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponKit) get "success")] call _assert;
["0.5 duplicate name case-insensitive rejected",!((["patrol mx","PRIMARY",(_kitMxRecipeResult get "data") get "recipe"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponKit) get "success")] call _assert;

// Slot must match recipe weapon category.
private _kitP07CfgResult = ["hgun_P07_F"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponConfiguration;
private _kitP07RecipeResult = createHashMap;
if (_kitP07CfgResult get "success") then {
 _kitP07RecipeResult = [(_kitP07CfgResult get "data") get "configuration","16Rnd_9x21_Mag"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponRecipe;
};
["0.5 HANDGUN recipe prerequisite",_kitP07RecipeResult getOrDefault ["success",false]] call _assert;
if (_kitP07RecipeResult getOrDefault ["success",false]) then {
 ["0.5 recipe-slot mismatch rejected",!((["Wrong Slot","PRIMARY",(_kitP07RecipeResult get "data") get "recipe"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponKit) get "success")] call _assert;
 private _handgunKitResult05 = ["Sidearm","HANDGUN",(_kitP07RecipeResult get "data") get "recipe"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponKit;
 ["0.5 HANDGUN kit creates",_handgunKitResult05 get "success"] call _assert;
};

// SECONDARY kit proves target slot contract over the frozen R5 recipe behavior.
private _kitNlawCfgResult = ["launch_NLAW_F"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponConfiguration;
private _kitNlawRecipeResult = createHashMap;
if (_kitNlawCfgResult get "success") then {
 _kitNlawRecipeResult = [(_kitNlawCfgResult get "data") get "configuration","NLAW_F"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponRecipe;
};
["0.5 SECONDARY recipe prerequisite",_kitNlawRecipeResult getOrDefault ["success",false]] call _assert;
if (_kitNlawRecipeResult getOrDefault ["success",false]) then {
 private _secondaryKitResult05 = ["AT Tube","SECONDARY",(_kitNlawRecipeResult get "data") get "recipe"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponKit;
 ["0.5 SECONDARY kit creates",_secondaryKitResult05 get "success"] call _assert;
};

// Defensive copies from repository.
if !(_kitAId isEqualTo "") then {
 private _getA1 = [_kitAId] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponKit;
 ["0.5 get kit succeeds",_getA1 get "success"] call _assert;
 if (_getA1 get "success") then {
  private _copyA = (_getA1 get "data") get "kit";
  _copyA set ["name","MUTATED OUTSIDE"];
  private _getA2 = [_kitAId] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponKit;
  ["0.5 repository defensive copy",_getA2 get "success" && {(((_getA2 get "data") get "kit") get "name") isEqualTo "Patrol MX"}] call _assert;
 };
};

private _list05 = [] call ServoPeregrino_Organizador_Weapons_fnc_listWeaponKits;
["0.5 list kits succeeds",_list05 get "success"] call _assert;
["0.5 list contains created kits",_list05 get "success" && {((_list05 get "data") get "count") >= 3}] call _assert;

// Fingerprint excludes name + kitId; duplicate content remains equal.
private _duplicate05 = createHashMap;
if !(_kitAId isEqualTo "") then {
 _duplicate05 = [_kitAId,"Patrol MX Copy"] call ServoPeregrino_Organizador_Weapons_fnc_duplicateWeaponKit;
 ["0.5 duplicate kit creates",_duplicate05 get "success"] call _assert;
 if (_duplicate05 get "success") then {
  private _kitB = (_duplicate05 get "data") get "kit";
  ["0.5 duplicate gets distinct kitId",!((_kitB get "kitId") isEqualTo _kitAId)] call _assert;
  private _cmpAB = [_kitA,_kitB] call ServoPeregrino_Organizador_Weapons_fnc_compareWeaponKits;
  ["0.5 duplicate same content",_cmpAB get "success" && {((_cmpAB get "data") get "sameContent")}] call _assert;
  ["0.5 duplicate distinct identity",_cmpAB get "success" && {!((_cmpAB get "data") get "sameIdentity")}] call _assert;
  ["0.5 duplicate distinct name",_cmpAB get "success" && {!((_cmpAB get "data") get "sameName")}] call _assert;
 };
 ["0.5 duplicate name collision rejected",!(([_kitAId,"Sidearm"] call ServoPeregrino_Organizador_Weapons_fnc_duplicateWeaponKit) get "success")] call _assert;
};

// Rename preserves identity/content and rejects collision.
if !(_kitAId isEqualTo "") then {
 private _beforeRename = [_kitAId] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponKit;
 private _rename05 = [_kitAId,"  Patrol MX Revised  "] call ServoPeregrino_Organizador_Weapons_fnc_renameWeaponKit;
 ["0.5 rename succeeds",_rename05 get "success"] call _assert;
 if (_rename05 get "success" && {_beforeRename get "success"}) then {
  private _renamed = (_rename05 get "data") get "kit";
  ["0.5 rename trims name",(_renamed get "name") isEqualTo "Patrol MX Revised"] call _assert;
  ["0.5 rename preserves kitId",(_renamed get "kitId") isEqualTo _kitAId] call _assert;
  private _renameCmp = [(_beforeRename get "data") get "kit",_renamed] call ServoPeregrino_Organizador_Weapons_fnc_compareWeaponKits;
  ["0.5 rename preserves content",_renameCmp get "success" && {((_renameCmp get "data") get "sameContent")}] call _assert;
 };
 ["0.5 rename collision rejected",!(([_kitAId,"Sidearm"] call ServoPeregrino_Organizador_Weapons_fnc_renameWeaponKit) get "success")] call _assert;
};

// Updating recipe preserves kit identity/name/slot; mismatched category fails.
if !(_kitAId isEqualTo "") then {
 private _mxEmptyRecipe = [(_kitMxCfgResult get "data") get "configuration",""] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponRecipe;
 private _update05 = [_kitAId,(_mxEmptyRecipe get "data") get "recipe"] call ServoPeregrino_Organizador_Weapons_fnc_updateWeaponKitRecipe;
 ["0.5 update recipe succeeds",_update05 get "success"] call _assert;
 if (_update05 get "success") then {
  private _updatedKit05 = (_update05 get "data") get "kit";
  ["0.5 update preserves kitId",(_updatedKit05 get "kitId") isEqualTo _kitAId] call _assert;
  ["0.5 update preserves name",(_updatedKit05 get "name") isEqualTo "Patrol MX Revised"] call _assert;
  ["0.5 update preserves targetSlot",(_updatedKit05 get "targetSlot") isEqualTo "PRIMARY"] call _assert;
  ["0.5 update applies new recipe",((_updatedKit05 get "recipe") get "magazineClass") isEqualTo ""] call _assert;
 };
 if (_kitP07RecipeResult getOrDefault ["success",false]) then {
  ["0.5 update mismatched recipe rejected",!(([_kitAId,(_kitP07RecipeResult get "data") get "recipe"] call ServoPeregrino_Organizador_Weapons_fnc_updateWeaponKitRecipe) get "success")] call _assert;
 };
};

// Delete semantics.
if (_duplicate05 getOrDefault ["success",false]) then {
 private _duplicateId05 = (((_duplicate05 get "data") get "kit") get "kitId");
 private _delete05 = [_duplicateId05] call ServoPeregrino_Organizador_Weapons_fnc_deleteWeaponKit;
 ["0.5 delete succeeds",_delete05 get "success"] call _assert;
 ["0.5 deleted kit no longer found",!(([_duplicateId05] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponKit) get "success")] call _assert;
 ["0.5 delete missing rejected",!(([_duplicateId05] call ServoPeregrino_Organizador_Weapons_fnc_deleteWeaponKit) get "success")] call _assert;
};

// Kit operations are data/repository only; no weapon or inventory application in 0.5.
private _kitLoadoutBefore05 = getUnitLoadout player;
if !(_kitAId isEqualTo "") then {
 [_kitAId] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponKit;
 [] call ServoPeregrino_Organizador_Weapons_fnc_listWeaponKits;
};
private _kitLoadoutAfter05 = getUnitLoadout player;
["0.5 kit operations do not mutate engine loadout",_kitLoadoutBefore05 isEqualTo _kitLoadoutAfter05] call _assert;

private _runtime05 = [] call ServoPeregrino_Organizador_Weapons_fnc_getRuntimeStatus;
["0.5 runtime kit schema marker",((_runtime05 get "data") getOrDefault ["kitSchema",""]) isEqualTo "0.5-kit-candidate"] call _assert;
["0.5 runtime repository mode marker",((_runtime05 get "data") getOrDefault ["kitRepositoryMode",""]) isEqualTo "SESSION_LOCAL_CANDIDATE"] call _assert;
["0.6-D runtime UI draft marker",((_runtime05 get "data") getOrDefault ["kitUI",""]) isEqualTo "PLAYER_UI_0_6_E_R2_UX_CONVERGENCE_DIRECT_DRAFT_EQUIP_UICOMMON"] call _assert;
["0.5 runtime application deferred marker",((_runtime05 get "data") getOrDefault ["kitApplication",""]) isEqualTo "DEFERRED_0_7"] call _assert;


// -----------------------------------------------------------------------------
// 0.6-D R3 preflight — fail clearly before UI calls if CfgFunctions did not
// resolve the new mission-local UI functions.
// -----------------------------------------------------------------------------
private _uiFunctionNames06A = [
 "ServoPeregrino_Organizador_Weapons_fnc_createUIState",
 "ServoPeregrino_Organizador_Weapons_fnc_getUIState",
 "ServoPeregrino_Organizador_Weapons_fnc_getUISlotLabel",
 "ServoPeregrino_Organizador_Weapons_fnc_getWeaponPresentationInfo",
 "ServoPeregrino_Organizador_Weapons_fnc_getClassPresentationInfo",
 "ServoPeregrino_Organizador_Weapons_fnc_getEquipmentSlotSnapshot",
 "ServoPeregrino_Organizador_Weapons_fnc_buildCompatibilitySelectorModel",
 "ServoPeregrino_Organizador_Weapons_fnc_getOrCreateWeaponKitDraft",
 "ServoPeregrino_Organizador_Weapons_fnc_setWeaponKitDraftSelection",
 "ServoPeregrino_Organizador_Weapons_fnc_discardWeaponKitDraft",
 "ServoPeregrino_Organizador_Weapons_fnc_getUniqueWeaponKitName",
 "ServoPeregrino_Organizador_Weapons_fnc_createWeaponKitFromCatalogWeapon",
 "ServoPeregrino_Organizador_Weapons_fnc_setWeaponKitDraftWeapon",
 "ServoPeregrino_Organizador_Weapons_fnc_saveWeaponKitDraft",
 "ServoPeregrino_Organizador_Weapons_fnc_applyCatalogSelectionToDraft",
 "ServoPeregrino_Organizador_Weapons_fnc_clearWeaponKitDraft",
 "ServoPeregrino_Organizador_Weapons_fnc_escapeStructuredText",
 "ServoPeregrino_Organizador_Weapons_fnc_pushUIFeedback",
 "ServoPeregrino_Organizador_Weapons_fnc_getUICatalogWindow",
 "ServoPeregrino_Organizador_Weapons_fnc_buildUIViewModel",
 "ServoPeregrino_Organizador_Weapons_fnc_refreshCatalogWindowUI",
 "ServoPeregrino_Organizador_Weapons_fnc_refreshDraftUI",
 "ServoPeregrino_Organizador_Weapons_fnc_refreshEquipmentViewUI",
 "ServoPeregrino_Organizador_Weapons_fnc_refreshInterface",
 "ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent",
 "ServoPeregrino_Organizador_Weapons_fnc_handleUIWheel",
 "ServoPeregrino_Organizador_Weapons_fnc_onInterfaceLoad",
 "ServoPeregrino_Organizador_Weapons_fnc_onInterfaceUnload",
 "ServoPeregrino_Organizador_Weapons_fnc_openInterface"
];
private _missingUIFunctions06A = _uiFunctionNames06A select {isNil _x};
["0.6-E R2 all UI/authoring functions loaded",(count _missingUIFunctions06A) isEqualTo 0] call _assert;
diag_log format ["[SP_ORG] [WEAPONS] [AUTO_TEST_DETAIL] test=UI_FUNCTION_PREFLIGHT_0_6_E_R2 missing=%1",_missingUIFunctions06A];

if ((count _missingUIFunctions06A) isEqualTo 0) then {

// -----------------------------------------------------------------------------
// 0.6-B R4 — read-only weapon presentation contract.
// No compatibility discovery, draft creation, WeaponKit mutation or loadout mutation.
// -----------------------------------------------------------------------------
private _presentationLoadoutBefore06B = getUnitLoadout player;

private _mxInfoR06B = ["arifle_MX_F"] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponPresentationInfo;
["0.6-B MX presentation resolves",_mxInfoR06B get "success"] call _assert;
if (_mxInfoR06B get "success") then {
 private _mxInfo06B = (_mxInfoR06B get "data") get "info";
 ["0.6-B presentation schema marker",(_mxInfo06B getOrDefault ["schemaVersion",""]) isEqualTo "0.6-B-presentation-candidate"] call _assert;
 ["0.6-B MX canonical class",(_mxInfo06B getOrDefault ["weaponClass",""]) isEqualTo "arifle_MX_F"] call _assert;
 ["0.6-B MX display name available",(_mxInfo06B getOrDefault ["displayName",""]) isNotEqualTo ""] call _assert;
 ["0.6-B MX category PRIMARY",(_mxInfo06B getOrDefault ["category",""]) isEqualTo "PRIMARY"] call _assert;
 ["0.6-B MX UI label Principal",(_mxInfo06B getOrDefault ["categoryLabel",""]) isEqualTo "Principal"] call _assert;
 ["0.6-B MX origin label available",(_mxInfo06B getOrDefault ["originLabel",""]) isNotEqualTo ""] call _assert;
 ["0.6-B presentation excludes compatibility",isNil {_mxInfo06B get "compatibility"}] call _assert;
};

private _p07InfoR06B = ["hgun_P07_F"] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponPresentationInfo;
["0.6-B P07 presentation resolves",_p07InfoR06B get "success"] call _assert;
if (_p07InfoR06B get "success") then {
 private _p07Info06B = (_p07InfoR06B get "data") get "info";
 ["0.6-B P07 UI label Porte",(_p07Info06B getOrDefault ["categoryLabel",""]) isEqualTo "Porte"] call _assert;
};

private _nlawInfoR06B = ["launch_NLAW_F"] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponPresentationInfo;
["0.6-B NLAW presentation resolves",_nlawInfoR06B get "success"] call _assert;
if (_nlawInfoR06B get "success") then {
 private _nlawInfo06B = (_nlawInfoR06B get "data") get "info";
 ["0.6-B NLAW UI label Secundária",(_nlawInfo06B getOrDefault ["categoryLabel",""]) isEqualTo "Secundária"] call _assert;
};

["0.6-B empty presentation rejected",!(([""] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponPresentationInfo) get "success")] call _assert;
["0.6-B unknown presentation rejected",!((["SP_ORG_NO_SUCH_WEAPON"] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponPresentationInfo) get "success")] call _assert;
["0.6-B presentation does not mutate loadout",_presentationLoadoutBefore06B isEqualTo (getUnitLoadout player)] call _assert;

// -----------------------------------------------------------------------------
// 0.6-D baseline — Compatibility Selectors model reused by the local draft.
// Uses the already-approved 0.3 engine compatibility layer. The model is now
// draft-editable, while repository and physical loadout mutation remain forbidden.
// -----------------------------------------------------------------------------
private _compatRepoBefore06C = [] call ServoPeregrino_Organizador_Weapons_fnc_listWeaponKits;
private _compatLoadoutBefore06C = getUnitLoadout player;

private _selectorCfgResult06C = ["arifle_MX_F"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponConfiguration;
["0.6-D selector configuration prerequisite",_selectorCfgResult06C get "success"] call _assert;
private _selectorRecipeResult06C = createHashMap;
if (_selectorCfgResult06C get "success") then {
 private _selectorCfg06C = (_selectorCfgResult06C get "data") get "configuration";
 _selectorCfg06C set ["muzzle","muzzle_snds_H"];
 _selectorCfg06C set ["pointer","acc_pointer_IR"];
 _selectorCfg06C set ["optic","optic_Aco"];
 _selectorCfg06C set ["bipod","bipod_01_F_blk"];
 _selectorRecipeResult06C = [_selectorCfg06C,"30Rnd_65x39_caseless_mag"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponRecipe;
};
["0.6-D configured Recipe prerequisite",_selectorRecipeResult06C getOrDefault ["success",false]] call _assert;

private _selectorModelResult06C = createHashMap;
if (_selectorRecipeResult06C getOrDefault ["success",false]) then {
 _selectorModelResult06C = ["arifle_MX_F",(_selectorRecipeResult06C get "data") get "recipe"] call ServoPeregrino_Organizador_Weapons_fnc_buildCompatibilitySelectorModel;
};
["0.6-D selector model builds",_selectorModelResult06C getOrDefault ["success",false]] call _assert;

if (_selectorModelResult06C getOrDefault ["success",false]) then {
 private _selectorModel06C = (_selectorModelResult06C get "data") get "model";
 private _selectors06C = _selectorModel06C getOrDefault ["selectors",createHashMap];
 ["0.6-D selector schema marker",(_selectorModel06C getOrDefault ["schemaVersion",""]) isEqualTo "0.6-D-compatibility-selector-candidate"] call _assert;
 ["0.6-D selector model editable through draft",!(_selectorModel06C getOrDefault ["readOnly",true])] call _assert;
 ["0.6-D selector model declares draft mutation",_selectorModel06C getOrDefault ["draftMutation",false]] call _assert;
 ["0.6-D selector model still forbids WeaponKit mutation",!(_selectorModel06C getOrDefault ["weaponKitMutation",true])] call _assert;
 ["0.6-D selector model still forbids loadout mutation",!(_selectorModel06C getOrDefault ["loadoutMutation",true])] call _assert;
 ["0.6-D selector set complete",({!isNil {_selectors06C get _x}} count ["optic","muzzle","pointer","bipod","magazineClass"]) isEqualTo 5] call _assert;

 {
  private _selector = _selectors06C getOrDefault [_x,createHashMap];
  [format ["0.6-D %1 current draft value remains compatible",_x],_selector getOrDefault ["currentCompatible",false]] call _assert;
  [format ["0.6-D %1 options include explicit none",_x],
   (count (_selector getOrDefault ["options",[]])) > 0
   && {(((_selector get "options") select 0) getOrDefault ["className","__missing__"]) isEqualTo ""}
  ] call _assert;
  [format ["0.6-D %1 current draft value selected",_x],(_selector getOrDefault ["selectedIndex",-1]) >= 0] call _assert;
 } forEach ["optic","muzzle","pointer","bipod","magazineClass"];

 private _engineCompatibility06C = ["arifle_MX_F"] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponCompatibility;
 ["0.6-D engine compatibility prerequisite",_engineCompatibility06C get "success"] call _assert;
 if (_engineCompatibility06C get "success") then {
  private _engineData06C = _engineCompatibility06C get "data";
  {
   private _selector = _selectors06C get _x;
   private _selectorClasses = (_selector get "options") apply {_x getOrDefault ["className",""]};
   if ((count _selectorClasses) > 0) then {_selectorClasses deleteAt 0};
   private _engineClasses = ((_engineData06C get "slots") get _x);
   [format ["0.6-D %1 options exactly mirror 0.3 compatibility",_x],(_selectorClasses apply {toLowerANSI _x}) isEqualTo (_engineClasses apply {toLowerANSI _x})] call _assert;
  } forEach ["optic","muzzle","pointer","bipod"];

  private _magSelectorClasses = ((_selectors06C get "magazineClass") get "options") apply {_x getOrDefault ["className",""]};
  if ((count _magSelectorClasses) > 0) then {_magSelectorClasses deleteAt 0};
  ["0.6-D magazine options exactly mirror 0.3 compatibility",(_magSelectorClasses apply {toLowerANSI _x}) isEqualTo ((_engineData06C get "magazines") apply {toLowerANSI _x})] call _assert;
 };

 private _cachedSelector06C = ["ARIFLE_mx_F",(_selectorRecipeResult06C get "data") get "recipe"] call ServoPeregrino_Organizador_Weapons_fnc_buildCompatibilitySelectorModel;
 ["0.6-D compatibility UI cache is case-insensitive",
  _cachedSelector06C get "success"
  && {(((_cachedSelector06C get "data") get "model") getOrDefault ["cacheHit",false])}
 ] call _assert;
};

if (_selectorRecipeResult06C getOrDefault ["success",false]) then {
 private _mismatchSelector06C = ["hgun_P07_F",(_selectorRecipeResult06C get "data") get "recipe"] call ServoPeregrino_Organizador_Weapons_fnc_buildCompatibilitySelectorModel;
 ["0.6-D mismatched Recipe/weapon rejected",!(_mismatchSelector06C get "success") && {(_mismatchSelector06C get "code") isEqualTo "WEAPONS_UI_COMPATIBILITY_RECIPE_WEAPON_MISMATCH"}] call _assert;
};

private _compatRepoAfter06C = [] call ServoPeregrino_Organizador_Weapons_fnc_listWeaponKits;
["0.6-D selector model does not mutate WeaponKit repository",
 _compatRepoBefore06C get "success"
 && {_compatRepoAfter06C get "success"}
 && {(((_compatRepoBefore06C get "data") get "kits") isEqualTo (((_compatRepoAfter06C get "data") get "kits")))}
] call _assert;
["0.6-D selector model does not mutate loadout",_compatLoadoutBefore06C isEqualTo (getUnitLoadout player)] call _assert;


// -----------------------------------------------------------------------------
// 0.6-D R1 baseline — WeaponKit Draft model preserved by R2.
// Draft is session-local UI state. It may edit only compatible Recipe fields;
// repository and physical loadout remain immutable until later gates.
// -----------------------------------------------------------------------------
if (_kitAId isNotEqualTo "") then {
 private _draftRepoBefore06D = [] call ServoPeregrino_Organizador_Weapons_fnc_listWeaponKits;
 private _draftLoadoutBefore06D = getUnitLoadout player;
 private _savedKitBefore06D = [_kitAId] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponKit;

 private _draftCreate06D = [_kitAId] call ServoPeregrino_Organizador_Weapons_fnc_getOrCreateWeaponKitDraft;
 ["0.6-D local draft creates from saved WeaponKit",_draftCreate06D getOrDefault ["success",false]] call _assert;
 if (_draftCreate06D getOrDefault ["success",false]) then {
  private _draft06D = (_draftCreate06D get "data") get "draft";
  ["0.6-D draft schema marker",(_draft06D getOrDefault ["schemaVersion",""]) isEqualTo "0.6-D-weaponkit-draft-candidate"] call _assert;
  ["0.6-D fresh draft is clean",!(_draft06D getOrDefault ["dirty",true])] call _assert;
  ["0.6-D draft preserves source kit id",(_draft06D getOrDefault ["sourceKitId",""]) isEqualTo _kitAId] call _assert;
  ["0.6-D draft preserves target slot",(_draft06D getOrDefault ["targetSlot",""]) isEqualTo "PRIMARY"] call _assert;
  if (_savedKitBefore06D getOrDefault ["success",false]) then {
   private _savedRecipe06D = (((_savedKitBefore06D get "data") get "kit") get "recipe");
   private _draftRecipeCompare06D = [_savedRecipe06D,_draft06D getOrDefault ["recipe",createHashMap]] call ServoPeregrino_Organizador_Weapons_fnc_compareWeaponRecipes;
   ["0.6-D fresh draft Recipe equals saved Recipe",_draftRecipeCompare06D get "success" && {((_draftRecipeCompare06D get "data") getOrDefault ["equal",false])}] call _assert;
  };
 };

 private _badField06D = [_kitAId,"weaponClass","arifle_MX_SW_F"] call ServoPeregrino_Organizador_Weapons_fnc_setWeaponKitDraftSelection;
 ["0.6-D base weapon is not editable in Draft gate",!(_badField06D getOrDefault ["success",false]) && {(_badField06D getOrDefault ["code",""]) isEqualTo "WEAPONS_UI_DRAFT_FIELD_INVALID"}] call _assert;

 private _badClass06D = [_kitAId,"optic","SP_ORG_NO_SUCH_OPTIC"] call ServoPeregrino_Organizador_Weapons_fnc_setWeaponKitDraftSelection;
 ["0.6-D incompatible selector value rejected",!(_badClass06D getOrDefault ["success",false]) && {(_badClass06D getOrDefault ["code",""]) isEqualTo "WEAPONS_UI_DRAFT_SELECTION_INCOMPATIBLE"}] call _assert;

 private _draftCompat06D = ["arifle_MX_F"] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponCompatibility;
 private _draftOptic06D = "";
 if (_draftCompat06D getOrDefault ["success",false]) then {
  private _opticClasses06D = (((_draftCompat06D get "data") get "slots") getOrDefault ["optic",[]]);
  if ((count _opticClasses06D) > 0) then {_draftOptic06D = _opticClasses06D select 0};
 };
 ["0.6-D MX provides an optic for draft edit",_draftOptic06D isNotEqualTo ""] call _assert;

 if (_draftOptic06D isNotEqualTo "") then {
  private _setDraftOptic06D = [_kitAId,"optic",_draftOptic06D] call ServoPeregrino_Organizador_Weapons_fnc_setWeaponKitDraftSelection;
  ["0.6-D compatible optic updates local draft",_setDraftOptic06D getOrDefault ["success",false]] call _assert;
  if (_setDraftOptic06D getOrDefault ["success",false]) then {
   private _editedDraft06D = (_setDraftOptic06D get "data") get "draft";
   private _editedRecipe06D = _editedDraft06D getOrDefault ["recipe",createHashMap];
   private _editedCfg06D = _editedRecipe06D getOrDefault ["configuration",createHashMap];
   ["0.6-D edited draft becomes dirty",_editedDraft06D getOrDefault ["dirty",false]] call _assert;
   ["0.6-D edited draft stores selected optic",(toLowerANSI (_editedCfg06D getOrDefault ["optic",""])) isEqualTo (toLowerANSI _draftOptic06D)] call _assert;
   ["0.6-D draft revision advances",(_editedDraft06D getOrDefault ["revision",0]) > 0] call _assert;
  };

  private _setDraftBack06D = [_kitAId,"optic",""] call ServoPeregrino_Organizador_Weapons_fnc_setWeaponKitDraftSelection;
  ["0.6-D returning to saved optic succeeds",_setDraftBack06D getOrDefault ["success",false]] call _assert;
  if (_setDraftBack06D getOrDefault ["success",false]) then {
   private _restoredDraft06D = (_setDraftBack06D get "data") get "draft";
   ["0.6-D returning Recipe to saved content clears dirty",!(_restoredDraft06D getOrDefault ["dirty",true])] call _assert;
  };

  // Dirty it again so Discard has real work to do.
  [_kitAId,"optic",_draftOptic06D] call ServoPeregrino_Organizador_Weapons_fnc_setWeaponKitDraftSelection;
 };

 private _discardDraft06D = [_kitAId] call ServoPeregrino_Organizador_Weapons_fnc_discardWeaponKitDraft;
 ["0.6-D discard restores saved WeaponKit snapshot",_discardDraft06D getOrDefault ["success",false]] call _assert;
 if (_discardDraft06D getOrDefault ["success",false]) then {
  private _discarded06D = (_discardDraft06D get "data") get "draft";
  ["0.6-D discarded draft is clean",!(_discarded06D getOrDefault ["dirty",true])] call _assert;
  if (_savedKitBefore06D getOrDefault ["success",false]) then {
   private _savedRecipeAfterDiscard06D = (((_savedKitBefore06D get "data") get "kit") get "recipe");
   private _discardCmp06D = [_savedRecipeAfterDiscard06D,_discarded06D getOrDefault ["recipe",createHashMap]] call ServoPeregrino_Organizador_Weapons_fnc_compareWeaponRecipes;
   ["0.6-D discard Recipe equals saved Recipe",_discardCmp06D get "success" && {((_discardCmp06D get "data") getOrDefault ["equal",false])}] call _assert;
  };
 };

 private _draftRepoAfter06D = [] call ServoPeregrino_Organizador_Weapons_fnc_listWeaponKits;
 ["0.6-D model operations do not mutate WeaponKit repository",
  _draftRepoBefore06D get "success"
  && {_draftRepoAfter06D get "success"}
  && {(((_draftRepoBefore06D get "data") get "kits") isEqualTo (((_draftRepoAfter06D get "data") get "kits")))}
 ] call _assert;
 ["0.6-D model operations do not mutate loadout",_draftLoadoutBefore06D isEqualTo (getUnitLoadout player)] call _assert;
};

// -----------------------------------------------------------------------------
// 0.6-A — Weapons Player UI shell / Items visual grammar.
// Scope: layout, labels, ALL/type filters, search/navigation, footer and read-only selected kit.
// No WeaponKit editing and no inventory application in this checkpoint.
// -----------------------------------------------------------------------------
["0.6-A label ALL => Todos",(["ALL"] call ServoPeregrino_Organizador_Weapons_fnc_getUISlotLabel) isEqualTo "Todos"] call _assert;
["0.6-A label PRIMARY => Principal",(["PRIMARY"] call ServoPeregrino_Organizador_Weapons_fnc_getUISlotLabel) isEqualTo "Principal"] call _assert;
["0.6-A label HANDGUN => Porte",(["HANDGUN"] call ServoPeregrino_Organizador_Weapons_fnc_getUISlotLabel) isEqualTo "Porte"] call _assert;
["0.6-A label SECONDARY => Secundária",(["SECONDARY"] call ServoPeregrino_Organizador_Weapons_fnc_getUISlotLabel) isEqualTo "Secundária"] call _assert;

missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,nil];
private _uiState06A = [] call ServoPeregrino_Organizador_Weapons_fnc_createUIState;
["0.6-A UI state creates",(_uiState06A getOrDefault ["ready",false])] call _assert;
["UI state exposes stable draft/focused-refresh contract",
 ((_uiState06A getOrDefault ["draftsByKitId",createHashMap]) isEqualType createHashMap)
 && {(_uiState06A getOrDefault ["catalogFocusedRefreshCount",-1]) isEqualType 0}
 && {(_uiState06A getOrDefault ["draftFocusedRefreshCount",-1]) isEqualType 0}
 && {(_uiState06A getOrDefault ["equipmentFocusedRefreshCount",-1]) isEqualType 0}
] call _assert;
["UI state release label",_uiState06A getOrDefault ["version",""]] call _observe;
["0.6-A R4 default kit filter Todos/internal ALL",(_uiState06A getOrDefault ["kitTypeFilter",""]) isEqualTo "ALL"] call _assert;
["0.6-A R4 default catalog filter Todos/internal ALL",(_uiState06A getOrDefault ["catalogTypeFilter",""]) isEqualTo "ALL"] call _assert;

// View model uses the real 0.5 private/session-local repository and 0.3 catalog.
private _vmAll06A = [] call ServoPeregrino_Organizador_Weapons_fnc_buildUIViewModel;
["0.6-A view model builds",_vmAll06A get "success"] call _assert;
if (_vmAll06A get "success") then {
 private _vmData06A = _vmAll06A get "data";
 private _allPrivateKits06A = _vmData06A getOrDefault ["kits",[]];

 ["0.6-A R4 TODOS shows every private kit",
  (count _allPrivateKits06A) isEqualTo (_vmData06A getOrDefault ["allKitCount",-1])
 ] call _assert;
 ["0.6-A catalog available",(_vmData06A getOrDefault ["catalogTotal",0]) > 0] call _assert;
 ["0.6-A R4 TODOS catalog matches full catalog",
  (_vmData06A getOrDefault ["catalogMatchCount",-1]) isEqualTo (_vmData06A getOrDefault ["catalogTotal",-2])
 ] call _assert;
 ["0.6-A R4 catalog render projection bounded",
  (_vmData06A getOrDefault ["catalogRenderedCount",999999]) <= SP_ORG_WEAPONS_UI_CATALOG_WINDOW_SIZE
 ] call _assert;
 ["0.6-A R4 full catalog remains searchable behind projection",
  (_vmData06A getOrDefault ["catalogMatchCount",0]) >= (_vmData06A getOrDefault ["catalogRenderedCount",0])
  && {(_vmData06A getOrDefault ["catalogTotal",0]) >= (_vmData06A getOrDefault ["catalogMatchCount",0])}
 ] call _assert;
};

// Kit type filters change only the private-kit UI projection.
["KIT_TYPE","PRIMARY"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
private _vmPrimary06A = [] call ServoPeregrino_Organizador_Weapons_fnc_buildUIViewModel;
["0.6-A Principal filter returns only PRIMARY",
 _vmPrimary06A get "success"
 && {(((_vmPrimary06A get "data") getOrDefault ["kits",[]]) findIf {
  toUpperANSI (_x getOrDefault ["targetSlot",""]) isNotEqualTo "PRIMARY"
 }) < 0}
] call _assert;

["KIT_TYPE","HANDGUN"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
private _vmPorte06A = [] call ServoPeregrino_Organizador_Weapons_fnc_buildUIViewModel;
["0.6-A Porte filter maps to HANDGUN",
 _vmPorte06A get "success"
 && {(((_vmPorte06A get "data") getOrDefault ["kits",[]]) findIf {
  toUpperANSI (_x getOrDefault ["targetSlot",""]) isNotEqualTo "HANDGUN"
 }) < 0}
] call _assert;

["KIT_SEARCH","Sidearm"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
private _vmPorteSearch06A = [] call ServoPeregrino_Organizador_Weapons_fnc_buildUIViewModel;
["0.6-A kit search works inside active type",
 _vmPorteSearch06A get "success"
 && {(count (((_vmPorteSearch06A get "data") getOrDefault ["kits",[]]))) >= 1}
] call _assert;

["KIT_SEARCH",""] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
["KIT_TYPE","SECONDARY"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
private _vmSecondary06A = [] call ServoPeregrino_Organizador_Weapons_fnc_buildUIViewModel;
["0.6-A Secundária filter maps to SECONDARY",
 _vmSecondary06A get "success"
 && {(((_vmSecondary06A get "data") getOrDefault ["kits",[]]) findIf {
  toUpperANSI (_x getOrDefault ["targetSlot",""]) isNotEqualTo "SECONDARY"
 }) < 0}
] call _assert;

["KIT_TYPE","ALL"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
private _vmKitsAllAgain06A = [] call ServoPeregrino_Organizador_Weapons_fnc_buildUIViewModel;
["0.6-A R4 kit TODOS restores all private kits",
 _vmKitsAllAgain06A get "success"
 && {(count (((_vmKitsAllAgain06A get "data") getOrDefault ["kits",[]]))
     isEqualTo (((_vmKitsAllAgain06A get "data") getOrDefault ["allKitCount",-1])))}
] call _assert;

// Catalog type filters are independent from Meus Kits.
["CATALOG_TYPE","PRIMARY"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
private _vmCatPrimary06A = [] call ServoPeregrino_Organizador_Weapons_fnc_buildUIViewModel;
["0.6-A R4 Catalog Principal returns only PRIMARY",
 _vmCatPrimary06A get "success"
 && {(((_vmCatPrimary06A get "data") getOrDefault ["catalog",[]]) findIf {
  toUpperANSI (_x getOrDefault ["category",""]) isNotEqualTo "PRIMARY"
 }) < 0}
 && {((_vmCatPrimary06A get "data") getOrDefault ["catalogMatchCount",0]) > 0}
] call _assert;

["CATALOG_TYPE","HANDGUN"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
private _vmCatPorte06A = [] call ServoPeregrino_Organizador_Weapons_fnc_buildUIViewModel;
["0.6-A R4 Catalog Porte returns only HANDGUN",
 _vmCatPorte06A get "success"
 && {(((_vmCatPorte06A get "data") getOrDefault ["catalog",[]]) findIf {
  toUpperANSI (_x getOrDefault ["category",""]) isNotEqualTo "HANDGUN"
 }) < 0}
 && {((_vmCatPorte06A get "data") getOrDefault ["catalogMatchCount",0]) > 0}
] call _assert;

["CATALOG_TYPE","SECONDARY"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
private _vmCatSecondary06A = [] call ServoPeregrino_Organizador_Weapons_fnc_buildUIViewModel;
["0.6-A R4 Catalog Secundária returns only SECONDARY",
 _vmCatSecondary06A get "success"
 && {(((_vmCatSecondary06A get "data") getOrDefault ["catalog",[]]) findIf {
  toUpperANSI (_x getOrDefault ["category",""]) isNotEqualTo "SECONDARY"
 }) < 0}
 && {((_vmCatSecondary06A get "data") getOrDefault ["catalogMatchCount",0]) > 0}
] call _assert;

["CATALOG_TYPE","ALL"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
private _vmCatAll06A = [] call ServoPeregrino_Organizador_Weapons_fnc_buildUIViewModel;
["0.6-A R4 Catalog TODOS restores full catalog",
 _vmCatAll06A get "success"
 && {((_vmCatAll06A get "data") getOrDefault ["catalogMatchCount",-1])
     isEqualTo ((_vmCatAll06A get "data") getOrDefault ["catalogTotal",-2])}
] call _assert;

// Text search composes with the active catalog type filter.
["CATALOG_SEARCH","MX"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
private _vmCatalogSearch06A = [] call ServoPeregrino_Organizador_Weapons_fnc_buildUIViewModel;
["0.6-A catalog search returns matches",
 _vmCatalogSearch06A get "success"
 && {(count (((_vmCatalogSearch06A get "data") getOrDefault ["catalog",[]]))) > 0}
] call _assert;
if (_vmCatalogSearch06A get "success") then {
 private _catalogMx06A = ((_vmCatalogSearch06A get "data") getOrDefault ["catalog",[]]);
 ["0.6-A catalog search filters name/class",(_catalogMx06A findIf {
  private _dn = toLowerANSI (_x getOrDefault ["displayName",""]);
  private _cl = toLowerANSI (_x getOrDefault ["weaponClass",""]);
  (_dn find "mx" < 0) && {_cl find "mx" < 0}
 }) < 0] call _assert;
};

["CATALOG_SEARCH",""] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
["CATALOG_TYPE","PRIMARY"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
["CATALOG_SEARCH","MX"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
private _vmCatCombined06A = [] call ServoPeregrino_Organizador_Weapons_fnc_buildUIViewModel;
["0.6-A R4 catalog search composes with Principal filter",
 _vmCatCombined06A get "success"
 && {(((_vmCatCombined06A get "data") getOrDefault ["catalog",[]]) findIf {
  private _dn = toLowerANSI (_x getOrDefault ["displayName",""]);
  private _cl = toLowerANSI (_x getOrDefault ["weaponClass",""]);
  (toUpperANSI (_x getOrDefault ["category",""]) isNotEqualTo "PRIMARY")
  || {(_dn find "mx" < 0) && {_cl find "mx" < 0}}
 }) < 0}
] call _assert;

["CATALOG_SEARCH",""] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
["CATALOG_TYPE","ALL"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;

// -----------------------------------------------------------------------------
// 0.6-D R3 — UI convergence model: category filters, continuous window and
// read-only current equipment. No repository or loadout mutation is allowed.
// -----------------------------------------------------------------------------
private _r2State = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
_r2State set ["selectedKitId",_kitAId];
_r2State set ["kitQuery",""];
_r2State set ["kitTypeFilter","ALL"];
_r2State set ["catalogQuery",""];
_r2State set ["catalogTypeFilter","ALL"];
_r2State set ["catalogOffset",0];
missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_r2State];

["CATALOG_CATEGORY","OPTIC"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
private _vmOpticR2 = [] call ServoPeregrino_Organizador_Weapons_fnc_buildUIViewModel;
["0.6-D R3 optic category resolves compatible rows",
 _vmOpticR2 get "success"
 && {((_vmOpticR2 get "data") getOrDefault ["catalogMatchCount",0]) > 0}
 && {(((_vmOpticR2 get "data") getOrDefault ["catalog",[]]) findIf {(_x getOrDefault ["catalogKind",""]) isNotEqualTo "OPTIC"}) < 0}
] call _assert;

["CATALOG_CATEGORY","POINTER"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
private _vmPointerR2 = [] call ServoPeregrino_Organizador_Weapons_fnc_buildUIViewModel;
["0.6-D R3 pointer category resolves compatible rows",
 _vmPointerR2 get "success"
 && {((_vmPointerR2 get "data") getOrDefault ["catalogMatchCount",0]) > 0}
 && {(((_vmPointerR2 get "data") getOrDefault ["catalog",[]]) findIf {(_x getOrDefault ["catalogKind",""]) isNotEqualTo "POINTER"}) < 0}
] call _assert;

["CATALOG_CATEGORY","BIPOD"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
private _vmBipodR2 = [] call ServoPeregrino_Organizador_Weapons_fnc_buildUIViewModel;
["0.6-D R3 bipod category remains engine-derived",
 _vmBipodR2 get "success"
 && {(((_vmBipodR2 get "data") getOrDefault ["catalog",[]]) findIf {(_x getOrDefault ["catalogKind",""]) isNotEqualTo "BIPOD"}) < 0}
] call _assert;

["CATALOG_CATEGORY","MAGAZINE"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
private _vmMagazineR2 = [] call ServoPeregrino_Organizador_Weapons_fnc_buildUIViewModel;
["0.6-D R3 magazine category resolves compatible rows",
 _vmMagazineR2 get "success"
 && {((_vmMagazineR2 get "data") getOrDefault ["catalogMatchCount",0]) > 0}
 && {(((_vmMagazineR2 get "data") getOrDefault ["catalog",[]]) findIf {(_x getOrDefault ["catalogKind",""]) isNotEqualTo "MAGAZINE"}) < 0}
] call _assert;

["CATALOG_CATEGORY","GRIP"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
private _vmGripR2 = [] call ServoPeregrino_Organizador_Weapons_fnc_buildUIViewModel;
["0.6-D R3 grip category is a visual classification of engine underbarrel options",
 _vmGripR2 get "success"
 && {(((_vmGripR2 get "data") getOrDefault ["catalog",[]]) findIf {
  (_x getOrDefault ["catalogKind",""]) isNotEqualTo "GRIP"
  || {(_x getOrDefault ["underbarrelClassification",""]) isNotEqualTo "GRIP_HEURISTIC"}
 }) < 0}
] call _assert;

["CATALOG_CATEGORY","WEAPON"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
private _vmWeaponWindowR2 = [] call ServoPeregrino_Organizador_Weapons_fnc_buildUIViewModel;
["0.6-D R3 weapon category uses continuous bounded window",
 _vmWeaponWindowR2 get "success"
 && {((_vmWeaponWindowR2 get "data") getOrDefault ["catalogRenderedCount",999]) <= SP_ORG_WEAPONS_UI_CATALOG_WINDOW_SIZE}
 && {((_vmWeaponWindowR2 get "data") getOrDefault ["catalogMaxOffset",0]) > 0}
] call _assert;
if (_vmWeaponWindowR2 get "success") then {
 private _windowDataR2 = _vmWeaponWindowR2 get "data";
 private _scrollStateR2 = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
 _scrollStateR2 set ["catalogMaxOffset",_windowDataR2 getOrDefault ["catalogMaxOffset",0]];
 _scrollStateR2 set ["catalogOffset",0];
 missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_scrollStateR2];
 ["CATALOG_SCROLL",6] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
 private _afterRelativeScrollR2 = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
 ["0.6-D R3 relative catalog scroll advances six rows",(_afterRelativeScrollR2 getOrDefault ["catalogOffset",-1]) isEqualTo 6] call _assert;
 ["CATALOG_SCROLL_ABSOLUTE",12] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
 private _afterAbsoluteScrollR2 = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
 ["0.6-D R3 absolute catalog slider sets window offset",(_afterAbsoluteScrollR2 getOrDefault ["catalogOffset",-1]) isEqualTo 12] call _assert;
 ["CATALOG_SEARCH","MX"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
 private _afterSearchResetR2 = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
 ["0.6-D R3 catalog search resets continuous offset",(_afterSearchResetR2 getOrDefault ["catalogOffset",-1]) isEqualTo 0] call _assert;
};

private _equipmentLoadoutBeforeR2 = getUnitLoadout player;
private _equipmentPrimaryR2 = [player,"PRIMARY"] call ServoPeregrino_Organizador_Weapons_fnc_getEquipmentSlotSnapshot;
["0.6-D R3 primary equipment snapshot resolves",_equipmentPrimaryR2 get "success"] call _assert;
if (_equipmentPrimaryR2 get "success") then {
 private _eqSnapshotR2 = (_equipmentPrimaryR2 get "data") get "snapshot";
 ["0.6-D R3 equipment snapshot schema marker",(_eqSnapshotR2 getOrDefault ["schemaVersion",""]) isEqualTo "0.6-D-r2-equipment-view-candidate"] call _assert;
 ["0.6-D R3 equipment snapshot slot PRIMARY",(_eqSnapshotR2 getOrDefault ["slot",""]) isEqualTo "PRIMARY"] call _assert;
};
["0.6-D R3 equipment inspection does not mutate loadout",_equipmentLoadoutBeforeR2 isEqualTo (getUnitLoadout player)] call _assert;

// Restore canonical catalog projection before opening the dialog.
["CATALOG_SEARCH",""] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
["CATALOG_TYPE","ALL"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
["CATALOG_CATEGORY","ALL"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;

// R3 regression setup: emulate stale MEUS KITS state from a previous UI session.
// Opening the dialog must ignore this projection and start in TODOS with empty search.
["KIT_TYPE","PRIMARY"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
["KIT_SEARCH","__R3_STALE_OPEN_STATE__"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;

// Snapshot before UI shell interaction: 0.6-A must not mutate kit repository or loadout.
private _kitsBeforeUI06A = [] call ServoPeregrino_Organizador_Weapons_fnc_listWeaponKits;
private _loadoutBeforeUI06A = getUnitLoadout player;

private _open06A = [] call ServoPeregrino_Organizador_Weapons_fnc_openInterface;
["0.6-A interface opens",_open06A get "success"] call _assert;
["0.6-A open metadata says no inventory mutation",
 _open06A get "success"
 && {!(((_open06A get "data") getOrDefault ["mutatesInventory",true]))}
] call _assert;

disableSerialization;
private _display06A = findDisplay SP_ORG_WEAPONS_UI_DISPLAY_IDD;
["0.6-A display exists",!isNull _display06A] call _assert;

if (!isNull _display06A) then {
 // R4: wait for the explicit initial-render handshake instead of assuming
 // the first list paint always finishes within a fixed 50 ms.
 private _initialSyncWaitStartedR4 = diag_tickTime;
 private _initialSyncDeadlineR4 = diag_tickTime + 4;
 waitUntil {
  uiSleep 0.01;
  private _waitStateR4 = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
  (_waitStateR4 getOrDefault ["initialSyncComplete",false])
  || {diag_tickTime >= _initialSyncDeadlineR4}
 };

 private _stateInitialR4 = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
 private _repoInitialR4 = [] call ServoPeregrino_Organizador_Weapons_fnc_listWeaponKits;
 private _expectedInitialRowsR4 = if (_repoInitialR4 get "success") then {
  count (((_repoInitialR4 get "data") getOrDefault ["kits",[]]))
 } else {-1};

 ["0.6-B R4 initial sync handshake completes",
  _stateInitialR4 getOrDefault ["initialSyncComplete",false]
 ] call _assert;
 ["0.6-B R4 opens Meus Kits with TODOS active",
  (_stateInitialR4 getOrDefault ["kitTypeFilter",""]) isEqualTo "ALL"
 ] call _assert;
 ["0.6-B R4 opens Meus Kits with empty search",
  (_stateInitialR4 getOrDefault ["kitQuery","__NOT_EMPTY__"]) isEqualTo ""
 ] call _assert;
 ["0.6-B R4 initial Meus Kits rows match repository",
  _expectedInitialRowsR4 >= 0
  && {(lbSize (_display06A displayCtrl 1110)) isEqualTo _expectedInitialRowsR4}
 ] call _assert;
 ["0.6-B R4 initial kit is selected when kits exist",
  (_expectedInitialRowsR4 isEqualTo 0)
  || {(lbCurSel (_display06A displayCtrl 1110)) >= 0}
 ] call _assert;

 diag_log format [
  "[SP_ORG] [WEAPONS] [AUTO_TEST_DETAIL] test=UI_INITIAL_KITS_R4 filter=%1 query=%2 rows=%3 expectedRows=%4 selected=%5 handshake=%6 waitMs=%7 syncElapsedMs=%8",
  _stateInitialR4 getOrDefault ["kitTypeFilter",""],
  _stateInitialR4 getOrDefault ["kitQuery",""],
  lbSize (_display06A displayCtrl 1110),
  _expectedInitialRowsR4,
  lbCurSel (_display06A displayCtrl 1110),
  _stateInitialR4 getOrDefault ["initialSyncComplete",false],
  round ((diag_tickTime - _initialSyncWaitStartedR4) * 1000),
  _stateInitialR4 getOrDefault ["initialSyncElapsedMs",-1]
 ];
 ["0.6-D R3 panel title MEUS KITS DE ARMAS",(ctrlText (_display06A displayCtrl 1000)) isEqualTo "MEUS KITS DE ARMAS"] call _assert;
 ["0.6-E R2 panel title ARMAS DO KIT",(ctrlText (_display06A displayCtrl 2000)) isEqualTo "ARMAS DO KIT"] call _assert;
 ["0.6-D R3 panel title CATÁLOGO DE ARMAS",(ctrlText (_display06A displayCtrl 3000)) isEqualTo "CATÁLOGO DE ARMAS"] call _assert;
 ["0.6-D R3 panel title CONTEÚDO DO EQUIPAMENTO",(ctrlText (_display06A displayCtrl 4000)) isEqualTo "CONTEÚDO DO EQUIPAMENTO"] call _assert;
 private _headerCtrl06A = _display06A displayCtrl 100;
["Header control exists and remains populated",!isNull _headerCtrl06A && {(ctrlText _headerCtrl06A) isNotEqualTo ""}] call _assert;
["Header release text",ctrlText _headerCtrl06A] call _observe;
 private _footerContextPosF = ctrlPosition (_display06A displayCtrl 5000);
 private _footerResultPosF = ctrlPosition (_display06A displayCtrl 5001);
 private _footerHistoryPosF = ctrlPosition (_display06A displayCtrl 5002);
 ["0.6-F R3 footer remains three ordered visual bands",
  (_footerContextPosF # 1) < (_footerResultPosF # 1)
  && {(_footerResultPosF # 1) < (_footerHistoryPosF # 1)}
 ] call _assert;

 ["0.6-A R4 Meus Kits filter Todos",(ctrlText (_display06A displayCtrl 1103)) isEqualTo "TODOS"] call _assert;
 ["0.6-D R3 kit filter Principal present",(ctrlText (_display06A displayCtrl 1104)) in ["PRINCIPAL","PRINC."]] call _assert;
 ["0.6-A filter button Porte",(ctrlText (_display06A displayCtrl 1105)) isEqualTo "PORTE"] call _assert;
 ["0.6-D R3 kit filter Secundária present",(ctrlText (_display06A displayCtrl 1106)) in ["SECUNDÁRIA","SEC."]] call _assert;
 ["0.6-A Publicos visible but disabled",
  (ctrlText (_display06A displayCtrl 1107)) isEqualTo "PÚBLICOS"
  && {!ctrlEnabled (_display06A displayCtrl 1107)}
 ] call _assert;

 ["0.6-A R4 Catalog filter Todos",(ctrlText (_display06A displayCtrl 3111)) isEqualTo "TODOS"] call _assert;
 ["0.6-A R4 Catalog filter Principal",(ctrlText (_display06A displayCtrl 3112)) isEqualTo "PRINC."] call _assert;
 ["0.6-A R4 Catalog filter Porte",(ctrlText (_display06A displayCtrl 3113)) isEqualTo "PORTE"] call _assert;
 ["0.6-A R4 Catalog filter Secundária",(ctrlText (_display06A displayCtrl 3114)) isEqualTo "SEC."] call _assert;
 ["0.6-D R3 accessory/category filters present",
  (ctrlText (_display06A displayCtrl 3132)) isEqualTo "TODOS"
  && {(ctrlText (_display06A displayCtrl 3133)) isEqualTo "ARMA"}
  && {(ctrlText (_display06A displayCtrl 3134)) isEqualTo "ÓTICA"}
  && {(ctrlText (_display06A displayCtrl 3135)) isEqualTo "APONT."}
  && {(ctrlText (_display06A displayCtrl 3136)) isEqualTo "BIPÉ"}
  && {(ctrlText (_display06A displayCtrl 3137)) isEqualTo "CARREG."}
  && {(ctrlText (_display06A displayCtrl 3138)) isEqualTo "EMPUNH."}
 ] call _assert;
 ["0.6-D R3 visible catalog scrollbar exists",!isNull (_display06A displayCtrl 3124)] call _assert;
 ["0.6-E R2 equipment slot selectors present in compact same-row grammar",
  (ctrlText (_display06A displayCtrl 4011)) in ["PRINCIPAL","PRINC."]
  && {(ctrlText (_display06A displayCtrl 4012)) isEqualTo "PORTE"}
  && {(ctrlText (_display06A displayCtrl 4013)) in ["SECUNDÁRIA","SEC."]}
 ] call _assert;

 ["0.6-A Meus Kits search exists",!isNull (_display06A displayCtrl 1100)] call _assert;
 ["0.6-A Catalog search exists",!isNull (_display06A displayCtrl 3100)] call _assert;
 ["0.6-A footer Context exists",!isNull (_display06A displayCtrl 5000)] call _assert;
 ["0.6-D R3 footer Result exists",!isNull (_display06A displayCtrl 5001)] call _assert;
 ["0.6-A footer History exists",!isNull (_display06A displayCtrl 5002)] call _assert;

 ["0.6-E R2 Meus Kits action order",
  (ctrlText (_display06A displayCtrl 1120)) isEqualTo "NOVO"
  && {(ctrlText (_display06A displayCtrl 1122)) isEqualTo "DUPLICAR"}
  && {(ctrlText (_display06A displayCtrl 1123)) isEqualTo "EXCLUIR"}
  && {(ctrlText (_display06A displayCtrl 1124)) isEqualTo "PUBLICAR"}
 ] call _assert;
 ["0.6-E R2 RENOMEAR removed from P1",isNull (_display06A displayCtrl 1121) || {(ctrlText (_display06A displayCtrl 1121)) isEqualTo ""}] call _assert;
 ["0.6-E R2 ARMAS DO KIT actions present",
  (ctrlText (_display06A displayCtrl 2141)) isEqualTo "SALVAR"
  && {(ctrlText (_display06A displayCtrl 2142)) isEqualTo "SALVAR COMO NOVO"}
  && {(ctrlText (_display06A displayCtrl 2140)) isEqualTo "DESCARTAR"}
  && {(ctrlText (_display06A displayCtrl 2143)) isEqualTo "LIMPAR"}
 ] call _assert;
 ["0.6-E R2 P2 and P4 search controls present",
  !isNull (_display06A displayCtrl 2051)
  && {!isNull (_display06A displayCtrl 4100)}
 ] call _assert;
 private _kitsTypePosR6 = ctrlPosition (_display06A displayCtrl 1102);
 private _kitsTodosPosR6 = ctrlPosition (_display06A displayCtrl 1103);
 private _catalogTypePosR6 = ctrlPosition (_display06A displayCtrl 3110);
 private _catalogTodosPosR6 = ctrlPosition (_display06A displayCtrl 3111);
 private _catalogAccessoryPosR6 = ctrlPosition (_display06A displayCtrl 3131);
 private _catalogAccessoryFirstPosR6 = ctrlPosition (_display06A displayCtrl 3132);
 ["0.6-F R6 P1 Tipo label sits close to its first filter",
  ((_kitsTodosPosR6#0) - ((_kitsTypePosR6#0)+(_kitsTypePosR6#2))) >= 0
  && {((_kitsTodosPosR6#0) - ((_kitsTypePosR6#0)+(_kitsTypePosR6#2))) <= (0.003*safeZoneW)}
 ] call _assert;
 ["0.6-F R6 P3 Tipo label sits close to its first filter",
  ((_catalogTodosPosR6#0) - ((_catalogTypePosR6#0)+(_catalogTypePosR6#2))) >= 0
  && {((_catalogTodosPosR6#0) - ((_catalogTypePosR6#0)+(_catalogTypePosR6#2))) <= (0.003*safeZoneW)}
 ] call _assert;
 ["0.6-F R6 P3 Acessório label sits close to its first filter",
  ((_catalogAccessoryFirstPosR6#0) - ((_catalogAccessoryPosR6#0)+(_catalogAccessoryPosR6#2))) >= 0
  && {((_catalogAccessoryFirstPosR6#0) - ((_catalogAccessoryPosR6#0)+(_catalogAccessoryPosR6#2))) <= (0.003*safeZoneW)}
 ] call _assert;

 ["0.6-E R2 direct draft controls present",
  (ctrlText (_display06A displayCtrl 3150)) isEqualTo "← EQUIPAR NO RASCUNHO"
  && {(ctrlText (_display06A displayCtrl 3151)) isEqualTo "EQUIPAMENTO →"}
  && {!ctrlEnabled (_display06A displayCtrl 3151)}
 ] call _assert;

 ["0.6-A selected kit fields present",
  !isNull (_display06A displayCtrl 2021)
  && {!isNull (_display06A displayCtrl 2023)}
  && {!isNull (_display06A displayCtrl 2025)}
  && {!isNull (_display06A displayCtrl 2027)}
  && {!isNull (_display06A displayCtrl 2029)}
  && {!isNull (_display06A displayCtrl 2031)}
 ] call _assert;

 private _insideSafe = {
  params ["_ctrl"];
  private _p = ctrlPosition _ctrl;
  private _x = _p select 0;
  private _y = _p select 1;
  private _w = _p select 2;
  private _h = _p select 3;
  (_x >= safeZoneX - 0.001)
  && {_y >= safeZoneY - 0.001}
  && {(_x + _w) <= (safeZoneX + safeZoneW + 0.001)}
  && {(_y + _h) <= (safeZoneY + safeZoneH + 0.001)}
 };
 ["0.6-A core controls stay inside safeZone",
  ([_display06A displayCtrl 1000] call _insideSafe)
  && {[_display06A displayCtrl 2000] call _insideSafe}
  && {[_display06A displayCtrl 3000] call _insideSafe}
  && {[_display06A displayCtrl 4000] call _insideSafe}
  && {[_display06A displayCtrl 3114] call _insideSafe}
  && {[_display06A displayCtrl 3124] call _insideSafe}
  && {[_display06A displayCtrl 4013] call _insideSafe}
  && {[_display06A displayCtrl 5002] call _insideSafe}
 ] call _assert;

 // R3 header geometry — operational blocks are anchored from Close toward the left.
 private _headerTitlePosR3 = ctrlPosition (_display06A displayCtrl 100);
 private _headerContextPosR3 = ctrlPosition (_display06A displayCtrl 104);
 private _headerOperatorPosR3 = ctrlPosition (_display06A displayCtrl 101);
 private _headerFuturePosR3 = ctrlPosition (_display06A displayCtrl 107);
 private _headerClosePosR3 = ctrlPosition (_display06A displayCtrl 102);
 ["0.6-D R3 header close is rightmost operational control",(_headerClosePosR3#0) > (_headerFuturePosR3#0)] call _assert;
 ["0.6-D R3 header operator block sits left of future slot",(_headerOperatorPosR3#0) < (_headerFuturePosR3#0)] call _assert;
 ["0.6-D R3 header context sits left of operator block",(_headerContextPosR3#0) < (_headerOperatorPosR3#0)] call _assert;
 ["0.6-D R3 header title ends before operational context",((_headerTitlePosR3#0)+(_headerTitlePosR3#2)) <= ((_headerContextPosR3#0)+0.002*safeZoneW)] call _assert;

 private _stateAfterOpenR2 = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
 ["0.6-D R3 opening resets catalog category to TODOS",(_stateAfterOpenR2 getOrDefault ["catalogCategoryFilter",""]) isEqualTo "ALL"] call _assert;
 ["0.6-D R3 opening resets catalog offset",(_stateAfterOpenR2 getOrDefault ["catalogOffset",-1]) isEqualTo 0] call _assert;
 ["0.6-D R3 catalog window size matches Items pattern",(_stateAfterOpenR2 getOrDefault ["catalogWindowSize",-1]) isEqualTo SP_ORG_WEAPONS_UI_CATALOG_WINDOW_SIZE] call _assert;
 ["0.6-D R3 catalog slider enabled for full catalog",ctrlEnabled (_display06A displayCtrl 3124)] call _assert;

 private _equipmentLoadoutBeforeUIR2 = getUnitLoadout player;
 private _equipmentFocusBeforeR3 = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
 private _equipmentFullBeforeR3 = _equipmentFocusBeforeR3 getOrDefault ["refreshAppliedCount",0];
 private _equipmentFocusedBeforeR3 = _equipmentFocusBeforeR3 getOrDefault ["equipmentFocusedRefreshCount",0];
 ["EQUIPMENT_SLOT","HANDGUN"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
 private _equipmentStateHandgunR2 = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
 ["0.6-D R3 equipment panel switches to Porte",(_equipmentStateHandgunR2 getOrDefault ["equipmentSlotView",""]) isEqualTo "HANDGUN"] call _assert;
 ["EQUIPMENT_SLOT","SECONDARY"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
 private _equipmentStateSecondaryR2 = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
 ["0.6-D R3 equipment panel switches to Secundária",(_equipmentStateSecondaryR2 getOrDefault ["equipmentSlotView",""]) isEqualTo "SECONDARY"] call _assert;
 ["EQUIPMENT_SLOT","PRIMARY"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
 private _equipmentFocusAfterR3 = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
 ["0.6-D R3 equipment slot navigation does not mutate loadout",_equipmentLoadoutBeforeUIR2 isEqualTo (getUnitLoadout player)] call _assert;
 ["0.6-D R3 equipment navigation avoids full refresh",(_equipmentFocusAfterR3 getOrDefault ["refreshAppliedCount",-1]) isEqualTo _equipmentFullBeforeR3] call _assert;
 ["0.6-D R3 equipment navigation uses focused refresh",(_equipmentFocusAfterR3 getOrDefault ["equipmentFocusedRefreshCount",0]) >= (_equipmentFocusedBeforeR3+3) && {(_equipmentFocusAfterR3 getOrDefault ["lastRefreshMode",""]) isEqualTo "EQUIPMENT_FOCUSED"}] call _assert;

 ["CATALOG_CATEGORY","OPTIC"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
 private _uiCategoryStateR2 = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
 ["0.6-D R3 UI category event selects Óticas",(_uiCategoryStateR2 getOrDefault ["catalogCategoryFilter",""]) isEqualTo "OPTIC"] call _assert;
 ["0.6-D R3 UI category event resets scrollbar offset",(_uiCategoryStateR2 getOrDefault ["catalogOffset",-1]) isEqualTo 0] call _assert;
 ["CATALOG_CATEGORY","ALL"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;

 // R3 performance regression: wheel/slider must repaint only the catalog window.
 private _catalogPerfBeforeR3 = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
 private _catalogFullBeforeR3 = _catalogPerfBeforeR3 getOrDefault ["refreshAppliedCount",0];
 private _catalogFocusedBeforeR3 = _catalogPerfBeforeR3 getOrDefault ["catalogFocusedRefreshCount",0];
 private _projectionBeforeR3 = missionNamespace getVariable [SP_ORG_WEAPONS_UI_CATALOG_PROJECTION_VAR,createHashMap];
 private _projectionBuildBeforeR3 = _projectionBeforeR3 getOrDefault ["projectionBuildCount",0];
 ["CATALOG_SCROLL",6] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
 private _catalogPerfAfterWheelR3 = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
 private _projectionAfterWheelR3 = missionNamespace getVariable [SP_ORG_WEAPONS_UI_CATALOG_PROJECTION_VAR,createHashMap];
 ["0.6-D R3 catalog wheel avoids full refresh",(_catalogPerfAfterWheelR3 getOrDefault ["refreshAppliedCount",-1]) isEqualTo _catalogFullBeforeR3] call _assert;
 ["0.6-D R3 catalog wheel uses focused refresh",(_catalogPerfAfterWheelR3 getOrDefault ["catalogFocusedRefreshCount",0]) > _catalogFocusedBeforeR3 && {(_catalogPerfAfterWheelR3 getOrDefault ["lastRefreshMode",""]) isEqualTo "CATALOG_FOCUSED"}] call _assert;
 ["0.6-D R3 catalog wheel reuses cached projection",(_projectionAfterWheelR3 getOrDefault ["projectionBuildCount",-1]) isEqualTo _projectionBuildBeforeR3] call _assert;
 private _catalogFullBeforeSliderR3 = _catalogPerfAfterWheelR3 getOrDefault ["refreshAppliedCount",0];
 ["CATALOG_SCROLL_ABSOLUTE",12] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
 private _catalogPerfAfterSliderR3 = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
 ["0.6-D R3 catalog slider avoids full refresh",(_catalogPerfAfterSliderR3 getOrDefault ["refreshAppliedCount",-1]) isEqualTo _catalogFullBeforeSliderR3 && {(_catalogPerfAfterSliderR3 getOrDefault ["catalogOffset",-1]) isEqualTo 12}] call _assert;
 ["CATALOG_SCROLL_ABSOLUTE",0] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;

 // --------------------------------------------------------------------------
 // 0.6-D R3 UI behavior — Catalog selection owns Catalog details only.
 // ARMAS DO KIT is never replaced by catalog preview.
 // --------------------------------------------------------------------------
 private _repoBeforeInfo06B = [] call ServoPeregrino_Organizador_Weapons_fnc_listWeaponKits;
 private _loadoutBeforeInfo06B = getUnitLoadout player;

 private _previewIdleDeadlineR4 = diag_tickTime + 3;
 waitUntil {
  uiSleep 0.01;
  private _idleStateR4 = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
  !(_idleStateR4 getOrDefault ["refreshInProgress",false])
  || {diag_tickTime >= _previewIdleDeadlineR4}
 };

 ["KIT_SEARCH","__SP_ORG_NO_PRIVATE_KIT_MATCH__"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
 ["CATALOG_CATEGORY","WEAPON"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
 ["CATALOG_TYPE","PRIMARY"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
 ["CATALOG_SEARCH","arifle_MX_F"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;

 private _vmInfo06B = [] call ServoPeregrino_Organizador_Weapons_fnc_buildUIViewModel;
 ["0.6-D R3 catalog information view model resolves",_vmInfo06B get "success"] call _assert;
 if (_vmInfo06B get "success") then {
  private _vmInfoData06B = _vmInfo06B get "data";
  private _catalogInfo06B = _vmInfoData06B getOrDefault ["selectedCatalogInfo",createHashMap];
  ["0.6-D R3 selected catalog info available",(count _catalogInfo06B) > 0] call _assert;
  ["0.6-D R3 selected catalog info is MX",(toLowerANSI (_catalogInfo06B getOrDefault ["weaponClass",""])) isEqualTo "arifle_mx_f"] call _assert;
  ["0.6-D R3 selected catalog row is weapon/PRIMARY",
   (_catalogInfo06B getOrDefault ["catalogKind",""]) isEqualTo "WEAPON"
   && {(_catalogInfo06B getOrDefault ["targetSlot",""]) isEqualTo "PRIMARY"}
  ] call _assert;
 };

 private _previewRefresh06B = [] call ServoPeregrino_Organizador_Weapons_fnc_refreshInterface;
 ["0.6-D R3 catalog details refresh succeeds",_previewRefresh06B get "success"] call _assert;
 ["0.6-D R3 P2 stays SEM KIT when kit projection is empty",(ctrlText (_display06A displayCtrl 2002)) isEqualTo "SEM KIT"] call _assert;
 ["0.6-D R3 P2 does not impersonate catalog preview",(ctrlText (_display06A displayCtrl 2021)) isEqualTo "Nenhuma"] call _assert;
 ["0.6-D R3 catalog details control remains available",!isNull (_display06A displayCtrl 3130)] call _assert;

 private _stateCatalogFocus06B = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
 ["0.6-D R3 catalog selection owns catalog focus",(_stateCatalogFocus06B getOrDefault ["lastFocus",""]) isEqualTo "CATALOG"] call _assert;

 // Restore kit projection, then click the already-selected first kit.
 // This verifies same-selection can still switch information focus from Catalog to Kits.
 ["KIT_SEARCH",""] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
 ["KIT_TYPE","ALL"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
 private _kitList06B = _display06A displayCtrl 1110;
 if ((lbSize _kitList06B) > 0) then {
  ["KIT_SELECT",0] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
 };
 private _stateKitFocus06B = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
 ["0.6-B kit click restores information focus",(_stateKitFocus06B getOrDefault ["lastFocus",""]) isEqualTo "KITS"] call _assert;

 private _vmKitInfo06B = [] call ServoPeregrino_Organizador_Weapons_fnc_buildUIViewModel;
 ["0.6-B selected kit weapon information resolves",
  _vmKitInfo06B get "success"
  && {(count ((_vmKitInfo06B get "data") getOrDefault ["selectedKitWeaponInfo",createHashMap])) > 0}
 ] call _assert;

 // --------------------------------------------------------------------------
 // 0.6-D R3 regression — selectors still edit the local WeaponKit draft. Changes
 // survive refresh/focus while repository/loadout remain untouched; DESCARTAR
 // restores the current saved WeaponKit snapshot.
 // --------------------------------------------------------------------------
 if (_kitAId isNotEqualTo "") then {
  private _compatState06D = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
  _compatState06D set ["kitQuery",""];
  _compatState06D set ["kitTypeFilter","ALL"];
  _compatState06D set ["selectedKitId",_kitAId];
  _compatState06D set ["lastFocus","KITS"];
  missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_compatState06D];
  [_kitAId] call ServoPeregrino_Organizador_Weapons_fnc_discardWeaponKitDraft;

  private _repoBeforeCombo06D = [] call ServoPeregrino_Organizador_Weapons_fnc_listWeaponKits;
  private _loadoutBeforeCombo06D = getUnitLoadout player;
  private _compatRefresh06D = [] call ServoPeregrino_Organizador_Weapons_fnc_refreshInterface;
  ["0.6-D selected kit draft refresh succeeds",_compatRefresh06D get "success"] call _assert;

  private _vmCompatUI06D = [] call ServoPeregrino_Organizador_Weapons_fnc_buildUIViewModel;
  ["0.6-D selected kit draft view model resolves",
   _vmCompatUI06D get "success"
   && {(count ((_vmCompatUI06D get "data") getOrDefault ["selectedKitDraft",createHashMap])) > 0}
   && {(count ((_vmCompatUI06D get "data") getOrDefault ["selectedKitCompatibility",createHashMap])) > 0}
  ] call _assert;

  private _opticCtrl06D = _display06A displayCtrl 2023;
  private _muzzleCtrl06D = _display06A displayCtrl 2025;
  private _pointerCtrl06D = _display06A displayCtrl 2027;
  private _bipodCtrl06D = _display06A displayCtrl 2029;
  private _magCtrl06D = _display06A displayCtrl 2031;

  ["0.6-D five compatibility controls populated",
   (lbSize _opticCtrl06D) > 0
   && {(lbSize _muzzleCtrl06D) > 0}
   && {(lbSize _pointerCtrl06D) > 0}
   && {(lbSize _bipodCtrl06D) > 0}
   && {(lbSize _magCtrl06D) > 0}
  ] call _assert;
  ["0.6-D compatibility controls enabled for selected kit",
   ctrlEnabled _opticCtrl06D
   && {ctrlEnabled _muzzleCtrl06D}
   && {ctrlEnabled _pointerCtrl06D}
   && {ctrlEnabled _bipodCtrl06D}
   && {ctrlEnabled _magCtrl06D}
  ] call _assert;
  ["0.6-D clean draft starts from saved empty MX values",
   (_opticCtrl06D lbData (lbCurSel _opticCtrl06D)) isEqualTo ""
   && {(_muzzleCtrl06D lbData (lbCurSel _muzzleCtrl06D)) isEqualTo ""}
   && {(_pointerCtrl06D lbData (lbCurSel _pointerCtrl06D)) isEqualTo ""}
   && {(_bipodCtrl06D lbData (lbCurSel _bipodCtrl06D)) isEqualTo ""}
   && {(_magCtrl06D lbData (lbCurSel _magCtrl06D)) isEqualTo ""}
   && {(ctrlText (_display06A displayCtrl 2002)) isEqualTo "SALVO"}
  ] call _assert;

  private _altOpticIndex06D = -1;
  for "_i" from 0 to ((lbSize _opticCtrl06D) - 1) do {
   if ((_opticCtrl06D lbData _i) isNotEqualTo "" && {_altOpticIndex06D < 0}) then {_altOpticIndex06D = _i};
  };
  ["0.6-D MX exposes at least one compatible optic",_altOpticIndex06D >= 0] call _assert;
  private _chosenOptic06D = "";
  if (_altOpticIndex06D >= 0) then {
   _chosenOptic06D = _opticCtrl06D lbData _altOpticIndex06D;
   private _draftPerfBeforeR3 = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
   private _draftFullBeforeR3 = _draftPerfBeforeR3 getOrDefault ["refreshAppliedCount",0];
   private _draftFocusedBeforeR3 = _draftPerfBeforeR3 getOrDefault ["draftFocusedRefreshCount",0];
   ["COMPAT_SELECT",["optic",_altOpticIndex06D]] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
   private _draftPerfAfterR3 = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
   ["0.6-D compatible selector persists in local draft after refresh",
    (toLowerANSI (_opticCtrl06D lbData (lbCurSel _opticCtrl06D))) isEqualTo (toLowerANSI _chosenOptic06D)
   ] call _assert;
   ["0.6-D R3 compatibility edit avoids full refresh",(_draftPerfAfterR3 getOrDefault ["refreshAppliedCount",-1]) isEqualTo _draftFullBeforeR3] call _assert;
   ["0.6-D R3 compatibility edit uses draft-focused refresh",(_draftPerfAfterR3 getOrDefault ["draftFocusedRefreshCount",0]) > _draftFocusedBeforeR3 && {(_draftPerfAfterR3 getOrDefault ["lastRefreshMode",""]) isEqualTo "DRAFT_FOCUSED"}] call _assert;
  };

  private _stateAfterCombo06D = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
  private _draftsAfterCombo06D = _stateAfterCombo06D getOrDefault ["draftsByKitId",createHashMap];
  private _draftAfterCombo06D = _draftsAfterCombo06D getOrDefault [_kitAId,createHashMap];
  private _draftRecipeAfterCombo06D = _draftAfterCombo06D getOrDefault ["recipe",createHashMap];
  private _draftCfgAfterCombo06D = _draftRecipeAfterCombo06D getOrDefault ["configuration",createHashMap];
  ["0.6-D UI stores draft per WeaponKit id",(count _draftAfterCombo06D) > 0 && {(_draftAfterCombo06D getOrDefault ["sourceKitId",""]) isEqualTo _kitAId}] call _assert;
  ["0.6-D selector interaction marks draft dirty",_draftAfterCombo06D getOrDefault ["dirty",false]] call _assert;
  ["0.6-D UI draft stores selected optic",(toLowerANSI (_draftCfgAfterCombo06D getOrDefault ["optic",""])) isEqualTo (toLowerANSI _chosenOptic06D)] call _assert;
  ["0.6-D status exposes ALTERADO",(ctrlText (_display06A displayCtrl 2002)) isEqualTo "ALTERADO"] call _assert;
  ["0.6-D DESCARTAR enabled only for dirty draft",ctrlEnabled (_display06A displayCtrl 2140)] call _assert;

  // Refresh/focus changes must not silently lose unsaved draft state.
  ["CATALOG_SEARCH","MX"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
  ["CATALOG_TYPE","PRIMARY"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
  ["KIT_SELECT",lbCurSel (_display06A displayCtrl 1110)] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
  ["0.6-D draft survives normal refresh/focus cycle",
   (toLowerANSI (_opticCtrl06D lbData (lbCurSel _opticCtrl06D))) isEqualTo (toLowerANSI _chosenOptic06D)
  ] call _assert;

  ["DRAFT_DISCARD"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
  private _stateAfterDiscard06D = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
  private _draftsAfterDiscard06D = _stateAfterDiscard06D getOrDefault ["draftsByKitId",createHashMap];
  private _draftAfterDiscard06D = _draftsAfterDiscard06D getOrDefault [_kitAId,createHashMap];
  ["0.6-D discard restores saved selector value",
   (_opticCtrl06D lbData (lbCurSel _opticCtrl06D)) isEqualTo ""
  ] call _assert;
  ["0.6-D discard clears dirty status",
   !(_draftAfterDiscard06D getOrDefault ["dirty",true])
   && {(ctrlText (_display06A displayCtrl 2002)) isEqualTo "SALVO"}
   && {!ctrlEnabled (_display06A displayCtrl 2140)}
  ] call _assert;

  private _repoAfterCombo06D = [] call ServoPeregrino_Organizador_Weapons_fnc_listWeaponKits;
  ["0.6-D selector/discard interaction does not mutate WeaponKit repository",
   _repoBeforeCombo06D get "success"
   && {_repoAfterCombo06D get "success"}
   && {(((_repoBeforeCombo06D get "data") get "kits") isEqualTo (((_repoAfterCombo06D get "data") get "kits")))}
  ] call _assert;
  ["0.6-D selector/discard interaction does not mutate loadout",_loadoutBeforeCombo06D isEqualTo (getUnitLoadout player)] call _assert;
 };


 // --------------------------------------------------------------------------
 // 0.6-E R2 — UX Convergence / Direct Catalog-to-Draft authoring.
 // NOVO prepares a pending draft without creating an invalid WeaponKit.
 // The first WEAPON sent from Catalog creates the minimum valid session kit.
 // All authoring below must leave getUnitLoadout untouched.
 // --------------------------------------------------------------------------
 private _authoringLoadoutBeforeE = getUnitLoadout player;
 private _authoringRepoBeforeE = [] call ServoPeregrino_Organizador_Weapons_fnc_listWeaponKits;
 private _authoringCountBeforeE = if (_authoringRepoBeforeE get "success") then {count ((_authoringRepoBeforeE get "data") getOrDefault ["kits",[]])} else {-1};

 ["CATALOG_SEARCH",""] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
 ["P2_SEARCH",""] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
 ["P4_SEARCH",""] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
 ["P2_SEARCH","AUTO-R2"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
 private _searchStateP2E = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
 ["0.6-F R4 P2 search remains isolated from Catalog/P4",
  (_searchStateP2E getOrDefault ["draftQuery",""]) isEqualTo "AUTO-R2"
  && {(_searchStateP2E getOrDefault ["catalogQuery",""]) isEqualTo ""}
  && {(_searchStateP2E getOrDefault ["equipmentQuery",""]) isEqualTo ""}
  && {(ctrlText (_display06A displayCtrl 2051)) isEqualTo "AUTO-R2"}
  && {(ctrlText (_display06A displayCtrl 3100)) isEqualTo ""}
  && {(ctrlText (_display06A displayCtrl 4100)) isEqualTo ""}
 ] call _assert;
 ["P4_SEARCH","AUTO-R2-P4"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
 private _searchStateP4E = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
 ["0.6-F R4 P4 search remains isolated from Catalog/P2",
  (_searchStateP4E getOrDefault ["draftQuery",""]) isEqualTo "AUTO-R2"
  && {(_searchStateP4E getOrDefault ["catalogQuery",""]) isEqualTo ""}
  && {(_searchStateP4E getOrDefault ["equipmentQuery",""]) isEqualTo "AUTO-R2-P4"}
  && {(ctrlText (_display06A displayCtrl 2051)) isEqualTo "AUTO-R2"}
  && {(ctrlText (_display06A displayCtrl 3100)) isEqualTo ""}
  && {(ctrlText (_display06A displayCtrl 4100)) isEqualTo "AUTO-R2-P4"}
 ] call _assert;
 ["P2_SEARCH",""] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
 ["P4_SEARCH",""] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;

 ["NEW_KIT"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
 private _pendingStateE = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
 private _repoPendingE = [] call ServoPeregrino_Organizador_Weapons_fnc_listWeaponKits;
 ["0.6-E R2 NOVO prepares pending draft without repository object",
  (_pendingStateE getOrDefault ["pendingNewKit",false])
  && {(_pendingStateE getOrDefault ["selectedKitId",""]) isEqualTo ""}
  && {(_pendingStateE getOrDefault ["catalogCategoryFilter",""]) isEqualTo "WEAPON"}
  && {(_pendingStateE getOrDefault ["catalogQuery",""]) isEqualTo ""}
  && {_repoPendingE get "success"}
  && {count ((_repoPendingE get "data") getOrDefault ["kits",[]]) isEqualTo _authoringCountBeforeE}
 ] call _assert;
 ["0.6-E R2 pending draft shows NOVO",(ctrlText (_display06A displayCtrl 2002)) isEqualTo "NOVO"] call _assert;
 ["0.6-E R2 NOVO does not mutate physical loadout",_authoringLoadoutBeforeE isEqualTo (getUnitLoadout player)] call _assert;

 private _pendingBadStateE = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
 _pendingBadStateE set ["selectedCatalogClass","optic_Aco"];
 _pendingBadStateE set ["selectedCatalogKind","OPTIC"];
 missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_pendingBadStateE];
 private _badFirstE = ["AUTO R2 Pending"] call ServoPeregrino_Organizador_Weapons_fnc_applyCatalogSelectionToDraft;
 ["0.6-F R6 pending draft still requires a base WEAPON before accessories",
  !(_badFirstE getOrDefault ["success",false])
  && {(_badFirstE getOrDefault ["code",""]) isEqualTo "WEAPONS_UI_DRAFT_BASE_WEAPON_REQUIRED"}
 ] call _assert;

 private _pendingWeaponStateE = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
 _pendingWeaponStateE set ["selectedCatalogClass","arifle_MX_F"];
 _pendingWeaponStateE set ["selectedCatalogKind","WEAPON"];
 _pendingWeaponStateE set ["catalogTypeFilter","PRIMARY"];
 _pendingWeaponStateE set ["catalogCategoryFilter","WEAPON"];
 missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_pendingWeaponStateE];
 (_display06A displayCtrl 2001) ctrlSetText "AUTO R2 Pending";
 ["CATALOG_TO_DRAFT"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;

 private _afterWeaponStateE = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
 private _authoringKitIdE = _afterWeaponStateE getOrDefault ["selectedKitId",""];
 private _authoringRepoAfterWeaponE = [] call ServoPeregrino_Organizador_Weapons_fnc_listWeaponKits;
 ["0.6-E R2 catalog weapon completes one valid session WeaponKit",
  _authoringKitIdE isNotEqualTo ""
  && {!(_afterWeaponStateE getOrDefault ["pendingNewKit",true])}
  && {_afterWeaponStateE getOrDefault ["selectedKitIsNew",false]}
  && {_authoringRepoAfterWeaponE get "success"}
  && {count ((_authoringRepoAfterWeaponE get "data") getOrDefault ["kits",[]]) isEqualTo (_authoringCountBeforeE + 1)}
 ] call _assert;
 private _authoringKitRE = [_authoringKitIdE] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponKit;
 ["0.6-E R2 direct weapon creates/selects valid kit",_authoringKitRE get "success"] call _assert;
 if (_authoringKitRE get "success") then {
  private _authoringKitE = (_authoringKitRE get "data") get "kit";
  private _authoringRecipeE = _authoringKitE getOrDefault ["recipe",createHashMap];
  private _authoringCfgE = _authoringRecipeE getOrDefault ["configuration",createHashMap];
  ["0.6-E R2 direct weapon derives PRIMARY target slot",(_authoringKitE getOrDefault ["targetSlot",""]) isEqualTo "PRIMARY"] call _assert;
  ["0.6-E R2 direct weapon stores selected catalog weapon",(toLowerANSI (_authoringCfgE getOrDefault ["weaponClass",""])) isEqualTo "arifle_mx_f"] call _assert;
 };
 ["0.6-E R2 new valid kit remains NOVO until SALVAR",(ctrlText (_display06A displayCtrl 2002)) isEqualTo "NOVO"] call _assert;
 ["0.6-E R2 direct weapon does not mutate physical loadout",_authoringLoadoutBeforeE isEqualTo (getUnitLoadout player)] call _assert;

 if (_authoringKitIdE isNotEqualTo "") then {
  private _draftBaseRE = [_authoringKitIdE] call ServoPeregrino_Organizador_Weapons_fnc_getOrCreateWeaponKitDraft;
  private _draftBaseE = if (_draftBaseRE get "success") then {(_draftBaseRE get "data") get "draft"} else {createHashMap};
  private _selectorRE = [(((_draftBaseE getOrDefault ["recipe",createHashMap]) getOrDefault ["configuration",createHashMap]) getOrDefault ["weaponClass",""]),_draftBaseE getOrDefault ["recipe",createHashMap]] call ServoPeregrino_Organizador_Weapons_fnc_buildCompatibilitySelectorModel;
  private _opticE = "";
  if (_selectorRE get "success") then {
   private _selectorModelE = (_selectorRE get "data") get "model";
   private _opticSelectorE = (_selectorModelE getOrDefault ["selectors",createHashMap]) getOrDefault ["optic",createHashMap];
   private _opticOptionsE = _opticSelectorE getOrDefault ["options",[]];
   private _opticIdxE = _opticOptionsE findIf {(_x getOrDefault ["className",""]) isNotEqualTo ""};
   if (_opticIdxE >= 0) then {_opticE = (_opticOptionsE#_opticIdxE) getOrDefault ["className",""]};
  };
  ["0.6-E R2 MX exposes direct-compatible optic",_opticE isNotEqualTo ""] call _assert;
  if (_opticE isNotEqualTo "") then {
   // HF1 regression: Catalog accessory projection and P2 selector must use the same
   // engine-derived compatibility source for the current draft base weapon.
   ["CATALOG_CATEGORY","OPTIC"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
   private _projectionOpticE = missionNamespace getVariable [SP_ORG_WEAPONS_UI_CATALOG_PROJECTION_VAR,createHashMap];
   private _projectionRowsOpticE = _projectionOpticE getOrDefault ["rows",[]];
   ["0.6-E R2 HF1 catalog exposes selector-compatible optic",
    (_projectionRowsOpticE findIf {
     (toUpperANSI (_x getOrDefault ["catalogKind",""])) isEqualTo "OPTIC"
     && {(toLowerANSI (_x getOrDefault ["catalogClass",""])) isEqualTo (toLowerANSI _opticE)}
    }) >= 0
   ] call _assert;
   ["0.6-E R2 HF1 catalog projection tracks MX draft weapon",
    (toLowerANSI (_projectionOpticE getOrDefault ["sourceWeaponClass",""])) isEqualTo "arifle_mx_f"
   ] call _assert;
   private _opticStateE = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
   _opticStateE set ["selectedCatalogClass",_opticE];
   _opticStateE set ["selectedCatalogKind","OPTIC"];
   missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_opticStateE];
   ["CATALOG_TO_DRAFT"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
   private _draftOpticE = ((([] call ServoPeregrino_Organizador_Weapons_fnc_getUIState) getOrDefault ["draftsByKitId",createHashMap]) getOrDefault [_authoringKitIdE,createHashMap]);
   private _draftOpticCfgE = (_draftOpticE getOrDefault ["recipe",createHashMap]) getOrDefault ["configuration",createHashMap];
   ["0.6-E R2 direct optic changes only draft",
    _draftOpticE getOrDefault ["dirty",false]
    && {(toLowerANSI (_draftOpticCfgE getOrDefault ["optic",""])) isEqualTo (toLowerANSI _opticE)}
   ] call _assert;
  };

  ["DRAFT_CLEAR"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
  private _draftClearedE = ((([] call ServoPeregrino_Organizador_Weapons_fnc_getUIState) getOrDefault ["draftsByKitId",createHashMap]) getOrDefault [_authoringKitIdE,createHashMap]);
  private _draftClearedRecipeE = _draftClearedE getOrDefault ["recipe",createHashMap];
  private _draftClearedCfgE = _draftClearedRecipeE getOrDefault ["configuration",createHashMap];
  ["0.6-E R2 LIMPAR preserves base weapon",(toLowerANSI (_draftClearedCfgE getOrDefault ["weaponClass",""])) isEqualTo "arifle_mx_f"] call _assert;
  ["0.6-E R2 LIMPAR clears optional content",
   (_draftClearedCfgE getOrDefault ["optic",""]) isEqualTo ""
   && {(_draftClearedCfgE getOrDefault ["muzzle",""]) isEqualTo ""}
   && {(_draftClearedCfgE getOrDefault ["pointer",""]) isEqualTo ""}
   && {(_draftClearedCfgE getOrDefault ["bipod",""]) isEqualTo ""}
   && {(_draftClearedRecipeE getOrDefault ["magazineClass",""]) isEqualTo ""}
  ] call _assert;

  private _replaceStateE = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
  _replaceStateE set ["selectedCatalogClass","arifle_MXC_F"];
  _replaceStateE set ["selectedCatalogKind","WEAPON"];
  private _baseSwapFullBeforeE = _replaceStateE getOrDefault ["refreshAppliedCount",0];
  private _baseSwapDraftBeforeE = _replaceStateE getOrDefault ["draftFocusedRefreshCount",0];
  private _baseSwapCatalogBeforeE = _replaceStateE getOrDefault ["catalogFocusedRefreshCount",0];
  missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_replaceStateE];
  ["CATALOG_TO_DRAFT"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
  private _stateAfterBaseSwapE = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
  private _draftAfterWeaponE = ((_stateAfterBaseSwapE getOrDefault ["draftsByKitId",createHashMap]) getOrDefault [_authoringKitIdE,createHashMap]);
  private _draftRecipeAfterWeaponE = _draftAfterWeaponE getOrDefault ["recipe",createHashMap];
  private _draftCfgAfterWeaponE = _draftRecipeAfterWeaponE getOrDefault ["configuration",createHashMap];
  ["0.6-E R2 direct base weapon changes only draft",
   _draftAfterWeaponE getOrDefault ["dirty",false]
   && {(toLowerANSI (_draftCfgAfterWeaponE getOrDefault ["weaponClass",""])) isEqualTo "arifle_mxc_f"}
  ] call _assert;
  ["0.6-C2 base-weapon swap avoids FULL and refreshes only Draft+Catalog",
   (_stateAfterBaseSwapE getOrDefault ["refreshAppliedCount",0]) isEqualTo _baseSwapFullBeforeE
   && {(_stateAfterBaseSwapE getOrDefault ["draftFocusedRefreshCount",0]) isEqualTo (_baseSwapDraftBeforeE + 1)}
   && {(_stateAfterBaseSwapE getOrDefault ["catalogFocusedRefreshCount",0]) isEqualTo (_baseSwapCatalogBeforeE + 1)}
   && {(_stateAfterBaseSwapE getOrDefault ["lastRefreshMode",""]) isEqualTo "CATALOG_FOCUSED"}
  ] call _assert;
  private _projectionAfterBaseSwapE = missionNamespace getVariable [SP_ORG_WEAPONS_UI_CATALOG_PROJECTION_VAR,createHashMap];
  ["0.6-E R2 HF1 base-weapon swap rebuilds catalog compatibility projection",
   (toLowerANSI (_projectionAfterBaseSwapE getOrDefault ["sourceWeaponClass",""])) isEqualTo "arifle_mxc_f"
  ] call _assert;
  ["0.6-E R2 direct base weapon resets attachments",
   (_draftCfgAfterWeaponE getOrDefault ["optic",""]) isEqualTo ""
   && {(_draftCfgAfterWeaponE getOrDefault ["muzzle",""]) isEqualTo ""}
   && {(_draftCfgAfterWeaponE getOrDefault ["pointer",""]) isEqualTo ""}
   && {(_draftCfgAfterWeaponE getOrDefault ["bipod",""]) isEqualTo ""}
   && {(_draftRecipeAfterWeaponE getOrDefault ["magazineClass",""]) isEqualTo ""}
  ] call _assert;
  private _repoBeforeSaveE = [_authoringKitIdE] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponKit;
  private _repoBeforeSaveCfgE = if (_repoBeforeSaveE get "success") then {(((_repoBeforeSaveE get "data") get "kit") get "recipe") get "configuration"} else {createHashMap};
  ["0.6-E R2 draft base weapon does not auto-save repository",(toLowerANSI (_repoBeforeSaveCfgE getOrDefault ["weaponClass",""])) isEqualTo "arifle_mx_f"] call _assert;

  private _crossSlotStateE = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
  _crossSlotStateE set ["selectedCatalogClass","hgun_P07_F"];
  _crossSlotStateE set ["selectedCatalogKind","WEAPON"];
  missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_crossSlotStateE];
  private _crossSlotE = [] call ServoPeregrino_Organizador_Weapons_fnc_applyCatalogSelectionToDraft;
  ["0.6-F R6 direct draft accepts weapon from another internal slot",_crossSlotE getOrDefault ["success",false]] call _assert;
  private _crossSlotStateAfterE = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
  private _crossSlotDraftE = ((_crossSlotStateAfterE getOrDefault ["draftsByKitId",createHashMap]) getOrDefault [_authoringKitIdE,createHashMap]);
  private _crossSlotRecipeE = _crossSlotDraftE getOrDefault ["recipe",createHashMap];
  private _crossSlotCfgE = _crossSlotRecipeE getOrDefault ["configuration",createHashMap];
  ["0.6-F R6 cross-slot replacement updates internal slot and weapon",
   (_crossSlotDraftE getOrDefault ["targetSlot",""]) isEqualTo "HANDGUN"
   && {(toLowerANSI (_crossSlotCfgE getOrDefault ["weaponClass",""])) isEqualTo "hgun_p07_f"}
  ] call _assert;

  private _saveNameE = format ["AUTO R5 Saved %1",floor (diag_tickTime * 1000)];
  (_display06A displayCtrl 2001) ctrlSetText _saveNameE;
  ["SAVE_DRAFT"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
  private _savedRE = [_authoringKitIdE] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponKit;
  private _savedKitE = if (_savedRE get "success") then {(_savedRE get "data") get "kit"} else {createHashMap};
  private _savedCfgE = (_savedKitE getOrDefault ["recipe",createHashMap]) getOrDefault ["configuration",createHashMap];
  private _savedStateE = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
  private _savedDraftE = ((_savedStateE getOrDefault ["draftsByKitId",createHashMap]) getOrDefault [_authoringKitIdE,createHashMap]);
  ["0.6-F R6 SALVAR commits inline name",(_savedKitE getOrDefault ["name",""]) isEqualTo _saveNameE] call _assert;
  ["0.6-F R6 SALVAR persists dynamic draft weapon",(toLowerANSI (_savedCfgE getOrDefault ["weaponClass",""])) isEqualTo "hgun_p07_f"] call _assert;
  ["0.6-F R6 SALVAR marks draft clean and exits NOVO",!(_savedDraftE getOrDefault ["dirty",true]) && {!(_savedStateE getOrDefault ["selectedKitIsNew",true])}] call _assert;

  private _repoBeforePublishE = [] call ServoPeregrino_Organizador_Weapons_fnc_listWeaponKits;
  private _loadoutBeforePublishE = getUnitLoadout player;
  ["PUBLISH_KIT"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
  private _repoAfterPublishE = [] call ServoPeregrino_Organizador_Weapons_fnc_listWeaponKits;
  ["0.6-E R2 PUBLICAR reserved without repository mutation",
   _repoBeforePublishE get "success"
   && {_repoAfterPublishE get "success"}
   && {(((_repoBeforePublishE get "data") get "kits") isEqualTo (((_repoAfterPublishE get "data") get "kits")))}
  ] call _assert;
  ["0.6-E R2 PUBLICAR does not mutate loadout",_loadoutBeforePublishE isEqualTo (getUnitLoadout player)] call _assert;

  private _loadoutBeforeRightE = getUnitLoadout player;
  ["CATALOG_TO_EQUIPMENT"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
  ["0.6-E R2 right/catalog physical action remains non-mutating",_loadoutBeforeRightE isEqualTo (getUnitLoadout player)] call _assert;

  private _stateBeforeDupE = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
  _stateBeforeDupE set ["selectedKitId",_authoringKitIdE];
  missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_stateBeforeDupE];
  ["DUPLICATE_KIT"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
  private _dupStateE = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
  private _dupIdE = _dupStateE getOrDefault ["selectedKitId",""];
  private _dupRE = [_dupIdE] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponKit;
  ["0.6-E R2 DUPLICAR creates fresh kit identity",_dupIdE isNotEqualTo "" && {_dupIdE isNotEqualTo _authoringKitIdE} && {_dupRE get "success"}] call _assert;
  if (_dupRE get "success" && {_savedRE get "success"}) then {
   private _cmpDupE = [(((_dupRE get "data") get "kit") get "recipe"),_savedKitE get "recipe"] call ServoPeregrino_Organizador_Weapons_fnc_compareWeaponRecipes;
   ["0.6-E R2 DUPLICAR copies saved Recipe",_cmpDupE get "success" && {((_cmpDupE get "data") getOrDefault ["equal",false])}] call _assert;
  };
  if (_dupIdE isNotEqualTo "") then {
   ["DELETE_KIT"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
   ["0.6-E R2 EXCLUIR removes duplicated kit",!(([_dupIdE] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponKit) get "success")] call _assert;
  };

  private _stateBeforeSaveAsE = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
  _stateBeforeSaveAsE set ["selectedKitId",_authoringKitIdE];
  _stateBeforeSaveAsE set ["selectedCatalogClass","arifle_MX_F"];
  _stateBeforeSaveAsE set ["selectedCatalogKind","WEAPON"];
  missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_stateBeforeSaveAsE];
  ["CATALOG_TO_DRAFT"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
  private _saveAsNameE = format ["AUTO R2 SaveAs %1",floor (diag_tickTime * 1000)];
  (_display06A displayCtrl 2001) ctrlSetText _saveAsNameE;
  ["SAVE_AS_NEW"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
  private _saveAsStateE = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
  private _saveAsIdE = _saveAsStateE getOrDefault ["selectedKitId",""];
  private _saveAsRE = [_saveAsIdE] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponKit;
  ["0.6-E R2 SALVAR COMO NOVO creates new identity",_saveAsIdE isNotEqualTo "" && {_saveAsIdE isNotEqualTo _authoringKitIdE} && {_saveAsRE get "success"}] call _assert;
  if (_saveAsRE get "success") then {
   private _saveAsKitE = (_saveAsRE get "data") get "kit";
   private _saveAsCfgE = (_saveAsKitE get "recipe") get "configuration";
   ["0.6-E R2 SALVAR COMO NOVO commits typed name",(_saveAsKitE getOrDefault ["name",""]) isEqualTo _saveAsNameE] call _assert;
   ["0.6-E R2 SALVAR COMO NOVO uses current draft Recipe",(toLowerANSI (_saveAsCfgE getOrDefault ["weaponClass",""])) isEqualTo "arifle_mx_f"] call _assert;
  };
  private _sourceAfterSaveAsE = [_authoringKitIdE] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponKit;
  private _sourceAfterSaveAsKitE = if (_sourceAfterSaveAsE get "success") then {((_sourceAfterSaveAsE get "data") get "kit")} else {createHashMap};
  private _sourceSaveAsCmpE = if (_sourceAfterSaveAsE get "success") then {
   [(_sourceAfterSaveAsKitE getOrDefault ["recipe",createHashMap]),(_savedKitE getOrDefault ["recipe",createHashMap])] call ServoPeregrino_Organizador_Weapons_fnc_compareWeaponRecipes
  } else {createHashMap};
  ["0.6-F R6 SALVAR COMO NOVO leaves the already-saved source definition unchanged",
   (_sourceAfterSaveAsE getOrDefault ["success",false])
   && {(_sourceSaveAsCmpE getOrDefault ["success",false])}
   && {(((_sourceSaveAsCmpE get "data") getOrDefault ["equal",false]))}
   && {(_sourceAfterSaveAsKitE getOrDefault ["targetSlot",""]) isEqualTo (_savedKitE getOrDefault ["targetSlot",""])}
  ] call _assert;

  if (_saveAsIdE isNotEqualTo "") then {
   ["DELETE_KIT"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
   ["0.6-E R2 EXCLUIR removes save-as kit",!(([_saveAsIdE] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponKit) get "success")] call _assert;
  };
  private _stateDeleteSourceE = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
  _stateDeleteSourceE set ["selectedKitId",_authoringKitIdE];
  missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_stateDeleteSourceE];
  ["DELETE_KIT"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
  ["0.6-E R2 EXCLUIR removes source authoring kit",!(([_authoringKitIdE] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponKit) get "success")] call _assert;
 };

 private _beforePendingDiscardE = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
 private _expectedRestoreKitIdE = _beforePendingDiscardE getOrDefault ["selectedKitId",""];
 ["NEW_KIT"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
 private _pendingBeforeDiscardE = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
 ["0.6-F R3 NOVO remembers previous selected kit for cancel",
  (_pendingBeforeDiscardE getOrDefault ["previousKitIdBeforeNew",""]) isEqualTo _expectedRestoreKitIdE
 ] call _assert;
 ["DRAFT_DISCARD"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
 private _afterPendingDiscardE = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
 ["0.6-F R3 DESCARTAR cancels pending-new without creating kit",
  !(_afterPendingDiscardE getOrDefault ["pendingNewKit",true])
 ] call _assert;
 ["0.6-F R3 DESCARTAR restores the kit selected before NOVO",
  (_afterPendingDiscardE getOrDefault ["selectedKitId",""]) isEqualTo _expectedRestoreKitIdE
 ] call _assert;
 ["0.6-F R3 DESCARTAR clears temporary restore context",
  (_afterPendingDiscardE getOrDefault ["previousKitIdBeforeNew",""]) isEqualTo ""
 ] call _assert;

 private _authoringRepoAfterCleanupE = [] call ServoPeregrino_Organizador_Weapons_fnc_listWeaponKits;
 ["0.6-E R2 authoring cleanup restores repository",
  _authoringRepoBeforeE get "success"
  && {_authoringRepoAfterCleanupE get "success"}
  && {(((_authoringRepoBeforeE get "data") get "kits") isEqualTo (((_authoringRepoAfterCleanupE get "data") get "kits")))}
 ] call _assert;
 ["0.6-E R2 authoring lifecycle never mutates physical loadout",_authoringLoadoutBeforeE isEqualTo (getUnitLoadout player)] call _assert;

 private _restoreBaselineStateE = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
 _restoreBaselineStateE set ["selectedKitId",_kitAId];
 _restoreBaselineStateE set ["pendingNewKit",false];
 _restoreBaselineStateE set ["pendingNewName",""];
 _restoreBaselineStateE set ["selectedKitIsNew",false];
 _restoreBaselineStateE set ["kitQuery",""];
 _restoreBaselineStateE set ["kitTypeFilter","ALL"];
 _restoreBaselineStateE set ["catalogQuery",""];
 missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_restoreBaselineStateE];
 [] call ServoPeregrino_Organizador_Weapons_fnc_refreshInterface;

 private _repoAfterInfo06B = [] call ServoPeregrino_Organizador_Weapons_fnc_listWeaponKits;
 ["0.6-B selection/info does not mutate WeaponKit repository",
  _repoBeforeInfo06B get "success"
  && {_repoAfterInfo06B get "success"}
  && {(((_repoBeforeInfo06B get "data") get "kits") isEqualTo (((_repoAfterInfo06B get "data") get "kits")))}
 ] call _assert;
 ["0.6-B selection/info does not mutate loadout",_loadoutBeforeInfo06B isEqualTo (getUnitLoadout player)] call _assert;

 // Reset catalog projection for remaining shell regression checks.
 ["CATALOG_SEARCH",""] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
 ["CATALOG_TYPE","ALL"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
 ["CATALOG_CATEGORY","ALL"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;

 // UI-only feedback actions must not edit WeaponKit or player inventory.
 ["UI_DEFERRED","SALVAR"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
 private _refreshStartedR4 = diag_tickTime;
 private _refresh06A = [] call ServoPeregrino_Organizador_Weapons_fnc_refreshInterface;
 private _refreshElapsedR4 = round ((diag_tickTime - _refreshStartedR4) * 1000);
 ["0.6-A refresh succeeds",_refresh06A get "success"] call _assert;
 ["0.6-A R4 refresh returns without recursive lock",_refreshElapsedR4 < 10000] call _assert;

 private _stateAfterRefreshR4 = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
 ["0.6-A R4 refresh guard released",
  !(_stateAfterRefreshR4 getOrDefault ["refreshInProgress",true])
 ] call _assert;
 ["0.6-A R4 refresh applied count bounded",
  (_stateAfterRefreshR4 getOrDefault ["refreshAppliedCount",0])
  <= ((_stateAfterRefreshR4 getOrDefault ["refreshRequestCount",0]) max 1)
 ] call _assert;
 diag_log format [
  "[SP_ORG] [WEAPONS] [AUTO_TEST_DETAIL] test=UI_REFRESH_GUARD_0_6_D_R3 elapsedMs=%1 requests=%2 applied=%3 kitFilter=%4 catalogFilter=%5",
  _refreshElapsedR4,
  _stateAfterRefreshR4 getOrDefault ["refreshRequestCount",0],
  _stateAfterRefreshR4 getOrDefault ["refreshAppliedCount",0],
  _stateAfterRefreshR4 getOrDefault ["kitTypeFilter",""],
  _stateAfterRefreshR4 getOrDefault ["catalogTypeFilter",""]
 ];
};

private _kitsAfterUI06A = [] call ServoPeregrino_Organizador_Weapons_fnc_listWeaponKits;
private _loadoutAfterUI06A = getUnitLoadout player;
["0.6-A UI shell does not mutate WeaponKit repository",
 _kitsBeforeUI06A get "success"
 && {_kitsAfterUI06A get "success"}
 && {(((_kitsBeforeUI06A get "data") get "kits") isEqualTo (((_kitsAfterUI06A get "data") get "kits")))}
] call _assert;
["0.6-A UI shell does not mutate engine loadout",_loadoutBeforeUI06A isEqualTo _loadoutAfterUI06A] call _assert;

// P2 and P4 preview/name/class are intentionally aligned vertically for future 3D-preview convergence.
if (!isNull (findDisplay SP_ORG_WEAPONS_UI_DISPLAY_IDD)) then {
 private _displayF2 = findDisplay SP_ORG_WEAPONS_UI_DISPLAY_IDD;
 private _p2Pic = ctrlPosition (_displayF2 displayCtrl 2010);
 private _p4Pic = ctrlPosition (_displayF2 displayCtrl 4020);
 private _p2Name = ctrlPosition (_displayF2 displayCtrl 2021);
 private _p4Name = ctrlPosition (_displayF2 displayCtrl 4021);
 private _p2Class = ctrlPosition (_displayF2 displayCtrl 2032);
 private _p4Class = ctrlPosition (_displayF2 displayCtrl 4022);
 ["0.6-F R3 P2/P4 preview vertical alignment",abs ((_p2Pic#1)-(_p4Pic#1)) < (0.002*safeZoneH)] call _assert;
 ["0.6-F R3 P2/P4 name vertical alignment",abs ((_p2Name#1)-(_p4Name#1)) < (0.002*safeZoneH)] call _assert;
 ["0.6-F R3 P2/P4 class vertical alignment",abs ((_p2Class#1)-(_p4Class#1)) < (0.002*safeZoneH)] call _assert;
 ["0.6-F R3 changed-row background controls present",{!isNull (_displayF2 displayCtrl _x)} count [2060,2061,2062,2063,2064,2065] isEqualTo 6] call _assert;
};

// R3 proved the dialog closes, but findDisplay stayed alive until onUnload on the next UI frame.
// R4 executes this runner in scheduled context and waits up to 1 second for the engine to process onUnload.
private _closeStartR4 = diag_tickTime;
if (!isNull (findDisplay SP_ORG_WEAPONS_UI_DISPLAY_IDD)) then {closeDialog 0};
waitUntil {
 uiSleep 0.01;
 isNull (findDisplay SP_ORG_WEAPONS_UI_DISPLAY_IDD)
 || {(diag_tickTime - _closeStartR4) >= 1}
};
private _closeElapsedR4 = round ((diag_tickTime - _closeStartR4) * 1000);
private _closedR4 = isNull (findDisplay SP_ORG_WEAPONS_UI_DISPLAY_IDD);
["0.6-A R4 interface closes after onUnload frame",_closedR4] call _assert;
private _stateAfterCloseR4 = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
["0.6-A R4 UI state marks closed after onUnload",
 _closedR4 && {!(_stateAfterCloseR4 getOrDefault ["open",true])}
] call _assert;
diag_log format [
 "[SP_ORG] [WEAPONS] [AUTO_TEST_DETAIL] test=UI_CLOSE_TIMING_R4 elapsedMs=%1 closed=%2 stateOpen=%3",
 _closeElapsedR4,_closedR4,_stateAfterCloseR4 getOrDefault ["open",true]
];

// 0.6-F R3 — per-field diff model used by ARMAS DO KIT amber highlighting.
private _diffBaseCfgR = ["arifle_MX_F"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponConfiguration;
private _diffBaseRecipeR = [(_diffBaseCfgR get "data") get "configuration","30Rnd_65x39_caseless_mag"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponRecipe;
private _diffBaseRecipe = (_diffBaseRecipeR get "data") get "recipe";
private _diffCurrentRecipe = [_diffBaseRecipe] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
private _diffCfg = [_diffCurrentRecipe get "configuration"] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
_diffCfg set ["optic","optic_Aco"];
_diffCurrentRecipe set ["configuration",_diffCfg];
private _diffDraft = createHashMapFromArray [["baseRecipe",[_diffBaseRecipe] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],["recipe",_diffCurrentRecipe]];
private _diffR = [_diffDraft] call ServoPeregrino_Organizador_Weapons_fnc_getDraftChangedFields;
private _diffData = _diffR getOrDefault ["data",createHashMap];
private _diffMap = _diffData getOrDefault ["changed",createHashMap];
["0.6-F R3 diff helper detects changed optic",_diffR getOrDefault ["success",false] && {_diffMap getOrDefault ["optic",false]} && {!(_diffMap getOrDefault ["weaponClass",true])}] call _assert;
_diffCurrentRecipe set ["configuration",[_diffBaseRecipe get "configuration"] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy];
_diffDraft set ["recipe",_diffCurrentRecipe];
private _diffRevertedR = [_diffDraft] call ServoPeregrino_Organizador_Weapons_fnc_getDraftChangedFields;
["0.6-F R3 diff helper clears highlight when value returns to base",((_diffRevertedR get "data") getOrDefault ["count",-1]) isEqualTo 0] call _assert;

// 0.6-F R3 — independent searches, global Catalog query, and stable blank name editing.
private _stateR3 = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
_stateR3 set ["draftQuery",""];
_stateR3 set ["catalogQuery",""];
_stateR3 set ["equipmentQuery",""];
_stateR3 set ["catalogTypeFilter","PRIMARY"];
_stateR3 set ["catalogCategoryFilter","OPTIC"];
missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_stateR3];

["P2_SEARCH","mira"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
private _afterP2R3 = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
["0.6-F R3 P2 search is local",(_afterP2R3 getOrDefault ["draftQuery",""]) isEqualTo "mira" && {(_afterP2R3 getOrDefault ["catalogQuery",""]) isEqualTo ""} && {(_afterP2R3 getOrDefault ["equipmentQuery",""]) isEqualTo ""}] call _assert;

["P4_SEARCH","laser"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
private _afterP4R3 = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
["0.6-F R3 P4 search is local",(_afterP4R3 getOrDefault ["draftQuery",""]) isEqualTo "mira" && {(_afterP4R3 getOrDefault ["catalogQuery",""]) isEqualTo ""} && {(_afterP4R3 getOrDefault ["equipmentQuery",""]) isEqualTo "laser"}] call _assert;

["CATALOG_SEARCH","mx"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
private _afterCatalogSearchR3 = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
["0.6-F R3 Catalog search does not overwrite P2/P4",(_afterCatalogSearchR3 getOrDefault ["catalogQuery",""]) isEqualTo "mx" && {(_afterCatalogSearchR3 getOrDefault ["draftQuery",""]) isEqualTo "mira"} && {(_afterCatalogSearchR3 getOrDefault ["equipmentQuery",""]) isEqualTo "laser"}] call _assert;

private _globalWindowR3 = [] call ServoPeregrino_Organizador_Weapons_fnc_getUICatalogWindow;
private _globalDataR3 = _globalWindowR3 getOrDefault ["data",createHashMap];
["0.6-F R3 Catalog text search ignores stored filters",_globalWindowR3 getOrDefault ["success",false] && {_globalDataR3 getOrDefault ["filtersIgnoredBySearch",false]} && {(_globalDataR3 getOrDefault ["storedTypeFilter",""]) isEqualTo "PRIMARY"} && {(_globalDataR3 getOrDefault ["storedCategoryFilter",""]) isEqualTo "OPTIC"} && {(_globalDataR3 getOrDefault ["effectiveTypeFilter",""]) isEqualTo "ALL"} && {(_globalDataR3 getOrDefault ["effectiveCategoryFilter",""]) isEqualTo "ALL"}] call _assert;

["CATALOG_SEARCH",""] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
private _filteredWindowR3 = [] call ServoPeregrino_Organizador_Weapons_fnc_getUICatalogWindow;
private _filteredDataR3 = _filteredWindowR3 getOrDefault ["data",createHashMap];
["0.6-F R3 clearing Catalog search restores stored filters",_filteredWindowR3 getOrDefault ["success",false] && {!(_filteredDataR3 getOrDefault ["filtersIgnoredBySearch",true])} && {(_filteredDataR3 getOrDefault ["effectiveTypeFilter",""]) isEqualTo "PRIMARY"} && {(_filteredDataR3 getOrDefault ["effectiveCategoryFilter",""]) isEqualTo "OPTIC"}] call _assert;

// Name field must be allowed to become temporarily blank while editing.
private _nameEditOpenR3 = [] call ServoPeregrino_Organizador_Weapons_fnc_openInterface;
if (_nameEditOpenR3 getOrDefault ["success",false]) then {
 uiSleep 0.05;
 private _displayNameR3 = findDisplay SP_ORG_WEAPONS_UI_DISPLAY_IDD;
 private _stateNameR3 = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
 private _kitsNameR3 = [] call ServoPeregrino_Organizador_Weapons_fnc_listWeaponKits;
 private _kitRowsNameR3 = if (_kitsNameR3 getOrDefault ["success",false]) then {((_kitsNameR3 get "data") getOrDefault ["kits",[]])} else {[]};
 if (!isNull _displayNameR3 && {(count _kitRowsNameR3)>0}) then {
  private _kitIdNameR3 = (_kitRowsNameR3#0) getOrDefault ["kitId",""];
  _stateNameR3 set ["selectedKitId",_kitIdNameR3];
  _stateNameR3 set ["pendingNewKit",false];
  _stateNameR3 set ["draftNameEditing",false];
  _stateNameR3 set ["draftNameInput",""];
  missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_stateNameR3];
  ["FULL"] call ServoPeregrino_Organizador_Weapons_fnc_refreshDraftUI;
  ["DRAFT_NAME_INPUT",""] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
  uiSleep 0.01;
  ["TEST_NAME_BLANK"] call ServoPeregrino_Organizador_Weapons_fnc_refreshDraftUI;
  ["0.6-F R3 inline name may remain blank during editing",(ctrlText (_displayNameR3 displayCtrl 2001)) isEqualTo ""] call _assert;
  private _stateBlankR3 = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
  ["0.6-F R3 blank name keeps editing state",_stateBlankR3 getOrDefault ["draftNameEditing",false] && {(_stateBlankR3 getOrDefault ["draftNameInput","x"]) isEqualTo ""}] call _assert;
 };
 closeDialog 0;
 uiSleep 0.05;
};

private _runtime06A = [] call ServoPeregrino_Organizador_Weapons_fnc_getRuntimeStatus;
["Runtime checkpoint label",((_runtime06A get "data") getOrDefault ["uiCheckpoint",""])] call _observe;
["0.6-D R3 runtime information convergence marker",((_runtime06A get "data") getOrDefault ["uiInformationMode",""]) isEqualTo "DRAFT_PLUS_CATALOG_PLUS_EQUIPMENT_PRESENTATION"] call _assert;
["Runtime UI revision label",((_runtime06A get "data") getOrDefault ["uiRevision",""])] call _observe;
["0.6-D R3 runtime four-panel layout marker",((_runtime06A get "data") getOrDefault ["uiLayout",""]) isEqualTo "FOUR_PANEL_ITEMS_CONVERGENCE"] call _assert;
["0.6-D R3 runtime continuous catalog marker",((_runtime06A get "data") getOrDefault ["uiCatalogMode",""]) isEqualTo "CONTINUOUS_WINDOW_VISIBLE_SLIDER_FOCUSED_REFRESH"] call _assert;
["0.6-D R3 runtime equipment read-only marker",((_runtime06A get "data") getOrDefault ["uiEquipmentView",""]) isEqualTo "READ_ONLY_CURRENT_WEAPON"] call _assert;
["0.6-D runtime compatibility mode marker",((_runtime06A get "data") getOrDefault ["uiCompatibilityMode",""]) isEqualTo "DRAFT_EDITABLE_COMPATIBILITY_SELECTORS"] call _assert;
["0.6-D runtime draft active",((_runtime06A get "data") getOrDefault ["uiDraft",""]) isEqualTo "LOCAL_WEAPONKIT_DRAFT_WITH_AUTHORING_CANDIDATE"] call _assert;
["0.6-E R2 runtime direct authoring enabled",((_runtime06A get "data") getOrDefault ["uiAuthoring",""]) isEqualTo "SESSION_LOCAL_DIRECT_CATALOG_TO_DRAFT_0_6_E_R2"] call _assert;
["0.6-E R2 UICommon dependency marker",((_runtime06A get "data") getOrDefault ["uiCommonRequired",false])] call _assert;
["0.6-E R2 direct-draft marker",((_runtime06A get "data") getOrDefault ["uiDirectDraftEquip",false])] call _assert;
["Runtime visual-freeze label",((_runtime06A get "data") getOrDefault ["uiVisualFreeze",""])] call _observe;

["0.6-F R3 runtime changed-row diff marker",((_runtime06A get "data") getOrDefault ["uiDraftDiffHighlight",""]) isEqualTo "BASE_RECIPE_FIELD_DIFF_AMBER"] call _assert;
["0.6-F R4 runtime preview-ready layout marker",((_runtime06A get "data") getOrDefault ["uiDraftPreviewLayout",""]) isEqualTo "EQUIPMENT_MIRRORED_KEEP_ASPECT_PREVIEW_READY"] call _assert;
["0.6-F R3 runtime search isolation marker",((_runtime06A get "data") getOrDefault ["uiSearchMode",""]) isEqualTo "INDEPENDENT_P2_P3_P4"] call _assert;
["0.6-F R3 runtime global Catalog search marker",((_runtime06A get "data") getOrDefault ["uiCatalogSearchMode",""]) isEqualTo "GLOBAL_QUERY_IGNORES_STORED_FILTERS"] call _assert;
["0.6-F R3 runtime inline-name edit marker",((_runtime06A get "data") getOrDefault ["uiNameEditingMode",""]) isEqualTo "EMPTY_ALLOWED_UNTIL_SAVE"] call _assert;
["0.6-F R4 runtime keep-aspect preview marker",((_runtime06A get "data") getOrDefault ["uiPreviewScaleMode",""]) isEqualTo "KEEP_ASPECT_CENTERED_2D"] call _assert;
["Runtime Catalog filter grammar label",((_runtime06A get "data") getOrDefault ["uiCatalogFilterGrammar",""])] call _observe;

private _displayR4 = findDisplay SP_ORG_WEAPONS_UI_DISPLAY_IDD;
if (!isNull _displayR4) then {
 private _typeWidthsR4 = [3111,3112,3113,3114] apply {(ctrlPosition (_displayR4 displayCtrl _x)) # 2};
 private _kindWidthsR4 = [3132,3133,3134,3135,3136,3137,3138] apply {(ctrlPosition (_displayR4 displayCtrl _x)) # 2};
 ["0.6-F R4 Catalog type buttons use uniform width",({_x isEqualTo (_typeWidthsR4#0)} count _typeWidthsR4) isEqualTo count _typeWidthsR4] call _assert;
 ["0.6-F R4 Catalog accessory buttons use uniform width",({_x isEqualTo (_kindWidthsR4#0)} count _kindWidthsR4) isEqualTo count _kindWidthsR4] call _assert;
 ["0.6-F R4 Catalog accessory labels use compact grammar",
  (ctrlText (_displayR4 displayCtrl 3132)) isEqualTo "TODOS"
  && {(ctrlText (_displayR4 displayCtrl 3133)) isEqualTo "ARMA"}
  && {(ctrlText (_displayR4 displayCtrl 3134)) isEqualTo "ÓTICA"}
  && {(ctrlText (_displayR4 displayCtrl 3135)) isEqualTo "APONT."}
  && {(ctrlText (_displayR4 displayCtrl 3136)) isEqualTo "BIPÉ"}
  && {(ctrlText (_displayR4 displayCtrl 3137)) isEqualTo "CARREG."}
  && {(ctrlText (_displayR4 displayCtrl 3138)) isEqualTo "EMPUNH."}
 ] call _assert;
};

["0.6-F R6 runtime auto-create marker",((_runtime06A get "data") getOrDefault ["uiDraftAutoCreate",""]) isEqualTo "WEAPON_FROM_CATALOG_WHEN_NO_KIT"] call _assert;
["0.6-F R6 runtime slot visibility internal-only",((_runtime06A get "data") getOrDefault ["uiDraftSlotVisibility",""]) isEqualTo "INTERNAL_ONLY"] call _assert;
["0.6-F R6 runtime friendly feedback marker",((_runtime06A get "data") getOrDefault ["uiPlayerFeedback",""]) isEqualTo "FRIENDLY_NO_INTERNAL_CODES"] call _assert;
["0.6-F R6 runtime dynamic weapon editing marker",((_runtime06A get "data") getOrDefault ["uiWeaponBaseEditing",""]) isEqualTo "ANY_SUPPORTED_WEAPON_DYNAMIC_INTERNAL_SLOT"] call _assert;

private _r5CfgMx = ["arifle_MX_F"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponConfiguration;
private _r5RecipeMx = [(_r5CfgMx get "data") get "configuration",""] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponRecipe;
private _r5UniqueNameR = ["R5 Dynamic Slot Test"] call ServoPeregrino_Organizador_Weapons_fnc_getUniqueWeaponKitName;
private _r5KitCreate = [((_r5UniqueNameR get "data") get "name"),"PRIMARY",(_r5RecipeMx get "data") get "recipe"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponKit;
if (_r5KitCreate getOrDefault ["success",false]) then {
 private _r5KitId = ((_r5KitCreate get "data") get "kit") get "kitId";
 [_r5KitId] call ServoPeregrino_Organizador_Weapons_fnc_getOrCreateWeaponKitDraft;
 private _r5Swap = [_r5KitId,"hgun_P07_F"] call ServoPeregrino_Organizador_Weapons_fnc_setWeaponKitDraftWeapon;
 ["0.6-F R6 draft accepts another supported weapon category",_r5Swap getOrDefault ["success",false]] call _assert;
 private _r5SwapDraft = ((_r5Swap getOrDefault ["data",createHashMap]) getOrDefault ["draft",createHashMap]);
 ["0.6-F R6 cross-category swap updates internal slot",(_r5SwapDraft getOrDefault ["targetSlot",""]) isEqualTo "HANDGUN"] call _assert;
 private _r5Save = [_r5KitId] call ServoPeregrino_Organizador_Weapons_fnc_saveWeaponKitDraft;
 ["0.6-F R6 dynamic slot+recipe save is atomic",_r5Save getOrDefault ["success",false] && {((((_r5Save get "data") get "kit") getOrDefault ["targetSlot",""]) isEqualTo "HANDGUN")}] call _assert;
};

private _r5State = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
_r5State set ["selectedKitId",""];
_r5State set ["pendingNewKit",false];
_r5State set ["pendingNewName",""];
_r5State set ["selectedCatalogClass","arifle_MX_F"];
_r5State set ["selectedCatalogKind","WEAPON"];
missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_r5State];
private _r5Auto = [""] call ServoPeregrino_Organizador_Weapons_fnc_applyCatalogSelectionToDraft;
["0.6-F R6 Catalog weapon auto-creates draft kit when none selected",_r5Auto getOrDefault ["success",false] && {(_r5Auto getOrDefault ["code",""]) isEqualTo "WEAPONS_UI_DRAFT_AUTO_CREATED"}] call _assert;
private _r5StateAfterAuto = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
["0.6-F R6 auto-created kit becomes selected and NOVO",(_r5StateAfterAuto getOrDefault ["selectedKitId",""]) isNotEqualTo "" && {_r5StateAfterAuto getOrDefault ["selectedKitIsNew",false]}] call _assert;

["0.6-A runtime application still deferred",((_runtime06A get "data") getOrDefault ["kitApplication",""]) isEqualTo "DEFERRED_0_7"] call _assert;


} else {
 diag_log "[SP_ORG] [WEAPONS] [AUTO_TEST_DETAIL] test=UI_BLOCK_0_6_D_R3 status=SKIPPED reason=MISSING_UI_FUNCTIONS";
};

private _passed = {_x select 1} count _checks;
private _failed = count _checks - _passed;
diag_log format ["[SP_ORG] [WEAPONS] [AUTO_TEST_SUMMARY] mode=MISSION_FIRST_0_6_F_R6 passed=%1 failed=%2 total=%3 observations=%4 | UI_SCOPE=UX_CONVERGENCE_DIRECT_DRAFT_EQUIP_UICOMMON | DRAFT_MODE=LOCAL_SESSION_DIRECT_CATALOG_TO_DRAFT | AUTHORING_GATE=SESSION_LOCAL_DIRECT_CATALOG_TO_DRAFT_0_6_E_R2 | APPLICATION_GATE=DEFERRED_0_7 | MP_GATE=DEFERRED_0_8 | IDENTITY_MANUAL_GATE=OPEN | PBO_GATE=DEFERRED",_passed,_failed,count _checks,count _observations];
hint format ["Weapons 0.6-F R6 AUTO TEST: %1/%2; falhas=%3. Depois abra a UI e valide Novo -> Catálogo -> EQUIPAR NO RASCUNHO, nome inline + Salvar, Duplicar/Excluir/Publicar reservado e fluidez; nada deve equipar fisicamente.",_passed,count _checks,_failed];

[_failed isEqualTo 0,"WEAPONS_AUTO_TEST_COMPLETE","0.6-F R6 validates the R5 dynamic-authoring behavior plus compact Tipo/Acessório filter spacing and corrected regression contracts: keep-aspect previews, uniform Catalog filter grammar, independent panel searches, global Catalog text search, stable inline-name editing, semantic changed-row highlighting, P2/P4 preview-ready alignment, NOVO cancel restore and direct Catalog-to-Draft authoring and the homologated R3 focused-refresh baseline. Physical application remains a 0.7 gate and multiplayer authority remains 0.8.",createHashMapFromArray [
 ["passed",_passed],["failed",_failed],["checks",_checks],["observations",_observations],
 ["uiScope","UX_CONVERGENCE_DIRECT_DRAFT_EQUIP_UICOMMON"],
 ["informationMode","DRAFT_PLUS_CATALOG_PLUS_EQUIPMENT_PRESENTATION"],
 ["compatibilityMode","DRAFT_EDITABLE_COMPATIBILITY_SELECTORS"],
 ["draftMode","LOCAL_WEAPONKIT_DRAFT_WITH_AUTHORING_CANDIDATE"],
 ["authoringGate","SESSION_LOCAL_DIRECT_CATALOG_TO_DRAFT_0_6_E_R2"],
 ["applicationGate","DEFERRED_0_7"],
 ["mpGate","DEFERRED_0_8"],
 ["pboGate","DEFERRED"],
 ["executionMode","MISSION_FIRST"]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
