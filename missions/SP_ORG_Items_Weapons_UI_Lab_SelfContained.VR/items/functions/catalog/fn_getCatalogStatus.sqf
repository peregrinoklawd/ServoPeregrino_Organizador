#include "..\..\script_version.hpp"

private _cache = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_CACHE_VAR, createHashMap];
private _metrics = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_METRICS_VAR, createHashMap];
private _buildState = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_BUILD_STATE_VAR, createHashMap];
private _cacheBuilt = (_cache getOrDefault ["provider", ""]) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_PROVIDER
    && {(_cache getOrDefault ["buildKey", ""]) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD};

[
    true,
    "ITEMS_CATALOG_STATUS",
    "Estado do cache e da construção de catálogo obtido sem construir ou revarrer configs.",
    createHashMapFromArray [
        ["provider", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_PROVIDER],
        ["catalogModelVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_MODEL_VERSION],
        ["cacheBuilt", _cacheBuilt],
        ["buildKey", _cache getOrDefault ["buildKey", ""]],
        ["itemCount", if (_cacheBuilt) then {count (_cache getOrDefault ["items", []])} else {0}],
        ["buildCount", _metrics getOrDefault ["buildCount", 0]],
        ["configScanCount", _metrics getOrDefault ["configScanCount", 0]],
        ["scanAttemptCount", _metrics getOrDefault ["scanAttemptCount", 0]],
        ["cacheHitCount", _metrics getOrDefault ["cacheHitCount", 0]],
        ["invalidationCount", _metrics getOrDefault ["invalidationCount", 0]],
        ["configVisitedCount", _metrics getOrDefault ["configVisitedCount", 0]],
        ["candidateCount", _metrics getOrDefault ["candidateCount", 0]],
        ["weaponPrefilterSkippedCount", _metrics getOrDefault ["weaponPrefilterSkippedCount", 0]],
        ["magazineFastPathCount", _metrics getOrDefault ["magazineFastPathCount", 0]],
        ["lastBuildDurationMs", _metrics getOrDefault ["lastBuildDurationMs", 0]],
        ["lastInvalidationReason", _metrics getOrDefault ["lastInvalidationReason", ""]],
        ["buildInProgress", _buildState getOrDefault ["running", false]],
        ["buildCurrentRoot", _buildState getOrDefault ["currentRoot", ""]],
        ["buildVisitedCount", _buildState getOrDefault ["visitedConfigClasses", 0]],
        ["buildCandidateCount", _buildState getOrDefault ["candidateCount", 0]],
        ["buildPartialItemCount", _buildState getOrDefault ["itemCount", 0]],
        ["categories", [] call ServoPeregrino_Organizador_Items_fnc_getCatalogCategories]
    ]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
