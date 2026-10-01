#include "..\..\script_version.hpp"
params [["_message","",[""]],["_kind","INFO",[""]]];
private _state = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR, createHashMap];
if ((count _state) isEqualTo 0) then {_state = [] call ServoPeregrino_Organizador_Items_fnc_createUIState;};
private _kindU = toUpper _kind;
if !(_kindU in ["SUCCESS","INFO","WARN","ERROR"]) then {_kindU = "INFO";};
private _history = +(_state getOrDefault ["history", []]);
if (_message isNotEqualTo "") then {
    _history pushBack [_kindU, _message, diag_tickTime];
    while {(count _history) > 6} do {_history deleteAt 0;};
    _state set ["temporaryMessage", _message];
    _state set ["lastFeedbackKind", _kindU];
};
_state set ["history", _history];
_state set ["revision", (_state getOrDefault ["revision",0]) + 1];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR, _state];
true
