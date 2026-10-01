params [
    ["_container", objNull, [objNull]],
    ["_target", "", [""]],
    ["_containerClass", "", [""]]
];

private _capture = [_container, _target, _containerClass] call ServoPeregrino_Organizador_Items_fnc_captureContainerContent;
if !(_capture getOrDefault ["success", false]) exitWith {_capture};
private _cd = _capture getOrDefault ["data", createHashMap];
private _fingerprint = [
    _cd getOrDefault ["entries", []],
    _cd getOrDefault ["reservedCargo", []],
    _cd getOrDefault ["containerClass", ""],
    _cd getOrDefault ["target", ""]
] call ServoPeregrino_Organizador_Items_fnc_buildMutableFingerprint;
[
    true,
    "ITEMS_MUTABLE_FINGERPRINT_READY",
    "Fingerprint canônico do conteúdo mutável foi calculado.",
    createHashMapFromArray [["fingerprint", _fingerprint], ["capture", _cd]]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
