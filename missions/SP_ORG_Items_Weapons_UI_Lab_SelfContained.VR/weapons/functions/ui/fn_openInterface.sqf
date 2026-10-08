#include "..\..\script_version.hpp"
private _initResult = [] call ServoPeregrino_Organizador_Weapons_fnc_initialize;
if !(_initResult get "success") exitWith {_initResult};
if (!hasInterface) exitWith {
 [false,"WEAPONS_UI_NO_INTERFACE","A interface de Weapons exige cliente com interface."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
disableSerialization;

private _existing = findDisplay SP_ORG_WEAPONS_UI_DISPLAY_IDD;
if (!isNull _existing) exitWith {
 [true,"WEAPONS_UI_ALREADY_OPEN","A interface de Weapons já está aberta.",createHashMapFromArray [
  ["idd",SP_ORG_WEAPONS_UI_DISPLAY_IDD],
  ["checkpoint","0.6-F R6"],
  ["applicationGate","LOCAL_DRAFT_AND_CATALOG_APPLY_0_7_D2"],
  ["mutatesInventory",false]
 ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

[] call ServoPeregrino_Organizador_Weapons_fnc_createUIState;
private _ok = createDialog "SP_ORG_Weapons_Dialog";
if (!_ok) exitWith {
 [false,"WEAPONS_UI_CREATE_DIALOG_FAILED","O Arma não conseguiu criar SP_ORG_Weapons_Dialog.",createHashMapFromArray [
  ["dialog","SP_ORG_Weapons_Dialog"]
 ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

[true,"WEAPONS_UI_OPENED","Visual baseline 0.6-F R6 sobre UICommon; aplicação física local 0.7-D2 habilitada para rascunho e Catálogo.",createHashMapFromArray [
 ["idd",SP_ORG_WEAPONS_UI_DISPLAY_IDD],
 ["checkpoint","0.6-F R6"],
 ["panels",["WEAPON_KITS","SELECTED_KIT_DRAFT","WEAPON_CATALOG","EQUIPMENT_CONTENT"]],
 ["footer",["CONTEXT","RESULT","HISTORY"]],
 ["visualGrammar","ITEMS_MULTIPLAYER_LAB_R3_CONVERGENCE"],
 ["catalogMode","CONTINUOUS_WINDOW_VISIBLE_SLIDER"],
 ["catalogCategoryFilter",["ALL","WEAPON","OPTIC","POINTER","BIPOD","MAGAZINE","GRIP"]],
 ["equipmentContentMode","READ_ONLY_CURRENT_WEAPON"],
 ["informationMode","READ_ONLY_BASIC_WEAPON_PRESENTATION"],
 ["compatibilityMode","DRAFT_EDITABLE_COMPATIBILITY_SELECTORS"],
 ["draftMode","LOCAL_WEAPONKIT_DRAFT_WITH_AUTHORING_CANDIDATE"],
 ["authoringGate","SESSION_LOCAL_ENABLED_0_6_E"],
 ["slotLabels",createHashMapFromArray [["PRIMARY","Principal"],["HANDGUN","Porte"],["SECONDARY","Secundária"]]],
 ["mutatesInventory",false],
 ["applicationGate","LOCAL_DRAFT_AND_CATALOG_APPLY_0_7_D2"]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
