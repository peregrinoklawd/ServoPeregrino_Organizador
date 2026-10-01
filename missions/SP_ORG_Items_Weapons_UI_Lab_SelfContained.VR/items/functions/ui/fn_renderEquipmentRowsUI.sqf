#include "..\..\script_version.hpp"
disableSerialization;
params [
    ["_rows",[],[[]]],
    ["_view","U",[""]],
    ["_capacity",createHashMap,[createHashMap]],
    ["_contentMass",0,[0]],
    ["_unknownMassCount",0,[0]],
    ["_status","OK",[""]],
    ["_reason","EQUIPMENT_RENDER",[""]]
];
private _display=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR,displayNull];
if (isNull _display) exitWith {createHashMapFromArray [["success",false],["rowCount",0]]};
private _state=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _table=_display displayCtrl SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_EQUIPMENT_TABLE_IDC;
private _legacy=_display displayCtrl 4120;
private _oldScroll=if (isNull _table) then {[]} else {ctrlScrollValues _table};
private _selectedPayload=+(_state getOrDefault ["selectedEquipmentPayload",[]]);
private _selectedSerialized=if ((count _selectedPayload) isEqualTo 5) then {str _selectedPayload} else {""};
private _selectedRow=-1;

["HIDE",controlNull,_display] call ServoPeregrino_Organizador_Items_fnc_updateUIItemTooltip;
if (!isNull _table) then {ctClear _table;};
if (!isNull _legacy) then {lbClear _legacy;};
{
    private _row=_x;
    private _payload=[_row getOrDefault ["type","ITEM"],_row getOrDefault ["className",""],_row getOrDefault ["quantity",0],_row getOrDefault ["stateMode","NONE"],+(_row getOrDefault ["stateData",[]])];
    private _serialized=str _payload;
    private _displayName=_row getOrDefault ["displayName",_row getOrDefault ["className",""]];
    private _massSuffix=if (_row getOrDefault ["massKnown",false]) then {format [" · %1",[(_row getOrDefault ["totalMass",0]),false,2] call ServoPeregrino_Organizador_Items_fnc_formatUIMass]} else {" · peso ?"};
    private _stateSuffix=if ((_row getOrDefault ["stateMode",""]) isEqualTo "EXACT") then {format [" · %1",(_row getOrDefault ["stateData",[]]) joinString "/"]} else {if ((_row getOrDefault ["stateMode",""]) isEqualTo "DEFAULT_FULL") then {" · CHEIO"} else {""}};
    if (!isNull _table) then {
        ctAddRow _table params ["_rowIndex","_controls"];
        if ((count _controls)>=8) then {
            _controls params ["_bg","_capture","_pic","_name","_minus","_qty","_plus","_del"];
            {_x setVariable ["SPORG_Items_equipmentPayload",+_payload]; _x setVariable ["SPORG_Items_equipmentView",_view]; _x setVariable ["SPORG_Items_equipmentDisplayName",_displayName];} forEach _controls;
            _bg ctrlSetBackgroundColor [0.01,0.015,0.017,if ((_rowIndex mod 2) isEqualTo 0) then {0.12} else {0.20}];
            _capture ctrlSetText "←";
            _capture ctrlSetTooltip format ["Adicionar %1 ao Kit Selecionado sem remover do equipamento",_displayName];
            _capture ctrlAddEventHandler ["ButtonClick",{[_this#0] call ServoPeregrino_Organizador_Items_fnc_captureEquipmentRowToDraft;}];
            _pic ctrlSetText (_row getOrDefault ["picture",""]); _pic ctrlSetTextColor [1,1,1,1];
            _name ctrlSetText format ["%1%2%3",_displayName,_stateSuffix,_massSuffix];
            private _viewLabel=[_view] call ServoPeregrino_Organizador_Items_fnc_getUITargetLabel;
            private _ammoInfo=if ((_row getOrDefault ["stateMode",""]) isEqualTo "EXACT") then {format [" · Munição %1",(_row getOrDefault ["stateData",[]]) joinString "/"]} else {""};
            private _tip=format ["%1\nQuantidade: %2%3\nPeso da linha: %4\nBotão da esquerda adiciona ao Kit Selecionado; - / quantidade / + / X alteram %5.",_displayName,_row getOrDefault ["quantity",0],_ammoInfo,if (_row getOrDefault ["massKnown",false]) then {[(_row getOrDefault ["totalMass",0]),true,2] call ServoPeregrino_Organizador_Items_fnc_formatUIMass} else {"n/d"},_viewLabel];
            _pic ctrlSetTooltip _tip; _name ctrlSetTooltip _tip;
            private _tipMass=if (_row getOrDefault ["massKnown",false]) then {[(_row getOrDefault ["totalMass",0]),true,2] call ServoPeregrino_Organizador_Items_fnc_formatUIMass} else {"n/d"};
            private _tipStateLine=if (_ammoInfo isEqualTo "") then {format ["Peso da linha: %1",_tipMass]} else {format ["Munição: %1 · Peso da linha: %2",(_row getOrDefault ["stateData",[]]) joinString "/",_tipMass]};
            private _tooltipLines=[format ["%1 · Quantidade: %2",_viewLabel,_row getOrDefault ["quantity",0]],_tipStateLine,"Arraste para o Kit Selecionado ou use os controles da linha para ajustar o equipamento."];
            {
                _x setVariable ["SPORG_Items_tooltipTitle",_displayName];
                _x setVariable ["SPORG_Items_tooltipLines",+_tooltipLines];
                _x setVariable ["SPORG_Items_tooltipPicture",_row getOrDefault ["picture",""]];
                _x ctrlAddEventHandler ["MouseEnter",{["SHOW",_this#0] call ServoPeregrino_Organizador_Items_fnc_updateUIItemTooltip;}];
                _x ctrlAddEventHandler ["MouseExit",{["HIDE",_this#0] call ServoPeregrino_Organizador_Items_fnc_updateUIItemTooltip;}];
            } forEach [_pic,_name];
            _minus ctrlSetText "-"; _plus ctrlSetText "+"; _del ctrlSetText "X"; _qty ctrlSetText str (_row getOrDefault ["quantity",0]);
            _minus ctrlSetTooltip format ["Remover 1 unidade de %1 de %2",_displayName,_viewLabel];
            _plus ctrlSetTooltip (if ((_row getOrDefault ["stateMode",""]) isEqualTo "EXACT") then {format ["Adicionar 1 magazine cheio de %1 a %2; munições parciais existentes permanecem intactas",_displayName,_viewLabel]} else {format ["Adicionar 1 unidade de %1 a %2",_displayName,_viewLabel]});
            _del ctrlSetTooltip format ["Remover imediatamente toda a linha %1 x%2 de %3",_displayName,_row getOrDefault ["quantity",0],_viewLabel];
            _qty ctrlSetTooltip format ["Quantidade desejada em %1. Digite um valor e pressione Enter. O valor 0 remove a linha após confirmação. Munição parcial pode ser reduzida, mas não aumentada por digitação.",_viewLabel];
            _minus ctrlAddEventHandler ["ButtonClick",{["MINUS",_this#0,-1] call ServoPeregrino_Organizador_Items_fnc_requestEquipmentRowAction;}];
            _plus ctrlAddEventHandler ["ButtonClick",{["PLUS",_this#0,-1] call ServoPeregrino_Organizador_Items_fnc_requestEquipmentRowAction;}];
            _del ctrlAddEventHandler ["ButtonClick",{["DELETE",_this#0,-1] call ServoPeregrino_Organizador_Items_fnc_requestEquipmentRowAction;}];
            _qty ctrlAddEventHandler ["KillFocus",{[_this#0] call ServoPeregrino_Organizador_Items_fnc_commitEquipmentQuantityFromControl;}];
            _qty ctrlAddEventHandler ["KeyDown",{_this call ServoPeregrino_Organizador_Items_fnc_handleEquipmentQuantityKeyDown}];
            if (_serialized isEqualTo _selectedSerialized) then {_selectedRow=_rowIndex;};
        };
    };
    // Compatibilidade: replica payload no listbox legado invisível, sem ser a superfície visual.
    if (!isNull _legacy) then {private _li=_legacy lbAdd _displayName; _legacy lbSetData [_li,_serialized];};
} forEach _rows;
if (!isNull _table) then {
    if (_selectedRow>=0) then {_table ctSetCurSel _selectedRow;};
    if ((count _oldScroll)>=2) then {_table ctrlSetScrollValues [_oldScroll#0,_oldScroll#1];};
};

private _known=_capacity getOrDefault ["known",false];
private _current=_capacity getOrDefault ["currentLoad",0];
private _max=_capacity getOrDefault ["maxLoad",0];
private _available=_capacity getOrDefault ["availableLoad",-1];
private _ratio=if (_known && {_max>0}) then {((_current/_max) max 0) min 1} else {0};
private _barBg=_display displayCtrl 4142; private _barFill=_display displayCtrl 4143;
if (!isNull _barBg && {!isNull _barFill}) then {private _p=ctrlPosition _barBg; _barFill ctrlSetPosition [_p#0,_p#1,(_p#2)*_ratio,_p#3]; _barFill ctrlCommit 0;};
private _currentKg=(_current/22.0462262185) toFixed 2;
private _maxKg=(_max/22.0462262185) toFixed 2;
private _availableKg=(_available max 0)/22.0462262185;
private _capacityText=if (_known) then {format ["%1 / %2 kg",_currentKg,_maxKg]} else {"n/d"};
private _capacityTip=if (_known) then {format ["Usado: %1 kg de %2 kg · Livre: %3 kg · %4%%",_currentKg,_maxKg,_availableKg toFixed 2,round (_ratio*100)]} else {"Capacidade não disponível para este equipamento."};
{private _c=_display displayCtrl _x; if (!isNull _c) then {_c ctrlSetTooltip _capacityTip;};} forEach [4141,4142,4143,4144];
(_display displayCtrl 4144) ctrlSetText _capacityText;
private _massText=format ["Itens %1%2",[_contentMass,false,2] call ServoPeregrino_Organizador_Items_fnc_formatUIMass,if (_unknownMassCount>0) then {format [" + %1 peso(s) n/d",_unknownMassCount]} else {""}];
private _viewLabelStatus=[_view] call ServoPeregrino_Organizador_Items_fnc_getUITargetLabel;
(_display displayCtrl 4122) ctrlSetStructuredText parseText format ["<t color='#B9DDD5'>%1 · %2 · %3 linha(s) · %4</t><br/><t color='#D0D7D5'>Botão da esquerda = adicionar ao kit · - / quantidade / + = ajustar equipamento · X = remover linha · LIMPAR = esvaziar itens gerenciáveis</t>",_viewLabelStatus,_status,count _rows,_massText];
_state set ["equipmentRenderedRowCount",count _rows];
_state set ["lastEquipmentCapacityRatio",_ratio];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state];
createHashMapFromArray [["success",true],["rowCount",count _rows],["capacityKnown",_known],["capacityRatio",_ratio]]
