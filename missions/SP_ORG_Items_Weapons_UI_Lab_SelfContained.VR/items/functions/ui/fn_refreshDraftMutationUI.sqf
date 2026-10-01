#include "..\..\script_version.hpp"
disableSerialization;
params [
    ["_reason","DRAFT_MUTATION",[""]],
    ["_options",createHashMap,[createHashMap]]
];
private _startedAt=diag_tickTime;
private _display=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR,displayNull];
if (isNull _display) exitWith {false};

private _state=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
if ((count _state) isEqualTo 0) then {_state=[] call ServoPeregrino_Organizador_Items_fnc_createUIState;};
_state set ["refreshing",true];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state];

private _draftR=[] call ServoPeregrino_Organizador_Items_fnc_getDraftState;
private _draftData=_draftR getOrDefault ["data",createHashMap];
private _hasDraft=_draftData getOrDefault ["hasDraft",false];
private _draft=_draftData getOrDefault ["current",createHashMap];
private _dirty=_draft getOrDefault ["dirty",false];
private _needle=toLower (_state getOrDefault ["draftQuery",""]);
private _rows=[];
private _draftTotalMass=0;
private _draftUnknownMassCount=0;
if (_hasDraft) then {
    {
        private _entry=_x;
        if (_entry isEqualType [] && {(count _entry) isEqualTo 6}) then {
            private _meta=[_entry#2] call ServoPeregrino_Organizador_Items_fnc_resolveUIItemMetadata;
            private _displayName=_meta getOrDefault ["displayName",_entry#2];
            private _aware=[_entry,_meta] call ServoPeregrino_Organizador_Items_fnc_getUIEntryAwareness;
            if (_aware getOrDefault ["known",false]) then {_draftTotalMass=_draftTotalMass+(_aware getOrDefault ["totalMass",0]);} else {_draftUnknownMassCount=_draftUnknownMassCount+1;};
            private _hay=toLower format ["%1 %2",_entry#2,_displayName];
            if (_needle isEqualTo "" || {_hay find _needle >= 0}) then {
                _rows pushBack createHashMapFromArray [
                    ["entry",+_entry],["type",_entry#1],["className",_entry#2],["quantity",_entry#3],["stateMode",_entry#4],["stateData",+(_entry#5)],
                    ["displayName",_displayName],["picture",_meta getOrDefault ["picture",""]],["available",_meta getOrDefault ["available",false]],
                    ["massKnown",_aware getOrDefault ["known",false]],["unitMass",_aware getOrDefault ["unitMass",0]],["totalMass",_aware getOrDefault ["totalMass",0]]
                ];
            };
        };
    } forEach (_draft getOrDefault ["entries",[]]);
};

private _nameCtrl=_display displayCtrl 2100;
_nameCtrl ctrlEnable _hasDraft;
if ((ctrlText _nameCtrl) isNotEqualTo (_draft getOrDefault ["name",""])) then {_nameCtrl ctrlSetText (_draft getOrDefault ["name",""]);};
(_display displayCtrl 2001) ctrlSetText (if !_hasDraft then {"SEM KIT"} else {if (_dirty) then {"ALTERADO"} else {"SALVO"}});
(_display displayCtrl 2001) ctrlSetTextColor (if !_hasDraft then {[0.55,0.60,0.60,1]} else {if (_dirty) then {[0.96,0.72,0.25,1]} else {[0.45,0.85,0.68,1]}});

private _draftCtrl=_display displayCtrl SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DRAFT_TABLE_IDC;
private _oldScroll=ctrlScrollValues _draftCtrl;
private _selectedKey=_state getOrDefault ["selectedDraftRowKey",[]];
private _selectedIndex=-1;
["HIDE",controlNull,_display] call ServoPeregrino_Organizador_Items_fnc_updateUIItemTooltip;
ctClear _draftCtrl;
{
    private _row=_x;
    private _key=[_row getOrDefault ["type","ITEM"],_row getOrDefault ["className",""],_row getOrDefault ["stateMode","NONE"]];
    ctAddRow _draftCtrl params ["_rowIndex","_controls"];
    if ((count _controls)>=7) then {
        _controls params ["_bg","_pic","_name","_minus","_qty","_plus","_del"];
        {_x setVariable ["SPORG_Items_rowKey",+_key];} forEach _controls;
        private _dragEntry=+(_row getOrDefault ["entry",[]]);
        if ((count _dragEntry) isNotEqualTo 6) then {private _er=[_row getOrDefault ["type","ITEM"],_row getOrDefault ["className",""],_row getOrDefault ["quantity",0],_row getOrDefault ["stateMode","NONE"],+(_row getOrDefault ["stateData",[]])] call ServoPeregrino_Organizador_Items_fnc_createItemEntry; if (_er getOrDefault ["success",false]) then {_dragEntry=+(((_er getOrDefault ["data",createHashMap]) getOrDefault ["entry",[]]));};};
        private _dragDisplayName=_row getOrDefault ["displayName",_row getOrDefault ["className",""]];
        {_x setVariable ["SPORG_Items_draftEntry",+_dragEntry]; _x setVariable ["SPORG_Items_draftDisplayName",_dragDisplayName];} forEach [_pic,_name];
        _bg ctrlSetBackgroundColor [0.01,0.015,0.017,if ((_rowIndex mod 2) isEqualTo 0) then {0.12} else {0.20}];
        _pic ctrlSetText (_row getOrDefault ["picture",""]);
        _pic ctrlSetTextColor [1,1,1,1];
        _pic ctrlSetTooltip format ["%1\n%2",_row getOrDefault ["displayName",_row getOrDefault ["className",""]],_row getOrDefault ["className",""]];
        private _suffix=if ((_row getOrDefault ["stateMode",""]) isEqualTo "EXACT") then {format [" · EXACT %1",_row getOrDefault ["stateData",[]]]} else {if ((_row getOrDefault ["stateMode",""]) isEqualTo "DEFAULT_FULL") then {" · CHEIO"} else {""}};
        private _massSuffix=if (_row getOrDefault ["massKnown",false]) then {format [" · %1",[(_row getOrDefault ["totalMass",0]),false,2] call ServoPeregrino_Organizador_Items_fnc_formatUIMass]} else {" · peso ?"};
        _name ctrlSetText format ["%1%2%3",_row getOrDefault ["displayName",_row getOrDefault ["className",""]],_suffix,_massSuffix];
        _name ctrlSetTooltip format ["%1\nClasse: %2\nTipo: %3 · Estado: %4 · Quantidade: %5\nPeso unitário: %6 · Peso da linha: %7",_row getOrDefault ["displayName",_row getOrDefault ["className",""]],_row getOrDefault ["className",""],_row getOrDefault ["type","ITEM"],_row getOrDefault ["stateMode","NONE"],_row getOrDefault ["quantity",0],[(_row getOrDefault ["unitMass",0]),true,2] call ServoPeregrino_Organizador_Items_fnc_formatUIMass,[(_row getOrDefault ["totalMass",0]),true,2] call ServoPeregrino_Organizador_Items_fnc_formatUIMass];
        private _draftStateMode=_row getOrDefault ["stateMode","NONE"];
        private _draftStateText=if (_draftStateMode isEqualTo "EXACT") then {format [" · Munição: %1",(_row getOrDefault ["stateData",[]]) joinString "/"]} else {if (_draftStateMode isEqualTo "DEFAULT_FULL") then {" · Estado: cheio"} else {""}};
        private _draftMassText=if (_row getOrDefault ["massKnown",false]) then {format ["Peso: %1 por unidade · %2 nesta linha",[(_row getOrDefault ["unitMass",0]),true,2] call ServoPeregrino_Organizador_Items_fnc_formatUIMass,[(_row getOrDefault ["totalMass",0]),true,2] call ServoPeregrino_Organizador_Items_fnc_formatUIMass]} else {"Peso: não disponível"};
        private _draftTipLines=[format ["Quantidade no kit: %1%2",_row getOrDefault ["quantity",0],_draftStateText],_draftMassText,"Arraste para o equipamento ou use - / quantidade / + / X para editar o kit."];
        {
            _x setVariable ["SPORG_Items_tooltipTitle",_dragDisplayName];
            _x setVariable ["SPORG_Items_tooltipLines",+_draftTipLines];
            _x setVariable ["SPORG_Items_tooltipPicture",_row getOrDefault ["picture",""]];
            _x ctrlAddEventHandler ["MouseEnter",{["SHOW",_this#0] call ServoPeregrino_Organizador_Items_fnc_updateUIItemTooltip;}];
            _x ctrlAddEventHandler ["MouseExit",{["HIDE",_this#0] call ServoPeregrino_Organizador_Items_fnc_updateUIItemTooltip;}];
        } forEach [_pic,_name];
        _minus ctrlSetText "-"; _plus ctrlSetText "+"; _del ctrlSetText "X"; _qty ctrlSetText str (_row getOrDefault ["quantity",0]);
        _minus ctrlSetTooltip "Reduzir uma unidade";
        _plus ctrlSetTooltip (if ((_row getOrDefault ["stateMode",""]) isEqualTo "EXACT") then {"EXACT permanece; + cria/incrementa DEFAULT_FULL separado"} else {"Adicionar uma unidade"});
        _del ctrlSetTooltip "Remover este item do kit";
        _qty ctrlSetTooltip "Quantidade direta; 0 remove; EXACT não pode crescer por digitação";
        _minus ctrlAddEventHandler ["ButtonClick",{private _r=["MINUS",_this#0] call ServoPeregrino_Organizador_Items_fnc_handleDraftRowAction; [_r,"REMOVE",true] call ServoPeregrino_Organizador_Items_fnc_presentLogicalMutationResult; ["ROW_MINUS"] call ServoPeregrino_Organizador_Items_fnc_refreshDraftMutationUI;}];
        _plus ctrlAddEventHandler ["ButtonClick",{private _r=["PLUS",_this#0] call ServoPeregrino_Organizador_Items_fnc_handleDraftRowAction; [_r,"ADD",true] call ServoPeregrino_Organizador_Items_fnc_presentLogicalMutationResult; ["ROW_PLUS"] call ServoPeregrino_Organizador_Items_fnc_refreshDraftMutationUI;}];
        _del ctrlAddEventHandler ["ButtonClick",{private _r=["DELETE",_this#0] call ServoPeregrino_Organizador_Items_fnc_handleDraftRowAction; [_r,"REMOVE",true] call ServoPeregrino_Organizador_Items_fnc_presentLogicalMutationResult; ["ROW_DELETE"] call ServoPeregrino_Organizador_Items_fnc_refreshDraftMutationUI;}];
        _qty ctrlAddEventHandler ["KillFocus",{[_this#0] call ServoPeregrino_Organizador_Items_fnc_commitDraftQuantityFromControl;}];
        _qty ctrlAddEventHandler ["KeyDown",{_this call ServoPeregrino_Organizador_Items_fnc_handleDraftQuantityKeyDown}];
        _pic ctrlAddEventHandler ["MouseButtonDown",{["DRAFT_ROW_DRAG_START",_this] call ServoPeregrino_Organizador_Items_fnc_handleUIDragEvent;}];
        _name ctrlAddEventHandler ["MouseButtonDown",{["DRAFT_ROW_DRAG_START",_this] call ServoPeregrino_Organizador_Items_fnc_handleUIDragEvent;}];
        if (_key isEqualTo _selectedKey) then {_selectedIndex=_rowIndex;};
    };
} forEach _rows;
if (_selectedIndex>=0) then {_draftCtrl ctSetCurSel _selectedIndex;};
if ((count _oldScroll)>=2) then {_draftCtrl ctrlSetScrollValues [_oldScroll#0,-1];};

(_display displayCtrl 2120) ctrlSetStructuredText parseText format ["<t color='#8FB7B0'>%1 · %2 item(ns) · peso %3%4</t><br/><t color='#8A9696'>Use - / quantidade / + / X para editar o kit. Use os botões abaixo para adicionar, remover ou substituir itens no equipamento.</t>",_draft getOrDefault ["mode","NONE"],count _rows,[_draftTotalMass,false,2] call ServoPeregrino_Organizador_Items_fnc_formatUIMass,if (_draftUnknownMassCount>0) then {format [" + %1 peso(s) n/d",_draftUnknownMassCount]} else {""}];
{(_display displayCtrl _x) ctrlEnable _hasDraft;} forEach [2140,2141,2142];

// Atualiza apenas feedback/contexto. Catálogo, kits e Equipment permanecem intocados.
_state=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _physicalTarget=_state getOrDefault ["resolvedPhysicalTarget","-"];
private _context=format ["Kit: %1  •  Adicionar em: %2  •  Mostrando: %3",if (_hasDraft) then {_draft getOrDefault ["name","Kit Selecionado"]} else {"nenhum"},[_physicalTarget] call ServoPeregrino_Organizador_Items_fnc_getUITargetLabel,[_state getOrDefault ["equipmentView","U"]] call ServoPeregrino_Organizador_Items_fnc_getUITargetLabel];
private _contextSafe=[_context] call ServoPeregrino_Organizador_Items_fnc_escapeStructuredText;
private _messageSafe=[_state getOrDefault ["temporaryMessage",""]] call ServoPeregrino_Organizador_Items_fnc_escapeStructuredText;
private _feedbackPalette=[_state getOrDefault ["lastFeedbackKind","INFO"]] call ServoPeregrino_Organizador_Items_fnc_getUIFeedbackPalette;
(_display displayCtrl 5000) ctrlSetStructuredText parseText format ["<t color='#6FCBB8'>CONTEXTO</t><t color='#A8C9C2'>  •  %1</t>",_contextSafe];
(_display displayCtrl 5001) ctrlSetStructuredText parseText format ["<t color='%1'>RESULTADO</t><t color='%2'>  •  %3</t>",_feedbackPalette getOrDefault ["labelColor","#7EC8FF"],_feedbackPalette getOrDefault ["messageColor","#D7EEFF"],_messageSafe];
private _hist=_state getOrDefault ["history",[]];
private _histText="";
{private _entry=_x; _histText=_histText + (if (_histText isEqualTo "") then {""} else {"  |  "}) + format ["%1: %2",_entry#0,_entry#1];} forEach (_hist select [((count _hist)-3) max 0,(3 min (count _hist))]);
private _histSafe=[_histText] call ServoPeregrino_Organizador_Items_fnc_escapeStructuredText;
(_display displayCtrl 5002) ctrlSetStructuredText parseText format ["<t color='#81918E'>HISTÓRICO  •  %1</t>",_histSafe];

private _durationMs=round ((diag_tickTime-_startedAt)*1000);
_state=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
_state set ["lastRefreshTick",diag_tickTime];
_state set ["lastRefreshMode","DRAFT_FOCUSED"];
_state set ["draftFocusedRefreshCount",(_state getOrDefault ["draftFocusedRefreshCount",0])+1];
_state set ["lastDraftFocusedRefreshDurationMs",_durationMs];
_state set ["lastDraftFocusedRefreshReason",toUpper _reason];
_state set ["lastDraftTotalMass",_draftTotalMass];
_state set ["lastDraftUnknownMassCount",_draftUnknownMassCount];
private _perf=+(_state getOrDefault ["uiPerfHistory",[]]);
_perf pushBack ["DRAFT_FOCUSED",toUpper _reason,_durationMs,count _rows,diag_tickTime];
while {(count _perf)>24} do {_perf deleteAt 0;};
_state set ["uiPerfHistory",_perf];
_state set ["refreshing",false];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state];
if (_state getOrDefault ["uiPerfTracing",true]) then {
    diag_log format ["[SP_ORG] [ITEMS] [UI_PERF] mode=DRAFT_FOCUSED reason=%1 durationMs=%2 draftRows=%3 catalogTouched=false equipmentRecapture=false repositoryWrite=false",toUpper _reason,_durationMs,count _rows];
};
true
