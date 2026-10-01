#include "..\..\script_version.hpp"

private _state = [] call ServoPeregrino_Organizador_Weapons_fnc_getUIState;
private _kitQuery = toLowerANSI (_state getOrDefault ["kitQuery",""]);
private _kitType = toUpperANSI (_state getOrDefault ["kitTypeFilter","ALL"]);
private _catalogQuery = toLowerANSI (_state getOrDefault ["catalogQuery",""]);
private _catalogType = toUpperANSI (_state getOrDefault ["catalogTypeFilter","ALL"]);
private _catalogKind = toUpperANSI (_state getOrDefault ["catalogCategoryFilter","ALL"]);
private _catalogOffset = (_state getOrDefault ["catalogOffset",0]) max 0;
private _catalogWindowSize = ((_state getOrDefault ["catalogWindowSize",SP_ORG_WEAPONS_UI_CATALOG_WINDOW_SIZE]) max 8) min 100;
private _equipmentSlotView = toUpperANSI (_state getOrDefault ["equipmentSlotView","PRIMARY"]);
if !(_equipmentSlotView in ["PRIMARY","HANDGUN","SECONDARY"]) then {_equipmentSlotView = "PRIMARY"};

private _kitsResult = [] call ServoPeregrino_Organizador_Weapons_fnc_listWeaponKits;
if !(_kitsResult get "success") exitWith {_kitsResult};

private _allKits = (_kitsResult get "data") getOrDefault ["kits",[]];
private _filteredKits = _allKits select {
 private _name = toLowerANSI (_x getOrDefault ["name",""]);
 private _slot = toUpperANSI (_x getOrDefault ["targetSlot",""]);
 (_kitType isEqualTo "ALL" || {_slot isEqualTo _kitType})
 && {_kitQuery isEqualTo "" || {_name find _kitQuery >= 0}}
};
_filteredKits = [_filteredKits,[],{toLowerANSI (_x getOrDefault ["name",""])},"ASCEND"] call BIS_fnc_sortBy;

private _selectedKitId = _state getOrDefault ["selectedKitId",""];
private _selectedKit = createHashMap;
if (_selectedKitId isNotEqualTo "") then {
 private _idx = _filteredKits findIf {(_x getOrDefault ["kitId",""]) isEqualTo _selectedKitId};
 if (_idx >= 0) then {_selectedKit = _filteredKits select _idx};
};
if ((count _selectedKit) isEqualTo 0 && {(count _filteredKits) > 0}) then {
 _selectedKit = _filteredKits select 0;
 _selectedKitId = _selectedKit getOrDefault ["kitId",""];
};

private _selectedKitWeaponInfo = createHashMap;
private _selectedKitCompatibility = createHashMap;
private _selectedKitCompatibilityCode = "NOT_REQUESTED";
private _selectedKitDraft = createHashMap;
private _selectedKitDraftCode = "NOT_REQUESTED";
private _selectedKitWeaponClass = "";
private _selectedKitSlot = "";

if ((count _selectedKit) > 0) then {
 _selectedKitSlot = toUpperANSI (_selectedKit getOrDefault ["targetSlot",""]);
 private _draftResult = [_selectedKitId] call ServoPeregrino_Organizador_Weapons_fnc_getOrCreateWeaponKitDraft;
 _selectedKitDraftCode = _draftResult getOrDefault ["code","UNKNOWN"];
 if (_draftResult get "success") then {_selectedKitDraft = ((_draftResult get "data") get "draft")};

 private _recipe = if ((count _selectedKitDraft) > 0) then {_selectedKitDraft getOrDefault ["recipe",createHashMap]} else {_selectedKit getOrDefault ["recipe",createHashMap]};
 private _configuration = _recipe getOrDefault ["configuration",createHashMap];
 _selectedKitWeaponClass = _configuration getOrDefault ["weaponClass",""];
 if (_selectedKitWeaponClass isNotEqualTo "") then {
  private _kitInfoResult = [_selectedKitWeaponClass] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponPresentationInfo;
  if (_kitInfoResult get "success") then {_selectedKitWeaponInfo = ((_kitInfoResult get "data") get "info")};

  private _compatibilityResult = [_selectedKitWeaponClass,_recipe] call ServoPeregrino_Organizador_Weapons_fnc_buildCompatibilitySelectorModel;
  _selectedKitCompatibilityCode = _compatibilityResult getOrDefault ["code","UNKNOWN"];
  if (_compatibilityResult get "success") then {_selectedKitCompatibility = ((_compatibilityResult get "data") get "model")};
 };
};

// Catalog projection/window is cache-backed in R3. The expensive base-row conversion,
// accessory projection, sort and filter-index construction happen only when their source/filter key changes.
private _catalogWindowResult = [_selectedKitId,_selectedKit,_selectedKitDraft,_selectedKitCompatibility] call ServoPeregrino_Organizador_Weapons_fnc_getUICatalogWindow;
if !(_catalogWindowResult get "success") exitWith {_catalogWindowResult};
private _catalogWindowData = _catalogWindowResult get "data";
private _catalogWindow = _catalogWindowData getOrDefault ["rows",[]];
private _catalogMatchCount = _catalogWindowData getOrDefault ["catalogMatchCount",0];
private _catalogMaxOffset = _catalogWindowData getOrDefault ["catalogMaxOffset",0];
private _catalogTotal = _catalogWindowData getOrDefault ["catalogTotal",0];
private _catalogBaseWeaponTotal = _catalogWindowData getOrDefault ["catalogBaseWeaponTotal",0];
_catalogOffset = _catalogWindowData getOrDefault ["catalogOffset",_catalogOffset];
private _selectedCatalog = _catalogWindowData getOrDefault ["selectedCatalog",createHashMap];
private _selectedCatalogClass = _catalogWindowData getOrDefault ["selectedCatalogClass",""];
private _selectedCatalogKind = _catalogWindowData getOrDefault ["selectedCatalogKind",""];

private _equipmentResult = [player,_equipmentSlotView] call ServoPeregrino_Organizador_Weapons_fnc_getEquipmentSlotSnapshot;
private _equipmentSnapshot = createHashMap;
private _equipmentCode = _equipmentResult getOrDefault ["code","UNKNOWN"];
if (_equipmentResult get "success") then {_equipmentSnapshot = (_equipmentResult get "data") get "snapshot"};

[true,"WEAPONS_UI_VIEW_MODEL","0.6-E R1 view model built with authoring lifecycle over the homologated four-panel/focused-refresh baseline.",createHashMapFromArray [
 ["state",_state],
 ["kits",_filteredKits],
 ["allKitCount",count _allKits],
 ["kitTypeFilter",_kitType],
 ["selectedKit",[_selectedKit] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
 ["selectedKitId",_selectedKitId],
 ["selectedKitWeaponInfo",[_selectedKitWeaponInfo] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
 ["selectedKitDraft",[_selectedKitDraft] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
 ["selectedKitDraftCode",_selectedKitDraftCode],
 ["selectedKitCompatibility",[_selectedKitCompatibility] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
 ["selectedKitCompatibilityCode",_selectedKitCompatibilityCode],
 ["catalog",[_catalogWindow] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
 ["catalogTypeFilter",_catalogType],
 ["catalogCategoryFilter",_catalogKind],
 ["catalogMatchCount",_catalogMatchCount],
 ["catalogRenderedCount",count _catalogWindow],
 ["catalogWindowSize",_catalogWindowSize],
 ["catalogOffset",_catalogOffset],
 ["catalogMaxOffset",_catalogMaxOffset],
 ["catalogTotal",_catalogTotal],
 ["catalogBaseWeaponTotal",_catalogBaseWeaponTotal],
 ["selectedCatalog",[_selectedCatalog] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
 ["selectedCatalogClass",_selectedCatalogClass],
 ["selectedCatalogKind",_selectedCatalogKind],
 ["selectedCatalogInfo",[_selectedCatalog] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
 ["catalogProjectionBuiltNow",_catalogWindowData getOrDefault ["projectionBuiltNow",false]],
 ["catalogProjectionBuildMs",_catalogWindowData getOrDefault ["projectionBuildMs",0]],
 ["catalogFilterBuiltNow",_catalogWindowData getOrDefault ["filterBuiltNow",false]],
 ["catalogFilterMs",_catalogWindowData getOrDefault ["filterMs",0]],
 ["catalogWindowBuildMs",_catalogWindowData getOrDefault ["totalMs",0]],
 ["equipmentSlotView",_equipmentSlotView],
 ["equipmentSnapshot",[_equipmentSnapshot] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
 ["equipmentSnapshotCode",_equipmentCode]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
