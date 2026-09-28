if (!isServer) exitWith {};
if (isNil "ServoPeregrino_Organizador_Weapons_fnc_initialize") exitWith {diag_log "[SP_ORG] [WEAPONS] [LAB_ADDON_MISSING]"};
missionNamespace setVariable ["SP_ORG_Weapons_LabEnabled",true];
[] call ServoPeregrino_Organizador_Weapons_fnc_initialize;
private _marker = createMarker ["respawn_west",[2,0,0]];
_marker setMarkerType "Empty";
{
 _x params ["_name","_position"];
 private _box = createVehicle ["Box_NATO_Wps_F",_position,[],0,"CAN_COLLIDE"];
 clearWeaponCargoGlobal _box; clearMagazineCargoGlobal _box;
 clearItemCargoGlobal _box; clearBackpackCargoGlobal _box;
 _box setVariable ["SP_ORG_Weapons_labLabel",_name,true];
 missionNamespace setVariable ["SP_ORG_Weapons_Box_" + _name,_box,true];
 private _m = createMarker ["Weapons_" + _name,_position]; _m setMarkerType "mil_dot"; _m setMarkerText _name;
} forEach [["TRANSFER",[1,5,0]],["DUPLICATES",[5,5,0]],["ACCESSORIES",[9,5,0]]];
private _items = missionNamespace getVariable "SP_ORG_Weapons_Box_ACCESSORIES";
{_items addItemCargoGlobal [_x,4]} forEach ["optic_Aco","optic_Hamr","muzzle_snds_H","acc_pointer_IR","acc_flashlight","bipod_01_F_blk"];
_items addWeaponCargoGlobal ["hgun_P07_F",4];
_items addWeaponCargoGlobal ["launch_NLAW_F",4];
private _duplicates = missionNamespace getVariable "SP_ORG_Weapons_Box_DUPLICATES";
private _row = ["arifle_MX_F","","","",["30Rnd_65x39_caseless_mag",30],[],""];
_duplicates addWeaponWithAttachmentsCargoGlobal [_row,2];
private _capture = [_row] call ServoPeregrino_Organizador_Weapons_fnc_configurationFromWeaponArray;
private _ids = [];
for "_i" from 1 to 2 do {
 private _result = [(_capture get "data") get "configuration"] call ServoPeregrino_Organizador_Weapons_fnc_createWeaponInstance;
 if (_result get "success") then {_ids pushBack (((_result get "data") get "instance") get "instanceId")};
};
// These two records are UNBOUND. Their order MUST NOT be assigned to cargo rows.
diag_log format ["[SP_ORG] [WEAPONS] [DUPLICATES_UNBOUND] logicalIds=%1; physicalCount=2; mapping=UNPROVEN",_ids];
diag_log "[SP_ORG] [WEAPONS] [LAB_READY] 4 slots; all physical gates OPEN";
