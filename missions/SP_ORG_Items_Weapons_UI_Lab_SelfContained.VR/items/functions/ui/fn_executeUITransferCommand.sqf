#include "..\..\script_version.hpp"
params [
    ["_sourceType", "", [""]],
    ["_payload", []],
    ["_destination", "DRAFT", [""]],
    ["_operation", "AUTO", [""]],
    ["_unit", objNull, [objNull]],
    ["_requestedTarget", "", [""]],
    ["_options", createHashMap, [createHashMap]]
];
private _startedAt = diag_tickTime;
private _commandSequence = (missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_COMMAND_COUNTER_VAR,0]) + 1;
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_COMMAND_COUNTER_VAR,_commandSequence];
private _commandId = format ["sporg-ui-%1-%2", round (_startedAt * 1000), _commandSequence];
private _source = toUpper _sourceType;
private _dest = toUpper _destination;
private _op = toUpper _operation;
if (_op isEqualTo "AUTO" && {_dest isEqualTo "PHYSICAL"}) then {_op = "ADD";};
private _origin = _options getOrDefault ["commandOrigin","DIRECT"];
private _sourceSnapshot = createHashMap;
private _resolvedTargetForMeta = "";
private _requestedTargetForMeta = _requestedTarget;
private _containerClassForMeta = "";
private _sourceIdentity = "";
private _sourceEntryCount = 0;

private _decorate = {
    params ["_r"];
    if !(_r isEqualType createHashMap) then {
        _r = [false,"ITEMS_UI_COMMAND_RESULT_INVALID","Dispatcher UI não recebeu Result HashMap válido.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult;
    };
    private _d = _r getOrDefault ["data",createHashMap];
    private _uiCommand = _d getOrDefault ["uiCommand",createHashMap];
    _uiCommand set ["sourceType",_source];
    _uiCommand set ["destination",_dest];
    _uiCommand set ["operation",if (_dest isEqualTo "DRAFT") then {"LOGICAL_COPY"} else {_op}];
    _uiCommand set ["target",_resolvedTargetForMeta];
    _uiCommand set ["requestedTarget",_requestedTargetForMeta];
    _uiCommand set ["mutatesInventory",_dest isEqualTo "PHYSICAL"];
    _uiCommand set ["singleDispatch",true];
    _uiCommand set ["commandOrigin",_origin];
    _uiCommand set ["commandId",_commandId];
    _d set ["uiCommand",_uiCommand];
    private _trace = createHashMapFromArray [
        ["commandId",_commandId],["startedAtTick",_startedAt],["completedAtTick",diag_tickTime],
        ["durationMs",round ((diag_tickTime-_startedAt)*1000)],["sourceIdentity",_sourceIdentity],
        ["sourceEntryCount",_sourceEntryCount],["containerClass",_containerClassForMeta]
    ];
    _d set ["physicalTrace",_trace];
    _r set ["data",_d];
    _r
};

if (_dest isEqualTo "DRAFT") exitWith {
    private _r = [_source,_payload,_options] call ServoPeregrino_Organizador_Items_fnc_handleUITransferToDraft;
    [_r] call _decorate
};
if !(_dest isEqualTo "PHYSICAL") exitWith {
    [[false,"ITEMS_UI_COMMAND_DESTINATION_INVALID","Este item não pode ser solto neste local.",createHashMapFromArray [["destination",_destination]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult] call _decorate
};
if !(_op in ["ADD","REMOVE","REPLACE","CLEAR"]) exitWith {
    [[false,"ITEMS_UI_PHYSICAL_OPERATION_INVALID","Esta ação não está disponível para o equipamento.",createHashMapFromArray [["operation",_operation]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult] call _decorate
};
if (isNull _unit) exitWith {
    [[false,"ITEMS_UI_PHYSICAL_UNIT_NULL","Não foi possível identificar o jogador para concluir a ação.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult] call _decorate
};

private _preferred = "ANY";
private _sourcePrecheck = createHashMap;
if (_source isEqualTo "KIT") then {
    _sourcePrecheck = [_payload] call ServoPeregrino_Organizador_Items_fnc_getSavedKitApplicationSource;
    if (_sourcePrecheck getOrDefault ["success",false]) then {
        _sourceSnapshot = ((_sourcePrecheck getOrDefault ["data",createHashMap]) getOrDefault ["source",createHashMap]);
        _preferred = _sourceSnapshot getOrDefault ["preferredTarget","ANY"];
    };
};
if (_source isEqualTo "DRAFT" && {!(_op isEqualTo "CLEAR")}) then {
    _sourcePrecheck = [] call ServoPeregrino_Organizador_Items_fnc_getDraftApplicationSource;
    if (_sourcePrecheck getOrDefault ["success",false]) then {
        _sourceSnapshot = ((_sourcePrecheck getOrDefault ["data",createHashMap]) getOrDefault ["source",createHashMap]);
        _preferred = _sourceSnapshot getOrDefault ["preferredTarget","ANY"];
    };
};
if ((count _sourceSnapshot)>0) then {
    _sourceIdentity = _sourceSnapshot getOrDefault ["identity",_sourceSnapshot getOrDefault ["name",""]];
    _sourceEntryCount = count (_sourceSnapshot getOrDefault ["entries",[]]);
} else {
    _sourceIdentity = if (_source isEqualTo "CATALOG") then {if (_payload isEqualType "") then {_payload} else {str _payload}} else {if (_source isEqualTo "ENTRY") then {if (_payload isEqualType [] && {(count _payload)>2}) then {_payload#2} else {"ENTRY"}} else {""}};
    _sourceEntryCount = if (_source in ["CATALOG","ENTRY"]) then {1} else {0};
};
if ((count _sourcePrecheck) > 0 && {!(_sourcePrecheck getOrDefault ["success",false])}) exitWith {
    private _r = [_sourcePrecheck] call _decorate;
    diag_log format ["[SP_ORG] [ITEMS] [PHYSICAL_FLOW] POST id=%1 origin=%2 source=%3 op=%4 requested=%5 resolved=- success=false code=%6 reason=SOURCE_PRECHECK durationMs=%7",_commandId,_origin,_source,_op,_requestedTarget,_r getOrDefault ["code","UNKNOWN"],round ((diag_tickTime-_startedAt)*1000)];
    _r
};

private _readyR = [_unit,_requestedTarget,_preferred,_options] call ServoPeregrino_Organizador_Items_fnc_getUIPhysicalReadiness;
private _ready = _readyR getOrDefault ["data",createHashMap];
_resolvedTargetForMeta = _ready getOrDefault ["resolvedTarget",""];
_requestedTargetForMeta = _ready getOrDefault ["requestedTarget",_requestedTarget];
_containerClassForMeta = _ready getOrDefault ["containerClass",""];
if !(_ready getOrDefault ["physicalMutationEnabled",false]) exitWith {
    private _r = [[false,"ITEMS_UI_PHYSICAL_NOT_READY",_readyR getOrDefault ["message","O equipamento escolhido não está disponível para receber itens agora."],createHashMapFromArray [["readiness",_ready]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult] call _decorate;
    diag_log format ["[SP_ORG] [ITEMS] [PHYSICAL_FLOW] POST id=%1 origin=%2 source=%3 op=%4 requested=%5 resolved=%6 success=false code=%7 reason=NOT_READY durationMs=%8",_commandId,_origin,_source,_op,_requestedTargetForMeta,_resolvedTargetForMeta,_r getOrDefault ["code","UNKNOWN"],round ((diag_tickTime-_startedAt)*1000)];
    _r
};

private _target = _resolvedTargetForMeta;
private _container = _ready getOrDefault ["container",objNull];
private _containerClass = _containerClassForMeta;
private _ctx = createHashMapFromArray [["containerClass",_containerClass],["gearClass",_containerClass],["sourceProvider","UI_PHYSICAL"]];
if (_ready getOrDefault ["testFixture",false]) then {
    _ctx set ["maxLoadOverride",100000];
    _ctx set ["currentLoadOverride",0];
};
private _execOptions = [_options] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
_execOptions set ["lockOwner",_execOptions getOrDefault ["lockOwner","UI_PHYSICAL"]];
_execOptions set ["uiCommandId",_commandId];

diag_log format ["[SP_ORG] [ITEMS] [PHYSICAL_FLOW] PRE id=%1 origin=%2 source=%3 sourceId=%4 sourceEntries=%5 op=%6 requested=%7 resolved=%8 view=%9 containerClass=%10",_commandId,_origin,_source,_sourceIdentity,_sourceEntryCount,_op,_requestedTargetForMeta,_target,(missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]) getOrDefault ["equipmentView","-"],_containerClass];

private _result = createHashMap;
switch _source do {
    case "CATALOG": {
        if !(_op isEqualTo "ADD") exitWith {_result = [false,"ITEMS_UI_CATALOG_PHYSICAL_OPERATION_UNSUPPORTED","Itens do catálogo só podem ser adicionados ao equipamento.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult;};
        private _resolved = [_payload] call ServoPeregrino_Organizador_Items_fnc_resolveCatalogItem;
        if !(_resolved getOrDefault ["success",false]) exitWith {_result = _resolved;};
        private _item = ((_resolved getOrDefault ["data",createHashMap]) getOrDefault ["item",createHashMap]);
        if !((_item getOrDefault ["available",false]) && {_item getOrDefault ["eligible",false]}) exitWith {_result = [false,"ITEMS_UI_CATALOG_ITEM_NOT_PHYSICAL","Este item não está disponível para ser adicionado ao equipamento.",createHashMapFromArray [["item",_item]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult;};
        private _entryR = if ((_item getOrDefault ["contentType",""]) isEqualTo "MAGAZINE") then {["MAGAZINE",_payload,1,"DEFAULT_FULL",[]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry} else {["ITEM",_payload,1,"NONE",[]] call ServoPeregrino_Organizador_Items_fnc_createItemEntry};
        if !(_entryR getOrDefault ["success",false]) exitWith {_result = _entryR;};
        private _entry = ((_entryR getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]]);
        _result = [_container,_target,"ADD",[_entry],"BEST_EFFORT",_ctx,_execOptions] call ServoPeregrino_Organizador_Items_fnc_executeContentOperation;
    };
    case "KIT": {
        if !(_op in ["ADD","REMOVE","REPLACE"]) exitWith {_result = [false,"ITEMS_UI_KIT_PHYSICAL_OPERATION_UNSUPPORTED","Esta ação não está disponível para o kit selecionado.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult;};
        _result = [_container,_target,_payload,_op,if (_op in ["ADD","REMOVE"]) then {"BEST_EFFORT"} else {"STRICT"},_ctx,_execOptions] call ServoPeregrino_Organizador_Items_fnc_executeSavedKitApplication;
    };
    case "DRAFT": {
        if (_op isEqualTo "CLEAR") then {
            _result = [_container,_target,"CLEAR",[],"STRICT",_ctx,_execOptions] call ServoPeregrino_Organizador_Items_fnc_executeContentOperation;
        } else {
            _result = [_container,_target,_op,if (_op in ["ADD","REMOVE"]) then {"BEST_EFFORT"} else {"STRICT"},_ctx,_execOptions] call ServoPeregrino_Organizador_Items_fnc_executeDraftApplication;
        };
    };
    case "ENTRY": {
        if !(_payload isEqualType [] && {(count _payload) isEqualTo 6}) exitWith {_result = [false,"ITEMS_UI_ENTRY_PHYSICAL_PAYLOAD_INVALID","Não foi possível identificar o item arrastado.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult;};
        if !(_op in ["ADD","REMOVE"]) exitWith {_result = [false,"ITEMS_UI_ENTRY_PHYSICAL_OPERATION_UNSUPPORTED","Este item só pode ser adicionado ou removido.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult;};
        _result = [_container,_target,_op,[_payload],"BEST_EFFORT",_ctx,_execOptions] call ServoPeregrino_Organizador_Items_fnc_executeContentOperation;
    };
    default {_result = [false,"ITEMS_UI_PHYSICAL_SOURCE_UNKNOWN","Esta origem não pode alterar o equipamento.",createHashMapFromArray [["sourceType",_source]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult;};
};
_result = [_result] call _decorate;
private _rd = _result getOrDefault ["data",createHashMap];
private _apply = _rd getOrDefault ["applyResult",createHashMap];
private _appliedQty = 0;
{_appliedQty = _appliedQty + (_x param [3,0,[0]]);} forEach (_apply getOrDefault ["appliedEntries",[]]);
private _rejected = count (_apply getOrDefault ["rejectedEntries",[]]);
private _actions = count (_apply getOrDefault ["actionResults",[]]);
private _status = _apply getOrDefault ["status",if (_result getOrDefault ["success",false]) then {"COMPLETE"} else {"FAILED"}];
diag_log format ["[SP_ORG] [ITEMS] [PHYSICAL_FLOW] POST id=%1 origin=%2 source=%3 op=%4 requested=%5 resolved=%6 success=%7 code=%8 status=%9 actions=%10 appliedQty=%11 rejected=%12 durationMs=%13",_commandId,_origin,_source,_op,_requestedTargetForMeta,_target,_result getOrDefault ["success",false],_result getOrDefault ["code","UNKNOWN"],_status,_actions,_appliedQty,_rejected,round ((diag_tickTime-_startedAt)*1000)];
_result
