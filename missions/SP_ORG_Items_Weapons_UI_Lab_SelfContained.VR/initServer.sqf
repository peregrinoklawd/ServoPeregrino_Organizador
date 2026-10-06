if (!isServer) exitWith {};

missionNamespace setVariable ["SP_ORG_Weapons_MissionFirst",true,true];
missionNamespace setVariable ["SP_ORG_Weapons_LabEnabled",true,true];

private _n = [] call ServoPeregrino_Organizador_Nexus_fnc_initialize;
private _u = [] call ServoPeregrino_Organizador_UICommon_fnc_initialize;
private _i = [] call ServoPeregrino_Organizador_Items_fnc_initialize;
private _w = [] call ServoPeregrino_Organizador_Weapons_fnc_initialize;

diag_log format [
    "[SP_ORG] [FULL_UI_LAB] SERVER_INIT nexus=%1 uicommon=%2 items=%3 weapons=%4",
    _n getOrDefault ["code","?"],
    _u getOrDefault ["code","?"],
    _i getOrDefault ["code","?"],
    _w getOrDefault ["code","?"]
];

if ((markerType "respawn_west") isEqualTo "") then {
    private _marker = createMarker ["respawn_west",[2,0,0]];
    _marker setMarkerType "Empty";
};

{
    _x params ["_name","_position"];
    private _old = missionNamespace getVariable ["SP_ORG_Weapons_Box_" + _name,objNull];
    if (!isNull _old) then {deleteVehicle _old;};
    private _box = createVehicle ["Box_NATO_Wps_F",_position,[],0,"CAN_COLLIDE"];
    clearWeaponCargoGlobal _box;
    clearMagazineCargoGlobal _box;
    clearItemCargoGlobal _box;
    clearBackpackCargoGlobal _box;
    _box setVariable ["SP_ORG_Weapons_labLabel",_name,true];
    missionNamespace setVariable ["SP_ORG_Weapons_Box_" + _name,_box,true];
    private _markerName = "Weapons_" + _name;
    if ((markerType _markerName) isEqualTo "") then {createMarker [_markerName,_position];};
    _markerName setMarkerType "mil_dot";
    _markerName setMarkerText _name;
} forEach [["TRANSFER",[1,5,0]],["DUPLICATES",[5,5,0]],["ACCESSORIES",[9,5,0]]];

private _accessories = missionNamespace getVariable ["SP_ORG_Weapons_Box_ACCESSORIES",objNull];
if (!isNull _accessories) then {
    {_accessories addItemCargoGlobal [_x,4]} forEach ["optic_Aco","optic_Hamr","muzzle_snds_H","acc_pointer_IR","acc_flashlight","bipod_01_F_blk"];
    _accessories addWeaponCargoGlobal ["hgun_P07_F",4];
    _accessories addWeaponCargoGlobal ["launch_NLAW_F",4];
};

private _liveInit = [] call ServoPeregrino_Organizador_Weapons_fnc_initializeLiveLifecycleTest;
diag_log format ["[SP_ORG] [FULL_UI_LAB] WEAPONS_LIVE_TEST_INIT result=%1",_liveInit];
diag_log format ["[SP_ORG] [FULL_UI_LAB] READY slots=%1 uiCommonBuild=%2 itemsBuild=%3 weaponsBuild=%4",
    playableSlotsNumber west,
    ([] call ServoPeregrino_Organizador_UICommon_fnc_getBuildInfo) getOrDefault ["build",""],
    ([] call ServoPeregrino_Organizador_Items_fnc_getBuildInfo) getOrDefault ["build",""],
    ([] call ServoPeregrino_Organizador_Weapons_fnc_getBuildInfo) getOrDefault ["build",""]
];
