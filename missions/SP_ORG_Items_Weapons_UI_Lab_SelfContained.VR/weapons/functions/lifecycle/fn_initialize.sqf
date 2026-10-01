#include "..\..\script_version.hpp"
private _nexus = [] call ServoPeregrino_Organizador_Weapons_fnc_validateNexus;
if !(_nexus getOrDefault ["success",false]) exitWith {_nexus};
private _authority = if (isServer) then {[] call ServoPeregrino_Organizador_Weapons_fnc_initializeAuthority} else {[true,"WEAPONS_CLIENT_MODE","Server owns SESSION logical registry."] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
if (isServer && {!(_authority get "success")}) exitWith {_authority};
private _kitStore = [] call ServoPeregrino_Organizador_Weapons_fnc_initializeWeaponKitStore;
if !(_kitStore getOrDefault ["success",false]) exitWith {_kitStore};
private _uiState = [] call ServoPeregrino_Organizador_Weapons_fnc_createUIState;
missionNamespace setVariable [SP_ORG_WEAPONS_RUNTIME,createHashMapFromArray [
 ["ready",true],
 ["scope","SESSION"],
 ["identityGate","OPEN"],
 ["identityStrategy","EVENT_DELTA_EVIDENCE_CANDIDATE"],
 ["configurationSchema","0.2-candidate"],
 ["configurationApply","ENGINE_ROUNDTRIP_CANDIDATE"],
 ["catalogSchema","0.3-catalog-candidate"],
 ["catalogStrategy","CFGWEAPONS_ENGINE_DISCOVERY"],
 ["compatibilityStrategy","ON_DEMAND_ENGINE_QUERY"],
 ["recipeSchema","0.4-recipe-candidate"],
 ["recipeStrategy","DESIRED_BUILD_MODEL"],
 ["kitSchema","0.5-kit-candidate"],
 ["kitUI","PLAYER_UI_0_6_E_R1_AUTHORING_LIFECYCLE_CANDIDATE"],
 ["uiCheckpoint","0.6-E"],
 ["uiRevision","R1"],
 ["uiLayout","FOUR_PANEL_ITEMS_CONVERGENCE"],
 ["uiCatalogMode","CONTINUOUS_WINDOW_VISIBLE_SLIDER_FOCUSED_REFRESH"],
 ["uiEquipmentView","READ_ONLY_CURRENT_WEAPON"],
 ["uiInformationMode","DRAFT_PLUS_CATALOG_PLUS_EQUIPMENT_PRESENTATION"],
 ["uiCompatibilityMode","DRAFT_EDITABLE_COMPATIBILITY_SELECTORS"],
    ["uiWeaponBaseEditing","SAME_TARGET_SLOT_DRAFT_ONLY"],
    ["uiNameAuthoring","INLINE_EDIT_EXPLICIT_COMMIT"],
 ["uiDraft","LOCAL_WEAPONKIT_DRAFT_WITH_AUTHORING_CANDIDATE"],
 ["uiAuthoring","SESSION_LOCAL_ENABLED_0_6_E"],
 ["kitApplication","DEFERRED_0_7"],
 ["stableContracts",[]],
 ["physicalIdentityProven",false],
 ["conditionOwned",false],
 ["executionMode","MISSION_FIRST"],
 ["pboGate","DEFERRED"],
 ["build",SERVO_PEREGRINO_ORGANIZADOR_WEAPONS_BUILD]
]];
["weapons.runtime",1,"ServoPeregrino_Organizador_Weapons",createHashMapFromArray [["scope","SESSION"],["identityGate","OPEN"],["configurationSchema","0.2-candidate"],["configurationApply","ENGINE_ROUNDTRIP_CANDIDATE"],["catalogSchema","0.3-catalog-candidate"],["catalogStrategy","CFGWEAPONS_ENGINE_DISCOVERY"],["compatibilityStrategy","ON_DEMAND_ENGINE_QUERY"],["recipeSchema","0.4-recipe-candidate"],["recipeStrategy","DESIRED_BUILD_MODEL"],["kitSchema","0.5-kit-candidate"],["kitUI","PLAYER_UI_0_6_E_R1_AUTHORING_LIFECYCLE_CANDIDATE"],["uiCheckpoint","0.6-E"],["uiRevision","R1"],["uiLayout","FOUR_PANEL_ITEMS_CONVERGENCE"],["uiCatalogMode","CONTINUOUS_WINDOW_VISIBLE_SLIDER_FOCUSED_REFRESH"],["uiEquipmentView","READ_ONLY_CURRENT_WEAPON"],["uiInformationMode","DRAFT_PLUS_CATALOG_PLUS_EQUIPMENT_PRESENTATION"],["uiCompatibilityMode","DRAFT_EDITABLE_COMPATIBILITY_SELECTORS"],["uiDraft","LOCAL_WEAPONKIT_DRAFT_WITH_AUTHORING_CANDIDATE"],["uiAuthoring","SESSION_LOCAL_ENABLED_0_6_E"],["kitApplication","DEFERRED_0_7"],["physicalIdentityProven",false],["executionMode","MISSION_FIRST"],["pboGate","DEFERRED"]]] call ServoPeregrino_Organizador_Nexus_fnc_registerCapability;
diag_log "[SP_ORG] [WEAPONS] [INFO] WEAPONS 0.6-E R1 INITIALIZED - Session-local WeaponKit authoring enabled over the homologated R3 focused-refresh/four-panel baseline.";
[true,"WEAPONS_INITIALIZED","0.6-E R1 mission-first pronta; Novo/Renomear/Duplicar/Excluir/Salvar/Salvar como novo e troca da arma-base no rascunho estão habilitados no repositório session-local. Aplicação física continua em 0.7."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
