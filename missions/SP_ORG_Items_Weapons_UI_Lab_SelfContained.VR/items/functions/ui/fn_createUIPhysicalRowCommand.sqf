#include "..\..\script_version.hpp"
params [
    ["_action", "", [""]],
    ["_entry", [], [[]]],
    ["_explicitValue", -1, [0]]
];
if ((count _entry) isNotEqualTo 6) exitWith {[false,"ITEMS_UI_PHYSICAL_ROW_ENTRY_INVALID","Não foi possível identificar esta linha do equipamento.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
_entry params ["_version","_type","_className","_quantity","_stateMode","_stateData"];
if (_quantity <= 0) exitWith {[false,"ITEMS_UI_PHYSICAL_ROW_QUANTITY_INVALID","Este item não possui quantidade disponível para remover.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _actionU = toUpper _action;
private _operation = "";
private _delta = 0;
switch _actionU do {
    case "DELETE": {_operation = "REMOVE"; _delta = _quantity;};
    case "MINUS": {_operation = "REMOVE"; _delta = 1 min _quantity;};
    case "PLUS": {_operation = "ADD"; _delta = 1;};
    case "QUANTITY": {
        if (_explicitValue < 0 || {round _explicitValue isNotEqualTo _explicitValue}) exitWith {};
        if (_explicitValue < _quantity) then {_operation = "REMOVE"; _delta = _quantity - _explicitValue;};
        if (_explicitValue isEqualTo _quantity) then {_operation = "NOOP"; _delta = 0;};
        if (_explicitValue > _quantity) then {_operation = "ADD"; _delta = _explicitValue - _quantity;};
    };
    default {};
};
if (_operation isEqualTo "") exitWith {[false,"ITEMS_UI_PHYSICAL_ROW_ACTION_INVALID","A quantidade informada não pode ser aplicada a este item.",createHashMapFromArray [["action",_action],["value",_explicitValue]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
if (_operation isEqualTo "NOOP") exitWith {[true,"ITEMS_UI_PHYSICAL_ROW_NOOP","A quantidade já está no valor solicitado.",createHashMapFromArray [["operation","NOOP"],["entry",[_entry] call ServoPeregrino_Organizador_Items_fnc_deepCopy]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
if (_operation isEqualTo "ADD" && {_stateMode isEqualTo "EXACT"}) exitWith {[false,"ITEMS_UI_PHYSICAL_EXACT_ADD_REQUIRES_STATE","Carregadores parcialmente usados não podem ter a quantidade aumentada diretamente.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _states = [];
if (_stateMode isEqualTo "EXACT") then {
    if ((count _stateData) < _delta) exitWith {};
    _states = +(_stateData select [0,_delta]);
};
if (_stateMode isEqualTo "EXACT" && {(count _states) isNotEqualTo _delta}) exitWith {[false,"ITEMS_UI_PHYSICAL_EXACT_STATE_INVALID","Não foi possível localizar carregadores suficientes para concluir a remoção.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _entryR = [_type,_className,_delta,_stateMode,_states] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
if !(_entryR getOrDefault ["success",false]) exitWith {_entryR};
private _deltaEntry = ((_entryR getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]]);
[true,"ITEMS_UI_PHYSICAL_ROW_COMMAND_READY","Ação de linha foi normalizada para um único comando físico.",createHashMapFromArray [
    ["operation",_operation],["entry",_deltaEntry],["sourceType","ENTRY"],["sourceQuantity",_quantity],["requestedQuantity",_explicitValue],["delta",_delta]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
