#include "..\..\script_version.hpp"

params [["_className", "", [""]]];
if (_className isEqualTo "") exitWith {
    [false, "ITEMS_CATALOG_CLASS_EMPTY", "Classname vazio não pode ser resolvido.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _cache = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_CACHE_VAR, createHashMap];
private _cacheValid = (_cache getOrDefault ["provider", ""]) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_PROVIDER
    && {(_cache getOrDefault ["buildKey", ""]) isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD};

private _cached = createHashMap;
if (_cacheValid) then {
    private _index = _cache getOrDefault ["index", createHashMap];
    _cached = _index getOrDefault [_className, createHashMap];
};
if ((count _cached) > 0) exitWith {
    [
        true,
        "ITEMS_CATALOG_ITEM_RESOLVED_CACHE",
        "Item resolvido pelo índice do cache sem varrer configs.",
        createHashMapFromArray [["item", [_cached] call ServoPeregrino_Organizador_Items_fnc_copyCatalogItem], ["fromCache", true]]
    ] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _source = "";
if (isClass (configFile >> "CfgMagazines" >> _className)) then {_source = "CfgMagazines";};
if (_source isEqualTo "" && {isClass (configFile >> "CfgWeapons" >> _className)}) then {_source = "CfgWeapons";};

if (_source isEqualTo "") exitWith {
    private _unavailable = [_className, ""] call ServoPeregrino_Organizador_Items_fnc_createCatalogItemFromConfig;
    private _item = ((_unavailable getOrDefault ["data", createHashMap]) getOrDefault ["item", createHashMap]);
    [
        true,
        "ITEMS_CATALOG_ITEM_RESOLVED_UNAVAILABLE",
        "Classname não existe nos configs atuais e permanece explicitamente indisponível.",
        createHashMapFromArray [["item", _item], ["fromCache", false]]
    ] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _resolved = [_className, _source] call ServoPeregrino_Organizador_Items_fnc_createCatalogItemFromConfig;
if !(_resolved getOrDefault ["success", false]) exitWith {_resolved};
private _item = ((_resolved getOrDefault ["data", createHashMap]) getOrDefault ["item", createHashMap]);
[
    true,
    if (_item getOrDefault ["eligible", false]) then {"ITEMS_CATALOG_ITEM_RESOLVED_DIRECT"} else {"ITEMS_CATALOG_ITEM_RESOLVED_FOREIGN_DOMAIN"},
    "Classname resolvido por acesso direto ao config, sem varredura global.",
    createHashMapFromArray [["item", _item], ["fromCache", false]]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
