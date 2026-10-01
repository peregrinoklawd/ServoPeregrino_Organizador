#include "..\..\script_version.hpp"
params [["_result",createHashMap,[createHashMap]]];

private _ok=_result getOrDefault ["success",false];
private _code=toUpper (_result getOrDefault ["code","UNKNOWN"]);
private _msg=_result getOrDefault ["message",_code];
private _data=_result getOrDefault ["data",createHashMap];
private _cmd=_data getOrDefault ["uiCommand",createHashMap];
private _apply=_data getOrDefault ["applyResult",createHashMap];
private _status=toUpper (_apply getOrDefault ["status",_data getOrDefault ["status",if (_ok) then {"COMPLETE"} else {"FAILED"}]]);
private _rolledBack=(_data getOrDefault ["rolledBack",false]) || {_status isEqualTo "ROLLED_BACK"} || {_code isEqualTo "ITEMS_ROLLED_BACK"};
private _rollbackSucceeded=_data getOrDefault ["rollbackSucceeded",_rolledBack];
private _rollbackFailed=(_status isEqualTo "ROLLBACK_FAILED") || {_code isEqualTo "ITEMS_ROLLBACK_FAILED"} || {_rolledBack && {!_rollbackSucceeded}};
private _partial=_ok && {(_status isEqualTo "PARTIAL") || {_code isEqualTo "ITEMS_APPLICATION_PARTIAL"}};
private _blockedCodes=[
    "ITEMS_UI_PHYSICAL_NOT_READY","ITEMS_UI_PHYSICAL_UNIT_NULL","ITEMS_UI_PHYSICAL_SOURCE_UNKNOWN",
    "ITEMS_UI_CATALOG_ITEM_NOT_PHYSICAL","ITEMS_UI_CATALOG_PHYSICAL_OPERATION_UNSUPPORTED",
    "ITEMS_UI_KIT_PHYSICAL_OPERATION_UNSUPPORTED","ITEMS_UI_ENTRY_PHYSICAL_OPERATION_UNSUPPORTED",
    "ITEMS_UI_PHYSICAL_OPERATION_INVALID","ITEMS_UI_COMMAND_DESTINATION_INVALID"
];
private _blocked=!_ok && {_code in _blockedCodes};

private _outcome="FAILURE";
private _severity="ERROR";
private _soundKey="FAILURE";
if (_rollbackFailed) then {_outcome="ROLLBACK_FAILED"; _severity="ERROR"; _soundKey="FAILURE";} else {
    if (_rolledBack) then {_outcome="ROLLBACK"; _severity="WARN"; _soundKey="ROLLBACK";} else {
        if (_blocked) then {_outcome="BLOCKED"; _severity="WARN"; _soundKey="BLOCKED";} else {
            if (_partial) then {_outcome="PARTIAL"; _severity="WARN"; _soundKey="PARTIAL";} else {
                if (_ok) then {_outcome="SUCCESS"; _severity="SUCCESS"; _soundKey="SUCCESS";};
            };
        };
    };
};

private _appliedQty=0;
{_appliedQty=_appliedQty+(_x param [3,0,[0]]);} forEach (_apply getOrDefault ["appliedEntries",[]]);
private _rejected=count (_apply getOrDefault ["rejectedEntries",[]]);
private _actions=count (_apply getOrDefault ["actionResults",[]]);
private _operation=toUpper (_cmd getOrDefault ["operation",_data getOrDefault ["operation","OP"]]);
private _target=_cmd getOrDefault ["target",_data getOrDefault ["target","-"]];
private _targetLabel=[_target] call ServoPeregrino_Organizador_Items_fnc_getUITargetLabel;
private _commandId=_cmd getOrDefault ["commandId","-"];
private _qtyText=if (_appliedQty isEqualTo 1) then {"1 item"} else {format ["%1 itens",_appliedQty]};

private _movementKey="";
if (_ok && {!_partial} && {!_rolledBack}) then {
    _movementKey=switch _operation do {
        case "ADD":{"ADD"}; case "LOGICAL_COPY":{"ADD"}; case "REMOVE":{"REMOVE"}; case "CLEAR":{"CLEAR"}; case "REPLACE":{"REPLACE"}; default {""};
    };
};

private _friendlyBlocked=switch _code do {
    case "ITEMS_UI_PHYSICAL_NOT_READY": {"Não é possível alterar esse equipamento agora. Escolha um destino disponível e tente novamente."};
    case "ITEMS_UI_PHYSICAL_UNIT_NULL": {"Não foi possível localizar o jogador para concluir a operação."};
    case "ITEMS_UI_PHYSICAL_SOURCE_UNKNOWN": {"Esse item não pode ser usado nesta operação."};
    case "ITEMS_UI_CATALOG_ITEM_NOT_PHYSICAL": {"Esse item do catálogo não pode ser adicionado diretamente ao equipamento."};
    case "ITEMS_UI_CATALOG_PHYSICAL_OPERATION_UNSUPPORTED": {"Essa ação não está disponível para este item do catálogo."};
    case "ITEMS_UI_KIT_PHYSICAL_OPERATION_UNSUPPORTED": {"Essa ação não está disponível para o kit selecionado."};
    case "ITEMS_UI_ENTRY_PHYSICAL_OPERATION_UNSUPPORTED": {"Essa ação não está disponível para este item do kit."};
    case "ITEMS_UI_PHYSICAL_OPERATION_INVALID": {"Essa operação não é válida para o equipamento."};
    case "ITEMS_UI_COMMAND_DESTINATION_INVALID": {"Solte o item em uma área válida do Organizador."};
    default {"Não foi possível concluir a operação agora."};
};

private _summary="";
if ((count _cmd)>0) then {
    _summary=switch _outcome do {
        case "SUCCESS": {
            switch _operation do {
                case "ADD": {format ["%1 adicionados a %2.",_qtyText,_targetLabel]};
                case "REMOVE": {format ["%1 removidos de %2.",_qtyText,_targetLabel]};
                case "REPLACE": {format ["O conteúdo de %1 foi substituído pelo Kit Selecionado.",_targetLabel]};
                case "CLEAR": {format ["Os itens gerenciáveis de %1 foram removidos.",_targetLabel]};
                case "LOGICAL_COPY": {"Item adicionado ao Kit Selecionado."};
                default {"Operação concluída."};
            }
        };
        case "PARTIAL": {format ["A operação foi concluída parcialmente em %1: %2 aplicados e %3 não puderam ser processados.",_targetLabel,_appliedQty,_rejected]};
        case "BLOCKED": {_friendlyBlocked};
        case "ROLLBACK": {format ["A operação em %1 encontrou um problema e foi desfeita com segurança.",_targetLabel]};
        case "ROLLBACK_FAILED": {format ["Falha crítica ao restaurar %1. Evite novas alterações e consulte o RPT.",_targetLabel]};
        default {format ["Não foi possível concluir a operação em %1. %2",_targetLabel,_msg]};
    };
} else {
    _summary=switch _outcome do {
        case "SUCCESS": {_msg};
        case "PARTIAL": {"A operação foi concluída apenas parcialmente."};
        case "BLOCKED": {_friendlyBlocked};
        case "ROLLBACK": {"A operação encontrou um problema e foi desfeita com segurança."};
        case "ROLLBACK_FAILED": {"Falha crítica ao restaurar o estado anterior. Consulte o RPT antes de continuar."};
        default {_msg};
    };
};

createHashMapFromArray [
    ["outcome",_outcome],["severity",_severity],["soundKey",_soundKey],["message",_summary],
    ["code",_code],["status",_status],["operation",_operation],["target",_target],["commandId",_commandId],
    ["appliedQty",_appliedQty],["rejectedCount",_rejected],["actionCount",_actions],
    ["rolledBack",_rolledBack],["rollbackSucceeded",_rollbackSucceeded],["movementKey",_movementKey]
]
