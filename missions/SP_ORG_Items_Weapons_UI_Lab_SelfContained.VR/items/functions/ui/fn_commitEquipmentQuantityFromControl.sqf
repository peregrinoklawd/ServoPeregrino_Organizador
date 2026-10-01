#include "..\..\script_version.hpp"
disableSerialization;
params [["_control",controlNull,[controlNull]]];
if (isNull _control) exitWith {false};
private _state=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
if (_state getOrDefault ["refreshing",false]) exitWith {true};
private _raw=ctrlText _control;
private _chars=toArray _raw;
if (_raw isEqualTo "" || {(_chars findIf {!(_x in [48,49,50,51,52,53,54,55,56,57])})>=0}) exitWith {
    ["Informe uma quantidade inteira igual ou maior que zero.","WARN"] call ServoPeregrino_Organizador_Items_fnc_pushUIFeedback;
    [] call ServoPeregrino_Organizador_Items_fnc_refreshEquipmentSelectionControls;
    true
};
private _value=parseNumber _raw;
["QUANTITY",_control,_value] call ServoPeregrino_Organizador_Items_fnc_requestEquipmentRowAction;
true
