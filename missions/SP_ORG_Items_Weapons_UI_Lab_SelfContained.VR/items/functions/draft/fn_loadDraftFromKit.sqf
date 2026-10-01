#include "..\..\script_version.hpp"

params [["_kitId", "", [""]]];
private _state = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR, createHashMap];
private _current = _state getOrDefault ["current", createHashMap];
if ((_state getOrDefault ["hasDraft", false]) && {_current getOrDefault ["dirty", false]}) exitWith {
    [false, "ITEMS_DRAFT_DIRTY_BLOCKS_REPLACE", "Existe um Draft dirty. Salve ou descarte explicitamente antes de carregar outro kit.", createHashMapFromArray [["kitId", _kitId]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _get = [_kitId] call ServoPeregrino_Organizador_Items_fnc_getKit;
if !(_get getOrDefault ["success", false]) exitWith {_get};
private _kit = ((_get getOrDefault ["data", createHashMap]) getOrDefault ["kit", []]);
private _now = systemTimeUTC;
private _draft = createHashMapFromArray [
    ["version", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_VERSION], ["mode", "EDIT"], ["kitId", _kit # 2],
    ["baseUpdatedAtUTC", +(_kit # 7)], ["name", _kit # 3], ["preferredTarget", _kit # 4],
    ["origin", [(_kit # 5)] call ServoPeregrino_Organizador_Items_fnc_deepCopy],
    ["entries", [(_kit # 8)] call ServoPeregrino_Organizador_Items_fnc_deepCopy], ["dirty", false],
    ["createdFrom", "REPOSITORY"], ["openedAtUTC", +_now], ["lastModifiedAtUTC", +_now]
];
private _clean = [_draft] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _newState = createHashMapFromArray [
    ["ready", true], ["hasDraft", true], ["current", _draft], ["baseline", _clean],
    ["revision", (_state getOrDefault ["revision", 0]) + 1], ["lastAction", "LOAD_EDIT"]
];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR, _newState];
[true, "ITEMS_DRAFT_EDIT_LOADED", "ItemKit carregado como Draft EDIT sem alterar Repository.", createHashMapFromArray [["draft", [_draft] call ServoPeregrino_Organizador_Items_fnc_deepCopy]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
