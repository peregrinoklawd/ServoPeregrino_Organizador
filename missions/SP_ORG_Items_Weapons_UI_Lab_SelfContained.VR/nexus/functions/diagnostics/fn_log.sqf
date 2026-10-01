#include "..\..\script_version.hpp"

params [
    ["_component", "NEXUS", [""]],
    ["_level", "INFO", [""]],
    ["_message", "", [""]],
    ["_context", createHashMap, [createHashMap]]
];

private _levels = createHashMapFromArray [
    ["TRACE", 0],
    ["DEBUG", 1],
    ["INFO", 2],
    ["WARN", 3],
    ["ERROR", 4]
];
private _normalizedLevel = toUpperANSI _level;
private _value = _levels getOrDefault [_normalizedLevel, 2];
private _threshold = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_NEXUS_LOG_LEVEL_VAR, 2];

if (_value < _threshold) exitWith {false};

private _contextText = "";
if ((count _context) > 0) then {
    _contextText = format [" | CONTEXT=%1", _context];
};

diag_log format [
    "[SP_ORG] [%1] [%2] %3%4",
    toUpperANSI _component,
    _normalizedLevel,
    _message,
    _contextText
];
true
