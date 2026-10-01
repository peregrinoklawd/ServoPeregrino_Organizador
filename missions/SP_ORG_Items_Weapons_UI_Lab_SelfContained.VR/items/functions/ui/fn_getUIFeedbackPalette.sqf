#include "..\..\script_version.hpp"
params [["_kind", "INFO", [""]]];
private _k = toUpper _kind;
if !(_k in ["SUCCESS","INFO","WARN","ERROR"]) then {_k = "INFO";};
switch _k do {
    case "SUCCESS": {createHashMapFromArray [["kind","SUCCESS"],["labelColor","#6FE3A1"],["messageColor","#C8FFE0"]]};
    case "WARN":    {createHashMapFromArray [["kind","WARN"],["labelColor","#FFC15A"],["messageColor","#FFE0A3"]]};
    case "ERROR":   {createHashMapFromArray [["kind","ERROR"],["labelColor","#FF7070"],["messageColor","#FFD0D0"]]};
    default          {createHashMapFromArray [["kind","INFO"],["labelColor","#7EC8FF"],["messageColor","#D7EEFF"]]};
}
