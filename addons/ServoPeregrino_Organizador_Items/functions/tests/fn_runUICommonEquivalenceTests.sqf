#include "..\..\script_version.hpp"

private _passed=0;
private _failed=0;
private _details=[];
private _assert={
    params ["_name","_ok"];
    if (_ok) then {_passed=_passed+1; _details pushBack [_name,"PASS"];} else {_failed=_failed+1; _details pushBack [_name,"FAIL"];};
};

["uicommon-initialize-loaded",!(isNil "ServoPeregrino_Organizador_UICommon_fnc_initialize")] call _assert;
["uicommon-escape-loaded",!(isNil "ServoPeregrino_Organizador_UICommon_fnc_escapeStructuredText")] call _assert;
["uicommon-clamp-loaded",!(isNil "ServoPeregrino_Organizador_UICommon_fnc_clampVirtualOffset")] call _assert;
["uicommon-window-loaded",!(isNil "ServoPeregrino_Organizador_UICommon_fnc_getVirtualWindow")] call _assert;

["items-wrapper-simple",(["Alpha 123"] call ServoPeregrino_Organizador_Items_fnc_escapeStructuredText) isEqualTo "Alpha 123"] call _assert;
["items-wrapper-reserved",(["A&B<C>D"] call ServoPeregrino_Organizador_Items_fnc_escapeStructuredText) isEqualTo "A&amp;B&lt;C&gt;D"] call _assert;
["items-wrapper-empty",([""] call ServoPeregrino_Organizador_Items_fnc_escapeStructuredText) isEqualTo ""] call _assert;
private _sample="Nome & Classe <teste>";
["items-wrapper-equals-shared",([_sample] call ServoPeregrino_Organizador_Items_fnc_escapeStructuredText) isEqualTo ([_sample] call ServoPeregrino_Organizador_UICommon_fnc_escapeStructuredText)] call _assert;

["shared-clamp-last-window",([999,100,32] call ServoPeregrino_Organizador_UICommon_fnc_clampVirtualOffset) isEqualTo 68] call _assert;
private _tail=[[0,1,2,3,4,5],99,3] call ServoPeregrino_Organizador_UICommon_fnc_getVirtualWindow;
["shared-window-tail",(_tail getOrDefault ["rows",[]]) isEqualTo [3,4,5]] call _assert;

private _runtime=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_RUNTIME_VAR,createHashMap];
["items-runtime-uicommon-ready",_runtime getOrDefault ["uiCommonReady",false]] call _assert;
private _sharedBuild=[] call ServoPeregrino_Organizador_UICommon_fnc_getBuildInfo;
["shared-build-equivalence-r1",(_sharedBuild getOrDefault ["build",""]) isEqualTo "0.1.1-items-equivalence-r1"] call _assert;

private _ok=_failed isEqualTo 0;
[_ok,"ITEMS_UICOMMON_EQUIVALENCE_TESTS",format ["Items + UICommon Equivalence R1: %1 PASS / %2 FAIL.",_passed,_failed],createHashMapFromArray [
    ["passed",_passed],["failed",_failed],["checks",_passed+_failed],["details",_details],
    ["itemsBuild",SERVO_PEREGRINO_ORGANIZADOR_ITEMS_BUILD],["uiCommonBuild",_sharedBuild getOrDefault ["build",""]]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
