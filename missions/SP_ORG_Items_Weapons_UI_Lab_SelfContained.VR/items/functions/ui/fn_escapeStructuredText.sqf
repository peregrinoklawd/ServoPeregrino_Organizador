params [["_text", "", [""]]];
private _out = "";
{
    switch _x do {
        case 38: {_out = _out + "&amp;";};   // &
        case 60: {_out = _out + "&lt;";};    // <
        case 62: {_out = _out + "&gt;";};    // >
        default {_out = _out + toString [_x];};
    };
} forEach (toArray _text);
_out
