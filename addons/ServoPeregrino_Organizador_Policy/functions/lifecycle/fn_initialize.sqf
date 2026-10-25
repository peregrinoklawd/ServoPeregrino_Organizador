/* P1: register pure capabilities only. DO NOT load or activate server policy. */
if (isNil "ServoPeregrino_Organizador_Nexus_fnc_registerCapability") exitWith {
    diag_log "[SPORG_POLICY_P1] [INIT] NEXUS_MISSING capability registration unavailable";
};
private _provider = "ServoPeregrino_Organizador_Policy";
private _meta = createHashMapFromArray [
    ["phase", "P1_CORE_ONLY"], ["authority", "NONE_P1"],
    ["runtimePolicyLoaded", false], ["entrypoint", "STATIC_FUNCTIONS"]
];
private _a = ["policy.evaluate", 1, _provider, _meta] call ServoPeregrino_Organizador_Nexus_fnc_registerCapability;
private _b = ["policy.snapshot", 1, _provider, _meta] call ServoPeregrino_Organizador_Nexus_fnc_registerCapability;
diag_log format ["[SPORG_POLICY_P1] [INIT] evaluate=%1 snapshot=%2 state=CORE_ONLY_NO_LOADER_NO_AUTHORITY", _a getOrDefault ["code", "ERROR"], _b getOrDefault ["code", "ERROR"]];
