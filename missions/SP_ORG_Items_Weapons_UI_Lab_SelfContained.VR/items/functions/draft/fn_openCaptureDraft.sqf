#include "..\..\script_version.hpp"

params ["_captureDraft"];
if !(_captureDraft isEqualType createHashMap) exitWith {
    [false, "ITEMS_DRAFT_CAPTURE_INVALID", "Capture draft precisa ser um HashMap runtime.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _state = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR, createHashMap];
private _current = _state getOrDefault ["current", createHashMap];
if ((_state getOrDefault ["hasDraft", false]) && {_current getOrDefault ["dirty", false]}) exitWith {
    [false, "ITEMS_DRAFT_DIRTY_BLOCKS_REPLACE", "Existe um Draft dirty. Salve ou descarte explicitamente antes de adotar uma captura.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _entries = _captureDraft getOrDefault ["entries", []];
private _normalized = [_entries] call ServoPeregrino_Organizador_Items_fnc_normalizeItemEntries;
if !(_normalized getOrDefault ["success", false]) exitWith {_normalized};
private _target = toUpper (_captureDraft getOrDefault ["preferredTarget", "ANY"]);
if !(_target in ["ANY", "UNIFORM", "VEST", "BACKPACK"]) then {_target = "ANY";};
private _origin = _captureDraft getOrDefault ["origin", ["CAPTURE", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CONTAINER_PROVIDER]];
if ((count _origin) isNotEqualTo 2) then {_origin = ["CAPTURE", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CONTAINER_PROVIDER];};
private _now = systemTimeUTC;
private _draft = createHashMapFromArray [
    ["version", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_VERSION], ["mode", "NEW"], ["kitId", ""], ["baseUpdatedAtUTC", []],
    ["name", _captureDraft getOrDefault ["name", "Captura de equipamento"]], ["preferredTarget", _target],
    ["origin", [_origin] call ServoPeregrino_Organizador_Items_fnc_deepCopy],
    ["entries", [((_normalized getOrDefault ["data", createHashMap]) getOrDefault ["entries", []])] call ServoPeregrino_Organizador_Items_fnc_deepCopy],
    ["dirty", true], ["createdFrom", "CAPTURE"], ["openedAtUTC", +_now], ["lastModifiedAtUTC", +_now]
];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR, createHashMapFromArray [
    ["ready", true], ["hasDraft", true], ["current", _draft], ["baseline", createHashMap],
    ["revision", (_state getOrDefault ["revision", 0]) + 1], ["lastAction", "OPEN_CAPTURE"]
]];
[true, "ITEMS_DRAFT_CAPTURE_OPENED", "Capture draft adotado como Draft NEW sem persistência automática.", createHashMapFromArray [["draft", [_draft] call ServoPeregrino_Organizador_Items_fnc_deepCopy]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
