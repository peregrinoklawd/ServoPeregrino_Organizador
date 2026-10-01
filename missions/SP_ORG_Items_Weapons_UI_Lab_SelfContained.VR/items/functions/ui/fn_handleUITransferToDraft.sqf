#include "..\..\script_version.hpp"
params [
    ["_sourceType","",[""]],
    ["_payload",nil],
    ["_options",createHashMap,[createHashMap]]
];

private _type=toUpper _sourceType;
private _origin=toUpper (_options getOrDefault ["commandOrigin","DIRECT"]);
private _autoCreateExplicit=_options getOrDefault ["autoCreateDraftIfMissing",false];
private _autoCreateLegacyDrop=_options getOrDefault ["autoCreateDraftOnDrop",false];
private _autoCreateByDnD=(_origin find "DND_") isEqualTo 0;
private _autoCreateRequested=_autoCreateExplicit || {_autoCreateLegacyDrop} || {_autoCreateByDnD};
private _autoCreateTrigger=if (_autoCreateByDnD) then {"DND"} else {if (_autoCreateExplicit) then {"EXPLICIT_ADD"} else {"LEGACY"}};
private _stateBefore=[missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMap]] call ServoPeregrino_Organizador_Items_fnc_deepCopy;
private _draftBefore=([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap];
private _hadDraft=_draftBefore getOrDefault ["hasDraft",false];
private _autoCreated=false;

// D.6.4: explicit add gestures (DnD or the visible ← controls) may materialize an
// empty Rascunho automatically. Neutral selection/click paths do not opt in.
if (!_hadDraft && {!_autoCreateRequested}) exitWith {
    [false,"ITEMS_UI_DRAFT_REQUIRED","Crie ou selecione um kit antes de adicionar itens.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _createFailure=createHashMap;
if (!_hadDraft && {_autoCreateRequested}) then {
    private _newR=["Novo Kit","ANY",[_autoCreateTrigger,"AUTO_CREATE"],[]] call ServoPeregrino_Organizador_Items_fnc_createNewDraft;
    if (_newR getOrDefault ["success",false]) then {
        _autoCreated=true;
        diag_log format ["[SP_ORG] [ITEMS] [DRAFT_AUTO_CREATE] origin=%1 source=%2 trigger=%3 created=true",_origin,_type,_autoCreateTrigger];
    } else {
        _createFailure=_newR;
    };
};
if ((count _createFailure)>0) exitWith {_createFailure};

// Guard after materialization. This is deliberately top-level so a failed create
// cannot fall through into the source-specific mutation path.
private _draftAfterMaterialize=([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap];
if !(_draftAfterMaterialize getOrDefault ["hasDraft",false]) exitWith {
    [false,"ITEMS_UI_DRAFT_REQUIRED","Não foi possível preparar um novo Rascunho para receber o item.",createHashMapFromArray [["origin",_origin],["sourceType",_type]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _result=switch _type do {
    case "CATALOG": {
        if !(_payload isEqualType "" && {_payload isNotEqualTo ""}) exitWith {[false,"ITEMS_UI_CATALOG_SOURCE_INVALID","Origem de catálogo inválida.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
        [_payload,1] call ServoPeregrino_Organizador_Items_fnc_addCatalogItemToDraft
    };
    case "EQUIPMENT": {
        if !(_payload isEqualType [] && {(count _payload) isEqualTo 5}) exitWith {[false,"ITEMS_UI_EQUIPMENT_SOURCE_INVALID","Não foi possível identificar o item do equipamento.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
        _payload params ["_entryType","_className","_quantity","_stateMode","_stateData"];
        private _entryR=[_entryType,_className,_quantity,_stateMode,_stateData] call ServoPeregrino_Organizador_Items_fnc_createItemEntry;
        if !(_entryR getOrDefault ["success",false]) exitWith {_entryR};
        [((_entryR getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]])] call ServoPeregrino_Organizador_Items_fnc_addEntryToDraft
    };
    case "KIT": {
        if !(_payload isEqualType "" && {_payload isNotEqualTo ""}) exitWith {[false,"ITEMS_UI_KIT_SOURCE_INVALID","Não foi possível identificar o kit selecionado.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
        [_payload] call ServoPeregrino_Organizador_Items_fnc_mergeKitIntoDraft
    };
    default {[false,"ITEMS_UI_TRANSFER_SOURCE_UNKNOWN","Este item não pode ser adicionado ao kit desta forma.",createHashMapFromArray [["sourceType",_sourceType]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
};

// Auto-create + transfer behaves as one logical gesture. If the payload fails, the
// pre-drop draft state is restored so we do not leave a phantom empty Rascunho.
if (_autoCreated) then {
    if !(_result getOrDefault ["success",false]) then {
        missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,_stateBefore];
        diag_log format ["[SP_ORG] [ITEMS] [DRAFT_AUTO_CREATE] origin=%1 source=%2 created=true rollback=true code=%3",_origin,_type,_result getOrDefault ["code","UNKNOWN"]];
    } else {
        private _data=_result getOrDefault ["data",createHashMap];
        _data set ["autoDraftCreated",true];
        _data set ["autoDraftOrigin",_origin];
        _data set ["autoDraftTrigger",_autoCreateTrigger];
        _result set ["data",_data];
        _result set ["message",if (_type isEqualTo "KIT") then {"Novo Rascunho criado e kit adicionado."} else {"Novo Rascunho criado e item adicionado."}];
    };
};
_result
