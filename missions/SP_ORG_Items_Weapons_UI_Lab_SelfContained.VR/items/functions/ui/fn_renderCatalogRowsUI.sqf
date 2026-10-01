#include "..\..\script_version.hpp"
disableSerialization;
params [
    ["_rows",[],[[]]],
    ["_selectedClass","",[""]],
    ["_reason","CATALOG_RENDER",[""]]
];

private _display=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR,displayNull];
if (isNull _display) exitWith {createHashMapFromArray [["success",false],["rowCount",0],["code","ITEMS_UI_DISPLAY_MISSING"]]};
private _state=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
private _table=_display displayCtrl SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_TABLE_IDC;
private _legacy=_display displayCtrl 3120;
private _selectedRow=-1;

["HIDE",controlNull,_display] call ServoPeregrino_Organizador_Items_fnc_updateUIItemTooltip;
if (!isNull _table) then {ctClear _table; _table ctrlShow true; _table ctrlEnable true;};
if (!isNull _legacy) then {
    _legacy ctrlShow false;
    _legacy ctrlEnable false;
    _legacy ctrlSetPosition [safeZoneX-10,safeZoneY-10,0.001,0.001];
    _legacy ctrlCommit 0;
    lbClear _legacy;
};
// C.4: 3121/3124/3123 compõem uma única barra global. O scrollbar interno da CT é transparente por config.
{private _scrollPart=_display displayCtrl _x; if (!isNull _scrollPart) then {_scrollPart ctrlShow true;};} forEach [3121,3124,3123];

private _categoryLabel={
    params ["_id"];
    switch (toUpper _id) do {
        case "MAGAZINES":{"Munição"}; case "GRENADES":{"Granada"}; case "EXPLOSIVES":{"Explosivo"};
        case "TOOLS":{"Ferramenta"}; case "FOOD":{"Alimento"}; case "MEDICAL":{"Médico"}; default {"Outro"};
    }
};

{
    private _row=_x;
    private _className=_row getOrDefault ["className",""];
    private _displayName=_row getOrDefault ["displayName",_className];
    private _category=[_row getOrDefault ["categoryId","OTHER"]] call _categoryLabel;
    private _massValue=_row getOrDefault ["massEstimate",0];
    private _massLabel=if (_massValue>0) then {[_massValue,false,2] call ServoPeregrino_Organizador_Items_fnc_formatUIMass} else {"peso n/d"};
    private _massTooltipLabel=if (_massValue>0) then {[_massValue,true,2] call ServoPeregrino_Organizador_Items_fnc_formatUIMass} else {"peso n/d"};
    private _magCapacity=_row getOrDefault ["magazineCapacity",0];
    private _capacity=if (_magCapacity>0) then {format [" · Capacidade %1",_magCapacity]} else {""};
    private _picture=_row getOrDefault ["picture",""];

    if (!isNull _table) then {
        ctAddRow _table params ["_rowIndex","_controls"];
        if ((count _controls)>=5) then {
            _controls params ["_bg","_toDraft","_pic","_name","_toPhysical"];
            {
                _x setVariable ["SPORG_Items_catalogClass",_className];
                _x setVariable ["SPORG_Items_catalogDisplayName",_displayName];
                _x setVariable ["SPORG_Items_catalogRowIndex",_rowIndex];
            } forEach _controls;
            _bg ctrlSetBackgroundColor [0.01,0.015,0.017,if ((_rowIndex mod 2) isEqualTo 0) then {0.12} else {0.20}];

            _toDraft ctrlSetText "←";
            _toDraft ctrlSetTooltip format ["Adicionar 1x %1 ao Kit Selecionado",_displayName];
            _toDraft ctrlAddEventHandler ["ButtonClick",{["CATALOG_ROW_BUTTON",[_this#0,"DRAFT"]] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent;}];

            _pic ctrlSetText _picture;
            _pic ctrlSetTextColor [1,1,1,1];
            _name ctrlSetText format ["%1  ·  %2",_displayName,_massLabel];
            private _tip=format ["%1\n%2 · Peso %3%4\nBotão da esquerda: adicionar ao Kit Selecionado. Botão da direita: adicionar ao equipamento exibido em Mostrar.",_displayName,_category,_massTooltipLabel,_capacity];
            _pic ctrlSetTooltip _tip;
            _name ctrlSetTooltip _tip;
            private _tooltipLines=[format ["Categoria: %1",_category],format ["Peso: %1%2",_massTooltipLabel,_capacity],"Arraste o item para o Kit Selecionado ou para o equipamento."];
            {
                _x setVariable ["SPORG_Items_tooltipTitle",_displayName];
                _x setVariable ["SPORG_Items_tooltipLines",+_tooltipLines];
                _x setVariable ["SPORG_Items_tooltipPicture",_picture];
                _x ctrlAddEventHandler ["MouseEnter",{["SHOW",_this#0] call ServoPeregrino_Organizador_Items_fnc_updateUIItemTooltip;}];
                _x ctrlAddEventHandler ["MouseExit",{["HIDE",_this#0] call ServoPeregrino_Organizador_Items_fnc_updateUIItemTooltip;}];
            } forEach [_pic,_name];
            _pic ctrlAddEventHandler ["MouseButtonClick",{["CATALOG_ROW_SELECT",_this#0] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent;}];
            _name ctrlAddEventHandler ["MouseButtonClick",{["CATALOG_ROW_SELECT",_this#0] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent;}];

            _toPhysical ctrlSetText "→";
            _toPhysical ctrlSetTooltip format ["Adicionar 1x %1 ao equipamento exibido em Mostrar",_displayName];
            _toPhysical ctrlAddEventHandler ["ButtonClick",{["CATALOG_ROW_BUTTON",[_this#0,"PHYSICAL"]] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent;}];

            if (_className isEqualTo _selectedClass) then {_selectedRow=_rowIndex;};
        };
    };

    // Compatibilidade invisível: os gates históricos continuam observando o ListBox 3120.
    if (!isNull _legacy) then {
        private _i=_legacy lbAdd format ["←   %1  ·  %2",_displayName,_massLabel];
        _legacy lbSetData [_i,_className];
        _legacy lbSetTooltip [_i,format ["%1\n%2 · Peso %3%4\nBotão da esquerda: adicionar ao Kit Selecionado. Botão da direita: adicionar ao equipamento exibido em Mostrar.",_displayName,_category,_massTooltipLabel,_capacity]];
        _legacy lbSetTextRight [_i,"→"];
        _legacy lbSetColorRight [_i,[0.65,0.93,0.85,1]];
        _legacy lbSetSelectColorRight [_i,[1,1,1,1]];
        if (_picture isNotEqualTo "") then {_legacy lbSetPicture [_i,_picture]; _legacy lbSetPictureColor [_i,[1,1,1,1]]; _legacy lbSetPictureColorSelected [_i,[1,1,1,1]];};
        if (_className isEqualTo _selectedClass) then {_legacy lbSetCurSel _i;};
    };
} forEach _rows;

if (!isNull _table && {_selectedRow>=0}) then {_table ctSetCurSel _selectedRow;};
_state set ["catalogRenderedRowCount",count _rows];
_state set ["catalogVisibleSurface","CT_CONTROLS_TABLE"];
_state set ["catalogLegacyListHidden",true];
_state set ["catalogLegacyListDisabled",true];
_state set ["catalogSingleVisibleScrollbar",true];
_state set ["catalogInternalTableScrollbarHidden",true];
_state set ["lastCatalogRenderReason",toUpper _reason];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state];

createHashMapFromArray [["success",true],["rowCount",count _rows],["selectedRow",_selectedRow],["visibleTableIDC",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_TABLE_IDC],["legacyListIDC",3120]]
