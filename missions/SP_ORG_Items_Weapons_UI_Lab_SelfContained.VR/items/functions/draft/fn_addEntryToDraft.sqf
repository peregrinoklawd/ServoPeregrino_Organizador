#include "..\..\script_version.hpp"
params [["_entry", [], [[]]]];
private _valid = [_entry] call ServoPeregrino_Organizador_Items_fnc_validateItemEntrySemantic; if !(_valid getOrDefault ["success", false]) exitWith {_valid};
private _state = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR, createHashMap];
if !(_state getOrDefault ["hasDraft", false]) exitWith {[false, "ITEMS_DRAFT_NOT_OPEN", "Nenhum Draft está aberto.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _draft = [(_state getOrDefault ["current", createHashMap])] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _combined = [(_draft getOrDefault ["entries", []])] call ServoPeregrino_Organizador_Items_fnc_deepCopy; _combined pushBack ([_entry] call ServoPeregrino_Organizador_Items_fnc_deepCopy);
private _normalized = [_combined] call ServoPeregrino_Organizador_Items_fnc_normalizeItemEntries; if !(_normalized getOrDefault ["success", false]) exitWith {_normalized};
_draft set ["entries", [((_normalized getOrDefault ["data", createHashMap]) getOrDefault ["entries", []])] call ServoPeregrino_Organizador_Items_fnc_deepCopy]; _draft set ["dirty", true]; _draft set ["lastModifiedAtUTC", systemTimeUTC];
_state set ["current", _draft]; _state set ["revision", (_state getOrDefault ["revision", 0]) + 1]; _state set ["lastAction", "ADD_ENTRY"]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR, _state];
[true, "ITEMS_DRAFT_ENTRY_ADDED", "ItemEntry adicionada/mesclada no Draft em memória.", createHashMapFromArray [["draft", [_draft] call ServoPeregrino_Organizador_Items_fnc_deepCopy]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
