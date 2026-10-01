#include "..\..\script_version.hpp"

params [["_force", false, [false]]];

private _cache = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_CACHE_VAR, createHashMap];
private _cacheValid = (_cache getOrDefault ["provider", ""]) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_PROVIDER
    && {(_cache getOrDefault ["buildKey", ""]) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD};

private _metrics = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_METRICS_VAR, createHashMap];
if ((count _metrics) isEqualTo 0) then {
    _metrics = createHashMapFromArray [
        ["buildCount", 0],
        ["configScanCount", 0],
        ["scanAttemptCount", 0],
        ["cacheHitCount", 0],
        ["invalidationCount", 0],
        ["configVisitedCount", 0],
        ["candidateCount", 0],
        ["weaponPrefilterSkippedCount", 0],
        ["magazineFastPathCount", 0],
        ["lastBuildDurationMs", 0],
        ["lastInvalidationReason", ""]
    ];
};

if (_cacheValid && {!_force}) exitWith {
    _metrics set ["cacheHitCount", (_metrics getOrDefault ["cacheHitCount", 0]) + 1];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_METRICS_VAR, _metrics];
    [
        true,
        "ITEMS_CATALOG_CACHE_HIT",
        "Catálogo já estava construído para esta sessão/build; configs não foram revarridos.",
        createHashMapFromArray [
            ["provider", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_PROVIDER],
            ["itemCount", count (_cache getOrDefault ["items", []])],
            ["cacheHit", true],
            ["buildKey", _cache getOrDefault ["buildKey", ""]]
        ]
    ] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _existingBuild = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_BUILD_STATE_VAR, createHashMap];
if (_existingBuild getOrDefault ["running", false]) exitWith {
    [
        false,
        "ITEMS_CATALOG_BUILD_IN_PROGRESS",
        "Já existe uma construção CONFIG_ALL em andamento. A chamada concorrente foi recusada sem iniciar nova varredura.",
        createHashMapFromArray [
            ["provider", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_PROVIDER],
            ["buildState", _existingBuild]
        ]
    ] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _startedAt = diag_tickTime;
private _items = [];
private _index = createHashMap;
private _visited = 0;
private _candidates = 0;
private _weaponPrefilterSkipped = 0;
private _magazineFastPath = 0;
private _roots = ["CfgWeapons", "CfgMagazines"];

private _buildState = createHashMapFromArray [
    ["running", true],
    ["provider", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_PROVIDER],
    ["buildKey", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],
    ["startedAtTick", _startedAt],
    ["currentRoot", ""],
    ["visitedConfigClasses", 0],
    ["candidateCount", 0],
    ["itemCount", 0]
];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_BUILD_STATE_VAR, _buildState];
_metrics set ["scanAttemptCount", (_metrics getOrDefault ["scanAttemptCount", 0]) + 1];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_METRICS_VAR, _metrics];

diag_log format [
    "[SP_ORG] [ITEMS] [CATALOG 0.5.1] BUILD_START provider=%1 build=%2",
    SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_PROVIDER,
    SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD
];

{
    private _rootName = _x;
    private _root = configFile >> _rootName;
    _buildState set ["currentRoot", _rootName];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_BUILD_STATE_VAR, _buildState];

    for "_i" from 0 to ((count _root) - 1) do {
        private _cfg = _root select _i;
        if (isClass _cfg) then {
            _visited = _visited + 1;
            private _className = configName _cfg;
            private _scope = getNumber (_cfg >> "scope");
            private _scopeArsenal = getNumber (_cfg >> "scopeArsenal");
            private _displayName = getText (_cfg >> "displayName");

            if ((_className isNotEqualTo "") && {_displayName isNotEqualTo ""} && {(_scope >= 2) || {_scopeArsenal >= 2}}) then {
                // CfgWeapons contém também armas-base em grande volume. Classes de inventário
                // elegíveis têm ItemInfo; prefiltrar evita BIS_fnc_itemType em armas óbvias.
                private _shouldResolve = true;
                if (_rootName isEqualTo "CfgWeapons") then {
                    _shouldResolve = isClass (_cfg >> "ItemInfo");
                    if (!_shouldResolve) then {
                        _weaponPrefilterSkipped = _weaponPrefilterSkipped + 1;
                    };
                };

                if (_shouldResolve) then {
                    _candidates = _candidates + 1;
                    if (_rootName isEqualTo "CfgMagazines") then {
                        _magazineFastPath = _magazineFastPath + 1;
                    };

                    private _catalogItemResult = [_className, _rootName] call ServoPeregrino_Organizador_Items_fnc_createCatalogItemFromConfig;
                    if (_catalogItemResult getOrDefault ["success", false]) then {
                        private _catalogItem = ((_catalogItemResult getOrDefault ["data", createHashMap]) getOrDefault ["item", createHashMap]);
                        if ((_catalogItem getOrDefault ["eligible", false]) && {(count (_index getOrDefault [_className, createHashMap])) isEqualTo 0}) then {
                            _items pushBack _catalogItem;
                            _index set [_className, _catalogItem];
                        };
                    };
                };
            };

            if ((_visited mod 500) isEqualTo 0) then {
                _buildState set ["visitedConfigClasses", _visited];
                _buildState set ["candidateCount", _candidates];
                _buildState set ["itemCount", count _items];
                missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_BUILD_STATE_VAR, _buildState];

                if ((_visited mod 2000) isEqualTo 0) then {
                    diag_log format [
                        "[SP_ORG] [ITEMS] [CATALOG 0.5.1] BUILD_PROGRESS root=%1 visited=%2 candidates=%3 items=%4 elapsed=%5ms",
                        _rootName,
                        _visited,
                        _candidates,
                        count _items,
                        round ((diag_tickTime - _startedAt) * 1000)
                    ];
                };

                // Em contexto agendado, devolver um frame ocasionalmente evita monopolizar
                // a fila de scripts em modsets grandes. Em contexto não agendado, não suspende.
                if (canSuspend) then {
                    uiSleep 0.001;
                };
            };
        };
    };
} forEach _roots;

_buildState set ["visitedConfigClasses", _visited];
_buildState set ["candidateCount", _candidates];
_buildState set ["itemCount", count _items];

if ((count _items) isEqualTo 0) exitWith {
    _buildState set ["running", false];
    _buildState set ["completed", false];
    _buildState set ["failureCode", "ITEMS_CATALOG_EMPTY"];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_BUILD_STATE_VAR, _buildState];
    [
        false,
        "ITEMS_CATALOG_EMPTY",
        "CONFIG_ALL não encontrou nenhuma classe CONTENT elegível; cache não foi publicado.",
        createHashMapFromArray [
            ["visitedConfigClasses", _visited],
            ["candidateCount", _candidates],
            ["weaponPrefilterSkippedCount", _weaponPrefilterSkipped]
        ]
    ] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

// A ordem bruta de CfgWeapons/CfgMagazines não é uma ordem de navegação.
// Ordenamos uma única vez após o scan para que filtros (ex.: MÉDICO) sejam previsíveis sem custo por interação.
_items = [_items, [], {
    format ["%1|%2",toLower (_x getOrDefault ["displayName",""]),toLower (_x getOrDefault ["className",""])]
}, "ASCEND"] call BIS_fnc_sortBy;

private _durationMs = round ((diag_tickTime - _startedAt) * 1000);
_cache = createHashMapFromArray [
    ["provider", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_PROVIDER],
    ["catalogModelVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_MODEL_VERSION],
    ["buildKey", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],
    ["builtAtUTC", systemTimeUTC],
    ["items", _items],
    ["index", _index]
];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_CACHE_VAR, _cache];

_metrics set ["buildCount", (_metrics getOrDefault ["buildCount", 0]) + 1];
_metrics set ["configScanCount", (_metrics getOrDefault ["configScanCount", 0]) + 1];
_metrics set ["configVisitedCount", _visited];
_metrics set ["candidateCount", _candidates];
_metrics set ["weaponPrefilterSkippedCount", _weaponPrefilterSkipped];
_metrics set ["magazineFastPathCount", _magazineFastPath];
_metrics set ["lastBuildDurationMs", _durationMs];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_METRICS_VAR, _metrics];

_buildState set ["running", false];
_buildState set ["completed", true];
_buildState set ["currentRoot", ""];
_buildState set ["durationMs", _durationMs];
_buildState set ["weaponPrefilterSkippedCount", _weaponPrefilterSkipped];
_buildState set ["magazineFastPathCount", _magazineFastPath];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_BUILD_STATE_VAR, _buildState];

[
    "ITEMS",
    "INFO",
    format ["Catalog CONFIG_ALL construído: %1 itens elegíveis, %2 configs visitados, %3 candidatos, %4 ms.", count _items, _visited, _candidates, _durationMs],
    createHashMapFromArray [
        ["provider", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_PROVIDER],
        ["itemCount", count _items],
        ["visitedConfigClasses", _visited],
        ["candidateCount", _candidates],
        ["weaponPrefilterSkippedCount", _weaponPrefilterSkipped],
        ["magazineFastPathCount", _magazineFastPath],
        ["durationMs", _durationMs]
    ]
] call ServoPeregrino_Organizador_Nexus_fnc_log;

private _runtime = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_RUNTIME_VAR, createHashMap];
if ((count _runtime) > 0) then {
    _runtime set ["catalogCacheBuilt", true];
    _runtime set ["catalogCacheItemCount", count _items];
    _runtime set ["catalogLastBuildDurationMs", _durationMs];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_RUNTIME_VAR, _runtime];
};

[
    true,
    "ITEMS_CATALOG_BUILT",
    "Catálogo CONFIG_ALL construído sob demanda e cacheado em missionNamespace.",
    createHashMapFromArray [
        ["provider", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_PROVIDER],
        ["itemCount", count _items],
        ["visitedConfigClasses", _visited],
        ["candidateCount", _candidates],
        ["weaponPrefilterSkippedCount", _weaponPrefilterSkipped],
        ["magazineFastPathCount", _magazineFastPath],
        ["durationMs", _durationMs],
        ["cacheHit", false],
        ["buildKey", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD]
    ]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
