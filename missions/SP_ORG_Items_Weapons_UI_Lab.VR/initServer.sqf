if (!isServer) exitWith {};

private _nexus = if (isNil "ServoPeregrino_Organizador_Nexus_fnc_initialize") then {
    createHashMapFromArray [["success",false],["code","NEXUS_MISSING"]]
} else {
    [] call ServoPeregrino_Organizador_Nexus_fnc_initialize
};

private _uiCommon = if (isNil "ServoPeregrino_Organizador_UICommon_fnc_initialize") then {
    createHashMapFromArray [["success",false],["code","UICOMMON_MISSING"]]
} else {
    [] call ServoPeregrino_Organizador_UICommon_fnc_initialize
};

private _items = if (isNil "ServoPeregrino_Organizador_Items_fnc_initialize") then {
    createHashMapFromArray [["success",false],["code","ITEMS_MISSING"]]
} else {
    [] call ServoPeregrino_Organizador_Items_fnc_initialize
};

private _weapons = if (isNil "ServoPeregrino_Organizador_Weapons_fnc_initialize") then {
    createHashMapFromArray [["success",false],["code","WEAPONS_MISSING"]]
} else {
    [] call ServoPeregrino_Organizador_Weapons_fnc_initialize
};

diag_log format [
    "[SP_ORG] [UI_LAB] SERVER_READY nexus=%1 uicommon=%2 items=%3 weapons=%4 slots=%5",
    _nexus getOrDefault ["code","?"],
    _uiCommon getOrDefault ["code","?"],
    _items getOrDefault ["code","?"],
    _weapons getOrDefault ["code","?"],
    playableSlotsNumber west
];
