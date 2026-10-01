#include "..\..\script_version.hpp"
params [["_kitId", "", [""]]];
private _get = [_kitId] call ServoPeregrino_Organizador_Items_fnc_getKit; if !(_get getOrDefault ["success", false]) exitWith {_get}; private _kit = ((_get getOrDefault ["data", createHashMap]) getOrDefault ["kit", []]); private _merged = [(_kit # 8)] call ServoPeregrino_Organizador_Items_fnc_mergeEntriesIntoDraft; if !(_merged getOrDefault ["success", false]) exitWith {_merged};
[true, "ITEMS_DRAFT_KIT_MERGED", "Payload do ItemKit foi copiado/mesclado no Draft atual sem autosave.", createHashMapFromArray [["sourceKitId", _kitId], ["draft", ((_merged getOrDefault ["data", createHashMap]) getOrDefault ["draft", createHashMap])]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
