#include "..\..\script_version.hpp"
params [["_target", "ANY", [""]]];
private _t = toUpper _target; if (_t isEqualTo "U") then {_t = "UNIFORM";}; if (_t isEqualTo "C") then {_t = "VEST";}; if (_t isEqualTo "M") then {_t = "BACKPACK";};
if !(_t in ["ANY", "UNIFORM", "VEST", "BACKPACK"]) exitWith {[false, "ITEMS_DRAFT_TARGET_INVALID", "Target do Draft inválido.", createHashMapFromArray [["target", _target]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _state = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR, createHashMap];
if !(_state getOrDefault ["hasDraft", false]) exitWith {[false, "ITEMS_DRAFT_NOT_OPEN", "Nenhum Draft está aberto.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _draft = [(_state getOrDefault ["current", createHashMap])] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
if ((_draft getOrDefault ["preferredTarget", "ANY"]) isEqualTo _t) exitWith {[true, "ITEMS_DRAFT_TARGET_UNCHANGED", "Target já possui esse valor.", createHashMapFromArray [["draft", _draft]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
_draft set ["preferredTarget", _t]; _draft set ["dirty", true]; _draft set ["lastModifiedAtUTC", systemTimeUTC];
_state set ["current", _draft]; _state set ["revision", (_state getOrDefault ["revision", 0]) + 1]; _state set ["lastAction", "SET_TARGET"];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR, _state];
[true, "ITEMS_DRAFT_TARGET_CHANGED", "Target alterado somente no Draft.", createHashMapFromArray [["draft", [_draft] call ServoPeregrino_Organizador_Items_fnc_deepCopy]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
