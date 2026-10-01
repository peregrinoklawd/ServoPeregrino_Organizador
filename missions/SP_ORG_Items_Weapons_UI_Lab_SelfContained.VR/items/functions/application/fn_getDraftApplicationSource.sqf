private _draftR = [] call ServoPeregrino_Organizador_Items_fnc_getDraftState;
if !(_draftR getOrDefault ["success", false]) exitWith {_draftR};
private _data = _draftR getOrDefault ["data", createHashMap];
if !(_data getOrDefault ["hasDraft", false]) exitWith {[false, "ITEMS_DRAFT_EMPTY", "Não existe Draft para aplicar.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _current = _data getOrDefault ["current", createHashMap];
private _source = createHashMapFromArray [
    ["kind", "DRAFT"], ["identity", _current getOrDefault ["kitId", ""]], ["mode", _current getOrDefault ["mode", "NEW"]],
    ["dirty", _current getOrDefault ["dirty", false]], ["name", _current getOrDefault ["name", ""]],
    ["preferredTarget", _current getOrDefault ["preferredTarget", "ANY"]], ["entries", [(_current getOrDefault ["entries", []])] call ServoPeregrino_Organizador_Items_fnc_deepCopy]
];
[true, "ITEMS_DRAFT_APPLICATION_SOURCE_READY", "Estado corrente do Draft foi congelado como fonte lógica de aplicação, sem persistir.", createHashMapFromArray [["source", _source]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
