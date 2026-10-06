/*
 * UICommon R3 — color a composite rounded visual surface.
 * Safe for a mix of picture corners and static-fill controls.
 */
disableSerialization;
params [
    ["_display",displayNull,[displayNull]],
    ["_idcs",[],[[]]],
    ["_color",[0.015,0.02,0.022,0.44],[[]]]
];
if (isNull _display) exitWith {0};
private _updated=0;
{
    private _ctrl=_display displayCtrl _x;
    if (!isNull _ctrl) then {
        _ctrl ctrlSetTextColor _color;
        _ctrl ctrlSetBackgroundColor _color;
        _updated=_updated+1;
    };
} forEach _idcs;
_updated
