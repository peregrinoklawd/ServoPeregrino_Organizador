#include "..\..\script_version.hpp"
params [
    ["_action","",[""]],
    ["_source",controlNull,[controlNull,[]]],
    ["_explicitValue",nil]
];
private _key = if (_source isEqualType controlNull) then {_source getVariable ["SPORG_Items_rowKey",[]]} else {+_source};
if ((count _key) isNotEqualTo 3) exitWith {[false,"ITEMS_UI_DRAFT_ROW_KEY_INVALID","A ação não possui uma chave de linha válida.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
_key params ["_type","_className","_mode"];
private _result = createHashMap;
switch (toUpper _action) do {
    case "PLUS": {_result = [_type,_className,_mode] call ServoPeregrino_Organizador_Items_fnc_incrementDraftEntry;};
    case "MINUS": {_result = [_type,_className,_mode] call ServoPeregrino_Organizador_Items_fnc_decrementDraftEntry;};
    case "DELETE": {_result = [_type,_className,_mode] call ServoPeregrino_Organizador_Items_fnc_removeDraftEntry;};
    case "QUANTITY": {
        private _raw = if (isNil "_explicitValue") then {if (_source isEqualType controlNull) then {ctrlText _source} else {""}} else {str _explicitValue};
        private _chars = toArray _raw;
        if (_raw isEqualTo "" || {(_chars findIf {!(_x in [48,49,50,51,52,53,54,55,56,57])}) >= 0}) then {
            _result = [false,"ITEMS_UI_QUANTITY_TEXT_INVALID","Quantidade deve conter apenas dígitos inteiros não negativos.",createHashMapFromArray [["value",_raw]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult;
        } else {
            _result = [_type,_className,_mode,parseNumber _raw] call ServoPeregrino_Organizador_Items_fnc_setDraftEntryQuantity;
        };
    };
    default {_result = [false,"ITEMS_UI_DRAFT_ROW_ACTION_UNKNOWN","Ação de linha desconhecida.",createHashMapFromArray [["action",_action]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult;};
};
_result
