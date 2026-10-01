#include "..\..\script_version.hpp"
params [
    ["_container", objNull, [objNull]],
    ["_target", "", [""]],
    ["_containerClass", "", [""]]
];
private _captureR = [_container, _target, _containerClass] call ServoPeregrino_Organizador_Items_fnc_captureContainerContent;
if !(_captureR getOrDefault ["success", false]) exitWith {_captureR};
private _capture = _captureR getOrDefault ["data", createHashMap];
private _fp = [_capture getOrDefault ["entries", []], _capture getOrDefault ["reservedCargo", []], _capture getOrDefault ["containerClass", ""], _target] call ServoPeregrino_Organizador_Items_fnc_buildMutableFingerprint;
private _snapshot = createHashMapFromArray [
    ["version", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CONTAINER_SNAPSHOT_VERSION], ["target", toUpper _target], ["container", _container], ["containerClass", _capture getOrDefault ["containerClass", ""]],
    ["entries", [_capture getOrDefault ["entries", []]] call ServoPeregrino_Organizador_Items_fnc_deepCopy], ["reservedCargo", [_capture getOrDefault ["reservedCargo", []]] call ServoPeregrino_Organizador_Items_fnc_deepCopy],
    ["fingerprint", _fp], ["capturedAtTick", diag_tickTime]
];
[true, "ITEMS_CONTAINER_SNAPSHOT_READY", "ContainerSnapshot v1 capturado antes da mutação.", createHashMapFromArray [["snapshot", _snapshot]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
