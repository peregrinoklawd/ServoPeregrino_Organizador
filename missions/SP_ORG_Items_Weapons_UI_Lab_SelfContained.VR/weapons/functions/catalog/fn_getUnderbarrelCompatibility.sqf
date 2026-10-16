#include "..\..\script_version.hpp"
// Backward-compatible R4 public adapter; UC-001-B uses one canonical resolver.
params [["_weaponClass","",[""]]];
private _r=[_weaponClass] call ServoPeregrino_Organizador_Weapons_fnc_resolveAttachmentCompatibility;
if !(_r getOrDefault ["success",false]) exitWith {_r};
private _d=_r getOrDefault ["data",createHashMap];
private _s=(_d getOrDefault ["sourcesBySlot",createHashMap]) getOrDefault ["bipod",createHashMap];
private _source=if ((_s getOrDefault ["cbaAddedCount",0])>0) then {"ENGINE_PLUS_CBA_UNDERBARREL"} else {"ENGINE_UNDERBARREL"};
[true,"WEAPONS_UNDERBARREL_COMPATIBILITY_DISCOVERED","Underbarrel compatibility derived from canonical UC-001-B source.",createHashMapFromArray [
 ["weaponClass",_d getOrDefault ["weaponClass",""]],
 ["items",+((_d getOrDefault ["slots",createHashMap]) getOrDefault ["bipod",[]])],
 ["engineCount",_s getOrDefault ["engineCount",0]],
 ["cbaAvailable",_s getOrDefault ["cbaAvailable",false]],
 ["cbaCount",_s getOrDefault ["cbaCount",0]],
 ["cbaAdded",+(_s getOrDefault ["cbaAdded",[]])],
 ["cbaAddedCount",_s getOrDefault ["cbaAddedCount",0]],
 ["source",_source]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
