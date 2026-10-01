#include "..\..\script_version.hpp"
disableSerialization;
params [["_reason","USER_INTERACTION",[""]]];

private _state=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,createHashMap];
if ((count _state) isEqualTo 0) exitWith {createHashMapFromArray [["cleared",false],["previous",""]]};
private _previous=toUpper (_state getOrDefault ["kitLibraryActionStatus",""]);
if (_previous isEqualTo "") exitWith {createHashMapFromArray [["cleared",false],["previous",""]]};

_state set ["kitLibraryActionStatus",""];
_state set ["lastKitLibraryActionStatus",_previous];
_state set ["kitLibraryActionStatusClearReason",toUpper _reason];
_state set ["kitLibraryActionStatusClearedAtTick",diag_tickTime];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR,_state];

private _display=uiNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR,displayNull];
if (!isNull _display) then {
    private _statusCtrl=_display displayCtrl 1001;
    if (!isNull _statusCtrl) then {_statusCtrl ctrlSetText "";};
};

createHashMapFromArray [["cleared",true],["previous",_previous],["reason",toUpper _reason]]
