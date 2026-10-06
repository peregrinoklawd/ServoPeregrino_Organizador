#include "..\..\script_version.hpp"
params [
 ["_sourceKitId","",[""]],
 ["_sourceKit",createHashMap,[createHashMap]],
 ["_sourceDraft",createHashMap,[createHashMap]],
 ["_sourceCompatibility",createHashMap,[createHashMap]]
];

private _startedAt = diag_tickTime;
private _state = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
private _query = toLowerANSI (_state getOrDefault ["catalogQuery",""]);
private _typeFilter = toUpperANSI (_state getOrDefault ["catalogTypeFilter","ALL"]);
private _kindFilter = toUpperANSI (_state getOrDefault ["catalogCategoryFilter","ALL"]);
// 0.6-F R3: a non-empty Catalog query is a temporary global-search mode.
// Stored filters are preserved, but ignored until the query becomes empty again.
private _filtersIgnoredBySearch = _query isNotEqualTo "";
private _effectiveTypeFilter = if (_filtersIgnoredBySearch) then {"ALL"} else {_typeFilter};
private _effectiveKindFilter = if (_filtersIgnoredBySearch) then {"ALL"} else {_kindFilter};
private _offset = (_state getOrDefault ["catalogOffset",0]) max 0;
private _windowSize = ((_state getOrDefault ["catalogWindowSize",SP_ORG_WEAPONS_UI_CATALOG_WINDOW_SIZE]) max 8) min 100;

if (_sourceKitId isEqualTo "") then {_sourceKitId = _state getOrDefault ["selectedKitId",""]};

// Base weapon rows are immutable during a session/build. Convert the 0.3 catalog only once,
// instead of rebuilding thousands of HashMaps on every wheel tick like R2 did.
private _baseRows = missionNamespace getVariable [SP_ORG_WEAPONS_UI_BASE_CATALOG_ROWS_VAR,[]];
private _baseCatalogCount = 0;
private _baseRowsBuiltNow = false;
private _baseRowsBuildMs = 0;
if ((count _baseRows) isEqualTo 0) then {
 private _baseStarted = diag_tickTime;
 private _catalogResult = [false,false] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponCatalog;
 if !(_catalogResult get "success") exitWith {_catalogResult};
 private _entries = ((_catalogResult get "data") get "catalog") getOrDefault ["entries",[]];
 _baseCatalogCount = count _entries;
 {
  private _slot = toUpperANSI (_x getOrDefault ["category",""]);
  _baseRows pushBack (createHashMapFromArray [
   ["schemaVersion","0.6-D-r3-catalog-row-candidate"],
   ["catalogKind","WEAPON"],["catalogKindLabel","Arma"],["catalogKindOrder",0],
   ["catalogClass",_x getOrDefault ["weaponClass",""]],["weaponClass",_x getOrDefault ["weaponClass",""]],
   ["displayName",_x getOrDefault ["displayName",_x getOrDefault ["weaponClass",""]]],
   ["picture",_x getOrDefault ["picture",""]],["descriptionShort",_x getOrDefault ["descriptionShort",""]],
   ["targetSlot",_slot],["category",_slot],
   ["sourceAddons",+(_x getOrDefault ["sourceAddons",[]])],["sourceMods",+(_x getOrDefault ["sourceMods",[]])],
   ["compatibleWithWeaponClass",""],["underbarrelClassification",""]
  ]);
 } forEach _entries;
 missionNamespace setVariable [SP_ORG_WEAPONS_UI_BASE_CATALOG_ROWS_VAR,_baseRows];
 _baseRowsBuiltNow = true;
 _baseRowsBuildMs = round ((diag_tickTime-_baseStarted)*1000);
} else {
 _baseCatalogCount = count _baseRows;
};

// Resolve selected-kit source only when the projection needs it. Normal scroll keeps the same
// sourceKey and therefore reuses the existing combined/sorted rows and filtered index list.
private _selectedKitSlot = "";
private _selectedWeaponClass = "";
private _projection = missionNamespace getVariable [SP_ORG_WEAPONS_UI_CATALOG_PROJECTION_VAR,createHashMap];

// Fast path for wheel/slider navigation. In 0.6-E the draft base weapon can change,
// therefore every base-weapon mutation/discard explicitly invalidates this projection.
// While the projection remains valid for the selected kit, its weapon/slot can be reused
// without re-reading repository/draft on every wheel/slider tick.
private _projectionSourceKitId = _projection getOrDefault ["sourceKitId",""];
private _canReuseProjectionSource = (
 _sourceKitId isNotEqualTo ""
 && {(toLowerANSI _projectionSourceKitId) isEqualTo (toLowerANSI _sourceKitId)}
 && {(_projection getOrDefault ["sourceWeaponClass",""]) isNotEqualTo ""}
);
if (_canReuseProjectionSource) then {
 _selectedKitSlot = _projection getOrDefault ["sourceSlot",""];
 _selectedWeaponClass = _projection getOrDefault ["sourceWeaponClass",""];
} else {
 if ((count _sourceKit) isEqualTo 0 && {_sourceKitId isNotEqualTo ""}) then {
  private _kitResult = [_sourceKitId] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponKit;
  if (_kitResult get "success") then {_sourceKit = ((_kitResult get "data") get "kit")};
 };
 if ((count _sourceKit) > 0) then {
  _selectedKitSlot = toUpperANSI (_sourceKit getOrDefault ["targetSlot",""]);
  if ((count _sourceDraft) isEqualTo 0) then {
   private _draftResult = [_sourceKitId] call ServoPeregrino_Organizador_Weapons_fnc_getOrCreateWeaponKitDraft;
   if (_draftResult get "success") then {_sourceDraft = ((_draftResult get "data") get "draft")};
  };
  private _recipe = if ((count _sourceDraft)>0) then {_sourceDraft getOrDefault ["recipe",createHashMap]} else {_sourceKit getOrDefault ["recipe",createHashMap]};
  private _cfg = _recipe getOrDefault ["configuration",createHashMap];
  _selectedWeaponClass = _cfg getOrDefault ["weaponClass",""];
 };
};

private _sourceKey = format ["%1|%2|%3|%4",SERVO_PEREGRINO_ORGANIZADOR_WEAPONS_BUILD,_baseCatalogCount,toLowerANSI _sourceKitId,toLowerANSI _selectedWeaponClass];
private _projectionBuiltNow = false;
private _projectionBuildMs = 0;

if ((_projection getOrDefault ["sourceKey",""]) isNotEqualTo _sourceKey) then {
 private _projectionStarted = diag_tickTime;
 private _rows = +_baseRows;

 if (_selectedWeaponClass isNotEqualTo "") then {
  if ((count _sourceCompatibility) isEqualTo 0) then {
   private _recipe = if ((count _sourceDraft)>0) then {_sourceDraft getOrDefault ["recipe",createHashMap]} else {_sourceKit getOrDefault ["recipe",createHashMap]};
   private _compatResult = [_selectedWeaponClass,_recipe] call ServoPeregrino_Organizador_Weapons_fnc_buildCompatibilitySelectorModel;
   if (_compatResult get "success") then {_sourceCompatibility = ((_compatResult get "data") get "model")};
  };

  private _appendAccessory = {
   params ["_className","_kind","_kindLabel","_order","_rootKind",["_underbarrelClass",""]];
   if (_className isEqualTo "") exitWith {};
   private _p = [_className,_rootKind] call ServoPeregrino_Organizador_Weapons_fnc_getClassPresentationInfo;
   private _info = if (_p get "success") then {(_p get "data") get "info"} else {
    createHashMapFromArray [["className",_className],["displayName",_className],["picture",""],["descriptionShort",""],["sourceAddons",[]],["sourceMods",[]]]
   };
   _rows pushBack (createHashMapFromArray [
    ["schemaVersion","0.6-D-r3-catalog-row-candidate"],
    ["catalogKind",_kind],["catalogKindLabel",_kindLabel],["catalogKindOrder",_order],
    ["catalogClass",_info getOrDefault ["className",_className]],["weaponClass",""],
    ["displayName",_info getOrDefault ["displayName",_className]],["picture",_info getOrDefault ["picture",""]],
    ["descriptionShort",_info getOrDefault ["descriptionShort",""]],["targetSlot",_selectedKitSlot],["category",_selectedKitSlot],
    ["sourceAddons",+(_info getOrDefault ["sourceAddons",[]])],["sourceMods",+(_info getOrDefault ["sourceMods",[]])],
    ["compatibleWithWeaponClass",_selectedWeaponClass],["underbarrelClassification",_underbarrelClass]
   ]);
  };

  if ((count _sourceCompatibility)>0) then {
   private _selectors = _sourceCompatibility getOrDefault ["selectors",createHashMap];
   {
    _x params ["_selectorKey","_rowKind","_rowKindLabel","_rowOrder","_rootKind"];
    private _selector = _selectors getOrDefault [_selectorKey,createHashMap];
    {
     private _className = _x getOrDefault ["className",""];
     if (_className isNotEqualTo "") then {[_className,_rowKind,_rowKindLabel,_rowOrder,_rootKind] call _appendAccessory};
    } forEach (_selector getOrDefault ["options",[]]);
   } forEach [
    ["optic","OPTIC","Ótica",1,"OPTIC"],
    ["pointer","POINTER","Apontador",2,"POINTER"],
    ["magazineClass","MAGAZINE","Carregador",4,"MAGAZINE"]
   ];

   private _underbarrel = (_selectors getOrDefault ["bipod",createHashMap]) getOrDefault ["options",[]];
   {
    private _className = _x getOrDefault ["className",""];
    if (_className isNotEqualTo "") then {
     private _dn = toLowerANSI (_x getOrDefault ["displayName",""]);
     private _cl = toLowerANSI _className;
     private _isBipod = (_dn find "bipod" >= 0) || {_cl find "bipod" >= 0} || {_dn find "bipé" >= 0};
     if (_isBipod) then {[_className,"BIPOD","Bipé",3,"BIPOD","BIPOD_HEURISTIC"] call _appendAccessory}
     else {[_className,"GRIP","Empunhadura",5,"BIPOD","GRIP_HEURISTIC"] call _appendAccessory};
    };
   } forEach _underbarrel;
  };
 };

 private _seen = createHashMap;
 _rows = _rows select {
  private _key = format ["%1|%2",toUpperANSI (_x getOrDefault ["catalogKind",""]),toLowerANSI (_x getOrDefault ["catalogClass",""])];
  if (_seen getOrDefault [_key,false]) then {false} else {_seen set [_key,true];true}
 };
 _rows = [_rows,[],{
  format ["%1|%2|%3",100+(_x getOrDefault ["catalogKindOrder",9]),toLowerANSI (_x getOrDefault ["displayName",""]),toLowerANSI (_x getOrDefault ["catalogClass",""])]
 },"ASCEND"] call BIS_fnc_sortBy;

 _projectionBuildMs = round ((diag_tickTime-_projectionStarted)*1000);
 _projection = createHashMapFromArray [
  ["sourceKey",_sourceKey],["rows",_rows],["baseWeaponTotal",_baseCatalogCount],
  ["sourceKitId",_sourceKitId],["sourceWeaponClass",_selectedWeaponClass],["sourceSlot",_selectedKitSlot],
  ["projectionBuildMs",_projectionBuildMs],["projectionBuildCount",((missionNamespace getVariable [SP_ORG_WEAPONS_UI_CATALOG_PROJECTION_VAR,createHashMap]) getOrDefault ["projectionBuildCount",0])+1],
  ["filterKey",""],["filteredIndices",[]],["filterBuildCount",0],["filterMs",0]
 ];
 _projectionBuiltNow = true;
};

private _rows = _projection getOrDefault ["rows",[]];
private _filterKey = format ["%1|%2|%3",_effectiveTypeFilter,_effectiveKindFilter,_query];
private _filterBuiltNow = false;
private _filterMs = _projection getOrDefault ["filterMs",0];
if ((_projection getOrDefault ["filterKey",""]) isNotEqualTo _filterKey) then {
 private _filterStarted = diag_tickTime;
 private _indices = [];
 {
  private _slot = toUpperANSI (_x getOrDefault ["targetSlot",""]);
  private _kind = toUpperANSI (_x getOrDefault ["catalogKind",""]);
  private _dn = toLowerANSI (_x getOrDefault ["displayName",""]);
  private _cl = toLowerANSI (_x getOrDefault ["catalogClass",""]);
  if (
   (_effectiveTypeFilter isEqualTo "ALL" || {_slot isEqualTo _effectiveTypeFilter})
   && {(_effectiveKindFilter isEqualTo "ALL" || {_kind isEqualTo _effectiveKindFilter})}
   && {(_query isEqualTo "" || {_dn find _query >= 0 || {_cl find _query >= 0}})}
  ) then {_indices pushBack _forEachIndex};
 } forEach _rows;
 _filterMs = round ((diag_tickTime-_filterStarted)*1000);
 _projection set ["filterKey",_filterKey];
 _projection set ["filteredIndices",_indices];
 _projection set ["filterMs",_filterMs];
 _projection set ["filterBuildCount",(_projection getOrDefault ["filterBuildCount",0])+1];
 _filterBuiltNow = true;
};

private _indices = _projection getOrDefault ["filteredIndices",[]];
private _matchCount = count _indices;
private _maxOffset = (_matchCount-_windowSize) max 0;
_offset = [_offset,_matchCount,_windowSize] call ServoPeregrino_Organizador_UICommon_fnc_clampVirtualOffset;
private _take = (_matchCount-_offset) min _windowSize;
private _windowIndices = if (_take>0) then {_indices select [_offset,_take]} else {[]};
private _windowRows = [];
{_windowRows pushBack (_rows select _x)} forEach _windowIndices;

private _selectedClass = _state getOrDefault ["selectedCatalogClass",""];
private _selectedKind = toUpperANSI (_state getOrDefault ["selectedCatalogKind",""]);
private _selected = createHashMap;
if (_selectedClass isNotEqualTo "") then {
 private _matchIndex = _indices findIf {
  private _row = _rows select _x;
  (toLowerANSI (_row getOrDefault ["catalogClass",""])) isEqualTo (toLowerANSI _selectedClass)
  && {(_selectedKind isEqualTo "" || {(toUpperANSI (_row getOrDefault ["catalogKind",""])) isEqualTo _selectedKind})}
 };
 if (_matchIndex>=0) then {_selected = _rows select (_indices select _matchIndex)};
};
if ((count _selected) isEqualTo 0 && {(count _windowRows)>0}) then {
 _selected = _windowRows select 0;
 _selectedClass = _selected getOrDefault ["catalogClass",""];
 _selectedKind = _selected getOrDefault ["catalogKind",""];
};

missionNamespace setVariable [SP_ORG_WEAPONS_UI_CATALOG_PROJECTION_VAR,_projection];
private _totalMs = round ((diag_tickTime-_startedAt)*1000);

[true,"WEAPONS_UI_CATALOG_WINDOW_READY","Catálogo focal construído sobre projeção cacheada; scroll não reconstrói a UI inteira.",createHashMapFromArray [
 ["rows",[_windowRows] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
 ["selectedCatalog",[_selected] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
 ["selectedCatalogClass",_selectedClass],["selectedCatalogKind",_selectedKind],
 ["catalogOffset",_offset],["catalogWindowSize",_windowSize],["catalogMatchCount",_matchCount],["catalogMaxOffset",_maxOffset],
 ["catalogTotal",count _rows],["catalogBaseWeaponTotal",_projection getOrDefault ["baseWeaponTotal",_baseCatalogCount]],
 ["projectionBuiltNow",_projectionBuiltNow],["projectionBuildMs",if (_projectionBuiltNow) then {_projectionBuildMs} else {0}],
 ["projectionBuildCount",_projection getOrDefault ["projectionBuildCount",0]],
 ["baseRowsBuiltNow",_baseRowsBuiltNow],["baseRowsBuildMs",_baseRowsBuildMs],
 ["filterBuiltNow",_filterBuiltNow],["filterMs",if (_filterBuiltNow) then {_filterMs} else {0}],
 ["filterBuildCount",_projection getOrDefault ["filterBuildCount",0]],
 ["filtersIgnoredBySearch",_filtersIgnoredBySearch],
 ["storedTypeFilter",_typeFilter],["storedCategoryFilter",_kindFilter],
 ["effectiveTypeFilter",_effectiveTypeFilter],["effectiveCategoryFilter",_effectiveKindFilter],
 ["totalMs",_totalMs]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
