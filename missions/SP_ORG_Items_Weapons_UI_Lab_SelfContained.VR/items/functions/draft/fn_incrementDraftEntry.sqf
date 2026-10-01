#include "..\..\script_version.hpp"
params [["_entryType", "ITEM", [""]], ["_className", "", [""]], ["_stateMode", "NONE", [""]]];
private _type = toUpper _entryType; private _mode = toUpper _stateMode; private _state = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR, createHashMap]; if !(_state getOrDefault ["hasDraft", false]) exitWith {[false, "ITEMS_DRAFT_NOT_OPEN", "Nenhum Draft está aberto.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _draft = _state getOrDefault ["current", createHashMap]; private _entries = _draft getOrDefault ["entries", []]; private _index = _entries findIf {(_x # 1) isEqualTo _type && {(_x # 2) isEqualTo _className} && {(_x # 4) isEqualTo _mode}}; if (_index < 0) exitWith {[false, "ITEMS_DRAFT_ENTRY_NOT_FOUND", "ItemEntry não encontrada no Draft.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _entry = _entries # _index;
if (_mode isEqualTo "EXACT") exitWith {
    private _full = ["MAGAZINE", _className, 1, "DEFAULT_FULL", []] call ServoPeregrino_Organizador_Items_fnc_createItemEntry; if !(_full getOrDefault ["success", false]) exitWith {_full};
    private _added = [((_full getOrDefault ["data", createHashMap]) getOrDefault ["entry", []])] call ServoPeregrino_Organizador_Items_fnc_addEntryToDraft; if !(_added getOrDefault ["success", false]) exitWith {_added};
    [true, "ITEMS_DRAFT_EXACT_INCREMENT_AS_DEFAULT_FULL", "+ em EXACT preserva stateData e cria/incrementa DEFAULT_FULL separado.", createHashMapFromArray [["exactBefore", [_entry] call ServoPeregrino_Organizador_Items_fnc_deepCopy], ["draft", ((_added getOrDefault ["data", createHashMap]) getOrDefault ["draft", createHashMap])]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
[_type, _className, _mode, (_entry # 3) + 1] call ServoPeregrino_Organizador_Items_fnc_setDraftEntryQuantity
