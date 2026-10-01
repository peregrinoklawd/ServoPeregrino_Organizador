#include "..\..\script_version.hpp"
disableSerialization;
params [["_display",displayNull,[displayNull]]];
uiNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR,_display];
["HIDE",createHashMap,_display,-1000,-1000,false] call ServoPeregrino_Organizador_Items_fnc_updateUIDragVisualProxy;
["HIDE",controlNull,_display] call ServoPeregrino_Organizador_Items_fnc_updateUIItemTooltip;
// C.4: o ListBox histórico continua existindo para a suíte, mas jamais pode renderizar/capturar mouse no jogador.
private _legacyCatalog=_display displayCtrl 3120;
if (!isNull _legacyCatalog) then {
    _legacyCatalog ctrlShow false;
    _legacyCatalog ctrlEnable false;
    _legacyCatalog ctrlSetPosition [safeZoneX-10,safeZoneY-10,0.001,0.001];
    _legacyCatalog ctrlCommit 0;
};
// A navegação visível é uma única barra integrada 3121 + 3124 + 3123.
{private _scrollCtrl=_display displayCtrl _x; if (!isNull _scrollCtrl) then {_scrollCtrl ctrlShow true;};} forEach [3121,3124,3123];
private _state=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap]; if ((count _state) isEqualTo 0) then {_state=[] call ServoPeregrino_Organizador_Items_fnc_createUIState;};
_state set ["open",true]; _state set ["openedAtTick",diag_tickTime]; missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state];
["Organizador aberto. Arraste o nome ou ícone de um item e solte em qualquer área compatível do Kit Selecionado ou Conteúdo do Equipamento.","INFO"] call ServoPeregrino_Organizador_Items_fnc_pushUIFeedback;
[] call ServoPeregrino_Organizador_Items_fnc_refreshInterface;
private _status=[] call ServoPeregrino_Organizador_Items_fnc_getCatalogStatus; private _sd=_status getOrDefault ["data",createHashMap];
private _testOrchestrator=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
if ((_sd getOrDefault ["cacheBuilt",false]) && {!(_testOrchestrator getOrDefault ["running",false])}) then {[] spawn {uiSleep 0.05; ["","ALL",0,1] call ServoPeregrino_Organizador_Items_fnc_getUICatalogWindow;};};
if !(_sd getOrDefault ["cacheBuilt",false]) then {
    // Poll visual leve: só atualiza o texto de progresso, sem reconstruir view-model nem recapturar equipamento.
    [] spawn {
        disableSerialization;
        for "_i" from 0 to 180 do {
            uiSleep 0.5;
            private _d=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR,displayNull];
            if (isNull _d) exitWith {};
            private _sr=[] call ServoPeregrino_Organizador_Items_fnc_getCatalogStatus; private _s=_sr getOrDefault ["data",createHashMap];
            if (_s getOrDefault ["cacheBuilt",false]) exitWith {};
            if (_s getOrDefault ["buildInProgress",false]) then {
                private _root=_s getOrDefault ["buildCurrentRoot",""];
                (_d displayCtrl 3122) ctrlSetText format ["Catalogando %1... %2 configs · %3 itens",if (_root isEqualTo "") then {"CONFIG_ALL"} else {_root},_s getOrDefault ["buildVisitedCount",0],_s getOrDefault ["buildPartialItemCount",0]];
            };
        };
    };
    [] spawn {
        private _r=[] call ServoPeregrino_Organizador_Items_fnc_getCatalog;
        if (_r getOrDefault ["success",false]) then {["Catálogo CONFIG_ALL pronto no cache da sessão.","SUCCESS"] call ServoPeregrino_Organizador_Items_fnc_pushUIFeedback;} else {[format ["Catálogo não ficou pronto: %1",_r getOrDefault ["code","UNKNOWN"]],"WARN"] call ServoPeregrino_Organizador_Items_fnc_pushUIFeedback;};
        [] call ServoPeregrino_Organizador_Items_fnc_refreshInterface;
        private _testOrchestratorAfter=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_ORCHESTRATOR_VAR,createHashMap];
        if !(_testOrchestratorAfter getOrDefault ["running",false]) then {["","ALL",0,1] call ServoPeregrino_Organizador_Items_fnc_getUICatalogWindow;};
    };
};
true
