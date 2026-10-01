#include "..\..\script_version.hpp"
params [["_entryType", "ITEM", [""]], ["_className", "", [""]], ["_stateMode", "NONE", [""]]];
private _type = toUpper _entryType; private _mode = toUpper _stateMode;
private _state = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR, createHashMap]; if !(_state getOrDefault ["hasDraft", false]) exitWith {[false, "ITEMS_DRAFT_NOT_OPEN", "Nenhum Draft está aberto.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _draft = [(_state getOrDefault ["current", createHashMap])] call ServoPeregrino_Organizador_Items_fnc_deepCopy; private _entries = [(_draft getOrDefault ["entries", []])] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _index = _entries findIf {(_x # 1) isEqualTo _type && {(_x # 2) isEqualTo _className} && {(_x # 4) isEqualTo _mode}};
if (_index < 0) exitWith {[false, "ITEMS_DRAFT_ENTRY_NOT_FOUND", "ItemEntry não encontrada no Draft.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _removed = [_entries # _index] call ServoPeregrino_Organizador_Items_fnc_deepCopy; _entries deleteAt _index; _draft set ["entries", _entries]; _draft set ["dirty", true]; _draft set ["lastModifiedAtUTC", systemTimeUTC];
_state set ["current", _draft]; _state set ["revision", (_state getOrDefault ["revision", 0]) + 1]; _state set ["lastAction", "REMOVE_ENTRY"]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR, _state];
[true, "ITEMS_DRAFT_ENTRY_REMOVED", "ItemEntry removida integralmente do Draft.", createHashMapFromArray [["removed", _removed], ["draft", [_draft] call ServoPeregrino_Organizador_Items_fnc_deepCopy]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
