#include "..\..\script_version.hpp"
params [["_snapshot", createHashMap, [createHashMap]]];
if ((_snapshot getOrDefault ["version", 0]) isNotEqualTo SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CONTAINER_SNAPSHOT_VERSION) exitWith {[false, "ITEMS_ROLLBACK_FAILED", "ContainerSnapshot inválido para restauração.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _container = _snapshot getOrDefault ["container", objNull];
if (isNull _container) exitWith {[false, "ITEMS_ROLLBACK_FAILED", "ContainerSnapshot perdeu o container físico.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult};
private _target = _snapshot getOrDefault ["target", ""];
private _containerClass = _snapshot getOrDefault ["containerClass", ""];
private _currentR = [_container, _target, _containerClass] call ServoPeregrino_Organizador_Items_fnc_captureContainerContent;
if !(_currentR getOrDefault ["success", false]) exitWith {_currentR};
private _current = _currentR getOrDefault ["data", createHashMap];
{
    if ((_x # 1) isEqualTo "ITEM") then {_container addItemCargoGlobal [_x # 2, -(_x # 3)];};
} forEach (_current getOrDefault ["entries", []]);
clearMagazineCargoGlobal _container;
{
    if ((_x # 1) isEqualTo "ITEM") then {
        _container addItemCargoGlobal [_x # 2, _x # 3];
    } else {
        if ((_x # 4) isEqualTo "EXACT") then {
            private _magClass = _x # 2;
            private _magStates = +(_x # 5);
            {_container addMagazineAmmoCargo [_magClass, 1, _x];} forEach _magStates;
        };
    };
} forEach (_snapshot getOrDefault ["entries", []]);
private _afterR = [_container, _target, _containerClass] call ServoPeregrino_Organizador_Items_fnc_getMutableContentFingerprint;
if !(_afterR getOrDefault ["success", false]) exitWith {_afterR};
private _afterFp = ((_afterR getOrDefault ["data", createHashMap]) getOrDefault ["fingerprint", createHashMap]);
private _expectedFp = _snapshot getOrDefault ["fingerprint", createHashMap];
private _ok = (_afterFp getOrDefault ["serialized", "A"]) isEqualTo (_expectedFp getOrDefault ["serialized", "B"]);
[
    _ok,
    if (_ok) then {"ITEMS_ROLLBACK_RESTORED"} else {"ITEMS_ROLLBACK_FAILED"},
    if (_ok) then {"Snapshot focal restaurado e fingerprint comprovado."} else {"Restauração focal não reproduziu o fingerprint do snapshot."},
    createHashMapFromArray [["fingerprint", _afterFp], ["expectedFingerprint", _expectedFp]]
] call ServoPeregrino_Organizador_Nexus_fnc_createResult
