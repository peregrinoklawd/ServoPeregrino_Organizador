#include "..\..\script_version.hpp"
disableSerialization;
params ["_displayOrControl",["_scroll",0,[0]]];
private _display=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR,displayNull];
if (isNull _display) exitWith {false};

// O display consome o wheel para impedir que PrevAction/NextAction do gameplay recebam o gesto.
// No Catálogo 0.12-C, o wheel move o offset global da lista contínua virtualizada; nos demais
// painéis continua ajustando somente o scrollbar local. Nenhum handler global é instalado.
getMousePosition params ["_mx","_my"];
private _hovered=controlNull;
{
    private _c=_display displayCtrl _x;
    if (!isNull _c) then {
        private _p=ctrlPosition _c;
        if (_mx>=(_p#0) && {_mx<=((_p#0)+(_p#2))} && {_my>=(_p#1)} && {_my<=((_p#1)+(_p#3))}) exitWith {_hovered=_c;};
    };
} forEach [1102,2104,SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_TABLE_IDC,4140,4120];

private _manuallyScrolled=false;
private _hoverIDC=-1;
if (!isNull _hovered && {_scroll isNotEqualTo 0}) then {
    _hoverIDC=ctrlIDC _hovered;
    if (_hoverIDC isEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CATALOG_TABLE_IDC) then {
        private _delta=if (_scroll>0) then {-6} else {6};
        ["CATALOG_SCROLL",_delta] call ServoPeregrino_Organizador_Items_fnc_handleUIEvent;
        _manuallyScrolled=true;
    } else {
        private _sv=ctrlScrollValues _hovered;
        if ((count _sv)>=2) then {
            private _step=0.075;
            private _next=((_sv#0)+(if (_scroll>0) then {-_step} else {_step})) max 0 min 1;
            _hovered ctrlSetScrollValues [_next,-1];
            _manuallyScrolled=true;
        };
    };
};
private _state=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
if ((count _state)>0) then {
    _state set ["wheelConsumeCount",(_state getOrDefault ["wheelConsumeCount",0])+1];
    if (_manuallyScrolled) then {_state set ["wheelManualScrollCount",(_state getOrDefault ["wheelManualScrollCount",0])+1];};
    _state set ["lastWheelScrollIDC",_hoverIDC];
    _state set ["lastWheelTick",diag_tickTime];
    missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state];
};
true
