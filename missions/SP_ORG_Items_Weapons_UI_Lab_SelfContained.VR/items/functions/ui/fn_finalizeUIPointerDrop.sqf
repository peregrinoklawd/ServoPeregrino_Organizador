#include "..\..\script_version.hpp"
disableSerialization;
params [
    ["_drag",createHashMap,[createHashMap]],
    ["_pointerX",-1000,[0]],
    ["_pointerY",-1000,[0]],
    ["_display",displayNull,[displayNull]],
    ["_useCurrentMouse",true,[true]],
    ["_originOverride","",[""]]
];
if (isNull _display) then {_display=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR,displayNull];};
private _source=_drag getOrDefault ["sourceType",""];
if !(_drag getOrDefault ["active",false]) exitWith {createHashMapFromArray [["success",false],["accepted",false],["code","ITEMS_UI_DND_NOT_ACTIVE"],["destination",""],["area","OUTSIDE"]]};

private _target=[_pointerX,_pointerY,_source,_display,_useCurrentMouse] call ServoPeregrino_Organizador_Items_fnc_resolveUIPanelDropTarget;
private _destination=_target getOrDefault ["destination",""];
private _area=_target getOrDefault ["area","OUTSIDE"];
if (_destination isEqualTo "") exitWith {
    diag_log format ["[SP_ORG] [ITEMS] [DND] DROP source=%1 destination=NONE accepted=false reason=%2 area=%3 coord=%4",_source,_target getOrDefault ["reason","OUTSIDE"],_area,_target getOrDefault ["coordinateSource","UNKNOWN"]];
    [format ["PANEL_RELEASE_%1",_target getOrDefault ["reason","OUTSIDE"]]] call ServoPeregrino_Organizador_Items_fnc_cancelUIDrag;
    createHashMapFromArray [["success",false],["accepted",false],["code",_target getOrDefault ["reason","OUTSIDE"]],["destination",""],["area",_area],["target",_target]]
};

private _origin=if (_originOverride isNotEqualTo "") then {_originOverride} else {
    switch _source do {
        case "EQUIPMENT":{"DND_EQUIPMENT_TABLE"};
        case "CATALOG":{if (_destination isEqualTo "PHYSICAL") then {"DND_CATALOG_TABLE_PHYSICAL"} else {"DND_CATALOG_TABLE_DRAFT"}};
        case "KIT":{if (_destination isEqualTo "PHYSICAL") then {"DND_KIT_PANEL_PHYSICAL"} else {"DND_KIT_PANEL_DRAFT"}};
        case "ENTRY":{"DND_DRAFT_ROW_PHYSICAL"};
        default {"DND_POINTER"};
    }
};
private _stateNow=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
// D.6.2: dropping inside Conteúdo do Equipamento is governed by what the player is viewing (Mostrar),
// not by the independent Kit application target.
private _requestedTarget=if (_destination isEqualTo "PHYSICAL") then {_stateNow getOrDefault ["equipmentView","U"]} else {""};
private _result=[_source,_drag getOrDefault ["sourcePayload",[]],_destination,"AUTO",player,_requestedTarget,createHashMapFromArray [["commandOrigin",_origin],["autoCreateDraftIfMissing",_destination isEqualTo "DRAFT"]]] call ServoPeregrino_Organizador_Items_fnc_executeUITransferCommand;
private _ok=_result getOrDefault ["success",false];
diag_log format ["[SP_ORG] [ITEMS] [DND] DROP source=%1 destination=%2 accepted=%3 code=%4 origin=%5 area=%6 coord=%7",_source,_destination,_ok,_result getOrDefault ["code","UNKNOWN"],_origin,_area,_target getOrDefault ["coordinateSource","UNKNOWN"]];
["DROP_COMPLETE"] call ServoPeregrino_Organizador_Items_fnc_cancelUIDrag;
[_result,true] call ServoPeregrino_Organizador_Items_fnc_presentUIResult;
if (_ok) then {
    if (_destination isEqualTo "PHYSICAL") then {[_result] call ServoPeregrino_Organizador_Items_fnc_refreshPhysicalMutationUI;} else {["DND_TO_DRAFT"] call ServoPeregrino_Organizador_Items_fnc_refreshDraftMutationUI;};
};
createHashMapFromArray [["success",_ok],["accepted",_ok],["code",_result getOrDefault ["code","UNKNOWN"]],["destination",_destination],["area",_area],["origin",_origin],["result",_result],["target",_target]]
