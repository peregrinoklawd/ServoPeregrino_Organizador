params [
 ["_loadout",false],
 ["_targetSlot","PRIMARY",[""]]
];

private _slot = toUpperANSI _targetSlot;
private _slotIndex = ["PRIMARY","SECONDARY","HANDGUN"] find _slot;
if !(_loadout isEqualType [] && {count _loadout >= 10}) exitWith {
 [false,"WEAPONS_APPLICATION_LOADOUT_SHAPE_INVALID","Expected standard getUnitLoadout array with at least 10 domains."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};
if (_slotIndex < 0) exitWith {
 [false,"WEAPONS_APPLICATION_SLOT_INVALID","Expected PRIMARY, SECONDARY or HANDGUN."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _domains = [];
{
 _x params ["_name","_index"];
 if (_index != _slotIndex) then {
  _domains pushBack [_name,[(_loadout select _index)] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy];
 };
} forEach [
 ["PRIMARY",0],
 ["SECONDARY",1],
 ["HANDGUN",2]
];

{
 _x params ["_name","_index"];
 _domains pushBack [_name,[(_loadout select _index)] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy];
} forEach [
 ["UNIFORM",3],
 ["VEST",4],
 ["BACKPACK",5],
 ["HEADGEAR",6],
 ["GOGGLES",7],
 ["BINOCULAR",8],
 ["ASSIGNED_ITEMS",9]
];

private _fingerprint = str _domains;
[true,"WEAPONS_APPLICATION_PRESERVATION_FINGERPRINT","Stable non-target loadout preservation fingerprint created without mutation.",createHashMapFromArray [
 ["targetSlot",_slot],
 ["targetSlotIndex",_slotIndex],
 ["domains",_domains],
 ["fingerprint",_fingerprint]
]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
