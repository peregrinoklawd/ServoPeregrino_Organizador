#include "..\..\script_version.hpp"
disableSerialization;
private _display=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR,displayNull];
if (isNull _display) exitWith {false};
private _payload=[];
private _state=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _view=_state getOrDefault ["equipmentView","U"];
private _table=_display displayCtrl SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_EQUIPMENT_TABLE_IDC;
if (!isNull _table) then {
    private _sel=ctCurSel _table;
    if (_sel>=0) then {private _controls=_table ctRowControls _sel; if ((count _controls)>0) then {_payload=+((_controls#0) getVariable ["SPORG_Items_equipmentPayload",[]]);};};
};
// fallback histórico para o listbox legado invisível.
if ((count _payload) isNotEqualTo 5) then {
    private _list=_display displayCtrl 4120; private _row=if (isNull _list) then {-1} else {lbCurSel _list};
    if (_row>=0) then {private _raw=_list lbData _row; if (_raw isNotEqualTo "") then {_payload=parseSimpleArray _raw;};};
};
private _valid=(count _payload) isEqualTo 5;
private _minus=_display displayCtrl 4130; private _qty=_display displayCtrl 4131; private _plus=_display displayCtrl 4132; private _del=_display displayCtrl 4133;
{if (!isNull _x) then {_x ctrlEnable _valid;};} forEach [_minus,_qty,_plus,_del];
if (!_valid) exitWith {_state set ["selectedEquipmentPayload",[]]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state]; false};
_payload params ["_type","_className","_quantity","_mode","_states"];
{if (!isNull _x) then {_x setVariable ["SPORG_Items_equipmentPayload",+_payload]; _x setVariable ["SPORG_Items_equipmentView",_view];};} forEach [_minus,_qty,_plus,_del];
if (!isNull _qty && {(ctrlText _qty) isNotEqualTo str _quantity}) then {_qty ctrlSetText str _quantity;};
_state set ["selectedEquipmentPayload",+_payload]; _state set ["selectedEquipmentView",_view];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state];
true
