#include "..\..\script_version.hpp"
params [["_kit",[],[[]]]];
if ((count _kit) < 10) exitWith {createHashMapFromArray [["isTestKit",false],["confidence","NONE"],["reasons",["INVALID_SHAPE"]],["id",""] ,["name",""]]};
private _id=_kit param [2,"",[""]];
private _name=_kit param [3,"",[""]];
private _origin=_kit param [5,[],[[]]];
private _nameL=toLower _name;
private _metaL=toLower str _origin;
private _nameMatches=[];
private _metaMatches=[];
private _namePatterns=["kit cp-c","kit persistido cp-b","0.10 final saved e2e","kit delete clean","kit delete dirty","kit delete other","fonte merge 0.8","kit fonte merge 0.6","kit persistência 0.4","clone persistente 0.4","kit mod ausente persistente","kit médico 0.4","demo draft 0.6","kit ui demo 0.7","kit ui demo 0.8","kit ui demo 0.9","kit ui demo 0.10","kit ui demo 0.11"];
{if ((_nameL find _x)>=0) then {_nameMatches pushBackUnique _x;};} forEach _namePatterns;
private _metaPatterns=["cpb_test","cpc_test","final_0_10","delete_detach","delete_other","missing_mod","repository","merge","ui_demo","lab","test"];
{if ((_metaL find _x)>=0) then {_metaMatches pushBackUnique _x;};} forEach _metaPatterns;
private _high=((count _nameMatches)>0) && {(count _metaMatches)>0};
private _reasons=[];
{_reasons pushBack format ["NAME:%1",_x];} forEach _nameMatches;
{_reasons pushBack format ["META:%1",_x];} forEach _metaMatches;
createHashMapFromArray [["isTestKit",_high],["confidence",if (_high) then {"HIGH"} else {"NONE"}],["reasons",_reasons],["id",_id],["name",_name],["origin",_origin],["nameMatches",_nameMatches],["metaMatches",_metaMatches]]
