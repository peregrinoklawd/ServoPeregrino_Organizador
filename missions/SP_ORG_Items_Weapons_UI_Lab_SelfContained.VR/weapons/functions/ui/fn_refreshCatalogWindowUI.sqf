#include "..\..\script_version.hpp"
disableSerialization;
params [["_reason","CATALOG_FOCUSED",[""]]];

private _display = findDisplay SP_ORG_WEAPONS_UI_DISPLAY_IDD;
if (isNull _display) exitWith {
 [false,"WEAPONS_UI_NOT_OPEN","Weapons UI is not open."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
if ((count _state) isEqualTo 0) exitWith {
 [false,"WEAPONS_UI_STATE_MISSING","Weapons UI state is missing."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if (_state getOrDefault ["catalogRefreshInProgress",false]) exitWith {
 [true,"WEAPONS_UI_CATALOG_REFRESH_REENTRANT_SKIPPED","Nested catalog-focused refresh ignored."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

_state set ["catalogRefreshInProgress",true];
missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
private _startedAt = diag_tickTime;
private _windowResult = [] call ServoPeregrino_Organizador_Weapons_fnc_getUICatalogWindow;
if !(_windowResult get "success") exitWith {
 private _failed = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
 _failed set ["catalogRefreshInProgress",false];
 missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_failed];
 _windowResult
};
private _data = _windowResult get "data";
_state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];

private _slotLabel = {params ["_slot"];[_slot] call ServoPeregrino_Organizador_Weapons_fnc_getUISlotLabel};
private _kindValue = {
 params ["_kind"];
 switch (toUpperANSI _kind) do {
  case "WEAPON": {0}; case "OPTIC": {1}; case "POINTER": {2}; case "BIPOD": {3}; case "MAGAZINE": {4}; case "GRIP": {5}; default {-1};
 }
};

private _query = _state getOrDefault ["catalogQuery",""];
private _catalogSearchGlobal = _query isNotEqualTo "";
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
private _searchCtrl = _display displayCtrl 3100;
if ((ctrlText _searchCtrl) isNotEqualTo _query) then {_searchCtrl ctrlSetText _query};

private _catCtrl = _display displayCtrl 3120;
lbClear _catCtrl;
private _selectedClass = _data getOrDefault ["selectedCatalogClass",""];
private _selectedKind = _data getOrDefault ["selectedCatalogKind",""];
private _selIndex = -1;
{
 private _kind = _x getOrDefault ["catalogKind",""];
 private _kindLabel = _x getOrDefault ["catalogKindLabel",""];
 private _class = _x getOrDefault ["catalogClass",""];
 private _idx = _catCtrl lbAdd format ["←  %1  |  %2  →",_kindLabel,_x getOrDefault ["displayName",_class]];
 _catCtrl lbSetData [_idx,_class];
 _catCtrl lbSetValue [_idx,[_kind] call _kindValue];
 private _picture = _x getOrDefault ["picture",""];
 if (_picture isNotEqualTo "") then {_catCtrl lbSetPicture [_idx,_picture]};
 private _mods = _x getOrDefault ["sourceMods",[]];
 private _addons = _x getOrDefault ["sourceAddons",[]];
 private _origin = if ((count _mods)>0) then {_mods joinString ", "} else {if ((count _addons)>0) then {_addons joinString ", "} else {"Origem não informada"}};
 _catCtrl lbSetTooltip [_idx,format ["%1 | %2 | Classe: %3 | Tipo: %4 | Origem: %5",_kindLabel,_x getOrDefault ["displayName",""],_class,[(_x getOrDefault ["targetSlot",""])] call _slotLabel,_origin]];
 if ((toLowerANSI _class) isEqualTo (toLowerANSI _selectedClass) && {(toUpperANSI _kind) isEqualTo (toUpperANSI _selectedKind)}) then {_selIndex=_idx};
} forEach (_data getOrDefault ["rows",[]]);
if (_selIndex>=0) then {_catCtrl lbSetCurSel _selIndex};

private _offset = _data getOrDefault ["catalogOffset",0];
private _matchCount = _data getOrDefault ["catalogMatchCount",0];
private _rendered = count (_data getOrDefault ["rows",[]]);
private _maxOffset = _data getOrDefault ["catalogMaxOffset",0];
private _windowSize = _data getOrDefault ["catalogWindowSize",SP_ORG_WEAPONS_UI_CATALOG_WINDOW_SIZE];
private _lastShown = (_offset+_rendered) min _matchCount;
private _globalSearch = _data getOrDefault ["filtersIgnoredBySearch",_catalogSearchGlobal];
(_display displayCtrl 3122) ctrlSetText (
 if (_matchCount isEqualTo 0) then {
  if (_globalSearch) then {"Nenhum resultado · busca global (filtros ignorados)"} else {"Nenhum resultado"}
 } else {
  format ["Mostrando %1 a %2 de %3%4",_offset+1,_lastShown,_matchCount,if (_globalSearch) then {" · busca global"} else {""}]
 }
);
private _slider = _display displayCtrl 3124;
[_slider,_offset,_matchCount,_windowSize,6,12,true] call ServoPeregrino_Organizador_UICommon_fnc_syncVirtualSlider;

private _selected = _data getOrDefault ["selectedCatalog",createHashMap];
private _details = "Selecione um item. ← envia para ARMAS DO KIT; → permanece reservado para aplicação física em 0.7.";
if ((count _selected)>0) then {
 private _dn = [_selected getOrDefault ["displayName",""]] call ServoPeregrino_Organizador_Weapons_fnc_escapeStructuredText;
 private _kindSafe = [_selected getOrDefault ["catalogKindLabel",""]] call ServoPeregrino_Organizador_Weapons_fnc_escapeStructuredText;
 private _classSafe = [_selected getOrDefault ["catalogClass",""]] call ServoPeregrino_Organizador_Weapons_fnc_escapeStructuredText;
 private _descSafe = [_selected getOrDefault ["descriptionShort",""]] call ServoPeregrino_Organizador_Weapons_fnc_escapeStructuredText;
 private _compatClass = _selected getOrDefault ["compatibleWithWeaponClass",""];
 private _compatLine = if (_compatClass isEqualTo "") then {""} else {format ["<br/><t color='#8FB7B0'>Compatível com: %1</t>",[_compatClass] call ServoPeregrino_Organizador_Weapons_fnc_escapeStructuredText]};
 _details = format ["<t size='1.05' color='#CDE7E1'>%1</t><br/>%2 · Classe: %3%4%5",_dn,_kindSafe,_classSafe,_compatLine,if (_descSafe isEqualTo "") then {""} else {format ["<br/>%1",_descSafe]}];
};
(_display displayCtrl 3130) ctrlSetStructuredText parseText _details;
private _hasSelection = (count _selected)>0;
(_display displayCtrl 3150) ctrlEnable _hasSelection;
(_display displayCtrl 3151) ctrlEnable false;
(_display displayCtrl 3151) ctrlSetTooltip "Aplicação física slot-safe será habilitada em Weapons 0.7.";

_state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
_state set ["selectedCatalogClass",_selectedClass];
_state set ["selectedCatalogKind",_selectedKind];
_state set ["catalogOffset",_offset];
_state set ["catalogTotalFiltered",_matchCount];
_state set ["catalogMaxOffset",_maxOffset];
_state set ["catalogScrollRatio",if (_maxOffset>0) then {_offset/_maxOffset} else {0}];
private _elapsed = round ((diag_tickTime-_startedAt)*1000);
_state set ["catalogRefreshInProgress",false];
_state set ["catalogFocusedRefreshCount",(_state getOrDefault ["catalogFocusedRefreshCount",0])+1];
_state set ["lastCatalogFocusedRefreshDurationMs",_elapsed];
_state set ["lastCatalogProjectionBuildDurationMs",_data getOrDefault ["projectionBuildMs",0]];
_state set ["lastCatalogFilterDurationMs",_data getOrDefault ["filterMs",0]];
_state set ["lastRefreshMode","CATALOG_FOCUSED"];
_state set ["lastRefreshTick",diag_tickTime];
missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];

private _kitName = _state getOrDefault ["selectedKitName","Nenhum"];
if (_kitName isEqualTo "") then {_kitName=if (_state getOrDefault ["pendingNewKit",false]) then {_state getOrDefault ["pendingNewName","Novo Kit"]} else {"Nenhum"}};
private _kitSlot = _state getOrDefault ["selectedKitSlot",""];
private _draftState = if (_state getOrDefault ["pendingNewKit",false]) then {"NOVO"} else {if (_state getOrDefault ["selectedKitIsNew",false]) then {"NOVO"} else {if (_state getOrDefault ["selectedKitDraftDirty",false]) then {"ALTERADO"} else {if (_kitSlot isEqualTo "") then {"-"} else {"SALVO"}}}};
private _equipmentSlot = _state getOrDefault ["equipmentSlotView","PRIMARY"];
private _context = format ["Kit: %1 | Tipo: %2 | Rascunho: %3 | Catálogo: %4/%5%6 | Equipamento: %7",_kitName,if (_kitSlot isEqualTo "") then {"-"} else {[_kitSlot] call _slotLabel},_draftState,_catalogType,_catalogKind,if (_globalSearch) then {" (filtros pausados pela busca)"} else {""},[_equipmentSlot] call _slotLabel];
// Message/history are intentionally not rebuilt from domain state; they remain the feedback channel.
private _message=_state getOrDefault ["temporaryMessage",""];
private _history=_state getOrDefault ["history",[]];
private _historyText="";
{if (_historyText isNotEqualTo "") then {_historyText=_historyText+"   •   "};_historyText=_historyText+_x} forEach (_history select [((count _history)-3) max 0,(3 min (count _history))]);
[
 _display,
 [
  [5000,"CONTEXTO",_context,"#6FCBB8","#BFEADF","  •  "],
  [5001,"RESULTADO",_message,"#7EC8FF","#DFE6E6","  •  "],
  [5002,"HISTÓRICO",_historyText,"#93A7A4","#A8B7B5","  •  "]
 ]
] call ServoPeregrino_Organizador_UICommon_fnc_renderFooter;

diag_log format ["[SP_ORG] [WEAPONS] [UI_PERF] mode=CATALOG_FOCUSED reason=%1 totalMs=%2 projectionBuilt=%3 projectionMs=%4 filterBuilt=%5 filterMs=%6 matched=%7 offset=%8/%9 rows=%10 fullRefresh=false",toUpperANSI _reason,_elapsed,_data getOrDefault ["projectionBuiltNow",false],_data getOrDefault ["projectionBuildMs",0],_data getOrDefault ["filterBuiltNow",false],_data getOrDefault ["filterMs",0],_matchCount,_offset,_maxOffset,_rendered];

[true,"WEAPONS_UI_CATALOG_FOCUSED_REFRESHED","Catálogo atualizado sem reconstruir os demais painéis.",createHashMapFromArray [["refreshMs",_elapsed],["catalogOffset",_offset],["catalogMatchCount",_matchCount],["fullRefresh",false]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
