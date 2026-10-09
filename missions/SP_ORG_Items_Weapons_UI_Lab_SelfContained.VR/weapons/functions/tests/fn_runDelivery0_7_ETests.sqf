#include "..\..\script_version.hpp"
if (!canSuspend || {!isServer} || {isRemoteExecuted} || {!(missionNamespace getVariable ["SP_ORG_Weapons_LabEnabled",false])}) exitWith {
 [false,"WEAPONS_TEST_SCHEDULED_LAB_ONLY","Use SP_ORG LAB - TESTAR WEAPONS 0.7-E."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if (!isNull (findDisplay SP_ORG_WEAPONS_UI_DISPLAY_IDD)) exitWith {
 [false,"WEAPONS_TEST_UI_MUST_BE_CLOSED","Feche Weapons antes de iniciar o AUTO TEST. Não abra durante a execução."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _legacy=[] call ServoPeregrino_Organizador_Weapons_fnc_runDelivery0_7_D2Tests;
private _ld=_legacy getOrDefault ["data",createHashMap];
private _checks=[];
private _assert={
 params ["_name","_ok"];
 _checks pushBack [_name,_ok];
 diag_log format ["[SP_ORG] [WEAPONS] [AUTO_TEST] mode=MISSION_FIRST_0_7_E_R3 %1 | %2",if (_ok) then {"PASS"} else {"FAIL"},_name];
};
["E cumulative D2 baseline",_legacy getOrDefault ["success",false] && {(_ld getOrDefault ["passed",0]) isEqualTo 1360}] call _assert;
private _playerBefore=[getUnitLoadout player] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
private _stateBefore=[missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap]] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
private _storeBefore=[missionNamespace getVariable [SP_ORG_WEAPONS_KIT_STORE,createHashMap]] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
private _group=createGroup [west,true];
private _unit=_group createUnit ["B_Soldier_F",getPosATL player,[],0,"NONE"];
["E isolated target local",!isNull _unit && {local _unit}] call _assert;
private _storeAfterFixture=createHashMap;private _kitId="";
private _test={
 if (isNull _unit) exitWith {};
 _unit hideObject true;_unit allowDamage false;_unit enableSimulation false;
 private _loadout=[getUnitLoadout _unit] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 _loadout set [0,["arifle_MX_F","","","optic_Hamr",["30Rnd_65x39_caseless_mag",17],[],""]];
 _unit setUnitLoadout [_loadout,false];
 private _observedBefore=[getUnitLoadout _unit] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 private _eq=[_unit,"PRIMARY"] call ServoPeregrino_Organizador_Weapons_fnc_getEquipmentSlotSnapshot;
 ["E occupied P4 snapshot",_eq getOrDefault ["success",false] && {((_eq getOrDefault ["data",createHashMap]) getOrDefault ["snapshot",createHashMap]) getOrDefault ["equipped",false]}] call _assert;
 private _observed=(_eq getOrDefault ["data",createHashMap]) getOrDefault ["snapshot",createHashMap];
 private _entryCfgR=["hgun_P07_F"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponConfiguration;
 private _entryRecipeR=if (_entryCfgR getOrDefault ["success",false]) then {
  [(_entryCfgR get "data") get "configuration","16Rnd_9x21_Mag"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponRecipe
 } else {_entryCfgR};
 private _nameR=["E Capture Fixture"] call ServoPeregrino_Organizador_Weapons_fnc_getUniqueWeaponKitName;
 private _newKitR=if (_entryRecipeR getOrDefault ["success",false] && {_nameR getOrDefault ["success",false]}) then {
  [(_nameR get "data") get "name","HANDGUN",(_entryRecipeR get "data") get "recipe"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponKit
 } else {
  [false,"WEAPONS_TEST_FIXTURE_FAILED","Could not create isolated fixture."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
 };
 ["E fixture kit and recipe",_newKitR getOrDefault ["success",false]] call _assert;
 if !(_newKitR getOrDefault ["success",false]) exitWith {};
 _kitId=((_newKitR get "data") get "kit") get "kitId";
 private _draftR=[_kitId] call ServoPeregrino_Organizador_Weapons_fnc_getOrCreateWeaponKitDraft;
 ["E original kit draft available",_draftR getOrDefault ["success",false]] call _assert;
 _storeAfterFixture=[missionNamespace getVariable SP_ORG_WEAPONS_KIT_STORE] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 private _state=missionNamespace getVariable SP_ORG_WEAPONS_UI_STATE;
 _state set ["selectedKitId",_kitId];
 _state set ["pendingNewKit",false];
 _state set ["pendingCapturedDraft",createHashMap];
 missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
 private _otherDraft=[(_state get "draftsByKitId") get _kitId] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 missionNamespace setVariable [SP_ORG_WEAPONS_UI_CATALOG_PROJECTION_VAR,createHashMapFromArray [
  ["sourceKitId",_kitId],["sourceWeaponClass","hgun_P07_F"],["sourceSlot","HANDGUN"],["sourceKey","R3_STALE_SENTINEL"]
 ]];
 ["E R3 stale catalog fixture created",(missionNamespace getVariable SP_ORG_WEAPONS_UI_CATALOG_PROJECTION_VAR) getOrDefault ["sourceWeaponClass",""] isEqualTo "hgun_P07_F"] call _assert;
 private _captured=[_unit,"PRIMARY"] call ServoPeregrino_Organizador_Weapons_fnc_captureEquippedWeaponToDraft;
 private _capData=_captured getOrDefault ["data",createHashMap];
 private _draft=_capData getOrDefault ["draft",createHashMap];
 private _recipe=_draft getOrDefault ["recipe",createHashMap];
 private _config=_recipe getOrDefault ["configuration",createHashMap];
 ["E capture existing succeeds",_captured getOrDefault ["success",false]] call _assert;
 ["E R3 capture invalidates stale catalog",count (missionNamespace getVariable [SP_ORG_WEAPONS_UI_CATALOG_PROJECTION_VAR,createHashMap]) isEqualTo 0] call _assert;
 private _catalogExisting=[] call ServoPeregrino_Organizador_Weapons_fnc_getUICatalogWindow;
 private _projectionExisting=missionNamespace getVariable [SP_ORG_WEAPONS_UI_CATALOG_PROJECTION_VAR,createHashMap];
 private _rowsExisting=_projectionExisting getOrDefault ["rows",[]];
 ["E R3 catalog rebuilt for captured physical weapon",_catalogExisting getOrDefault ["success",false] && {(_projectionExisting getOrDefault ["sourceWeaponClass",""]) isEqualTo "arifle_MX_F"}] call _assert;
 ["E R3 catalog slot follows captured draft",(_projectionExisting getOrDefault ["sourceSlot",""]) isEqualTo "PRIMARY"] call _assert;
 ["E R3 captured optic appears in catalog",(count (_rowsExisting select {(_x getOrDefault ["catalogKind",""]) isEqualTo "OPTIC" && {(_x getOrDefault ["catalogClass",""]) isEqualTo "optic_Hamr"}}))>0] call _assert;
 ["E capture uses actual P4 slot",(_draft getOrDefault ["targetSlot",""]) isEqualTo "PRIMARY"] call _assert;
 ["E capture stores observed weapon class",(_config getOrDefault ["weaponClass",""]) isEqualTo (_observed getOrDefault ["weaponClass",""])] call _assert;
 ["E capture preserves observed optic",(_config getOrDefault ["optic",""]) isEqualTo ((_observed getOrDefault ["configuration",createHashMap]) getOrDefault ["optic",""])] call _assert;
 ["E capture preserves observed magazine class",(_recipe getOrDefault ["magazineClass",""]) isEqualTo (_observed getOrDefault ["magazineClass",""])] call _assert;
 ["E capture changes target slot with dirty draft",_draft getOrDefault ["dirty",false] && {!((_otherDraft getOrDefault ["targetSlot",""]) isEqualTo (_draft getOrDefault ["targetSlot",""]))}] call _assert;
 ["E capture never stores round count in Recipe",isNil {_recipe get "ammoCount"} && {!(_capData getOrDefault ["ammoCountPersisted",true])}] call _assert;
 ["E capture returns transient loaded state",(_capData getOrDefault ["observedLoadedState",createHashMap]) isEqualTo (_observed getOrDefault ["loadedState",createHashMap])] call _assert;
 ["E capture did not touch live loadout",(getUnitLoadout _unit) isEqualTo _observedBefore] call _assert;
 ["E capture did not touch repository",(missionNamespace getVariable SP_ORG_WEAPONS_KIT_STORE) isEqualTo _storeAfterFixture] call _assert;
 private _savedFixtureR=[_kitId] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponKit;
 private _savedFixture=(_savedFixtureR getOrDefault ["data",createHashMap]) getOrDefault ["kit",createHashMap];
 ["E original saved WeaponKit unchanged",((_newKitR get "data") get "kit") isEqualTo _savedFixture] call _assert;
 private _beforeRepeat=[missionNamespace getVariable SP_ORG_WEAPONS_UI_STATE] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 private _again=[_unit,"PRIMARY"] call ServoPeregrino_Organizador_Weapons_fnc_captureEquippedWeaponToDraft;
 private _afterRepeat=missionNamespace getVariable SP_ORG_WEAPONS_UI_STATE;
 ["E repeated capture no change",_again getOrDefault ["success",false] && {!((_again getOrDefault ["data",createHashMap]) getOrDefault ["changed",true])}] call _assert;
 ["E repeated capture preserves revision",(((_afterRepeat get "draftsByKitId") get _kitId) getOrDefault ["revision",-1]) isEqualTo (((_beforeRepeat get "draftsByKitId") get _kitId) getOrDefault ["revision",-2])] call _assert;
 // Simulate NOVO, without writing a session kit until the explicit SAVE handler.
 _state=missionNamespace getVariable SP_ORG_WEAPONS_UI_STATE;
 _state set ["selectedKitId",""];
 _state set ["pendingNewKit",true];
 _state set ["pendingNewName","E Capture Unsaved Fixture"];
 _state set ["pendingCapturedDraft",createHashMap];
 missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
 private _fresh=[_unit,"PRIMARY"] call ServoPeregrino_Organizador_Weapons_fnc_captureEquippedWeaponToDraft;
 private _freshData=_fresh getOrDefault ["data",createHashMap];
 private _stage=(missionNamespace getVariable SP_ORG_WEAPONS_UI_STATE) getOrDefault ["pendingCapturedDraft",createHashMap];
 ["E no selection creates pending draft",_fresh getOrDefault ["success",false] && {_freshData getOrDefault ["createdNew",false]} && {count _stage>0}] call _assert;
 ["E pending Recipe carries captured weapon",(((_stage get "recipe") get "configuration") get "weaponClass") isEqualTo (_observed get "weaponClass")] call _assert;
 ["E pending has no repository kit",(missionNamespace getVariable SP_ORG_WEAPONS_KIT_STORE) isEqualTo _storeAfterFixture] call _assert;
 ["E pending state marks unsaved",((missionNamespace getVariable SP_ORG_WEAPONS_UI_STATE) getOrDefault ["selectedKitId","X"]) isEqualTo "" && {((missionNamespace getVariable SP_ORG_WEAPONS_UI_STATE) getOrDefault ["pendingNewKit",false])}] call _assert;
 private _pendingCatalog=[] call ServoPeregrino_Organizador_Weapons_fnc_getUICatalogWindow;
 private _pendingProjection=missionNamespace getVariable [SP_ORG_WEAPONS_UI_CATALOG_PROJECTION_VAR,createHashMap];
 private _pendingRows=_pendingProjection getOrDefault ["rows",[]];
 ["E R3 NOVO pending sources captured weapon",_pendingCatalog getOrDefault ["success",false] && {(_pendingProjection getOrDefault ["sourceWeaponClass",""]) isEqualTo "arifle_MX_F"}] call _assert;
 ["E R3 NOVO pending advertises correct slot",(_pendingProjection getOrDefault ["sourceSlot",""]) isEqualTo "PRIMARY"] call _assert;
 ["E R3 NOVO pending offers captured optic",_pendingRows findIf {(_x getOrDefault ["catalogKind",""]) isEqualTo "OPTIC" && {(_x getOrDefault ["catalogClass",""]) isEqualTo "optic_Hamr"}} >= 0] call _assert;
 ["E R3 NOVO pending exposes accessory rows",count (_pendingRows select {(_x getOrDefault ["catalogKind",""]) isEqualTo "BIPOD"})>0] call _assert;
 ["E R3 pending catalog has no kit mutation",(missionNamespace getVariable SP_ORG_WEAPONS_KIT_STORE) isEqualTo _storeAfterFixture] call _assert;
 private _priorPending=[_stage] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 private _alternate=[_priorPending] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 _alternate set ["recipe",(_entryRecipeR get "data") get "recipe"];
 _alternate set ["targetSlot","HANDGUN"];
 _state=missionNamespace getVariable SP_ORG_WEAPONS_UI_STATE;
 _state set ["pendingCapturedDraft",_alternate];
 missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
 private _alternateWindow=[] call ServoPeregrino_Organizador_Weapons_fnc_getUICatalogWindow;
 private _alternateProjection=missionNamespace getVariable SP_ORG_WEAPONS_UI_CATALOG_PROJECTION_VAR;
 ["E R3 pending change updates compatibility weapon",_alternateWindow getOrDefault ["success",false] && {(_alternateProjection getOrDefault ["sourceWeaponClass",""]) isEqualTo "hgun_P07_F"}] call _assert;
 _state set ["pendingCapturedDraft",_priorPending];
 missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
 private _restoredWindow=[] call ServoPeregrino_Organizador_Weapons_fnc_getUICatalogWindow;
 private _restoredProjection=missionNamespace getVariable SP_ORG_WEAPONS_UI_CATALOG_PROJECTION_VAR;
 ["E R3 pending restore recalculates catalog",_restoredWindow getOrDefault ["success",false] && {(_restoredProjection getOrDefault ["sourceWeaponClass",""]) isEqualTo "arifle_MX_F"}] call _assert;
 private _setR=["optic",""] call ServoPeregrino_Organizador_Weapons_fnc_setPendingCapturedDraftSelection;
 ["E pending compatibility edit valid",_setR getOrDefault ["success",false]] call _assert;
 ["E pending editing keeps repository",(missionNamespace getVariable SP_ORG_WEAPONS_KIT_STORE) isEqualTo _storeAfterFixture] call _assert;
 // E1 R2 regression: a physically observed modded accessory can be rejected
 // by compatibleItems even though getUnitLoadout exposes it. A bad attachment
 // must not abort the whole capture or leak into the strict canonical Recipe.
 private _incompatibleCfgR=["hgun_P07_F"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponConfiguration;
 private _sourceCfg=(_incompatibleCfgR get "data") get "configuration";
 _sourceCfg set ["optic","optic_Hamr"];
 private _sourceBefore=[_sourceCfg] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 private _invalidSemantic=[_sourceCfg] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponConfigurationSemantic;
 ["E R2 physical mismatch fixture actually rejected",!(_invalidSemantic getOrDefault ["success",true]) && {(_invalidSemantic getOrDefault ["code",""]) isEqualTo "WEAPONS_CONFIGURATION_INCOMPATIBLE"}] call _assert;
 private _prepared=[_sourceCfg,""] call ServoPeregrino_Organizador_Weapons_fnc_prepareObservedCaptureRecipe;
 private _preparedData=_prepared getOrDefault ["data",createHashMap];
 private _preparedRecipe=_preparedData getOrDefault ["recipe",createHashMap];
 private _preparedCfg=_preparedRecipe getOrDefault ["configuration",createHashMap];
 private _omissions=_preparedData getOrDefault ["omissions",[]];
 ["E R2 mismatched physical weapon still captured",_prepared getOrDefault ["success",false]] call _assert;
 ["E R2 partial capture is never presented as exact",(_prepared getOrDefault ["code",""]) isEqualTo "WEAPONS_UI_OBSERVED_CAPTURE_PARTIAL" && {_preparedData getOrDefault ["partial",false]}] call _assert;
 ["E R2 omitted accessory field and classname stated",count _omissions isEqualTo 1 && {((_omissions select 0) getOrDefault ["field",""]) isEqualTo "optic"} && {((_omissions select 0) getOrDefault ["className",""]) isEqualTo "optic_Hamr"}] call _assert;
 ["E R2 canonical Recipe retains base weapon",(_preparedCfg getOrDefault ["weaponClass",""]) isEqualTo "hgun_P07_F"] call _assert;
 ["E R2 canonical Recipe excludes incompatible optic",(_preparedCfg getOrDefault ["optic","INCOMPATIBLE"]) isEqualTo ""] call _assert;
 ["E R2 source observation remains completely unchanged",_sourceCfg isEqualTo _sourceBefore] call _assert;
 private _safeR=[_preparedRecipe] call ServoPeregrino_Organizador_Weapons_fnc_validateWeaponRecipeSemantic;
 ["E R2 canonical Recipe passes unmodified strict validator",_safeR getOrDefault ["success",false]] call _assert;
 private _unknownCfgR=["SP_ORG_Unknown_Weapon_E1R2"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponConfiguration;
 private _unknownR=[(_unknownCfgR get "data") get "configuration",""] call ServoPeregrino_Organizador_Weapons_fnc_prepareObservedCaptureRecipe;
 ["E R2 unknown weapon still rejected fail-closed",!(_unknownR getOrDefault ["success",true])] call _assert;
 private _validPrimaryR=["arifle_MX_F"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponConfiguration;
 private _incompatibleMag=[(_validPrimaryR get "data") get "configuration","16Rnd_9x21_Mag"] call ServoPeregrino_Organizador_Weapons_fnc_prepareObservedCaptureRecipe;
 private _magData=_incompatibleMag getOrDefault ["data",createHashMap];
 private _magOmissions=_magData getOrDefault ["omissions",[]];
 ["E R2 incompatible magazine does not block weapon",_incompatibleMag getOrDefault ["success",false]] call _assert;
 ["E R2 incompatible magazine omission is explicit",count _magOmissions isEqualTo 1 && {((_magOmissions select 0) getOrDefault ["field",""]) isEqualTo "magazineClass"}] call _assert;
 ["E R2 incompatible magazine omitted from Recipe",((_magData getOrDefault ["recipe",createHashMap]) getOrDefault ["magazineClass","X"]) isEqualTo ""] call _assert;
 // Use a real UI SAVE, which must be the ONLY action that creates the new kit.
 [] call ServoPeregrino_Organizador_Weapons_fnc_openInterface;
 [] call ServoPeregrino_Organizador_Weapons_fnc_refreshInterface;
 private _display=findDisplay SP_ORG_WEAPONS_UI_DISPLAY_IDD;
 ["E capture control exists",!isNull (_display displayCtrl 4123)] call _assert;
 private _p4Slot=(missionNamespace getVariable SP_ORG_WEAPONS_UI_STATE) getOrDefault ["equipmentSlotView","PRIMARY"];
 private _playerSnapshotR=[player,_p4Slot] call ServoPeregrino_Organizador_Weapons_fnc_getEquipmentSlotSnapshot;
 private _playerSnapshot=(_playerSnapshotR getOrDefault ["data",createHashMap]) getOrDefault ["snapshot",createHashMap];
 ["E P4 capture button matches occupied slot",(ctrlEnabled (_display displayCtrl 4123)) isEqualTo (_playerSnapshot getOrDefault ["equipped",false])] call _assert;
 (_display displayCtrl 2001) ctrlSetText "E Capture Unsaved Fixture";
 ["SAVE_DRAFT"] call ServoPeregrino_Organizador_Weapons_fnc_handleUIEvent;
 private _savedState=missionNamespace getVariable SP_ORG_WEAPONS_UI_STATE;
 private _savedId=_savedState getOrDefault ["selectedKitId",""];
 private _savedR=if (_savedId isNotEqualTo "") then {[_savedId] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponKit} else {createHashMap};
 ["E explicit SAVE creates one WeaponKit",_savedId isNotEqualTo "" && {_savedR getOrDefault ["success",false]}] call _assert;
 ["E save clears transient pending",!(_savedState getOrDefault ["pendingNewKit",true]) && {count (_savedState getOrDefault ["pendingCapturedDraft",createHashMap]) isEqualTo 0}] call _assert;
 private _savedKit=(_savedR getOrDefault ["data",createHashMap]) getOrDefault ["kit",createHashMap];
 private _savedRecipe=_savedKit getOrDefault ["recipe",createHashMap];
 private _editedDraft=(_setR getOrDefault ["data",createHashMap]) getOrDefault ["draft",createHashMap];
 ["E saved Recipe matches pending edit",_savedRecipe isEqualTo (_editedDraft getOrDefault ["recipe",createHashMap])] call _assert;
 ["E SAVE did not touch player",(getUnitLoadout player) isEqualTo _playerBefore] call _assert;
 ["E SAVE did not touch isolated target",(getUnitLoadout _unit) isEqualTo _observedBefore] call _assert;
 // An empty selected slot fails without altering pending draft/repository.
 private _beforeEmpty=[missionNamespace getVariable SP_ORG_WEAPONS_UI_STATE] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
 private _empty=[_unit,"SECONDARY"] call ServoPeregrino_Organizador_Weapons_fnc_captureEquippedWeaponToDraft;
 ["E empty slot refused",!(_empty getOrDefault ["success",true]) && {(_empty getOrDefault ["code",""]) isEqualTo "WEAPONS_UI_CAPTURE_SLOT_EMPTY"}] call _assert;
 ["E empty slot did not alter state",(missionNamespace getVariable SP_ORG_WEAPONS_UI_STATE) isEqualTo _beforeEmpty] call _assert;
 ["E empty slot did not alter physical state",(getUnitLoadout _unit) isEqualTo _observedBefore] call _assert;
};
[] call _test;
if (!isNull _unit) then {deleteVehicle _unit};
private _deadline=diag_tickTime+5;
waitUntil {sleep 0.01;isNull _unit || {diag_tickTime>=_deadline}};
["E isolated target removed",isNull _unit] call _assert;
deleteGroup _group;
["E final player loadout preserved",(getUnitLoadout player) isEqualTo _playerBefore] call _assert;
missionNamespace setVariable [SP_ORG_WEAPONS_KIT_STORE,_storeBefore];
missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_stateBefore];
[] call ServoPeregrino_Organizador_Weapons_fnc_refreshInterface;
private _lp={_x select 1} count _checks;
private _lb={(_x param [2,""]) isEqualTo "BLOCKED"} count _checks;
private _lf=count _checks-_lp-_lb;
private _passed=(_ld getOrDefault ["passed",0])+_lp;
private _failed=(_ld getOrDefault ["failed",1])+_lf;
private _total=(_ld getOrDefault ["total",0])+count _checks;
diag_log format ["[SP_ORG] [WEAPONS] [AUTO_TEST_SUMMARY] mode=MISSION_FIRST_0_7_E_R3 passed=%1 failed=%2 blocked=%3 total=%4 expected=%5",_passed,_failed,_lb+(_ld getOrDefault ["blocked",0]),_total,1420];
hint format ["Weapons 0.7-E R3: %1/%2; falhas=%3; bloqueados=%4. Envie o RPT completo.",_passed,_total,_failed,_lb+(_ld getOrDefault ["blocked",0])];
[_failed isEqualTo 0 && {_lb isEqualTo 0} && {_total isEqualTo 1420},"WEAPONS_0_7_E_R3_AUTO_TEST_COMPLETE","E capture tests; Arma runtime/manual approval pending.",createHashMapFromArray [
 ["passed",_passed],["failed",_failed],["blocked",_lb+(_ld getOrDefault ["blocked",0])],["total",_total],
 ["expected",1420],["checks",_checks],["manual","PENDING"]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
