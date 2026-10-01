#include "..\..\script_version.hpp"

params [
    ["_sourceKitId", "", [""]],
    ["_newName", "", [""]]
];
private _get = [_sourceKitId] call ServoPeregrino_Organizador_Items_fnc_getKit;
if !(_get getOrDefault ["success", false]) exitWith {_get};
private _source = ((_get getOrDefault ["data", createHashMap]) getOrDefault ["kit", []]);
private _cloneResult = [_source, _newName] call ServoPeregrino_Organizador_Items_fnc_cloneItemKit;
if !(_cloneResult getOrDefault ["success", false]) exitWith {_cloneResult};
private _clone = ((_cloneResult getOrDefault ["data", createHashMap]) getOrDefault ["kit", []]);
private _metadataSource = [_clone # 9] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
// clonedFromId representa sempre a origem imediata do clone persistente.
// Remover valor herdado evita metadata ambígua ao clonar um clone.
private _metadata = _metadataSource select {
    !((_x isEqualType []) && {(count _x) >= 1} && {(_x # 0) isEqualTo "clonedFromId"})
};
_metadata pushBack ["clonedFromId", _sourceKitId];
_clone set [9, _metadata];
private _save = [_clone] call ServoPeregrino_Organizador_Items_fnc_saveKit;
if !(_save getOrDefault ["success", false]) exitWith {_save};
private _savedClone = ((_save getOrDefault ["data", createHashMap]) getOrDefault ["kit", _clone]);
[
    true,
    "ITEMS_KIT_PERSISTED_CLONED",
    "ItemKit foi clonado e persistido com novo ID.",
    createHashMapFromArray [["sourceId", _sourceKitId], ["cloneId", _savedClone # 2], ["kit", _savedClone]]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
