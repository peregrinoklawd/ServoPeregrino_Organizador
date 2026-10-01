params [
 ["_unit",objNull,[objNull]],
 ["_slot","PRIMARY",[""]]
];

private _slotU = toUpperANSI _slot;
if (isNull _unit || {!(_unit isKindOf "CAManBase")} || {!(_slotU in ["PRIMARY","HANDGUN","SECONDARY"])}) exitWith {
 [false,"WEAPONS_UI_EQUIPMENT_TARGET_INVALID","Expected CAManBase and PRIMARY/HANDGUN/SECONDARY."] call ServoPeregrino_Organizador_Nexus_fnc_createResult
};

private _capture = [_unit,_slotU] call ServoPeregrino_Organizador_Weapons_fnc_captureWeaponConfiguration;
if !(_capture get "success") exitWith {
 if ((_capture getOrDefault ["code",""]) isEqualTo "WEAPONS_SLOT_EMPTY") then {
  [true,"WEAPONS_UI_EQUIPMENT_SLOT_EMPTY","Selected equipment slot is empty.",createHashMapFromArray [[
   "snapshot",createHashMapFromArray [
    ["schemaVersion","0.6-D-r2-equipment-view-candidate"],
    ["slot",_slotU],
    ["slotLabel",[_slotU] call ServoPeregrino_Organizador_Weapons_fnc_getUISlotLabel],
    ["equipped",false],
    ["weaponClass",""],
    ["weaponInfo",createHashMap],
    ["configuration",createHashMap],
    ["loadedState",createHashMap],
    ["magazineClass",""],
    ["opticInfo",createHashMap],
    ["muzzleInfo",createHashMap],
    ["pointerInfo",createHashMap],
    ["bipodInfo",createHashMap],
    ["magazineInfo",createHashMap]
   ]
  ]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
 } else {
  _capture
 };
};

private _data = _capture get "data";
private _cfg = _data get "configuration";
private _loaded = _data get "loadedState";
private _weaponClass = _cfg getOrDefault ["weaponClass",""];
private _weaponInfo = createHashMap;
private _weaponResult = [_weaponClass] call ServoPeregrino_Organizador_Weapons_fnc_getWeaponPresentationInfo;
if (_weaponResult get "success") then {_weaponInfo = (_weaponResult get "data") get "info"};

private _mag = _loaded getOrDefault ["primaryMagazine",[]];
private _magClass = if (_mag isEqualType [] && {count _mag >= 1}) then {_mag param [0,""]} else {""};

private _resolve = {
 params ["_className","_kind"];
 private _r = [_className,_kind] call ServoPeregrino_Organizador_Weapons_fnc_getClassPresentationInfo;
 if (_r get "success") then {(_r get "data") get "info"} else {
  createHashMapFromArray [["present",false],["className",_className],["displayName",if (_className isEqualTo "") then {"Nenhum"} else {_className}],["picture",""],["kind",_kind]]
 }
};

[true,"WEAPONS_UI_EQUIPMENT_SNAPSHOT","Read-only current equipment snapshot resolved.",createHashMapFromArray [[
 "snapshot",createHashMapFromArray [
  ["schemaVersion","0.6-D-r2-equipment-view-candidate"],
  ["slot",_slotU],
  ["slotLabel",[_slotU] call ServoPeregrino_Organizador_Weapons_fnc_getUISlotLabel],
  ["equipped",true],
  ["weaponClass",_weaponClass],
  ["weaponInfo",_weaponInfo],
  ["configuration",[_cfg] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
  ["loadedState",[_loaded] call ServoPeregrino_Organizador_Weapons_fnc_deepCopy],
  ["magazineClass",_magClass],
  ["opticInfo",[_cfg getOrDefault ["optic",""],"ITEM"] call _resolve],
  ["muzzleInfo",[_cfg getOrDefault ["muzzle",""],"ITEM"] call _resolve],
  ["pointerInfo",[_cfg getOrDefault ["pointer",""],"ITEM"] call _resolve],
  ["bipodInfo",[_cfg getOrDefault ["bipod",""],"ITEM"] call _resolve],
  ["magazineInfo",[_magClass,"MAGAZINE"] call _resolve]
 ]
]]] call ServoPeregrino_Organizador_Nexus_fnc_createResult
