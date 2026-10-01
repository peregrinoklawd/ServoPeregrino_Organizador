#include "..\..\script_version.hpp"
disableSerialization;
params [["_reason","CATALOG_FOCUSED",[""]]];

private _startedAt=diag_tickTime;
private _display=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR,displayNull];
if (isNull _display) exitWith {false};
private _state=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
if ((count _state) isEqualTo 0) then {_state=[] call ServoPeregrino_Organizador_Items_fnc_createUIState;};
_state set ["refreshing",true];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state];

private _windowR=[
    _state getOrDefault ["catalogQuery",""],
    _state getOrDefault ["catalogCategory","ALL"],
    _state getOrDefault ["catalogOffset",0],
    _state getOrDefault ["catalogWindowSize",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_WINDOW_SIZE]
] call ServoPeregrino_Organizador_Items_fnc_getUICatalogWindow;
if !(_windowR getOrDefault ["success",false]) exitWith {
    _state=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
    _state set ["refreshing",false];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state];
    false
};
private _data=_windowR getOrDefault ["data",createHashMap];
private _offset=_data getOrDefault ["offset",0];
private _total=_data getOrDefault ["totalFiltered",0];
private _windowSize=_data getOrDefault ["windowSize",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_WINDOW_SIZE];
private _maxOffset=(_total-_windowSize) max 0;
private _ratio=if (_maxOffset>0) then {(_offset/_maxOffset) max 0 min 1} else {0};
_state set ["catalogOffset",_offset];
_state set ["catalogTotalFiltered",_total];
_state set ["catalogMaxOffset",_maxOffset];
_state set ["catalogScrollRatio",_ratio];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state];

private _categoryLabel={
    params ["_id"];
    switch (toUpper _id) do {
        case "MAGAZINES":{"Munição"}; case "GRENADES":{"Granada"}; case "EXPLOSIVES":{"Explosivo"};
        case "TOOLS":{"Ferramenta"}; case "FOOD":{"Alimento"}; case "MEDICAL":{"Médico"}; default {"Outro"};
    }
};
private _renderStartedAt=diag_tickTime;
private _oldSelectedClass=_state getOrDefault ["selectedCatalogClass",""];
private _catalogRows=_data getOrDefault ["rows",[]];
[_catalogRows,_oldSelectedClass,_reason] call ServoPeregrino_Organizador_Items_fnc_renderCatalogRowsUI;

private _last=(_offset+count (_data getOrDefault ["rows",[]])) min _total;
(_display displayCtrl 3122) ctrlSetText (if (_total isEqualTo 0) then {"Nenhum item encontrado"} else {if (_total isEqualTo 1) then {"Mostrando 1 item"} else {format ["Mostrando %1 a %2 de %3 itens",_offset+1,_last,_total]}});
private _slider=_display displayCtrl 3124;
if (!isNull _slider) then {
    _slider sliderSetRange [0,(_maxOffset max 1)];
    _slider sliderSetSpeed [6,(_windowSize max 12)];
    _slider sliderSetPosition _offset;
    _slider ctrlEnable (_maxOffset>0);
    _slider ctrlShow true;
};
private _scrollUp=_display displayCtrl 3121; if (!isNull _scrollUp) then {_scrollUp ctrlShow true; _scrollUp ctrlEnable (_offset>0);};
private _scrollDown=_display displayCtrl 3123; if (!isNull _scrollDown) then {_scrollDown ctrlShow true; _scrollDown ctrlEnable (_offset<_maxOffset);};

private _sel=createHashMap;
if (_oldSelectedClass isNotEqualTo "") then {_sel=[_oldSelectedClass] call ServoPeregrino_Organizador_Items_fnc_resolveUIItemMetadata;};
private _details="Selecione um item. O botão da esquerda adiciona ao Kit Selecionado; o botão da direita adiciona ao equipamento exibido em Mostrar.";
if ((count _sel)>0) then {
    private _displayNameSafe=[_sel getOrDefault ["displayName",""]] call ServoPeregrino_Organizador_Items_fnc_escapeStructuredText;
    private _category=[_sel getOrDefault ["categoryId","OTHER"]] call _categoryLabel;
    private _categorySafe=[_category] call ServoPeregrino_Organizador_Items_fnc_escapeStructuredText;
    private _massValue=_sel getOrDefault ["massEstimate",0];
    private _massLabel=if (_massValue>0) then {[_massValue,true,2] call ServoPeregrino_Organizador_Items_fnc_formatUIMass} else {"n/d"};
    private _magCapacity=_sel getOrDefault ["magazineCapacity",0];
    private _capacityLine=if (_magCapacity>0) then {format [" · Capacidade: %1",_magCapacity]} else {""};
    _details=format ["<t size='1.05' color='#CDE7E1'>%1</t><br/>%2 · Peso: %3%4<br/><t color='#8FB7B0'>Botão da esquerda: Kit Selecionado · Botão da direita: equipamento exibido em Mostrar</t>",_displayNameSafe,_categorySafe,_massLabel,_capacityLine];
};
(_display displayCtrl 3130) ctrlSetStructuredText parseText _details;
private _searchCtrl=_display displayCtrl 3100;
if ((ctrlText _searchCtrl) isNotEqualTo (_state getOrDefault ["catalogQuery",""])) then {_searchCtrl ctrlSetText (_state getOrDefault ["catalogQuery",""]);};

private _catMap=[[3110,"ALL"],[3111,"MAGAZINES"],[3112,"GRENADES"],[3113,"EXPLOSIVES"],[3114,"TOOLS"],[3115,"FOOD"],[3116,"MEDICAL"],[3117,"OTHER"]];
{private _ctrl=_display displayCtrl (_x#0); _ctrl ctrlSetBackgroundColor (if ((_x#1) isEqualTo (_state getOrDefault ["catalogCategory","ALL"])) then {[0.08,0.38,0.30,0.76]} else {[0.08,0.11,0.12,0.58]});} forEach _catMap;

private _context=format ["catálogo contínuo | categoria: %1 | busca: %2 | %3/%4 | offset %5/%6 | destino: %7 | view: %8",_state getOrDefault ["catalogCategory","ALL"],if ((_state getOrDefault ["catalogQuery",""]) isEqualTo "") then {"-"} else {_state getOrDefault ["catalogQuery",""]},_total,_data getOrDefault ["baseCount",0],_offset,_maxOffset,_state getOrDefault ["applicationTarget","ANY"],_state getOrDefault ["equipmentView","U"]];
private _contextSafe=[_context] call ServoPeregrino_Organizador_Items_fnc_escapeStructuredText;
private _messageSafe=[_state getOrDefault ["temporaryMessage",""]] call ServoPeregrino_Organizador_Items_fnc_escapeStructuredText;
private _feedbackPalette=[_state getOrDefault ["lastFeedbackKind","INFO"]] call ServoPeregrino_Organizador_Items_fnc_getUIFeedbackPalette;
(_display displayCtrl 5000) ctrlSetStructuredText parseText format ["<t color='#6FCBB8'>CONTEXTO</t><t color='#A8C9C2'>  •  %1</t>",_contextSafe];
(_display displayCtrl 5001) ctrlSetStructuredText parseText format ["<t color='%1'>RESULTADO</t><t color='%2'>  •  %3</t>",_feedbackPalette getOrDefault ["labelColor","#7EC8FF"],_feedbackPalette getOrDefault ["messageColor","#D7EEFF"],_messageSafe];
private _hist=_state getOrDefault ["history",[]]; private _histText="";
{private _entry=_x; _histText=_histText+(if (_histText isEqualTo "") then {""} else {"  |  "})+format ["%1: %2",_entry#0,_entry#1];} forEach (_hist select [((count _hist)-3) max 0,(3 min (count _hist))]);
private _histSafe=[_histText] call ServoPeregrino_Organizador_Items_fnc_escapeStructuredText;
(_display displayCtrl 5002) ctrlSetStructuredText parseText format ["<t color='#81918E'>HISTÓRICO  •  %1</t>",_histSafe];
private _renderMs=round ((diag_tickTime-_renderStartedAt)*1000);
private _totalMs=round ((diag_tickTime-_startedAt)*1000);

_state=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
_state set ["catalogOffset",_offset];
_state set ["catalogTotalFiltered",_total];
_state set ["catalogMaxOffset",_maxOffset];
_state set ["catalogScrollRatio",_ratio];
_state set ["lastRefreshTick",diag_tickTime];
_state set ["lastRefreshMode","CATALOG_FOCUSED"];
_state set ["catalogFocusedRefreshCount",(_state getOrDefault ["catalogFocusedRefreshCount",0])+1];
_state set ["lastCatalogFocusedRefreshDurationMs",_totalMs];
_state set ["lastCatalogFocusedFilterDurationMs",_data getOrDefault ["filterMs",0]];
_state set ["lastCatalogProjectionBuildDurationMs",_data getOrDefault ["projectionBuildMs",0]];
_state set ["catalogProjectionBuildCount",_data getOrDefault ["projectionBuildCount",0]];
private _perf=+(_state getOrDefault ["uiPerfHistory",[]]);
_perf pushBack ["CATALOG_FOCUSED",toUpper _reason,_totalMs,_data getOrDefault ["filterMs",0],_renderMs,diag_tickTime];
while {(count _perf)>24} do {_perf deleteAt 0;};
_state set ["uiPerfHistory",_perf];
_state set ["refreshing",false];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state];
if (_state getOrDefault ["uiPerfTracing",true]) then {
    diag_log format ["[SP_ORG] [ITEMS] [UI_PERF] mode=CATALOG_FOCUSED reason=%1 totalMs=%2 projectionBuildMs=%3 filterMs=%4 renderMs=%5 base=%6 categoryBase=%7 matched=%8 offset=%9 maxOffset=%10 windowRows=%11 fullRefresh=false equipmentRecapture=false",toUpper _reason,_totalMs,_data getOrDefault ["projectionBuildMs",0],_data getOrDefault ["filterMs",0],_renderMs,_data getOrDefault ["baseCount",0],_data getOrDefault ["categoryBaseCount",0],_total,_offset,_maxOffset,count (_data getOrDefault ["rows",[]])];
};
true
