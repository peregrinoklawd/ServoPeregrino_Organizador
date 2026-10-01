#include "..\..\script_version.hpp"

private _state = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR, createHashMap];
if ((count _state) isEqualTo 0) then {
    _state = createHashMapFromArray [
        ["ready", true],
        ["hasDraft", false],
        ["current", createHashMap],
        ["baseline", createHashMap],
        ["revision", 0],
        ["lastAction", "NONE"]
    ];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR, _state];
};

private _hasDraft = _state getOrDefault ["hasDraft", false];
private _current = if (_hasDraft) then {[(_state getOrDefault ["current", createHashMap])] call ServoPeregrino_Organizador_Items_fnc_deepCopy} else {createHashMap};
[
    true,
    if (_hasDraft) then {"ITEMS_DRAFT_READY"} else {"ITEMS_DRAFT_EMPTY"},
    if (_hasDraft) then {"Draft atual retornado como cópia runtime."} else {"Draft Service pronto sem draft aberto."},
    createHashMapFromArray [
        ["ready", _state getOrDefault ["ready", true]],
        ["hasDraft", _hasDraft],
        ["revision", _state getOrDefault ["revision", 0]],
        ["lastAction", _state getOrDefault ["lastAction", "NONE"]],
        ["current", _current]
    ]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
