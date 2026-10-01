#include "..\..\script_version.hpp"
disableSerialization;
params [["_control",controlNull,[controlNull]]];
if (isNull _control) exitWith {false};
private _state = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
// ctClear/refresh pode destruir o Edit focado e disparar KillFocus. Esse evento interno
// nunca deve virar uma edição real nem iniciar um refresh recursivo.
if (_state getOrDefault ["refreshing",false]) exitWith {true};
private _key=_control getVariable ["SPORG_Items_rowKey",[]];
private _oldQty=-1;
if ((count _key) isEqualTo 3) then {
    _key params ["_type","_className","_mode"];
    private _ds=([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap];
    private _draft=_ds getOrDefault ["current",createHashMap];
    private _idx=(_draft getOrDefault ["entries",[]]) findIf {(_x#1) isEqualTo _type && {(_x#2) isEqualTo _className} && {(_x#4) isEqualTo _mode}};
    if (_idx>=0) then {_oldQty=((_draft getOrDefault ["entries",[]])#_idx)#3;};
};
private _result = ["QUANTITY",_control] call ServoPeregrino_Organizador_Items_fnc_handleDraftRowAction;
private _movement="";
if (_result getOrDefault ["success",false]) then {
    private _code=toUpper (_result getOrDefault ["code",""]);
    if (_code isEqualTo "ITEMS_DRAFT_ENTRY_REMOVED") then {_movement="REMOVE";} else {
        if (_code isEqualTo "ITEMS_DRAFT_QUANTITY_CHANGED") then {
            private _data=_result getOrDefault ["data",createHashMap];
            private _entry=_data getOrDefault ["entry",[]];
            private _newQty=if ((count _entry)>3) then {_entry#3} else {-1};
            if (_oldQty>=0 && {_newQty>=0}) then {_movement=if (_newQty>_oldQty) then {"ADD"} else {"REMOVE"};};
        };
    };
};
[_result,_movement,true] call ServoPeregrino_Organizador_Items_fnc_presentLogicalMutationResult;
["QUANTITY_COMMIT"] call ServoPeregrino_Organizador_Items_fnc_refreshDraftMutationUI;
true
