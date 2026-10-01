#include "..\..\script_version.hpp"
params [["_confirmation","",[""]]];
if !(_confirmation isEqualTo "CONFIRM_TEST_FIXTURE_CLEANUP") exitWith {
    [false,"ITEMS_TEST_LEAK_CLEANUP_CONFIRMATION_REQUIRED","Limpeza recusada sem confirmação explícita.",createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _scan=[] call ServoPeregrino_Organizador_Items_fnc_findLeakedTestKits;
if !(_scan getOrDefault ["success",false]) exitWith {_scan};
private _data=_scan getOrDefault ["data",createHashMap];
private _candidates=_data getOrDefault ["candidates",[]];
private _removed=[]; private _failed=[];
{
    private _id=_x getOrDefault ["id",""];
    private _name=_x getOrDefault ["name",""];
    private _r=[_id] call ServoPeregrino_Organizador_Items_fnc_deleteKitPreservingDraft;
    if (_r getOrDefault ["success",false]) then {_removed pushBack [_id,_name];} else {_failed pushBack [_id,_name,_r getOrDefault ["code","UNKNOWN"]];};
} forEach _candidates;
diag_log format ["[SP_ORG] [ITEMS] [TEST_STORAGE_GUARD] cleanup removed=%1 failed=%2",count _removed,count _failed];
[true,"ITEMS_TEST_LEAK_CLEANUP_COMPLETE",format ["Limpeza concluída: %1 removidos, %2 falhas.",count _removed,count _failed],createHashMapFromArray [["removed",_removed],["failed",_failed]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
