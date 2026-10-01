if (!isServer) exitWith {
 [false,"WEAPONS_SERVER_ONLY","Reset is server-only."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
[] call ServoPeregrino_Organizador_Weapons_fnc_initializeLiveLifecycleTest
