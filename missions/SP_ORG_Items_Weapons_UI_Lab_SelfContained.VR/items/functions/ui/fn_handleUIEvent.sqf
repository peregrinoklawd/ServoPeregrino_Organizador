#include "..\..\script_version.hpp"
disableSerialization;
params [["_event","",[""]],["_value",nil]];
private _state=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
if ((count _state) isEqualTo 0) then {_state=[] call ServoPeregrino_Organizador_Items_fnc_createUIState;};
private _eventU=toUpper _event;
if ((_state getOrDefault ["refreshing",false]) && {_eventU in ["KIT_SELECT","CATALOG_SELECT","CATALOG_TABLE_SELECT","CATALOG_ROW_SELECT","CATALOG_SCROLL_ABSOLUTE","DRAFT_ROW_SELECT","EQUIPMENT_SELECT"]}) exitWith {true};
// COPIADO/PUBLICADO são confirmações transitórias: ficam visíveis até a próxima interação real.
[_eventU] call ServoPeregrino_Organizador_Items_fnc_clearKitLibraryActionStatus;
_state=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state];
private _display=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR,displayNull];
private _refresh=true; private _draftFocusedRefresh=false; private _draftFocusedReason="EVENT"; private _catalogFocusedRefresh=false; private _catalogFocusedReason="EVENT"; private _equipmentFocusedRefresh=false; private _equipmentFocusedReason="EVENT"; private _equipmentSameView=false; private _feedback=""; private _feedbackLevel="INFO"; private _result=createHashMap; private _stateManagedExternally=false; private _focusedRefreshResult=createHashMap; private _targetRefresh=false; private _targetRefreshReason="EVENT"; private _soundOutcome=""; private _movementSound=""; private _pendingOutcome=createHashMap;
// Result feedback is staged locally. Writing it immediately would mutate UI State and then be
// overwritten by the older local _state at the end of this handler.
private _publishResult={
    params ["_r",["_audible",false,[true]]];
    if ((count _r)>0) then {
        _pendingOutcome=[_r] call ServoPeregrino_Organizador_Items_fnc_classifyUIOutcome;
        _feedback=_pendingOutcome getOrDefault ["message",_r getOrDefault ["message",_r getOrDefault ["code","UNKNOWN"]]];
        _feedbackLevel=_pendingOutcome getOrDefault ["severity",if (_r getOrDefault ["success",false]) then {"SUCCESS"} else {"WARN"}];
        if (_audible) then {_soundOutcome=_pendingOutcome getOrDefault ["soundKey",""]; _movementSound=_pendingOutcome getOrDefault ["movementKey",""];};
    };
};
private _clickArrow={
    params ["_mouseArgs","_sourceType"];
    _mouseArgs params ["_ctrl","_button","_x","_y","_shift","_ctrlKey","_alt"];
    if !(_button isEqualTo 0) exitWith {createHashMap};
    private _p=ctrlPosition _ctrl; private _localX=if (_x>=0 && {_x<=(_p#2)}) then {_x} else {_x-(_p#0)};
    // A zona de ação não cresce com a largura do painel: usa uma rail aspect-safe derivada da altura da UI.
    private _arrowHitW = (((0.045 * safeZoneH) * pixelW / pixelH) min ((_p#2) * 0.22));
    if (_localX < ((_p#2)-_arrowHitW)) exitWith {createHashMap};
    private _row=lbCurSel _ctrl; if (_row<0) exitWith {createHashMap};
    private _data=_ctrl lbData _row; private _payload=if (_sourceType isEqualTo "EQUIPMENT") then {if (_data isEqualTo "") then {[]} else {parseSimpleArray _data}} else {_data};
    private _arrowOrigin=if ((toUpper _sourceType) isEqualTo "EQUIPMENT") then {"EQUIPMENT_ARROW_TO_DRAFT"} else {"CATALOG_ARROW_TO_DRAFT"};
    [_sourceType,_payload,"DRAFT","AUTO",player,"",createHashMapFromArray [["commandOrigin",_arrowOrigin],["autoCreateDraftIfMissing",true]]] call ServoPeregrino_Organizador_Items_fnc_executeUITransferCommand
};
private _executeCatalogClassAction={
    params ["_className","_destination",["_origin","CATALOG_ROW_BUTTON",[""]]];
    if (_className isEqualTo "" || {!(_destination in ["DRAFT","PHYSICAL"])}) exitWith {createHashMap};
    private _requestedTarget=if (_destination isEqualTo "PHYSICAL") then {_state getOrDefault ["equipmentView","U"]} else {""};
    private _opts=createHashMapFromArray [["commandOrigin",_origin]];
    if (_destination isEqualTo "DRAFT") then {_opts set ["autoCreateDraftIfMissing",true];};
    ["CATALOG",_className,_destination,"AUTO",player,_requestedTarget,_opts] call ServoPeregrino_Organizador_Items_fnc_executeUITransferCommand
};

private _clickCatalogAction={
    params ["_mouseArgs"];
    _mouseArgs params ["_ctrl","_button","_x","_y","_shift","_ctrlKey","_alt"];
    if !(_button isEqualTo 0) exitWith {createHashMap};
    private _p=ctrlPosition _ctrl;
    private _localX=if (_x>=0 && {_x<=(_p#2)}) then {_x} else {_x-(_p#0)};
    // 0.12-C.2: ações laterais independentes. O picture continua seleção pura;
    // ← fica imediatamente depois do picture e → ocupa somente a borda direita.
    private _pictureW=((0.027*safeZoneH)*pixelW/pixelH);
    private _sideHitW=(((0.032*safeZoneH)*pixelW/pixelH) min ((_p#2)*0.14));
    private _leftStart=_pictureW;
    private _leftEnd=_leftStart+_sideHitW;
    private _rightStart=(_p#2)-_sideHitW;
    private _hitLeft=(_localX>=_leftStart) && {_localX<=_leftEnd};
    private _hitRight=_localX>=_rightStart;
    if !(_hitLeft || {_hitRight}) exitWith {createHashMap};
    private _row=lbCurSel _ctrl;
    if (_row<0) exitWith {createHashMap};
    private _className=_ctrl lbData _row;
    if (_className isEqualTo "") exitWith {createHashMap};
    private _destination=if (_hitLeft) then {"DRAFT"} else {"PHYSICAL"};
    [_className,_destination,if (_destination isEqualTo "DRAFT") then {"CATALOG_ARROW_TO_DRAFT"} else {"CATALOG_ARROW_TO_PHYSICAL"}] call _executeCatalogClassAction
};
switch _eventU do {
    case "REQUEST_CLOSE": {["CLOSE_UI"] call ServoPeregrino_Organizador_Items_fnc_requestDraftTransition; _refresh=false; _stateManagedExternally=true;};
    case "KIT_SEARCH": {_state set ["kitQuery",_value];};
    case "KIT_LIBRARY_MODE": {
        private _mode=toUpper _value;
        if (_mode in ["PRIVATE","PUBLIC"]) then {
            _state set ["kitLibraryMode",_mode];
            _feedback=if (_mode isEqualTo "PRIVATE") then {"Exibindo seus kits privados."} else {"Exibindo kits públicos compartilhados nesta sessão."};
            _feedbackLevel="INFO";
        };
    };
    case "DRAFT_SEARCH": {_state set ["draftQuery",_value]; _refresh=false; _draftFocusedRefresh=true; _draftFocusedReason="DRAFT_SEARCH";};
    case "CATALOG_SEARCH": {_state set ["catalogQuery",_value]; _state set ["catalogOffset",0]; _refresh=false; _catalogFocusedRefresh=true; _catalogFocusedReason="CATALOG_SEARCH";};
    case "EQUIPMENT_SEARCH": {_state set ["equipmentQuery",_value]; _refresh=false; _equipmentFocusedRefresh=true; _equipmentFocusedReason="EQUIPMENT_SEARCH"; _equipmentSameView=false;};
    case "EQUIPMENT_SELECT": {
        _refresh=false;
        [] call ServoPeregrino_Organizador_Items_fnc_refreshEquipmentSelectionControls;
        // O helper grava o payload/view congelados no estado; recarregamos para não sobrescrevê-los
        // com a cópia local anterior quando o handler persiste a revisão no final.
        _state=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state];
    };
    case "APP_TARGET": {
        private _v=toUpper _value;
        if (_v in ["ANY","U","C","M"]) then {
            private _viewBefore=_state getOrDefault ["equipmentView","U"];
            _state set ["applicationTarget",_v];
            private _ready=[player,_v,""] call ServoPeregrino_Organizador_Items_fnc_getUIPhysicalReadiness;
            private _rd=_ready getOrDefault ["data",createHashMap];
            _feedback=if (_rd getOrDefault ["physicalMutationEnabled",false]) then {
                format ["As ações APLICAR, REMOVER e SUBSTITUIR do kit usarão %1. O painel continua mostrando %2.",[_rd getOrDefault ["resolvedTarget","-"]] call ServoPeregrino_Organizador_Items_fnc_getUITargetLabel,[_viewBefore] call ServoPeregrino_Organizador_Items_fnc_getUITargetLabel]
            } else {
                format ["%1 foi escolhido para as ações do kit, mas não pode receber itens agora. O painel continua mostrando %2.",[_v] call ServoPeregrino_Organizador_Items_fnc_getUITargetLabel,[_viewBefore] call ServoPeregrino_Organizador_Items_fnc_getUITargetLabel]
            };
            _feedbackLevel=if (_rd getOrDefault ["physicalMutationEnabled",false]) then {"INFO"} else {"WARN"};
            _refresh=false;
            _targetRefresh=true;
            _targetRefreshReason="APP_TARGET";
        };
    };
    case "EQUIPMENT_VIEW": {
        private _v=toUpper _value;
        if (_v in ["U","C","M"]) then {
            private _before=_state getOrDefault ["equipmentView","U"];
            _equipmentSameView=_before isEqualTo _v;
            _state set ["equipmentView",_v];
            _feedback=if (_equipmentSameView) then {format ["Você já está visualizando %1. Itens adicionados diretamente pelo Catálogo irão para este equipamento.",[_v] call ServoPeregrino_Organizador_Items_fnc_getUITargetLabel]} else {format ["Agora mostrando %1. Itens adicionados diretamente pelo Catálogo irão para este equipamento; Onde aplicar o kit? não mudou.",[_v] call ServoPeregrino_Organizador_Items_fnc_getUITargetLabel]};
            _refresh=false;
            _equipmentFocusedRefresh=true;
            _equipmentFocusedReason="EQUIPMENT_VIEW";
        };
    };
    case "CATALOG_CATEGORY": {private _v=toUpper _value; if (_v in ([] call ServoPeregrino_Organizador_Items_fnc_getCatalogCategories)) then {_state set ["catalogCategory",_v]; _state set ["catalogOffset",0]; _refresh=false; _catalogFocusedRefresh=true; _catalogFocusedReason="CATALOG_CATEGORY";};};
    // CATALOG_PAGE permanece como alias legado, mas a superfície 0.12-C usa scroll contínuo.
    case "CATALOG_PAGE": {private _size=_state getOrDefault ["catalogWindowSize",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_WINDOW_SIZE]; private _max=_state getOrDefault ["catalogMaxOffset",0]; _state set ["catalogOffset",((((_state getOrDefault ["catalogOffset",0])+(_value*_size)) max 0) min _max)]; _refresh=false; _catalogFocusedRefresh=true; _catalogFocusedReason="CATALOG_SCROLL_LEGACY";};
    case "CATALOG_SCROLL": {
        private _max=_state getOrDefault ["catalogMaxOffset",0];
        private _offset=(((_state getOrDefault ["catalogOffset",0])+_value) max 0) min _max;
        _state set ["catalogOffset",round _offset];
        _state set ["catalogContinuousScrollCount",(_state getOrDefault ["catalogContinuousScrollCount",0])+1];
        _refresh=false; _catalogFocusedRefresh=true; _catalogFocusedReason="CATALOG_SCROLL";
    };
    case "CATALOG_SCROLL_ABSOLUTE": {
        private _max=_state getOrDefault ["catalogMaxOffset",0];
        private _offset=round (((_value max 0) min _max));
        private _ratio=if (_max>0) then {_offset/_max} else {0};
        _state set ["catalogScrollRatio",_ratio];
        _state set ["catalogOffset",_offset];
        _state set ["catalogContinuousScrollCount",(_state getOrDefault ["catalogContinuousScrollCount",0])+1];
        _refresh=false; _catalogFocusedRefresh=true; _catalogFocusedReason="CATALOG_SCROLL_SLIDER";
    };
    case "KIT_SELECT": {
        if (!isNull _display && {_value>=0}) then {
            private _id=(_display displayCtrl 1102) lbData _value;
            private _mode=toUpper (_state getOrDefault ["kitLibraryMode","PRIVATE"]);
            if (_mode isEqualTo "PUBLIC") then {
                _state set ["selectedPublicKitId",_id];
                _feedback="Kit público selecionado. Ele permanece somente leitura até você salvar uma cópia no privado.";
                _feedbackLevel="INFO";
                _refresh=false;
            } else {
                ["LOAD_KIT",_id] call ServoPeregrino_Organizador_Items_fnc_requestDraftTransition;
                _refresh=false; _stateManagedExternally=true;
            };
        };
    };
    case "NEW_KIT": {if ((toUpper (_state getOrDefault ["kitLibraryMode","PRIVATE"])) isEqualTo "PRIVATE") then {["NEW_DRAFT"] call ServoPeregrino_Organizador_Items_fnc_requestDraftTransition; _refresh=false; _stateManagedExternally=true;} else {_feedback="NOVO está disponível na aba PRIVADOS."; _feedbackLevel="WARN";};};
    case "DUPLICATE_KIT": {
        if ((toUpper (_state getOrDefault ["kitLibraryMode","PRIVATE"])) isEqualTo "PUBLIC") exitWith {_feedback="Duplicar diretamente um kit público não é permitido. Use SALVAR NO PRIVADO."; _feedbackLevel="WARN";};
        private _id=_state getOrDefault ["selectedKitId",""];
        if (_id isEqualTo "") then {_feedback="Selecione um kit persistido para duplicar."; _feedbackLevel="WARN";} else {
            private _get=[_id] call ServoPeregrino_Organizador_Items_fnc_getKit;
            if (_get getOrDefault ["success",false]) then {private _kit=((_get getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]]); _result=[_id,format ["%1 — Cópia",_kit#3]] call ServoPeregrino_Organizador_Items_fnc_cloneKit;} else {_result=_get;};
            [_result] call _publishResult;
        };
    };
    case "DELETE_KIT_REQUEST": {
        if ((toUpper (_state getOrDefault ["kitLibraryMode","PRIVATE"])) isEqualTo "PUBLIC") exitWith {_feedback="Kits públicos são somente leitura nesta interface."; _feedbackLevel="WARN";};
        private _id=_state getOrDefault ["selectedKitId",""];
        if (_id isEqualTo "") then {_feedback="Selecione um kit persistido para excluir."; _feedbackLevel="WARN";} else {
            private _get=[_id] call ServoPeregrino_Organizador_Items_fnc_getKit;
            private _kitName=if (_get getOrDefault ["success",false]) then {((((_get getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]]) param [3,"Kit selecionado",[""]]))} else {"Kit selecionado"};
            private _draftD=([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap]; private _cur=_draftD getOrDefault ["current",createHashMap];
            private _isBacking=(_draftD getOrDefault ["hasDraft",false]) && {(_cur getOrDefault ["mode",""]) isEqualTo "EDIT"} && {(_cur getOrDefault ["kitId",""]) isEqualTo _id};
            private _isDirty=_isBacking && {_cur getOrDefault ["dirty",false]};
            private _deleteIndex=if (!isNull _display) then {lbCurSel (_display displayCtrl 1102)} else {-1};
            [_id,_kitName,_isBacking,_isDirty,_deleteIndex] spawn {
                params ["_kitId","_name","_preserveDraft","_dirty","_preferredIndex"];
                private _question=if (_preserveDraft) then {
                    if (_dirty) then {format ["Excluir permanentemente o kit salvo '%1'? As alterações que estão abertas serão mantidas como um novo Kit Selecionado ainda não salvo.",_name]} else {format ["Excluir permanentemente o kit salvo '%1'? O conteúdo que está aberto será mantido como um novo Kit Selecionado ainda não salvo.",_name]}
                } else {format ["Excluir permanentemente o kit salvo '%1'?",_name]};
                private _yes=[_question,"SP_ORG_Items",true,true] call BIS_fnc_guiMessage;
                if (_yes) then {
                    private _r=[_kitId] call ServoPeregrino_Organizador_Items_fnc_deleteKitPreservingDraft;
                    [_r getOrDefault ["message",_r getOrDefault ["code","UNKNOWN"]],if (_r getOrDefault ["success",false]) then {"INFO"} else {"WARN"}] call ServoPeregrino_Organizador_Items_fnc_pushUIFeedback;
                    private _ui=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
                    if (_r getOrDefault ["success",false]) then {
                        // Remove a identidade excluída antes do rebuild. Depois do rebuild, promove o próximo
                        // item VISÍVEL para a seleção lógica sem carregar outro kit no Rascunho preservado.
                        _ui set ["selectedKitId",""];
                        missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_ui];
                        [] call ServoPeregrino_Organizador_Items_fnc_refreshInterface;
                        [_preferredIndex] call ServoPeregrino_Organizador_Items_fnc_reconcilePrivateKitSelectionAfterDelete;
                    } else {
                        [] call ServoPeregrino_Organizador_Items_fnc_refreshInterface;
                    };
                };
            };
            _refresh=false;
        };
    };
    case "PUBLISH_KIT": {
        _state set ["kitLibraryActionStatus",""];
        private _mode=toUpper (_state getOrDefault ["kitLibraryMode","PRIVATE"]);
        private _id=_state getOrDefault ["selectedKitId",""];
        if !(_mode isEqualTo "PRIVATE") then {_feedback="PUBLICAR usa um kit da aba PRIVADOS."; _feedbackLevel="WARN";} else {
            if (_id isEqualTo "") then {_feedback="Selecione um kit privado para publicar."; _feedbackLevel="WARN";} else {
                _result=[_id,player] call ServoPeregrino_Organizador_Items_fnc_publishKitToPublic;
                private _publishData=_result getOrDefault ["data",createHashMap];
                private _pending=_publishData getOrDefault ["pending",false];
                if (_pending) then {
                    [_result getOrDefault ["message","Solicitação enviada ao servidor."],"INFO"] call ServoPeregrino_Organizador_Items_fnc_pushUIFeedback;
                    _state set ["kitLibraryActionStatus","ENVIADO"];
                } else {
                    [_result,true] call _publishResult;
                    if (_result getOrDefault ["success",false]) then {_state set ["kitLibraryActionStatus","PUBLICADO"];};
                };
            };
        };
    };
    case "SAVE_PUBLIC_PRIVATE": {
        _state set ["kitLibraryActionStatus",""];
        private _mode=toUpper (_state getOrDefault ["kitLibraryMode","PRIVATE"]);
        private _publicId=_state getOrDefault ["selectedPublicKitId",""];
        if !(_mode isEqualTo "PUBLIC") then {_feedback="SALVAR NO PRIVADO usa um kit da aba PÚBLICOS."; _feedbackLevel="WARN";} else {
            if (_publicId isEqualTo "") then {_feedback="Selecione um kit público para salvar no privado."; _feedbackLevel="WARN";} else {
                _result=[_publicId] call ServoPeregrino_Organizador_Items_fnc_savePublicKitToPrivate;
                // Cópia Público → Privado é persistência explícita: confirma sucesso também por áudio.
                [_result,true] call _publishResult;
                if (_result getOrDefault ["success",false]) then {
                    private _rd=_result getOrDefault ["data",createHashMap];
                    // Mantém a navegação na aba PÚBLICOS e preserva busca/seleção para permitir copiar vários kits em sequência.
                    _state set ["selectedKitId",_rd getOrDefault ["kitId",""]];
                    _state set ["kitLibraryActionStatus","COPIADO"];
                };
            };
        };
    };
    case "REFRESH_PUBLIC_KITS": {
        _feedback="Biblioteca pública da sessão atualizada."; _feedbackLevel="INFO";
    };
    case "DRAFT_NAME": {_result=[_value] call ServoPeregrino_Organizador_Items_fnc_setDraftName; [_result] call _publishResult; _refresh=false; _draftFocusedRefresh=true; _draftFocusedReason="DRAFT_NAME";};
    case "DRAFT_TARGET": {_result=[_value] call ServoPeregrino_Organizador_Items_fnc_setDraftPreferredTarget; [_result] call _publishResult;};
    case "DRAFT_SAVE": {_result=[] call ServoPeregrino_Organizador_Items_fnc_saveDraft; [_result] call _publishResult; if (_result getOrDefault ["success",false]) then {private _ds=([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap]; _state set ["selectedKitId",((_ds getOrDefault ["current",createHashMap]) getOrDefault ["kitId",""])];};};
    case "DRAFT_SAVE_AS_NEW": {_result=[] call ServoPeregrino_Organizador_Items_fnc_saveDraftAsNew; [_result] call _publishResult; if (_result getOrDefault ["success",false]) then {private _ds=([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap]; _state set ["selectedKitId",((_ds getOrDefault ["current",createHashMap]) getOrDefault ["kitId",""])];};};
    case "DRAFT_DISCARD_REQUEST": {["DISCARD_DRAFT"] call ServoPeregrino_Organizador_Items_fnc_requestDraftTransition; _refresh=false; _stateManagedExternally=true;};
    case "DRAFT_ROW_SELECT": {
        if (!isNull _display && {_value>=0}) then {
            private _table=_display displayCtrl 2104; private _controls=_table ctRowControls _value;
            if ((count _controls)>0) then {_state set ["selectedDraftRowKey",(_controls#0) getVariable ["SPORG_Items_rowKey",[]]];};
        };
        // Seleção pura não reconstrói Controls Table nem altera scroll.
        _refresh=false;
    };
    case "CATALOG_TABLE_SELECT": {
        _refresh=false;
        if (!isNull _display && {_value>=0}) then {
            private _table=_display displayCtrl SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_TABLE_IDC;
            private _controls=_table ctRowControls _value;
            if ((count _controls)>0) then {
                private _className=(_controls#0) getVariable ["SPORG_Items_catalogClass",""];
                if (_className isNotEqualTo "") then {_state set ["selectedCatalogClass",_className]; [_className] call ServoPeregrino_Organizador_Items_fnc_refreshCatalogSelectionDetails;};
            };
        };
    };
    case "CATALOG_ROW_SELECT": {
        _refresh=false;
        private _ctrl=_value;
        if (!isNull _ctrl) then {
            private _className=_ctrl getVariable ["SPORG_Items_catalogClass",""];
            private _rowIndex=_ctrl getVariable ["SPORG_Items_catalogRowIndex",-1];
            if (_className isNotEqualTo "") then {
                _state set ["selectedCatalogClass",_className];
                if (!isNull _display && {_rowIndex>=0}) then {(_display displayCtrl SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_TABLE_IDC) ctSetCurSel _rowIndex;};
                [_className] call ServoPeregrino_Organizador_Items_fnc_refreshCatalogSelectionDetails;
            };
        };
    };
    case "CATALOG_ROW_BUTTON": {
        _refresh=false;
        _value params ["_ctrl","_destination"];
        private _className=if (isNull _ctrl) then {""} else {_ctrl getVariable ["SPORG_Items_catalogClass",""]};
        private _dest=toUpper _destination;
        private _origin=if (_dest isEqualTo "DRAFT") then {"CATALOG_BUTTON_TO_DRAFT"} else {"CATALOG_BUTTON_TO_PHYSICAL"};
        _result=[_className,_dest,_origin] call _executeCatalogClassAction;
        if ((count _result)>0) then {
            [_result,true] call _publishResult;
            if (_dest isEqualTo "DRAFT") then {
                if (_result getOrDefault ["success",false]) then {_draftFocusedRefresh=true; _draftFocusedReason="CATALOG_BUTTON_TO_DRAFT";};
            } else {
                if (_result getOrDefault ["success",false]) then {_focusedRefreshResult=_result;} else {_targetRefresh=true; _targetRefreshReason="CATALOG_BUTTON_TO_PHYSICAL_FAILURE";};
            };
        };
    };
    case "CATALOG_SELECT": {
        if (!isNull _display && {_value>=0}) then {
            private _className=(_display displayCtrl 3120) lbData _value;
            _state set ["selectedCatalogClass",_className];
            // O ListBox já selecionou a linha. Atualizamos somente detalhes; lbClear/lbSetCurSel causavam autoscroll.
            [_className] call ServoPeregrino_Organizador_Items_fnc_refreshCatalogSelectionDetails;
        };
        _refresh=false;
    };
    case "CATALOG_ARROW_CLICK": {
        _result=[_value] call _clickCatalogAction;
        // Fora da rail ←/→ o clique permanece somente seleção.
        if ((count _result) isEqualTo 0) then {
            _refresh=false;
        } else {
            [_result,true] call _publishResult;
            _refresh=false;
            private _rd=_result getOrDefault ["data",createHashMap];
            private _cmd=_rd getOrDefault ["uiCommand",createHashMap];
            private _destination=_cmd getOrDefault ["destination","DRAFT"];
            if (_destination isEqualTo "DRAFT") then {
                if (_result getOrDefault ["success",false]) then {_draftFocusedRefresh=true; _draftFocusedReason="CATALOG_ARROW_TO_DRAFT";};
            } else {
                if (_result getOrDefault ["success",false]) then {_focusedRefreshResult=_result;} else {_targetRefresh=true; _targetRefreshReason="CATALOG_ARROW_TO_PHYSICAL_FAILURE";};
            };
        };
    };
    case "EQUIPMENT_ARROW_CLICK": {
        _result=[_value,"EQUIPMENT"] call _clickArrow;
        // Mesmo contrato preventivo: clicar no corpo da linha não é uma operação de transferência.
        if ((count _result) isEqualTo 0) then {_refresh=false;} else {[_result,true] call _publishResult; _refresh=false; _draftFocusedRefresh=true; _draftFocusedReason="EQUIPMENT_ARROW_TO_DRAFT";};
    };
    case "PHYSICAL_APPLY": {
        _result=["DRAFT",[],"PHYSICAL","ADD",player,_state getOrDefault ["applicationTarget","ANY"],createHashMapFromArray [["commandOrigin","BUTTON_APPLY"]]] call ServoPeregrino_Organizador_Items_fnc_executeUITransferCommand;
        [_result,true] call _publishResult;
        if (_result getOrDefault ["success",false]) then {_focusedRefreshResult=_result;} else {_targetRefresh=true; _targetRefreshReason="COMMAND_FAILURE";};
        _refresh=false;
    };
    case "PHYSICAL_REMOVE": {
        _result=["DRAFT",[],"PHYSICAL","REMOVE",player,_state getOrDefault ["applicationTarget","ANY"],createHashMapFromArray [["commandOrigin","BUTTON_REMOVE"]]] call ServoPeregrino_Organizador_Items_fnc_executeUITransferCommand;
        [_result,true] call _publishResult;
        if (_result getOrDefault ["success",false]) then {_focusedRefreshResult=_result;} else {_targetRefresh=true; _targetRefreshReason="COMMAND_FAILURE";};
        _refresh=false;
    };
    case "PHYSICAL_REPLACE_REQUEST": {
        _refresh=false;
        private _target=_state getOrDefault ["applicationTarget","ANY"];
        [_target] spawn {
            params ["_targetArg"];
            private _yes=[format ["Substituir os itens gerenciáveis de %1 pelo conteúdo do Kit Selecionado? Armas e outros conteúdos reservados serão preservados.",[_targetArg] call ServoPeregrino_Organizador_Items_fnc_getUITargetLabel],"Substituir conteúdo do equipamento",true,true] call BIS_fnc_guiMessage;
            if (_yes) then {
                private _r=["DRAFT",[],"PHYSICAL","REPLACE",player,_targetArg,createHashMapFromArray [["commandOrigin","BUTTON_REPLACE"]]] call ServoPeregrino_Organizador_Items_fnc_executeUITransferCommand;
                private _rdAsync=_r getOrDefault ["data",createHashMap];
                private _cmdAsync=_rdAsync getOrDefault ["uiCommand",createHashMap];
                [_r,true] call ServoPeregrino_Organizador_Items_fnc_presentUIResult;
                if (_r getOrDefault ["success",false]) then {[_r] call ServoPeregrino_Organizador_Items_fnc_refreshPhysicalMutationUI;} else {[createHashMapFromArray [["reason","COMMAND_FAILURE"]]] call ServoPeregrino_Organizador_Items_fnc_refreshPhysicalTargetUI;};
            };
        };
    };
    case "DRAFT_CLEAR_REQUEST": {
        _refresh=false;
        private _draftData=([] call ServoPeregrino_Organizador_Items_fnc_getDraftState) getOrDefault ["data",createHashMap];
        private _draftNow=_draftData getOrDefault ["current",createHashMap];
        if !(_draftData getOrDefault ["hasDraft",false]) then {
            _feedback="Nenhum Kit Selecionado está aberto para limpar."; _feedbackLevel="WARN";
        } else {
            private _countEntries=count (_draftNow getOrDefault ["entries",[]]);
            if (_countEntries isEqualTo 0) then {
                _result=[] call ServoPeregrino_Organizador_Items_fnc_clearDraftEntries; [_result,true] call _publishResult; _refresh=false; _draftFocusedRefresh=true; _draftFocusedReason="DRAFT_CLEAR_NOOP";
            } else {
                [_countEntries] spawn {
                    params ["_entryCount"];
                    private _yes=[format ["Remover todos os %1 itens/linhas do Kit Selecionado? Isso não altera o equipamento do jogador.",_entryCount],"Limpar Kit Selecionado",true,true] call BIS_fnc_guiMessage;
                    if (_yes) then {
                        private _r=[] call ServoPeregrino_Organizador_Items_fnc_clearDraftEntries;
                        [_r,true,createHashMapFromArray [["movementHint","REMOVE"]]] call ServoPeregrino_Organizador_Items_fnc_presentUIResult;
                        if (_r getOrDefault ["success",false]) then {
                            private _ui=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
                            _ui set ["selectedDraftRowKey",[]];
                            missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_ui];
                        };
                        ["DRAFT_CLEAR"] call ServoPeregrino_Organizador_Items_fnc_refreshDraftMutationUI;
                    };
                };
            };
        };
    };
    case "EQUIPMENT_CLEAR_REQUEST": {
        _refresh=false;
        private _view=_state getOrDefault ["equipmentView","U"];
        [_view] spawn {
            params ["_viewArg"];
            private _yes=[format ["Remover todos os itens gerenciáveis de %1? Armas, mochilas internas e outros conteúdos reservados serão preservados.",[_viewArg] call ServoPeregrino_Organizador_Items_fnc_getUITargetLabel],"Limpar equipamento mostrado",true,true] call BIS_fnc_guiMessage;
            if (_yes) then {
                private _r=[player,_viewArg,createHashMapFromArray [["commandOrigin","BUTTON_EQUIPMENT_CLEAR"]]] call ServoPeregrino_Organizador_Items_fnc_executeEquipmentClear;
                private _rdAsync=_r getOrDefault ["data",createHashMap];
                private _cmdAsync=_rdAsync getOrDefault ["uiCommand",createHashMap];
                [_r,true] call ServoPeregrino_Organizador_Items_fnc_presentUIResult;
                if (_r getOrDefault ["success",false]) then {[_r] call ServoPeregrino_Organizador_Items_fnc_refreshPhysicalMutationUI;} else {[createHashMapFromArray [["reason","EQUIPMENT_CLEAR_FAILURE"]]] call ServoPeregrino_Organizador_Items_fnc_refreshPhysicalTargetUI;};
            };
        };
    };
    case "CAPTURE_EQUIPMENT": {
        _result=[player,_state getOrDefault ["equipmentView","U"]] call ServoPeregrino_Organizador_Items_fnc_captureEquipmentToDraft;
        [_result,true] call _publishResult;
        _refresh=false; _draftFocusedRefresh=true; _draftFocusedReason="CAPTURE_EQUIPMENT_TO_DRAFT";
    };
    case "REFRESH": {_feedback="Conteúdo do equipamento atualizado."; _refresh=false; _equipmentFocusedRefresh=true; _equipmentFocusedReason="EQUIPMENT_REFRESH"; _equipmentSameView=false;};
    default {_refresh=false;};
};
if (!_stateManagedExternally) then {_state set ["revision",(_state getOrDefault ["revision",0])+1]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state];};
if (_feedback isNotEqualTo "") then {[_feedback,_feedbackLevel] call ServoPeregrino_Organizador_Items_fnc_pushUIFeedback;};
if ((count _pendingOutcome)>0) then {
    private _uiOutcomeState=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
    _uiOutcomeState set ["lastOutcome",_pendingOutcome getOrDefault ["outcome",""]];
    _uiOutcomeState set ["lastOutcomeSummary",_pendingOutcome getOrDefault ["message",""]];
    _uiOutcomeState set ["lastOutcomeCode",_pendingOutcome getOrDefault ["code",""]];
    _uiOutcomeState set ["lastOutcomeMetrics",createHashMapFromArray [["appliedQty",_pendingOutcome getOrDefault ["appliedQty",0]],["rejectedCount",_pendingOutcome getOrDefault ["rejectedCount",0]],["actionCount",_pendingOutcome getOrDefault ["actionCount",0]],["commandId",_pendingOutcome getOrDefault ["commandId","-"]]]];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_uiOutcomeState];
};
if (_soundOutcome isNotEqualTo "") then {
    if ((_pendingOutcome getOrDefault ["outcome",""]) isEqualTo "SUCCESS" && {_movementSound isNotEqualTo ""}) then {[_movementSound] call ServoPeregrino_Organizador_Items_fnc_playUIMovementSound;} else {[_soundOutcome] call ServoPeregrino_Organizador_Items_fnc_playUIFeedbackSound;};
};
if ((count _focusedRefreshResult)>0) then {[_focusedRefreshResult] call ServoPeregrino_Organizador_Items_fnc_refreshPhysicalMutationUI;};
if (_targetRefresh && {(count _focusedRefreshResult) isEqualTo 0}) then {[createHashMapFromArray [["reason",_targetRefreshReason]]] call ServoPeregrino_Organizador_Items_fnc_refreshPhysicalTargetUI;};
if (_draftFocusedRefresh) then {[_draftFocusedReason] call ServoPeregrino_Organizador_Items_fnc_refreshDraftMutationUI;};
if (_equipmentFocusedRefresh) then {[createHashMapFromArray [["reason",_equipmentFocusedReason],["sameView",_equipmentSameView]]] call ServoPeregrino_Organizador_Items_fnc_refreshEquipmentViewUI;};
if (_catalogFocusedRefresh) then {[_catalogFocusedReason] call ServoPeregrino_Organizador_Items_fnc_refreshCatalogWindowUI;};
if (_refresh) then {[] call ServoPeregrino_Organizador_Items_fnc_refreshInterface;};
true
