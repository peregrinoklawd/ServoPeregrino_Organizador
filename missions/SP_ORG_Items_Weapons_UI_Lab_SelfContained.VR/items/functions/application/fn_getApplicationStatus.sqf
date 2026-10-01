#include "..\..\script_version.hpp"
private _s = missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_STATE_VAR, createHashMapFromArray [["ready", false], ["executing", false]]];
[true, "ITEMS_APPLICATION_STATUS", "Status runtime do Physical Transaction Engine.", createHashMapFromArray [
    ["ready", _s getOrDefault ["ready", false]], ["executing", _s getOrDefault ["executing", false]], ["activePlanId", _s getOrDefault ["activePlanId", ""]],
    ["lockToken", _s getOrDefault ["lockToken", ""]], ["lockOwner", _s getOrDefault ["lockOwner", ""]], ["lockAcquiredAtTick", _s getOrDefault ["lockAcquiredAtTick", -1]],
    ["lastResult", _s getOrDefault ["lastResult", createHashMap]], ["planVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_PLAN_VERSION],
    ["snapshotVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CONTAINER_SNAPSHOT_VERSION], ["applyResultVersion", SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLY_RESULT_VERSION]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
