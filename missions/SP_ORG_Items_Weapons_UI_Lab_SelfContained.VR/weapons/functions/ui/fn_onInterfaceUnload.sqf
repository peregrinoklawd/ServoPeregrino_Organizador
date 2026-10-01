#include "..\..\script_version.hpp"
private _state = missionNamespace getVariable [SP_ORG_WEAPONS_UI_STATE,createHashMap];
if ((count _state) > 0) then {
 _state set ["open",false];
 _state set ["revision",(_state getOrDefault ["revision",0]) + 1];
 missionNamespace setVariable [SP_ORG_WEAPONS_UI_STATE,_state];
};
diag_log "[SP_ORG] [WEAPONS] [UI] 0.6-E R1 interface closed; session-local drafts preserved.";
true
