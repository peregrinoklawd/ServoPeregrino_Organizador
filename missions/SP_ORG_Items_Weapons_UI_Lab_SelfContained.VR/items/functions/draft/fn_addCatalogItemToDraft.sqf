#include "..\..\script_version.hpp"
params [["_className", "", [""]], ["_quantity", 1, [0]]];
if (_quantity <= 0 || {round _quantity isNotEqualTo _quantity}) exitWith {[false, "ITEMS_DRAFT_QUANTITY_INVALID", "Quantidade precisa ser inteiro positivo.", createHashMapFromArray [["quantity", _quantity]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _resolved = [_className] call ServoPeregrino_Organizador_Items_fnc_resolveCatalogItem; if !(_resolved getOrDefault ["success", false]) exitWith {_resolved};
private _item = ((_resolved getOrDefault ["data", createHashMap]) getOrDefault ["item", createHashMap]);
if !(_item getOrDefault ["available", false]) exitWith {[false, "ITEMS_DRAFT_CATALOG_ITEM_UNAVAILABLE", "Classe indisponível não pode ser materializada no Draft pelo catálogo atual.", createHashMapFromArray [["className", _className], ["item", _item]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
if !(_item getOrDefault ["eligible", false]) exitWith {[false, "ITEMS_DRAFT_CATALOG_ITEM_FOREIGN_DOMAIN", "Classe pertence a domínio reservado e não entra no Draft de Items.", createHashMapFromArray [["className", _className], ["item", _item]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _contentType = _item getOrDefault ["contentType", "UNKNOWN"];
private _entryResult = if (_contentType isEqualTo "MAGAZINE") then {["MAGAZINE", _className, _quantity, "DEFAULT_FULL", []] call ServoPeregrino_Organizador_Items_fnc_createItemEntry} else {["ITEM", _className, _quantity, "NONE", []] call ServoPeregrino_Organizador_Items_fnc_createItemEntry};
if !(_entryResult getOrDefault ["success", false]) exitWith {_entryResult};
private _entry = ((_entryResult getOrDefault ["data", createHashMap]) getOrDefault ["entry", []]);
private _added = [_entry] call ServoPeregrino_Organizador_Items_fnc_addEntryToDraft; if !(_added getOrDefault ["success", false]) exitWith {_added};
[true, "ITEMS_DRAFT_CATALOG_ITEM_ADDED", "Item elegível do Catalog foi convertido em ItemEntry e adicionado ao Draft.", createHashMapFromArray [["className", _className], ["entry", _entry], ["draft", ((_added getOrDefault ["data", createHashMap]) getOrDefault ["draft", createHashMap])]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
