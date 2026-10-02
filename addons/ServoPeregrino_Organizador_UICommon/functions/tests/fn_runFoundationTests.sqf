private _passed = 0;
private _failed = 0;
private _details = [];

private _assert = {
    params ["_name", "_condition"];
    if (_condition) then {
        _passed = _passed + 1;
        _details pushBack [_name, "PASS"];
    } else {
        _failed = _failed + 1;
        _details pushBack [_name, "FAIL"];
    };
};

["offset-negative-clamps-zero", ([-10, 100, 32] call ServoPeregrino_Organizador_UICommon_fnc_clampVirtualOffset) isEqualTo 0] call _assert;
["offset-upper-clamps-last-window", ([999, 100, 32] call ServoPeregrino_Organizador_UICommon_fnc_clampVirtualOffset) isEqualTo 68] call _assert;
["offset-small-list-zero", ([10, 3, 32] call ServoPeregrino_Organizador_UICommon_fnc_clampVirtualOffset) isEqualTo 0] call _assert;

private _window = [[0,1,2,3,4,5], 2, 3] call ServoPeregrino_Organizador_UICommon_fnc_getVirtualWindow;
["window-offset", (_window get "offset") isEqualTo 2] call _assert;
["window-count", (_window get "visibleCount") isEqualTo 3] call _assert;
["window-rows", (_window get "rows") isEqualTo [2,3,4]] call _assert;

private _tail = [[0,1,2,3,4,5], 99, 3] call ServoPeregrino_Organizador_UICommon_fnc_getVirtualWindow;
["window-tail-clamps-offset", (_tail get "offset") isEqualTo 3] call _assert;
["window-tail-rows", (_tail get "rows") isEqualTo [3,4,5]] call _assert;

private _theme = [] call ServoPeregrino_Organizador_UICommon_fnc_getThemeTokens;
["theme-font", (_theme get "font") isEqualTo "RobotoCondensed"] call _assert;
["theme-four-panel", (_theme get "layoutModel") isEqualTo "FOUR_PANEL_V1"] call _assert;

["structured-text-pass-through", (["Alpha 123"] call ServoPeregrino_Organizador_UICommon_fnc_escapeStructuredText) isEqualTo "Alpha 123"] call _assert;
["structured-text-escapes-reserved", (["A&B<C>D"] call ServoPeregrino_Organizador_UICommon_fnc_escapeStructuredText) isEqualTo "A&amp;B&lt;C&gt;D"] call _assert;

private _ok = _failed isEqualTo 0;
[_ok, "UICOMMON_FOUNDATION_TESTS", format ["UICommon foundation: %1 PASS / %2 FAIL.", _passed, _failed], createHashMapFromArray [
    ["passed", _passed],
    ["failed", _failed],
    ["checks", _passed + _failed],
    ["details", _details]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
