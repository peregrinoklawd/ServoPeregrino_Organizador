#include "..\..\script_version.hpp"

private _initialized = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_INITIALIZED_VAR, false];
private _runtime = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_RUNTIME_VAR, createHashMap];
private _repository = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_REPOSITORY_VAR, createHashMap];
private _catalogStatusResult = [] call ServoPeregrino_Organizador_Items_fnc_getCatalogStatus;
private _catalogStatus = _catalogStatusResult getOrDefault ["data", createHashMap];
private _draftStatusResult = [] call ServoPeregrino_Organizador_Items_fnc_getDraftState;
private _draftStatus = _draftStatusResult getOrDefault ["data", createHashMap];
private _uiStatusResult = [] call ServoPeregrino_Organizador_Items_fnc_getUIState;
private _uiStatus = ((_uiStatusResult getOrDefault ["data", createHashMap]) getOrDefault ["state", createHashMap]);
private _applicationStatusResult = [] call ServoPeregrino_Organizador_Items_fnc_getApplicationStatus;
private _applicationStatus = _applicationStatusResult getOrDefault ["data", createHashMap];
private _data = createHashMapFromArray [
    ["initialized", _initialized],
    ["status", if (_initialized) then {_runtime getOrDefault ["status", "READY"]} else {_runtime getOrDefault ["status", "NOT_INITIALIZED"]}],
    ["ready", _initialized && {_runtime getOrDefault ["ready", false]}],
    ["uiReady", _runtime getOrDefault ["uiReady", false]],
    ["dataModelReady", _initialized && {_runtime getOrDefault ["dataModelReady", false]}],
    ["repositoryReady", _initialized && {_repository getOrDefault ["ready", false]}],
    ["captureReady", _initialized && {_runtime getOrDefault ["captureReady", false]}],
    ["catalogReady", _initialized && {_runtime getOrDefault ["catalogReady", false]}],
    ["draftReady", _initialized && {_runtime getOrDefault ["draftReady", false]}],
    ["applicationReady", _initialized && {_runtime getOrDefault ["applicationReady", false]}],
    ["applicationExecuting", _applicationStatus getOrDefault ["executing", false]],
    ["draftHasCurrent", _draftStatus getOrDefault ["hasDraft", false]],
    ["draftRevision", _draftStatus getOrDefault ["revision", 0]],
    ["uiOpen", _uiStatus getOrDefault ["open", false]],
    ["uiReadOnlyShell", _uiStatus getOrDefault ["readOnlyShell", true]],
    ["uiApplicationTarget", _uiStatus getOrDefault ["applicationTarget", "ANY"]],
    ["uiEquipmentView", _uiStatus getOrDefault ["equipmentView", "U"]],
    ["catalogProvider", _runtime getOrDefault ["catalogProvider", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_PROVIDER]],
    ["catalogCacheBuilt", _catalogStatus getOrDefault ["cacheBuilt", false]],
    ["catalogCacheItemCount", _catalogStatus getOrDefault ["itemCount", 0]],
    ["catalogBuildCount", _catalogStatus getOrDefault ["buildCount", 0]],
    ["catalogConfigScanCount", _catalogStatus getOrDefault ["configScanCount", 0]],
    ["catalogCacheHitCount", _catalogStatus getOrDefault ["cacheHitCount", 0]],
    ["catalogBuildInProgress", _catalogStatus getOrDefault ["buildInProgress", false]],
    ["catalogBuildVisitedCount", _catalogStatus getOrDefault ["buildVisitedCount", 0]],
    ["containerProvider", _runtime getOrDefault ["containerProvider", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CONTAINER_PROVIDER]],
    ["captureMutatesInventory", _runtime getOrDefault ["captureMutatesInventory", false]],
    ["repositorySource", _repository getOrDefault ["source", "NONE"]],
    ["repositoryRecovered", _repository getOrDefault ["recovered", false]],
    ["repositoryKitCount", _repository getOrDefault ["kitCount", 0]],
    ["storageVersion", _runtime getOrDefault ["storageVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_STORAGE_VERSION]],
    ["itemKitVersion", _runtime getOrDefault ["itemKitVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_KIT_VERSION]],
    ["itemEntryVersion", _runtime getOrDefault ["itemEntryVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_ENTRY_VERSION]],
    ["catalogModelVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_MODEL_VERSION],
    ["draftVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_VERSION],
    ["build", [] call ServoPeregrino_Organizador_Items_fnc_getBuildInfo],
    ["catalog", _catalogStatus],
    ["draft", _draftStatus],
    ["ui", _uiStatus],
    ["application", _applicationStatus],
    ["runtime", _runtime]
];

if (isNil "ServoPeregrino_Organizador_Nexus_fnc_createResult") exitWith {
    createHashMapFromArray [
        ["success", _initialized],
        ["code", if (_initialized) then {"ITEMS_RUNTIME_READY"} else {"ITEMS_NOT_INITIALIZED"}],
        ["message", if (_initialized) then {"SP_ORG_Items está pronto."} else {"SP_ORG_Items ainda não foi inicializado."}],
        ["data", _data],
        ["createdAtUTC", systemTimeUTC]
    ]
};

[
    _initialized,
    if (_initialized) then {"ITEMS_RUNTIME_READY"} else {"ITEMS_NOT_INITIALIZED"},
    if (_initialized) then {"SP_ORG_Items está pronto."} else {"SP_ORG_Items ainda não foi inicializado."},
    _data
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
