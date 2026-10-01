#include "..\..\script_version.hpp"
disableSerialization;
params ["_display","_key","_shift","_ctrlKey","_alt"];
if (_key isEqualTo 1) exitWith {
    private _uiState = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
    private _drag = _uiState getOrDefault ["dragState",createHashMap];
    if (_drag getOrDefault ["active",false]) exitWith {["ESC"] call ServoPeregrino_Organizador_Items_fnc_cancelUIDrag; true};
    private _draftR = [] call ServoPeregrino_Organizador_Items_fnc_getDraftState;
    private _dd = _draftR getOrDefault ["data",createHashMap];
    private _dirty = (_dd getOrDefault ["hasDraft",false]) && {((_dd getOrDefault ["current",createHashMap]) getOrDefault ["dirty",false])};
    if (_dirty) then {["REQUEST_CLOSE"] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent; true} else {false}
};
if !(_key isEqualTo 211) exitWith {false};
private _focused = focusedCtrl _display;
if (!isNull _focused && {(ctrlType _focused) isEqualTo 2}) exitWith {false}; // DELETE continua normal dentro de Edit.
if (!isNull _focused && {(ctrlIDC _focused) isEqualTo 1102}) exitWith {["DELETE_KIT_REQUEST"] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent; true};

// Em Equipment, DELETE converge para o mesmo request central dos botões físicos e remove a linha imediatamente.
if (!isNull _focused && {(ctrlIDC _focused) in [4120,4130,4131,4132,4133]}) exitWith {
    ["DELETE",_focused,-1] call ServoPeregrino_Organizador_Items_fnc_requestEquipmentRowAction;
    true
};
// 0.12-C: qualquer controle de uma linha Equipment carrega o payload congelado da própria linha.
private _focusedEquipmentPayload = if (isNull _focused) then {[]} else {+(_focused getVariable ["SPORG_Items_equipmentPayload",[]])};
if ((count _focusedEquipmentPayload) isEqualTo 5) exitWith {
    ["DELETE",_focused,-1] call ServoPeregrino_Organizador_Items_fnc_requestEquipmentRowAction;
    true
};

private _rowKey = if (isNull _focused) then {[]} else {_focused getVariable ["SPORG_Items_rowKey",[]]};
if ((count _rowKey) isNotEqualTo 3) then {
    private _table = _display displayCtrl SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAFT_TABLE_IDC;
    if (!isNull _table) then {
        private _sel = ctCurSel _table;
        if (_sel >= 0) then {private _controls = _table ctRowControls _sel; if ((count _controls)>0) then {_rowKey = (_controls#0) getVariable ["SPORG_Items_rowKey",[]];};};
    };
};
if ((count _rowKey) isEqualTo 3) exitWith {
    private _r = ["DELETE",_rowKey] call ServoPeregrino_Organizador_Items_fnc_handleDraftRowAction;
    [_r,"REMOVE",true] call ServoPeregrino_Organizador_Items_fnc_presentLogicalMutationResult;
    ["KEY_DELETE_DRAFT"] call ServoPeregrino_Organizador_Items_fnc_refreshDraftMutationUI;
    true
};
false
