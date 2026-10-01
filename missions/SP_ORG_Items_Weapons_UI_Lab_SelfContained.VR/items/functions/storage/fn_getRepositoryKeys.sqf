#include "..\..\script_version.hpp"

private _suffix = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_STORAGE_TEST_SUFFIX_VAR, ""];
private _testMode = !(_suffix isEqualTo "");
private _safeSuffix = _suffix;
if (_testMode) then {
    private _chars = toArray _safeSuffix;
    private _invalid = _chars findIf {
        private _c = _x;
        private _digit = (_c >= 48) && (_c <= 57);
        private _upper = (_c >= 65) && (_c <= 90);
        private _lower = (_c >= 97) && (_c <= 122);
        private _underscore = _c isEqualTo 95;
        !(_digit || _upper || _lower || _underscore)
    };
    if (_invalid >= 0) then {_safeSuffix = "INVALID";};
};

private _base = "ServoPeregrino_Organizador_Items_storage";
private _primary = if (_testMode) then {
    format ["%1_TEST_%2_v1", _base, _safeSuffix]
} else {
    format ["%1_v1", _base]
};
private _lastGood = if (_testMode) then {
    format ["%1_TEST_%2_lastGood_v1", _base, _safeSuffix]
} else {
    format ["%1_lastGood_v1", _base]
};

createHashMapFromArray [
    ["primary", _primary],
    ["lastGood", _lastGood],
    ["testMode", _testMode],
    ["suffix", _safeSuffix]
]
