#include "..\..\script_version.hpp"
if (!canSuspend || {!isServer} || {isRemoteExecuted} || {!(missionNamespace getVariable ["SP_ORG_Weapons_LabEnabled",false])}) exitWith {
 [false,"WEAPONS_TEST_SCHEDULED_LAB_ONLY","Use the scheduled D2 LAB action."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _legacy=[] call ServoPeregrino_Organizador_Weapons_fnc_runDelivery0_7_DTests;
private _ld=_legacy getOrDefault ["data",createHashMap];
private _checks=[];private _blocked=_ld getOrDefault ["blocked",0];
private _assert={params ["_name","_ok"];_checks pushBack [_name,_ok];diag_log format ["[SP_ORG] [WEAPONS] [AUTO_TEST] mode=MISSION_FIRST_0_7_D2 %1 | %2",if (_ok) then {"PASS"} else {"FAIL"},_name]};
private _blockTo={params ["_start","_expected","_label"];for "_i" from 1 to (_expected-(count _checks-_start)) do {_checks pushBack [format ["D2 %1 dependent %2",_label,_i],false,"BLOCKED"];_blocked=_blocked+1;diag_log format ["[SP_ORG] [WEAPONS] [AUTO_TEST] mode=MISSION_FIRST_0_7_D2 BLOCKED | %1 dependent %2",_label,_i]}};
["D2 cumulative A/B/C/D baseline",_legacy getOrDefault ["success",false] && {(_ld getOrDefault ["passed",0]) isEqualTo 1109}] call _assert;
private _cfgRoot=missionConfigFile >> "CfgFunctions";
["D2 Weapons feedback registered at owned UI path",getText (_cfgRoot >> "ServoPeregrino_Organizador_Weapons" >> "UI" >> "file") isEqualTo "weapons\functions\ui" && {isClass (_cfgRoot >> "ServoPeregrino_Organizador_Weapons" >> "UI" >> "getApplicationFeedback")}] call _assert;
["D2 Items never declares Weapons feedback",!isClass (_cfgRoot >> "ServoPeregrino_Organizador_Items" >> "UI" >> "getApplicationFeedback")] call _assert;
["D2 catalog executor loaded",!isNil "ServoPeregrino_Organizador_Weapons_fnc_executeCatalogApplication"] call _assert;
private _runtime=[] call ServoPeregrino_Organizador_Weapons_fnc_getRuntimeStatus;
["D2 runtime exposes local draft and catalog application",((_runtime get "data") getOrDefault ["uiPhysicalApplication",""]) isEqualTo "LOCAL_DRAFT_AND_CATALOG_APPLY_0_7_D2"] call _assert;
private _playerBefore=[getUnitLoadout player] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
private _stateBefore=[missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap]] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
private _storeBefore=[missionNamespace getVariable [SP_ORG_WEAPONS_KIT_STORE,createHashMap]] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
private _group=createGroup [west,true];private _unit=_group createUnit ["B_Soldier_F",getPosATL player,[],0,"NONE"];
["D2 isolated local unit",!isNull _unit && {local _unit}] call _assert;
if (!isNull _unit) then {_unit hideObject true;_unit allowDamage false;_unit enableSimulation false;_unit setVariable ["SP_ORG_Weapons_IsolatedFaultTarget",true]};
// Deliberately nonempty unsaved draft store; direct apply must not look at it.
private _state=missionNamespace getVariable SP_ORG_WEAPONS_UI_STATE;
private _drafts=_state getOrDefault ["draftsByKitId",createHashMap];
_drafts set ["D2-ISOLATION",createHashMapFromArray [["dirty",true],["revision",731],["recipe",createHashMapFromArray [["sentinel","unsaved"]]]]];
_state set ["draftsByKitId",_drafts];missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
private _draftsBefore=[_drafts] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
private _base=if (isNull _unit) then {[]} else {[getUnitLoadout _unit] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy};
private _run={
 params ["_label","_class","_kind","_slot","_row","_expectedSlot","_expectedCode","_fault","_draftRoute"];
 if (isNull _unit) exitWith {};
 private _si=["PRIMARY","SECONDARY","HANDGUN"] find _slot;
 private _load=[_base] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;_load set [_si,_row];
 if (_kind isEqualTo "WEAPON" && {!_draftRoute}) then {_load set [["PRIMARY","SECONDARY","HANDGUN"] find _expectedSlot,[]]};
 _unit setUnitLoadout [_load,false];
 // Isolated positive case: an unrequested magazine must stay absent when
 // the fixture contains no spare magazines for the engine to auto-load.
 // Never remove magazine cargo from a real player: this fixture is LAB-only.
 if (_label isEqualTo "WEAPON_PRIMARY_NO_CARGO_AMMO") then {
  removeAllItemsWithMagazines _unit;
 };
 private _before=[getUnitLoadout _unit] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 private _r=createHashMap;
 if (_draftRoute) then {
  private _c=[_class] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponConfiguration;
  if !(_c getOrDefault ["success",false]) exitWith {};
  private _rr=[(_c get "data") get "configuration",if (_expectedSlot isEqualTo "HANDGUN") then {"9Rnd_45ACP_Mag"} else {"30Rnd_65x39_caseless_mag"}] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponRecipe;
  if !(_rr getOrDefault ["success",false]) exitWith {};
  _r=[_unit,createHashMapFromArray [["targetSlot",_expectedSlot],["recipe",(_rr get "data") get "recipe"],["dirty",true]]] call ServoPeregrino_Organizador_Weapons_fnc_executeDraftApplication;
 } else {_r=[_unit,_class,_kind,_slot,_fault] call ServoPeregrino_Organizador_Weapons_fnc_executeCatalogApplication};
 private _d=_r getOrDefault ["data",createHashMap];private _post=_d getOrDefault ["postValidation",createHashMap];
 private _ok=_expectedCode in ["WEAPONS_APPLICATION_APPLIED","WEAPONS_APPLICATION_ALREADY_APPLIED"];
 // In an ammo-rich unit the engine may auto-load a spare magazine into a
 // weapon whose Recipe specifies none. Our strict post-validator must refuse
 // and restore, not silently accept unrequested ammo.
 private _rollback=!(_fault isEqualTo "") || {_expectedCode isEqualTo "WEAPONS_APPLICATION_APPLY_VERIFY_FAILED"};
 private _after=[getUnitLoadout _unit] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 if (_label in ["WEAPON_PRIMARY","WEAPON_PRIMARY_NO_CARGO_AMMO"]) then {
  diag_log format [
   "[SP_ORG] [WEAPONS] [NO_MAG_D2_DIAGNOSTIC] scenario=%1 expectedCode=%2 actualCode=%3 success=%4 failurePhase=%5 rollbackAttempted=%6 rollbackSucceeded=%7 rollbackRestoredExactly=%8 preMagazine=%9 postValidationExpectedRow=%10 postValidationObservedRow=%11 restoredRow=%12",
   _label,_expectedCode,_r getOrDefault ["code",""],_r getOrDefault ["success",false],
   _d getOrDefault ["failurePhase",""],_d getOrDefault ["rollbackAttempted",false],
   _d getOrDefault ["rollbackSucceeded",false],_d getOrDefault ["rollbackRestoredExactly",false],
   (_before param [0,[]]) param [4,[]],
   _post getOrDefault ["expectedTargetRow",[]],_post getOrDefault ["observedTargetRow",[]],
   _after param [0,[]]
  ];
 };
 private _targetSi=["PRIMARY","SECONDARY","HANDGUN"] find _expectedSlot;
 private _fpA=[_before,_expectedSlot] call ServoPeregrino_Organizador_Weapons_fnc_getApplicationPreservationFingerprint;
 private _fpB=[_after,_expectedSlot] call ServoPeregrino_Organizador_Weapons_fnc_getApplicationPreservationFingerprint;
 ["D2 outcome "+_label,(_r getOrDefault ["code",""]) isEqualTo _expectedCode && {(_r getOrDefault ["success",!_ok]) isEqualTo _ok}] call _assert;
 ["D2 natural slot or pre-mutation refusal "+_label,if (_ok || {_rollback}) then {(_d getOrDefault ["targetSlot",""]) isEqualTo _expectedSlot} else {(_d getOrDefault ["failurePhase",""]) isEqualTo "PRE_MUTATION"}] call _assert;
 ["D2 physical outcome "+_label,if (_ok) then {_post getOrDefault ["configurationMatched",false]} else {_after isEqualTo _before}] call _assert;
 private _plan=_d getOrDefault ["plan",createHashMap];
 ["D2 descriptive Plan authority or refusal "+_label,if (_ok || {_rollback}) then {_plan getOrDefault ["dryRunOnly",false] && {!(_plan getOrDefault ["mutationAuthorized",true])}} else {!(_d getOrDefault ["mutationPerformed",true])}] call _assert;
 ["D2 every draft exact "+_label,((missionNamespace getVariable SP_ORG_WEAPONS_UI_STATE) get "draftsByKitId") isEqualTo _draftsBefore] call _assert;
 ["D2 repository exact no create/save/publish "+_label,(missionNamespace getVariable SP_ORG_WEAPONS_KIT_STORE) isEqualTo _storeBefore] call _assert;
 ["D2 all protected domains "+_label,(_fpA getOrDefault ["success",false]) && {_fpB getOrDefault ["success",false]} && {((_fpA get "data") get "fingerprint") isEqualTo ((_fpB get "data") get "fingerprint")}] call _assert;
 ["D2 fullMagazines false "+_label,if (_ok || {_rollback}) then {!(_d getOrDefault ["fullMagazines",true])} else {!(_d getOrDefault ["mutationPerformed",true])}] call _assert;
 ["D2 rollback phase "+_label,(_d getOrDefault ["rollbackAttempted",!_rollback]) isEqualTo _rollback && {if (_rollback) then {_d getOrDefault ["rollbackSucceeded",false] && {_d getOrDefault ["rollbackRestoredExactly",false]}} else {true}}] call _assert;
 ["D2 post-validation ammo matches runner "+_label,if (_ok) then {_post getOrDefault ["primaryMagazineMatched",false] && {((_post getOrDefault ["expectedTargetRow",[]]) param [4,[]]) isEqualTo ((_after param [_targetSi,[]]) param [4,[]])}} else {_after isEqualTo _before}] call _assert;
 private _feedback=[_r] call ServoPeregrino_Organizador_Weapons_fnc_getApplicationFeedback;
 ["D2 human feedback "+_label,(_feedback get "message") != "" && {(_feedback get "message") find "WEAPONS_" < 0}] call _assert;
 // Observe the next actual engine frame, with a bounded timeout. Never adjust ammo to fit observation.
 private _frame=diag_frameNo;private _deadline=diag_tickTime+2;
 waitUntil {diag_frameNo > _frame || {diag_tickTime>=_deadline}};
 private _stable=getUnitLoadout _unit;
 ["D2 next-frame exact stable physical state "+_label,diag_frameNo > _frame && {_stable isEqualTo _after}] call _assert;
 diag_log format ["[SP_ORG] [WEAPONS] [AMMO_D2_STABLE] scenario=%1 frames=%2 policy=%3 expectedRow=%4",_label,diag_frameNo-_frame,_d getOrDefault ["ammoPolicy","PRE_MUTATION"],_post getOrDefault ["expectedTargetRow",[]]];
 diag_log format ["[SP_ORG] [WEAPONS] [AMMO_D2_STABLE_ROW] scenario=%1 observed=%2 currentWeapon=%3 currentMuzzle=%4",_label,_stable param [_targetSi,[]],currentWeapon _unit,currentMuzzle _unit];
 diag_log format ["[SP_ORG] [WEAPONS] [AMMO_D2_DETAIL] scenario=%1 magazines=%2",_label,magazinesAmmoFull _unit];
};
private _mx=["arifle_MX_SW_F","","","",["30Rnd_65x39_caseless_mag",17],[],""];
private _p07=["hgun_P07_F","","","",["16Rnd_9x21_Mag",7],[],""];
{
 private _start=count _checks;_x call _run;[_start,12,_x select 0] call _blockTo;
} forEach [
 // Ammo-rich fixture: engine may auto-load a compatible spare magazine.
 // Strict NO_RECIPE_MAGAZINE must reject it and restore the exact Snapshot.
 ["WEAPON_PRIMARY","arifle_MX_F","WEAPON","HANDGUN",_p07,"PRIMARY","WEAPONS_APPLICATION_APPLY_VERIFY_FAILED","",false],
 // Ammo-free isolated fixture: unrequested ammo must remain absent; apply succeeds.
 ["WEAPON_PRIMARY_NO_CARGO_AMMO","arifle_MX_F","WEAPON","HANDGUN",_p07,"PRIMARY","WEAPONS_APPLICATION_APPLIED","",false],
 ["WEAPON_HANDGUN","hgun_ACPC2_F","WEAPON","PRIMARY",_mx,"HANDGUN","WEAPONS_APPLICATION_APPLIED","",false],
 ["WEAPON_SECONDARY","launch_NLAW_F","WEAPON","PRIMARY",_mx,"SECONDARY","WEAPONS_APPLICATION_APPLIED","",false],
 ["OPTIC","optic_Hamr","OPTIC","PRIMARY",_mx,"PRIMARY","WEAPONS_APPLICATION_APPLIED","",false],
 ["POINTER","acc_pointer_IR","POINTER","PRIMARY",_mx,"PRIMARY","WEAPONS_APPLICATION_APPLIED","",false],
 ["MUZZLE","muzzle_snds_H","MUZZLE","PRIMARY",_mx,"PRIMARY","WEAPONS_APPLICATION_APPLIED","",false],
 ["BIPOD","bipod_01_F_blk","BIPOD","PRIMARY",_mx,"PRIMARY","WEAPONS_APPLICATION_APPLIED","",false],
 ["GRIP_UNREPRESENTABLE","hgun_P07_F","GRIP","PRIMARY",_mx,"PRIMARY","WEAPONS_UI_CATALOG_SELECTION_INCOMPATIBLE","",false],
 ["MAG_SAME_PARTIAL","30Rnd_65x39_caseless_mag","MAGAZINE","PRIMARY",_mx,"PRIMARY","WEAPONS_APPLICATION_ALREADY_APPLIED","",false],
 ["MAG_NEW","30Rnd_65x39_caseless_mag_Tracer","MAGAZINE","PRIMARY",_mx,"PRIMARY","WEAPONS_APPLICATION_APPLIED","",false],
 ["HANDGUN_SAME_PARTIAL","16Rnd_9x21_Mag","MAGAZINE","HANDGUN",_p07,"HANDGUN","WEAPONS_APPLICATION_ALREADY_APPLIED","",false],
 ["HANDGUN_NEW_MAG","9Rnd_45ACP_Mag","MAGAZINE","HANDGUN",["hgun_ACPC2_F","","","",[],[],""],"HANDGUN","WEAPONS_APPLICATION_APPLIED","",false],
 ["INCOMPATIBLE","hgun_P07_F","OPTIC","PRIMARY",_mx,"PRIMARY","WEAPONS_UI_CATALOG_SELECTION_INCOMPATIBLE","",false],
 ["EMPTY_DESTINATION","optic_Hamr","OPTIC","PRIMARY",[],"PRIMARY","WEAPONS_UI_CATALOG_EMPTY_DESTINATION","",false],
 ["UNSUPPORTED","optic_Hamr","UNKNOWN","PRIMARY",_mx,"PRIMARY","WEAPONS_UI_CATALOG_KIND_UNSUPPORTED","",false],
 ["CATALOG_C_ROLLBACK","optic_Hamr","OPTIC","PRIMARY",_mx,"PRIMARY","WEAPONS_APPLICATION_APPLY_VERIFY_FAILED","PROTECTED_DIVERGENCE",false],
 ["DRAFT_HANDGUN_REPLACE_STABLE","hgun_ACPC2_F","WEAPON","HANDGUN",_p07,"HANDGUN","WEAPONS_APPLICATION_APPLIED","",true],
 ["DRAFT_PRIMARY_REPLACE","arifle_MX_F","WEAPON","PRIMARY",["arifle_Katiba_F","","","",["30Rnd_65x39_caseless_green",13],[],""],"PRIMARY","WEAPONS_APPLICATION_APPLIED","",true]
];
private _uiTests={
 disableSerialization;
 private _load=getUnitLoadout player;private _si=[0,2,1] select (([0,2,1] findIf {count (_load param [_x,[]]) isEqualTo 7 && {((_load select _x) param [4,[]]) isNotEqualTo []}}) max 0);
 private _row=_load param [_si,[]];private _mag=(_row param [4,[]]) param [0,""];
 if (_mag isEqualTo "") exitWith {};
 [] call ServoPeregrino_Organizador_Weapons_fnc_openInterface;
 private _display=findDisplay SP_ORG_WEAPONS_UI_DISPLAY_IDD;
 private _s=missionNamespace getVariable SP_ORG_WEAPONS_UI_STATE;
 _s set ["selectedCatalogClass",_mag];_s set ["selectedCatalogKind","MAGAZINE"];_s set ["equipmentSlotView",["PRIMARY","SECONDARY","HANDGUN"] select _si];_s set ["equipmentQuery",""];
 missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_s];
 private _before=[_s] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 ["CATALOG_TO_EQUIPMENT"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
 private _after=missionNamespace getVariable SP_ORG_WEAPONS_UI_STATE;private _r=_after getOrDefault ["lastApplicationResult",createHashMap];
 ["D2 actual catalog UI NO_OP",(_r getOrDefault ["code",""]) isEqualTo "WEAPONS_APPLICATION_ALREADY_APPLIED"] call _assert;
 ["D2 button actionable",ctrlEnabled (_display displayCtrl 3151)] call _assert;
 ["D2 player intact after handler",(getUnitLoadout player) isEqualTo _playerBefore] call _assert;
 ["D2 UI drafts exact",(_after get "draftsByKitId") isEqualTo (_before get "draftsByKitId")] call _assert;
 ["D2 UI repository exact",(missionNamespace getVariable SP_ORG_WEAPONS_KIT_STORE) isEqualTo _storeBefore] call _assert;
 ["D2 no FULL refresh",(_after get "refreshAppliedCount") isEqualTo (_before get "refreshAppliedCount")] call _assert;
 ["D2 no catalog rebuild",(_after get "catalogFocusedRefreshCount") isEqualTo (_before get "catalogFocusedRefreshCount")] call _assert;
 ["D2 no P2 rebuild",(_after get "draftFocusedRefreshCount") isEqualTo (_before get "draftFocusedRefreshCount")] call _assert;
 ["D2 P4 focused once",(_after get "equipmentFocusedRefreshCount") isEqualTo ((_before get "equipmentFocusedRefreshCount")+1)] call _assert;
 ["D2 catalog selection and offset stable",(_after get "selectedCatalogClass") isEqualTo _mag && {(_after getOrDefault ["catalogOffset",-1]) isEqualTo (_before getOrDefault ["catalogOffset",-2])}] call _assert;
 ["D2 P4 slot and observed class",(_after get "equipmentSlotView") isEqualTo (["PRIMARY","SECONDARY","HANDGUN"] select _si) && {(ctrlText (_display displayCtrl 4022)) isEqualTo (_row select 0)}] call _assert;
 ["D2 rendered feedback human",(ctrlText (_display displayCtrl 5001)) find "Nada" >= 0 && {(ctrlText (_display displayCtrl 5001)) find "WEAPONS_" < 0}] call _assert;
};
private _start=count _checks;[] call _uiTests;[_start,12,"UI"] call _blockTo;
private _open=[] call ServoPeregrino_Organizador_Weapons_fnc_openInterface;
["D2 open retains distinct visual baseline",((_open getOrDefault ["data",createHashMap]) getOrDefault ["checkpoint",""]) isEqualTo "0.6-F R6"] call _assert;
["D2 actual tooltip describes direct physical intent",(getText (missionConfigFile >> "SP_ORG_Weapons_Dialog" >> "controls" >> "CatalogToEquipment" >> "tooltip")) find "Não altera o rascunho" >= 0] call _assert;
["D2 open exposes active application gate",((_open getOrDefault ["data",createHashMap]) getOrDefault ["applicationGate",""]) isEqualTo "LOCAL_DRAFT_AND_CATALOG_APPLY_0_7_D2"] call _assert;
if (!isNull _unit) then {deleteVehicle _unit};private _deadline=diag_tickTime+5;waitUntil {sleep 0.01;isNull _unit || {diag_tickTime>=_deadline}};
["D2 isolated unit removed",isNull _unit && {!(_unit in allUnits)} && {!(_unit in (allMissionObjects "CAManBase"))}] call _assert;deleteGroup _group;
["D2 player intact final",(getUnitLoadout player) isEqualTo _playerBefore] call _assert;
missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_stateBefore];missionNamespace setVariable [SP_ORG_WEAPONS_KIT_STORE,_storeBefore];[] call ServoPeregrino_Organizador_Weapons_fnc_refreshInterface;
private _lp={_x select 1} count _checks;private _lb={(_x param [2,""]) isEqualTo "BLOCKED"} count _checks;
private _passed=(_ld getOrDefault ["passed",0])+_lp;private _failed=(_ld getOrDefault ["failed",1])+count _checks-_lp-_lb;private _total=(_ld getOrDefault ["total",0])+count _checks;
diag_log format ["[SP_ORG] [WEAPONS] [AUTO_TEST_SUMMARY] mode=MISSION_FIRST_0_7_D2 passed=%1 failed=%2 blocked=%3 total=%4 expected=1360 UNDO=UNDO_DEFERRED MP=MP_DEFERRED_0_8",_passed,_failed,_blocked,_total];
hint format ["Weapons 0.7-D2: %1/%2; falhas=%3; bloqueados=%4. Envie o RPT completo.",_passed,_total,_failed,_blocked];
[_failed isEqualTo 0 && {_blocked isEqualTo 0} && {_total isEqualTo 1360},"WEAPONS_0_7_D2_AUTO_TEST_COMPLETE","Consolidated runtime gate; real Arma approval required.",createHashMapFromArray [["passed",_passed],["failed",_failed],["blocked",_blocked],["total",_total],["expected",1360],["checks",_checks],["undo","UNDO_DEFERRED"]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
