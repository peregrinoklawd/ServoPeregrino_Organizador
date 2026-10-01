#include "..\..\script_version.hpp"
params [
    ["_payload",[],[[]]],
    ["_action","",[""]],
    ["_explicitValue",-1,[0]],
    ["_view","",[""]],
    ["_origin","EQUIPMENT_ROW",[""]]
];
if ((count _payload) isNotEqualTo 5) exitWith {[false,"ITEMS_UI_EQUIPMENT_ROW_PAYLOAD_INVALID","Não foi possível identificar o item selecionado.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
_payload params ["_type","_className","_quantity","_mode","_states"];
private _entryR=[_type,_className,_quantity,_mode,_states] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
if !(_entryR getOrDefault ["success",false]) exitWith {_entryR};
private _entry=((_entryR getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]]);
private _actionU=toUpper _action;
private _cmdR=createHashMap;

// Mesma semântica do Draft: + sobre EXACT não inventa um novo stateData parcial;
// adiciona um DEFAULT_FULL separado, que reaparecerá como sua própria linha após a recaptura.
if (_actionU isEqualTo "PLUS" && {_mode isEqualTo "EXACT"}) then {
    private _fullR=["MAGAZINE",_className,1,"DEFAULT_FULL",[]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
    if (_fullR getOrDefault ["success",false]) then {
        _cmdR=[true,"ITEMS_UI_PHYSICAL_ROW_COMMAND_READY","Um novo carregador cheio foi adicionado sem alterar os carregadores parcialmente usados.",createHashMapFromArray [["operation","ADD"],["entry",((_fullR getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]])],["sourceQuantity",_quantity],["requestedQuantity",_quantity+1],["delta",1]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult;
    } else {_cmdR=_fullR;};
} else {
    _cmdR=[_actionU,_entry,_explicitValue] call ServoPeregrino_Organizador_Items_fnc_createUIPhysicalRowCommand;
};
if !(_cmdR getOrDefault ["success",false]) exitWith {[_cmdR,true] call ServoPeregrino_Organizador_Items_fnc_presentUIResult; _cmdR};
private _cd=_cmdR getOrDefault ["data",createHashMap];
private _operation=_cd getOrDefault ["operation",""];
if (_operation isEqualTo "NOOP") exitWith {[_cmdR,false] call ServoPeregrino_Organizador_Items_fnc_presentUIResult; [] call ServoPeregrino_Organizador_Items_fnc_refreshEquipmentSelectionControls; _cmdR};
private _target=toUpper _view;
if !(_target in ["U","C","M"]) exitWith {[false,"ITEMS_UI_EQUIPMENT_VIEW_INVALID","Escolha Uniforme, Colete ou Mochila antes de alterar este item.",createHashMapFromArray [["view",_view]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _r=["ENTRY",_cd getOrDefault ["entry",[]],"PHYSICAL",_operation,player,_target,createHashMapFromArray [["commandOrigin",_origin]]] call ServoPeregrino_Organizador_Items_fnc_executeUITransferCommand;
[_r,true] call ServoPeregrino_Organizador_Items_fnc_presentUIResult;
if (_r getOrDefault ["success",false]) then {[_r] call ServoPeregrino_Organizador_Items_fnc_refreshPhysicalMutationUI;} else {[createHashMapFromArray [["reason","EQUIPMENT_ROW_FAILURE"]]] call ServoPeregrino_Organizador_Items_fnc_refreshPhysicalTargetUI; [] call ServoPeregrino_Organizador_Items_fnc_refreshEquipmentSelectionControls;};
_r
