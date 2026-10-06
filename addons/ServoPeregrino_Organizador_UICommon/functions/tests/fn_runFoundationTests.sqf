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


private _scrollTail = [999, 100, 32] call ServoPeregrino_Organizador_UICommon_fnc_getVirtualScrollState;
["scroll-state-tail-offset", (_scrollTail get "offset") isEqualTo 68] call _assert;
["scroll-state-tail-max", (_scrollTail get "maxOffset") isEqualTo 68] call _assert;
["scroll-state-tail-visible", (_scrollTail get "visibleCount") isEqualTo 32] call _assert;
["scroll-state-tail-indices", (_scrollTail get "firstIndex") isEqualTo 68 && {(_scrollTail get "lastIndex") isEqualTo 99}] call _assert;
["scroll-state-tail-ratio", abs ((_scrollTail get "scrollRatio") - 1) < 0.0001] call _assert;

private _scrollSmall = [10, 3, 32] call ServoPeregrino_Organizador_UICommon_fnc_getVirtualScrollState;
["scroll-state-small-clamps", (_scrollSmall get "offset") isEqualTo 0 && {(_scrollSmall get "maxOffset") isEqualTo 0}] call _assert;
["scroll-state-small-visible", (_scrollSmall get "visibleCount") isEqualTo 3 && {(_scrollSmall get "firstIndex") isEqualTo 0} && {(_scrollSmall get "lastIndex") isEqualTo 2}] call _assert;

private _scrollEmpty = [10, 0, 32] call ServoPeregrino_Organizador_UICommon_fnc_getVirtualScrollState;
["scroll-state-empty", (_scrollEmpty get "visibleCount") isEqualTo 0 && {(_scrollEmpty get "firstIndex") isEqualTo -1} && {(_scrollEmpty get "lastIndex") isEqualTo -1}] call _assert;

["point-in-rect-inside", [0.20, 0.30, [0.10, 0.20, 0.30, 0.40]] call ServoPeregrino_Organizador_UICommon_fnc_pointInRect] call _assert;
["point-in-rect-inclusive-edge", [0.40, 0.60, [0.10, 0.20, 0.30, 0.40]] call ServoPeregrino_Organizador_UICommon_fnc_pointInRect] call _assert;
["point-in-rect-outside", !([0.401, 0.30, [0.10, 0.20, 0.30, 0.40]] call ServoPeregrino_Organizador_UICommon_fnc_pointInRect)] call _assert;
["point-in-rect-invalid-negative-size", !([0.10, 0.20, [0.10, 0.20, -0.30, 0.40]] call ServoPeregrino_Organizador_UICommon_fnc_pointInRect)] call _assert;


private _sliderState = [controlNull, 999, 100, 32, 6, 12, true] call ServoPeregrino_Organizador_UICommon_fnc_syncVirtualSlider;
["virtual-slider-null-control-offset", (_sliderState get "offset") isEqualTo 68] call _assert;
["virtual-slider-null-control-max", (_sliderState get "maxOffset") isEqualTo 68] call _assert;
["virtual-slider-null-control-ratio", abs ((_sliderState get "scrollRatio") - 1) < 0.0001] call _assert;

private _footerBand = ["A&B", "C<D>E", "#111111", "#222222", " :: "] call ServoPeregrino_Organizador_UICommon_fnc_buildFooterBandStructuredText;
["footer-band-label-escaped", (_footerBand find "A&amp;B") >= 0] call _assert;
["footer-band-text-escaped", (_footerBand find "C&lt;D&gt;E") >= 0] call _assert;
["footer-band-colors-preserved", (_footerBand find "#111111") >= 0 && {(_footerBand find "#222222") >= 0}] call _assert;
["footer-null-display-safe", ([findDisplay -99999, []] call ServoPeregrino_Organizador_UICommon_fnc_renderFooter) isEqualTo 0] call _assert;

private _hasUIClass = {
    params ["_name"];
    isClass (missionConfigFile >> _name) || {isClass (configFile >> _name)}
};
["visual-rounded-surface-class", ["SPORG_UICommon_RoundedSurface"] call _hasUIClass] call _assert;
["visual-search-edit-class", ["SPORG_UICommon_SearchEdit"] call _hasUIClass] call _assert;
["visual-search-clear-class", ["SPORG_UICommon_SearchClear"] call _hasUIClass] call _assert;
["visual-kit-list-class", ["SPORG_UICommon_KitList"] call _hasUIClass] call _assert;
["visual-round-corner-class", ["SPORG_UICommon_RoundCorner"] call _hasUIClass] call _assert;
["visual-round-fill-class", ["SPORG_UICommon_RoundFill"] call _hasUIClass] call _assert;
["responsive-layout-function-loaded", !(isNil "ServoPeregrino_Organizador_UICommon_fnc_applyResponsiveControlLayout")] call _assert;
["composite-color-function-loaded", !(isNil "ServoPeregrino_Organizador_UICommon_fnc_setCompositeControlColor")] call _assert;

private _ok = _failed isEqualTo 0;
[_ok, "UICOMMON_FOUNDATION_TESTS", format ["UICommon foundation: %1 PASS / %2 FAIL.", _passed, _failed], createHashMapFromArray [
    ["passed", _passed],
    ["failed", _failed],
    ["checks", _passed + _failed],
    ["details", _details]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
