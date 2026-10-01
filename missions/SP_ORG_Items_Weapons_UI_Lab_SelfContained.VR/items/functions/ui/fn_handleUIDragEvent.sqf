#include "..\..\script_version.hpp"
disableSerialization;
params [["_event","",[""]],["_args",[],[[]]]];
private _eventU=toUpper _event;
private _display=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR,displayNull];
private _draftDrop=if (isNull _display) then {controlNull} else {_display displayCtrl 2103};
private _physicalDrop=if (isNull _display) then {controlNull} else {_display displayCtrl 4113};
private _draftPanel=if (isNull _display) then {controlNull} else {_display displayCtrl SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAFT_PANEL_IDC};
private _equipmentPanel=if (isNull _display) then {controlNull} else {_display displayCtrl SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_EQUIPMENT_PANEL_IDC};

private _logStart={
    params ["_drag"];
    diag_log format ["[SP_ORG] [ITEMS] [DND] START source=%1 sourceId=%2 custom=%3 pointerAuthority=%4",_drag getOrDefault ["sourceType",""],_drag getOrDefault ["sourceId",""],_drag getOrDefault ["customPointerDrag",false],_drag getOrDefault ["pointerAuthority","LEGACY"]];
};

private _setDropVisuals={
    params ["_drag"];
    private _sourceType=_drag getOrDefault ["sourceType",""];
    ["MOVE",_drag,_display,-1000,-1000,true] call ServoPeregrino_Organizador_Items_fnc_updateUIDragVisualProxy;
    private _target=[-1000,-1000,_sourceType,_display,true] call ServoPeregrino_Organizador_Items_fnc_resolveUIPanelDropTarget;
    private _area=_target getOrDefault ["area","OUTSIDE"];
    private _destination=_target getOrDefault ["destination",""];
    private _draftAllowed=_target getOrDefault ["draftAllowed",false];
    private _physicalAllowed=_target getOrDefault ["physicalAllowed",false];
    private _physicalReady=_target getOrDefault ["physicalReady",false];

    if (!isNull _draftPanel) then {
        private _hover=_area isEqualTo "DRAFT_PANEL";
        _draftPanel ctrlSetBackgroundColor (if (_hover && {_draftAllowed}) then {[0.025,0.16,0.13,0.62]} else {if (_draftAllowed) then {[0.018,0.055,0.050,0.52]} else {[0.015,0.02,0.022,0.44]}});
    };
    if (!isNull _equipmentPanel) then {
        private _hover=_area isEqualTo "EQUIPMENT_PANEL";
        _equipmentPanel ctrlSetBackgroundColor (if (_hover && {_physicalAllowed} && {_physicalReady}) then {[0.18,0.095,0.025,0.64]} else {if (_physicalAllowed && {_physicalReady}) then {[0.065,0.042,0.025,0.52]} else {[0.015,0.02,0.022,0.44]}});
    };
    if (!isNull _draftDrop) then {
        private _draftStateForDrop=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR,createHashMap];
        private _hasDraftForDrop=_draftStateForDrop getOrDefault ["hasDraft",false];
        _draftDrop ctrlSetText (if (_draftAllowed) then {if (_hasDraftForDrop) then {"SOLTE EM QUALQUER LUGAR DESTE PAINEL PARA ADICIONAR AO KIT"} else {"SOLTE AQUI PARA CRIAR UM RASCUNHO E ADICIONAR"}} else {"ESTE ITEM NÃO PODE SER ADICIONADO AQUI"});
        _draftDrop ctrlSetBackgroundColor (if (_area isEqualTo "DRAFT_PANEL" && {_draftAllowed}) then {[0.05,0.42,0.32,0.72]} else {if (_draftAllowed) then {[0.04,0.28,0.23,0.38]} else {[0.10,0.08,0.07,0.25]}});
        _draftDrop ctrlSetTextColor (if (_draftAllowed) then {[0.70,0.94,0.87,1]} else {[0.65,0.58,0.56,0.85]});
    };
    if (!isNull _physicalDrop) then {
        private _enabled=_physicalAllowed && {_physicalReady};
        private _stateForView=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
        private _viewForDrop=_stateForView getOrDefault ["equipmentView","U"];
        private _viewForDropLabel=[_viewForDrop] call ServoPeregrino_Organizador_Items_fnc_getUITargetLabel;
        _physicalDrop ctrlSetText (if (_enabled) then {format ["SOLTE NESTE PAINEL PARA ADICIONAR A %1",_viewForDropLabel]} else {if (_physicalAllowed) then {"NÃO É POSSÍVEL ADICIONAR ITENS NESTE EQUIPAMENTO AGORA"} else {"ESTE ITEM NÃO PODE SER ADICIONADO AQUI"}});
        _physicalDrop ctrlSetBackgroundColor (if (_area isEqualTo "EQUIPMENT_PANEL" && {_enabled}) then {[0.42,0.24,0.04,0.78]} else {if (_enabled) then {[0.24,0.13,0.03,0.48]} else {[0.16,0.07,0.06,0.30]}});
        _physicalDrop ctrlSetTextColor (if (_enabled) then {[1,0.87,0.60,1]} else {[0.65,0.58,0.56,0.85]});
    };

    private _stateNow=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
    private _lastHover=_stateNow getOrDefault ["dragHoverArea","OUTSIDE"];
    if (_area isNotEqualTo _lastHover) then {
        _stateNow set ["dragHoverArea",_area];
        _stateNow set ["dragHoverDestination",_destination];
        missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_stateNow];
        diag_log format ["[SP_ORG] [ITEMS] [DND] HOVER source=%1 area=%2 destination=%3 reason=%4 coord=%5",_sourceType,_area,_destination,_target getOrDefault ["reason","OUTSIDE"],_target getOrDefault ["coordinateSource","UNKNOWN"]];
    };
    _target
};

private _beginCustom={
    params ["_sourceType","_sourceIDC","_sourceId","_payload","_sourceText",["_authority","DISPLAY_POINTER",[""]],["_sourcePicture","",[""]]];
    private _snapR=[_sourceType,_sourceIDC,_sourceId,_payload,_sourceText,_sourcePicture] call ServoPeregrino_Organizador_Items_fnc_createUIDragSnapshot;
    if !(_snapR getOrDefault ["success",false]) exitWith {false};
    private _drag=((_snapR getOrDefault ["data",createHashMap]) getOrDefault ["drag",createHashMap]);
    _drag set ["customPointerDrag",true];
    _drag set ["pointerAuthority",_authority];
    private _stateNow=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
    _stateNow set ["dragState",_drag];
    _stateNow set ["pointerDragCandidate",createHashMap];
    _stateNow set ["pointerDragTravel",0];
    _stateNow set ["dragHoverArea","OUTSIDE"];
    _stateNow set ["dragHoverDestination",""];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_stateNow];
    [_drag] call _logStart;
    ["HIDE",controlNull,_display] call ServoPeregrino_Organizador_Items_fnc_updateUIItemTooltip;
    ["SHOW",_drag,_display,-1000,-1000,true] call ServoPeregrino_Organizador_Items_fnc_updateUIDragVisualProxy;
    [_drag] call _setDropVisuals;
    true
};

// C.7 authoritative input: display MouseButtonDown only arms a serializable source candidate.
// It deliberately returns false so ordinary click/selection/button semantics are not consumed.
if (_eventU isEqualTo "POINTER_DOWN") exitWith {
    private _button=_args param [1,-1,[0]];
    if !(_button isEqualTo 0) exitWith {false};
    ["POINTER_DOWN"] call ServoPeregrino_Organizador_Items_fnc_clearKitLibraryActionStatus;
    private _source=[_display,-1000,-1000,true] call ServoPeregrino_Organizador_Items_fnc_resolveUIPointerSource;
    private _stateNow=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
    if (_source getOrDefault ["found",false]) then {
        _stateNow set ["pointerDragCandidate",_source];
        _stateNow set ["pointerDragTravel",0];
        _stateNow set ["pointerButtonDown",true];
        _stateNow set ["pointerCandidateTick",diag_tickTime];
    } else {
        _stateNow set ["pointerDragCandidate",createHashMap];
        _stateNow set ["pointerDragTravel",0];
        _stateNow set ["pointerButtonDown",false];
    };
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_stateNow];
    false
};

// Display MouseMoving supplies DELTAS, not absolute cursor position. We only accumulate travel here;
// hover/drop coordinates always come from getMousePosition via the target resolver.
if (_eventU isEqualTo "POINTER_MOVE") exitWith {
    ["SYNC",controlNull,_display] call ServoPeregrino_Organizador_Items_fnc_updateUIItemTooltip;
    private _stateNow=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
    private _drag=_stateNow getOrDefault ["dragState",createHashMap];
    if (_drag getOrDefault ["active",false]) exitWith {[_drag] call _setDropVisuals; false};
    if !(_stateNow getOrDefault ["pointerButtonDown",false]) exitWith {false};
    private _candidate=_stateNow getOrDefault ["pointerDragCandidate",createHashMap];
    if !(_candidate getOrDefault ["found",false]) exitWith {false};
    private _dx=_args param [1,0,[0]];
    private _dy=_args param [2,0,[0]];
    private _travel=(_stateNow getOrDefault ["pointerDragTravel",0]) + sqrt ((_dx*_dx)+(_dy*_dy));
    _stateNow set ["pointerDragTravel",_travel];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_stateNow];
    if (_travel >= SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DND_POINTER_THRESHOLD) then {
        [_candidate getOrDefault ["sourceType",""],_candidate getOrDefault ["sourceIDC",-1],_candidate getOrDefault ["sourceId",""],_candidate getOrDefault ["sourcePayload",[]],_candidate getOrDefault ["sourceText",""],"DISPLAY_POINTER",_candidate getOrDefault ["sourcePicture",""]] call _beginCustom;
    };
    false
};

if (_eventU isEqualTo "MOUSE_UP") exitWith {
    private _stateNow=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
    _stateNow set ["pointerButtonDown",false];
    private _drag=_stateNow getOrDefault ["dragState",createHashMap];
    if !(_drag getOrDefault ["active",false]) exitWith {
        _stateNow set ["pointerDragCandidate",createHashMap];
        _stateNow set ["pointerDragTravel",0];
        missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_stateNow];
        false
    };
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_stateNow];
    [_drag,-1000,-1000,_display,true,""] call ServoPeregrino_Organizador_Items_fnc_finalizeUIPointerDrop;
    true
};

// Legacy entry points retained for old gates/callers. Visible CT rows no longer bind these directly.
if (_eventU isEqualTo "EQUIPMENT_ROW_DRAG_START") exitWith {
    _args params ["_ctrl","_button","_x","_y","_shift","_ctrlKey","_alt"];
    if !(_button isEqualTo 0) exitWith {false};
    private _payload=+(_ctrl getVariable ["SPORG_Items_equipmentPayload",[]]);
    if ((count _payload) isNotEqualTo 5) exitWith {false};
    ["EQUIPMENT",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_EQUIPMENT_TABLE_IDC,str _payload,_payload,_ctrl getVariable ["SPORG_Items_equipmentDisplayName",""],"LEGACY_DIRECT"] call _beginCustom
};
if (_eventU isEqualTo "CATALOG_ROW_DRAG_START") exitWith {
    _args params ["_ctrl","_button","_x","_y","_shift","_ctrlKey","_alt"];
    if !(_button isEqualTo 0) exitWith {false};
    private _className=_ctrl getVariable ["SPORG_Items_catalogClass",""];
    if (_className isEqualTo "") exitWith {false};
    ["CATALOG",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_TABLE_IDC,_className,_className,_ctrl getVariable ["SPORG_Items_catalogDisplayName",_className],"LEGACY_DIRECT"] call _beginCustom
};
if (_eventU isEqualTo "DRAFT_ROW_DRAG_START") exitWith {
    _args params ["_ctrl","_button","_x","_y","_shift","_ctrlKey","_alt"];
    if !(_button isEqualTo 0) exitWith {false};
    private _entry=+(_ctrl getVariable ["SPORG_Items_draftEntry",[]]);
    if ((count _entry) isNotEqualTo 6) exitWith {false};
    private _className=_entry param [2,"",[""]];
    ["ENTRY",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAFT_TABLE_IDC,_className,_entry,_ctrl getVariable ["SPORG_Items_draftDisplayName",_className],"LEGACY_DIRECT"] call _beginCustom
};

// Native ListBox path remains authoritative for Meus Kits.
if (_eventU isEqualTo "START") exitWith {
    ["DND_START"] call ServoPeregrino_Organizador_Items_fnc_clearKitLibraryActionStatus;
    _args params ["_ctrl","_listboxInfo"];
    private _idc=ctrlIDC _ctrl;
    private _sourceType=switch _idc do {case 1102:{"KIT"}; case 3120:{"CATALOG"}; case 4120:{"EQUIPMENT"}; default {""};};
    if (_sourceType isEqualTo "KIT") then {
        private _uiNow=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
        if ((toUpper (_uiNow getOrDefault ["kitLibraryMode","PRIVATE"])) isEqualTo "PUBLIC") exitWith {
            ["Kits públicos são somente leitura. Use SALVAR NO PRIVADO antes de arrastar.","INFO"] call ServoPeregrino_Organizador_Items_fnc_pushUIFeedback;
            false
        };
    };
    if (_sourceType isEqualTo "" || {(count _listboxInfo) isEqualTo 0}) exitWith {false};
    (_listboxInfo#0) params ["_text","_value","_data"];
    private _payload=if (_sourceType isEqualTo "EQUIPMENT") then {if (_data isEqualTo "") then {[]} else {parseSimpleArray _data}} else {_data};
    private _selectedRow=lbCurSel _ctrl;
    private _sourcePicture=if (_selectedRow>=0) then {_ctrl lbPicture _selectedRow} else {""};
    private _snapR=[_sourceType,_idc,_data,_payload,_text,_sourcePicture] call ServoPeregrino_Organizador_Items_fnc_createUIDragSnapshot;
    if !(_snapR getOrDefault ["success",false]) exitWith {false};
    private _drag=((_snapR getOrDefault ["data",createHashMap]) getOrDefault ["drag",createHashMap]);
    _drag set ["pointerAuthority","NATIVE_LISTBOX"];
    private _stateNow=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
    _stateNow set ["dragState",_drag]; _stateNow set ["pointerDragCandidate",createHashMap]; _stateNow set ["pointerDragTravel",0];
    _stateNow set ["dragHoverArea","OUTSIDE"]; _stateNow set ["dragHoverDestination",""];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_stateNow];
    [_drag] call _logStart;
    ["HIDE",controlNull,_display] call ServoPeregrino_Organizador_Items_fnc_updateUIItemTooltip;
    ["SHOW",_drag,_display,-1000,-1000,true] call ServoPeregrino_Organizador_Items_fnc_updateUIDragVisualProxy;
    [_drag] call _setDropVisuals;
    true
};
if (_eventU isEqualTo "MOVE") exitWith {
    private _stateNow=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
    private _drag=_stateNow getOrDefault ["dragState",createHashMap];
    if !(_drag getOrDefault ["active",false]) exitWith {false};
    [_drag] call _setDropVisuals;
    true
};

// Narrow legacy drop strips remain compatible; panel-wide runtime drop is handled by display MouseButtonUp.
if (_eventU isEqualTo "DROP") exitWith {
    _args params ["_target","_x","_y","_originIDC","_listboxInfo"];
    private _stateNow=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
    private _drag=_stateNow getOrDefault ["dragState",createHashMap];
    if !(_drag getOrDefault ["active",false]) exitWith {false};
    private _savedIDC=_drag getOrDefault ["sourceIDC",-1];
    if (_savedIDC isNotEqualTo _originIDC) exitWith {
        ["DROP_ORIGIN_CONTROL_CHANGED"] call ServoPeregrino_Organizador_Items_fnc_cancelUIDrag;
        ["O arraste foi cancelado porque o item de origem mudou. Tente novamente.","WARN"] call ServoPeregrino_Organizador_Items_fnc_pushUIFeedback;
        ["BLOCKED"] call ServoPeregrino_Organizador_Items_fnc_playUIFeedbackSound;
        false
    };
    private _targetIDC=ctrlIDC _target;
    private _destination=switch _targetIDC do {case 2103:{"DRAFT"}; case 4113:{"PHYSICAL"}; default {""};};
    if (_destination isEqualTo "") exitWith {["DROP_INVALID_TARGET"] call ServoPeregrino_Organizador_Items_fnc_cancelUIDrag; false};
    private _source=_drag getOrDefault ["sourceType",""];
    private _valid=(_destination isEqualTo "DRAFT" && {_source in ["CATALOG","EQUIPMENT","KIT"]}) || {_destination isEqualTo "PHYSICAL" && {_source in ["CATALOG","KIT","ENTRY"]}};
    if (!_valid) exitWith {["DROP_SOURCE_NOT_ALLOWED"] call ServoPeregrino_Organizador_Items_fnc_cancelUIDrag; false};
    private _origin=switch _source do {case "EQUIPMENT":{"DND_EQUIPMENT_TABLE"}; case "CATALOG":{if (_destination isEqualTo "PHYSICAL") then {"DND_CATALOG_TABLE_PHYSICAL"} else {"DND_CATALOG_TABLE_DRAFT"}}; case "KIT":{if (_destination isEqualTo "PHYSICAL") then {"DND_KIT_PANEL_PHYSICAL"} else {"DND_KIT_PANEL_DRAFT"}}; case "ENTRY":{"DND_DRAFT_ROW_PHYSICAL"}; default {"DND_CUSTOM"};};
    // Strip drop does not need coordinate resolution because the target control itself is authoritative.
    // D.6.2: legacy strip obeys the same authority as panel-wide drop: Equipment View (Mostrar).
    private _requestedTarget=if (_destination isEqualTo "PHYSICAL") then {_stateNow getOrDefault ["equipmentView","U"]} else {""};
    private _result=[_source,_drag getOrDefault ["sourcePayload",[]],_destination,"AUTO",player,_requestedTarget,createHashMapFromArray [["commandOrigin",_origin],["autoCreateDraftIfMissing",_destination isEqualTo "DRAFT"]]] call ServoPeregrino_Organizador_Items_fnc_executeUITransferCommand;
    private _ok=_result getOrDefault ["success",false];
    diag_log format ["[SP_ORG] [ITEMS] [DND] DROP source=%1 destination=%2 accepted=%3 code=%4 origin=%5 area=LEGACY_STRIP coord=TARGET_CONTROL",_source,_destination,_ok,_result getOrDefault ["code","UNKNOWN"],_origin];
    ["DROP_COMPLETE"] call ServoPeregrino_Organizador_Items_fnc_cancelUIDrag;
    [_result,true] call ServoPeregrino_Organizador_Items_fnc_presentUIResult;
    if (_ok) then {if (_destination isEqualTo "PHYSICAL") then {[_result] call ServoPeregrino_Organizador_Items_fnc_refreshPhysicalMutationUI;} else {["DND_TO_DRAFT"] call ServoPeregrino_Organizador_Items_fnc_refreshDraftMutationUI;};};
    _ok
};
false
