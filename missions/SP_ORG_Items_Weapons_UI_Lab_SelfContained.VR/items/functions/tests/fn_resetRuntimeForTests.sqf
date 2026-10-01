#include "..\..\script_version.hpp"

if !(isNil "ServoPeregrino_Organizador_Nexus_fnc_unregisterCapability") then {
    {
        private _capabilityId = _x;
        if ([_capabilityId, 1] call ServoPeregrino_Organizador_Nexus_fnc_hasCapability) then {
            [_capabilityId, SERVO_PEREGRINO_ORGANIZADOR_ITEMS_PROVIDER] call ServoPeregrino_Organizador_Nexus_fnc_unregisterCapability;
        };
    } forEach [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_RUNTIME_CAPABILITY, SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_CAPABILITY];
};

missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_INITIALIZED_VAR, false];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_RUNTIME_VAR, createHashMap];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_REPOSITORY_VAR, createHashMap];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_TEST_RESULT_VAR, createHashMap];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_ITEMKIT_COUNTER_VAR, 0];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_CACHE_VAR, createHashMap];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_METRICS_VAR, createHashMap];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_CATALOG_BUILD_STATE_VAR, createHashMap];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_DRAFT_STATE_VAR, createHashMap];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_STATE_VAR, createHashMap];
missionNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_APPLICATION_STATE_VAR, createHashMap];
uiNamespace setVariable [SERVO_PEREGRINO_ORGANIZADOR_ITEMS_UI_DISPLAY_VAR, displayNull];

true
