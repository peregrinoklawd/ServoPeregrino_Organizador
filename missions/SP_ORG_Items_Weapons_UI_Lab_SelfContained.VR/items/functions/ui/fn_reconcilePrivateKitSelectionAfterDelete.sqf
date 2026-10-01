#include "..\..\script_version.hpp"
disableSerialization;
params [
    ["_preferredIndex",-1,[0]],
    ["_display",displayNull,[displayNull]]
];

if (isNull _display) then {
    _display=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR,displayNull];
};
if (isNull _display) exitWith {
    [false,"ITEMS_UI_KIT_SELECTION_RECONCILE_NO_DISPLAY","Não foi possível sincronizar a seleção de kits porque a interface não está aberta.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _state=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
if ((count _state) isEqualTo 0) then {_state=[] call ServoPeregrino_Organizador_Items_fnc_createUIState;};
if !((toUpper (_state getOrDefault ["kitLibraryMode","PRIVATE"])) isEqualTo "PRIVATE") exitWith {
    [false,"ITEMS_UI_KIT_SELECTION_RECONCILE_NOT_PRIVATE","A reconciliação automática após exclusão só é usada na biblioteca privada.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _kitsCtrl=_display displayCtrl 1102;
if (isNull _kitsCtrl) exitWith {
    [false,"ITEMS_UI_KIT_SELECTION_RECONCILE_NO_LIST","A lista de kits privados não está disponível.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _size=lbSize _kitsCtrl;
private _selectedIndex=-1;
private _selectedId="";

// O highlight visual do ListBox pode migrar automaticamente após um lbDelete/lbClear. Durante esta
// sincronização bloqueamos KIT_SELECT para não abrir outro kit e, principalmente, para não destruir o
// Rascunho NEW preservado pela exclusão do backing kit.
_state set ["refreshing",true];
if (_size>0) then {
    _selectedIndex=((_preferredIndex max 0) min (_size-1));
    _selectedId=_kitsCtrl lbData _selectedIndex;
    _state set ["selectedKitId",_selectedId];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state];
    if ((lbCurSel _kitsCtrl) isNotEqualTo _selectedIndex) then {_kitsCtrl lbSetCurSel _selectedIndex;};
} else {
    _state set ["selectedKitId",""];
};

private _publishCtrl=_display displayCtrl 1113;
if (!isNull _publishCtrl) then {_publishCtrl ctrlEnable (_selectedId isNotEqualTo "");};
_state set ["refreshing",false];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state];

diag_log format ["[SP_ORG] [ITEMS] [KIT_LIBRARY_SELECTION] reconciled=true preferredIndex=%1 selectedIndex=%2 selectedKitId=%3 visibleCount=%4",_preferredIndex,_selectedIndex,_selectedId,_size];
[true,"ITEMS_UI_KIT_SELECTION_RECONCILED","Seleção da biblioteca privada sincronizada após exclusão.",createHashMapFromArray [["selectedIndex",_selectedIndex],["selectedKitId",_selectedId],["visibleCount",_size]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
