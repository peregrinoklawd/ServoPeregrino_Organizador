#include "..\..\script_version.hpp"
params [["_kit",[],[[]]]];

private _totalMass=0;
private _unknownMassCount=0;
private _entries=[];
if (_kit isEqualType [] && {(count _kit)>8}) then {_entries=+(_kit#8);};
{
    private _entry=_x;
    if (_entry isEqualType [] && {(count _entry) isEqualTo 6}) then {
        private _meta=[_entry#2] call ServoPeregrino_Organizador_Items_fnc_resolveUIItemMetadata;
        private _aware=[_entry,_meta] call ServoPeregrino_Organizador_Items_fnc_getUIEntryAwareness;
        if (_aware getOrDefault ["known",false]) then {
            _totalMass=_totalMass+(_aware getOrDefault ["totalMass",0]);
        } else {
            _unknownMassCount=_unknownMassCount+1;
        };
    } else {
        _unknownMassCount=_unknownMassCount+1;
    };
} forEach _entries;
createHashMapFromArray [
    ["entryCount",count _entries],
    ["totalMass",_totalMass],
    ["unknownMassCount",_unknownMassCount],
    ["known",_unknownMassCount isEqualTo 0]
]
