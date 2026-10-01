#include "..\..\script_version.hpp"
params [
    ["_unit", objNull, [objNull]],
    ["_equipmentView", "U", [""]],
    ["_options", createHashMap, [createHashMap]]
];
private _view = toUpper _equipmentView;
if !(_view in ["U","C","M"]) exitWith {
    [false,"ITEMS_UI_EQUIPMENT_CLEAR_VIEW_INVALID","Escolha Uniforme, Colete ou Mochila antes de limpar o conteúdo.",createHashMapFromArray [["equipmentView",_equipmentView]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _opts = [_options] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
_opts set ["commandOrigin", _opts getOrDefault ["commandOrigin","BUTTON_EQUIPMENT_CLEAR"]];
["DRAFT",[],"PHYSICAL","CLEAR",_unit,_view,_opts] call ServoPeregrino_Organizador_Items_fnc_executeUITransferCommand
