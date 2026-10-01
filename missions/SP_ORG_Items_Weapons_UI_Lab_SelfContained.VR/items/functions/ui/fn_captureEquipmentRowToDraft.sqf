#include "..\..\script_version.hpp"
disableSerialization;
params [["_source",controlNull,[controlNull]]];
if (isNull _source) exitWith {false};
private _payload=+(_source getVariable ["SPORG_Items_equipmentPayload",[]]);
if ((count _payload) isNotEqualTo 5) exitWith {false};
private _r=["EQUIPMENT",_payload,"DRAFT","AUTO",player,"",createHashMapFromArray [["commandOrigin","EQUIPMENT_ROW_CAPTURE"],["autoCreateDraftIfMissing",true]]] call ServoPeregrino_Organizador_Items_fnc_executeUITransferCommand;
[_r,true] call ServoPeregrino_Organizador_Items_fnc_presentUIResult;
if (_r getOrDefault ["success",false]) then {["EQUIPMENT_ROW_TO_DRAFT"] call ServoPeregrino_Organizador_Items_fnc_refreshDraftMutationUI;};
_r getOrDefault ["success",false]
