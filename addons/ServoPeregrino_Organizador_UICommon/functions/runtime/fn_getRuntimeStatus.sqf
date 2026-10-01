#include "..\..\script_version.hpp"

[true, "UICOMMON_RUNTIME_STATUS", "Estado atual do UICommon.", createHashMapFromArray [
    ["initialized", missionNamespace getVariable [SERVO_PEREGRINO_ORGANIZADOR_UICOMMON_INITIALIZED_VAR, false]],
    ["build", [] call ServoPeregrino_Organizador_UICommon_fnc_getBuildInfo],
    ["themeTokens", [] call ServoPeregrino_Organizador_UICommon_fnc_getThemeTokens]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
