#include "..\..\script_version.hpp"
params [["_name", "", [""]]];
private _state = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR, createHashMap];
if !(_state getOrDefault ["hasDraft", false]) exitWith {[false, "ITEMS_DRAFT_NOT_OPEN", "Nenhum Draft está aberto.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _draft = [(_state getOrDefault ["current", createHashMap])] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
if ((_draft getOrDefault ["name", ""]) isEqualTo _name) exitWith {[true, "ITEMS_DRAFT_NAME_UNCHANGED", "Nome do Draft já possui esse valor.", createHashMapFromArray [["draft", _draft]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
_draft set ["name", _name]; _draft set ["dirty", true]; _draft set ["lastModifiedAtUTC", systemTimeUTC];
_state set ["current", _draft]; _state set ["revision", (_state getOrDefault ["revision", 0]) + 1]; _state set ["lastAction", "SET_NAME"];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR, _state];
[true, "ITEMS_DRAFT_NAME_CHANGED", "Nome alterado apenas no Draft; Repository ainda não foi salvo.", createHashMapFromArray [["draft", [_draft] call ServoPeregrino_Organizador_Items_fnc_deepCopy]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
