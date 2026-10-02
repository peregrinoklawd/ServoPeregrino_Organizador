#include "script_version.hpp"

class CfgPatches
{
    class ServoPeregrino_Organizador_Items
    {
        name = "SP_ORG — Items";
        author = "Claudio Malta Telhada";
        requiredVersion = 2.18;
        requiredAddons[] = {"A3_Functions_F", "ServoPeregrino_Organizador_Nexus", "ServoPeregrino_Organizador_UICommon"};
        units[] = {};
        weapons[] = {};
        version = SERVO_PEREGRINO_ORGANIZADOR_ITEMS_SEMANTIC_VERSION;
    };
};

class CfgSounds
{
    sounds[] = {};
    class SP_ORG_Items_UI_Success  {name="SP_ORG_Items_UI_Success";  sound[]={"\ServoPeregrino_Organizador_Items\sounds\ui_success.ogg",0.55,1}; titles[]={};};
    class SP_ORG_Items_UI_Partial  {name="SP_ORG_Items_UI_Partial";  sound[]={"\ServoPeregrino_Organizador_Items\sounds\ui_partial.ogg",0.52,1}; titles[]={};};
    class SP_ORG_Items_UI_Failure  {name="SP_ORG_Items_UI_Failure";  sound[]={"\ServoPeregrino_Organizador_Items\sounds\ui_failure.ogg",0.52,1}; titles[]={};};
    class SP_ORG_Items_UI_Rollback {name="SP_ORG_Items_UI_Rollback"; sound[]={"\ServoPeregrino_Organizador_Items\sounds\ui_rollback.ogg",0.52,1}; titles[]={};};
    class SP_ORG_Items_UI_Blocked  {name="SP_ORG_Items_UI_Blocked";  sound[]={"\ServoPeregrino_Organizador_Items\sounds\ui_blocked.ogg",0.48,1}; titles[]={};};
};

class CfgFunctions
{
    class ServoPeregrino_Organizador_Items
    {
        tag = "ServoPeregrino_Organizador_Items";
        class Lifecycle {file="\ServoPeregrino_Organizador_Items\functions\lifecycle"; class initialize {preInit=1; postInit=1;}; class getBuildInfo {};};
        class Integration {file="\ServoPeregrino_Organizador_Items\functions\integration"; class validateNexus {};};
        class Runtime {file="\ServoPeregrino_Organizador_Items\functions\runtime"; class getRuntimeStatus {};};
        class Domain {file="\ServoPeregrino_Organizador_Items\functions\domain"; class deepCopy {}; class generateItemKitId {}; class isValidItemKitId {}; class createItemEntry {}; class validateItemEntryStructural {}; class validateItemEntrySemantic {}; class validateItemEntryEnvironmental {}; class normalizeItemEntries {}; class createItemKit {}; class validateItemKitStructural {}; class validateItemKitSemantic {}; class validateItemKitEnvironmental {}; class renameItemKit {}; class cloneItemKit {}; class createStoragePayload {}; class validateStorageStructural {}; class validateStorageSemantic {};};
        class Storage {file="\ServoPeregrino_Organizador_Items\functions\storage"; class getRepositoryKeys {}; class configureRepositoryTestMode {}; class migrateStorage {}; class buildRepositoryState {}; class getRepositoryStatus {}; class loadStorage {}; class saveStorage {}; class listKits {}; class getKit {}; class saveKit {}; class cloneKit {}; class deleteKit {}; class injectTestStoragePayload {};};
        class Library {file="\ServoPeregrino_Organizador_Items\functions\library"; class initializePublicLibraryAuthority {}; class getPublicLibrary {}; class listPublicKits {}; class getPublicKit {}; class commitPublicKitSnapshotServer {}; class requestPublicKitPublish {}; class serverHandlePublicLibraryRequest {}; class clientReceivePublicLibraryResult {}; class publishKitToPublic {}; class savePublicKitToPrivate {};};
        class Catalog {file="\ServoPeregrino_Organizador_Items\functions\catalog"; class getCatalogCategories {}; class deriveCatalogCategory {}; class classifyContentClass {}; class copyCatalogItem {}; class createCatalogItemFromConfig {}; class getCatalogStatus {}; class buildCatalog {}; class getCatalog {}; class filterCatalog {}; class resolveCatalogItem {}; class invalidateCatalogCache {};};
        class Inventory {file="\ServoPeregrino_Organizador_Items\functions\inventory"; class classifyCargoClass {}; class getLoadoutFingerprint {}; class compareLoadoutFingerprints {}; class resolvePlayerContainer {}; class analyzeContainerCargo {}; class capturePlayerContainer {}; class capturePlayerContainers {}; class captureContainerContent {}; class buildMutableFingerprint {}; class getMutableContentFingerprint {}; class getContainerCapacityMetrics {};};
        class Application {file="\ServoPeregrino_Organizador_Items\functions\application"; class getEntryUnitMass {}; class simulateApplicationEntries {}; class createApplicationPlan {}; class validateApplicationPlan {}; class captureContainerSnapshot {}; class mutateContainerEntry {}; class restoreContainerSnapshot {}; class rollbackApplication {}; class executeApplicationPlan {}; class executeSingleOperation {}; class createWholeKitApplicationPlan {}; class createReplaceApplicationPlan {}; class createClearApplicationPlan {}; class acquireApplicationLock {}; class releaseApplicationLock {}; class executeContentOperation {}; class chooseApplicationTarget {}; class resolveApplicationTarget {}; class getDraftApplicationSource {}; class getSavedKitApplicationSource {}; class executeDraftApplication {}; class executeSavedKitApplication {}; class getApplicationStatus {};};
        class Draft {file="\ServoPeregrino_Organizador_Items\functions\draft"; class createCaptureDraft {}; class getDraftState {}; class createNewDraft {}; class loadDraftFromKit {}; class openCaptureDraft {}; class setDraftName {}; class setDraftPreferredTarget {}; class addEntryToDraft {}; class addCatalogItemToDraft {}; class incrementDraftEntry {}; class decrementDraftEntry {}; class setDraftEntryQuantity {}; class removeDraftEntry {}; class clearDraftEntries {}; class mergeEntriesIntoDraft {}; class mergeKitIntoDraft {}; class saveDraft {}; class saveDraftAsNew {}; class discardDraft {}; class detachDraftFromPersistedKit {}; class deleteKitPreservingDraft {};};
        class UI {file="\ServoPeregrino_Organizador_Items\functions\ui"; class createUIState {}; class getUIState {}; class pushUIFeedback {}; class getUIFeedbackPalette {}; class classifyUIOutcome {}; class playUIFeedbackSound {}; class getUIMovementSoundProfile {}; class playUIMovementSound {}; class scanVanillaInventorySounds {}; class presentLogicalMutationResult {}; class presentUIResult {}; class escapeStructuredText {}; class refreshCatalogSelectionDetails {}; class resolveUIItemMetadata {}; class getUIEntryAwareness {}; class getUIItemKitAwareness {}; class formatUIMass {}; class getUITargetLabel {}; class refreshHeaderUI {}; class refreshHeaderStatusUI {}; class renderCatalogRowsUI {}; class renderEquipmentRowsUI {}; class captureEquipmentRowToDraft {}; class buildUIViewModel {}; class refreshInterface {}; class handleUIEvent {}; class handleDraftRowAction {}; class commitDraftQuantityFromControl {}; class handleUITransferToDraft {}; class getUIPhysicalReadiness {}; class refreshPhysicalMutationUI {}; class refreshDraftMutationUI {}; class refreshKitSwitchUI {}; class reconcilePrivateKitSelectionAfterDelete {}; class clearKitLibraryActionStatus {}; class refreshPhysicalTargetUI {}; class getUICatalogWindow {}; class refreshCatalogWindowUI {}; class refreshEquipmentViewUI {}; class createUIDragSnapshot {}; class createUIPhysicalRowCommand {}; class executeUITransferCommand {}; class executeEquipmentClear {}; class captureEquipmentToDraft {}; class handleUIDragEvent {}; class resolveUIPointerSource {}; class resolveUIPanelDropTarget {}; class finalizeUIPointerDrop {}; class updateUIDragVisualProxy {}; class updateUIItemTooltip {}; class cancelUIDrag {}; class handleDraftQuantityKeyDown {}; class getResponsiveCatalogLabels {}; class requestDraftTransition {}; class handleUIKeyDown {}; class handleUIWheel {}; class refreshEquipmentSelectionControls {}; class executeEquipmentRowAction {}; class requestEquipmentRowAction {}; class commitEquipmentQuantityFromControl {}; class handleEquipmentQuantityKeyDown {}; class onInterfaceLoad {}; class onInterfaceUnload {}; class openInterface {};};
        class Tests {file="\ServoPeregrino_Organizador_Items\functions\tests"; class resetRuntimeForTests {}; class runDelivery0_1Tests {}; class runDelivery0_2Tests {}; class runDelivery0_3Tests {}; class runDelivery0_4Tests {}; class runDelivery0_4_1Tests {}; class runDelivery0_4_2Tests {}; class runDelivery0_4_3Tests {}; class runDelivery0_5Tests {}; class runDelivery0_5_1Tests {}; class runDelivery0_6Tests {}; class runDelivery0_6_1Tests {}; class runDelivery0_7Tests {}; class runDelivery0_7_1Tests {}; class runDelivery0_7_2Tests {}; class runDelivery0_8Tests {}; class runDelivery0_8_1Tests {}; class runDelivery0_8_2Tests {}; class runDelivery0_8_3Tests {}; class runDelivery0_9Tests {}; class runDelivery0_9_1Tests {}; class runDelivery0_9_2Tests {}; class runDelivery0_9_3Tests {}; class getDelivery0_10TestContract {}; class runDelivery0_10CheckpointATests {}; class runDelivery0_10CheckpointBTests {}; class runDelivery0_10CheckpointCTests {}; class prepareCumulativeTestRun {}; class runDelivery0_10CheckpointDTests {}; class runDelivery0_10_0_7HotfixTests {}; class runDelivery0_11CheckpointATests {}; class runDelivery0_11CheckpointBTests {}; class runDelivery0_11CheckpointB1Tests {}; class runDelivery0_11CheckpointB2Tests {}; class runDelivery0_11CheckpointB3Tests {}; class runDelivery0_11CheckpointB4Tests {}; class runDelivery0_11CheckpointB5Tests {}; class runDelivery0_11CheckpointB6Tests {}; class runDelivery0_11CheckpointB61Tests {}; class runDelivery0_11CheckpointB7Tests {}; class runDelivery0_11CheckpointCTests {}; class runDelivery0_11CheckpointDTests {}; class runDelivery0_12CheckpointATests {}; class runDelivery0_12CheckpointBTests {}; class runDelivery0_12CheckpointCTests {}; class runDelivery0_12CheckpointC2Tests {}; class runDelivery0_12CheckpointC3Tests {}; class runDelivery0_12CheckpointC4Tests {}; class runDelivery0_12CheckpointC5Tests {}; class runDelivery0_12CheckpointC6Tests {}; class runDelivery0_12CheckpointC7Tests {}; class runDelivery0_12CheckpointC8Tests {}; class runDelivery0_12CheckpointC81Tests {}; class runDelivery0_12CheckpointD1Tests {}; class runDelivery0_12CheckpointD2Tests {}; class runDelivery0_12CheckpointD3Tests {}; class runDelivery0_12CheckpointD4Tests {}; class runDelivery0_12CheckpointD5Tests {}; class runDelivery0_12CheckpointD6Tests {}; class runDelivery0_12CheckpointD61Tests {}; class runDelivery0_12CheckpointD62Tests {}; class runDelivery0_12CheckpointD63Tests {}; class runDelivery0_12CheckpointD64Tests {}; class runDelivery0_12CheckpointD70Tests {}; class runDelivery0_12CheckpointD71Tests {}; class runDelivery0_12CheckpointD72Tests {}; class runDelivery0_12CheckpointD73Tests {}; class runDelivery0_12CheckpointD74Tests {}; class runDelivery0_13CheckpointATests {}; class runUICommonEquivalenceTests {}; class captureProductionRepositorySnapshot {}; class restoreProductionRepositorySnapshot {}; class classifyLeakedTestKit {}; class findLeakedTestKits {}; class cleanupLeakedTestKits {}; class installTestActions {};};
    };
};

#include "ui\items_dialog.hpp"

class CfgRemoteExec
{
    class Functions
    {
        class ServoPeregrino_Organizador_Items_fnc_serverHandlePublicLibraryRequest {allowedTargets=2; jip=0;};
        class ServoPeregrino_Organizador_Items_fnc_clientReceivePublicLibraryResult {allowedTargets=1; jip=0;};
    };
};
