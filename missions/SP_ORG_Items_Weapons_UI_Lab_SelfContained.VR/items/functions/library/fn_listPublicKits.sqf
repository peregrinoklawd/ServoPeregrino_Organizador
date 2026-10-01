#include "..\..\script_version.hpp"
private _libR=[] call ServoPeregrino_Organizador_Items_fnc_getPublicLibrary;
if !(_libR getOrDefault ["success",false]) exitWith {_libR};
private _libD=_libR getOrDefault ["data",createHashMap];
private _registry=_libD getOrDefault ["library",[]];
private _rows=[];
{
    private _entry=_x;
    if (_entry isEqualType [] && {(count _entry) isEqualTo 8}) then {
        private _kit=_entry#7;
        private _valid=[_kit] call ServoPeregrino_Organizador_Items_fnc_validateItemKitSemantic;
        if (_valid getOrDefault ["success",false]) then {
            private _summary=createHashMapFromArray [
                ["id",_entry#0],["publicId",_entry#0],["sourceKind",_entry#1],["sourceKitId",_entry#2],
                ["authorName",_entry#3],["authorKey",_entry#4],["publishedAtUTC",+(_entry#5)],["updatedAtUTC",+(_entry#6)],
                ["kitId",_kit#2],["name",_kit#3],["preferredTarget",_kit#4],["entryCount",count (_kit#8)]
            ];
            _rows pushBack [toLower (_kit#3),toLower (_entry#3),_entry#0,_summary];
        };
    };
} forEach (_registry#3);
_rows sort true;
private _summaries=_rows apply {_x#3};
[true,"ITEMS_PUBLIC_KITS_LISTED","Kits públicos da sessão listados a partir da réplica autoritativa do servidor.",createHashMapFromArray [["kits",_summaries],["count",count _summaries],["revision",_registry#2],["scope","SESSION"],["authority",_libD getOrDefault ["authority","SERVER"]],["authoritative",_libD getOrDefault ["authoritative",false]],["authorityPending",_libD getOrDefault ["authorityPending",false]]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
