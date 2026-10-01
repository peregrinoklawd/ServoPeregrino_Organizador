#include "..\..\script_version.hpp"
disableSerialization;
params [["_reason","LOAD_KIT",[""]]];

private _startedAt=diag_tickTime;
private _display=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR,displayNull];
if (isNull _display) exitWith {false};

private _state=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
if ((count _state) isEqualTo 0) then {_state=[] call ServoPeregrino_Organizador_Items_fnc_createUIState;};

private _fullBefore=_state getOrDefault ["fullRefreshCount",0];
private _catalogFocusBefore=_state getOrDefault ["catalogFocusedRefreshCount",0];
private _equipmentFocusBefore=_state getOrDefault ["equipmentFocusedRefreshCount",0];
private _equipmentCaptureBefore=_state getOrDefault ["equipmentCaptureCount",0];
private _targetBefore=_state getOrDefault ["targetRefreshCount",0];

private _kitsCtrl=_display displayCtrl 1102;
private _catalogCtrl=_display displayCtrl 3120;
private _equipmentCtrl=_display displayCtrl 4120;
private _catalogSizeBefore=lbSize _catalogCtrl;
private _catalogSelBefore=lbCurSel _catalogCtrl;
private _catalogScrollBefore=ctrlScrollValues _catalogCtrl;
private _equipmentSizeBefore=lbSize _equipmentCtrl;
private _equipmentSelBefore=lbCurSel _equipmentCtrl;
private _equipmentScrollBefore=ctrlScrollValues _equipmentCtrl;

// Sincroniza somente o highlight da lista já materializada; a coleção não é reconstruída.
_state set ["refreshing",true];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state];
private _selectedKitId=_state getOrDefault ["selectedKitId",""];
private _kitIndex=-1;
if (_selectedKitId isNotEqualTo "") then {
    for "_i" from 0 to ((lbSize _kitsCtrl)-1) do {
        if ((_kitsCtrl lbData _i) isEqualTo _selectedKitId) exitWith {_kitIndex=_i;};
    };
};
if (_kitIndex>=0 && {(lbCurSel _kitsCtrl) isNotEqualTo _kitIndex}) then {_kitsCtrl lbSetCurSel _kitIndex;};

// O novo kit altera somente Draft + readiness física derivada do preferredTarget.
private _draftOk=["KIT_SWITCH"] call ServoPeregrino_Organizador_Items_fnc_refreshDraftMutationUI;
private _targetOk=[createHashMapFromArray [["reason","KIT_SWITCH_FOCUSED"]]] call ServoPeregrino_Organizador_Items_fnc_refreshPhysicalTargetUI;

private _stateAfter=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
// D.7.2: LOAD_KIT usa refresh focado. Sem esta sincronização, PUBLICAR só era reavaliado no próximo
// full refresh (por exemplo, reabrir a interface ou terminar/atualizar o Catálogo), dando a falsa
// impressão de que o botão aguardava a construção do Catálogo.
private _publishCtrl=_display displayCtrl 1113;
if (!isNull _publishCtrl) then {
    _publishCtrl ctrlEnable ((toUpper (_stateAfter getOrDefault ["kitLibraryMode","PRIVATE"])) isEqualTo "PRIVATE" && {(_stateAfter getOrDefault ["selectedKitId",""]) isNotEqualTo ""});
};
private _fullAfter=_stateAfter getOrDefault ["fullRefreshCount",0];
private _catalogFocusAfter=_stateAfter getOrDefault ["catalogFocusedRefreshCount",0];
private _equipmentFocusAfter=_stateAfter getOrDefault ["equipmentFocusedRefreshCount",0];
private _equipmentCaptureAfter=_stateAfter getOrDefault ["equipmentCaptureCount",0];
private _targetAfter=_stateAfter getOrDefault ["targetRefreshCount",0];
private _catalogUntouched=(lbSize _catalogCtrl) isEqualTo _catalogSizeBefore
    && {(lbCurSel _catalogCtrl) isEqualTo _catalogSelBefore}
    && {(ctrlScrollValues _catalogCtrl) isEqualTo _catalogScrollBefore};
private _equipmentUntouched=(lbSize _equipmentCtrl) isEqualTo _equipmentSizeBefore
    && {(lbCurSel _equipmentCtrl) isEqualTo _equipmentSelBefore}
    && {(ctrlScrollValues _equipmentCtrl) isEqualTo _equipmentScrollBefore};
private _durationMs=round ((diag_tickTime-_startedAt)*1000);

_stateAfter set ["lastRefreshTick",diag_tickTime];
_stateAfter set ["lastRefreshMode","KIT_SWITCH_FOCUSED"];
_stateAfter set ["kitSwitchFocusedRefreshCount",(_stateAfter getOrDefault ["kitSwitchFocusedRefreshCount",0])+1];
_stateAfter set ["lastKitSwitchFocusedRefreshDurationMs",_durationMs];
_stateAfter set ["lastKitSwitchFocusedReason",toUpper _reason];
_stateAfter set ["lastKitSwitchFullDelta",_fullAfter-_fullBefore];
_stateAfter set ["lastKitSwitchCatalogFocusedDelta",_catalogFocusAfter-_catalogFocusBefore];
_stateAfter set ["lastKitSwitchEquipmentFocusedDelta",_equipmentFocusAfter-_equipmentFocusBefore];
_stateAfter set ["lastKitSwitchEquipmentCaptureDelta",_equipmentCaptureAfter-_equipmentCaptureBefore];
_stateAfter set ["lastKitSwitchTargetRefreshDelta",_targetAfter-_targetBefore];
_stateAfter set ["lastKitSwitchCatalogUntouched",_catalogUntouched];
_stateAfter set ["lastKitSwitchEquipmentUntouched",_equipmentUntouched];
private _perf=+(_stateAfter getOrDefault ["uiPerfHistory",[]]);
_perf pushBack ["KIT_SWITCH_FOCUSED",toUpper _reason,_durationMs,_fullAfter-_fullBefore,_equipmentCaptureAfter-_equipmentCaptureBefore,diag_tickTime];
while {(count _perf)>24} do {_perf deleteAt 0;};
_stateAfter set ["uiPerfHistory",_perf];
_stateAfter set ["refreshing",false];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_stateAfter];

if (_stateAfter getOrDefault ["uiPerfTracing",true]) then {
    diag_log format ["[SP_ORG] [ITEMS] [UI_PERF] mode=KIT_SWITCH_FOCUSED reason=%1 totalMs=%2 draftFocused=%3 targetRefresh=%4 fullDelta=%5 catalogTouched=%6 catalogFocusedDelta=%7 equipmentTouched=%8 equipmentFocusedDelta=%9 equipmentRecapture=%10 kitsRebuilt=false",toUpper _reason,_durationMs,_draftOk,_targetOk,_fullAfter-_fullBefore,!_catalogUntouched,_catalogFocusAfter-_catalogFocusBefore,!_equipmentUntouched,_equipmentFocusAfter-_equipmentFocusBefore,_equipmentCaptureAfter-_equipmentCaptureBefore];
};
_draftOk && {_targetOk}
