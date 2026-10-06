disableSerialization;
params [
    "_display",
    ["_bands", [], [[]]]
];

if (isNull _display) exitWith {0};

private _rendered = 0;
{
    _x params [
        ["_idc", -1, [0]],
        ["_label", "", [""]],
        ["_text", "", [""]],
        ["_labelColor", "#FFFFFF", [""]],
        ["_textColor", "#FFFFFF", [""]],
        ["_separator", "  •  ", [""]]
    ];

    private _ctrl = _display displayCtrl _idc;
    if (!isNull _ctrl) then {
        private _structured = [_label, _text, _labelColor, _textColor, _separator] call ServoPeregrino_Organizador_UICommon_fnc_buildFooterBandStructuredText;
        _ctrl ctrlSetStructuredText parseText _structured;
        _rendered = _rendered + 1;
    };
} forEach _bands;

_rendered
