#include "..\..\script_version.hpp"
disableSerialization;
params [["_reason","EQUIPMENT_FOCUSED",[""]]];

private _display = findDisplay SP_ORG_WEAPONS_UI_DISPLAY_IDD;
if (isNull _display) exitWith {[false,"WEAPONS_UI_NOT_OPEN","Weapons UI is not open."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
if (_state getOrDefault ["equipmentRefreshInProgress",false]) exitWith {[true,"WEAPONS_UI_EQUIPMENT_REFRESH_REENTRANT_SKIPPED","Nested equipment-focused refresh ignored."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
_state set ["equipmentRefreshInProgress",true];
missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
private _startedAt = diag_tickTime;
private _slot = toUpperANSI (_state getOrDefault ["equipmentSlotView","PRIMARY"]);
if !(_slot in ["PRIMARY","HANDGUN","SECONDARY"]) then {_slot="PRIMARY"};
private _slotLabel = {params ["_s"];[_s] call ServoPeregrino_Organizador_Weapons_fnc_getUISlotLabel};
private _query = _state getOrDefault ["equipmentQuery",""];
private _equipmentSearchCtrl = _display displayCtrl 4100;
if ((ctrlText _equipmentSearchCtrl) isNotEqualTo _query) then {_equipmentSearchCtrl ctrlSetText _query};

private _snapshotResult = [player,_slot] call ServoPeregrino_Organizador_Weapons_fnc_getEquipmentSlotSnapshot;
private _eq = if (_snapshotResult get "success") then {(_snapshotResult get "data") get "snapshot"} else {createHashMap};
{
 _x params ["_idc","_value"];
 (_display displayCtrl _idc) ctrlSetBackgroundColor (if (_value isEqualTo _slot) then {[0.08,0.38,0.30,0.76]} else {[0.08,0.11,0.12,0.58]});
} forEach [[4011,"PRIMARY"],[4012,"HANDGUN"],[4013,"SECONDARY"]];
(_display displayCtrl 104) ctrlSetText format ["Equipamento: %1",[_slot] call _slotLabel];

if ((count _eq) isEqualTo 0 || {!(_eq getOrDefault ["equipped",false])}) then {
 (_display displayCtrl 4020) ctrlSetText "";
 (_display displayCtrl 4021) ctrlSetText "Nenhuma arma equipada";
 (_display displayCtrl 4022) ctrlSetText "-";
 {(_display displayCtrl _x) ctrlSetText "Nenhum"} forEach [4031,4033,4035,4037,4039];
 (_display displayCtrl 4040) ctrlSetStructuredText parseText format ["<t color='#8FAAA4'>%1 sem arma equipada.<br/><br/>Este painel é somente leitura; aplicação física permanece em 0.7.</t>",[_slot] call _slotLabel];
} else {
 private _weaponInfo = _eq getOrDefault ["weaponInfo",createHashMap];
 (_display displayCtrl 4020) ctrlSetText (_weaponInfo getOrDefault ["picture",""]);
 (_display displayCtrl 4021) ctrlSetText (_weaponInfo getOrDefault ["displayName",_eq getOrDefault ["weaponClass",""]]);
 (_display displayCtrl 4022) ctrlSetText (_eq getOrDefault ["weaponClass",""]);
 {
  _x params ["_idc","_key"];
  private _info = _eq getOrDefault [_key,createHashMap];
  (_display displayCtrl _idc) ctrlSetText (_info getOrDefault ["displayName","Nenhum"]);
  (_display displayCtrl _idc) ctrlSetTooltip (_info getOrDefault ["className",""]);
 } forEach [[4031,"opticInfo"],[4033,"muzzleInfo"],[4035,"pointerInfo"],[4037,"bipodInfo"],[4039,"magazineInfo"]];
 private _loaded = _eq getOrDefault ["loadedState",createHashMap];
 private _mag = _loaded getOrDefault ["primaryMagazine",[]];
 private _ammoText = if (_mag isEqualType [] && {count _mag>=2}) then {format ["%1 munição(ões) observada(s)",_mag#1]} else {"Estado de munição não informado"};
 (_display displayCtrl 4040) ctrlSetStructuredText parseText format ["<t color='#CDE7E1'>EQUIPADO · %1</t><br/><t color='#8FB7B0'>%2</t><br/><br/>%3<br/>Comparação/aplicação física continua reservada para 0.7.",[_slot] call _slotLabel,[_eq getOrDefault ["weaponClass",""]] call ServoPeregrino_Organizador_Weapons_fnc_escapeStructuredText,_ammoText];
};

// Local P4 search filters only fields rendered in CONTEÚDO DO EQUIPAMENTO.
private _equipmentQueryLower = toLowerANSI _query;
private _weaponInfoNow = _eq getOrDefault ["weaponInfo",createHashMap];
private _weaponHaystack = format ["arma %1 %2",
 _weaponInfoNow getOrDefault ["displayName",_eq getOrDefault ["weaponClass",""]],
 _eq getOrDefault ["weaponClass",""]
];
private _weaponVisible = _equipmentQueryLower isEqualTo "" || {(toLowerANSI _weaponHaystack) find _equipmentQueryLower >= 0};
{(_display displayCtrl _x) ctrlShow _weaponVisible} forEach [4020,4021,4022];

private _eqRows = [
 [[4030,4031],"mira optic ótica","opticInfo"],
 [[4032,4033],"boca muzzle","muzzleInfo"],
 [[4034,4035],"apontador pointer laser","pointerInfo"],
 [[4036,4037],"bipé bipe empunhadura grip","bipodInfo"],
 [[4038,4039],"carregador magazine","magazineInfo"]
];
{
 _x params ["_idcs","_keywords","_infoKey"];
 private _info = _eq getOrDefault [_infoKey,createHashMap];
 private _haystack = format ["%1 %2 %3",_keywords,_info getOrDefault ["displayName",""],_info getOrDefault ["className",""]];
 private _visible = _equipmentQueryLower isEqualTo "" || {(toLowerANSI _haystack) find _equipmentQueryLower >= 0};
 {(_display displayCtrl _x) ctrlShow _visible} forEach _idcs;
} forEach _eqRows;

_state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
private _elapsed=round ((diag_tickTime-_startedAt)*1000);
_state set ["equipmentSlotView",_slot];
_state set ["equipmentRefreshInProgress",false];
_state set ["equipmentFocusedRefreshCount",(_state getOrDefault ["equipmentFocusedRefreshCount",0])+1];
_state set ["lastEquipmentFocusedRefreshDurationMs",_elapsed];
_state set ["lastRefreshMode","EQUIPMENT_FOCUSED"];
_state set ["lastRefreshTick",diag_tickTime];
missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];

diag_log format ["[SP_ORG] [WEAPONS] [UI_PERF] mode=EQUIPMENT_FOCUSED reason=%1 totalMs=%2 slot=%3 fullRefresh=false",toUpperANSI _reason,_elapsed,_slot];
[true,"WEAPONS_UI_EQUIPMENT_FOCUSED_REFRESHED","Conteúdo do equipamento atualizado sem reconstruir Kit/Catálogo.",createHashMapFromArray [["refreshMs",_elapsed],["slot",_slot],["fullRefresh",false]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
