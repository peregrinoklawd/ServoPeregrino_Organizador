#include "..\..\script_version.hpp"
params [["_kitId", "", [""]]];
private _state = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR, createHashMap];
if !(_state getOrDefault ["hasDraft", false]) exitWith {
    [true, "ITEMS_DRAFT_DETACH_NOOP", "Nenhum Draft aberto dependia do ItemKit excluído.", createHashMapFromArray [["kitId", _kitId], ["detached", false]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _current = _state getOrDefault ["current", createHashMap];
if !((_current getOrDefault ["mode", ""]) isEqualTo "EDIT" && {(_current getOrDefault ["kitId", ""]) isEqualTo _kitId}) exitWith {
    [true, "ITEMS_DRAFT_DETACH_NOOP", "O Draft aberto não usa o ItemKit excluído como backing persistido.", createHashMapFromArray [["kitId", _kitId], ["detached", false]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _detached = [_current] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _now = systemTimeUTC;
_detached set ["mode", "NEW"];
_detached set ["kitId", ""];
_detached set ["baseUpdatedAtUTC", []];
_detached set ["dirty", true];
_detached set ["createdFrom", "DELETE_DETACH"];
_detached set ["lastModifiedAtUTC", +_now];
_state set ["current", _detached];
_state set ["baseline", createHashMap];
_state set ["revision", (_state getOrDefault ["revision", 0]) + 1];
_state set ["lastAction", "DELETE_DETACH"];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR, _state];
[
    true,
    "ITEMS_DRAFT_DETACHED_FROM_DELETED_KIT",
    "ItemKit persistido foi removido; o conteúdo aberto foi preservado como Draft NEW não salvo.",
    createHashMapFromArray [["kitId", _kitId], ["detached", true], ["draft", [_detached] call ServoPeregrino_Organizador_Items_fnc_deepCopy]]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
