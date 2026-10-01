#include "..\..\script_version.hpp"

private _nexusValidation = [] call ServoPeregrino_Organizador_Items_fnc_validateNexus;
if !(_nexusValidation getOrDefault ["success", false]) exitWith {
    diag_log format [
        "[SP_ORG] [ITEMS] [ERROR] Falha de compatibilidade com Nexus: %1 — %2",
        _nexusValidation getOrDefault ["code", "UNKNOWN"],
        _nexusValidation getOrDefault ["message", ""]
    ];
    _nexusValidation
};

private _alreadyInitialized = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_INITIALIZED_VAR, false];
if (_alreadyInitialized) exitWith {
    [
        true,
        "ITEMS_ALREADY_INITIALIZED",
        "SP_ORG_Items já estava inicializado.",
        createHashMapFromArray [
            ["build", [] call ServoPeregrino_Organizador_Items_fnc_getBuildInfo],
            ["runtime", missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_RUNTIME_VAR, createHashMap]],
            ["repository", missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_REPOSITORY_VAR, createHashMap]]
        ]
    ] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _buildInfo = [] call ServoPeregrino_Organizador_Items_fnc_getBuildInfo;
private _runtime = createHashMapFromArray [
    ["status", "STARTING"],
    ["ready", false],
    ["uiReady", true],
    ["dataModelReady", true],
    ["repositoryReady", false],
    ["captureReady", true],
    ["catalogReady", true],
    ["draftReady", true],
    ["applicationReady", true],
        ["publicLibraryAuthority", "SERVER"],
        ["publicLibraryScope", "SESSION"],
    ["applicationPlanVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_PLAN_VERSION],
    ["containerSnapshotVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CONTAINER_SNAPSHOT_VERSION],
    ["applyResultVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLY_RESULT_VERSION],
    ["catalogProvider", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_PROVIDER],
    ["catalogCacheBuilt", false],
    ["catalogCacheItemCount", 0],
    ["containerProvider", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CONTAINER_PROVIDER],
    ["captureMutatesInventory", false],
    ["storageVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_STORAGE_VERSION],
    ["itemKitVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_KIT_VERSION],
    ["itemEntryVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_ENTRY_VERSION],
    ["catalogModelVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_MODEL_VERSION],
    ["draftVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_VERSION],
    ["uiStateVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VERSION],
    ["uiReadOnlyShell", false],
    ["initializedAtUTC", systemTimeUTC],
    ["build", _buildInfo]
];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_RUNTIME_VAR, _runtime];

// A arquitetura 1.0 exige catálogo lazy: initialize prepara o serviço, mas NÃO varre configs.
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_CACHE_VAR, createHashMap];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_BUILD_STATE_VAR, createHashMap];
if ((count (missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_METRICS_VAR, createHashMap])) isEqualTo 0) then {
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_METRICS_VAR, createHashMap];
};

// Draft Service é runtime-only e separado do Repository. Não há persistência automática.
if ((count (missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR, createHashMap])) isEqualTo 0) then {
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR, createHashMapFromArray [
        ["ready", true], ["hasDraft", false], ["current", createHashMap], ["baseline", createHashMap], ["revision", 0], ["lastAction", "NONE"]
    ]];
};

// CP-C ativa a camada física da UI sobre o Whole-Kit Engine já homologado no CP-B.1.
[] call ServoPeregrino_Organizador_Items_fnc_createUIState;
uiNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR, displayNull];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_STATE_VAR, createHashMapFromArray [
    ["ready", true], ["executing", false], ["activePlanId", ""], ["lastResult", createHashMap],
    ["lockToken", ""], ["lockOwner", ""], ["lockAcquiredAtTick", -1], ["lockRecovered", false],
    ["planVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_PLAN_VERSION],
    ["snapshotVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CONTAINER_SNAPSHOT_VERSION],
    ["applyResultVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLY_RESULT_VERSION]
]];

// 0.13-A: somente o servidor cria/muta a biblioteca pública; clientes aguardam a réplica.
private _publicAuthorityResult=if (isServer) then {[] call ServoPeregrino_Organizador_Items_fnc_initializePublicLibraryAuthority} else {[true,"ITEMS_PUBLIC_AUTHORITY_CLIENT_PENDING","Cliente aguardando a autoridade pública do servidor.",createHashMapFromArray [["authority","SERVER"],["scope","SESSION"]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
_runtime set ["publicLibraryAuthority","SERVER"];
_runtime set ["publicLibraryAuthoritative",isServer];
_runtime set ["publicLibraryScope","SESSION"];
_runtime set ["publicAuthorityResult",_publicAuthorityResult];

private _loadStorage = [] call ServoPeregrino_Organizador_Items_fnc_loadStorage;
if !(_loadStorage getOrDefault ["success", false]) exitWith {
    _runtime set ["status", "STORAGE_ERROR"];
    _runtime set ["storageError", _loadStorage];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_RUNTIME_VAR, _runtime];
    [
        false,
        "ITEMS_REPOSITORY_INITIALIZATION_FAILED",
        "SP_ORG_Items não iniciou porque o storage persistente não pôde ser validado/recuperado.",
        createHashMapFromArray [["storageResult", _loadStorage], ["runtime", _runtime]]
    ] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _repository = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_REPOSITORY_VAR, createHashMap];
_runtime set ["repositoryReady", _repository getOrDefault ["ready", false]];
_runtime set ["repositorySource", _repository getOrDefault ["source", "NONE"]];
_runtime set ["repositoryRecovered", _repository getOrDefault ["recovered", false]];
_runtime set ["repositoryKitCount", _repository getOrDefault ["kitCount", 0]];

private _runtimeCapabilityResult = [
    SERVO_PEREGRINO_ORGANIZADOR_ITEMS_RUNTIME_CAPABILITY,
    1,
    SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PROVIDER,
    createHashMapFromArray [
        ["description", "Identidade, build, Data Model, Repository, Capture, Catalog, Draft, UI e Physical Transaction Engine do SP_ORG_Items."],
        ["ready", true],
        ["dataModelReady", true],
        ["repositoryReady", true],
        ["captureReady", true],
        ["catalogReady", true],
        ["draftReady", true],
    ["applicationReady", true],
        ["publicLibraryAuthority", "SERVER"],
        ["publicLibraryScope", "SESSION"],
    ["applicationPlanVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_PLAN_VERSION],
    ["containerSnapshotVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CONTAINER_SNAPSHOT_VERSION],
    ["applyResultVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLY_RESULT_VERSION],
        ["draftVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_VERSION],
    ["uiStateVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VERSION],
    ["uiReadOnlyShell", false],
        ["catalogProvider", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_PROVIDER],
        ["catalogBuildMode", "LAZY_SESSION_CACHE"],
        ["containerProvider", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CONTAINER_PROVIDER],
        ["captureMutatesInventory", false],
        ["storageVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_STORAGE_VERSION],
        ["itemKitVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_KIT_VERSION],
        ["itemEntryVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_ENTRY_VERSION],
        ["catalogModelVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_MODEL_VERSION],
        ["entryPoint", "ServoPeregrino_Organizador_Items_fnc_getRuntimeStatus"],
        ["build", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD]
    ]
] call ServoPeregrino_Organizador_Nexus_fnc_registerCapability;

if !(_runtimeCapabilityResult getOrDefault ["success", false]) exitWith {
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_RUNTIME_VAR, createHashMap];
    [
        false,
        "ITEMS_RUNTIME_CAPABILITY_FAILED",
        "Não foi possível registrar items.runtime.",
        createHashMapFromArray [["nexusResult", _runtimeCapabilityResult]]
    ] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _uiCapabilityResult = [
    SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CAPABILITY,
    SERVO_PEREGRINO_ORGANIZADOR_ITEMS_INTERFACE_VERSION,
    SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PROVIDER,
    createHashMapFromArray [
        ["description", "Four-Panel UI com Draft Direct Manipulation, Physical UI readiness e Full DnD target-scoped."],
        ["ready", true],
        ["status", "DRAFT_DIRECT_MANIPULATION"],
        ["physicalUIStatus", "PHYSICAL_UI_FULL_DND"],
        ["entryPoint", "ServoPeregrino_Organizador_Items_fnc_openInterface"],
        ["displayClass", "SP_ORG_Items_Dialog"],
        ["displayIdd", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_IDD],
        ["panels", ["KITS","DRAFT","CATALOG","EQUIPMENT"]],
        ["mutatesInventory", false],
        ["draftInteractionReady", true],
        ["physicalMutationAvailable", true],
        ["physicalMutationEnabled", false],
        ["physicalCommandsMutateInventory", true],
        ["physicalCommandReadinessFunction", "ServoPeregrino_Organizador_Items_fnc_getUIPhysicalReadiness"]
    ]
] call ServoPeregrino_Organizador_Nexus_fnc_registerCapability;

if !(_uiCapabilityResult getOrDefault ["success", false]) exitWith {
    if ((_runtimeCapabilityResult getOrDefault ["code", ""]) isEqualTo "CAPABILITY_REGISTERED") then {
        [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_RUNTIME_CAPABILITY, SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PROVIDER] call ServoPeregrino_Organizador_Nexus_fnc_unregisterCapability;
    };
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_RUNTIME_VAR, createHashMap];
    [
        false,
        "ITEMS_UI_CAPABILITY_FAILED",
        "Não foi possível registrar items.ui.",
        createHashMapFromArray [["nexusResult", _uiCapabilityResult]]
    ] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

_runtime set ["status", "READY"];
_runtime set ["ready", true];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_RUNTIME_VAR, _runtime];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_INITIALIZED_VAR, true];

[
    SERVO_PEREGRINO_ORGANIZADOR_ITEMS_RUNTIME_EVENT,
    createHashMapFromArray [
        ["status", "READY"],
        ["build", _buildInfo],
        ["capabilities", [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_RUNTIME_CAPABILITY, SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CAPABILITY]],
        ["uiReady", true],
        ["dataModelReady", true],
        ["repositoryReady", true],
        ["captureReady", true],
        ["catalogReady", true],
        ["draftReady", true],
    ["applicationReady", true],
        ["publicLibraryAuthority", "SERVER"],
        ["publicLibraryScope", "SESSION"],
    ["applicationPlanVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_PLAN_VERSION],
    ["containerSnapshotVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CONTAINER_SNAPSHOT_VERSION],
    ["applyResultVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLY_RESULT_VERSION],
        ["draftVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_VERSION],
    ["uiStateVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VERSION],
    ["uiReadOnlyShell", false],
        ["catalogProvider", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_PROVIDER],
        ["catalogCacheBuilt", false],
        ["containerProvider", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CONTAINER_PROVIDER],
        ["captureMutatesInventory", false],
        ["repositorySource", _runtime getOrDefault ["repositorySource", "NONE"]],
        ["storageVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_STORAGE_VERSION],
        ["itemKitVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_KIT_VERSION],
        ["itemEntryVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_ENTRY_VERSION],
        ["catalogModelVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_MODEL_VERSION]
    ],
    SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PROVIDER,
    1
] call ServoPeregrino_Organizador_Nexus_fnc_publishEvent;

[
    "ITEMS",
    "INFO",
    "SP_ORG_Items 0.13-A inicializado: biblioteca pública continua SESSION-scoped, mas mutações multiplayer agora são autoritativas no servidor; clientes enviam snapshots validados; DnD/EXACT/Whole-Kit/Repository privado permanecem preservados.",
    createHashMapFromArray [
        ["build", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],
        ["storageSource", _runtime getOrDefault ["repositorySource", "NONE"]],
        ["catalogProvider", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_PROVIDER]
    ]
] call ServoPeregrino_Organizador_Nexus_fnc_log;

[
    true,
    "ITEMS_INITIALIZED",
    "SP_ORG_Items inicializado com sucesso.",
    createHashMapFromArray [["build", _buildInfo], ["runtime", _runtime], ["repository", _repository], ["storageResult", _loadStorage]]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
