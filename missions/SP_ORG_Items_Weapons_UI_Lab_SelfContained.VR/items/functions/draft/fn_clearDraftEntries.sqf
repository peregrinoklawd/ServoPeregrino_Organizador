#include "..\..\script_version.hpp"

private _state = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR, createHashMap];
if !(_state getOrDefault ["hasDraft", false]) exitWith {
    [false, "ITEMS_DRAFT_NOT_OPEN", "Nenhum Kit/Draft está aberto para limpar.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _draft = [(_state getOrDefault ["current", createHashMap])] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _entries = [(_draft getOrDefault ["entries", []])] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _clearedCount = count _entries;
if (_clearedCount isEqualTo 0) exitWith {
    [true, "ITEMS_DRAFT_CLEAR_NOOP", "O Kit Selecionado já está sem itens; nenhum conteúdo físico foi alterado.", createHashMapFromArray [
        ["clearedCount", 0], ["draft", [_draft] call ServoPeregrino_Organizador_Items_fnc_deepCopy], ["mutatesInventory", false]
    ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

_draft set ["entries", []];
_draft set ["dirty", true];
_draft set ["lastModifiedAtUTC", systemTimeUTC];
_state set ["current", _draft];
_state set ["revision", (_state getOrDefault ["revision", 0]) + 1];
_state set ["lastAction", "CLEAR_ENTRIES"];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR, _state];

[true, "ITEMS_DRAFT_ENTRIES_CLEARED", format ["%1 item(ns) removido(s) somente do Kit Selecionado/Draft. O equipamento físico não foi alterado.", _clearedCount], createHashMapFromArray [
    ["clearedCount", _clearedCount],
    ["draft", [_draft] call ServoPeregrino_Organizador_Items_fnc_deepCopy],
    ["mutatesInventory", false]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
