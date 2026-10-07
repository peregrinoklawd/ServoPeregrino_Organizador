#include "..\..\script_version.hpp"
if (!isServer || {isRemoteExecuted} || {!(missionNamespace getVariable ["SP_ORG_Weapons_LabEnabled",false])}) exitWith {
 [false,"WEAPONS_TEST_SERVER_LAB_ONLY","Run locally on mission-first lab server/host."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _legacy = [] call ServoPeregrino_Organizador_Weapons_fnc_runDelivery0_7_ATests;
private _legacyData = _legacy getOrDefault ["data",createHashMap];
private _legacyPassed = _legacyData getOrDefault ["passed",0];
private _legacyFailed = _legacyData getOrDefault ["failed",1];
private _legacyObservations = _legacyData getOrDefault ["legacyObservations",[]];

private _checks = [];
private _assert = {
 params [
  ["_name","UNNAMED_CHECK",[""]],
  ["_ok",false,[false]]
 ];
 _checks pushBack [_name,_ok];
 diag_log format ["[SP_ORG] [WEAPONS] [AUTO_TEST] mode=MISSION_FIRST_0_7_B %1 | %2",if (_ok) then {"PASS"} else {"FAIL"},_name];
};

["0.7-A frozen baseline remains green",_legacy getOrDefault ["success",false] && {_legacyPassed isEqualTo 673} && {_legacyFailed isEqualTo 0}] call _assert;
["0.7-B buildApplicationTargetLoadout loaded",!isNil "ServoPeregrino_Organizador_Weapons_fnc_buildApplicationTargetLoadout"] call _assert;
["0.7-B validateAppliedApplicationState loaded",!isNil "ServoPeregrino_Organizador_Weapons_fnc_validateAppliedApplicationState"] call _assert;
["0.7-B applyApplicationPlan loaded",!isNil "ServoPeregrino_Organizador_Weapons_fnc_applyApplicationPlan"] call _assert;

private _group = createGroup [west,true];
private _unit = _group createUnit ["B_Soldier_F",getPosATL player,[],0,"NONE"];
["0.7-B isolated test unit created",!isNull _unit && {_unit isKindOf "CAManBase"}] call _assert;
["0.7-B isolated test unit is local",!isNull _unit && {local _unit}] call _assert;

if (isNull _unit || {!local _unit}) exitWith {
 if (!isNull _unit) then {deleteVehicle _unit};
 if (!isNull _group) then {deleteGroup _group};
 [false,"WEAPONS_0_7_B_TEST_TARGET_MISSING","Could not create a local isolated infantry unit for physical mutation tests."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

_unit allowDamage false;
_unit hideObject true;
_unit enableSimulation false;

private _baseUnitLoadout = [getUnitLoadout _unit] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
private _baseAnimSpeed = getAnimSpeedCoef _unit;
private _scenarioResults = [];

private _cleanupKit = {
 params ["_kitId"];
 if !(_kitId isEqualTo "") then {
  [_kitId] call ServoPeregrino_Organizador_Weapons_fnc_deleteWeaponKit;
 };
};

private _runScenario = {
 params [
  ["_label","",[""]],
  ["_slot","PRIMARY",[""]],
  ["_baselineRow",[],[[]]],
  ["_desiredWeapon","",[""]],
  ["_desiredMagazine","",[""]],
  ["_desiredField","",[""]],
  ["_desiredFieldValue","",[""]],
  ["_expectedOperation","",[""]],
  ["_expectedMutation",true,[false]],
  ["_expectedAmmoPolicy","",[""]]
 ];

 private _slotIndex = ["PRIMARY","SECONDARY","HANDGUN"] find _slot;
 private _baselineLoadout = [_baseUnitLoadout] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 _baselineLoadout set [_slotIndex,[_baselineRow] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy];
 _unit setUnitLoadout [_baselineLoadout,false];
 _unit setAnimSpeedCoef _baseAnimSpeed;

 private _baselineObserved = [getUnitLoadout _unit] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 private _baselineObservedRow = [(_baselineObserved param [_slotIndex,[]])] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 private _kitId = "";

 [format ["0.7-B %1 baseline loadout shape",_label],count _baselineObserved >= 10] call _assert;

 private _cfgResult = [_desiredWeapon] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponConfiguration;
 [format ["0.7-B %1 configuration prerequisite",_label],_cfgResult getOrDefault ["success",false]] call _assert;

 if (_cfgResult getOrDefault ["success",false]) then {
  private _cfg = ((_cfgResult get "data") get "configuration");
  if !(_desiredField isEqualTo "") then {
   _cfg set [_desiredField,_desiredFieldValue];
  };

  private _cfgSemantic = [_cfg] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponConfigurationSemantic;
  [format ["0.7-B %1 desired configuration semantic",_label],_cfgSemantic getOrDefault ["success",false]] call _assert;

  if (_cfgSemantic getOrDefault ["success",false]) then {
   private _recipeResult = [_cfg,_desiredMagazine] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponRecipe;
   [format ["0.7-B %1 Recipe prerequisite",_label],_recipeResult getOrDefault ["success",false]] call _assert;

   if (_recipeResult getOrDefault ["success",false]) then {
    private _nameResult = [format ["0.7-B Apply %1",_label]] call ServoPeregrino_Organizador_Weapons_fnc_getUniqueWeaponKitName;
    [format ["0.7-B %1 unique kit name",_label],_nameResult getOrDefault ["success",false]] call _assert;

    if (_nameResult getOrDefault ["success",false]) then {
     private _kitResult = [
      ((_nameResult get "data") get "name"),
      _slot,
      ((_recipeResult get "data") get "recipe")
     ] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponKit;
     [format ["0.7-B %1 WeaponKit prerequisite",_label],_kitResult getOrDefault ["success",false]] call _assert;

     if (_kitResult getOrDefault ["success",false]) then {
      private _kit = (_kitResult get "data") get "kit";
      _kitId = _kit getOrDefault ["kitId",""];

      private _planResult = [_unit,_kit] call ServoPeregrino_Organizador_Weapons_fnc_createApplicationPlan;
      [format ["0.7-B %1 frozen 0.7-A plan creates",_label],_planResult getOrDefault ["success",false]] call _assert;

      if (_planResult getOrDefault ["success",false]) then {
       private _plan = (_planResult get "data") get "plan";
       [format ["0.7-B %1 operation=%2",_label,_expectedOperation],(_plan getOrDefault ["operation",""]) isEqualTo _expectedOperation] call _assert;
       [format ["0.7-B %1 plan schema remains frozen",_label],(_plan getOrDefault ["schemaVersion",""]) isEqualTo "0.7-A-application-plan-candidate"] call _assert;

       private _snapshotResult = [_unit,_plan] call ServoPeregrino_Organizador_Weapons_fnc_captureApplicationSnapshot;
       [format ["0.7-B %1 frozen 0.7-A snapshot captures",_label],_snapshotResult getOrDefault ["success",false]] call _assert;

       if (_snapshotResult getOrDefault ["success",false]) then {
        private _snapshot = (_snapshotResult get "data") get "snapshot";
        [format ["0.7-B %1 snapshot schema remains frozen",_label],(_snapshot getOrDefault ["schemaVersion",""]) isEqualTo "0.7-A-application-snapshot-candidate"] call _assert;

        private _build = [_plan,_snapshot] call ServoPeregrino_Organizador_Weapons_fnc_buildApplicationTargetLoadout;
        [format ["0.7-B %1 target loadout builds",_label],_build getOrDefault ["success",false]] call _assert;

        if (_build getOrDefault ["success",false]) then {
         private _buildData = _build get "data";
         [format ["0.7-B %1 ammo policy=%2",_label,_expectedAmmoPolicy],(_buildData getOrDefault ["ammoPolicy",""]) isEqualTo _expectedAmmoPolicy] call _assert;
         [format ["0.7-B %1 fullMagazines=false frozen",_label],!(_buildData getOrDefault ["fullMagazines",true])] call _assert;

         private _beforeApply = [getUnitLoadout _unit] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
         private _apply = [_unit,_plan,_snapshot] call ServoPeregrino_Organizador_Weapons_fnc_applyApplicationPlan;
         [format ["0.7-B %1 physical apply succeeds",_label],_apply getOrDefault ["success",false]] call _assert;

         if (_apply getOrDefault ["success",false]) then {
          private _applyData = _apply get "data";
          private _post = _applyData getOrDefault ["postValidation",createHashMap];
          private _afterApply = getUnitLoadout _unit;
          private _afterRow = _afterApply param [_slotIndex,[]];

          [format ["0.7-B %1 mutation flag",_label],(_applyData getOrDefault ["mutationPerformed",!_expectedMutation]) isEqualTo _expectedMutation] call _assert;
          [format ["0.7-B %1 preservation fingerprint holds",_label],_post getOrDefault ["preservationMatched",false]] call _assert;
          [format ["0.7-B %1 target configuration matches",_label],_post getOrDefault ["configurationMatched",false]] call _assert;
          [format ["0.7-B %1 primary magazine matches",_label],_post getOrDefault ["primaryMagazineMatched",false]] call _assert;
          [format ["0.7-B %1 secondary magazine matches",_label],_post getOrDefault ["secondaryMagazineMatched",false]] call _assert;
          [format ["0.7-B %1 target-only physical delta expectation",_label],((_baselineObservedRow isEqualTo _afterRow) isEqualTo (!_expectedMutation))] call _assert;
          [format ["0.7-B %1 rollback not needed on success",_label],!(_applyData getOrDefault ["rollbackAttempted",true])] call _assert;
          [format ["0.7-B %1 apply reports fullMagazines=false",_label],!(_applyData getOrDefault ["fullMagazines",true])] call _assert;

          if (_expectedAmmoPolicy isEqualTo "PRESERVE_OBSERVED_AMMO") then {
           private _beforeMag = _baselineObservedRow param [4,[]];
           private _afterMag = _afterRow param [4,[]];
           [format ["0.7-B %1 observed partial ammo preserved",_label],
            _beforeMag isEqualType [] && {_afterMag isEqualType []} && {count _beforeMag >= 2} && {count _afterMag >= 2}
            && {(toLowerANSI (_beforeMag param [0,""])) isEqualTo (toLowerANSI (_afterMag param [0,""]))}
            && {(_beforeMag param [1,-1]) isEqualTo (_afterMag param [1,-2])}
           ] call _assert;
          };

          _scenarioResults pushBack createHashMapFromArray [
           ["label",_label],
           ["slot",_slot],
           ["operation",_plan getOrDefault ["operation",""]],
           ["mutationPerformed",_applyData getOrDefault ["mutationPerformed",false]],
           ["ammoPolicy",_applyData getOrDefault ["ammoPolicy",""]],
           ["preservationMatched",_post getOrDefault ["preservationMatched",false]]
          ];
         };
        };
       };
      };
     };
    };
   };
  };
 };

 [_kitId] call _cleanupKit;
 _unit setUnitLoadout [[_baseUnitLoadout] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy,false];
 _unit setAnimSpeedCoef _baseAnimSpeed;
 [format ["0.7-B %1 isolated unit restored after scenario",_label],(getUnitLoadout _unit) isEqualTo _baseUnitLoadout] call _assert;
};

[
 "PRIMARY_RECONFIGURE_PARTIAL_AMMO",
 "PRIMARY",
 ["arifle_MX_F","","","",["30Rnd_65x39_caseless_mag",17],[],""],
 "arifle_MX_F",
 "30Rnd_65x39_caseless_mag",
 "optic",
 "optic_Hamr",
 "RECONFIGURE",
 true,
 "PRESERVE_OBSERVED_AMMO"
] call _runScenario;

[
 "HANDGUN_REPLACE",
 "HANDGUN",
 ["hgun_P07_F","","","",["16Rnd_9x21_Mag",7],[],""],
 "hgun_ACPC2_F",
 "9Rnd_45ACP_Mag",
 "",
 "",
 "REPLACE",
 true,
 "NEW_MAGAZINE_FULL_CAPACITY"
] call _runScenario;

[
 "SECONDARY_INSERT",
 "SECONDARY",
 [],
 "launch_NLAW_F",
 "NLAW_F",
 "",
 "",
 "INSERT",
 true,
 "NEW_MAGAZINE_FULL_CAPACITY"
] call _runScenario;

[
 "PRIMARY_NO_OP",
 "PRIMARY",
 ["arifle_MX_F","","","optic_Hamr",["30Rnd_65x39_caseless_mag",11],[],""],
 "arifle_MX_F",
 "30Rnd_65x39_caseless_mag",
 "optic",
 "optic_Hamr",
 "NO_OP",
 false,
 "PRESERVE_OBSERVED_AMMO"
] call _runScenario;

// Stale-snapshot guard: mutate a protected domain after Snapshot and prove apply refuses
// before executing any additional physical mutation.
private _staleBaseline = [_baseUnitLoadout] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
_staleBaseline set [0,["arifle_MX_F","","","",["30Rnd_65x39_caseless_mag",13],[],""]];
_unit setUnitLoadout [_staleBaseline,false];

private _staleCfgResult = ["arifle_MX_F"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponConfiguration;
if (_staleCfgResult getOrDefault ["success",false]) then {
 private _staleCfg = ((_staleCfgResult get "data") get "configuration");
 _staleCfg set ["optic","optic_Hamr"];
 private _staleRecipeResult = [_staleCfg,"30Rnd_65x39_caseless_mag"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponRecipe;
 ["0.7-B stale guard Recipe prerequisite",_staleRecipeResult getOrDefault ["success",false]] call _assert;

 if (_staleRecipeResult getOrDefault ["success",false]) then {
  private _staleNameResult = ["0.7-B Stale Guard"] call ServoPeregrino_Organizador_Weapons_fnc_getUniqueWeaponKitName;
  private _staleKitResult = [
   ((_staleNameResult get "data") getOrDefault ["name","0.7-B Stale Guard"]),
   "PRIMARY",
   ((_staleRecipeResult get "data") get "recipe")
  ] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponKit;
  ["0.7-B stale guard WeaponKit prerequisite",_staleKitResult getOrDefault ["success",false]] call _assert;

  if (_staleKitResult getOrDefault ["success",false]) then {
   private _staleKit = (_staleKitResult get "data") get "kit";
   private _staleKitId = _staleKit getOrDefault ["kitId",""];
   private _stalePlanResult = [_unit,_staleKit] call ServoPeregrino_Organizador_Weapons_fnc_createApplicationPlan;
   ["0.7-B stale guard Plan prerequisite",_stalePlanResult getOrDefault ["success",false]] call _assert;

   if (_stalePlanResult getOrDefault ["success",false]) then {
    private _stalePlan = (_stalePlanResult get "data") get "plan";
    private _staleSnapshotResult = [_unit,_stalePlan] call ServoPeregrino_Organizador_Weapons_fnc_captureApplicationSnapshot;
    ["0.7-B stale guard Snapshot prerequisite",_staleSnapshotResult getOrDefault ["success",false]] call _assert;

    if (_staleSnapshotResult getOrDefault ["success",false]) then {
     private _staleSnapshot = (_staleSnapshotResult get "data") get "snapshot";
     private _drift = [getUnitLoadout _unit] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
     private _oldHeadgear = _drift param [6,""];
     _drift set [6,if ((toLowerANSI _oldHeadgear) isEqualTo "h_helmetb") then {"H_HelmetB_light"} else {"H_HelmetB"}];
     _unit setUnitLoadout [_drift,false];

     private _beforeRefusedApply = [getUnitLoadout _unit] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
     private _refused = [_unit,_stalePlan,_staleSnapshot] call ServoPeregrino_Organizador_Weapons_fnc_applyApplicationPlan;
     private _afterRefusedApply = getUnitLoadout _unit;

     ["0.7-B stale snapshot is rejected",!(_refused getOrDefault ["success",true]) && {(_refused getOrDefault ["code",""]) isEqualTo "WEAPONS_APPLICATION_APPLY_STALE_SNAPSHOT"}] call _assert;
     ["0.7-B stale rejection performs no additional mutation",_beforeRefusedApply isEqualTo _afterRefusedApply] call _assert;
     ["0.7-B stale rejection reports mutationPerformed=false",!(((_refused getOrDefault ["data",createHashMap]) getOrDefault ["mutationPerformed",true]))] call _assert;
    };
   };

   [_staleKitId] call _cleanupKit;
  };
 };
};

_unit setUnitLoadout [[_baseUnitLoadout] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy,false];
_unit setAnimSpeedCoef _baseAnimSpeed;
["0.7-B isolated test unit final restoration",(getUnitLoadout _unit) isEqualTo _baseUnitLoadout] call _assert;

deleteVehicle _unit;
deleteGroup _group;
["0.7-B isolated test unit deleted",isNull _unit] call _assert;

private _runtime = [] call ServoPeregrino_Organizador_Weapons_fnc_getRuntimeStatus;
private _runtimeData = _runtime getOrDefault ["data",createHashMap];
["0.7-B runtime application gate active",(_runtimeData getOrDefault ["kitApplication",""]) isEqualTo "SLOT_SAFE_APPLY_0_7_B"] call _assert;
["0.7-B runtime target-slot mutation marker",(_runtimeData getOrDefault ["applicationMutation",""]) isEqualTo "TARGET_SLOT_ONLY_0_7_B"] call _assert;
["0.7-B runtime UI integration remains deferred",(_runtimeData getOrDefault ["uiPhysicalApplication",""]) isEqualTo "DEFERRED_0_7_D"] call _assert;
["0.7-B frozen Plan schema retained",(_runtimeData getOrDefault ["applicationPlanSchema",""]) isEqualTo "0.7-A-application-plan-candidate"] call _assert;
["0.7-B frozen Snapshot schema retained",(_runtimeData getOrDefault ["applicationSnapshotSchema",""]) isEqualTo "0.7-A-application-snapshot-candidate"] call _assert;

private _localPassed = {_x select 1} count _checks;
private _localFailed = count _checks - _localPassed;
private _passed = _legacyPassed + _localPassed;
private _failed = _legacyFailed + _localFailed;
private _total = _legacyPassed + _legacyFailed + count _checks;

diag_log format [
 "[SP_ORG] [WEAPONS] [AUTO_TEST_SUMMARY] mode=MISSION_FIRST_0_7_B passed=%1 failed=%2 total=%3 legacy=%4/%5 local=%6/%7 | APPLICATION_GATE=SLOT_SAFE_APPLY | STRATEGY=FULL_LOADOUT_CLONE_SETUNITLOADOUT_FALSE | POST_VALIDATION=TARGET_PLUS_PRESERVATION_FINGERPRINT | ROLLBACK=SAFETY_FALLBACK_0_7_B_HARDEN_0_7_C | UI_GATE=DEFERRED_0_7_D | MP_GATE=DEFERRED_0_8",
 _passed,_failed,_total,_legacyPassed,_legacyPassed+_legacyFailed,_localPassed,count _checks
];

hint format [
 "Weapons 0.7-B AUTO TEST: %1/%2; falhas=%3. Mutacao fisica foi executada somente na unidade isolada de teste; o jogador nao deve ter o loadout alterado.",
 _passed,_total,_failed
];

[_failed isEqualTo 0,"WEAPONS_0_7_B_AUTO_TEST_COMPLETE","0.7-B validates the first controlled physical slot-safe apply using frozen 0.7-A Plan/Snapshot contracts, target-only mutation, fullMagazines=false and post-validation of protected domains.",createHashMapFromArray [
 ["passed",_passed],
 ["failed",_failed],
 ["total",_total],
 ["legacyPassed",_legacyPassed],
 ["legacyFailed",_legacyFailed],
 ["localPassed",_localPassed],
 ["localFailed",_localFailed],
 ["checks",_checks],
 ["legacyObservations",_legacyObservations],
 ["scenarios",_scenarioResults],
 ["applicationGate","SLOT_SAFE_APPLY"],
 ["strategy","FULL_LOADOUT_CLONE_SETUNITLOADOUT_FALSE"],
 ["postValidation","TARGET_PLUS_PRESERVATION_FINGERPRINT"],
 ["rollback","SAFETY_FALLBACK_0_7_B_HARDEN_0_7_C"],
 ["uiGate","DEFERRED_0_7_D"],
 ["nextGate","0_7_C_POST_VALIDATION_ROLLBACK"],
 ["mpGate","DEFERRED_0_8"],
 ["executionMode","MISSION_FIRST"]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
