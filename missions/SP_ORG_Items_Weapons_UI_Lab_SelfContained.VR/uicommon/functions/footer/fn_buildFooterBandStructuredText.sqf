params [
    ["_label", "", [""]],
    ["_text", "", [""]],
    ["_labelColor", "#FFFFFF", [""]],
    ["_textColor", "#FFFFFF", [""]],
    ["_separator", "  •  ", [""]]
];

private _labelSafe = [_label] call ServoPeregrino_Organizador_UICommon_fnc_escapeStructuredText;
private _textSafe = [_text] call ServoPeregrino_Organizador_UICommon_fnc_escapeStructuredText;

format [
    "<t color='%1'>%2</t><t color='%3'>%4%5</t>",
    _labelColor,
    _labelSafe,
    _textColor,
    _separator,
    _textSafe
]
