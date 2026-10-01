params [["_kitId", "", [""]]];
private _kitR = [_kitId] call ServoPeregrino_Organizador_Items_fnc_getKit;
if !(_kitR getOrDefault ["success", false]) exitWith {_kitR};
private _kit = ((_kitR getOrDefault ["data", createHashMap]) getOrDefault ["kit", []]);
private _source = createHashMapFromArray [
    ["kind", "SAVED_KIT"], ["identity", _kit # 2], ["name", _kit # 3], ["preferredTarget", _kit # 4],
    ["updatedAtUTC", +(_kit # 7)], ["entries", [(_kit # 8)] call ServoPeregrino_Organizador_Items_fnc_deepCopy]
];
[true, "ITEMS_SAVED_KIT_APPLICATION_SOURCE_READY", "ItemKit persistido foi lido como snapshot lógico imutável para aplicação.", createHashMapFromArray [["source", _source]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
