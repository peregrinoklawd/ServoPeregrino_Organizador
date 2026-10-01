#include "..\..\script_version.hpp"
params [
 ["_message","",[""]],
 ["_kind","INFO",[""]],
 ["_addHistory",true,[false]]
];

private _state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
if ((count _state) isEqualTo 0) then {
 [] call ServoPeregrino_Organizador_Weapons_fnc_createUIState;
 _state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
};

_state set ["temporaryMessage",_message];
_state set ["lastFeedbackKind",toUpperANSI _kind];

if (_addHistory && {_message isNotEqualTo ""}) then {
 private _history = +(_state getOrDefault ["history",[]]);
 _history pushBack _message;
 while {(count _history) > 5} do {_history deleteAt 0};
 _state set ["history",_history];
};

_state set ["revision",(_state getOrDefault ["revision",0]) + 1];
missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
true
