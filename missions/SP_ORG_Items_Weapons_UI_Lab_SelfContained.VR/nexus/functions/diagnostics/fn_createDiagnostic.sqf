params [
    ["_severity", "INFO", [""]],
    ["_code", "UNSPECIFIED", [""]],
    ["_message", "", [""]],
    ["_context", createHashMap, [createHashMap]]
];

private _normalizedSeverity = toUpperANSI _severity;
if !(_normalizedSeverity in ["TRACE", "DEBUG", "INFO", "WARN", "ERROR"]) then {
    _normalizedSeverity = "INFO";
};

createHashMapFromArray [
    ["severity", _normalizedSeverity],
    ["code", toUpperANSI _code],
    ["message", _message],
    ["context", _context],
    ["createdAtUTC", systemTimeUTC]
]
