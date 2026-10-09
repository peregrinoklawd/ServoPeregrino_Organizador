#include "..\..\script_version.hpp"
// Laboratory-only, read-only compatibility triangulation. The isolated dummy
// is expendable; never set the player's loadout or rewrite compatibility policy.
params [
 ["_unit",objNull,[objNull]],
 ["_slot","PRIMARY",[""]],
 ["_additionalUnderbarrel",[],[[]]]
];
private _slotU=toUpperANSI _slot;
if (isNull _unit || {!local _unit} || {!(_slotU in ["PRIMARY","HANDGUN","SECONDARY"])}) exitWith {
 [false,"WEAPONS_COMPAT_AUDIT_TARGET_INVALID","Select a local player and valid weapon slot."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _snapshotR=[_unit,_slotU] call ServoPeregrino_Organizador_Weapons_fnc_getEquipmentSlotSnapshot;
if !(_snapshotR getOrDefault ["success",false]) exitWith {_snapshotR};
private _snap=(_snapshotR get "data") get "snapshot";
if !(_snap getOrDefault ["equipped",false]) exitWith {
 [false,"WEAPONS_COMPAT_AUDIT_NO_WEAPON","Equipe uma arma neste slot antes de executar o diagnóstico."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _configuration=_snap get "configuration";
private _weapon=_configuration getOrDefault ["weaponClass",""];
private _weaponCfg=configFile >> "CfgWeapons" >> _weapon;
private _baseClass=getText (_weaponCfg >> "baseWeapon");
if (_baseClass isEqualTo "") then {_baseClass=_weapon};
private _weaponSamples=[_weapon];
if ((toLowerANSI _baseClass) isNotEqualTo (toLowerANSI _weapon)) then {_weaponSamples pushBack _baseClass};
private _state=missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
private _kitId=_state getOrDefault ["selectedKitId",""];
private _draft=if (_kitId isEqualTo "" && {_state getOrDefault ["pendingNewKit",false]}) then {
 _state getOrDefault ["pendingCapturedDraft",createHashMap]
} else {
 (_state getOrDefault ["draftsByKitId",createHashMap]) getOrDefault [_kitId,createHashMap]
};
private _draftCfg=(_draft getOrDefault ["recipe",createHashMap]) getOrDefault ["configuration",createHashMap];
private _draftWeapon=_draftCfg getOrDefault ["weaponClass",""];
private _projection=missionNamespace getVariable [SP_ORG_WEAPONS_UI_CATALOG_PROJECTION_VAR,createHashMap];
private _projectedWeapon=_projection getOrDefault ["sourceWeaponClass",""];
private _catalogStale = (_draftWeapon isNotEqualTo "") && {(toLowerANSI _draftWeapon) isNotEqualTo (toLowerANSI _projectedWeapon)};
diag_log format ["[SP_ORG] [WEAPONS] [COMPAT_AUDIT_CONTEXT] slot=%1 physicalWeapon=%2 baseWeapon=%3 draftWeapon=%4 catalogProjectedWeapon=%5 catalogStale=%6 selectedKitId=%7 pendingNew=%8",_slotU,_weapon,_baseClass,_draftWeapon,_projectedWeapon,_catalogStale,_kitId,_state getOrDefault ["pendingNewKit",false]];

private _candidates=[];
private _addCandidate={
 params ["_item"];
 if (_item isEqualType "" && {_item isNotEqualTo ""}) then {
  if ((_candidates findIf {(toLowerANSI _x) isEqualTo (toLowerANSI _item)})<0) then {_candidates pushBack _item};
 };
};
[_configuration getOrDefault ["bipod",""]] call _addCandidate;
{[_x] call _addCandidate} forEach _additionalUnderbarrel;
private _rows=[];
private _cfgRoot=configFile >> "CfgWeapons";
private _containsCI={
 params ["_list","_className"];
 (count (_list select {(toLowerANSI _x) isEqualTo (toLowerANSI _className)}))>0
};
private _compatibleLists=[];
{
 private _w=_x;
 private _engine=compatibleItems [_w,"UnderBarrelSlot"];
 private _cba=[];
 private _bis=[];
 if !(isNil "CBA_fnc_compatibleItems") then {
  _cba=[_w,"bipod"] call CBA_fnc_compatibleItems;
 };
 if !(isNil "BIS_fnc_compatibleItems") then {
  _bis=_w call BIS_fnc_compatibleItems;
 };
 if !(_cba isEqualType []) then {_cba=[]};
 if !(_bis isEqualType []) then {_bis=[]};
 _compatibleLists pushBack (createHashMapFromArray [
  ["weapon",_w],["vanilla",_engine],["cba",_cba],["bis",_bis]
 ]);
 diag_log format ["[SP_ORG] [WEAPONS] [COMPAT_AUDIT_LISTS] weapon=%1 vanillaCount=%2 cbaCount=%3 bisCount=%4 vanillaMinusCBA=%5 cbaMinusVanilla=%6",_w,count _engine,count _cba,count _bis,_engine-(_cba),_cba-(_engine)];
} forEach _weaponSamples;
private _primaryList=_compatibleLists param [0,createHashMap];
{
 private _item=_x;
 private _itemCfg=_cfgRoot >> _item;
 private _engineItems=_primaryList getOrDefault ["vanilla",[]];
 private _cbaItems=_primaryList getOrDefault ["cba",[]];
 private _bisItems=_primaryList getOrDefault ["bis",[]];
 private _engineOkay=[_engineItems,_item] call _containsCI;
 private _cbaOkay=[_cbaItems,_item] call _containsCI;
 private _bisOkay=[_bisItems,_item] call _containsCI;
 private _rawSlotCfg=_weaponCfg >> "WeaponSlotsInfo" >> "UnderBarrelSlot";
 private _rawCompat=getArray (_rawSlotCfg >> "compatibleItems");
 private _rawOkay=[_rawCompat,_item] call _containsCI;
 private _baseEngineItems=if ((count _compatibleLists)>1) then {(_compatibleLists select 1) getOrDefault ["vanilla",[]]} else {[]};
 private _baseCbaItems=if ((count _compatibleLists)>1) then {(_compatibleLists select 1) getOrDefault ["cba",[]]} else {[]};
 private _entry=createHashMapFromArray [
  ["className",_item],["classExists",isClass _itemCfg],
  ["itemScope",if (isClass _itemCfg) then {getNumber (_itemCfg >> "scope")} else {-1}],
  ["observedOnPhysical",(toLowerANSI (_configuration getOrDefault ["bipod",""])) isEqualTo (toLowerANSI _item)],
  ["vanilla",_engineOkay],["cba",_cbaOkay],["bis",_bisOkay],
  ["rawConfig",_rawOkay],
  ["vanillaBase",[_baseEngineItems,_item] call _containsCI],
  ["cbaBase",[_baseCbaItems,_item] call _containsCI],
  ["engineRetainedImmediate",false],["engineRetainedStable",false],
  ["isolatedTestRan",false]
 ];
 _rows pushBack _entry;
} forEach _candidates;

// Engine setUnitLoadout experiment: CREATE a fresh local dummy, use its own
// loadout plus a weapon row copied from the player. NEVER test on player.
private _dummy=objNull;
private _group=grpNull;
if (_slotU isEqualTo "PRIMARY" && {canSuspend}) then {
 _group=createGroup [west,true];
 _dummy=_group createUnit ["B_Soldier_F",(getPosATL _unit) vectorAdd [0,0,-50],[],0,"NONE"];
 if (!isNull _dummy && {local _dummy}) then {
  _dummy hideObject true;
  _dummy allowDamage false;
  _dummy enableSimulation false;
  private _unitLoad=getUnitLoadout _unit;
  private _observedRow=_unitLoad param [0,[]];
  {
   private _entry=_x;
   private _sample=_entry getOrDefault ["className",""];
   if (_entry getOrDefault ["classExists",false] && {(count _observedRow)>6}) then {
    private _testRow=+_observedRow;
    _testRow set [6,_sample];
    private _isolatedLoad=[getUnitLoadout _dummy] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy;
    _isolatedLoad set [0,_testRow];
    _dummy setUnitLoadout [_isolatedLoad,false];
    private _instant=((getUnitLoadout _dummy) param [0,[]]) param [6,""];
    uiSleep 0.15;
    private _stable=((getUnitLoadout _dummy) param [0,[]]) param [6,""];
    _entry set ["isolatedTestRan",true];
    _entry set ["engineRetainedImmediate",(toLowerANSI _instant) isEqualTo (toLowerANSI _sample)];
    _entry set ["engineRetainedStable",(toLowerANSI _stable) isEqualTo (toLowerANSI _sample)];
    diag_log format ["[SP_ORG] [WEAPONS] [COMPAT_AUDIT_ISOLATED] weapon=%1 candidate=%2 instant=%3 stable=%4 matched=%5",_weapon,_sample,_instant,_stable,_entry get "engineRetainedStable"];
   };
  } forEach _rows;
 };
};
// Object deletion may finish on a later simulation frame. Do not claim
// that an isolated diagnostic dummy was removed until the engine confirms.
if (!isNull _dummy) then {
 deleteVehicle _dummy;
 private _deadline=diag_tickTime+5;
 waitUntil {uiSleep 0.02;isNull _dummy || {diag_tickTime>=_deadline}};
};
private _isolatedDeleted=isNull _dummy;
if (_isolatedDeleted && {!isNull _group}) then {deleteGroup _group};
{
 diag_log format ["[SP_ORG] [WEAPONS] [COMPAT_AUDIT_ITEM] weapon=%1 item=%2 result=%3",_weapon,_x getOrDefault ["className",""],_x];
} forEach _rows;
diag_log format ["[SP_ORG] [WEAPONS] [COMPAT_AUDIT_SUMMARY] weapon=%1 slot=%2 candidates=%3 isolatedDummyDeleted=%4 playerLoadoutMutated=false",_weapon,_slotU,count _rows,_isolatedDeleted];
[_isolatedDeleted,"WEAPONS_COMPAT_AUDIT_COMPLETED","Comparação Arma/CBA/BIS concluída. Unidade temporária removida apenas após confirmação; nenhuma alteração do equipamento do jogador.",createHashMapFromArray [
 ["weaponClass",_weapon],["baseWeapon",_baseClass],["slot",_slotU],["rows",_rows],
 ["sources",_compatibleLists],["draftWeapon",_draftWeapon],["projectedWeapon",_projectedWeapon],["catalogStale",_catalogStale],
 ["playerMutation",false],["isolatedDummyDeleted",_isolatedDeleted]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
