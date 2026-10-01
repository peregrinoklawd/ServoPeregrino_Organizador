if (!isServer) exitWith {};

private _n = [] call ServoPeregrino_Organizador_Nexus_fnc_initialize;
private _u = [] call ServoPeregrino_Organizador_UICommon_fnc_initialize;
private _i = [] call ServoPeregrino_Organizador_Items_fnc_initialize;

diag_log format [
    "[SP_ORG] [SELF_CONTAINED_UI_LAB] SERVER_READY nexus=%1 uicommon=%2 items=%3 slots=%4",
    _n getOrDefault ["code","?"],
    _u getOrDefault ["code","?"],
    _i getOrDefault ["code","?"],
    playableSlotsNumber west
];
