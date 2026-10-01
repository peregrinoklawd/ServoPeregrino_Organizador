#include "..\..\script_version.hpp"
private _existing = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR, createHashMap];
if ((count _existing) > 0) exitWith {[_existing] call ServoPeregrino_Organizador_Items_fnc_deepCopy};
private _state = createHashMapFromArray [
    ["version", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VERSION], ["ready", true], ["open", false], ["refreshing", false],
    ["readOnlyShell", false], ["draftInteractionReady", true], ["physicalMutationAvailable", true], ["physicalMutationEnabled", false], ["physicalCommandEnabled", false],
    ["equipmentViewCommandEnabled", false], ["resolvedEquipmentViewTarget", ""],
    ["applicationTarget", "ANY"], ["equipmentView", "U"],
    ["kitQuery", ""], ["kitLibraryMode", "PRIVATE"], ["selectedPublicKitId", ""], ["publicLibraryRevision", 0], ["kitLibraryActionStatus", ""], ["draftQuery", ""], ["catalogQuery", ""], ["catalogCategory", "ALL"], ["equipmentQuery", ""],
    ["catalogOffset", 0], ["catalogWindowSize", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_WINDOW_SIZE], ["catalogTotalFiltered",0], ["catalogMaxOffset",0], ["catalogScrollRatio",0], ["catalogContinuousScrollCount",0],
    ["selectedKitId", ""], ["selectedCatalogClass", ""], ["selectedDraftRowKey", []], ["selectedEquipmentPayload", []], ["selectedEquipmentView", "U"],
    ["wheelConsumeCount",0], ["wheelManualScrollCount",0], ["lastWheelScrollIDC",-1], ["lastWheelTick",-1],
    ["dragState", createHashMapFromArray [["active",false],["sourceType",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAG_NONE],["sourceIDC",-1],["sourceId",""],["sourcePayload",[]],["hasSourcePayload",false],["startedAtTick",-1]] ], ["dragHoverArea","OUTSIDE"], ["dragHoverDestination",""],
    ["pointerDragCandidate",createHashMap], ["pointerDragTravel",0], ["pointerButtonDown",false], ["pointerCandidateTick",-1],
    ["temporaryMessage", "Organizador pronto. Selecione um kit ou arraste itens entre os painéis."],
    ["lastFeedbackKind", "INFO"], ["history", []],
    ["soundEnabled", true], ["soundPerformanceHold", false], ["soundHistory", []], ["lastSoundOutcome", ""], ["lastSoundClass", ""], ["lastSoundPlayed", false], ["lastSoundTick", -1],
    ["movementSoundHistory", []], ["lastMovementSound", ""], ["lastMovementSoundPath", ""], ["lastMovementSoundClass", ""], ["lastMovementSoundMethod", ""], ["lastMovementSoundId", -1], ["lastMovementSoundPlayed", false],
    ["lastOutcome", ""], ["lastOutcomeSummary", ""], ["lastOutcomeCode", ""], ["lastOutcomeMetrics", createHashMap],
    ["lastDraftTotalMass",0], ["lastDraftUnknownMassCount",0], ["lastEquipmentContentMass",0], ["lastEquipmentUnknownMassCount",0], ["lastEquipmentCapacity",createHashMap], ["lastPhysicalCapacity",createHashMap],
    ["revision", 0], ["openedAtTick", -1], ["lastRefreshTick", -1],
    ["lastRefreshMode", "NONE"], ["fullRefreshCount", 0], ["focusedRefreshCount", 0], ["draftFocusedRefreshCount", 0], ["catalogFocusedRefreshCount", 0], ["equipmentFocusedRefreshCount", 0], ["kitSwitchFocusedRefreshCount", 0], ["equipmentCaptureCount", 0], ["targetRefreshCount", 0], ["lastFocusedRefreshTarget", ""], ["lastDraftFocusedRefreshDurationMs", -1], ["lastCatalogFocusedRefreshDurationMs", -1], ["lastCatalogFocusedFilterDurationMs", -1], ["lastCatalogProjectionBuildDurationMs", -1], ["catalogProjectionBuildCount", 0], ["lastEquipmentFocusedRefreshDurationMs", -1], ["lastEquipmentFocusedCaptureDurationMs", -1], ["lastEquipmentFocusedRenderDurationMs", -1], ["lastEquipmentFocusedCaptured", false], ["lastKitSwitchFocusedRefreshDurationMs", -1], ["lastKitSwitchFullDelta", -1], ["lastKitSwitchCatalogUntouched", false], ["lastKitSwitchEquipmentUntouched", false], ["lastKitSwitchEquipmentCaptureDelta", -1], ["lastKitSwitchTargetRefreshDelta", -1], ["lastFullRefreshDurationMs", -1], ["lastPhysicalFocusedRefreshDurationMs", -1], ["lastPhysicalFocusedCaptureDurationMs", -1], ["lastDraftFocusedRefreshReason", ""], ["uiPerfTracing", true], ["uiPerfHistory", []]
];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR, _state];
[_state] call ServoPeregrino_Organizador_Items_fnc_deepCopy
