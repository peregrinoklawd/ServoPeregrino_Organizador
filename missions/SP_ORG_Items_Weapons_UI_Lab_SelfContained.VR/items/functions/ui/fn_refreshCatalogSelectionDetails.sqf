#include "..\..\script_version.hpp"
disableSerialization;
params [["_className","",[""]]];
private _display=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR,displayNull];
if (isNull _display) exitWith {false};
private _ctrl=_display displayCtrl 3130;
if (isNull _ctrl) exitWith {false};
private _categoryLabel={
    params ["_id"];
    switch (toUpper _id) do {
        case "MAGAZINES":{"Munição"}; case "GRENADES":{"Granada"}; case "EXPLOSIVES":{"Explosivo"};
        case "TOOLS":{"Ferramenta"}; case "FOOD":{"Alimento"}; case "MEDICAL":{"Médico"}; default {"Outro"};
    }
};
private _details="Selecione um item. Use o botão da esquerda para adicionar ao Kit Selecionado ou o botão da direita para adicionar ao equipamento exibido em Mostrar.";
if (_className isNotEqualTo "") then {
    private _sel=[_className] call ServoPeregrino_Organizador_Items_fnc_resolveUIItemMetadata;
    if ((count _sel)>0) then {
        private _displayName=[_sel getOrDefault ["displayName",""]] call ServoPeregrino_Organizador_Items_fnc_escapeStructuredText;
        private _category=[_sel getOrDefault ["categoryId","OTHER"]] call _categoryLabel;
        private _categorySafe=[_category] call ServoPeregrino_Organizador_Items_fnc_escapeStructuredText;
        private _massValue=_sel getOrDefault ["massEstimate",0];
        private _massLabel=if (_massValue>0) then {[_massValue,true,2] call ServoPeregrino_Organizador_Items_fnc_formatUIMass} else {"n/d"};
        private _magCapacity=_sel getOrDefault ["magazineCapacity",0];
        private _capacityLine=if (_magCapacity>0) then {format [" · Capacidade: %1",_magCapacity]} else {""};
        _details=format ["<t size='1.05' color='#CDE7E1'>%1</t><br/>%2 · Peso: %3%4<br/><t color='#8FB7B0'>Botão da esquerda: adicionar ao Kit Selecionado · Botão da direita: adicionar ao equipamento exibido em Mostrar</t>",_displayName,_categorySafe,_massLabel,_capacityLine];
    };
};
_ctrl ctrlSetStructuredText parseText _details;
true
