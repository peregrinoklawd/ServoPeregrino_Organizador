#include "..\..\script_version.hpp"
private _suffix=missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_STORAGE_TEST_SUFFIX_VAR,""];
if !(_suffix isEqualTo "") exitWith {
    [false,"ITEMS_TEST_LEAK_SCAN_REQUIRES_PRODUCTION_NAMESPACE","Scanner de vazamento só pode rodar no namespace de produção.",createHashMapFromArray [["suffix",_suffix]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
private _list=[] call ServoPeregrino_Organizador_Items_fnc_listKits;
if !(_list getOrDefault ["success",false]) exitWith {_list};
private _summaries=((_list getOrDefault ["data",createHashMap]) getOrDefault ["kits",[]]);
private _candidates=[];
{
    private _id=_x getOrDefault ["id",""];
    if !(_id isEqualTo "") then {
        private _g=[_id] call ServoPeregrino_Organizador_Items_fnc_getKit;
        if (_g getOrDefault ["success",false]) then {
            private _kit=((_g getOrDefault ["data",createHashMap]) getOrDefault ["kit",[]]);
            private _c=[_kit] call ServoPeregrino_Organizador_Items_fnc_classifyLeakedTestKit;
            if ((_c isEqualType createHashMap) && {_c getOrDefault ["isTestKit",false]}) then {_candidates pushBack _c;};
        };
    };
} forEach _summaries;
diag_log format ["[SP_ORG] [ITEMS] [TEST_STORAGE_GUARD] leakedCandidates=%1 productionKits=%2",count _candidates,count _summaries];
{diag_log format ["[SP_ORG] [ITEMS] [TEST_STORAGE_GUARD] candidate id=%1 name=%2 reasons=%3",_x getOrDefault ["id",""],_x getOrDefault ["name",""],_x getOrDefault ["reasons",[]]];} forEach _candidates;
[true,"ITEMS_TEST_LEAK_SCAN_COMPLETE","Diagnóstico de kits de teste concluído.",createHashMapFromArray [["count",count _candidates],["candidates",_candidates],["productionCount",count _summaries]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
