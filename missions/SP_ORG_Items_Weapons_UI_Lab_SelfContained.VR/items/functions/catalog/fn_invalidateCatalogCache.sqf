#include "..\..\script_version.hpp"

params [["_reason", "EXPLICIT", [""]]];

private _buildState = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_BUILD_STATE_VAR, createHashMap];
if (_buildState getOrDefault ["running", false]) exitWith {
    [
        false,
        "ITEMS_CATALOG_BUILD_BUSY",
        "Cache não pode ser invalidado enquanto CONFIG_ALL está sendo construído.",
        createHashMapFromArray [["reason", _reason], ["buildState", _buildState]]
    ] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_CACHE_VAR, createHashMap];
private _metrics = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_METRICS_VAR, createHashMap];
if ((count _metrics) isEqualTo 0) then {
    _metrics = createHashMapFromArray [
        ["buildCount", 0], ["configScanCount", 0], ["scanAttemptCount", 0], ["cacheHitCount", 0],
        ["invalidationCount", 0], ["configVisitedCount", 0], ["candidateCount", 0],
        ["weaponPrefilterSkippedCount", 0], ["magazineFastPathCount", 0],
        ["lastBuildDurationMs", 0], ["lastInvalidationReason", ""]
    ];
};
_metrics set ["invalidationCount", (_metrics getOrDefault ["invalidationCount", 0]) + 1];
_metrics set ["lastInvalidationReason", _reason];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_METRICS_VAR, _metrics];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_BUILD_STATE_VAR, createHashMap];

private _runtime = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_RUNTIME_VAR, createHashMap];
if ((count _runtime) > 0) then {
    _runtime set ["catalogCacheBuilt", false];
    _runtime set ["catalogCacheItemCount", 0];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_RUNTIME_VAR, _runtime];
};

[
    true,
    "ITEMS_CATALOG_CACHE_INVALIDATED",
    "Cache de catálogo invalidado explicitamente; próxima consulta fará novo build.",
    createHashMapFromArray [["reason", _reason], ["provider", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_PROVIDER]]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
