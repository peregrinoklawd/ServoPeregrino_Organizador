#include "..\..\script_version.hpp"
if (!canSuspend || {!isServer} || {isRemoteExecuted} || {!(missionNamespace getVariable ["SP_ORG_Weapons_LabEnabled",false])}) exitWith {
 [false,"WEAPONS_TEST_SCHEDULED_LAB_ONLY","Use the scheduled LAB action."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _legacy=[] call ServoPeregrino_Organizador_Weapons_fnc_runDelivery0_7_CTests;
private _ld=_legacy getOrDefault ["data",createHashMap];
private _checks=[];
private _blocked=_ld getOrDefault ["blocked",0];
private _assert={params ["_name","_ok"];_checks pushBack [_name,_ok];diag_log format ["[SP_ORG] [WEAPONS] [AUTO_TEST] mode=MISSION_FIRST_0_7_D %1 | %2",if (_ok) then {"PASS"} else {"FAIL"},_name]};
private _blockTo={
 params ["_start","_expected","_label"];
 private _missing=_expected-(count _checks-_start);
 for "_i" from 1 to _missing do {_checks pushBack [format ["D %1 dependent %2",_label,_i],false,"BLOCKED"];_blocked=_blocked+1;diag_log format ["[SP_ORG] [WEAPONS] [AUTO_TEST] BLOCKED | D %1 dependent %2",_label,_i]};
};
["D cumulative C baseline",_legacy getOrDefault ["success",false] && {(_ld getOrDefault ["passed",0]) isEqualTo 978}] call _assert;
private _playerBefore=[getUnitLoadout player] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
private _stateBefore=[missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap]] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
private _storeBefore=[missionNamespace getVariable [SP_ORG_WEAPONS_KIT_STORE,createHashMap]] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
private _group=createGroup [west,true];
private _unit=_group createUnit ["B_Soldier_F",getPosATL player,[],0,"NONE"];
["D local isolated target",!isNull _unit && {local _unit}] call _assert;
private _kitId="";private _otherId="";
private _seed={
 private _cfgR=["arifle_MX_F"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponConfiguration;
 ["D fixture configuration",_cfgR getOrDefault ["success",false]] call _assert;
 if !(_cfgR getOrDefault ["success",false]) exitWith {};
 private _recipeR=[(_cfgR get "data") get "configuration","30Rnd_65x39_caseless_mag"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponRecipe;
 ["D fixture Recipe",_recipeR getOrDefault ["success",false]] call _assert;
 if !(_recipeR getOrDefault ["success",false]) exitWith {};
 private _nameR=["D Apply Fixture"] call ServoPeregrino_Organizador_Weapons_fnc_getUniqueWeaponKitName;
 private _kitR=[(_nameR get "data") get "name","PRIMARY",(_recipeR get "data") get "recipe"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponKit;
 private _otherNameR=["D Other Fixture"] call ServoPeregrino_Organizador_Weapons_fnc_getUniqueWeaponKitName;
 private _otherR=[(_otherNameR get "data") get "name","PRIMARY",(_recipeR get "data") get "recipe"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponKit;
 ["D two nonempty repository kits",_kitR getOrDefault ["success",false] && {_otherR getOrDefault ["success",false]}] call _assert;
 if !(_kitR getOrDefault ["success",false] && {_otherR getOrDefault ["success",false]}) exitWith {};
 _kitId=((_kitR get "data") get "kit") get "kitId";
 _otherId=((_otherR get "data") get "kit") get "kitId";
 [_kitId] call ServoPeregrino_Organizador_Weapons_fnc_getOrCreateWeaponKitDraft;
 [_otherId] call ServoPeregrino_Organizador_Weapons_fnc_getOrCreateWeaponKitDraft;
};
private _seedStart=count _checks;[] call _seed;[_seedStart,3,"fixture"] call _blockTo;
private _storeSeed=[missionNamespace getVariable [SP_ORG_WEAPONS_KIT_STORE,createHashMap]] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
private _state=missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
private _otherDraft=[(_state getOrDefault ["draftsByKitId",createHashMap]) getOrDefault [_otherId,createHashMap]] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
private _base=if (isNull _unit) then {[]} else {[getUnitLoadout _unit] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy};
private _run={
 params ["_label","_slot","_row","_weapon","_mag","_optic","_operation","_ammo","_mutation"];
 if (isNull _unit || {_kitId isEqualTo ""}) exitWith {};
 _unit hideObject true;_unit allowDamage false;_unit enableSimulation false;
 private _si=["PRIMARY","SECONDARY","HANDGUN"] find _slot;
 private _loadout=[_base] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;_loadout set [_si,_row];_unit setUnitLoadout [_loadout,false];
 private _cfgR=[_weapon] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponConfiguration;
 ["D config "+_label,_cfgR getOrDefault ["success",false]] call _assert;
 if !(_cfgR getOrDefault ["success",false]) exitWith {};
 private _cfg=(_cfgR get "data") get "configuration";_cfg set ["optic",_optic];
 private _recipeR=[_cfg,_mag] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponRecipe;
 ["D Recipe "+_label,_recipeR getOrDefault ["success",false]] call _assert;
 if !(_recipeR getOrDefault ["success",false]) exitWith {};
 private _draft=createHashMapFromArray [["sourceKitId",_kitId],["targetSlot",_slot],["recipe",(_recipeR get "data") get "recipe"],["dirty",true],["revision",99]];
 private _draftBefore=[_draft] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 private _s=missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
 (_s get "draftsByKitId") set [_kitId,_draft];_s set ["selectedKitId",_kitId];missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_s];
 private _result=[_unit,_draft] call ServoPeregrino_Organizador_Weapons_fnc_executeDraftApplication;
 private _d=_result getOrDefault ["data",createHashMap];private _post=_d getOrDefault ["postValidation",createHashMap];
 ["D draft apply succeeds "+_label,_result getOrDefault ["success",false]] call _assert;
 ["D operation "+_label,(_d getOrDefault ["operation",""]) isEqualTo _operation] call _assert;
 ["D target slot "+_label,(_d getOrDefault ["targetSlot",""]) isEqualTo _slot] call _assert;
 ["D source draft intact "+_label,_draft isEqualTo _draftBefore] call _assert;
 ["D dirty draft stays unsaved "+_label,_draft getOrDefault ["dirty",false]] call _assert;
 ["D repository exact unchanged "+_label,(missionNamespace getVariable [SP_ORG_WEAPONS_KIT_STORE,createHashMap]) isEqualTo _storeSeed] call _assert;
 private _afterState=missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
 ["D other draft unchanged "+_label,((_afterState get "draftsByKitId") get _otherId) isEqualTo _otherDraft] call _assert;
 ["D protected domains "+_label,_post getOrDefault ["preservationMatched",false]] call _assert;
 ["D fullMagazines false "+_label,!(_d getOrDefault ["fullMagazines",true])] call _assert;
 ["D mutation flag "+_label,(_d getOrDefault ["mutationPerformed",!_mutation]) isEqualTo _mutation] call _assert;
 ["D observed ammo "+_label,((((getUnitLoadout _unit) param [_si,[]]) param [4,[]]) param [1,-1]) isEqualTo _ammo] call _assert;
 ["D strict or SECONDARY family class "+_label,_post getOrDefault ["classEquivalent",false]] call _assert;
 private _feedback=[_result] call ServoPeregrino_Organizador_Weapons_fnc_getApplicationFeedback;
 ["D feedback human readable "+_label,(_feedback get "kind") isEqualTo "SUCCESS" && {(_feedback get "message") find "WEAPONS_" < 0}] call _assert;
 ["D no rollback on SUCCESS "+_label,!(_d getOrDefault ["rollbackAttempted",true])] call _assert;
 diag_log format ["[SP_ORG] [WEAPONS] [DRAFT_ROUTE_DIAGNOSTIC] scenario=%1 result=%2",_label,_result];
};
{
 private _start=count _checks;_x call _run;[_start,16,_x select 0] call _blockTo;
} forEach [
 ["PRIMARY_INSERT","PRIMARY",[],"arifle_MX_F","30Rnd_65x39_caseless_mag","","INSERT",30,true],
 ["HANDGUN_REPLACE","HANDGUN",["hgun_P07_F","","","",["16Rnd_9x21_Mag",7],[],""],"hgun_ACPC2_F","9Rnd_45ACP_Mag","","REPLACE",9,true],
 ["SECONDARY_INSERT","SECONDARY",[],"launch_NLAW_F","NLAW_F","","INSERT",1,true],
 ["PRIMARY_RECONFIGURE_PARTIAL","PRIMARY",["arifle_MX_F","","","",["30Rnd_65x39_caseless_mag",17],[],""],"arifle_MX_F","30Rnd_65x39_caseless_mag","optic_Hamr","RECONFIGURE",17,true],
 ["PRIMARY_NO_OP","PRIMARY",["arifle_MX_F","","","optic_Hamr",["30Rnd_65x39_caseless_mag",11],[],""],"arifle_MX_F","30Rnd_65x39_caseless_mag","optic_Hamr","NO_OP",11,false],
 ["SECONDARY_SPECIAL_FAMILY","SECONDARY",[],"launch_RPG32_F","RPG32_F","","INSERT",1,true]
];
private _failureTests={
 if (isNull _unit || {_kitId isEqualTo ""}) exitWith {};
 private _s=missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
 private _draft=[(_s get "draftsByKitId") get _kitId] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 private _load=[_base] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;_load set [1,[]];_unit setUnitLoadout [_load,false];
 _unit setVariable ["SP_ORG_Weapons_IsolatedFaultTarget",true];
 private _before=getUnitLoadout _unit;private _copy=[_draft] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 private _failed=[_unit,_draft,"PROTECTED_DIVERGENCE"] call ServoPeregrino_Organizador_Weapons_fnc_executeDraftApplication;
 private _d=_failed getOrDefault ["data",createHashMap];
 ["D physical failure through draft route",!(_failed getOrDefault ["success",true]) && {_d getOrDefault ["mutationPerformed",false]}] call _assert;
 ["D draft route C rollback verified",_d getOrDefault ["rollbackAttempted",false] && {_d getOrDefault ["rollbackSucceeded",false]}] call _assert;
 ["D failed draft route restores exact physical state",(getUnitLoadout _unit) isEqualTo _before] call _assert;
 ["D physical failure keeps draft",_draft isEqualTo _copy] call _assert;
 ["D physical failure keeps repository",(missionNamespace getVariable SP_ORG_WEAPONS_KIT_STORE) isEqualTo _storeSeed] call _assert;
 private _invalid=[_unit,createHashMap] call ServoPeregrino_Organizador_Weapons_fnc_executeDraftApplication;
 ["D invalid draft rejected before mutation",(_invalid getOrDefault ["code",""]) isEqualTo "WEAPONS_APPLICATION_DRAFT_INVALID" && {(getUnitLoadout _unit) isEqualTo _before}] call _assert;
 private _incompatible=[_draft] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 ((_incompatible get "recipe") get "configuration") set ["optic","hgun_P07_F"];
 private _bad=[_unit,_incompatible] call ServoPeregrino_Organizador_Weapons_fnc_executeDraftApplication;
 ["D incompatible draft refused",!(_bad getOrDefault ["success",true]) && {(getUnitLoadout _unit) isEqualTo _before}] call _assert;
};
private _failStart=count _checks;[] call _failureTests;[_failStart,7,"failure route"] call _blockTo;
{
 _x params ["_code","_word"];
 private _fake=createHashMapFromArray [["code",_code],["success",_code in ["WEAPONS_APPLICATION_APPLIED","WEAPONS_APPLICATION_ALREADY_APPLIED"]]];
 private _f=[_fake] call ServoPeregrino_Organizador_Weapons_fnc_getApplicationFeedback;
 ["D feedback "+_code,(_f get "message") find _word >= 0 && {(_f get "message") find "WEAPONS_" < 0}] call _assert;
} forEach [["WEAPONS_APPLICATION_APPLIED","equipado"],["WEAPONS_APPLICATION_ALREADY_APPLIED","Nada"],["WEAPONS_APPLICATION_APPLY_STALE_SNAPSHOT","mudou"],["WEAPONS_APPLICATION_DRAFT_INVALID","Escolha"],["WEAPONS_CONFIGURATION_OPTIC_INCOMPATIBLE","compatível"],["WEAPONS_APPLICATION_APPLY_VERIFY_FAILED","restaurado"],["WEAPONS_APPLICATION_ROLLBACK_FAILED","Confira"]];
// Actual player handler exercised only with a captured NO_OP source. No player mutation authorized by harness.
private _uiTests={
 disableSerialization;
 if (_kitId isEqualTo "") exitWith {};
 private _loadout=getUnitLoadout player;private _si=[0,2,1] select (([0,2,1] findIf {count (_loadout param [_x,[]]) isEqualTo 7}) max 0);
 private _capture=[_loadout param [_si,[]]] call ServoPeregrino_Organizador_Weapons_fnc_configurationFromWeaponArray;
 ["D UI player configuration capture",_capture getOrDefault ["success",false]] call _assert;
 if !(_capture getOrDefault ["success",false]) exitWith {};
 private _mag=((((_capture get "data") get "loadedState") get "primaryMagazine") param [0,""]);
 private _recipeR=[(_capture get "data") get "configuration",_mag] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponRecipe;
 ["D UI player Recipe",_recipeR getOrDefault ["success",false]] call _assert;
 if !(_recipeR getOrDefault ["success",false]) exitWith {};
 private _draft=createHashMapFromArray [["targetSlot",["PRIMARY","SECONDARY","HANDGUN"] select _si],["recipe",(_recipeR get "data") get "recipe"],["dirty",true]];
 private _s=missionNamespace getVariable SP_ORG_WEAPONS_UI_STATE;(_s get "draftsByKitId") set [_kitId,_draft];_s set ["selectedKitId",_kitId];_s set ["selectedKitDraftDirty",true];_s set ["equipmentQuery",""];missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_s];
 [] call ServoPeregrino_Organizador_Weapons_fnc_openInterface;
 [] call ServoPeregrino_Organizador_Weapons_fnc_refreshInterface;
 private _display=findDisplay SP_ORG_WEAPONS_UI_DISPLAY_IDD;
 ["D physical button visible",!isNull (_display displayCtrl 2144) && {ctrlEnabled (_display displayCtrl 2144)} && {(ctrlText (_display displayCtrl 2144)) isEqualTo "EQUIPAR RASCUNHO"}] call _assert;
 _s=[missionNamespace getVariable SP_ORG_WEAPONS_UI_STATE] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 ["APPLY_DRAFT"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
 private _after=missionNamespace getVariable SP_ORG_WEAPONS_UI_STATE;private _result=_after getOrDefault ["lastApplicationResult",createHashMap];
 ["D real UI handler NO_OP",_result getOrDefault ["success",false] && {(_result getOrDefault ["code",""]) isEqualTo "WEAPONS_APPLICATION_ALREADY_APPLIED"}] call _assert;
 ["D actual UI keeps player loadout",(getUnitLoadout player) isEqualTo _playerBefore] call _assert;
 ["D actual UI keeps repository",(missionNamespace getVariable SP_ORG_WEAPONS_KIT_STORE) isEqualTo _storeSeed] call _assert;
 ["D actual UI keeps every draft",(_after get "draftsByKitId") isEqualTo (_s get "draftsByKitId")] call _assert;
 ["D no full refresh",(_after get "refreshAppliedCount") isEqualTo (_s get "refreshAppliedCount")] call _assert;
 ["D no catalog focused rebuild",(_after get "catalogFocusedRefreshCount") isEqualTo (_s get "catalogFocusedRefreshCount")] call _assert;
 ["D no draft rebuild",(_after get "draftFocusedRefreshCount") isEqualTo (_s get "draftFocusedRefreshCount")] call _assert;
 ["D equipment focused refresh once",(_after get "equipmentFocusedRefreshCount") isEqualTo ((_s get "equipmentFocusedRefreshCount")+1)] call _assert;
 ["D equipment panel reflects observed row",(ctrlText (_display displayCtrl 4022)) isEqualTo ((_loadout select _si) select 0)] call _assert;
 ["D feedback footer and state human readable",(_after get "temporaryMessage") find "Nada" >= 0 && {(str (ctrlStructuredText (_display displayCtrl 5001))) find "Nada" >= 0 && {(str (ctrlStructuredText (_display displayCtrl 5001))) find "WEAPONS_" < 0}}] call _assert;
 ["D undo explicitly deferred",((_result getOrDefault ["data",createHashMap]) getOrDefault ["undo",""]) isEqualTo "UNDO_DEFERRED"] call _assert;
};
private _uiStart=count _checks;[] call _uiTests;[_uiStart,14,"actual UI"] call _blockTo;
if (!isNull _unit) then {deleteVehicle _unit};private _deadline=diag_tickTime+5;waitUntil {sleep 0.01;isNull _unit || {diag_tickTime>=_deadline}};
["D isolated unit removed",isNull _unit && {!(_unit in allUnits)} && {!(_unit in (allMissionObjects "CAManBase"))}] call _assert;
deleteGroup _group;
["D player loadout intact final",(getUnitLoadout player) isEqualTo _playerBefore] call _assert;
missionNamespace setVariable [SP_ORG_WEAPONS_KIT_STORE,_storeBefore];missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_stateBefore];
[] call ServoPeregrino_Organizador_Weapons_fnc_refreshInterface;
private _lp={_x select 1} count _checks;private _lb={(_x param [2,""]) isEqualTo "BLOCKED"} count _checks;
private _lf=count _checks-_lp-_lb;private _passed=(_ld getOrDefault ["passed",0])+_lp;private _failed=(_ld getOrDefault ["failed",1])+_lf;private _total=(_ld getOrDefault ["total",0])+count _checks;
diag_log format ["[SP_ORG] [WEAPONS] [AUTO_TEST_SUMMARY] mode=MISSION_FIRST_0_7_D passed=%1 failed=%2 blocked=%3 total=%4 expected=1109 UNDO=UNDO_DEFERRED",_passed,_failed,_blocked,_total];
hint format ["Weapons 0.7-D: %1/%2; falhas=%3; bloqueados=%4. Undo deferred.",_passed,_total,_failed,_blocked];
[_failed isEqualTo 0 && {_blocked isEqualTo 0} && {_total isEqualTo 1109},"WEAPONS_0_7_D_AUTO_TEST_COMPLETE","Local unsaved draft apply, repository separation, C rollback and focused UI integration; runtime pending.",createHashMapFromArray [["passed",_passed],["failed",_failed],["blocked",_blocked],["total",_total],["expected",1109],["checks",_checks],["undo","UNDO_DEFERRED"]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
