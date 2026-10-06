#include "..\..\script_version.hpp"
disableSerialization;

private _display = findDisplay SP_ORG_WEAPONS_UI_DISPLAY_IDD;
if (isNull _display) exitWith {
 [false,"WEAPONS_UI_NOT_OPEN","Weapons UI is not open."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
if ((count _state) isEqualTo 0) then {
 [] call ServoPeregrino_Organizador_Weapons_fnc_createUIState;
 _state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
};

_state set ["refreshRequestCount",(_state getOrDefault ["refreshRequestCount",0]) + 1];
if (_state getOrDefault ["refreshInProgress",false]) exitWith {
 missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
 [true,"WEAPONS_UI_REFRESH_REENTRANT_SKIPPED","Nested UI refresh ignored.",createHashMapFromArray [
  ["refreshRequestCount",_state getOrDefault ["refreshRequestCount",0]],
  ["refreshAppliedCount",_state getOrDefault ["refreshAppliedCount",0]]
 ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

_state set ["refreshInProgress",true];
missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
private _refreshStarted = diag_tickTime;

private _vmResult = [] call ServoPeregrino_Organizador_Weapons_fnc_buildUIViewModel;
if !(_vmResult get "success") exitWith {
 private _failedState = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
 _failedState set ["refreshInProgress",false];
 missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_failedState];
 _vmResult
};
private _vm = _vmResult get "data";
_state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];

private _slotLabel = {
 params ["_slot"];
 [_slot] call ServoPeregrino_Organizador_Weapons_fnc_getUISlotLabel
};
private _displayNameForClass = {
 params ["_root","_class","_none"];
 if (_class isEqualTo "") exitWith {_none};
 private _cfg = _root >> _class;
 if (!isClass _cfg) exitWith {_class};
 private _name = getText (_cfg >> "displayName");
 if (_name isEqualTo "") then {_class} else {_name}
};
private _setComboPlaceholder = {
 params ["_idc","_label","_tooltip"];
 private _ctrl = _display displayCtrl _idc;
 lbClear _ctrl;
 private _idx = _ctrl lbAdd _label;
 _ctrl lbSetData [_idx,""];
 _ctrl lbSetTooltip [_idx,_tooltip];
 _ctrl lbSetCurSel _idx;
 _ctrl ctrlSetTooltip _tooltip;
 _ctrl ctrlEnable false;
};
private _populateCompatibilityCombo = {
 params ["_idc","_selector","_tooltip"];
 private _ctrl = _display displayCtrl _idc;
 lbClear _ctrl;
 private _selectedIndex = _selector getOrDefault ["selectedIndex",-1];
 private _options = _selector getOrDefault ["options",[]];
 {
  private _idx = _ctrl lbAdd (_x getOrDefault ["displayName",_x getOrDefault ["className",""]]);
  private _className = _x getOrDefault ["className",""];
  _ctrl lbSetData [_idx,_className];
  _ctrl lbSetTooltip [_idx,if (_className isEqualTo "") then {_tooltip + " | Nenhum"} else {format ["%1 | Classe: %2",_tooltip,_className]}];
 } forEach _options;
 if (_selectedIndex < 0 || {_selectedIndex >= count _options}) then {_selectedIndex = 0};
 if ((count _options) > 0) then {_ctrl lbSetCurSel _selectedIndex};
 _ctrl ctrlSetTooltip _tooltip;
 _ctrl ctrlEnable ((count _options) > 0);
};
private _kindValue = {
 params ["_kind"];
 switch (toUpperANSI _kind) do {
  case "WEAPON": {0};
  case "OPTIC": {1};
  case "POINTER": {2};
  case "BIPOD": {3};
  case "MAGAZINE": {4};
  case "GRIP": {5};
  default {-1};
 }
};

(_display displayCtrl 101) ctrlSetText format ["Operador: %1",name player];
private _groupId = groupId (group player);
if (_groupId isEqualTo "") then {_groupId = "-"};
(_display displayCtrl 103) ctrlSetText format ["Unidade: %1",_groupId];

// 0.6-F R5: each panel owns its own search state.
private _kitSearchCtrl = _display displayCtrl 1100;
if ((ctrlText _kitSearchCtrl) isNotEqualTo (_state getOrDefault ["kitQuery",""])) then {_kitSearchCtrl ctrlSetText (_state getOrDefault ["kitQuery",""])};
private _draftSearchCtrl = _display displayCtrl 2051;
if ((ctrlText _draftSearchCtrl) isNotEqualTo (_state getOrDefault ["draftQuery",""])) then {_draftSearchCtrl ctrlSetText (_state getOrDefault ["draftQuery",""])};
private _catalogSearchCtrl = _display displayCtrl 3100;
if ((ctrlText _catalogSearchCtrl) isNotEqualTo (_state getOrDefault ["catalogQuery",""])) then {_catalogSearchCtrl ctrlSetText (_state getOrDefault ["catalogQuery",""])};
private _equipmentSearchCtrl = _display displayCtrl 4100;
if ((ctrlText _equipmentSearchCtrl) isNotEqualTo (_state getOrDefault ["equipmentQuery",""])) then {_equipmentSearchCtrl ctrlSetText (_state getOrDefault ["equipmentQuery",""])};
private _catalogSearchGlobal = (_state getOrDefault ["catalogQuery",""]) isNotEqualTo "";

// Filter visuals.
private _kitFilter = toUpperANSI (_state getOrDefault ["kitTypeFilter","ALL"]);
{
 _x params ["_idc","_value"];
 (_display displayCtrl _idc) ctrlSetBackgroundColor (if (_value isEqualTo _kitFilter) then {[0.12,0.32,0.38,0.76]} else {[0.08,0.11,0.12,0.58]});
} forEach [[1103,"ALL"],[1104,"PRIMARY"],[1105,"HANDGUN"],[1106,"SECONDARY"]];
(_display displayCtrl 1107) ctrlEnable false;

private _catalogType = toUpperANSI (_state getOrDefault ["catalogTypeFilter","ALL"]);
{
 _x params ["_idc","_value"];
 (_display displayCtrl _idc) ctrlSetBackgroundColor (if (!_catalogSearchGlobal && {_value isEqualTo _catalogType}) then {[0.12,0.32,0.38,0.76]} else {[0.08,0.11,0.12,0.58]});
} forEach [[3111,"ALL"],[3112,"PRIMARY"],[3113,"HANDGUN"],[3114,"SECONDARY"]];

private _catalogKind = toUpperANSI (_state getOrDefault ["catalogCategoryFilter","ALL"]);
{
 _x params ["_idc","_value"];
 (_display displayCtrl _idc) ctrlSetBackgroundColor (if (!_catalogSearchGlobal && {_value isEqualTo _catalogKind}) then {[0.08,0.38,0.30,0.76]} else {[0.08,0.11,0.12,0.58]});
} forEach [[3132,"ALL"],[3133,"WEAPON"],[3134,"OPTIC"],[3135,"POINTER"],[3136,"BIPOD"],[3137,"MAGAZINE"],[3138,"GRIP"]];

private _equipmentSlot = toUpperANSI (_vm getOrDefault ["equipmentSlotView","PRIMARY"]);
{
 _x params ["_idc","_value"];
 (_display displayCtrl _idc) ctrlSetBackgroundColor (if (_value isEqualTo _equipmentSlot) then {[0.08,0.38,0.30,0.76]} else {[0.08,0.11,0.12,0.58]});
} forEach [[4011,"PRIMARY"],[4012,"HANDGUN"],[4013,"SECONDARY"]];
(_display displayCtrl 104) ctrlSetText format ["Equipamento: %1",[_equipmentSlot] call _slotLabel];
// MEUS KITS DE ARMAS.
private _kitsCtrl = _display displayCtrl 1110;
lbClear _kitsCtrl;
private _selectedKitId = _vm getOrDefault ["selectedKitId",""];
// R2 Hotfix 1: P2 must render the selection resolved by the current kit projection.
// This is especially important for pending NOVO (selectedKitId intentionally empty)
// and for a kit search/filter that projects no selected kit.
private _resolvedState = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
if ((_resolvedState getOrDefault ["selectedKitId",""]) isNotEqualTo _selectedKitId) then {
 _resolvedState set ["selectedKitId",_selectedKitId];
 if (_selectedKitId isEqualTo "") then {_resolvedState set ["activeDraftKitId",""]};
 missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_resolvedState];
 _state = _resolvedState;
};
private _kitSelIndex = -1;
{
 private _idx = _kitsCtrl lbAdd (_x getOrDefault ["name","Sem nome"]);
 private _id = _x getOrDefault ["kitId",""];
 _kitsCtrl lbSetData [_idx,_id];
 private _recipe = _x getOrDefault ["recipe",createHashMap];
 private _cfg = _recipe getOrDefault ["configuration",createHashMap];
 private _wc = _cfg getOrDefault ["weaponClass",""];
 private _wn = [configFile >> "CfgWeapons",_wc,_wc] call _displayNameForClass;
 _kitsCtrl lbSetTooltip [_idx,format ["%1 | Tipo: %2 | Arma: %3 | Classe: %4",_x getOrDefault ["name",""],[(_x getOrDefault ["targetSlot",""])] call _slotLabel,_wn,_wc]];
 if (_id isEqualTo _selectedKitId) then {_kitSelIndex = _idx};
} forEach (_vm getOrDefault ["kits",[]]);
if (_kitSelIndex >= 0) then {_kitsCtrl lbSetCurSel _kitSelIndex};

// ARMAS DO KIT — R2 delegates panel-specific rendering to the focused renderer so
// pending NOVO, inline name, status and search semantics have one source of truth.
["FULL"] call ServoPeregrino_Organizador_Weapons_fnc_refreshDraftUI;

// CATÁLOGO DE ARMAS — continuous window + explicit Items-style slider.
private _catCtrl = _display displayCtrl 3120;
lbClear _catCtrl;
private _selectedCatalogClass = _vm getOrDefault ["selectedCatalogClass",""];
private _selectedCatalogKind = _vm getOrDefault ["selectedCatalogKind",""];
private _catSelIndex = -1;
{
 private _kind = _x getOrDefault ["catalogKind",""];
 private _kindLabel = _x getOrDefault ["catalogKindLabel",""];
 private _class = _x getOrDefault ["catalogClass",""];
 private _label = format ["←  %1  |  %2  →",_kindLabel,_x getOrDefault ["displayName",_class]];
 private _idx = _catCtrl lbAdd _label;
 _catCtrl lbSetData [_idx,_class];
 _catCtrl lbSetValue [_idx,[_kind] call _kindValue];
 private _picture = _x getOrDefault ["picture",""];
 if (_picture isNotEqualTo "") then {_catCtrl lbSetPicture [_idx,_picture]};
 private _mods = _x getOrDefault ["sourceMods",[]];
 private _addons = _x getOrDefault ["sourceAddons",[]];
 private _origin = if ((count _mods)>0) then {_mods joinString ", "} else {if ((count _addons)>0) then {_addons joinString ", "} else {"Origem não informada"}};
 _catCtrl lbSetTooltip [_idx,format ["%1 | %2 | Classe: %3 | Tipo: %4 | Origem: %5",_kindLabel,_x getOrDefault ["displayName",""],_class,[(_x getOrDefault ["targetSlot",""])] call _slotLabel,_origin]];
 if ((toLowerANSI _class) isEqualTo (toLowerANSI _selectedCatalogClass) && {(toUpperANSI _kind) isEqualTo (toUpperANSI _selectedCatalogKind)}) then {_catSelIndex = _idx};
} forEach (_vm getOrDefault ["catalog",[]]);
if (_catSelIndex >= 0) then {_catCtrl lbSetCurSel _catSelIndex};

private _catalogOffset = _vm getOrDefault ["catalogOffset",0];
private _catalogMatchCount = _vm getOrDefault ["catalogMatchCount",0];
private _catalogRenderedCount = _vm getOrDefault ["catalogRenderedCount",0];
private _catalogMaxOffset = _vm getOrDefault ["catalogMaxOffset",0];
private _catalogWindowSize = _vm getOrDefault ["catalogWindowSize",SP_ORG_WEAPONS_UI_CATALOG_WINDOW_SIZE];
private _lastShown = (_catalogOffset + _catalogRenderedCount) min _catalogMatchCount;
(_display displayCtrl 3122) ctrlSetText (
 if (_catalogMatchCount isEqualTo 0) then {
  if (_catalogSearchGlobal) then {"Nenhum resultado · busca global (filtros ignorados)"} else {"Nenhum resultado"}
 } else {
  format ["Mostrando %1 a %2 de %3%4",_catalogOffset+1,_lastShown,_catalogMatchCount,if (_catalogSearchGlobal) then {" · busca global"} else {""}]
 }
);
private _slider = _display displayCtrl 3124;
[_slider,_catalogOffset,_catalogMatchCount,_catalogWindowSize,6,12,true] call ServoPeregrino_Organizador_UICommon_fnc_syncVirtualSlider;

private _selectedCatalog = _vm getOrDefault ["selectedCatalog",createHashMap];
private _catalogDetails = "Selecione um item. ← envia para ARMAS DO KIT; → permanece reservado para aplicação física em 0.7.";
if ((count _selectedCatalog)>0) then {
 private _dn = [_selectedCatalog getOrDefault ["displayName",""]] call ServoPeregrino_Organizador_Weapons_fnc_escapeStructuredText;
 private _kindLabelSafe = [_selectedCatalog getOrDefault ["catalogKindLabel",""]] call ServoPeregrino_Organizador_Weapons_fnc_escapeStructuredText;
 private _classSafe = [_selectedCatalog getOrDefault ["catalogClass",""]] call ServoPeregrino_Organizador_Weapons_fnc_escapeStructuredText;
 private _descSafe = [_selectedCatalog getOrDefault ["descriptionShort",""]] call ServoPeregrino_Organizador_Weapons_fnc_escapeStructuredText;
 private _compatClass = _selectedCatalog getOrDefault ["compatibleWithWeaponClass",""];
 private _compatLine = if (_compatClass isEqualTo "") then {""} else {format ["<br/><t color='#8FB7B0'>Compatível com: %1</t>",[_compatClass] call ServoPeregrino_Organizador_Weapons_fnc_escapeStructuredText]};
 _catalogDetails = format ["<t size='1.05' color='#CDE7E1'>%1</t><br/>%2 · Classe: %3%4%5",_dn,_kindLabelSafe,_classSafe,_compatLine,if (_descSafe isEqualTo "") then {""} else {format ["<br/>%1",_descSafe]}];
};
(_display displayCtrl 3130) ctrlSetStructuredText parseText _catalogDetails;
private _hasCatalogSelection=(count _selectedCatalog)>0;
(_display displayCtrl 3150) ctrlEnable _hasCatalogSelection;
(_display displayCtrl 3151) ctrlEnable false;
(_display displayCtrl 3151) ctrlSetTooltip "Aplicação física slot-safe será habilitada em Weapons 0.7.";

// CONTEÚDO DO EQUIPAMENTO — read-only current physical state.
private _eq = _vm getOrDefault ["equipmentSnapshot",createHashMap];
if ((count _eq) isEqualTo 0 || {!(_eq getOrDefault ["equipped",false])}) then {
 (_display displayCtrl 4020) ctrlSetText "";
 (_display displayCtrl 4021) ctrlSetText "Nenhuma arma equipada";
 (_display displayCtrl 4022) ctrlSetText "-";
 {(_display displayCtrl _x) ctrlSetText "Nenhum"} forEach [4031,4033,4035,4037,4039];
 (_display displayCtrl 4040) ctrlSetStructuredText parseText format ["<t color='#8FAAA4'>%1 sem arma equipada.<br/><br/>Este painel é somente leitura; aplicação física permanece em 0.7.</t>",[_equipmentSlot] call _slotLabel];
} else {
 private _weaponInfo = _eq getOrDefault ["weaponInfo",createHashMap];
 private _weaponName = _weaponInfo getOrDefault ["displayName",_eq getOrDefault ["weaponClass",""]];
 (_display displayCtrl 4020) ctrlSetText (_weaponInfo getOrDefault ["picture",""]);
 (_display displayCtrl 4021) ctrlSetText _weaponName;
 (_display displayCtrl 4022) ctrlSetText (_eq getOrDefault ["weaponClass",""]);
 {
  _x params ["_idc","_key"];
  private _info = _eq getOrDefault [_key,createHashMap];
  (_display displayCtrl _idc) ctrlSetText (_info getOrDefault ["displayName","Nenhum"]);
  (_display displayCtrl _idc) ctrlSetTooltip (_info getOrDefault ["className",""]);
 } forEach [[4031,"opticInfo"],[4033,"muzzleInfo"],[4035,"pointerInfo"],[4037,"bipodInfo"],[4039,"magazineInfo"]];

 private _loaded = _eq getOrDefault ["loadedState",createHashMap];
 private _mag = _loaded getOrDefault ["primaryMagazine",[]];
 private _ammoText = if (_mag isEqualType [] && {count _mag >= 2}) then {format ["%1 munição(ões) observada(s)",_mag#1]} else {"Estado de munição não informado"};
 (_display displayCtrl 4040) ctrlSetStructuredText parseText format [
  "<t color='#CDE7E1'>EQUIPADO · %1</t><br/><t color='#8FB7B0'>%2</t><br/><br/>%3<br/>Comparação/aplicação física continua reservada para 0.7.",
  [_equipmentSlot] call _slotLabel,
  [_eq getOrDefault ["weaponClass",""]] call ServoPeregrino_Organizador_Weapons_fnc_escapeStructuredText,
  _ammoText
 ];
};

// Apply the independent P4 query after a full refresh as well.
private _equipmentQuery = _state getOrDefault ["equipmentQuery",""];
private _equipmentQueryLower = toLowerANSI _equipmentQuery;
private _weaponInfoNow = _eq getOrDefault ["weaponInfo",createHashMap];
private _weaponHaystack = format ["arma %1 %2",
 _weaponInfoNow getOrDefault ["displayName",_eq getOrDefault ["weaponClass",""]],
 _eq getOrDefault ["weaponClass",""]
];
private _weaponVisible = _equipmentQueryLower isEqualTo "" || {(toLowerANSI _weaponHaystack) find _equipmentQueryLower >= 0};
{(_display displayCtrl _x) ctrlShow _weaponVisible} forEach [4020,4021,4022];
{
 _x params ["_idcs","_keywords","_infoKey"];
 private _info = _eq getOrDefault [_infoKey,createHashMap];
 private _haystack = format ["%1 %2 %3",_keywords,_info getOrDefault ["displayName",""],_info getOrDefault ["className",""]];
 private _visible = _equipmentQueryLower isEqualTo "" || {(toLowerANSI _haystack) find _equipmentQueryLower >= 0};
 {(_display displayCtrl _x) ctrlShow _visible} forEach _idcs;
} forEach [
 [[4030,4031],"mira optic ótica","opticInfo"],
 [[4032,4033],"boca muzzle","muzzleInfo"],
 [[4034,4035],"apontador pointer laser","pointerInfo"],
 [[4036,4037],"bipé bipe empunhadura grip","bipodInfo"],
 [[4038,4039],"carregador magazine","magazineInfo"]
];

// Footer bands.
_state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
private _contextState=if (_state getOrDefault ["pendingNewKit",false]) then {"NOVO"} else {if (_state getOrDefault ["selectedKitIsNew",false]) then {"NOVO"} else {if (_state getOrDefault ["selectedKitDraftDirty",false]) then {"ALTERADO"} else {if ((_state getOrDefault ["selectedKitId",""]) isEqualTo "") then {"-"} else {"SALVO"}}}};
private _contextName=_state getOrDefault ["selectedKitName",""];
if (_contextName isEqualTo "") then {_contextName=if (_state getOrDefault ["pendingNewKit",false]) then {_state getOrDefault ["pendingNewName","Novo Kit"]} else {"Nenhum"}};
private _context = format [
 "Kit: %1 | Tipo: %2 | Rascunho: %3 | Catálogo: %4/%5 | Equipamento: %6",
 _contextName,
 if ((_state getOrDefault ["selectedKitSlot",""]) isEqualTo "") then {"-"} else {[(_state getOrDefault ["selectedKitSlot",""])] call _slotLabel},
 _contextState,
 _catalogType,
 _catalogKind + (if (_catalogSearchGlobal) then {" (filtros pausados pela busca)"} else {""}),
 [_equipmentSlot] call _slotLabel
];
private _message = _state getOrDefault ["temporaryMessage",""];
private _history = _state getOrDefault ["history",[]];
private _historyText = "";
{
 if (_historyText isNotEqualTo "") then {_historyText = _historyText + "   •   "};
 _historyText = _historyText + _x;
} forEach (_history select [((count _history)-3) max 0,(3 min (count _history))]);

private _message=_message;
private _history=_history;
private _historyText="";
{if (_historyText isNotEqualTo "") then {_historyText=_historyText+"   •   "};_historyText=_historyText+_x} forEach (_history select [((count _history)-3) max 0,(3 min (count _history))]);
[
 _display,
 [
  [5000,"CONTEXTO",_context,"#6FCBB8","#BFEADF","  •  "],
  [5001,"RESULTADO",_message,"#7EC8FF","#DFE6E6","  •  "],
  [5002,"HISTÓRICO",_historyText,"#9FB5B1","#C3CECC","  •  "]
 ]
] call ServoPeregrino_Organizador_UICommon_fnc_renderFooter;

private _refreshMs = round ((diag_tickTime - _refreshStarted) * 1000);
_state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
_state set ["selectedKitId",_selectedKitId];
_state set ["selectedCatalogClass",_selectedCatalogClass];
_state set ["selectedCatalogKind",_selectedCatalogKind];
_state set ["catalogOffset",_catalogOffset];
_state set ["catalogTotalFiltered",_catalogMatchCount];
_state set ["catalogMaxOffset",_catalogMaxOffset];
_state set ["catalogScrollRatio",if (_catalogMaxOffset>0) then {_catalogOffset/_catalogMaxOffset} else {0}];
_state set ["equipmentSlotView",_equipmentSlot];
// selectedKitName/Slot/DraftDirty are maintained by refreshDraftUI, which is the single R2 owner of P2 state.
_state set ["selectedKitName",_state getOrDefault ["selectedKitName",""]];
_state set ["selectedKitSlot",_state getOrDefault ["selectedKitSlot",""]];
_state set ["selectedKitDraftDirty",_state getOrDefault ["selectedKitDraftDirty",false]];
_state set ["refreshInProgress",false];
_state set ["lastRefreshTick",diag_tickTime];
_state set ["lastRefreshMode","FULL"];
_state set ["lastFullRefreshDurationMs",_refreshMs];
_state set ["refreshAppliedCount",(_state getOrDefault ["refreshAppliedCount",0]) + 1];
_state set ["revision",(_state getOrDefault ["revision",0]) + 1];
missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];

diag_log format [
 "[SP_ORG] [WEAPONS] [UI_REFRESH_0_6_E_R2] ms=%1 requests=%2 applied=%3 kits=%4 catalogRendered=%5 catalogMatches=%6 offset=%7/%8 kitFilter=%9 catalogType=%10 category=%11 equipment=%12",
 _refreshMs,_state getOrDefault ["refreshRequestCount",0],_state getOrDefault ["refreshAppliedCount",0],
 count (_vm getOrDefault ["kits",[]]),_catalogRenderedCount,_catalogMatchCount,_catalogOffset,_catalogMaxOffset,
 _kitFilter,_catalogType,_catalogKind,_equipmentSlot
];
diag_log format ["[SP_ORG] [WEAPONS] [UI_PERF] mode=FULL totalMs=%1 catalogWindowMs=%2 projectionBuilt=%3 projectionMs=%4 filterBuilt=%5 filterMs=%6 kits=%7 equipment=%8",_refreshMs,_vm getOrDefault ["catalogWindowBuildMs",0],_vm getOrDefault ["catalogProjectionBuiltNow",false],_vm getOrDefault ["catalogProjectionBuildMs",0],_vm getOrDefault ["catalogFilterBuiltNow",false],_vm getOrDefault ["catalogFilterMs",0],count (_vm getOrDefault ["kits",[]]),_equipmentSlot];

[true,"WEAPONS_UI_REFRESHED","0.6-F R5 full UI refresh completed with independent searches and global Catalog query semantics.",createHashMapFromArray [
 ["kitCount",count (_vm getOrDefault ["kits",[]])],
 ["catalogRenderedCount",_catalogRenderedCount],
 ["catalogMatchCount",_catalogMatchCount],
 ["catalogOffset",_catalogOffset],
 ["catalogMaxOffset",_catalogMaxOffset],
 ["refreshMs",_refreshMs],
 ["kitFilter",_kitFilter],
 ["catalogTypeFilter",_catalogType],
 ["catalogCategoryFilter",_catalogKind],
 ["equipmentSlotView",_equipmentSlot],
 ["selectedCatalogClass",_selectedCatalogClass],
 ["selectedCatalogKind",_selectedCatalogKind]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
