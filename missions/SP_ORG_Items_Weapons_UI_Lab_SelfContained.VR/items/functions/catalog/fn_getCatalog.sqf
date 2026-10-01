#include "..\..\script_version.hpp"

private _build = [false] call ServoPeregrino_Organizador_Items_fnc_buildCatalog;
if !(_build getOrDefault ["success", false]) exitWith {_build};

private _cache = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_CACHE_VAR, createHashMap];
private _items = _cache getOrDefault ["items", []];
private _copies = _items apply {[_x] call ServoPeregrino_Organizador_Items_fnc_copyCatalogItem};
private _status = [] call ServoPeregrino_Organizador_Items_fnc_getCatalogStatus;

[
    true,
    "ITEMS_CATALOG_READY",
    "Catálogo runtime retornado a partir do cache da sessão/build.",
    createHashMapFromArray [
        ["provider", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_PROVIDER],
        ["items", _copies],
        ["count", count _copies],
        ["status", _status getOrDefault ["data", createHashMap]]
    ]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
