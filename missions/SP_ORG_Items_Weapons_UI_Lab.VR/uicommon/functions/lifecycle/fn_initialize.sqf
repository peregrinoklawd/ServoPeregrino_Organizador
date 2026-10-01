#include "..\..\script_version.hpp"

if (missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_UICOMMON_INITIALIZED_VAR, false]) exitWith {
    [true, "UICOMMON_ALREADY_INITIALIZED", "UICommon já estava inicializado.", createHashMapFromArray [
        ["build", [] call ServoPeregrino_Organizador_UICommon_fnc_getBuildInfo]
    ]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _nexusResult = [] call ServoPeregrino_Organizador_Nexus_fnc_initialize;
if !(_nexusResult getOrDefault ["success", false]) exitWith {
    [false, "UICOMMON_NEXUS_UNAVAILABLE", "UICommon não conseguiu inicializar o Nexus.", createHashMap] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_UICOMMON_INITIALIZED_VAR, true];

[
    "uicommon.runtime",
    1,
    "ServoPeregrino_Organizador_UICommon",
    createHashMapFromArray [
        ["description", "Infraestrutura compartilhada de UI sem ownership de domínio."],
        ["stability", "EXPERIMENTAL_0_1"]
    ]
] call ServoPeregrino_Organizador_Nexus_fnc_registerCapability;

[
    "UICOMMON",
    "INFO",
    "UICommon inicializado.",
    createHashMapFromArray [["build", SERVO_PEREGRINO_ORGANIZADOR_UICOMMON_BUILD]]
] call ServoPeregrino_Organizador_Nexus_fnc_log;

[true, "UICOMMON_INITIALIZED", "UICommon inicializado com sucesso.", createHashMapFromArray [
    ["build", [] call ServoPeregrino_Organizador_UICommon_fnc_getBuildInfo]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
