#include "..\..\script_version.hpp"
private _check = [] call ServoPeregrino_Organizador_Weapons_fnc_validateNexus;
if !(_check get "success") exitWith {_check};

if (isNil "ServoPeregrino_Organizador_UICommon_fnc_initialize" || {isNil "ServoPeregrino_Organizador_UICommon_fnc_getBuildInfo"}) exitWith {
 [false,"WEAPONS_UICOMMON_REQUIRED","SP_ORG_Weapons 0.7-B requer UICommon 0.1.1.",createHashMapFromArray [["minimumVersion",SP_ORG_WEAPONS_UICOMMON_MIN_VERSION]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _uiCommonInit = [] call ServoPeregrino_Organizador_UICommon_fnc_initialize;
if !(_uiCommonInit getOrDefault ["success",false]) exitWith {_uiCommonInit};
private _uiCommonBuild = [] call ServoPeregrino_Organizador_UICommon_fnc_getBuildInfo;

private _old = missionNamespace getVariable [SP_ORG_WEAPONS_RUNTIME,createHashMap];
if (_old getOrDefault ["ready",false]) exitWith {
 [true,"WEAPONS_ALREADY_INITIALIZED","Runtime preservado."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _cap = ["weapons.runtime",1,"ServoPeregrino_Organizador_Weapons",createHashMapFromArray [
 ["ready",true],
 ["entryPoint","ServoPeregrino_Organizador_Weapons_fnc_getRuntimeStatus"],
 ["build",SERVO_PEREGRINO_ORGANIZADOR_WEAPONS_BUILD],
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
 ["kitRepositoryMode","SESSION_LOCAL_CANDIDATE"],
 ["kitApplication","SLOT_SAFE_APPLY_0_7_B"],
 ["rollbackGate","EXPLICIT_VERIFIED_0_7_C"],
 ["faultInjection","ISOLATED_LAB_ONLY"],
 ["undo","UNDO_DEFERRED"],
 ["applicationPlanSchema","0.7-A-application-plan-candidate"],
 ["applicationSnapshotSchema","0.7-A-application-snapshot-candidate"],
 ["applicationStrategy","FULL_LOADOUT_CLONE_SETUNITLOADOUT_FALSE_ACTIVE_0_7_B"],
 ["applicationMutation","TARGET_SLOT_ONLY_0_7_B"],
 ["applicationPostValidation","TARGET_PLUS_PRESERVATION_FINGERPRINT_0_7_B"],
 ["applicationRollback","SAFETY_FALLBACK_PRESENT_HARDEN_0_7_C"],
 ["kitUI","PLAYER_UI_0_6_E_R2_UX_CONVERGENCE_DIRECT_DRAFT_EQUIP_UICOMMON"],
 ["uiCheckpoint","0.6-F"],
 ["uiRevision","R6"],
 ["uiLayout","FOUR_PANEL_ITEMS_CONVERGENCE"],
 ["uiVisualFreeze","FINAL_0_6_F_R6_COMPACT_FILTER_SPACING_TEST_CONTRACT_HOTFIX"],
 ["uiDraftDiffHighlight","BASE_RECIPE_FIELD_DIFF_AMBER"],
 ["uiDraftPreviewLayout","EQUIPMENT_MIRRORED_KEEP_ASPECT_PREVIEW_READY"],
 ["uiSearchMode","INDEPENDENT_P2_P3_P4"],
 ["uiCatalogSearchMode","GLOBAL_QUERY_IGNORES_STORED_FILTERS"],
 ["uiNameEditingMode","EMPTY_ALLOWED_UNTIL_SAVE"],
 ["uiPreviewScaleMode","KEEP_ASPECT_CENTERED_2D"],
 ["uiCatalogFilterGrammar","UNIFORM_TEXT_BUTTONS_R6_COMPACT_LABEL_GAPS"],
 ["uiDraftAutoCreate","WEAPON_FROM_CATALOG_WHEN_NO_KIT"],
 ["uiDraftSlotVisibility","INTERNAL_ONLY"],
 ["uiPlayerFeedback","FRIENDLY_NO_INTERNAL_CODES"],
 ["uiCatalogMode","CONTINUOUS_WINDOW_VISIBLE_SLIDER_FOCUSED_REFRESH"],
 ["uiEquipmentView","READ_ONLY_CURRENT_WEAPON"],
 ["uiSlotLabels",createHashMapFromArray [["PRIMARY","Principal"],["HANDGUN","Porte"],["SECONDARY","Secundária"]]],
 ["uiInformationMode","DRAFT_PLUS_CATALOG_PLUS_EQUIPMENT_PRESENTATION"],
    ["uiCompatibilityMode","DRAFT_EDITABLE_COMPATIBILITY_SELECTORS"],
    ["uiWeaponBaseEditing","ANY_SUPPORTED_WEAPON_DYNAMIC_INTERNAL_SLOT"],
    ["uiNameAuthoring","INLINE_EDIT_SAVE_COMMIT"],
 ["uiCommonRequired",true],
 ["uiCommonMinimumVersion",SP_ORG_WEAPONS_UICOMMON_MIN_VERSION],
 ["uiCommonBuild",_uiCommonBuild],
 ["uiDirectDraftEquip",true],
 ["uiPhysicalApplication","LOCAL_DRAFT_APPLY_0_7_D"],
    ["uiDraft","LOCAL_WEAPONKIT_DRAFT_WITH_AUTHORING_CANDIDATE"],
    ["uiAuthoring","SESSION_LOCAL_DIRECT_CATALOG_TO_DRAFT_0_6_E_R2"],
 ["physicalIdentityProven",false],
 ["models","INTERNAL_CANDIDATES"],
 ["executionMode","MISSION_FIRST"]
]] call ServoPeregrino_Organizador_Nexus_fnc_registerCapability;
if !(_cap get "success") exitWith {_cap};

missionNamespace setVariable [SP_ORG_WEAPONS_RUNTIME,createHashMapFromArray [
 ["ready",true],
 ["status","WEAPONS_0_7_B_SLOT_SAFE_APPLY_PENDING_RUNTIME_VALIDATION"],
 ["build",[] call ServoPeregrino_Organizador_Weapons_fnc_getBuildInfo],
 ["physicalIdentityProven",false],
 ["identityStrategy","EVENT_DELTA_EVIDENCE_CANDIDATE"],
 ["configurationSchema","0.2-candidate"],
 ["configurationApply","ENGINE_ROUNDTRIP_CANDIDATE"],
 ["catalogSchema","0.3-catalog-candidate"],
 ["catalogStrategy","CFGWEAPONS_ENGINE_DISCOVERY"],
 ["compatibilityStrategy","ON_DEMAND_ENGINE_QUERY"],
 ["recipeSchema","0.4-recipe-candidate"],
 ["recipeStrategy","DESIRED_BUILD_MODEL"],
 ["kitSchema","0.5-kit-candidate"],
 ["kitRepositoryMode","SESSION_LOCAL_CANDIDATE"],
 ["kitApplication","SLOT_SAFE_APPLY_0_7_B"],
 ["rollbackGate","EXPLICIT_VERIFIED_0_7_C"],
 ["faultInjection","ISOLATED_LAB_ONLY"],
 ["undo","UNDO_DEFERRED"],
 ["applicationPlanSchema","0.7-A-application-plan-candidate"],
 ["applicationSnapshotSchema","0.7-A-application-snapshot-candidate"],
 ["applicationStrategy","FULL_LOADOUT_CLONE_SETUNITLOADOUT_FALSE_ACTIVE_0_7_B"],
 ["applicationMutation","TARGET_SLOT_ONLY_0_7_B"],
 ["applicationPostValidation","TARGET_PLUS_PRESERVATION_FINGERPRINT_0_7_B"],
 ["applicationRollback","SAFETY_FALLBACK_PRESENT_HARDEN_0_7_C"],
 ["kitUI","PLAYER_UI_0_6_E_R2_UX_CONVERGENCE_DIRECT_DRAFT_EQUIP_UICOMMON"],
 ["uiCheckpoint","0.6-F"],
 ["uiRevision","R6"],
 ["uiLayout","FOUR_PANEL_ITEMS_CONVERGENCE"],
 ["uiVisualFreeze","FINAL_0_6_F_R6_COMPACT_FILTER_SPACING_TEST_CONTRACT_HOTFIX"],
 ["uiDraftDiffHighlight","BASE_RECIPE_FIELD_DIFF_AMBER"],
 ["uiDraftPreviewLayout","EQUIPMENT_MIRRORED_KEEP_ASPECT_PREVIEW_READY"],
 ["uiSearchMode","INDEPENDENT_P2_P3_P4"],
 ["uiCatalogSearchMode","GLOBAL_QUERY_IGNORES_STORED_FILTERS"],
 ["uiNameEditingMode","EMPTY_ALLOWED_UNTIL_SAVE"],
 ["uiPreviewScaleMode","KEEP_ASPECT_CENTERED_2D"],
 ["uiCatalogFilterGrammar","UNIFORM_TEXT_BUTTONS_R6_COMPACT_LABEL_GAPS"],
 ["uiDraftAutoCreate","WEAPON_FROM_CATALOG_WHEN_NO_KIT"],
 ["uiDraftSlotVisibility","INTERNAL_ONLY"],
 ["uiPlayerFeedback","FRIENDLY_NO_INTERNAL_CODES"],
 ["uiCatalogMode","CONTINUOUS_WINDOW_VISIBLE_SLIDER_FOCUSED_REFRESH"],
 ["uiEquipmentView","READ_ONLY_CURRENT_WEAPON"],
 ["uiSlotLabels",createHashMapFromArray [["PRIMARY","Principal"],["HANDGUN","Porte"],["SECONDARY","Secundária"]]],
 ["uiInformationMode","DRAFT_PLUS_CATALOG_PLUS_EQUIPMENT_PRESENTATION"],
    ["uiCompatibilityMode","DRAFT_EDITABLE_COMPATIBILITY_SELECTORS"],
    ["uiWeaponBaseEditing","ANY_SUPPORTED_WEAPON_DYNAMIC_INTERNAL_SLOT"],
    ["uiNameAuthoring","INLINE_EDIT_SAVE_COMMIT"],
 ["uiCommonRequired",true],
 ["uiCommonMinimumVersion",SP_ORG_WEAPONS_UICOMMON_MIN_VERSION],
 ["uiCommonBuild",_uiCommonBuild],
 ["uiDirectDraftEquip",true],
 ["uiPhysicalApplication","LOCAL_DRAFT_APPLY_0_7_D"],
    ["uiDraft","LOCAL_WEAPONKIT_DRAFT_WITH_AUTHORING_CANDIDATE"],
    ["uiAuthoring","SESSION_LOCAL_DIRECT_CATALOG_TO_DRAFT_0_6_E_R2"],
 ["executionMode","MISSION_FIRST"],
 ["pboGate","DEFERRED"]
]];

private _kitStoreInit = [] call ServoPeregrino_Organizador_Weapons_fnc_initializeWeaponKitStore;
if !(_kitStoreInit get "success") exitWith {_kitStoreInit};

["WEAPONS","INFO","WEAPONS 0.7-D INITIALIZED - current draft local apply without autosave; explicit verified rollback; Undo deferred."] call ServoPeregrino_Organizador_Nexus_fnc_log;
[true,"WEAPONS_INITIALIZED","0.7-D candidata pronta para teste real: EQUIPAR RASCUNHO sem salvar; Plan/Snapshot preservados e rollback verificado."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
